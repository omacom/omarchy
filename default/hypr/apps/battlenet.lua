-- Battle.net launches under Proton; all its windows share class steam_app_battlenet.

-- The launcher. A fixed 1280x800 fits a normal monitor. On a smaller or scaled
-- panel that constant is bigger than the screen, so the centered float opens
-- partly off-screen and the client's fullscreen request fights it: closing the
-- window snaps between the two. Cap each side at the monitor, leaving room for
-- the bar and the outer gaps. A later suppress_event replaces the global
-- maximize suppress, so maximize stays in this list. Games share the class and
-- not this title.
o.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net$" }, {
  float = true,
  center = true,
  size = { "min(1280,monitor_w-48)", "min(800,monitor_h-64)" },
  suppress_event = "fullscreen maximize",
})

-- Installer: drop decorations and backdrop blur/shadow so the Blizzard chrome
-- isn't framed by the WM.
o.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net Setup$" }, {
  decorate = false,
  no_blur = true,
  no_shadow = true,
})
