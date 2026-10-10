-- Browser tags and styling.
o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })
o.window({ tag = "chromium-based-browser" }, { tile = true })

-- Video apps: remove the chromium browser tag so they can float.
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })

-- Hide screen sharing notification windows.
o.window({ tag = "chromium-based-browser", title = "^(.* is sharing your screen\\.|.* is sharing a window\\.|.* is sharing a tab\\.)$" }, {
  workspace = "special silent",
  float = true,
  move = { "100%-w-40", "100%-w-40" },
  pin = true,
  no_focus = true
})
o.window({ tag = "firefox-based-browser", title = "^Firefox — Sharing Indicator$" }, {
  workspace = "special silent",
  float = true,
  move = { "100%-w-40", "100%-w-40" },
  pin = true,
  no_focus = true
})
