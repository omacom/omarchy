-- Browser tags and styling.
o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })

-- Force chromium-based browsers into a tile to deal with the --app bug.
-- Edge keeps the chromium tag, but this rule does not tile its class: native
-- Wayland image hovers crash when that class is forced to tile
-- (omacom/omarchy#5097). Firefox already tiles without this rule.
o.window({
  tag = "chromium-based-browser",
  class = "negative:[mM]icrosoft-edge",
}, { tile = true })

-- Video apps: remove the chromium browser tag so they can float.
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })

-- Hide screen sharing notification windows.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })
