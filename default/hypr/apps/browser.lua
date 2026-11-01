-- Browser tags and styling.
--
-- Browsers do not take focus when they ask for it. Omarchy turns
-- misc:focus_on_activate on globally (Hyprland defaults it off), so a running
-- single-instance browser that is handed a URL by another process -- a link
-- clicked anywhere, a second `chromium <url>` from a terminal -- activates the
-- window that owns the session and the view jumps to whichever workspace that
-- window lives on. Telegram opts out the same way (apps/telegram.lua).
--
-- The opt-out names the classes the browsers report instead of a substring of
-- them, because an Omarchy web app is a Chromium window too: its class is
-- chrome-<host>_<path>-Default (omarchy-webapp-window-class), which an
-- unanchored pattern catches. That matters off the browser's own path --
-- clicking a web app's notification runs the notification's default action, and
-- only when nothing was invoked does the shell raise the sender by class
-- (shell/plugins/notifications/Service.qml), so a web app whose activation
-- request is suppressed has nothing left to bring its window up.
--
-- A browser's own notification has no such escape: clicking a Teams or Slack
-- toast that came from a browser tab runs the same default action, the page
-- focuses its window and the browser asks Hyprland for the activation this rule
-- suppresses, so the click would only close the toast. No per-window switch
-- separates that request from a URL handoff -- both are the same client asking
-- to be raised -- so a browser that has to raise itself from a notification
-- needs the shell to focus the window the request named (issue #7738) rather
-- than a narrower rule here. The suffixes are the names the Chromium releases
-- ship under (chromium and chromium-browser
-- on one machine; google-chrome-stable/-beta/-dev/-unstable; Brave's
-- -beta/-dev/-nightly and Edge's -beta/-dev channel builds, which are their own
-- packages and report their own class; Vivaldi's -snapshot), none of which the
-- web app class can spell. The tags keep their unscoped patterns: apps/pip.lua
-- and the video rules below key off them for web apps.
o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })
o.window("^((google-)?[cC]hrom(e|ium)(-browser|-stable|-beta|-dev|-unstable)?|[bB]rave-browser(-beta|-dev|-nightly)?|[mM]icrosoft-edge(-beta|-dev)?|Vivaldi-stable|Vivaldi-snapshot|helium)$", { focus_on_activate = false })
o.window("^(([fF]irefox)(-developer-edition)?|zen|librewolf)$", { focus_on_activate = false })
o.window({ tag = "chromium-based-browser" }, { tile = true })

-- Video apps: remove the chromium browser tag so they can float.
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })

-- Hide screen sharing notification windows.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })
