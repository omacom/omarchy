package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
o = {
  shell_quote = function(value) return "'" .. value:gsub("'", "'\\''") .. "'" end,
  launch = function(value) return value end,
}
local exec = hl.exec_cmd
hl.exec_cmd = function(command)
  if command == "omarchy-launch-shell" then
    local file = assert(io.open(os.getenv("CURSOR_TEST_STAGE") .. "/session", "w"))
    file:write(os.getenv("WAYLAND_DISPLAY") .. "\n" .. os.getenv("HYPRLAND_INSTANCE_SIGNATURE"))
    file:close()
    exec("quickshell -p " .. o.shell_quote(os.getenv("CURSOR_TEST_STAGE")))
  elseif command:match("^hyprctl ") then
    exec(command)
  end
end
require("default.hypr.autostart")
hl.config({
  misc = { disable_hyprland_logo = true, disable_splash_rendering = true, background_color = "rgb(000000)", disable_watchdog_warning = true },
  xwayland = { enabled = false },
  cursor = { enable_hyprcursor = false },
})
hl.monitor({ output = "", mode = "640x480@60", position = "auto", scale = 1 })
hl.layer_rule({ match = { namespace = "omarchy-background" }, no_anim = true })
hl.bind("SUPER + Q", hl.dsp.exec_cmd("true"))
