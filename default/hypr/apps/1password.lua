-- 1Password 8.12 renamed its app id from "1Password" to the reverse-DNS form,
-- so match both for privacy and main-window geometry.
local app_class = "^(1[pP]assword|com\\.onepassword\\.OnePassword)$"

o.window(app_class, { no_screen_share = true })
o.window({ class = app_class, title = "^.+ — 1Password$" }, { tag = "+floating-window" })
