# Setup

Setup is the `omarchy.setup` plugin of the Quickshell desktop: the welcome tour a new user is greeted with, and pages that show what each row of the Setup menu does before it is picked. It is loaded when summoned and unloaded when closed, so an idle shell pays nothing for it.

```bash
omarchy launch setup            # every page, opened on the first
omarchy launch setup welcome    # the welcome tour
omarchy launch setup security   # one page, by id, the last part of its id, or its name
```

_Setup > Welcome_ in the menu opens the tour. `bin/omarchy-launch-setup` is a thin wrapper over the standard plugin summon, with a payload of `{"mode": "tour"}` or `{"page": "<name>"}`.

With `--wait` it returns once Setup has been closed, the way `omarchy-menu-select` waits on the menu. The payload names a directory under `$XDG_RUNTIME_DIR` for the reply, and Setup leaves a file there for each step a finished tour set off, then `closed`; the launcher prints the steps, one a line. The directory is also what the request goes by. Setup answers only if that request's window had been shown, and says through `omarchy-shell shell call omarchy.setup state <directory>` whether it still has the screen (`opening`, `shown`, or `other` once Setup has closed or been opened again for someone else). So a Setup that never reached the screen, went down with the shell, or was replaced fails the wait rather than passing for one that was closed, and a wait that gives up closes only its own request. The request also says when its caller will stop waiting, so one still queued while the plugin loads is dropped rather than shown to nobody.

## Pages are a lens over the menu

Setup keeps no list of settings of its own. Its pages are read out of `default/omarchy/omarchy-menu.jsonc` and the user's menu extension, through the same `MenuModel.js` the menu uses, so a browser, a harness or a whole submenu added to the menu appears in Setup with no change here. `shell/plugins/setup/SetupModel.js` is the pure logic, plain JavaScript that Node loads for `test/shell.d/setup-test.sh`.

- **The essentials** come first, and are the tour's steps: the rows of _Appearance > Workspace Layout_, _Agent > Harness_ and _Setup > Defaults > Dictation_, the local model `omarchy-local-ai` recommends for this machine, and the _Install > Service > Tailscale_ row. `ESSENTIALS` in `SetupModel.js` names them. A step with nothing to offer on this machine is left out: Local AI where no recipe fits, Tailscale once it is installed.
- **Every row of the Setup menu** gets a page after them. A row that is an action is a page with one button. A submenu's own rows are its options, and each submenu under it is a titled group of options; anything deeper, and anything a provider lists at runtime (the languages), is an option that opens the menu there. A submenu an essentials page already shows (Dictation) is not repeated under Defaults.

Rows are found and judged as the menu does it. A submenu's rows are the entries whose parent it is, in order, without the rows that only stand in for another while Alt is held. A row whose `when:` fails is hidden, and so is a submenu left with nothing to show, and anything reached through a submenu the menu hides or switches off. `checked:` marks the current choice. A row whose `disabled:` succeeds is shown dimmed with nothing to run, which is how software already installed appears.

Two things Setup is stricter about than the menu. The menu opens a submenu from outside by route, which is made for typing: it folds case and underscores, follows aliases, and runs an action it lands on. A submenu that `MenuModel.resolveRoute` would not lead back to (an id it folds into another, a name it keeps for itself) is left out of Setup, which could only hand it over by route. And where the guard batch breaks off part way, or ends without answering every `when:` and `disabled:`, the menu falls back on its last full set of answers; Setup has none, so it keeps the answers that came and leaves out the rows whose guards got none.

`SetupData.qml` asks for everything once, each time Setup opens: one batch of guards for just the rows Setup reads and the submenus above them, built with `MenuModel.guardScript`, and `omarchy-agent-local list --json` for the local model, which changes nothing but the engine's own saved copy of that listing. Nothing polls, and nothing can be picked until every answer is in, translations included, so a row never shows and then vanishes, gains its check late, or moves under the pointer.

What the plugin adds is a sentence about each page (`pageDescription`), a line about an option where its name alone doesn't say (`optionDetail`), and the scene.

## Scenes

Each page has a scene: a miniature of the desktop that shows what the option under the cursor does. They are all built from `scenes/Desk.qml` (the screen and its bar), `scenes/Win.qml` (a window, with the accent border Hyprland gives the focused one), `scenes/Tile.qml` (anything that is not a window: a machine, a key, a file), `scenes/Way.qml` (the line between two of them, and something on its way along it) and `scenes/Keycap.qml` (a key), so they read as one set.

| Scene | Shows |
|---|---|
| `LayoutScene` | The same four windows rearranging between tiling, scrolling and floating as the cursor moves across the options |
| `AgentScene` | The hotkey, and the harness under the cursor at work in the window it opens |
| `DictationScene` | Right Alt held while a voice becomes written words, by way of this machine or the cloud |
| `LocalAiScene` | A model on this machine answering without leaving it |
| `TailscaleScene` | Three machines that reach each other directly, or sit apart |
| `DefaultsScene` | A link, a prompt or a text file handed to the app under the cursor |
| `PluginsScene` | A piece of the bar and its panel switched on, switched off, brought in, copied or taken out |
| `SecurityScene` | A password prompt answered by what the row sets up, with nothing typed; for SSHD, answered from another machine |
| `GitScene` | A history filling up under a name and an address, beside GitHub, signed in to |
| `KeyboardScene` | A chord opening a window, the legends of three layouts, or keys coming out in another script |
| `RegionScene` | A window each for script, formats and the hour, the cursor's one running through what it could be |
| `NetworkScene` | A name looked up through the resolver under the cursor, or the Wi-Fi code read by a phone |
| `HandoffScene` | What picking a row opens: a terminal wizard, the editor on the file it names, a list in the menu, or the app or setting itself |

`SETUP_SCENES` in `SetupModel.js` gives a Setup submenu its scene. `HandoffScene` is the fallback for every page without one, which is what lets a row from a menu extension get a picture too. `handoffKind` reads which of the four it is from the row's action: a floating terminal, `omarchy-launch-editor`, or an `omarchy-menu` command.

Scenes are pictures of the desktop, so they do not mirror for right-to-left languages. The splash and the scenes are illustrations someone has stopped to watch, so they run longer than [`agents/skills/motion.md`](../agents/skills/motion.md) allows the shell's own motion, and loop. Every animation's duration still goes through `Style.duration()`, the timers that step a scene stop under reduced motion, and each scene then rests on a finished frame. Nothing a key or a click does waits on any of them.

## The welcome tour

The tour walks the essentials one step at a time, after a splash that brings in the wordmark (drawn from the paths of `logo.svg` by `Wordmark.qml`).

Nothing changes until Finish. Each step remembers the option picked there, and Escape or _Skip tour_ at any point closes the tour with the machine exactly as it was. A click outside the card closes the pages but not the tour, because a stray click should not cost the choices made so far. A step with nothing chosen yet opens on a _Not now_ card, so pressing Enter through the tour changes nothing. The last screen, _Review_, lists what Finish is about to do.

Finish runs one command, `omarchy-setup-essentials`, with a flag for each step whose choice differs from what the machine has:

```bash
omarchy-setup-essentials --layout scrolling --dictation voxtype --tailscale --local-ai qwen3.8-27b-gufo --agent claude
```

The flag's value is read out of the menu row's own action (`stageArgs`), so the tour runs what the menu row would, and the local model is named by the recipe that was shown rather than asked for again as the best one. The difference from the menu is the order. Picking these from the menu one at a time opens a terminal for each, and several at once would contend for pacman's lock. `omarchy-setup-essentials` sets the layout at once, then hands the rest to one presentation terminal as `omarchy-setup-essentials --install …`, which runs them one after another: dictation, Tailscale, the local model (handed to the background, where the agents panel shows its progress), and the agent last, since installing an agent clears the terminal and opens the agent in it. It waits for a connection first, the way first run's own prompts do. Anything that failed is named before the agent takes the terminal and again at the end. Whether a thing was set up is judged by the result, not by how its command ended: the agent by being installed, since its command returns however the agent's own session did, and dictation by the backend in use, since an installer whose confirmation is turned down ends without an error and is then reported as left alone.

A row whose action the tour cannot read a value from, such as a harness a menu extension adds with a command of its own, is offered on the pages and left out of the tour.

## The pages

Outside the tour, a click or Enter runs the row as the menu would and closes Setup. It closes for the same reason the menu does: most rows open a terminal, the editor or a picker, which could not be reached under an overlay that holds the keyboard. The scene previews the option under the cursor, so what is there to see is seen before anything runs.
