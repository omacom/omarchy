-- /etc/mpv/scripts/disable-hwdec-on-nouveau.lua
-- Fix GH #17210 / #17211 - 4.5.0rc2 hwdec=auto-safe segfault on nouveau Kepler
local function has_nouveau()
    local f = io.open("/sys/module/nouveau", "r")
    if f then f:close() return true end
    local fm = io.open("/proc/modules", "r")
    if fm then
        for line in fm:lines() do
            if line:match("^nouveau%s") then fm:close() return true end
        end
        fm:close()
    end
    return false
end

if has_nouveau() then
    mp.set_property("hwdec", "no")
    mp.msg.warn("nouveau detected (GH #17210), forcing hwdec=no")
end
