-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "nautilus" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { omarchy = "nautilus-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled Omarchy applications, TUIs, and web apps.
  o.bind_preinstalled("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
  o.bind_preinstalled("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })
  o.bind_preinstalled("SUPER + SHIFT + Q", "Calculator", "omacalc")
  o.bind_preinstalled("XF86Calculator", "Calculator", "omacalc")
  o.bind_preinstalled("SUPER + SHIFT + M", "Music", { omarchy = "spotify" })
  o.bind_preinstalled("SUPER + SHIFT + ALT + M", "Music TUI", { tui = "cliamp", focus = true })
  if o.cmd_present("lazydocker") then
    o.bind_preinstalled("SUPER + SHIFT + D", "Docker", { tui = "omarchy-launch-docker-tui" })
  end
  o.bind_preinstalled("SUPER + SHIFT + G", "Signal", { omarchy = "signal" })
  o.bind_preinstalled("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind_preinstalled("SUPER + SHIFT + W", "Omawrite", { launch = "omawrite" })
  o.bind_preinstalled("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })

  o.bind_preinstalled("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
  o.bind_preinstalled("SUPER + SHIFT + ALT + A", "Grok", { webapp = "https://grok.com" })
  o.bind_preinstalled("SUPER + SHIFT + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
  o.bind_preinstalled("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
  o.bind_preinstalled("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
  o.bind_preinstalled("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
  o.bind_preinstalled("SUPER + SHIFT + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
  o.bind_preinstalled( "SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
  o.bind_preinstalled("SUPER + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
  o.bind_preinstalled("SUPER + SHIFT + S", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
  o.bind_preinstalled("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
  o.bind_preinstalled("SUPER + SHIFT + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })
end
