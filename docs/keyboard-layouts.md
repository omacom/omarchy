# Keyboard layouts

The `omarchy.keyboard-layout` bar widget opens an explicit layout picker. Its private QML components and Python standard-library backend live in `shell/plugins/bar/widgets/keyboard/`. The backend uses installed XKB registry data and libxkbcommon; it does not download dependencies or record typed text.

## State and ownership

`$XDG_STATE_HOME/omarchy/keyboard-layouts/` (normally `~/.local/state/omarchy/keyboard-layouts/`) contains the preferred physical keyboard and saved profiles in `settings.json`, the session-scoped observation cache in `activity.json`, strict non-executable device records in `active-v1.conf` and `pending-v1.conf`, and the mutation lock, transaction journal and recovery backups. Catalog data is cached under `$XDG_CACHE_HOME/omarchy/keyboard-layouts/`.

The package owns the fixed `default/hypr/keyboard-layouts.lua` loader and `shell/plugins/bar/widgets/keyboard/backend/deferred_runtime.py` helper. `default.hypr.toggles` loads the former after user input configuration. No activation command or user configuration rewrite is required. A fresh install has no saved records, so loading the module does not declare devices or change the keyboard. The widget remains available with one layout so users can add another.

Each edit validates layout/variant pairs and group-switch shortcuts, preserves unrelated XKB options, selects a surviving layout, and writes only profile/active/pending data under a lock. It checks the revision again before mutation, reloads Hyprland, and verifies every physical typing interface before accepting the result. A failed edit restores the previous files and runtime. Interrupted transactions recover on the next helper request; an external file conflict leaves the recovery journal for manual review. The loader and promotion helper are never written by a save or recovery.

The first saved layout is the login default; ordinary switching leaves that order alone. Reducing multiple groups to one keeps two identical physical XKB groups for the current session to avoid the observed unsafe live two-to-one transition. The bounded helper promotes the actual single group on the next compositor session. Only a complete, matching owned encoding is collapsed into one logical row.

Physical devices are grouped using sysfs typing capabilities. An ambiguous device requires selection, and custom keymaps block editing. Group-switch validation includes base, Shift, AltGr and Shift+AltGr characters plus both key press orders. Both Alt keys uses `grp:alt_altgr_toggle`; the alternate `grp:alts_toggle` damages the tested Polish AltGr map.

## Community plugin boundary

This integration does not adopt or delete `madmatt.keyboard-settings` state. While its `madmatt-keyboard-settings.lua` toggle exists, the native loader emits no device declarations and native saves and transaction recovery are refused. Users of that plugin should follow its documented cleanup/removal procedure before using built-in editing. Automatic transfer of saved profiles is outside this proposal.

## Process boundary

QML launches the package's supervisor using `/usr/bin/python3 -I -B` and `$OMARCHY_PATH`. Requests are argv JSON, never shell fragments. The environment is restricted to required session, locale, HOME/XDG and Omarchy paths. Responses, stderr, execution time and process lifetime are bounded; whole-process-group cleanup handles timeout and shell teardown. The backend never calls `hyprctl eval hl.device`, captures raw input, or rewrites `input.lua`.

## Validation

Run from the Omarchy checkout:

```sh
bash test/shell.d/keyboard-layout-test.sh
bash test/shell.d/keyboard-layout-native-test.sh
bash test/shell.d/plugin-clone-test.sh
bash test/shell.d/hyprland-keyboard-layout-test.sh
```

The Python suite uses temporary configuration, package and state trees and a fake compositor, with actual installed XKB compilation. It exercises first save without activation, absent-file rollback, read-only packaged code, community-plugin coexistence, native Lua loading, next-session promotion, stale revisions, interface synchronization, recovery and bounded subprocess handling.

The native suite renders upstream QML with fixture data and isolated environment paths, substituting the helper only in generated staging files. Logs and captures are written to `work/`. A minimal popup-container fixture verifies the built-in entry point because offscreen Qt cannot construct a Wayland PanelWindow. The real picker tests cover keyboard navigation, search, active-layout removal, operation readback, ambiguity feedback, animation state and repeated use. Graphical acceptance must run in a disposable Omarchy VM; offscreen captures do not establish actual bar placement, compositor focus, typing or login persistence.

Local verification on 2026-09-13 against upstream `692c02cad5c1ee90fe4188cc2be48e534cbe6e62`: 91 Python tests and 40 native fixture tests passed. The clone, manifest, Hyprland keyboard-layout and default-config checks passed. Picker/editor/search/ambiguity captures were inspected. A fresh encrypted Omarchy VM built from this source passed the keyboard-specific flow below. This adaptation has not been installed on the development desktop.

### Installed VM verification (2026-09-13)

The ISO was built from source commit `351de01813ea953402cd1c3305e731f49f84a05e`, `omarchy-iso` commit `a23f8d464dcb0616a61bfaa8026e23d0533da209`, and `omarchy-pkgs` commit `bce3b368e7cf711c41fc29eb5f8bfc1c658ab5b8`. ISO SHA-256: `e0d5bb5af30a8d2f66b26691b2f524932d51c47bf99dcafd3f1e53c4737f0079`. Tests exercised the installed `/usr/share/omarchy` package in a KVM guest with an emulated AT keyboard; only the test suite was synced into the guest.

A clean disposable overlay passed this sequence with QMP virtual-hardware keystrokes:

1. Open the bar picker with only US configured, navigate to the editor, search `pl`, and add Polish through the UI without an activation step.
2. Dismiss and reopen the popup, select Polish, then choose Polish as the login default through the editor. Verify the active layout stays Polish and the saved order becomes Polish/US.
3. Save the Both Alt keys shortcut, type `ąćęłńóśźżĄĆĘŁŃÓŚŹŻ` into a disposable terminal probe, and compare the complete synthetic sequence. The probe records only PASS/FAIL.
4. Switch to US with left-Alt/right-Alt, back to Polish with the reverse press order, then to US again. Verify the configured login default remains Polish.
5. Reboot into a new compositor session. Verify Polish is active, both layouts persist, and the original `input.lua` SHA-256 is unchanged.
6. Remove active Polish through the editor. Verify US survives, with two identical physical groups retained for the current session. Reboot again and verify promotion to one physical US group, with `input.lua` still unchanged.

Actual picker, editor, search, typing and post-reboot captures were inspected for placement, clipping and focus. [Installed desktop capture](../manual/images/keyboard-layouts-desktop.png).

The wider desktop acceptance run had two unrelated OCR failures: the weather panel's San Francisco label and the reminder message prompt were visible in their captures but not recognized by the assertions. The remaining test files and QMP shortcut smoke checks passed. The ISO harness also needed its installer-greeting matcher updated; an initial unencrypted VM failed its second boot with a disk-encryption mapping error, so verification used the standard encrypted installation. These harness/installer findings are not hidden by the passing keyboard run.

This validates virtual-hardware typing on one emulated keyboard. Multiple physical keyboards, hotplug and real-hardware login behavior still need hardware coverage; the existing isolated tests cover those backend contracts.

Adapted from [Keyboard Layouts for Omarchy](https://github.com/MadMatt341/omarchy-keyboard-settings). The original MIT notice is retained beside the reused implementation.
