-- Send with explicit mods to the focused surface by omitting the window target,
-- so universal clipboard shortcuts reach both normal windows and focused
-- layer-shell surfaces such as Omarchy panels. A virtual keyboard (wtype) won't
-- do: the physically held SUPER merges into the injected chord at the seat.
-- The down/up split works around Hyprland send_shortcut sometimes leaving
-- synthetic key state stuck/repeating.
-- https://github.com/hyprwm/Hyprland/discussions/14099
local function send_shortcut_once(mods, key)
  return function()
    hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "down" }))

    hl.timer(function()
      hl.dispatch(hl.dsp.send_key_state({ mods = mods, key = key, state = "up" }))
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

local keycode_cache = {}

local function add_xkb_option(command, name, value)
  if value ~= "" then
    table.insert(command, "--" .. name)
    table.insert(command, o.shell_quote(value))
  end
end

-- Hyprland's resolveKeycode maps a key name to a keysym and scans only the
-- active layout group. Thai, Russian, and other non-Latin groups have no
-- Latin C/V/X/A, so send_key_state raises "key not found". A "code:N" argument
-- skips that scan. N is an XKB keycode (evdev + 8), the same numbering the
-- keysym scan returns; a raw evdev code would press the neighboring key.
--
-- The code is the letter's position in the configured primary layout, not a
-- fixed QWERTY position. Dvorak, AZERTY, and Colemak put these letters
-- elsewhere, and the injected key has to be the same key Ctrl+letter uses
-- there. xkbcli how-to-type reports that position. A keymap file replaces the
-- kb_* rules, so those keep the named key and Hyprland resolves it against
-- the real keymap.
local function resolve_primary_keycode(key)
  if tostring(hl.get_config("input.kb_file") or "") ~= "" then
    return key
  end

  local config = {
    layout = tostring(hl.get_config("input.kb_layout") or "us"),
    variant = tostring(hl.get_config("input.kb_variant") or ""),
    model = tostring(hl.get_config("input.kb_model") or ""),
    options = tostring(hl.get_config("input.kb_options") or ""),
    rules = tostring(hl.get_config("input.kb_rules") or ""),
  }
  local cache_key = table.concat({
    key,
    config.layout,
    config.variant,
    config.model,
    config.options,
    config.rules,
  }, "\0")

  if keycode_cache[cache_key] then
    return keycode_cache[cache_key]
  end

  local command = { "xkbcli how-to-type" }
  add_xkb_option(command, "layout", config.layout)
  add_xkb_option(command, "variant", config.variant)
  add_xkb_option(command, "model", config.model)
  add_xkb_option(command, "options", config.options)
  add_xkb_option(command, "rules", config.rules)
  -- --keysym is a flag; the following word is the keysym itself. Look up the
  -- lowercase letter and accept only level 1. In us(3l) an uppercase A also
  -- sits on level 6 of another key, and that row is listed first.
  table.insert(command, "--keysym")
  table.insert(command, o.shell_quote(key:lower()))

  local pipe = io.popen(table.concat(command, " ") .. " 2>/dev/null")
  if not pipe then
    keycode_cache[cache_key] = key
    return key
  end

  local output = pipe:read("*a") or ""
  pipe:close()

  -- xkbcli numbers layouts and levels from 1. Take the unshifted letter on
  -- the primary layout, whichever group is active.
  for line in output:gmatch("[^\r\n]+") do
    local keycode, layout_index, level = line:match("^%s*(%d+)%s+%S+%s+(%d+)%s.-%s(%d+)%s+%[")
    if layout_index == "1" and level == "1" then
      local resolved = "code:" .. keycode
      keycode_cache[cache_key] = resolved
      return resolved
    end
  end

  -- xkbcli missing, or this keymap has no such letter. Keep today's named key
  -- rather than guessing a QWERTY position.
  keycode_cache[cache_key] = key
  return key
end

local function resolved_shortcut(mods, key)
  return function()
    send_shortcut_once(mods, resolve_primary_keycode(key))()
  end
end

local function universal_clipboard_shortcut(default_mods, default_key, terminal_mods, terminal_key)
  return function()
    if active_window_is_terminal() then
      send_shortcut_once(terminal_mods, resolve_primary_keycode(terminal_key))()
    else
      send_shortcut_once(default_mods, resolve_primary_keycode(default_key))()
    end
  end
end

o.bind("SUPER + A", "Select all", resolved_shortcut("CTRL", "A"))
o.bind("SUPER + C", "Universal copy", universal_clipboard_shortcut("CTRL", "C", "CTRL SHIFT", "C"))
-- Scripts paste the same way with `hyprctl dispatch 'o.universal_paste'`.
o.universal_paste = universal_clipboard_shortcut("CTRL", "V", "CTRL SHIFT", "V")
o.bind("SUPER + V", "Universal paste", o.universal_paste)
o.bind("SUPER + X", "Universal cut", resolved_shortcut("CTRL", "X"))
o.bind("SUPER + CTRL + V", "Clipboard manager", { panel = "omarchy.clipboard" })
