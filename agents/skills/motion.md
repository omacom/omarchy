# Motion

Read this before adding or changing any animation in `shell/`: a panel, popup, notification, button, list or anything else that moves, fades or resizes. The rules are adapted from Emil Kowalski's animation skills (https://github.com/emilkowalski/skills) to Qt Quick and to choices Omarchy has made; where the two differ, follow this file.

Every animation needs a reason: it shows where something came from or went, it confirms an input, or it keeps a change from jumping. "It looks nice" on something seen many times a day is not a reason. Verify every motion change frame by frame as described in [`visual-verification.md`](visual-verification.md).

## Should it animate

- Things opened many times a day by a single keystroke and gone in a moment don't animate: the menu, launcher, clipboard and emoji pickers have no open or close motion, and the volume/brightness OSD appears and disappears at once.
- A keystroke that acts and is done jumps: dismissing the newest notification, dismissing all, invoking the newest. They pass `instant` through `closeToasts()` in `shell/plugins/notifications/Service.qml`.
- Inside something the user stays and watches, keys get the same motion as the pointer: panels opened or closed by hotkey grow and fade like a click, and notification keyboard mode closes the selected card with its normal exit. There the motion shows where things went.
- Hover effects seen constantly stay small and quick, or don't animate.

## Tokens

- Every duration goes through `Style.duration(ms)`. It returns 0 when `omarchy toggle animations` has turned Hyprland's animations off, which is how the shell honours reduced motion. A bare `duration: 150` keeps animating after that, so don't write one; `test/shell.d/motion-test.sh` fails on it. A looping animation also needs `running: ... && !Style.reduceMotion`, or its zero-length steps spin the CPU.
- Movement and entrances use `Style.easeOut`, a strong ease-out (`cubic-bezier(0.23, 1, 0.32, 1)`) passed as `easing.type: Easing.Bezier; easing.bezierCurve: Style.easeOut`. Plain fades may use `Easing.OutCubic`, and hover colour changes `Easing.InOutQuad`.
- Never an ease-in curve on UI: it starts slowest at the moment the eye is on it. No overshoot or bounce.
- Never `Easing.Linear` except for constant motion such as a spinner.

## Durations

- UI motion stays under 300ms. Entrances take 180–250ms.
- Whatever leaves goes faster than it came, about two thirds of the time: panels open in 180ms and close in 120ms, notifications arrive in 250ms and leave in 200ms.
- Text fading out under something fading in takes half the time of the fade in, or the two texts show at once.
- Press feedback is 160ms.

## Patterns already in the shell

Build on these rather than writing a new open/close animation:

- `shell/Ui/KeyboardPanel.qml` - panels grow from 0.97 out of the point on their bar-facing edge nearest the icon they hang from (`growOrigin`), and fade. Switching between two panels in the same bar section morphs one card from the old place and size to the new (`morphFromLastCard`, `bar.popoutCardFor()`); across sections the old card fades and the new one grows in fresh. Content that arrives after opening, like a Wi-Fi scan, grows the card through `drawnHeight` and the card crops the new rows meanwhile.
- `shell/Ui/PopupCard.qml` - the same grow and fade for tray and media popups.
- `shell/Ui/Button.qml` - a button held down scales to 0.97. The `MouseArea` takes `1 / root.scale`, so only the drawing shrinks and a press near the edge still clicks.
- `shell/plugins/notifications/Service.qml` - one scene clock for the whole deck. A change snapshots where every card is now and retargets from there, so a move interrupted by another never jumps. A Behavior per card would restart from scratch on every retarget.

## Pitfalls

- Never scale from 0. Start at 0.95–0.97 with opacity 0.
- Scaling an item scales its `MouseArea` too; undo it on the hit area, as `Button` does.
- Animating height while content lays out to that height reflows every frame. Size the content to its final height and crop it with `clip` while the frame catches up.
- A `Behavior` that must not run for one particular change (a morph, a keyboard jump) needs its `enabled` condition true before the value changes. A flag set in `onOpenChanged` can be too late, because bindings may update first; use a binding that is already true, like `KeyboardPanel.takingOver`.
- A whole-shell flag that zeroes `Style.duration()` cuts short unrelated animations already running. Keep instant paths local, like `closeToasts(..., instant)`.
