---
name: omarchy-game
description: >
  Make a game for the Omarchy desktop: one HTML file using three.js, saved in
  ~/Games/<name>/, played in its own window from the app launcher. Use when
  asked to make, build, or write a game, an arcade game, a 3D game, a browser
  game, a board or card game, or a toy to play. Triggers: new game, make me a
  game, three.js, WebGL game, arcade, snake, asteroids, breakout, pinball,
  platformer, runner, maze, puzzle, chess, solitaire, minesweeper.
---

# Making an Omarchy Game

A game here is one file, `~/Games/<name>/index.html`: three.js from a pinned CDN, everything else written in the file — shapes built from three.js geometry, sound synthesized with WebAudio, text in HTML over the canvas. It opens in its own window from the app launcher, in the desktop's current theme, is played from the keyboard (and the mouse, where that is natural), and keeps its best score.

Every game starts from `template.html` beside this file. It is a complete, working game (dodge the falling blocks) with the parts every game needs already done: title screen, pause, game over, restart, help, sound, saved best score, a fixed-step loop, mouse picking, and the hooks `check` uses to play it. You replace the game inside it, not the frame around it.

Below, `SKILL_DIR` is the directory this SKILL.md is in, which also holds `template.html` and `check`. Use the path you read this file from (such as `~/.agents/skills/omarchy-game`), not a guess.

## 1. Settle the game

If the user hasn't said what game they want, ask. Then decide, in one sentence each, before writing code:

- **Goal**: what the player is trying to do.
- **Controls**: which keys, and what each does. Arrow keys and WASD both, Space for the main action. Board and card games move a cursor with the arrows and also take the mouse.
- **Losing**: what ends the round.
- **Score or winning**: what is counted, whether more is better (points) or less (a time, a move count), and whether the round can be won (a maze, a level) or only survived (a runner, asteroids).
- **Getting harder**: what changes over time so it stays interesting.

Keep it small enough to finish: one mechanic done well beats three done badly. But give it enough to play for a few minutes: a maze has many turns and dead ends, a shooter more than one kind of enemy, a runner obstacles that need different moves. Pick a short lowercase name of letters, digits and dashes (`snake`, `tilt-maze`).

## 2. Start from the template

```bash
mkdir -p ~/Games/<name>
cp "$SKILL_DIR/template.html" ~/Games/<name>/index.html
omarchy-theme-color --all
```

If `~/Games/<name>` already holds a game, ask before replacing it.

Read the whole template once before changing it. Then edit that copy in place, section by section — never write the file from scratch, and never rewrite the frame. Work in `~/Games/<name>/index.html` itself, not a copy elsewhere:

1. **SETTINGS**: set `NAME` to the game's name, and fill `PALETTE` from `omarchy-theme-color --all` (only these keys: `mode`, `background`, `foreground`, `accent`, `muted`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `orange`; ignore the rest), keeping `themed(...)` around it. Set `BEST_IS` to `'lower'` for a time or a move count, `formatScore` to show it (`m:ss` for times), and `KEY_REPEAT` to `true` for a cursor game.
2. **THE GAME**: replace everything in that section with your game. `build()` once for everything reused, `resized()` to fit the camera, `reset()` to start a round, `update(dt)` for every rule, `draw(dt)` for animation that changes no rules (it runs on every screen, so effects keep moving after a loss), `screenInput(code)` for choices on the title and end screens (a difficulty, a board size), `note(name)` when something worth testing happens, `endRound(won, { title, detail })` when the round ends — the title and detail are what the end screen says (`'CHECKMATE'`, `'Cleared in 1:42'`). Set `score` as the game goes.
3. **The screens** in the HTML: the `<title>`, the title screen's name, one line saying the goal, a line of controls, and the help table. Keep the element ids; add your own elements freely.
4. **CHECK**: the key presses that play your game for 5–10 seconds after it starts, and the `note()` names that must happen while they do. It must exercise the main mechanic: for breakout, keys that move the paddle under the ball and `expect: ['brick']`; for a maze, moves that reach a wall and `expect: ['bump']`; for chess, a move made with the cursor and `expect: ['move', 'reply']`. Make the first pickup or enemy appear in the same place every round, so the script can reach it; for a board or a deal, print the seed=1 layout with `console.warn` once, read it from check's page warnings, then remove the line.
5. **ACTIONS** if the game needs more keys than move, action, pause, mute and help. Help's `/` is only read off the playing screen, so a game may also use it during play.

The frame is the two parts marked THE FRAME. Leave them alone apart from ACTIONS, the camera, the lights and the fog: they are what make pause, restart, theming and `check` work. Code in THE GAME may use the names the first part lists; names starting with `_` are the frame's own, and a game naming something `held` or `clock` of its own is fine.

## 3. Check it, then look at it

```bash
"$SKILL_DIR/check" ~/Games/<name>/index.html
```

`check` opens the game headless, starts a round, pauses and resumes it, plays your `CHECK.play`, ends the round and restarts it, then opens it again in a light theme. It fails on any page error, a round that won't start, a simulation that doesn't move, a pause that doesn't stop it, or a `CHECK.expect` event that never happened. Fix what it reports and run it again until it says PASSED. Never weaken `CHECK` to make it pass: if the mechanic doesn't happen, the game is broken. It plays in real time, so physics can vary a little between runs; expect events that happen reliably, not ones that need luck.

Then look at `check-title.png`, `check-play.png`, `check-over.png` and `check-light.png` beside the game, every time, with your harness's tool for viewing an image (`view_image` in Codex, Read in Claude Code). Reading the file names in the output is not looking. A pass only proves the game runs; only the pictures show whether it is any good. For each picture, write one line answering each of these, then fix every answer that is no and check again:

- Does the play area fill most of the window, with the player and everything it needs fully on screen and nothing cut off at the edges?
- Is the player — or the cursor, in a board or card game — big and obvious, and is everything else told apart, in the theme's colours?
- Does it look like the game you set out to make, with enough in it to be worth playing, not a few shapes on an empty field?
- In `check-light.png`, is it as readable and as good-looking in a light theme?

`check` ends the round through `omarchyGame.end()`, so `check-over.png` shows the plain end screen. Look at your own losing and winning moments too: copy the game to a scratch folder, make the moment happen at once (a mine under the first reveal, a nearly cleared board), run check on the copy, and look.

## 4. Give it an icon

Write `~/Games/<name>/icon.svg`: a 256×256 square with a rounded tile filling it (`rx="56"`) in one strong colour, and on it one bold, simple picture of the game in a contrasting colour — a snake's coil, a chess knight, a flag on a mine — drawn with a few flat shapes. No text, no tiny detail, no more than three colours: it has to read at 32 pixels beside every other icon in the launcher. Then render it and look at it, large and small:

```bash
magick -background none ~/Games/<name>/icon.svg -resize 256x256 /tmp/<name>-icon.png
magick /tmp/<name>-icon.png -resize 32x32 /tmp/<name>-icon-32.png
```

## 5. Put it in the launcher

```bash
omarchy-games-install <name> ["Title"]
```

This adds the game to the app launcher (Super + Space) as a web app, opened in the desktop's current theme, with `icon.svg` as its icon (or a square cut from `check-play.png` if there is none). Run it again after renaming the title; the game file itself needs no reinstall after edits. Tell the user the game's name in the launcher, where the file is, the controls, and that it is removed under Remove > Web App (which leaves the file in `~/Games`).

## Making it good

- **Feel**: the player responds the moment a key goes down. Movement eases rather than snapping (`THREE.MathUtils.damp` in `draw`, or between fixed steps with its `alpha`). Every hit, pickup and death has a sound and something visible: a flash, a shake (`shake = 0.4`), a burst of particles, a squash; `noise()` makes knocks, thuds and explosions, `sound()` tones. Fire them once, at the moment it happens, never on every step while two things touch.
- **Fairness**: the first ten seconds are easy and it gets harder steadily. A loss is the player's mistake, never something they couldn't see coming: hazards appear far enough away to react, and no single key press ends the round by surprise (a snake ignores a turn straight back into itself; a ball starts on the paddle and leaves when the player launches it; a first reveal is never a mine).
- **Clarity**: one player, big enough to find at a glance and the most vivid thing on screen, never a dot. The score is always visible. `fitCamera()` from `resized()` keeps the whole play area in view at any window shape; check's window is about 16:9.
- **Colour**: every colour comes from `PALETTE`, or is mixed from its colours, or lightened or darkened toward white or black (`new THREE.Color(PALETTE.green).lerp(new THREE.Color(PALETTE.background), 0.4)`); white is fine for lights and for a mask a palette colour tints. Never a hex written for one theme. Light surfaces need a stronger mix than dark ones to show a difference. Tell things apart by brightness and size as well as hue, since some themes are nearly monochrome.
- **Polish**: the title screen says the goal in one line and the controls in another. The end screen says what happened and whether it was a new best; a game that can be drawn or won by a side says so in `endRound`'s title.

## three.js and the page

The template pins three.js 0.180. Much of what you remember is for older versions:

- Import only `three` and, if needed, `three/addons/...` through the importmap (`RoomEnvironment` with `PMREMGenerator` gives metal something to reflect; `BufferGeometryUtils` merges geometry). Never `examples/js/`, `THREE.Geometry`, `THREE.Face3`, `THREE.Math` (it's `THREE.MathUtils`), `*BufferGeometry` names (it's `BoxGeometry`), `renderer.outputEncoding` (it's `outputColorSpace`), or `physicallyCorrectLights`.
- Lights use physical units. The template's hemisphere and sun show colours close to the palette; keep them. A `PointLight` or `SpotLight` needs an intensity in the tens to hundreds to be seen at a few units away, or `decay: 0`. A floor that should match the page is `MeshBasicMaterial`, with a `ShadowMaterial` plane over it for shadows, as the template does.
- No files besides the one: no `TextureLoader`, `GLTFLoader`, fonts or images from paths, since a page opened from a file can't load its neighbours. Build shapes from geometry (`LatheGeometry` turns a profile into a chess piece), draw textures on a `<canvas>` with `THREE.CanvasTexture` (card faces, numbers), and put text in the HTML. No symbol glyphs such as ♛ ♠ in text or on canvas; they can draw as empty boxes. Draw them.
- Collisions are your own arithmetic in `update()`: distances, or boxes compared on each axis, all in world coordinates. If you parent meshes inside a group, compare `getWorldPosition()`, not `position`. Fast things move less than their own size per step or they pass through walls: split a step into substeps for a ball against flippers.
- Make geometries and materials once in `build()` and share them. Removing a mesh from the scene is enough at the end of a round; never create a material every frame.
- Hundreds of the same thing (bullets, tiles, particles) go in one `THREE.InstancedMesh` or `THREE.Points`.
- The camera is placed by your code, with `fitCamera()` or by hand. Not `OrbitControls`.
- The mouse: `pick(meshes)` is what is under the pointer, `pickPlane(y)` the point on the ground, and `wasClicked(0)`/`wasClicked(2)` work like `wasPressed`, inside `update()`. Clicks on the title and end screens start a round; give a clickable choice there a `<button>` and handle it from `screenInput` or its own listener added once in `build()`.
- Use the template's `random()` for anything random, never `Math.random()`: `check` seeds it, so its round plays the same every time and a pass or failure means something. `build()` and the first `reset()` use it too, so the round check plays starts after them.
- Heavy work — a chess engine's search, pathfinding, generating a level — must not stall a frame. Do a slice of a few milliseconds per frame from `draw` (a generator function you resume is the easy way), never per call of `update`, which can run a dozen times in one frame.
- `setAnimationLoop` is already running in the template. Don't start another loop, and don't add event listeners in `reset()`.
