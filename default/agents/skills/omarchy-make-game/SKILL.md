---
name: omarchy-make-game
description: >
  Build a browser game or interactive 3D toy as a single HTML file with three.js, saved in ~/Games/vibes/<name>/ and played from Game Vibes in the app launcher: arcade games, endless runners, board and card games, puzzles, visual toys, small simulations. Starts from a working template, and covers what makes a game good (feel, fairness, clarity, polish), the three.js traps older examples walk into, checking it in a headless browser, and adding it to Game Vibes. Triggers: game, make me a game, three.js, WebGL, HTML game, browser game, canvas, arcade, 3D toy, snake, asteroids, breakout, pinball, platformer, runner, maze, puzzle, chess, solitaire, minesweeper.
---

# Building a Web Game

A game is one file, `~/Games/vibes/<name>/index.html` (unless the user asked for it somewhere else): three.js from the `../three.min.js` Game Vibes keeps beside the games, everything else written in the file — shapes from three.js geometry, sound synthesized with Web Audio, text in HTML over the canvas. It's listed in Game Vibes, one launcher for every game made this way, and opens in the desktop's current theme, plays from the keyboard (and the mouse, where that's natural), and keeps its best score.

Every game starts from `template.html` beside this file: a complete, working game (dodge the falling blocks) with what every game needs already done — title screen, pause on Esc and on losing focus, game over, restart, help, sound, a saved best score, a fixed-step loop that survives slow frames, seeded randomness, mouse picking, a camera fit, and lights that show the theme's colours true. You replace the game inside it, not the frame around it. Below, `SKILL_DIR` is the directory you read this file from (such as `~/.agents/skills/omarchy-make-game`).

## Keeping on with a game in Game Vibes

A game in `~/Games/vibes/<name>` is the user's own: change it where it is. A game that isn't there is one Omarchy ships, read-only in `$OMARCHY_PATH/default/games/vibes`, so copy it first and change the copy, which takes its place in Game Vibes:

```bash
omarchy-games-vibes-copy <game>
```

Give a second name (`omarchy-games-vibes-copy <game> <new-name>`) only when the user wants a variant beside the original, of a shipped game or their own, and then give it its own `NAME`, `<title>` and title screen so its saved scores and its tile are its own. Either way, skip to the step the change needs: the game section for a new rule, step 3 for polish, and always step 4 to check it and step 5 to open it. These games are already built on the template.

## 1. Settle the game

If the user hasn't said what game they want, ask whether it's a new game or one in Game Vibes to keep working on. Then decide, in one sentence each, before writing code:

- **Goal**: what the player is trying to do.
- **Controls**: which keys, and what each does. Arrow keys and WASD both, Space for the main action. Board and card games move a cursor with the arrows and also take the mouse.
- **Losing**: what ends the round.
- **Score or winning**: what is counted, whether more is better (points) or less (a time, a move count), and whether the round can be won (a maze, a level) or only survived (a runner, asteroids).
- **Getting harder**: what changes over time so it stays interesting.

One mechanic done well beats three done badly, but give it enough to play for a few minutes: a maze has many turns and dead ends, a shooter more than one kind of enemy, a runner obstacles that need different moves. Pick a short lowercase name of letters, digits and dashes (`snake`, `tilt-maze`).

## 2. Start from the template

If `~/Games/vibes/<name>` already holds a game, ask before replacing it. Otherwise:

```bash
mkdir -p ~/Games/vibes/<name>
cp "$SKILL_DIR/template.html" ~/Games/vibes/<name>/index.html
cp "$OMARCHY_PATH/default/games/vibes/three.min.js" ~/Games/vibes/
```

The second copy is three.js, which the game loads from `../three.min.js`; Game Vibes puts it there too, but only once it has opened.

Read the whole template once, then edit that copy in place, section by section. Never write the file from scratch or rewrite the frame.

1. **SETTINGS**: set `NAME`. Leave `PALETTE` as it is: Game Vibes hands every game the desktop's theme as it opens, and those colours only stand in without one. Set `BEST_IS` to `'lower'` for a time or a move count, `formatScore` to show it (`m:ss` for times), and `KEY_REPEAT` to `true` for a cursor game.
2. **THE GAME**: replace that whole section with your game. `build()` once for everything reused, `resized()` to fit the camera, `reset()` to start a round, `update(dt)` for every rule, `draw(dt)` for animation that changes no rules (it runs on every screen, so effects keep moving after a loss), `screenInput(code)` for choices on the title and end screens, and `endRound(won, { title, detail })` when the round ends — the title and detail are what the end screen says (`'CHECKMATE'`, `'Cleared in 1:42'`). Set `score` as the game goes.
3. **The screens** in the HTML: the `<title>` and the description meta (a few words Game Vibes shows under the name), the title screen's name, one line saying the goal, a line of controls, and the help table. Keep the element ids; add your own elements freely.
4. **ACTIONS**, if the game needs more keys than move, action, pause, mute and help.

Leave the two parts marked THE FRAME alone apart from ACTIONS, the camera, the lights, the fog and, for bloom, the one `renderer.render` call: they make pause, restart, theming and the way back to Game Vibes work. Names starting with `_` are the frame's own.

**The rule every game keeps: the player can always get back to Game Vibes.** `Esc` on the title and end screens and `Q` on the pause screen go back to the list, and `Esc` (or losing focus) pauses a round, so there's a way out from anywhere, mid-round included. Never take `Esc`, `P` or `Q` for something else, never keep `Esc` from reaching the frame (a game may use it first to drop a held piece, as long as the next press pauses), and keep the pause screen's line that says `Q` goes back. A game copied from before this rule gets the frame's `leave` action and that line.

## 3. Make it good

A plain version that plays comes first; check it (step 4), then add these in one or two passes, checking after each:

- **Feel**: the player responds the moment a key goes down. Movement eases rather than snapping (`THREE.MathUtils.damp` in `draw`). The camera follows with a lag and shakes briefly on a hit (`shake = 0.4`). Every hit, pickup and death has a sound and something visible: a flash, a burst of particles (`THREE.Points`), a squash, the score popping. `noise()` makes knocks, thuds and explosions, `sound()` tones. Fire each once, at the moment it happens, never on every step while two things touch.
- **Fairness**: the first ten seconds are easy and it gets harder steadily, with obstacles in patterns (gaps to thread, walls with one opening) rather than at random, so a run has rhythm. A loss is the player's mistake, never something they couldn't see coming: hazards appear far enough away to react, and no single key press ends the round by surprise (a snake ignores a turn straight back into itself; a ball starts on the paddle; a first reveal is never a mine).
- **Clarity**: one player, big enough to find at a glance and the most vivid thing on screen, never a dot. The score is always visible. `fitCamera()` from `resized()` keeps the whole play area in view at any window shape.
- **Colour**: every colour comes from `PALETTE`, mixed from its colours, or lightened or darkened toward white or black (`new THREE.Color(PALETTE.green).lerp(new THREE.Color(PALETTE.background), 0.4)`). Never a hex written for one theme. Tell things apart by brightness and size as well as hue, since some themes are nearly monochrome.
- **Glow**: in a dark theme (`PALETTE.mode === 'dark'`), emissive materials on what matters and bloom (`EffectComposer`, `RenderPass`, `UnrealBloomPass` and, last, `OutputPass`, which puts the colours right, all on `THREE`) make it come alive: build the composer once and call `composer.render()` where the frame calls `renderer.render(scene, camera)`, resizing it in `resized()`. Leave bloom off in a light theme, where it washes everything out.
- **Polish**: the end screen says what happened and whether it was a new best; a game that can be won or drawn says so in `endRound`'s title.

Done is a playable game with most of these in place, each checked once. Don't tune numbers turn after turn: when they're in and the checks pass, finish the icon, open it in Game Vibes, and tell the user what you built and what could come next.

## 4. Check it, then look at it

`omarchy agent look page` renders the page headless in real time on the GPU, presses keys as a player would, and prints a screenshot and the page's console errors. Fix every error first. Then look at a round in progress, pressing keys that exercise the game's main mechanic, and at the same round in a light theme:

```bash
omarchy agent look page ~/Games/vibes/<name>/index.html#seed=1 --keys "Space ArrowLeft ArrowLeft" --after 3000
omarchy agent look page ~/Games/vibes/<name>/index.html#seed=1 --keys "Space ArrowLeft ArrowLeft" --after 8000
omarchy agent look page ~/Games/vibes/<name>/index.html#seed=1 --keys "Space ArrowLeft" --theme catppuccin-latte
```

`#seed=1` plays the same round every time, so a change you made is what changed. In a game that runs on its own, the world should have moved between the first two shots, and the score risen if your keys did what scores; in a turn-based one, the shots should show the moves your keys made. If the round is already over, or nothing changed, find out why before adding anything else. Without `--theme` a game shows in the template's stand-in colours.

Then check the way back, from the list as a player comes in, mid-round: start a round, pause it, and leave. The shot must show the Game Vibes list, not the game.

```bash
omarchy agent look page "$(omarchy-games-vibes-launch --url <name>)" --keys "Space Escape KeyQ" --after 1500
```

Open every screenshot with your tool for viewing images; reading the path is not looking. For each, write one line answering each of these, then fix every no and look again:

- Does the play area fill most of the window, with the player and everything it needs fully on screen and nothing cut off at the edges?
- Is the player — or the cursor, in a board or card game — big and obvious, and is everything else told apart?
- Does it look like the game you set out to make, with enough in it to be worth playing, not a few shapes on an empty field?
- In the light theme, is it as readable and as good-looking?

Look at your losing and winning moments too: make one happen at once in a scratch copy (a mine under the first reveal, a nearly cleared board) and look at that. Check with `look page` only; the user sees the game once, when it's done (step 5).

## 5. Give it an icon and open it in Game Vibes

Write `~/Games/vibes/<name>/icon.svg`: a 256×256 square with a rounded tile filling it (`rx="56"`) in one strong colour, and on it one bold, simple picture of the game in a contrasting colour — a snake's coil, a chess knight, a flag on a mine — from a few flat shapes. No text, no tiny detail, no more than three colours: it has to read small in the Game Vibes list. Render it and look at it, large and small:

```bash
magick -background none ~/Games/vibes/<name>/icon.svg -resize 256x256 /tmp/<name>-icon.png
magick /tmp/<name>-icon.png -resize 32x32 /tmp/<name>-icon-32.png
```

When it's done, open it for the user in Game Vibes, which lists it by its `<title>` and icon and opens straight into it:

```bash
omarchy-games-vibes-launch <name>
```

Do this once, at the end, not while checking. Game Vibes refreshes its list each time it opens, so later edits and a changed title need nothing more. Tell the user the game is open, that it's in Game Vibes in the app launcher (Super + Space), where the file is, and the controls.

## Sharing a game

A game is shared as a git repository with its `index.html` and `icon.svg` at the root, named `omarchy-<name>-game` so it installs as `<name>`. When the user asks to share one, run `git init` in `~/Games/vibes/<name>`, commit those files, and push to the remote they give. Anyone on Omarchy then installs it from the menu (Install > Gaming > Game Vibes) or with:

```bash
omarchy games vibes install <git-repo-url>
```

## three.js and the page

The template pins three.js 0.180. Much of what you remember is for older versions:

- three.js is the global `THREE` from the template's `<script src="../three.min.js">`: no importmap, no `import`, and nothing from a CDN, so a game plays offline. Its addons are the bloom passes alone (`THREE.EffectComposer`, `THREE.RenderPass`, `THREE.UnrealBloomPass`, `THREE.OutputPass`). A game kept outside `~/Games/vibes` needs a copy of `~/Games/vibes/three.min.js` in the folder above it. Never `examples/js/`, `THREE.Geometry`, `THREE.Face3`, `THREE.Math` (it's `THREE.MathUtils`), `*BufferGeometry` names (it's `BoxGeometry`), `renderer.outputEncoding` (it's `outputColorSpace`), or `physicallyCorrectLights`. `THREE.Clock` has `getDelta()` and `getElapsedTime()` and nothing else. When unsure of an API, read `https://threejs.org/docs/` or the module source at the pinned version.
- Lights use physical units. Keep the template's hemisphere and sun, which show the palette true. A `PointLight` or `SpotLight` needs an intensity in the tens to hundreds to be seen a few units away, or `decay: 0`. A floor that should match the page is `MeshBasicMaterial`, with a `ShadowMaterial` plane over it for shadows, as the template does.
- One file, with nothing fetched: a page opened from a file can't `fetch` or `import` its neighbours, and an image from a path can't become a WebGL texture, so no `TextureLoader`, `GLTFLoader` or font files. (An `<img>` or a CSS background from a file beside the page does work, for a backdrop behind the canvas.) Build shapes from geometry (`LatheGeometry` turns a profile into a chess piece), draw textures on a `<canvas>` with `THREE.CanvasTexture` (card faces, numbers), and put text in the HTML. No symbol glyphs such as ♛ ♠, which can draw as empty boxes; draw them.
- Collisions are your own arithmetic in `update()`, in world coordinates: use `getWorldPosition()` for meshes inside a group. Fast things move less than their own size per step or they pass through walls: split a step into substeps for a ball against flippers.
- Make geometries and materials once in `build()` and share them; never `new` one inside the loop. Reuse objects (a pool of obstacles moved back ahead of the player), and put hundreds of the same thing in one `InstancedMesh` or `Points`.
- Place the camera in code, with `fitCamera()` or by hand. Not `OrbitControls`.
- The mouse: `pick(meshes)` is what's under the pointer, `pickPlane(y)` the point on the ground, and `wasClicked(0)` works like `wasPressed`, inside `update()`. Clicks on the title and end screens start a round; give a choice there a `<button>`.
- Use the template's `random()`, never `Math.random()`, so `#seed=1` replays a round.
- Heavy work — a chess engine's search, pathfinding, generating a level — must not stall a frame. Do a slice of a few milliseconds per frame from `draw` (a generator you resume is the easy way), never from `update`, which can run a dozen times in one frame.
- The template's `setAnimationLoop` is already running. Don't start another loop, and don't add event listeners in `reset()`.
