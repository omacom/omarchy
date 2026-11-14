-- The model-specific hwdb maps the emoji scan code to KEY_PROG2 so it cannot
-- toggle Bluetooth through rfkill. Other special keys have model-specific actions.
local function read_dmi(name)
  local file = io.open("/sys/class/dmi/id/" .. name, "r")
  if not file then
    return ""
  end
  local value = file:read("*l") or ""
  file:close()
  return value
end

if read_dmi("sys_vendor") == "ASUSTeK COMPUTER INC."
    and read_dmi("product_name") == "ASUS Vivobook S 16 M5606UA_M5606UA" then
  o.bind("XF86Launch2", "Emojis", { panel = "omarchy.emojis" })
  -- KEY_F14 is XKB code 192; the default keysym is XF86Launch5.
  -- Expose Linux audio controls; ASUS Windows microphone algorithms are not available here.
  o.bind("code:192", "Microphone settings", { panel = "omarchy.audio" })
  o.bind("XF86Launch1", "Laptop hardware", { menu = "hardware" })
end
