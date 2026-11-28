-- Logitech MX Keys / MX Keys S -- action keys
--
-- keyd (/etc/keyd/logitech-mx-keys.conf) rewrites the MX Keys S / Mini chorded
-- action keys -- emoji, screenshot, dictation, lock -- to spare F14-F17, which
-- would otherwise land on unrelated shortcuts or nothing. Their mic-mute key
-- already emits a bare F13. The MX Keys (non-S) Fn+F4 / Fn+F5 Super+A / Super+D
-- chords are left untouched and nothing here binds them. Bind the rest to the
-- matching Omarchy command here.
--
-- Bound by keycode (code:191..195 == F13..F17): the F13-F24 keysyms are
-- missing from many non-US keymaps, so a plain "F14" bind would never match.
--
-- That config file is installed only when install/hardware/logitech-mx-keys.sh
-- detects one of these keyboards, so its presence gates these binds. F14-F17
-- come only from keyd's rewrite of that keyboard. The F13 bind is not
-- device-scoped (keyd passes the bare F13 through), so on a machine with an
-- MX Keys an F13 key on any other keyboard mutes the microphone too.

local function file_exists(path)
  local file = io.open(path, "r")
  if file then
    file:close()
    return true
  end
  return false
end

-- OMARCHY_MX_KEYS_KEYD_CONF overrides the gate path for tests.
local keyd_conf = os.getenv("OMARCHY_MX_KEYS_KEYD_CONF")
if not keyd_conf or keyd_conf == "" then
  keyd_conf = "/etc/keyd/logitech-mx-keys.conf"
end
if not file_exists(keyd_conf) then
  return
end

o.bind("code:191", "Mute microphone", "omarchy-audio-input-mute", { locked = true })
o.bind("code:192", "Emojis", "omarchy-shell shell toggle omarchy.emojis")
o.bind("code:193", "Screenshot", "omarchy-capture-screenshot")
o.bind("code:195", "Lock system", "omarchy-system-lock")

-- Same gate as default/hypr/bindings/dictation.lua: bind only once the chosen
-- dictation backend's own program is installed.
local pipe = io.popen("omarchy-default-dictation 2>/dev/null", "r")
local backend = pipe and pipe:read("*l")
if pipe then
  pipe:close()
end
if backend and backend:match("^[%w%-]+$") and not o.cmd_missing(backend) then
  o.bind("code:194", "Toggle dictation", "omarchy-dictation toggle")
end
