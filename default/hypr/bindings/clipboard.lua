-- Send with explicit mods to the focused surface by omitting the window target,
-- so universal clipboard shortcuts reach both normal windows and focused
-- layer-shell surfaces such as Omarchy panels. A virtual keyboard (wtype) won't
-- do: the physically held SUPER merges into the injected chord at the seat.
-- The down/up split works around Hyprland send_shortcut sometimes leaving
-- synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local keycodes = {}

-- Named injection scans the active group, which may have no Latin letters.
-- Injection delivers the key in group 0, so resolve the primary layout's
-- unmodified letter instead of assuming QWERTY positions: A/C/V/X also move
-- on AZERTY, Dvorak, and Colemak-DH layouts.
local function shortcut_keymap_options()
  -- main is the seat keyboard used by send_key_state, including for IPC paste.
  -- Read its effective rules on every invocation: another keyboard may have
  -- become active without any global input setting changing.
  local keyboard
  for _, device in ipairs(hl.get_devices and hl.get_devices() or {}) do
    if device.type == "keyboard" and device.main then
      keyboard = device
      break
    end
  end
  if not keyboard or not keyboard.layout or keyboard.layout == "" then
    return nil
  end

  local keymap = hl.get_config("input.kb_file") or ""
  if keymap ~= "" then
    -- A keymap replaces RMLVO; xkbcli rejects combining the two. Its optional
    -- file argument also requires the equals form rather than a separate word.
    return "--keymap=" .. o.shell_quote(keymap)
  end

  local options = {}
  for _, option in ipairs({ "layout", "variant", "model", "options", "rules" }) do
    local value = keyboard[option] or ""
    if value ~= "" then
      table.insert(options, "--" .. option .. " " .. o.shell_quote(value))
    end
  end
  return table.concat(options, " ")
end

local function shortcut_keycode(key)
  local options = shortcut_keymap_options()
  -- Unknown keyboards (or older Hyprland without device queries) retain native
  -- named-key resolution rather than guessing positions from global settings.
  if not options then
    return key
  end
  local lookup = "xkbcli how-to-type --disable-compose --keysym "
    .. options .. " " .. o.shell_quote(key:lower())
  if keycodes[lookup] then
    return keycodes[lookup]
  end

  local pipe = io.popen(lookup .. " 2>/dev/null", "r")
  local output = pipe and pipe:read("*a") or ""
  if pipe then pipe:close() end
  for line in output:gmatch("[^\r\n]+") do
    -- xkbcli uses XKB keycodes (evdev + 8), as send_key_state expects.
    -- Only group 1, level 1, without modifiers is the shortcut's base key.
    local code = line:match("^%s*(%d+)%s+%S+%s+1%s+.-%s+1%s+%[%s*%]%s*$")
    if code then
      keycodes[lookup] = "code:" .. code
      return keycodes[lookup]
    end
  end

  -- Retain named injection if the keymap cannot resolve a base letter.
  keycodes[lookup] = key
  return key
end

local function send_shortcut_once(mods, key)
  return function()
    local resolved_key = shortcut_keycode(key)
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = resolved_key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = resolved_key, state = "up" }))
    end, { timeout = 50, type = "oneshot" })
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
