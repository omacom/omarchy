-- Hotkeys for the preinstalled web apps in China, on the keys the global ones
-- use for the services they stand in for (docs/regions.md).
o.bind("SUPER + SHIFT + A", "AI", "omarchy-agent --or-webapp https://chat.deepseek.com/")
o.bind("SUPER + SHIFT + ALT + A", "Qwen", { webapp = "https://www.qianwen.com/" })
o.bind("SUPER + SHIFT + Y", "Bilibili", { webapp = "https://www.bilibili.com/" })
o.bind("SUPER + SHIFT + S", "Amap", { webapp = "https://www.amap.com/", focus = true })
o.bind("SUPER + SHIFT + X", "Weibo", { webapp = "https://weibo.com/" })
