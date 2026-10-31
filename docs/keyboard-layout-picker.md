# Keyboard layout picker

Right-click the existing keyboard indicator to choose a configured compositor layout or Fcitx input method. The current choice has a checkmark. With one layout, left-click also opens the picker; with several inputs, existing left-click and Super+I/Super+Shift+I cycling remain available. **Edit layouts…** opens `omarchy setup keyboard`; **Input methods…** opens `omarchy setup input`.

## Shared ownership

The picker extends the existing `InputMethodState` reader. It keeps Fcitx's pending selection when no application has an input context. The native menu runs asynchronously, so opening it does not block the reader. Selection rechecks the device names, compositor addresses, layout/variant list and input-method list before using an index. Reconnecting or changing those settings requires opening a fresh picker. Closing the reader terminates an outstanding picker process.

Layout editing uses `default/input-methods/typing_setup.py` and the existing `$XDG_CONFIG_HOME/omarchy/keyboard-layouts` preference file. Its existing reload, override check, Fcitx synchronization and rollback remain the save path for both entry points. Switching from the bar changes only the active input and never writes the saved layout order. Personal `input.lua` settings retain their existing precedence.

There is no per-keyboard profile database, additional Lua loader, active/pending encoding, promotion helper or recovery journal. The community plugin's state is outside this integration. Shared editing is refused while that plugin's loader is present, with a direction to use its cleanup procedure first. Per-keyboard editing, a separate login-default control and shortcut configuration are outside this change.

## Installed variants

The shared setup picker includes layouts and variants from installed `evdev.xml` and `evdev.extras.xml`, retaining the installer's familiar labels for its existing choices. Identifiers such as `us:intl` appear as searchable subtext and distinguish same-named choices. The registry is read on demand; it adds no idle polling or persistent catalogue cache.

Selections are limited to four distinct layout/variant pairs and compiled with libxkbcommon before saving. Omarchy's Latin-leading rule is retained. The compiled first group must also supply Latin letters without Shift or AltGr, covering non-Latin variants of otherwise Latin layouts. When necessary, US is inserted first; the four-group limit includes it. Neither typed text nor raw input is collected.

## Verification

Run the isolated checks from the source checkout:

```sh
PATH="$PWD/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 bash test/shell.d/input-picker-test.sh
PATH="$PWD/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 bash test/shell.d/typing-setup-test.sh
PATH="$PWD/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 bash test/shell.d/input-indicator-test.sh
PATH="$PWD/bin:$PATH" PYTHONDONTWRITEBYTECODE=1 bash test/shell.d/keyboard-layout-test.sh
```

The picker tests cover explicit index selection, custom-device preservation, stale reconnect/keymap/method rejection, Fcitx selection without focus, cancellation, duplicate opens, shared setup dispatch, an actual asynchronous Gio subprocess callback and abrupt reader death. Linux's parent-death signal keeps the picker from outliving a reader that Quickshell kills without graceful cleanup. Setup tests compile real XKB maps, including Russian and a Cyrillic variant of Azerbaijani, and exercise the existing configuration/Fcitx rollback behavior. Graphical acceptance belongs in a disposable VM; these fixtures do not establish real hardware or composition-engine compatibility.

### Observed results — 2026-10-17

All 25 shared setup tests and 11 picker tests passed, together with the existing input-reader/cycling checks and 65 widget-model checks. Plugin clone, manifest scanning and Hyprland keyboard/default-configuration checks passed. The broader menu and menu-plugin suites retain failures at the Opaque Bar check and already-cloned plugin row; both failures were reproduced on untouched base `33783b1707d2fd5cdbab99aec183fc761d14bca0` with identical output.

A disposable overlay of the September 13 encrypted VM installation ran the candidate through the supported development link. Pointer opening, keyboard navigation, variant search/save, direct selection, left-click and Super+I cycling, unchanged saved order on selection, and persistence across reboot passed. Personal `input.lua` remained identical to its original packaged copy. A Russian-leading selection retained US first; with Russian active, the actual Super+Shift+F binding opened Nautilus. Shell restart with the picker open initially exposed an orphan command; the parent-death fix passed a repeated VM check and an isolated abrupt-death regression. A temporary community-loader marker blocked shared edits without changing saved settings. Captures were inspected for readability, complete borders and active-choice feedback. The VM was shut down after testing.

This was an existing-installation source-update test, not a fresh ISO build. It used one emulated AT keyboard and QMP input. Real multiple-keyboard hardware, Bluetooth/remappers and live composition-engine workflows remain unverified.
