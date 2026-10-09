# Dictation key ownership

Omarchy installs its dictation shortcuts when a backend is selected. `o.dictation_keys` records each chord installed by `default/hypr/bindings/dictation.lua` as a table entry whose value is `true`. Press and release bindings share one entry. The table is reset on every configuration load and is empty without a selected backend or when Omarchy's default bindings are disabled.

The registry records ownership, not shortcut actions. A backend checks the chord strings it intends to handle natively.

The selected backend's generated `shortcuts.lua` loads after Omarchy's bindings. A backend that handles a chord natively can remove Omarchy's binding before installing its own:

```lua
local keys = "F9"
if o.dictation_keys[keys] then
  hl.unbind(keys)
end
-- Register the backend's native shortcut here.
```

Call `hl.unbind()` once per chord; it removes both press and release bindings. The registry describes Omarchy's default chords, so it remains available for integrations that need to check them after taking ownership. Personal bindings load afterwards and can override the backend's choices.
