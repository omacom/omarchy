if o.cmd_present("voxtype") then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "voxtype record toggle")
  o.bind("F9", "Start dictation (push-to-talk)", "voxtype record start")
  -- Transparent so keys pressed while F9 is held (including voxtype streaming output) can't shadow the release
  -- Non-consuming so ignore_mods doesn't swallow app shortcuts like Shift+F9 and Ctrl+F9
  o.bind("F9", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true, transparent = true, ignore_mods = true, non_consuming = true })
end
