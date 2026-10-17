-- Browser tags and styling.
o.window("((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)", { tag = "+chromium-based-browser" })
o.window("([fF]irefox|zen|librewolf)", { tag = "+firefox-based-browser" })
o.window({ tag = "chromium-based-browser" }, { tile = true })

-- Video apps: remove the chromium browser tag so they can float.
o.window("(^.+-youtube\\.com__.*$|^.+-app\\.zoom\\.us__wc_home.*$)", { tag = "-chromium-based-browser" })

-- Hide screen sharing notification windows.
-- The Chromium notification bar maps with an empty class under Wayland and its "Hide" button is broken.
o.window({ title = ".*is sharing.*" }, { workspace = "special silent" })

-- Localized titles are common words, so match them only on the classless notification bar.
o.window({
  class = "^$",
  title = ".*(compartilhando|compartiendo|partag|geteilt|freigegeben|condivid|udostępnia|deelt|предостав|демонстрирует|共有しています|正在共享|正在分享|正在共用).*",
}, {
  workspace = "special silent",
})

