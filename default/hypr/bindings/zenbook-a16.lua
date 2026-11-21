-- The ASUS Zenbook A16 UX3607OA keyboard turns its brightness keys back into
-- F5/F6 while Shift or Alt is held, so the modified brightness bindings in
-- media.lua never fire. Bind what the keyboard actually sends, on this model
-- only, since these are ordinary F-key chords everywhere else.

local paths = require("default.hypr.paths")

if not o.shell_succeeds(o.shell_quote(paths.omarchy_path .. "/bin/omarchy-hw-match") .. " UX3607OA") then
  return
end

o.bind("SHIFT + F6", "Brightness maximum", "omarchy-brightness-display 100%", { locked = true, repeating = true })
o.bind("SHIFT + F5", "Brightness minimum", "omarchy-brightness-display 1%", { locked = true, repeating = true })
o.bind("ALT + F6", "Brightness up precise", "omarchy-brightness-display +1%", { locked = true, repeating = true })
o.bind("ALT + F5", "Brightness down precise", "omarchy-brightness-display 1%-", { locked = true, repeating = true })
