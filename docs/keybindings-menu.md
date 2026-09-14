# Keybindings menu

The menu reads bindings collected inside the running Hyprland Lua state. It does not evaluate user configuration in a second interpreter or reconstruct action expressions.

`default/hypr/bootstrap.lua` installs `default.hypr.keybindings` before loading default and user modules. The collector wraps the real `hl.bind`, returns its original handle, and retains the original action. This covers both `o.bind` and direct `hl.bind`, including bindings registered later by a callback. Configuration loading remains Hyprland's responsibility.

`omarchy_keybindings.snapshot()` returns JSON containing a configuration-generation token and described, enabled bindings in registration order. Original key spellings come from the native handle, preserving keycodes and modifier aliases that `hyprctl binds` can omit. The menu formats the snapshot without a disk cache, so runtime enable/disable and registration changes are visible immediately. Removed handles are discarded along with their captured actions.

`omarchy_keybindings.invoke(generation, id)` validates the generation and current enabled state, then passes the retained action to `hl.dispatch`. Arbitrary Lua closures retain their captured variables. A selection from before a reload, or one removed/disabled while the menu is open, fails instead of executing a different or inactive action. A fresh UUID on every bootstrap prevents ID reuse across reloads or compositor restarts.

## Compatibility

Hyprland 0.56.2 crashes when `is_enabled()` is called on an expired keybinding handle. Its native `tostring` implementation safely reports `HL.Keybind(expired)`, which the collector checks before accessing any handle property. This is an expiry guard for real handles, not a replacement implementation of Hyprland APIs. The VM test exercises unbind, removal, disabled state, and re-enabling.

The entrypoint must load Omarchy's bootstrap before registering bindings, as the shipped configuration already does. The upgrade migration attempts to reload an existing graphical session; a stale compositor signature does not block subsequent migrations, and an offline upgrade takes effect at the next login. For a custom entrypoint without the bootstrap, the migration prints the exact `dofile` line and explains that it must precede any bindings or module imports, leaving user Lua intact. If the collector is unavailable, the menu reports reload and bootstrap recovery instructions. Interactive failures also send a desktop notification; clicking the bootstrap notification opens the full instructions in a terminal so the notification's three-line limit cannot hide them. `--print` reports errors only on stderr. Rejected selections, including stale generations and disabled bindings, ask the user to reopen the menu.

Only bindings with descriptions appear. The small set of intentionally grouped alternative chords share the same real action object; unrelated actions with the same description remain separate. Identical display rows are disambiguated so either action can be selected. The two browser-extension shortcuts remain explicit menu entries because they are not Hyprland bindings.

## Tests

- `test/shell.d/keybindings-registry-test.sh`: retained actions, metadata serialization, disabled/removed handles, repeated installation, stale IDs, and the upgrade migration.
- `test/shell.d/keybindings-menu-test.sh`: presentation and alternative chords, extra modifiers/keycodes, control characters and punctuation, duplicate selection, invalid IPC responses, an assertion that no external Lua interpreter is started, and visible errors for unavailable registries and failed selections.
- `test/acceptance.d/keybindings-test.sh`: real VM configuration containing live list queries, simultaneous listings without configuration side effects, native dispatchers and closures, submaps, enable/disable, removed handles, stale selections, and actual menu search/selection with screenshots. It also checks visible rejection notifications, migration behavior with offline/expired/live sessions and a custom entrypoint, opening recovery instructions from the notification, and restoring the menu with the documented bootstrap line.

Run the graphical test only in a disposable VM, following `agents/skills/acceptance-tests.md`. The committed acceptance test uses in-guest `wtype` only for menu controls. The initial PR validation also included manual QMP virtual-keyboard checks of global shortcuts; those additional checks are not automated by this test.
