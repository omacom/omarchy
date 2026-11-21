-- Send with explicit mods to the focused surface by omitting the window target,
-- so universal clipboard shortcuts reach both normal windows and focused
-- layer-shell surfaces such as Omarchy panels. A virtual keyboard (wtype) won't
-- do: the physically held SUPER merges into the injected chord at the seat.
-- The down/up split works around Hyprland send_shortcut sometimes leaving
-- synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
-- Configured rules are not the seat keymap: Fcitx can replace that keymap
-- without updating its reported layout. Resolve asynchronously from the actual
-- Wayland keymap, since querying this compositor from a Lua callback would block.
local requests = {}
local nonce_file = assert(io.open("/proc/sys/kernel/random/uuid"))
local request_prefix = nonce_file:read("*l")
nonce_file:close()
local request_sequence = 0

local function focused_window()
  local window = hl.get_active_window()
  return window and window.address or ""
end

local function seat_state()
  -- Metadata only guards against a device/group change during the round trip;
  -- the worker resolves from the actual keymap, never from these descriptions.
  for _, device in ipairs(hl.get_devices and hl.get_devices() or {}) do
    if device.type == "keyboard" and device.main then
      return table.concat({ device.address or "", device.active_keymap or "", device.active_layout_index or 0 }, "\0")
    end
  end
  return ""
end

local function resolve_next()
  local request = requests[1]
  if not request then return end

  request.timeout = hl.timer(function()
    if requests[1] == request and not request.started then
      table.remove(requests, 1)
      resolve_next()
    end
  end, { timeout = 5000, type = "oneshot" })
  hl.exec_cmd("omarchy-clipboard-keycode " .. request.id .. " " .. request.key:lower())
end

-- Called by omarchy-clipboard-keycode after it reads the seat's actual keymap.
-- Keep requests ordered, and ignore stale/duplicate responses or changed windows.
function o.clipboard_keycode_ready(id, code)
  local request = requests[1]
  if not request or request.id ~= id or request.started then return end
  request.started = true
  request.timeout:set_enabled(false)

  if focused_window() ~= request.window or seat_state() ~= request.seat then
    table.remove(requests, 1)
    resolve_next()
    return
  end

  local key = request.key
  if type(code) == "number" and code % 1 == 0 and code >= 8 and code <= 0xffffffff then
    key = "code:" .. code
  end

  -- Register cleanup first so even a native named-key error cannot stall the
  -- queue. A failed lookup retains named dispatch; it never guesses a layout.
  hl.timer(function()
    local ok, err = pcall(hl.dispatch, hl.dsp.send_key_state({ mods = request.mods, key = key, state = "up" }))
    table.remove(requests, 1)
    resolve_next()
    if not ok then error(err) end
  end, { timeout = 50, type = "oneshot" })
  hl.dispatch(hl.dsp.send_key_state({ mods = request.mods, key = key, state = "down" }))
end

local function send_shortcut_once(mods, key)
  return function()
    -- Reloads replace Lua state while old workers can still reply.
    request_sequence = request_sequence + 1
    o.clipboard_request_id = request_prefix .. ":" .. request_sequence
    table.insert(requests, { id = o.clipboard_request_id, mods = mods, key = key, window = focused_window(), seat = seat_state() })
    if #requests == 1 then resolve_next() end
  end
end

-- Lean on the terminal tag from default/hypr/apps/terminals.lua so there's one
-- definition of what counts as a terminal. Dynamic tags carry a trailing "*".
local function active_window_is_terminal()
  local window = hl.get_active_window()
  if not window then
    return false
  end

  for _, tag in ipairs(window.tags or {}) do
    if tag:gsub("%*$", "") == "terminal" then
      return true
    end
  end

  return false
end

local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
  return function()
    if active_window_is_terminal() then
      send_shortcut_once(terminal_mods, terminal_key)()
    else
      send_shortcut_once(default_mods, default_key)()
    end
  end
end

o.bind("SUPER + A", "Select all", send_shortcut_once("CTRL", "A"))
o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL SHIFT", "C"))
-- Scripts paste the same way with `hyprctl dispatch 'o.universal_paste'`.
o.universal_paste = universal_clipboard_shortcut("CTRL", "V", "CTRL SHIFT", "V")
o.bind("SUPER + V", "Universal paste", o.universal_paste)
o.bind("SUPER + X", "Universal cut", send_shortcut_once("CTRL", "X"))
o.bind("SUPER + CTRL + V", "Clipboard manager", { panel = "omarchy.clipboard" })
