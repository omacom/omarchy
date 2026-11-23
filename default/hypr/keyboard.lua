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

-- Hyprland matches a keysym bind against what a key types without Shift, so a
-- bind on / never fires on the layouts below, which type / only with Shift.
-- They put punctuation on the key US types / on, so bind that key instead.
-- Period has the same problem on the French-derived layouts.
local needs_shift = {
  SLASH = { code = 61, layouts = " at az ba be cd ch cz de dk dz ee es fi fo fr hr hu it latam me ml no pt se si sk sn tg tr " },
  PERIOD = { code = 60, layouts = " be cd dz fr ml sn tg " },
}

-- Variants that move the letters around can put one on that key: F on bépo.
local function moves_letters(variant)
  return variant:find("dvorak") or variant:find("bepo") or variant:find("colemak") or variant:find("neo") or variant:find("workman")
end

function keyboard.key(keysym)
  local selected = keyboard.selected()
  local layout = (selected.XKBLAYOUT or "us"):match("^[^,]*")
  local variant = (selected.XKBVARIANT or ""):match("^[^,]*")
  local symbol = needs_shift[keysym]

  if symbol and symbol.layouts:find(" " .. layout .. " ", 1, true) and not moves_letters(variant) then
    return "code:" .. symbol.code
  end

  return keysym
end

-- Whether Right Alt is AltGr on any layout the user types with: one in
-- Hyprland's list, or a Fcitx 5 keyboard-* entry, which switches layouts while
-- Hyprland stays on its first. XKB itself says what each layout puts on Right
-- Alt, so no list of AltGr layouts has to be kept up to date.
function keyboard.altgr()
  local paths = require("default.hypr.paths")
  local selected = keyboard.selected()
  local variants, layouts = {}, {}
  for variant in ((selected.XKBVARIANT or "") .. ","):gmatch("([^,]*),") do
    variants[#variants + 1] = variant
  end
  for layout in ((selected.XKBLAYOUT or "us") .. ","):gmatch("([^,]*),") do
    layouts[#layouts + 1] = { layout, variants[#layouts + 1] or "" }
  end

  local profile = io.open(paths.config_home .. "/fcitx5/profile", "r")
  if profile then
    for name in profile:read("a"):gmatch("Name%s*=%s*keyboard%-(%S+)") do
      layouts[#layouts + 1] = { name:match("^([^-]*)%-?(.*)$") }
    end
    profile:close()
  end

  -- Only names XKB could know pass, since they end up on a command line.
  -- Plain US never maps Right Alt to AltGr, so skip xkbcli when nothing else
  -- is configured.
  local commands = {}
  for _, entry in ipairs(layouts) do
    if not (entry[1] == "us" and entry[2] == "") and entry[1]:match("^[%w_]+$") and entry[2]:match("^[%w_-]*$") then
      table.insert(commands, "xkbcli compile-keymap --layout " .. entry[1] .. " --variant '" .. entry[2] .. "' </dev/null 2>/dev/null")
    end
  end
  if #commands == 0 then
    return false
  end
  local pipe = io.popen(table.concat(commands, "; "), "r")
  local keymaps = pipe and pipe:read("a") or ""
  if pipe then
    pipe:close()
  end
  return keymaps:find("key <RALT>%s*{[^}]*ISO_Level3_Shift") ~= nil
end

return keyboard
