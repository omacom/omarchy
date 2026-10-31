-- Define terminal tag so themes and bindings can single terminals out. Omarchy
-- launches TUIs and its own terminal windows under dedicated app-ids
-- (org.omarchy.btop, org.omarchy.terminal, TUI.float, ...), so match those too.
-- The class is matched in full, so foot's other app-id needs spelling out.
o.window(
  "(Alacritty|kitty|com.mitchellh.ghostty|foot|org\\.codeberg\\.dnkl\\.foot|wezterm|org\\.omarchy\\..*|TUI\\..*)",
  { tag = "+terminal" }
)

-- Other terminals and apps with a terminal inside copy and paste on
-- Ctrl + Shift + C/V too, but aren't themed as terminals. This tag routes only
-- the universal clipboard, so Super + C doesn't send Ctrl + C (interrupt) and
-- Super + V doesn't type ^V. Tag your own the same way:
-- o.window("^myapp$", { tag = "+terminal-clipboard" })
o.window(
  "(org\\.kde\\.konsole|org\\.gnome\\.Ptyxis|org\\.gnome\\.Console|org\\.gnome\\.Terminal|com\\.gexperts\\.Tilix|rio|dev\\.warp\\.Warp)",
  { tag = "+terminal-clipboard" }
)
