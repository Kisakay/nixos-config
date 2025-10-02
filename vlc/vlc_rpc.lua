VERSION = "1.3"

function descriptor()
  return { 
    title = "Now Playing File",
    version = VERSION,
    author = "Kisakay",
    url = "",
    capabilities = { "menu", "input-listener", "meta-listener" }
  }
end

local metadata = {}
local output_file = nil
local last_uri = nil

function activate()
  output_file = vlc.config.userdatadir() .. "/now_playing.txt"
  update_file()
  vlc.msg.info("[Now Playing] Extension activated")
end

function close()
  clear_file()
  vlc.msg.info("[Now Playing] Extension closed")
end

function deactivate()
  clear_file()
  vlc.msg.info("[Now Playing] Extension deactivated")
end

-- Menu
function menu()
  return { "Update Now Playing", "Clear Now Playing" }
end

function trigger_menu(id)
  if id == 1 then
    update_file()
  elseif id == 2 then
    clear_file()
  end
end

function input_changed()
  vlc.msg.dbg("[Now Playing] Input changed")
  update_file()
end

function meta_changed()
  vlc.msg.dbg("[Now Playing] Meta changed")
  update_file()
end

function playing_changed(status)
  vlc.msg.dbg("[Now Playing] Playing status changed: " .. tostring(status))
  update_file()
end

-- Core functions
function update_file()
  local new_metadata = get_metadata()
  
  local has_changed = false
  
  if new_metadata.is_playing ~= metadata.is_playing then
    has_changed = true
  elseif new_metadata.is_playing then
    local item = vlc.input.item()
    local current_uri = item and item:uri() or nil
    
    if current_uri ~= last_uri then
      has_changed = true
      last_uri = current_uri
    elseif new_metadata.title ~= metadata.title or
           new_metadata.artist ~= metadata.artist or
           new_metadata.album ~= metadata.album then
      has_changed = true
    end
  end
  
  if has_changed then
    metadata = new_metadata
    write_now_playing_file()
    vlc.msg.info("[Now Playing] File updated")
  end
end

function clear_file()
  local content = "NOT_PLAYING\n\n\n\n"
  write_to_file(content)
end

function get_metadata()
  local result = { is_playing = false }
  
  if not vlc.input.is_playing() then
    vlc.msg.dbg("[Now Playing] VLC not playing")
    return result
  end
  
  local item = vlc.input.item()
  if not item then
    vlc.msg.dbg("[Now Playing] No item")
    return result
  end
  
  local metas = item:metas()
  if not metas then
    vlc.msg.dbg("[Now Playing] No metas")
    return result
  end
  
  result.is_playing = true
  result.title = trim(metas["title"]) or ""
  result.artist = trim(metas["artist"]) or ""
  result.album = trim(metas["album"]) or ""
  result.filename = trim(metas["filename"]) or ""
  
  result.artwork_url = trim(metas["artwork_url"]) or 
                       trim(metas["art_url"]) or ""
  
  if item.info then
    local info = item:info()
    if info and not result.artwork_url or result.artwork_url == "" then
      result.artwork_url = trim(info["arturl"]) or ""
    end
  end
  
  vlc.msg.dbg("[Now Playing] Metadata: " .. (result.title or "no title"))
  
  return result
end

function get_artwork_base64()
  if not metadata.artwork_url or metadata.artwork_url == "" then
    return ""
  end
  
  local file_path = metadata.artwork_url:gsub("^file://", "")
  file_path = file_path:gsub("%%(%x%x)", function(h)
    return string.char(tonumber(h, 16))
  end)
  
  local file = io.open(file_path, "rb")
  if not file then
    vlc.msg.warn("[Now Playing] Cannot open artwork: " .. file_path)
    return ""
  end
  
  local data = file:read("*all")
  file:close()
  
  if not data or data == "" then
    vlc.msg.warn("[Now Playing] Artwork file is empty")
    return ""
  end
  
  if #data > 5000000 then -- 5MB max
    vlc.msg.warn("[Now Playing] Artwork too large: " .. #data .. " bytes")
    return ""
  end
  
  local encoded = base64_encode(data)
  vlc.msg.dbg("[Now Playing] Artwork encoded: " .. #data .. " bytes -> " .. #encoded .. " chars")
  return encoded
end

function base64_encode(data)
  local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  local result = {}
  
  for i = 1, #data, 3 do
    local b1, b2, b3 = data:byte(i, i+2)
    
    local n = b1 * 65536 + (b2 or 0) * 256 + (b3 or 0)
    
    local c1 = math.floor(n / 262144) % 64
    local c2 = math.floor(n / 4096) % 64
    local c3 = math.floor(n / 64) % 64
    local c4 = n % 64
    
    table.insert(result, b64chars:sub(c1 + 1, c1 + 1))
    table.insert(result, b64chars:sub(c2 + 1, c2 + 1))
    
    if b2 then
      table.insert(result, b64chars:sub(c3 + 1, c3 + 1))
    else
      table.insert(result, '=')
    end
    
    if b3 then
      table.insert(result, b64chars:sub(c4 + 1, c4 + 1))
    else
      table.insert(result, '=')
    end
  end
  
  return table.concat(result)
end

function write_now_playing_file()
  local lines = {}
  
  if metadata.is_playing then
    table.insert(lines, "PLAYING")
    table.insert(lines, metadata.album)
    table.insert(lines, metadata.title ~= "" and metadata.title or metadata.filename or "Unknown")
    table.insert(lines, metadata.artist)
    table.insert(lines, get_artwork_base64())
  else
    table.insert(lines, "NOT_PLAYING")
    table.insert(lines, "")
    table.insert(lines, "")
    table.insert(lines, "")
    table.insert(lines, "")
  end
  
  write_to_file(table.concat(lines, "\n"))
end

function trim(str)
  if not str then return nil end
  local result = str:match("^%s*(.-)%s*$")
  return result ~= "" and result or nil
end

function write_to_file(content)
  local file = io.open(output_file, "w")
  if not file then
    vlc.msg.err("[Now Playing] Cannot write to: " .. output_file)
    return
  end
  
  file:write(content)
  file:flush()
  file:close()
  vlc.msg.dbg("[Now Playing] File written: " .. output_file)
end