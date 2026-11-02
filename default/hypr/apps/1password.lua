-- 1Password 8.12 renamed its app id from "1Password" to the reverse-DNS form,
-- so match both to keep older installs floating too.
o.window("^(1[pP]assword|com\\.onepassword\\.OnePassword)$", { no_screen_share = true, tag = "+floating-window" })

-- Move the pointer into Quick Access when it opens, without locking focus.
hl.on("window.open", function(window)
  if window.class == "com.onepassword.OnePassword" and window.title == "Quick Access — 1Password" then
    local position, size = window.at, window.size
    hl.dispatch(hl.dsp.cursor.move({ x = position.x + size.x / 2, y = position.y + size.y / 2 }))
  end
end)
