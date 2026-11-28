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

-- Layouts that can't type Latin letters, and us variants that can't either:
-- Russian phonetic and Cherokee. Keep in sync with default/hypr/input.lua and
-- etc/mkinitcpio.conf.d/omarchy_hooks.conf.
local non_latin_layouts =
  " af am ara bd bg by et ge gr il in iq ir kg kh kz la lk mk mm mn mv np rs ru sy th tj ua "
local non_latin_us_variants = " chr rus "

local function non_latin(layout, variant)
  return non_latin_layouts:find(" " .. layout .. " ", 1, true)
    or (layout == "us" and non_latin_us_variants:find(" " .. variant .. " ", 1, true))
end

-- The first key that types the letter without modifiers on a layout.
local function letter_code(letter, layout, variant)
  local output = io.popen(string.format(
    "xkbcli how-to-type --disable-compose --layout %s --variant %s %s 2>/dev/null",
    o.shell_quote(layout),
    o.shell_quote(variant),
    o.shell_quote(letter:lower())
  ))
  if not output then return nil end

  local code = output:read("*a"):match("\n(%d+)%s[^\n]-%[ %]")
  output:close()
  return code
end

local function resolve_letter(letter, kb_layout, kb_variant)
  local variants = {}
  for variant in (kb_variant .. ","):gmatch("([^,]*),") do
    variants[#variants + 1] = variant:match("^%s*(.-)%s*$")
  end

  local latin, has_non_latin = {}, false
  local i = 0
  for layout in (kb_layout .. ","):gmatch("([^,]*),") do
    local layout = layout:match("^%s*(.-)%s*$")
    i = i + 1
    if non_latin(layout, variants[i] or "") then
      has_non_latin = true
    else
      latin[#latin + 1] = { layout, variants[i] or "" }
    end
  end
  if not has_non_latin then return letter end

  local code
  for _, entry in ipairs(latin) do
    local entry_code = letter_code(letter, entry[1], entry[2])
    if not entry_code or (code and entry_code ~= code) then return letter end
    code = entry_code
  end

  return code and "code:" .. code or letter
end

-- Hyprland looks a sent key name up in the active layout group only, so sending
-- C fails while a non-Latin group is active. Sending the keycode the letter sits
-- on works in every group, but only types that letter on Latin layouts that put
-- it on the same key, so the name stays otherwise: A on us,fr,ru, where it would
-- type Q under French. Without a non-Latin group the name always works. Reads
-- Hyprland's own layouts, personal overrides included, on the first press after
-- they change. A keymap file replaces them, so its letters keep their names.
local letter_cache = { layouts = nil, keys = {} }

function keyboard.letter(letter)
  if tostring(hl.get_config("input.kb_file") or "") ~= "" then return letter end

  local kb_layout = tostring(hl.get_config("input.kb_layout") or "us")
  local kb_variant = tostring(hl.get_config("input.kb_variant") or "")
  local layouts = kb_layout .. "\n" .. kb_variant
  if letter_cache.layouts ~= layouts then
    letter_cache = { layouts = layouts, keys = {} }
  end

  letter_cache.keys[letter] = letter_cache.keys[letter] or resolve_letter(letter, kb_layout, kb_variant)
  return letter_cache.keys[letter]
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
  -- is configured, and deduplicate entries shared between Hyprland and Fcitx.
  local commands, seen = {}, {}
  for _, entry in ipairs(layouts) do
    local key = entry[1] .. "\0" .. entry[2]
    if not seen[key] and not (entry[1] == "us" and entry[2] == "") and entry[1]:match("^[%w_]+$") and entry[2]:match("^[%w_-]*$") then
      seen[key] = true
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
