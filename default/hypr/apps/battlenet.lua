-- Battle.net installs standalone under umu-launcher (bin/omarchy-install-gaming-battlenet),
-- so the launcher and each game get their own class: the launcher is battle.net.exe, the
-- installer battle.net-setup.exe. default/applications/battlenet.desktop already records
-- this as StartupWMClass=battle.net.exe.

-- The actual launcher: float-centered. Matched on class alone, because a window rule is
-- applied when the window is mapped and the launcher maps with the title "Battle.net Login",
-- only becoming "Battle.net" after sign-in. Its dialogs (folder pickers, updates) share the
-- class and are better floated too.
o.window({ class = "^battle\\.net\\.exe$" }, {
  float = true,
  center = true,
  size = { 1280, 800 },
})

-- Installer: drop decorations and backdrop blur/shadow so the Blizzard chrome
-- isn't framed by the WM.
o.window({ class = "^battle\\.net-setup\\.exe$" }, {
  float = true,
  center = true,
  decorate = false,
  no_blur = true,
  no_shadow = true,
})
