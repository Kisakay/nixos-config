# i3 à côté de COSMIC — bonnes pratiques anti-casse :
# - COSMIC = Wayland, i3 = X11. Un seul greeter (cosmic-greeter) propose les
#   deux sessions au login. Aucun DM ajouté, aucun conflit.
# - Zéro mutation de $HOME : la conf i3 vit dans /etc/i3/config (option
#   services.xserver.windowManager.i3.configFile), les compagnons
#   (picom/rofi/alacritty/i3blocks/xsettingsd) dans /etc/xdg/*. $HOME reste
#   prioritaire : tout override local continue de gagner (précédence XDG).
# - Autostart i3 uniquement (exec i3) : picom, dunst, nm-applet, xsettingsd,
#   polkit, wallpaper. Rien de tout ça ne tourne sous COSMIC.
# - Portail : voir desktop/cosmic.nix (cosmic sous COSMIC, gtk sous i3).
# - NIXOS_OZONE_WL (force Wayland, défini globalement pour COSMIC) est unset
#   dans la session i3 pour rester en X11 natif.
# - cosmic-greeter lance les sessions X11 via `startx` (codé en dur en amont) :
#   sans xinit, la session meurt instantanément et on retombe sur le greeter.
{ pkgs, ... }:

{
  services.xserver.displayManager.startx.enable = true;

  services.xserver.windowManager.i3 = {
    enable = true;

    extraPackages = with pkgs; [
      dmenu
      i3status
      i3blocks
    ];

    extraSessionCommands = ''
      # X11 natif sous i3 : ne pas forcer Wayland (défini globalement pour COSMIC).
      unset NIXOS_OZONE_WL
      export _JAVA_AWT_NONREPARENTING=1
      export XCURSOR_THEME="breeze_cursors"
      export XCURSOR_SIZE="32"
    '';

    # Base : rice/i3/config (Catppuccin Mocha), nettoyée :
# - focus vim + flèches ajouté (manquait : impossible de naviguer au clavier)
# - move uniformisé (le rice mélangeait vim à gauche et flèche à droite)
# - doublons supprimés ($term x2, kill x2, terminal sur 2 touches)
# - typo corrigée (exec\ --no-startup-id)
# - split/layouts/resize/flottantes standard i3 ajoutés (efficacité)
# - $mod+v et $mod+e rendus aux standards i3 (split v / layout toggle),
#   clipboard déplacé sur $mod+c, emoji sur $mod+period, lock sur $mod+Ctrl+l
#   (conflit avec focus vim sinon)
# - chemins /etc (déclaratif) au lieu de ~/.config (impératif)
    configFile = pkgs.writeText "i3-config" ''
      # ─────────────────────────────────────────────
      # i3 — généré par NixOS (modules/nixos/desktop/i3.nix).
      # Ne pas éditer ici : `nixos-rebuild switch` régénère /etc/i3/config.
      # Source d'inspiration : rice/i3/config (Catppuccin Mocha).
      # Session choisie au login dans cosmic-greeter (i3 = X11, COSMIC = Wayland).
      # ─────────────────────────────────────────────
      set $mod Mod4
      set $term alacritty

      font pango:JetBrainsMono Nerd Font 10

      # Curseur X par défaut
      exec --no-startup-id xsetroot -cursor_name left_ptr

      # ── Terminal / launcher ──
      bindsym $mod+Return exec $term
      bindsym $mod+d exec sh -c 'command -v rofi >/dev/null && rofi -show drun'

      # ── Focus (vim + flèches) ──
      bindsym $mod+h focus left
      bindsym $mod+j focus down
      bindsym $mod+k focus up
      bindsym $mod+l focus right
      bindsym $mod+Left focus left
      bindsym $mod+Down focus down
      bindsym $mod+Up focus up
      bindsym $mod+Right focus right

      # ── Déplacement fenêtres (vim + flèches) ──
      bindsym $mod+Shift+h move left
      bindsym $mod+Shift+j move down
      bindsym $mod+Shift+k move up
      bindsym $mod+Shift+l move right
      bindsym $mod+Shift+Left move left
      bindsym $mod+Shift+Down move down
      bindsym $mod+Shift+Up move up
      bindsym $mod+Shift+Right move right

      # ── Split / layouts ──
      bindsym $mod+b split h
      bindsym $mod+v split v
      bindsym $mod+s layout stacking
      bindsym $mod+w layout tabbed
      bindsym $mod+e layout toggle split
      bindsym $mod+f fullscreen toggle
      bindsym $mod+Shift+space floating toggle
      bindsym $mod+space focus mode_toggle

      # ── Resize ──
      mode "resize" {
        bindsym h resize shrink width 10 px or 10 ppt
        bindsym j resize grow height 10 px or 10 ppt
        bindsym k resize shrink height 10 px or 10 ppt
        bindsym l resize grow width 10 px or 10 ppt
        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt
        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
      }
      bindsym $mod+r mode "resize"

      # ── Workspaces ──
      bindsym $mod+1 workspace 1
      bindsym $mod+2 workspace 2
      bindsym $mod+3 workspace 3
      bindsym $mod+4 workspace 4
      bindsym $mod+5 workspace 5
      bindsym $mod+6 workspace 6
      bindsym $mod+7 workspace 7
      bindsym $mod+8 workspace 8
      bindsym $mod+9 workspace 9

      bindsym $mod+Shift+1 move container to workspace 1
      bindsym $mod+Shift+2 move container to workspace 2
      bindsym $mod+Shift+3 move container to workspace 3
      bindsym $mod+Shift+4 move container to workspace 4
      bindsym $mod+Shift+5 move container to workspace 5
      bindsym $mod+Shift+6 move container to workspace 6
      bindsym $mod+Shift+7 move container to workspace 7
      bindsym $mod+Shift+8 move container to workspace 8
      bindsym $mod+Shift+9 move container to workspace 9

      # ── Écrans (noms repris du rice ; screen-setup.sh gère tour + laptop) ──
      set $main DP-8
      set $right DP-7
      set $laptop eDP-1

      workspace 1 output $main
      workspace 2 output $main
      workspace 3 output $main
      workspace 4 output $main
      workspace 5 output $main
      workspace 6 output $main
      workspace 7 output $right
      workspace 8 output $right
      workspace 9 output $right

      exec --no-startup-id /etc/i3/scripts/screen-setup.sh
      bindsym $mod+Shift+s exec --no-startup-id /etc/i3/scripts/screen-setup.sh
      exec --no-startup-id i3-msg 'workspace 1'

      # ── Système ──
      bindsym $mod+Shift+q kill
      bindsym $mod+Shift+c reload
      bindsym $mod+Shift+r restart
      bindsym $mod+Control+l exec sh -c 'command -v i3lock >/dev/null && i3lock -c 1e1e2e || loginctl lock-session'

      # ── Fichiers / emoji / presse-papier ──
      bindsym $mod+Shift+e exec sh -c 'command -v thunar >/dev/null && thunar || command -v nautilus >/dev/null && nautilus || xdg-open ~'
      bindsym $mod+c exec sh -c 'command -v copyq >/dev/null && copyq toggle'
      bindsym $mod+period exec sh -c 'command -v rofimoji >/dev/null && rofimoji'

      # ── Audio / luminosité / médias ──
      bindsym XF86AudioRaiseVolume exec pamixer -i 5
      bindsym XF86AudioLowerVolume exec pamixer -d 5
      bindsym XF86AudioMute exec pamixer -t
      bindsym XF86MonBrightnessUp exec brightnessctl set +5%
      bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next
      bindsym XF86AudioPrev exec playerctl previous

      # ── Screenshot ──
      bindsym Print exec --no-startup-id /etc/i3/scripts/screenshot.sh

      # ── Flottantes ──
      for_window [window_role="pop-up"] floating enable
      for_window [window_role="task_dialog"] floating enable
      for_window [class="Pavucontrol"] floating enable
      for_window [class="Nm-connection-editor"] floating enable
      for_window [class="Arandr"] floating enable
      for_window [class="Copyq"] floating enable

      # ── Décor Catppuccin Mocha (comme la barre du rice) ──
      default_border pixel 2
      default_floating_border pixel 2
      hide_edge_borders smart
      smart_gaps on
      gaps inner 8
      gaps outer 4
      client.focused          #89b4fa #89b4fa #1e1e2e #89b4fa #89b4fa
      client.focused_inactive #585b70 #585b70 #cdd6f4 #585b70 #585b70
      client.unfocused        #313244 #313244 #cdd6f4 #313244 #313244
      client.urgent           #f38ba8 #f38ba8 #1e1e2e #f38ba8 #f38ba8

      # ── Barre (conf déclarative /etc/xdg/i3blocks/config, issue du rice) ──
      bar {
          status_command i3blocks -c /etc/xdg/i3blocks/config
          position top
          tray_output primary

          colors {
              background #1e1e2e
              statusline #cdd6f4
              separator  #585b70

              focused_workspace  #89b4fa #89b4fa #1e1e2e
              active_workspace   #74c7ec #74c7ec #1e1e2e
              inactive_workspace #313244 #313244 #cdd6f4
              urgent_workspace   #f38ba8 #f38ba8 #1e1e2e
          }
      }

      # ── Autostart i3 uniquement (chaque ligne est guardée) ──
      exec --no-startup-id sh -c 'command -v xsettingsd >/dev/null && xsettingsd'
      exec --no-startup-id sh -c 'command -v dunst >/dev/null && dunst'
      exec --no-startup-id sh -c 'command -v nm-applet >/dev/null && nm-applet'
      exec --no-startup-id sh -c 'a=$(echo /run/current-system/sw/libexec/*authentication-agent-1); [ -x "$a" ] && exec "$a"'
      exec --no-startup-id sh -c 'command -v playerctld >/dev/null && playerctld'
      exec --no-startup-id sh -c 'command -v copyq >/dev/null && copyq'
      exec_always --no-startup-id /etc/i3/scripts/wallpaper.sh
      bindsym $mod+Shift+w exec --no-startup-id /etc/i3/scripts/wallpaper.sh image
    '';
  };

  # Outils i3 uniquement : rien ici ne touche COSMIC (pas de daemon global,
  # démarrage seulement via les exec i3 ci-dessus).
  environment.systemPackages = with pkgs; [
    alacritty
    rofi
    picom
    feh
    dunst
    libnotify
    networkmanagerapplet
    arandr
    xorg.xrandr
    xorg.xsetroot
    xorg.xauth # startx s'en sert pour le cookie X (.Xauthority)
    flameshot
    maim
    xclip
    xdotool
    pamixer
    playerctl
    brightnessctl
    copyq
    rofimoji
    xsettingsd
    mate.mate-polkit
    xfce.thunar
    i3lock-color
  ];

  # Compagnons : /etc/xdg = défauts système, $HOME reste prioritaire.
  # Scripts : /etc/i3/scripts (exécutables, versionnés dans rice/).
  environment.etc = {
    "xdg/picom/picom.conf".source = ../../../rice/picom/picom.conf;
    "xdg/rofi/config.rasi".source = ../../../rice/rofi/config.rasi;
    "xdg/alacritty/alacritty.toml".source = ../../../rice/alacritty/alacritty.toml;
    "xdg/i3blocks/config".source = ../../../rice/i3blocks/config;
    "xdg/xsettingsd/xsettingsd.conf".source = ../../../rice/xsettingsd/xsettingsd.conf;

    "i3/background".source = ../../../rice/background;

    "i3/scripts/screen-setup.sh" = {
      source = ../../../rice/i3/scripts/screen-setup.sh;
      mode = "0755";
    };
    "i3/scripts/wallpaper.sh" = {
      source = ../../../rice/i3/scripts/wallpaper.sh;
      mode = "0755";
    };
    "i3/scripts/screenshot.sh" = {
      source = ../../../rice/i3/scripts/screenshot.sh;
      mode = "0755";
    };
    "i3/scripts/now-playing.sh" = {
      source = ../../../rice/i3/scripts/now-playing.sh;
      mode = "0755";
    };
  };
}
