-- Browser tags and styling.
--
-- Browsers do not take focus when they ask for it. Omarchy turns
-- misc:focus_on_activate on globally (Hyprland defaults it off), so a running
-- single-instance browser that is handed a URL by another process -- a link
-- clicked anywhere, a second `chromium <url>` from a terminal -- activates the
-- window that owns the session and the view jumps to whichever workspace that
-- window lives on. Telegram opts out the same way (apps/telegram.lua).
o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser", focus_on_activate = false })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser", focus_on_activate = false })
o.window({ tag = "chromium-based-browser" }, { tile = true })

-- Video apps: remove the chromium browser tag so they can float.
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })

-- Hide screen sharing notification windows.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })
