-- Cua Hyprland plugin input route. omarchy-toggle-cua-input owns this flag:
-- it lands here only after the plugin passed the package's compatibility
-- check and loaded, and it is removed by the same command.
--
-- The plugin's admission guard accepts exactly this keymap and nothing else,
-- so a plain US layout replaces Omarchy's default (Compose on Caps Lock,
-- both Shifts for Caps Lock) for as long as the flag is on.
hl.config({
  input = {
    kb_rules = "evdev",
    kb_model = "pc105",
    kb_layout = "us",
    kb_variant = "",
    kb_options = "",
    kb_file = "",
  },
  plugin = { cua = { enabled = true } },
})

-- The package never autoloads its module, and a loaded module does not
-- survive the session, so a session that starts with the flag on loads it
-- again, after the same compatibility check; a failed check turns the flag
-- off rather than leaving the keymap changed for nothing.
hl.on("hyprland.start", function()
  hl.exec_cmd("omarchy-toggle-cua-input --load")
end)
