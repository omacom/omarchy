-- Bound only once the chosen backend's own program is installed (Omarchy ships
-- every adapter): an aarch64 machine has no Superwhisper build, and
-- push-to-talk would hold Right Alt (AltGr) for nothing.
local pipe = io.popen("omarchy-default-dictation 2>/dev/null", "r")
local backend = pipe and pipe:read("*l")
if pipe then
  pipe:close()
end
if not (backend and backend:match("^[%w%-]+$") and not o.cmd_missing(backend)) then
  return
end

-- Alt + Space records while held. A tap shorter than this keeps recording
-- until the next press, so one chord covers push-to-talk and hands-free.
local tap_ms = 300
local locked, finishing, held_long, presses = false, false, false, 0

local function start()
  if locked then
    locked, finishing = false, true
    hl.exec_cmd("omarchy-dictation stop")
  else
    presses = presses + 1
    local press = presses
    held_long = false
    hl.timer(function()
      if press == presses then
        held_long = true
      end
    end, { timeout = tap_ms, type = "oneshot" })
    hl.exec_cmd("omarchy-dictation start")
  end
end

local function stop()
  if finishing then
    finishing = false
  elseif held_long then
    hl.exec_cmd("omarchy-dictation stop")
  else
    locked = true
  end
end

-- Right Alt always stops on release, which also ends a tap-locked recording
-- it joined, so the next Alt + Space press starts afresh.
local function stop_right_alt()
  locked = false
  hl.exec_cmd("omarchy-dictation stop")
end

o.bind_hold("ALT + SPACE", "Start dictation (push-to-talk)", start, "Stop dictation (push-to-talk)", stop)
-- A modifier's mask changes between its press and release. Match the keysym
-- independently of that mask; AltGr layouts use a different keysym.
o.bind_hold("ALT + Alt_R", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", stop_right_alt, { ignore_mods = true })
