o.window("^(Bitwarden)$", { no_screen_share = true, tag = "+floating-window" })

-- The extension's popout asks for the width set in its preferences and a height of its own,
-- so float it without the shared 875x600 that would override that size.
o.window("chrome-nngceckbapebfimnlniiiahkandclblb-Default", {
  no_screen_share = true,
  float = true,
  center = true,
})
