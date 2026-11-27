# Welcome Setup

Welcome is the `omarchy.setup` plugin of the Quickshell desktop: a focused, animated onboarding tour for first login that can be reopened anytime from _Setup > Welcome_ or `omarchy launch setup`. It is loaded when summoned and unloaded when closed, so an idle shell pays nothing for it.

```bash
omarchy launch setup          # open the welcome tour
omarchy launch setup --wait   # return once Welcome is closed
```

`bin/omarchy-launch-setup` wraps `omarchy-shell shell summon omarchy.setup` (accepting an optional `welcome` operand for compatibility and rejecting unknown arguments).

With `--wait` it returns once Welcome has been closed. The payload names a runtime directory under `$XDG_RUNTIME_DIR` for the reply, and Welcome writes marker files there for each step a finished tour set off, `seen-agent` when the Agent step was presented, `seen-ready` when the Ready screen was reached, and `closed` last; the launcher prints every marker except `closed`, one per line. The directory also identifies the request: Welcome answers only if that request reached the screen, and reports through `omarchy-shell shell call omarchy.setup state <directory>` whether it still owns the screen (`opening`, `shown`, or `other`). Requests carry an `expires` deadline so one queued while the plugin loads is dropped rather than shown after its caller gave up.

## Essentials in order

The tour walks up to five essentials, omitting any step with nothing to offer on this machine:

1. **Workspace Layout** (choice) — reads the direct rows of _Appearance > Workspace Layout_ (`Tiling`, `Scrolling`, `Floating`) from `default/omarchy/omarchy-menu.jsonc` and the user's menu extension. Each card draws a miniature layout pictogram, labels the saved choice as `Current`, and previews the four windows rearranging in `scenes/LayoutScene.qml`.
2. **Dictation** (choice) — reads the direct rows of _Setup > Defaults > Dictation_, distinguishing cloud and on-device options in both icon and inside-card subtitle, previewed in `scenes/DictationScene.qml`. When **Superwhisper** is selected, a compact processing mode bar offers **Cloud** (`--dictation-mode cloud`) and **On-device** (`--dictation-mode offline`, letting Superwhisper auto-select `offline_lite` on machines with under 12 GB RAM and queueing missing offline models in the background). `SetupData.qml` reads Superwhisper's current mode via `superwhisper models show` so unchanged selections stay no-ops and mode-only switches skip reinstalling.
3. **Agent** (toggle) — offered when no default agent is set (`~/.config/omarchy/defaults/agent`) and the agents panel has a live IPC handler (`IpcRegistry.handlerFor("omarchy.agents")`). Availability is sampled once as the tour leaves Splash and frozen for that tour so steps never shift mid-flow.
4. **Local AI** (opt-in toggle or choice) — follows the same hardware-blueprint filter as the Agents panel (`omarchy-models list --json`: `kind === "text" && available && !installed`, sorted with `best` first). Omitted when no blueprint fits; renders a single opt-in toggle card when one blueprint fits, or opt-in blueprint cards with the `best` recipe badged `Recommended` and memory/context/speed specs when two or more fit.
5. **Tailscale** (toggle) — reads _Install > Service > Tailscale_ and is omitted once Tailscale is installed (`disabled:` guard true).

`shell/plugins/setup/SetupModel.js` is the pure logic (loaded by Node in `test/shell.d/setup-test.sh`). `SetupData.qml` evaluates one compact bash guard batch covering only the layout, dictation, and Tailscale rows and their ancestor submenus, plus the default agent file and `omarchy-models list --json`. Unanswered `when:` or `disabled:` guards on a partial batch hide the affected row rather than guessing; an unanswered `checked:` stays unknown. If no offered option on a choice step matches the machine's saved setting, the step starts unstaged with a quiet _Keep current setting_ action so pressing Enter changes nothing.

## Controls and scenes

- **Splash** brings in the Omarchy wordmark (`Wordmark.qml` from `logo.svg`) over a subtle accent glow with a single glint, and presents **Get started** and **Skip**.
- **Choice steps** use Left/Right (in reading order) or click to pick an option and immediately update the animated hero scene. `Enter` continues; `Space` does not advance.
- **Toggle steps** use a single full-width `SetupToggleCard` with an Omarchy `ToggleSwitch` (`interactive: false`) bound to the same staged boolean as the hero scene. `Space` or click toggles Off/On; reading-order Left/Right set Off/On idempotently. `Enter` continues, keeping un-toggled opt-ins off.
- `Tab` / `Shift+Tab` cycle keyboard focus across controls and footer buttons; `Backspace` / `PageUp` go back; `Esc` closes with nothing changed.
- Scenes build on `scenes/Desk.qml`, `scenes/Win.qml`, `scenes/Tile.qml`, `scenes/Way.qml`, and `scenes/Keycap.qml`. They never mirror for RTL languages, pass every animation duration through `Style.duration()`, and rest on an informative finished frame under reduced motion.

## Apply and handoff

Nothing changes until the **Ready** screen confirms (`Apply choices`, or `Start using Omarchy` when nothing changed). Ready also highlights Omarchy's three core shortcuts (`Super + Space`, `Super + L`, `Super + K`) and only mentions the terminal/password prompt when at least one install (`dictation`, `local-ai`, or `tailscale`) is staged.

Applying runs one command:

```bash
omarchy-setup-essentials --layout scrolling --dictation voxtype --tailscale --local-ai qwen3.8-27b-gufo --agent
```

`omarchy-setup-essentials` switches the workspace layout immediately. When installs are staged, they run sequentially in one floating presentation terminal, waiting for an internet connection first if offline. When `--agent` is combined with installs, the terminal finishes its acknowledgement prompt and closes cleanly before a detached handoff opens the Agents panel (`omarchy-shell omarchy.agents open`); cancelling with Ctrl-C or closing the terminal early leaves Agents closed. When `--agent` is chosen without installs, the panel opens directly over the clean desktop.

## First run

`install/user/first-run/welcome-tour.sh` runs `omarchy-launch-setup --wait` once from `omarchy-provision-first-run`, holding back first-run notifications until Welcome closes. Closing Welcome marks `welcome-tour` done. If the reply includes `agent` or `seen-agent`, `agent-setup-invitation` is marked done so `wifi.sh` does not immediately follow with a duplicate agent toast; if it includes `seen-ready`, `welcome-keybindings` is marked done so `welcome.sh` does not duplicate the shortcuts shown on Ready. Skipping on Splash leaves both fallback toasts eligible.

Images that must suppress first-run Welcome (kiosks, acceptance VM runs) create `~/.local/state/omarchy/done/welcome-tour`; `test/acceptance` also hides any already-open `omarchy.setup` overlay until first run completes.
