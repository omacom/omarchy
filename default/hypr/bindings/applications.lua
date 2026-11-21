-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "files" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { omarchy = "files-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled Omarchy applications, TUIs, and web apps.
  o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
  o.bind("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })
  o.bind("SUPER + SHIFT + Q", "Calculator", "omacalc")
  o.bind("XF86Calculator", "Calculator", "omacalc")
  if o.region_hotkey("Music") then
    o.bind("SUPER + SHIFT + M", "Music", { omarchy = "spotify" })
  end
  o.bind("SUPER + SHIFT + ALT + M", "Music TUI", { tui = "cliamp", focus = true })
  if o.cmd_present("lazydocker") then
    o.bind("SUPER + SHIFT + D", "Docker", { tui = "omarchy-launch-docker-tui" })
  end
  o.bind("SUPER + SHIFT + G", "Signal", { omarchy = "signal" })
  o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("SUPER + SHIFT + W", "Omawrite", { launch = "omawrite" })
  o.bind("SUPER + SHIFT + SLASH", "Passwords", { omarchy = "1password" })

  o.bind_webapp("SUPER + SHIFT + A", "ChatGPT", "https://chatgpt.com")
  o.bind_webapp("SUPER + SHIFT + ALT + A", "Grok", "https://grok.com")
  o.bind_webapp("SUPER + SHIFT + C", "Calendar", "https://app.hey.com/calendar/weeks/")
  o.bind_webapp("SUPER + SHIFT + E", "Email", "https://app.hey.com")
  o.bind_webapp("SUPER + SHIFT + ALT + E", "New email", "https://app.hey.com/messages/new?display=standalone&new_window=true")
  o.bind_webapp("SUPER + SHIFT + Y", "YouTube", "https://youtube.com/")
  o.bind_webapp("SUPER + SHIFT + ALT + G", "WhatsApp", "https://web.whatsapp.com/", { focus = true })
  o.bind_webapp("SUPER + SHIFT + CTRL + G", "Google Messages", "https://messages.google.com/web/conversations", { focus = true })
  o.bind_webapp("SUPER + SHIFT + P", "Google Photos", "https://photos.google.com/", { focus = true })
  o.bind_webapp("SUPER + SHIFT + S", "Google Maps", "https://maps.google.com/", { focus = true })
  o.bind_webapp("SUPER + SHIFT + X", "X", "https://x.com/")
  o.bind_webapp("SUPER + SHIFT + ALT + X", "X Post", "https://x.com/compose/post")
end
