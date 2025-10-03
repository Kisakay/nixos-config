package main

import (
	"bytes"
	"crypto/md5"
	"encoding/base64"
	"encoding/hex"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/altfoxie/drpc"
	"github.com/fsnotify/fsnotify"
)

const (
	clientID        = "1396439427106078720"
	nowPlayingPath  = "/home/kisakay/.local/share/vlc/now_playing.txt"
	catboxUploadURL = "https://catbox.moe/user/api.php"
	httpTimeout     = 30 * time.Second
	defaultImage    = "vlc"
)

type State struct {
	Status  string
	Album   string
	Title   string
	Artist  string
	Artwork string
}

type RPCManager struct {
	client       *drpc.Client
	httpClient   *http.Client
	connected    bool
	artworkCache map[string]string
	currentArt   string
}

func NewRPCManager(clientID string) (*RPCManager, error) {
	client, err := drpc.New(clientID)
	if err != nil {
		return nil, err
	}

	return &RPCManager{
		client:       client,
		httpClient:   &http.Client{Timeout: httpTimeout},
		artworkCache: make(map[string]string),
	}, nil
}

func (r *RPCManager) Close() {
	if r.connected {
		r.client.Close()
		r.connected = false
	}
}

func readNowPlaying(path string) (*State, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}

	// Fichier vide ou en cours d'écriture
	if len(data) == 0 {
		return &State{Status: "NOT_PLAYING"}, nil
	}

	lines := strings.Split(string(data), "\n")

	// Nettoyer les lignes vides à la fin
	for len(lines) > 0 && strings.TrimSpace(lines[len(lines)-1]) == "" {
		lines = lines[:len(lines)-1]
	}

	if len(lines) < 4 {
		return &State{Status: "NOT_PLAYING"}, nil
	}

	state := &State{
		Status: strings.TrimSpace(lines[0]),
		Album:  strings.TrimSpace(lines[1]),
		Title:  strings.TrimSpace(lines[2]),
		Artist: strings.TrimSpace(lines[3]),
	}

	if len(lines) >= 5 {
		state.Artwork = strings.TrimSpace(lines[4])
	}

	return state, nil
}

func hashData(data []byte) string {
	hash := md5.Sum(data)
	return hex.EncodeToString(hash[:])
}

func (r *RPCManager) uploadToCatbox(imageData []byte, hash string) (string, error) {
	if url, exists := r.artworkCache[hash]; exists {
		return url, nil
	}

	body := &bytes.Buffer{}
	writer := multipart.NewWriter(body)

	writer.WriteField("reqtype", "fileupload")

	part, err := writer.CreateFormFile("fileToUpload", "artwork.jpg")
	if err != nil {
		return "", err
	}

	if _, err := part.Write(imageData); err != nil {
		return "", err
	}

	writer.Close()

	req, err := http.NewRequest("POST", catboxUploadURL, body)
	if err != nil {
		return "", err
	}
	req.Header.Set("Content-Type", writer.FormDataContentType())

	resp, err := r.httpClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("catbox returned status %d", resp.StatusCode)
	}

	urlBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	url := strings.TrimSpace(string(urlBytes))
	if url == "" {
		return "", fmt.Errorf("empty URL from catbox")
	}

	r.artworkCache[hash] = url
	return url, nil
}

func (r *RPCManager) processArtwork(base64Data string) string {
	if base64Data == "" {
		return defaultImage
	}

	imageData, err := base64.StdEncoding.DecodeString(base64Data)
	if err != nil {
		fmt.Printf("Failed to decode artwork: %v\n", err)
		return defaultImage
	}

	hash := hashData(imageData)

	if url, exists := r.artworkCache[hash]; exists {
		return url
	}

	fmt.Printf("Uploading artwork (%d bytes)...\n", len(imageData))
	url, err := r.uploadToCatbox(imageData, hash)
	if err != nil {
		fmt.Printf("Upload failed: %v\n", err)
		return defaultImage
	}

	fmt.Printf("Uploaded: %s\n", url)
	return url
}

func (r *RPCManager) Update(state *State) error {
	if state.Status == "NOT_PLAYING" {
		if r.connected {
			r.Close()
			r.currentArt = ""
			fmt.Println("VLC stopped. RPC hidden.")
		}
		return nil
	}

	if !r.connected {
		fmt.Println("Connecting to Discord...")
		if err := r.client.Connect(); err != nil {
			return fmt.Errorf("connection failed: %w", err)
		}
		r.connected = true
		fmt.Println("Connected.")
	}

	details := state.Title
	if state.Album != "" {
		details = fmt.Sprintf("%s: %s", state.Album, state.Title)
	}

	largeImage := defaultImage
	if state.Artwork != "" {
		newArt := r.processArtwork(state.Artwork)
		if newArt != defaultImage {
			largeImage = newArt
			r.currentArt = newArt
		} else if r.currentArt != "" {
			largeImage = r.currentArt
		}
	}

	largeImageText := fmt.Sprintf("On %s", state.Album)

	activity := drpc.Activity{
		Details: details,
		State:   state.Artist,
		Assets: &drpc.Assets{
			LargeImage: largeImage,
			LargeText:  largeImageText,
			SmallImage: defaultImage,
			SmallText:  "VLC media player",
		},
	}

	return r.client.SetActivity(activity)
}

func statesEqual(a, b *State) bool {
	if a == nil || b == nil {
		return a == b
	}
	return *a == *b
}

func watchFile(path string, onChange func(*State)) error {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		return err
	}
	defer watcher.Close()

	if err := watcher.Add(path); err != nil {
		return err
	}

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	// Debounce pour éviter les lectures multiples
	var debounceTimer *time.Timer

	for {
		select {
		case event := <-watcher.Events:
			if event.Op&fsnotify.Write == fsnotify.Write {
				// Annuler le timer précédent s'il existe
				if debounceTimer != nil {
					debounceTimer.Stop()
				}

				// Attendre 50ms avant de lire le fichier
				debounceTimer = time.AfterFunc(50*time.Millisecond, func() {
					state, err := readNowPlaying(path)
					if err != nil {
						// Ignorer silencieusement les erreurs de lecture
						return
					}
					onChange(state)
				})
			}
		case err := <-watcher.Errors:
			fmt.Printf("Watcher error: %v\n", err)
		case <-sigChan:
			return nil
		}
	}
}

func main() {
	rpc, err := NewRPCManager(clientID)
	if err != nil {
		fmt.Printf("Failed to create RPC: %v\n", err)
		os.Exit(1)
	}
	defer rpc.Close()

	fmt.Println("VLC Discord RPC with Catbox support")
	fmt.Println("Watching:", nowPlayingPath)
	fmt.Println()

	currentState, err := readNowPlaying(nowPlayingPath)
	if err != nil {
		currentState = &State{Status: "NOT_PLAYING"}
	} else {
		rpc.Update(currentState)
	}

	if err := watchFile(nowPlayingPath, func(newState *State) {
		if !statesEqual(currentState, newState) {
			if err := rpc.Update(newState); err != nil {
				fmt.Printf("Error updating RPC: %v\n", err)
			}
			currentState = newState
		}
	}); err != nil {
		fmt.Printf("Error watching file: %v\n", err)
	}

	fmt.Println("\nShutting down...")
	fmt.Println("Stopped.")
}
