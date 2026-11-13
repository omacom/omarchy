-- Battle.net launches under Proton; all its windows share class steam_app_battlenet.

-- The launcher floats. Its tray menu has the same title, so set no size or
-- position here: Battle.net restores the launcher's own and places the menu
-- where it was opened.
--
-- Battle.net also asks to go fullscreen, which fights the float on small or
-- scaled panels, so the close bind looks like a resize. Ignore that request.
-- suppress_event replaces the global "maximize" one, so maximize stays listed.
o.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net$" }, {
  float = true,
  suppress_event = "fullscreen maximize",
})

-- Installer: drop decorations and backdrop blur/shadow so the Blizzard chrome
-- isn't framed by the WM.
o.window({ class = "^steam_app_battlenet$", title = "^Battle\\.net Setup$" }, {
  decorate = false,
  no_blur = true,
  no_shadow = true,
})
