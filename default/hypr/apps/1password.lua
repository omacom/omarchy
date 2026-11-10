-- 1Password 8.12 renamed its app id from "1Password" to the reverse-DNS form,
-- so match both to keep older installs floating too.
local class = "^(1[pP]assword|com\\.onepassword\\.OnePassword)$"
o.window(class, { tag = "+floating-window" })
-- The remote-session service disables this rule while Gliff is connected.
o.window(class, { name = "omarchy-1password-screen-share", no_screen_share = true })
