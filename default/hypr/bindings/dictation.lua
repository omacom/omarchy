-- Bound only once the chosen backend's own program is installed (Omarchy ships
-- every adapter): an aarch64 machine has no Superwhisper build, and
-- push-to-talk would hold Right Alt (AltGr) for nothing.
local pipe = io.popen("omarchy-default-dictation 2>/dev/null", "r")
local backend = pipe and pipe:read("*l")
if pipe then
  pipe:close()
end
if backend and backend:match("^[%w%-]+$") and not o.cmd_missing(backend) then
  -- Named, so apps such as the backend's settings can change these keys with
  -- `omarchy shortcut set`. A modifier on its own, like Right Alt, is matched
  -- independently of the modifier mask that changes between press and release;
  -- AltGr layouts send a different keysym.
  o.shortcut("omarchy.dictation.toggle", {
    description = "Toggle dictation",
    keys = "SUPER + CTRL + X",
    command = "omarchy-dictation toggle",
  })
  o.shortcut("omarchy.dictation.hold", {
    description = "Start dictation (push-to-talk)",
    release_description = "Stop dictation (push-to-talk)",
    keys = { "F9", "ALT + Alt_R" },
    command = "omarchy-dictation start",
    release = "omarchy-dictation stop",
  })
end
