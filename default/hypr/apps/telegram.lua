-- Prevent Telegram from stealing focus on new messages.
--
-- `focus_on_activate` is only a misc: config option, never a window rule, so
-- a rule carrying it parses cleanly and does nothing. `suppress_event` is the
-- window-rule key Hyprland honours for app-initiated focus requests.
--
-- An app-specific `suppress_event` replaces rather than merges with the
-- global `suppress_event = "maximize"` in default/hypr/windows.lua, so
-- "maximize" is repeated here. Telegram Desktop appends a hash of its install
-- path to its app-id when it is not installed system-wide
-- (org.telegram.desktop._<hash>), and Hyprland full-matches the class regex,
-- so the pattern keeps a trailing .* to cover those installs too.
o.window("^org\\.telegram\\.desktop.*$", {
  suppress_event = "maximize activate activatefocus",
})
