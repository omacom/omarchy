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
  -- A web app the region leaves out (docs/regions.md) gets no hotkey.
  local function bind_webapp(keys, description, dispatcher)
    if not o.region_omits_webapp(dispatcher.webapp) then
      o.bind(keys, description, dispatcher)
    end
  end

  o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
  o.bind("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })
  o.bind("SUPER + SHIFT + Q", "Calculator", "omacalc")
  o.bind("XF86Calculator", "Calculator", "omacalc")
  if not o.region_omits_webapp("https://open.spotify.com/") then
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

  bind_webapp("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
  bind_webapp("SUPER + SHIFT + ALT + A", "Grok", { webapp = "https://grok.com" })
  bind_webapp("SUPER + SHIFT + C", "Calendar", { webapp = "https://app.hey.com/calendar/weeks/" })
  bind_webapp("SUPER + SHIFT + E", "Email", { webapp = "https://app.hey.com" })
  bind_webapp("SUPER + SHIFT + ALT + E", "New email", { webapp = "https://app.hey.com/messages/new?display=standalone&new_window=true" })
  bind_webapp("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com/" })
  bind_webapp("SUPER + SHIFT + ALT + G", "WhatsApp", { webapp = "https://web.whatsapp.com/", focus = true })
  bind_webapp("SUPER + SHIFT + CTRL + G", "Google Messages", { webapp = "https://messages.google.com/web/conversations", focus = true })
  bind_webapp("SUPER + SHIFT + P", "Google Photos", { webapp = "https://photos.google.com/", focus = true })
  bind_webapp("SUPER + SHIFT + S", "Google Maps", { webapp = "https://maps.google.com/", focus = true })
  bind_webapp("SUPER + SHIFT + X", "X", { webapp = "https://x.com/" })
  bind_webapp("SUPER + SHIFT + ALT + X", "X Post", { webapp = "https://x.com/compose/post" })
end
