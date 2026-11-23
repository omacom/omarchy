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

-- Layouts that can't type Latin letters. Keep in sync with the list in
-- etc/mkinitcpio.conf.d/omarchy_hooks.conf.
local non_latin_layouts =
  " af am ara bd bg by et ge gr il in iq ir kg kh kz la lk mk mm mn mv np rs ru sy th tj ua "
-- us variants that can't type Latin letters either: Russian phonetic and Cherokee.
local non_latin_us_variants = " chr rus "

function keyboard.non_latin(layout, variant)
  return non_latin_layouts:find(" " .. layout .. " ", 1, true) ~= nil
    or (layout == "us" and non_latin_us_variants:find(" " .. (variant or "") .. " ", 1, true) ~= nil)
end

local function split(list)
  local items = {}
  for item in (list .. ","):gmatch("([^,]*),") do
    items[#items + 1] = item
  end
  return items
end

-- The selected layouts and variants as Hyprland gets them. Hyprland resolves
-- keybindings against the first entry in kb_layout, not the layout that's
-- currently active, so Omarchy's Latin-keysym bindings (SUPER + W and friends)
-- only fire when a Latin layout leads. Installing with a non-Latin one would
-- otherwise leave the desktop unusable, so us moves in front of it.
function keyboard.layouts()
  local selected = keyboard.selected()
  local kb_layout = selected.XKBLAYOUT or "us"
  local kb_variant = selected.XKBVARIANT or ""

  if not keyboard.non_latin(kb_layout:match("^[^,]*")) then
    return kb_layout, kb_variant
  end

  -- Variants pair with layouts by position. A list that already names us (as in
  -- "ru,us") moves that entry and its variant to the front rather than gaining a
  -- second us, which would make the toggle cycle through a duplicate.
  local layouts, variants = split(kb_layout), split(kb_variant)

  local us_variant = ""
  for i, layout in ipairs(layouts) do
    if layout == "us" and not keyboard.non_latin("us", variants[i]) then
      us_variant = variants[i] or ""
      table.remove(layouts, i)
      if variants[i] then table.remove(variants, i) end
      break
    end
  end

  table.insert(layouts, 1, "us")
  table.insert(variants, 1, us_variant)
  return table.concat(layouts, ","), table.concat(variants, ",")
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

-- Hyprland looks a sent key name up in the active layout group only, so sending
-- C fails while a non-Latin group is active. Sending the keycode the letter sits
-- on works in every group, but only types that letter on Latin layouts that put
-- it on the same key, so the name stays otherwise: A on us,fr,ru, where it would
-- type Q under French. Without a non-Latin group the name always works.
function keyboard.letter(letter)
  local kb_layout, kb_variant = keyboard.layouts()
  local variants = split(kb_variant)
  local latin, non_latin = {}, false
  for i, layout in ipairs(split(kb_layout)) do
    if keyboard.non_latin(layout, variants[i]) then
      non_latin = true
    else
      latin[#latin + 1] = { layout, variants[i] or "" }
    end
  end
  if not non_latin then return letter end

  local code
  for _, entry in ipairs(latin) do
    local entry_code = letter_code(letter, entry[1], entry[2])
    if not entry_code or (code and entry_code ~= code) then return letter end
    code = entry_code
  end

  return code and "code:" .. code or letter
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

return keyboard
