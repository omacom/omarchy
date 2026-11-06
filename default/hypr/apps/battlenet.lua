-- Battle.net launches under Proton; all its windows share class steam_app_battlenet.

-- The actual launcher: float-centered.
o.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net$" }, {
  float = true,
  center = true,
  size = { 1280, 800 },
})

-- Installer: drop decorations and backdrop blur/shadow so the Blizzard chrome
-- isn't framed by the WM.
o.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net Setup$" }, {
  decorate = false,
  no_blur = true,
  no_shadow = true,
})

-- Games started from the launcher (World of Warcraft and the rest) share its class
-- and Proton prefix. When follow_mouse focuses the launcher, Wine asks to activate
-- the running game, and the global focus_on_activate then hands it focus back and
-- warps the cursor onto it, so the launcher can't be hovered while a game is open.
-- The launcher's own windows (Battle.net, Battle.net - Chats and Groups, Blizzard
-- dialogs) keep focus_on_activate. A running game is no longer raised by Play; it
-- is marked urgent instead.
o.window({ class = "^steam_app_battlenet$", title = "negative:^(Battle\\.net|Blizzard).*$" }, {
  focus_on_activate = false,
})
