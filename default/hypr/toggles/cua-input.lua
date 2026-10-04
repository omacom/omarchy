-- Agent keyboards own their keymaps; this flag leaves human input unchanged.
-- The option exists only while the module is loaded; setting it earlier is a config error at login.
if hl.get_config("plugin.cua.enabled") ~= nil then
  hl.config({ plugin = { cua = { enabled = true } } })
end

-- A mapped module does not survive logout; verify it again each session.
hl.on("hyprland.start", function()
  hl.exec_cmd("omarchy-toggle-cua-input --load")
end)
