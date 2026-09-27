# Omarchy bidirectional keybinding guide — development pre-study

Status: proposal / implementation brief  
Prepared: 2026-09-05  
Target project: [omacom/omarchy](https://github.com/omacom/omarchy)

## Executive summary

Extend the existing `Super + K` keybinding guide so it supports two inputs in the same interface, with no explicit mode switch:

- Type ordinary words and receive matching shortcuts.
- Physically press a shortcut chord and receive its description.

Example:

- Type `file manager` → `SUPER + SHIFT + F → File manager`.
- Physically press `Super + Shift + F` → `SUPER + SHIFT + F → File manager`, without opening the file manager.

This should be implemented in Omarchy, not Hyprland. Hyprland already supports the standard Wayland keyboard-shortcuts inhibitor protocol, and Quickshell exposes it through `Quickshell.Wayland.ShortcutInhibitor`. The existing Omarchy menu already requests keyboard focus and receives key events. The required work is therefore an Omarchy shell/menu enhancement plus a small change to the keybinding-record interface.

Do not use synthetic key injection or keep a fake modifier logically pressed. That approach is unnecessarily fragile and can leak modifier state, interact with keyboard layouts, or fail for bindings that ignore modifiers.

## Product contract

There is exactly one entry point and one interface:

1. The user presses `Super + K`.
2. The existing Keybindings guide opens.
3. If the user types ordinary unmodified printable text, the guide performs its current description search.
4. If the user physically presses a chord, the guide looks up that chord and shows its description.
5. The inspected shortcut must not execute.

There is no second `Super + K`, capture button, capture mode, prompt, or manually typed shortcut syntax.

### Input classification

The guide should classify input automatically:

- Unmodified printable keys: text search.
- `Shift` plus a printable key where Shift is being used to type text: text search. Uppercase letters must remain usable in search.
- A non-modifier key pressed while `Super`, `Ctrl`, or `Alt` is held: chord lookup.
- Non-text keys such as `Print`, function keys, arrows, navigation keys, and media keys: chord lookup, with or without modifiers.
- Modifier press/release by itself: update transient modifier state but do not search until a non-modifier key arrives.
- `Escape`: preserve the existing clear/close behavior; it must not become a chord query.
- `Enter`, arrows, Tab, Delete, and other existing menu-navigation controls: preserve current behavior unless held with a modifier that forms a known shortcut.

The result should be resolved on the non-modifier key press. Waiting for all modifiers to be released would make the interface feel laggy.

## Why it belongs in Omarchy

Omarchy owns all relevant product concepts:

- `Super + K` and its “Keybindings” meaning.
- Collection and normalization of configured Hyprland bindings.
- Human-readable binding descriptions.
- The searchable guide UI.
- The desired interaction and visual presentation.

Hyprland owns the compositor primitive required to suppress global shortcuts, and that primitive already exists. A Hyprland PR is only warranted if a minimal reproduction demonstrates that its implementation of `keyboard-shortcuts-inhibit-unstable-v1` does not suppress a normal binding for a focused layer-shell surface.

## Existing implementation

The installed Omarchy source currently contains:

- `default/hypr/bindings/utilities.lua`
  - Registers `SUPER + K`, description `Keybindings`, action `omarchy-menu-keybindings`.
- `bin/omarchy-menu-keybindings`
  - Reads dynamic bindings from `hyprctl binds`.
  - Supplements Lua-only bindings by scanning the user configuration.
  - Normalizes modifier masks, keycodes, mouse buttons, and descriptions.
  - Produces records with display text and dispatch metadata.
  - Sends display rows to `omarchy-menu-select`.
  - Dispatches the selected binding when a row is selected.
- `shell/plugins/menu/Menu.qml`
  - Implements the native Quickshell menu.
  - Uses a full-screen `PanelWindow`.
  - Sets `WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive`.
  - Has a `keyCatcher` with `Keys.priority: Keys.BeforeItem` and an existing `Keys.onPressed` handler.

This means Omarchy already possesses the reverse index data. The current display row has this conceptual shape:

```text
SUPER SHIFT + F → File manager
```

The missing pieces are:

1. Prevent Hyprland from executing the chord while this particular menu is focused.
2. Observe and normalize the physical chord in QML.
3. Match it against the keybinding records.
4. Show the matching row without dispatching it.

## Recommended architecture

### 1. Identify the menu request as a keybinding-inspection request

Avoid enabling shortcut inhibition for every Omarchy menu. The generic menu is also used to execute commands and should retain its current behavior.

Extend the `omarchy-menu-select` request with semantic metadata, for example:

```bash
omarchy-menu-select 'Keybindings' --inspect-keybindings -- --width 800 --height 500
```

The exact flag should follow the existing IPC/request conventions in the repository. A generic alternative would be `--capture-shortcuts`, but the behavior is currently specific to the keybinding guide.

The corresponding menu request/model property might be:

```qml
property bool inspectKeybindings: false
```

### 2. Activate a Quickshell shortcut inhibitor

Attach a `ShortcutInhibitor` to the menu's focused `PanelWindow` only while the keybinding guide is open:

```qml
import Quickshell.Wayland

ShortcutInhibitor {
  id: shortcutInhibitor
  window: panel
  enabled: root.opened && root.inspectKeybindings
}
```

The actual `window` value may need to be the Quickshell window object expected by the installed Quickshell version rather than the QML wrapper. Follow existing Quickshell patterns and verify `active` before relying on suppression.

Important behavior:

- If the inhibitor is not active, do not silently pretend inspection is safe.
- Either keep ordinary text search but decline modified-chord inspection, or close the guide and report that capture could not be activated.
- Handle the inhibitor's `cancelled` signal by disabling chord inspection immediately.
- The inhibitor must be disabled as soon as the menu closes or loses the relevant focus.

Hyprland bindings marked to bypass inhibitors (currently represented by flags such as `dont_inhibit` / `allow_input_capture`, depending on the mechanism and version) need explicit testing. The inspector must not claim that a chord is harmless if Hyprland will still process it.

### 3. Preserve structured binding records

Do not reverse-parse the formatted display string if it can be avoided. Pass structured fields to the menu:

```text
display label | normalized chord | description | dispatcher | argument
```

The transport could remain tab-separated if that is the established contract, but the menu needs direct access to at least:

- normalized chord;
- human description;
- display label;
- optionally flags indicating whether the chord bypasses inhibition.

Normalization must be shared between record production and QML chord capture. If the shell cannot reuse the Bash normalization logic directly, define a small, explicit canonical representation and test both sides against the same fixture table.

Suggested canonical form:

```text
SUPER+SHIFT+F
CTRL+ALT+DELETE
PRINT
SUPER+mouse:272
```

Suggested modifier order:

```text
SUPER, SHIFT, CTRL, ALT
```

Display formatting can remain `SUPER SHIFT + F` to preserve the current UI.

### 4. Capture before the text field

Use the existing `keyCatcher` and `Keys.priority: Keys.BeforeItem` path. In pseudocode:

```qml
Keys.onPressed: function(event) {
  if (handleExistingMenuControls(event)) {
    event.accepted = true
    return
  }

  if (root.inspectKeybindings && shortcutInhibitor.active && isChordInput(event)) {
    const chord = normalizeChord(event.key, event.modifiers)
    root.showBindingForChord(chord)
    event.accepted = true
    return
  }

  // Preserve the existing text-search path.
}
```

`isChordInput` must not treat `Shift + letter` as a chord, because users need capitalization. It should treat `Super`, `Ctrl`, or `Alt` plus a non-modifier key as a chord. It should also treat recognized non-printable keys as chords.

Qt modifier auto-repeat and native scan-code behavior should be checked. Use Qt's key enum and modifier mask for the first implementation; only use native scan codes when required to distinguish a configured `code:` binding.

### 5. Display the lookup result without dispatching

Chord lookup must never follow the existing selection path that calls `dispatch_binding`.

Recommended result behavior:

- Replace/filter the rows to the exact chord match.
- Keep the search field unchanged or temporarily display the chord as a non-editable chip/status line.
- If several bindings share a chord, display all of them and their relevant context/submap.
- If no record matches, show `No binding found for SUPER + ...`.
- The next normal character should return naturally to textual search; no explicit mode-reset action should be required.

The user may still deliberately execute a selected row using the guide's existing behavior. Inspection itself must not trigger selection or execution.

## Opening-event race

`Super + K` opens the guide, so its key release events may arrive after the surface and inhibitor become active.

Do not solve this with a visible delay. Internally gate chord recognition until all keys from the opening gesture have been released. Options:

- Ignore release events entirely and only resolve chords on non-modifier press; if the opening `K` press occurred before the surface gained focus, this may already be sufficient.
- Record an `armed` flag after the first zero-modifier state or a short event-loop turn after focus acquisition.
- Explicitly ignore the initial `Super + K` sequence associated with the summon request.

Choose the smallest solution that passes an automated or integration test. Avoid arbitrary long timers.

## Safety and escape behavior

Shortcut inhibition creates a temporary keyboard grab-like experience, so failure recovery matters:

- `Escape` must always clear/close through the client.
- Clicking outside must still close the guide.
- Focus loss must deactivate the inhibitor.
- Closing/unmapping the window must deactivate it automatically.
- Handle `ShortcutInhibitor.cancelled`.
- Do not enable inhibition globally or for unrelated menu requests.
- Verify that switching TTY remains compositor/kernel controlled and is not affected.
- Test a shell reload/crash while the guide is open; Wayland resource destruction should release inhibition.
- Do not add a synthetic-key fallback.

## Keyboard-layout considerations

The existing script already resolves `code:` bindings through `xkbcli` and the active keymap. The inspector introduces the reverse direction and therefore needs tests for:

- US QWERTY.
- A non-US layout used by a contributor or CI fixture.
- A configured binding expressed as a keysym.
- A configured binding expressed as `code:<number>`.
- Shifted symbols such as `/`, `?`, `-`, `_`, number-row symbols, and locale-specific symbols.
- Left/right variants of Ctrl, Alt, Shift, and Super; these should normally normalize to the same logical modifier.
- AltGr, which may appear as Ctrl+Alt on some stacks and must not be misreported casually.

For an MVP, it is acceptable to support the same logical representation already shown by `omarchy-menu-keybindings` and report no match for ambiguous raw-keycode cases. Do not silently map an uncertain chord to the wrong action.

## Interaction with binding flags and submaps

The existing list may include bindings that:

- ignore extra modifiers;
- fire on release;
- repeat while held;
- remain active under shortcut inhibition;
- exist only in a Hyprland submap;
- are device-specific;
- use mouse buttons or switches.

MVP scope should be ordinary keyboard bindings in the default submap. Suggested behavior outside that scope:

- Release bindings: identify on key press but label normally; do not wait to execute, because nothing executes.
- Repeating bindings: identify once.
- `ignore_mods`: exact chord lookup first; optionally show an “also matches because modifiers are ignored” result later.
- Inhibitor-bypassing bindings: exclude from safe capture or label as unsafe until a robust policy is implemented.
- Other submaps: show only if record metadata reliably exposes the submap; otherwise defer.
- Mouse/switch bindings: retain text discoverability; physical capture can be a later extension.

## Test plan

Follow the repository's `AGENTS.md` and run the full required suite, including `./test/all` before submission.

### Unit tests

- Normalize every supported Qt modifier combination into the canonical order.
- Normalize key aliases consistently with `bin/omarchy-menu-keybindings`.
- `Shift + f` remains text input.
- `Super + Shift + F` becomes a chord query.
- `Ctrl + K` becomes a chord query, not the letter `k` in search.
- `Print`, `F9`, media keys, arrows with modifiers, and Delete with modifiers classify correctly.
- Modifier-only events do not produce a result.
- Duplicate chords return all matching descriptions.
- An unknown chord returns an explicit no-match state.

### Integration tests

- Open with `Super + K`; the menu appears and the original action does not repeat.
- Type `browser`; normal search still works.
- Physically press a safe test chord; its description appears and its dispatcher is not called.
- Physically press a normally destructive chord such as close-window in a disposable test environment; the window is not closed.
- Press Escape; the guide closes and normal Hyprland shortcuts work immediately afterward.
- Click outside; same restoration behavior.
- Cancel the inhibitor; chord capture stops safely.
- Change keyboard layout and repeat lookup.
- Reload/terminate the shell while inhibited; normal shortcuts recover.

### Manual UX checks

- No visible capture mode or additional activation step appears.
- Modified chords feel instantaneous.
- Typing normal prose never unexpectedly switches to chord lookup.
- The result communicates both the physical chord and the description clearly.
- Unknown chords do not look like errors or execute anything.

## Acceptance criteria

- `Super + K` remains the sole entry point.
- Existing word search behaves unchanged.
- A physical chord entered while the guide is open resolves to its human description.
- The inspected ordinary Hyprland binding does not execute.
- No extra mode switch, prompt, button, or second invocation is required.
- Escape/outside-click/focus-loss restore normal keybindings immediately.
- Failure to obtain shortcut inhibition fails safely.
- The implementation does not inject synthetic input.
- Automated tests cover classification, normalization, non-execution, and cleanup.
- Documentation briefly describes the bidirectional behavior.

## Scope recommendation

### MVP

- Default-submap keyboard chords.
- `Super`, `Ctrl`, and `Alt` combinations.
- Common non-printable keys.
- Exact-match lookup.
- Safe failure when inhibition is unavailable.

### Follow-ups

- Mouse bindings.
- Device-specific bindings.
- Submap-aware results.
- `ignore_mods` fuzzy matching.
- Displaying binding source file and line.
- Showing conflicts or several actions bound to one chord.

Do not expand the first PR into a general keybinding editor.

## Likely files to change

Confirm paths against the development branch before editing:

- `bin/omarchy-menu-keybindings`
  - Emit structured normalized-chord data and request inspection semantics.
- The `omarchy-menu-select` request/CLI implementation
  - Carry an inspector/capture flag into the shell menu request.
- `shell/plugins/menu/Menu.qml`
  - Add the conditional `ShortcutInhibitor`, key classification, normalization, and chord-result behavior.
- Menu model/helper JS used by `Menu.qml`
  - Prefer placing pure normalization and matching functions here for unit testing.
- Existing keybindings-menu and shell/menu tests
  - Add fixtures and regression coverage.
- `manual/07-hotkeys.md` or the current guide documentation
  - Add one concise explanation.

## Relationship to current Omarchy PRs

- [PR #7722 — Display keybindings in menu on demand via `?`](https://github.com/omacom/omarchy/pull/7722)
  - Closest functional overlap. It adds shortcut-aware menu data and textual searching by shortcut tokens. Coordinate with it to avoid conflicting changes to menu models and keybinding parsing.
- [PR #8569 — Show hotkey chips on menu rows](https://github.com/omacom/omarchy/pull/8569)
  - Related discoverability work, but not physical chord inspection.
- [PR #7165 — Make hotkeys discoverable](https://github.com/omacom/omarchy/pull/7165)
  - Introduces a structured relationship between actions/menu rows and bindings. Its data-model approach may reduce duplicated parsing if accepted.

Before coding, check the current state of these PRs and the target branch. The repository is moving quickly and overlapping work may have landed or changed shape.

## Upstream references

- [Quickshell `ShortcutInhibitor`](https://quickshell.org/docs/v0.3.1/types/Quickshell.Wayland/ShortcutInhibitor/)
  - Prevents the compositor from processing shortcuts for a focused surface so the application receives the key events.
- [Hyprland bind documentation](https://wiki.hypr.land/Configuring/Basics/Binds/)
  - Current binding model, flags, keycodes, global bindings, and submaps.
- [Hyprland bind flags](https://wiki.hypr.land/configuring/core/binds/flags/)
  - Includes flags related to inhibition/input capture and identifies bindings that may remain active.

## Suggested development sequence for Cursor

1. Clone/fork the repository; never develop in `/usr/share/omarchy`.
2. Read the repository's current `AGENTS.md` completely.
3. Re-check PRs #7722, #8569, and #7165 for overlap or merge status.
4. Trace `omarchy-menu-keybindings` → `omarchy-menu-select` → shell IPC → `Menu.qml` and document the exact request data flow.
5. Build a minimal spike that enables `ShortcutInhibitor` only for the Keybindings request and logs received modified key events without performing lookup.
6. Verify experimentally that `Super + W` or another disposable test binding is received by QML and not executed.
7. If that succeeds, add structured chord data, normalization, lookup, UI behavior, and tests.
8. If it fails, produce a minimal standalone Quickshell reproduction before considering an upstream Quickshell or Hyprland report.
9. Run focused tests, then `./test/all`.
10. Open an atomic Omarchy PR with a short screen recording showing word search and physical chord inspection in the same guide.

## Suggested PR description

### What

Make the `Super + K` keybinding guide bidirectional. Typing words continues to search descriptions; physically pressing a shortcut now shows what it does without executing it.

### Why

The guide currently answers “which shortcut performs this action?” but not “what will this shortcut do?” Users exploring an unfamiliar keyboard-driven system need both directions.

### Interaction

- `Super + K`
- Type `file manager` → see its shortcut.
- Or physically press `Super + Shift + F` → see `File manager`.
- No second invocation or capture mode is required.

### Safety

The focused guide uses Quickshell's Wayland shortcut inhibitor, so normal compositor bindings are not executed during inspection. Inhibition is scoped to the keybinding guide and released on close or focus loss.

## Open questions to resolve during the spike

1. Does the Omarchy-packaged Quickshell version expose `ShortcutInhibitor` with the documented API?
2. What exact window object must be assigned to its `window` property for `PanelWindow`?
3. Does Hyprland grant inhibition to Omarchy's overlay layer-shell surface consistently?
4. Which current Omarchy bindings bypass shortcut inhibition?
5. Can the existing menu request transport structured hidden fields cleanly, or should keybinding inspection get a dedicated request/model path?
6. How should `Shift + printable key` be classified for layouts where Shift changes the symbol substantially?
7. What is the safest behavior when the inhibitor reports inactive or cancelled?

These are spike questions, not reasons to redesign Hyprland up front.
