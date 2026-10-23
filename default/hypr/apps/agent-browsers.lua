-- Browsers launched with --class=agent-<name> stay on their own hidden workspace and never take focus.
o.window("agent-.*", { workspace = "special:agents silent", suppress_event = "activate fullscreen fullscreenoutput" })
