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

-- Layouts whose default Right Alt is ISO_Level3_Shift (AltGr), not Alt.
-- Hyprland matches keybinds against the first kb_layout entry, and Fcitx
-- keeps that entry on a Latin layout while the active group is Swedish (or
-- another AltGr layout). A bind on Alt_R then takes the key those layouts
-- need for @ and the rest of level 3.
local altgr_layouts = {
  ad = true, al = true, at = true, ba = true, be = true, br = true, ca = true,
  ch = true, cz = true, de = true, dk = true, ee = true, es = true, fi = true,
  fo = true, fr = true, gb = true, hr = true, hu = true, ie = true, is = true,
  it = true, latam = true, lt = true, lv = true, nl = true, no = true, pl = true,
  pt = true, ro = true, se = true, si = true, sk = true, tr = true,
}

function keyboard.layout_uses_altgr(layout)
  local code = tostring(layout or ""):match("^([%a]+)")
  return altgr_layouts[code or ""] == true
end

function keyboard.fcitx_keyboard_layouts()
  local paths = require("default.hypr.paths")
  local configured = os.getenv("FCITX_CONFIG_HOME")
  local profile = (configured and configured ~= "" and configured or paths.config_home .. "/fcitx5") .. "/profile"
  local file = io.open(profile, "r")
  if not file then
    return {}
  end

  local layouts = {}
  for name in file:read("a"):gmatch("Name%s*=%s*keyboard%-([%a]+)") do
    layouts[#layouts + 1] = name
  end
  file:close()
  return layouts
end

function keyboard.right_alt_is_altgr()
  local selected = keyboard.selected().XKBLAYOUT or "us"
  for layout in (selected .. ","):gmatch("([^,]*),") do
    if keyboard.layout_uses_altgr(layout) then
      return true
    end
  end
  for _, layout in ipairs(keyboard.fcitx_keyboard_layouts()) do
    if keyboard.layout_uses_altgr(layout) then
      return true
    end
  end
  return false
end

return keyboard
