-- Agent keyboards own their keymaps; this flag leaves human input unchanged.
hl.config({ plugin = { cua = { enabled = true } } })

-- A mapped module does not survive logout; verify it again each session.
hl.on("hyprland.start", function()
  hl.exec_cmd("omarchy-toggle-cua-input --load")
end)
