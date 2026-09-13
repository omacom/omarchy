# Keybindings menu

The menu reads bindings collected inside the running Hyprland Lua state. It does not evaluate user configuration in a second interpreter or reconstruct action expressions.

`default/hypr/bootstrap.lua` installs `default.hypr.keybindings` before loading default and user modules. The collector wraps the real `hl.bind`, returns its original handle, and retains the original action. This covers both `o.bind` and direct `hl.bind`, including bindings registered later by a callback. Configuration loading remains Hyprland's responsibility.

`omarchy_keybindings.snapshot()` returns JSON containing a configuration-generation token and described, enabled bindings in registration order. Original key spellings come from the native handle, preserving keycodes and modifier aliases that `hyprctl binds` can omit. The menu formats the snapshot without a disk cache, so runtime enable/disable and registration changes are visible immediately. Removed handles are discarded along with their captured actions.

`omarchy_keybindings.invoke(generation, id)` validates the generation and current enabled state, then passes the retained action to `hl.dispatch`. Arbitrary Lua closures retain their captured variables. A selection from before a reload, or one removed/disabled while the menu is open, fails instead of executing a different or inactive action. A fresh UUID on every bootstrap prevents ID reuse across reloads or compositor restarts.

## Compatibility

Hyprland 0.56.2 crashes when `is_enabled()` is called on an expired keybinding handle. Its native `tostring` implementation safely reports `HL.Keybind(expired)`, which the collector checks before accessing any handle property. This is an expiry guard for real handles, not a replacement implementation of Hyprland APIs. The VM test exercises unbind, removal, disabled state, and re-enabling.

The entrypoint must load Omarchy's bootstrap before registering bindings, as the shipped configuration already does. The upgrade migration reloads an existing graphical session without rewriting user configuration; an offline upgrade takes effect at the next login. If the menu is invoked before the collector is loaded, it asks for a Hyprland reload rather than falling back to configuration replay.

Only bindings with descriptions appear. The small set of intentionally grouped alternative chords share the same real action object; unrelated actions with the same description remain separate. Identical display rows are disambiguated so either action can be selected. The two browser-extension shortcuts remain explicit menu entries because they are not Hyprland bindings.

## Tests

- `test/shell.d/keybindings-registry-test.sh`: retained actions, metadata serialization, disabled/removed handles, repeated installation, stale IDs, and the upgrade migration.
- `test/shell.d/keybindings-menu-test.sh`: presentation and alternative chords, extra modifiers/keycodes, control characters and punctuation, duplicate selection, invalid IPC responses, and listing with an unusable Lua interpreter and an infinite loop in the user configuration.
- `test/acceptance.d/keybindings-test.sh`: real VM configuration containing live list queries, simultaneous listings without configuration side effects, native dispatchers and closures, submaps, enable/disable, removed handles, stale selections, and actual menu search/selection with screenshots.

Run the graphical test only in a disposable VM, following `agents/skills/acceptance-tests.md`. QMP keyboard checks additionally verify global shortcuts through the VM's virtual keyboard; in-guest `wtype` is used only for menu controls.
