# Local Models

A service-only plugin for the models that run on hardware you own. `Models.qml` follows what `omarchy-models` writes to `~/.local/state/omarchy/agent-local/` (this machine's models in `status.json`, the catalog's recipes in `list.json`, the models other machines share on the tailnet in `network.json`) and runs the setups the agents panel starts, so they carry on while it's closed. [`docs/local-models.md`](../../../docs/local-models.md) covers the contract with the engine.

It has no panel of its own. Coding models are managed from the agents panel, which draws a line for each one added and offers the rest under +; see the [agents README](../agents/README.md). Image, video and music models have no shell UI: Fantasi and Flowtunes manage them, as `omarchy models` does.

What it does beyond following the files:

- **Setups** — `setUp(recipe)` runs `omarchy-models use --detach`, which installs Podman through polkit first on a machine without it. One runs at a time; others chosen meanwhile wait their turn. Until `status.json` lists a setup, `setupRows()` stands in for it: starting, installing, waiting, or failed with the reason the command gave.
- **Ready to code** — a coding model set up here sends a notification once it has downloaded and loaded, whose click opens an agent on it.
- **Launchers** — every model set up gets an app launcher, drawn by `omarchy-models-launchers`, run again when a setup finishes in the background or a model goes.
- **Memory** — `readMemory()` asks `omarchy-models memory --json` what each running model holds now, into `modelMemory`; nothing reads it until a panel showing memory calls it.
- **Tailnet** — `refreshNetwork()` surveys the models paired machines share, which the agents panel runs while it's open; `shareClients` counts the machines using each model this one shares.
