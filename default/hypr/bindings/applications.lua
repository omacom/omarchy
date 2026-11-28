local keyboard = require("default.hypr.keyboard")

-- Essential application bindings.
o.bind("SUPER + RETURN", "Terminal", o.launch_terminal())
o.bind("SUPER + SHIFT + RETURN", "Browser", { omarchy = "browser" })

-- Some laptop keyboards and every numpad emit KP_Enter for Enter. Applications
-- treat the two keys the same, so the bindings should too. The mirrors carry no
-- description so the keybindings menu does not list each action twice.
o.bind("SUPER + KP_Enter", nil, o.launch_terminal())
o.bind("SUPER + SHIFT + KP_Enter", nil, { omarchy = "browser" })
o.bind("SUPER + SHIFT + F", "File manager", { omarchy = "files" })
o.bind("SUPER + ALT + SHIFT + F", "File manager (cwd)", { omarchy = "files-cwd" })
o.bind("SUPER + SHIFT + B", "Browser", { omarchy = "browser" })
o.bind("SUPER + SHIFT + ALT + B", "Browser (private)", { omarchy = "browser --private" })
o.bind("SUPER + SHIFT + N", "Editor", { omarchy = "editor" })

if o.preinstalled_bindings_enabled() then
  -- Bindings for preinstalled Omarchy applications, TUIs, and web apps.
  o.bind("SUPER + ALT + RETURN", "Tmux", { omarchy = "terminal-tmux" })
  o.bind("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })
  o.bind("SUPER + ALT + KP_Enter", nil, { omarchy = "terminal-tmux" })
  o.bind("SUPER + CTRL + KP_Enter", nil, { omarchy = "terminal-herdr" })
  o.bind("SUPER + SHIFT + Q", "Calculator", "omacalc")
  o.bind("XF86Calculator", "Calculator", "omacalc")
  o.bind("SUPER + SHIFT + ALT + M", "Music TUI", { tui = "cliamp", focus = true })
  if o.cmd_present("lazydocker") then
    o.bind("SUPER + SHIFT + D", "Docker", { tui = "omarchy-launch-docker-tui" })
  end
  o.bind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^obsidian$" })
  o.bind("SUPER + SHIFT + W", "Omawrite", { launch = "omawrite" })
  o.bind("SUPER + SHIFT + " .. keyboard.key("SLASH"), "Passwords", { omarchy = "1password" })

  -- Hotkeys for apps and web apps whose services depend on the region
  -- (docs/regions.md).
  require("default.hypr.require_optional").module("default.hypr.bindings.regions." .. o.region())
end
