---
name: web-game
description: >
  Build a browser game or interactive 3D toy as a single HTML file with three.js: arcade games, endless runners, visual toys, small simulations. Covers the file's shape, a game loop that survives slow frames, the polish that makes it feel good (bloom, particles, camera motion, sound, difficulty), and checking it in a headless browser. Triggers: game, three.js, WebGL, HTML game, browser game, canvas, arcade, 3D toy.
---

# Building a Web Game

One `index.html`, no build step, three.js from a CDN pinned to an exact version. Get a plain version playable first, check it, then make it feel good one item at a time, checking after each.

## Shape

```html
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>Game</title>
  <style>html, body { margin: 0; height: 100%; overflow: hidden; background: #05060a; font-family: system-ui, sans-serif; }</style>
  <script type="importmap">
    { "imports": {
      "three": "https://cdn.jsdelivr.net/npm/three@0.170.0/build/three.module.js",
      "three/addons/": "https://cdn.jsdelivr.net/npm/three@0.170.0/examples/jsm/"
    } }
  </script>
</head>
<body>
  <div id="hud"></div>
  <script type="module">
    import * as THREE from "three";

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
    renderer.setSize(innerWidth, innerHeight);
    document.body.appendChild(renderer.domElement);
    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(70, innerWidth / innerHeight, 0.1, 500);
    addEventListener("resize", () => {
      camera.aspect = innerWidth / innerHeight;
      camera.updateProjectionMatrix();
      renderer.setSize(innerWidth, innerHeight);
    });

    const keys = new Set();
    addEventListener("keydown", (e) => { keys.add(e.code); if (e.code === "Space" || e.code === "Enter") onAction(); });
    addEventListener("keyup", (e) => keys.delete(e.code));

    let state = "title"; // "title" | "playing" | "over"
    function reset() { /* put every moving thing back, zero the score */ }
    function onAction() { if (state !== "playing") { reset(); state = "playing"; } }

    const clock = new THREE.Clock();
    renderer.setAnimationLoop(() => {
      // A stalled tab or a slow first frame must not teleport the player into
      // an obstacle: cap the step.
      const dt = Math.min(clock.getDelta(), 1 / 30);
      if (state === "playing") update(dt);
      renderer.render(scene, camera);
    });
    function update(dt) { /* move, spawn, collide, score */ }
  </script>
</body>
</html>
```

- Use `THREE.Clock`'s `getDelta()` and `getElapsedTime()`; it has no other time methods. Read the docs for any three.js API you aren't sure of: `https://threejs.org/docs/` or the module source under the pinned version.
- Steer with `keys.has("ArrowLeft") || keys.has("KeyA")` inside `update`, so holding a key steers smoothly.
- The title screen, the HUD, and the game-over screen are HTML over the canvas. Game over shows the score and the best score (kept in `localStorage`) and how to play again.
- Make every object once and reuse it: a pool of obstacles moved back ahead of the player, never `new` geometry or materials inside the loop.

## Making It Feel Good

A plain version that works comes first. Then add these, checking the game after each:

- **Light and glow.** Emissive materials on what matters, fog in the background color so things appear out of the dark, and bloom: `EffectComposer`, `RenderPass` and `UnrealBloomPass` from `three/addons/postprocessing/`, rendering through the composer instead of the renderer.
- **Motion you can feel.** The camera follows with a lag (`camera.position.lerp(target, 1 - Math.exp(-5 * dt))`), the field of view widens as speed rises, and the camera shakes briefly on a hit.
- **Particles.** A `THREE.Points` cloud for speed streaks or stars rushing past, a trail behind the player, and a burst when something breaks or the player crashes.
- **A difficulty curve.** Speed and density rise over time, and obstacles come in patterns (gaps to thread, walls with one opening, moving pieces) rather than at random, so the run has rhythm.
- **Feedback.** Sound from the Web Audio API with oscillators and noise, made in code (no files), started on the first key press: a tone for points, a thud for hits. A near-miss bonus, the score popping when it rises, a short slow-motion on the crash.
- **Readable at a glance.** Three or four colors that carry meaning (player, danger, reward), a big score, and a title screen that says the keys, on a dark panel so the glow behind it can't wash the text out.

Done is a playable game with most of these in place, each checked once. Add them in one or two passes rather than tuning numbers turn after turn; when they're in and the checks pass, stop and tell the user what you built and what could come next.

## Checking It

`omarchy agent look page index.html` renders the page headless and prints its console errors; open the image it prints. Fix every error before anything else. Then look at a run in progress, pressing keys as a player would:

```bash
omarchy agent look page index.html --keys "Space ArrowLeft ArrowLeft" --after 3000
omarchy agent look page index.html --keys "Space ArrowLeft ArrowLeft" --after 8000
```

The page runs in real time on the GPU, as it would for a player, and `--after` is how long it plays before the shot. Between the two shots the score should rise and the world should have moved about as far as a player would see in five seconds. If the run is already over, or nothing changed, find out why before adding anything else. Never open the page in the user's browser to test it; tell them where it is when it's done.
