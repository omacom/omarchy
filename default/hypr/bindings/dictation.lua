-- Backends can take over an Omarchy dictation chord with hl.unbind(keys).
-- Keep one entry per chord: unbinding it removes both press and release.
o.dictation_keys = {}
local function bind(keys, description, command, options)
  o.bind(keys, description, command, options)
  o.dictation_keys[keys] = true
end

if o.shell_succeeds("omarchy-default-dictation") then
  bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  bind("F9", "Start dictation (push-to-talk)", "omarchy-dictation start")
  bind("F9", "Stop dictation (push-to-talk)", "omarchy-dictation stop", { release = true })
  -- A modifier's mask changes between its press and release. Match the keysym
  -- independently of that mask; AltGr layouts use a different keysym.
  bind("ALT + Alt_R", "Start dictation (push-to-talk)", "omarchy-dictation start", { ignore_mods = true })
  bind("ALT + Alt_R", "Stop dictation (push-to-talk)", "omarchy-dictation stop", { release = true, ignore_mods = true })
end
