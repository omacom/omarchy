# Local Models

One bar icon and one panel for the models that run on hardware you own: this machine's, and those other machines share on the tailnet. `Models.qml` follows what `omarchy-models` writes to `~/.local/state/omarchy/agent-local/` and runs the setups and pairings the panel starts; `Panel.qml` owns the bar button and the popup. [`docs/local-models.md`](../../../docs/local-models.md) covers the contract with the engine.

The icon sits left of the agents icon, and shows only on a machine that can run a model itself: the catalog has a recipe that fits it (the engine's `available`), a model is set up here, or another DGX Spark is cabled to it. Models the tailnet shares show on such a machine, but never make the panel appear on one that can't run any, where Super + Ctrl + Shift + X and IPC open nothing either.

## Panel

- **Hero** — the sparkles, and how much memory is free of the machine's total. Its corner has + to add a model, while there is one that fits and isn't set up, or a tailnet model hidden from the page.
- **Memory bar** — the machine's RAM to scale: what Omarchy holds (the system and its apps), then each running model in turn, then what's free, outlined. A model's slice is what it holds now, as `omarchy-models memory --json` measures it, which for an idle model can be far less than it took to load. Free is `MemAvailable` plus the GPU driver's pooled pages (`GPUReclaim`), the room the engine itself counts when it decides whether a model fits, read on open and every 2 seconds while the panel stays open. The line under it adds up Omarchy and the models. With the pointer or the keyboard cursor on a model, it speaks for that one instead: a running model's slice lights up and the line says what it holds; a stopped model lays what it needs into the free space, in the accent when it fits and in the warning color when it doesn't, and the line says by how much. Whether it fits is the engine's call (`fits` in `status.json`), the same one that greys out its play button.
- **One line per model** — this machine's models and setups first, then the tailnet's, then the recommended model as an offer while none is set up, or a cabled DGX Spark first of all. Lines keep their place when a model starts or stops; drag one by its mark, or press Ctrl+Up/Down, to move it, and the order is kept in `~/.local/state/omarchy/local-models-order.json`. Each has its maker's mark (drawn from `../agents/assets/`, where the launchers and notifications find them too), name and what it makes, and its buttons: update, share, play or pause, and the terminal or Fantasi once it runs; a tailnet model pairs and disconnects instead. Under the name, the memory it holds or needs, the download or load as it goes, and any error, which opens the model's logs.
- **Adding** — + lists the catalog's recipes that fit and aren't set up, recommended first, then the tailnet's models hidden from the page under _Network models_. Choosing a recipe sets it up in the background, with its own line following the download; choosing a hidden model brings it back.

## Interactions

- Bar icon: left = panel, middle = refresh.
- Panel: the arrows (or `h`/`j`/`k`/`l`) walk a cursor over everything that does something, row by row. Ctrl+Up/Down (or Ctrl+`k`/`j`) moves the line the cursor is in. Enter acts on it, or refreshes when nothing is lit; `r` refreshes, Delete removes the model on this machine (or hides an offer or a tailnet model), Tab moves to the neighboring bar panel, Esc leaves adding or closes.
- IPC: `omarchy-shell omarchy.local-models <open|close|toggle|refresh>`.

## Settings

Lines hidden with Delete live in the widget's entry in `~/.config/omarchy/shell.json`, by line id: `local:<recipe>` for an offer, `local:link` for a cabled Spark, `net:<host>/<recipe>` for a tailnet model. A model set up here is removed rather than hidden.

```json
{ "id": "omarchy.local-models", "hidden": ["net:box/qwen3.8-27b-gufo"] }
```
