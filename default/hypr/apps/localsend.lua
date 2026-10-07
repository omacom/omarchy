-- Float LocalSend and fzf file picker.
local localsend = "(org\\.localsend\\.)?localsend(_app)?"
o.window("Share", { float = true, center = true })
o.window(localsend, { float = true, center = true, size = { 1100, 700 } })
o.transparent_window(localsend)
