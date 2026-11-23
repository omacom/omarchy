-- The keyboard layout picked at install time. The installer and first-boot
-- setup persist it to /etc/vconsole.conf, so Hyprland reads it from there
-- instead of rewriting every user's config.

local keyboard = {}

local function read_values(path)
  local values = {}
  local file = io.open(path, "r")
  if not file then
    return values
  end

  for line in file:lines() do
    local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
    if key and value then
      value = value:gsub("%s+#.*$", "")
      value = value:gsub('^"(.*)"$', "%1")
      value = value:gsub("^'(.*)'$", "%1")
      values[key] = value
    end
  end

  file:close()
  return values
end

function keyboard.selected()
  local paths = require("default.hypr.paths")
  local values = read_values(paths.config_home .. "/omarchy/keyboard-layouts")
  if values.XKBLAYOUT then return values end
  return keyboard.installed()
end

function keyboard.vconsole()
  return read_values("/etc/vconsole.conf")
end

-- Choices whose console keymap is plain US but whose desktop layout is not:
-- Korean keeps US letters, and Lao is non-Latin, so US still leads. Korean
-- installs take kr104, which adds Right Alt and Right Ctrl as 한/영 and 한자;
-- plain kr is what earlier installs saved.
local desktop_overrides = { kr = true, ["kr:kr104"] = true, la = true }

function keyboard.installed()
  local values = keyboard.vconsole()
  local override = read_values("/etc/omarchy/input-method").XKB_LAYOUT
  if desktop_overrides[override]
    and (values.XKBLAYOUT or "us") == "us"
    and (values.XKBVARIANT or "") == "" then
    values.XKBLAYOUT, values.XKBVARIANT = override:match("^([^:]*):?(.*)$")
  end
  return values
end

-- Japanese (JIS) keyboards put +, ^, and the Henkan/Muhenkan keys where US
-- keyboards don't, so a few defaults only apply when that layout leads.
function keyboard.jis()
  local layout = keyboard.selected().XKBLAYOUT or "us"
  return layout:match("^[^,]*") == "jp"
end

-- What each key types without Shift on the leading layout: the keysyms it
-- types anywhere, and the one on each keycode. Read once per config load.
local unshifted

local function unshifted_keysyms()
  if unshifted then return unshifted end
  unshifted = { typed = {}, at = {} }

  local selected = keyboard.selected()
  local layout = (selected.XKBLAYOUT or "us"):match("^[^,]*")
  local variant = (selected.XKBVARIANT or ""):match("^[^,]*")
  if not layout:match("^[%w_-]+$") or not variant:match("^[%w_-]*$") then return unshifted end

  local command = "xkbcli compile-keymap --layout " .. layout
  if variant ~= "" then command = command .. " --variant " .. variant end
  local pipe = io.popen(command .. " </dev/null 2>/dev/null")
  if not pipe then return unshifted end
  local keymap = pipe:read("*a") or ""
  pipe:close()

  local codes = {}
  for name, code in keymap:gmatch("<([%w_]+)>%s*=%s*(%d+)%s*;") do
    codes[name] = tonumber(code)
  end

  -- Short entries read `{ [ minus, underscore ] }`; longer ones name a type and
  -- then `symbols[1]= [ ssharp, ... ]` across several lines.
  for name, body in keymap:gmatch("key%s+<([%w_]+)>%s*(%b{})") do
    local keysym = body:match("symbols%[[^%]]*%]%s*=%s*%[%s*([%w_]+)") or body:match("[{,]%s*%[%s*([%w_]+)")
    if keysym then
      unshifted.typed[keysym:lower()] = true
      if codes[name] then unshifted.at[codes[name]] = keysym:lower() end
    end
  end

  return unshifted
end

-- Hyprland matches a keysym bind against what the key types without Shift, so
-- a bind on / never fires where / needs Shift, as on most European layouts.
-- Those layouts get the key US keyboards type it on instead, as long as that
-- key types punctuation there rather than a letter (F on bépo, Z on Dvorak).
local punctuation = { minus = true, equal = true, exclam = true, period = true, colon = true, semicolon = true, comma = true, apostrophe = true }

function keyboard.key(keysym, code)
  local keysyms = unshifted_keysyms()
  if keysyms.typed[keysym:lower()] or not punctuation[keysyms.at[code]] then
    return keysym
  end

  return "code:" .. code
end

return keyboard
