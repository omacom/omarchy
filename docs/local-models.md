# Local models

Local models run open models on the machine for the coding agents. The work happens in the `omarchy-local-ai` package, built from [omacom/omarchy-local-ai](https://github.com/omacom/omarchy-local-ai): its engine, the curated recipe catalog it reads from its own install directory, and their reference (`docs/engine.md` there, `/usr/share/doc/omarchy-local-ai/` once installed). The package depends on Podman and crun, so only machines that use local models get them. A recipe or engine change is a release of that repository, which the omarchy-pkgs recipe builds from its tag.

## What stays in Omarchy

| Path | Role |
|---|---|
| `bin/omarchy-agent-local` | The routed command (`omarchy agent local <command>`). Runs `omarchy-local-ai`; when the package is missing, `use` from a terminal installs it with `omarchy-pkg-add` first, and anything else says how to set one up |
| `shell/plugins/agents/Main.qml` | Watches the engine's `status.json` (`localModel`) and `list.json` (`localRecipes`, null until the package has listed recipes) |
| `shell/plugins/agents/Panel.qml` | Model lines (play/pause, terminal, memory meter, loading, stopping and removing bars, errors, Delete to remove) and Add another › Local AI. Before the package is set up, Local AI opens a terminal running `omarchy-agent-local use best` |
| `bin/omarchy-agent` | `--local` and `--local-model <recipe>` ask `omarchy-agent-local overlay` for the agent's launch overlay |
| `shell/plugins/agents/Panel.qml` (Add another) | Runs `omarchy-agent-local refresh --quiet` when the add view opens, so Local AI lists what an upgraded package brought |
| `manual/17-ai.md` | The user-facing guide |

## The contract with the package

The panel reads two files under `~/.local/state/omarchy/agent-local/`, written atomically by the engine:

- `status.json`: `{models: {<recipe>: {...}}, last, ram_total_gib, best}`. Each model has `unit` (`active`, `activating`, `inactive`, `failed`, `deactivating` or `removing`), `since_ms`, `expected_load_seconds`, `expected_stop_seconds`, `expected_remove_seconds`, `fits`, `error`, `vendor`, `observed` and its endpoint. `Main.qml` keeps the last valid copy and accepts only those unit states.
- `list.json`: the recipes as this machine sees them, with `available`, `installed`, `best`, `vendor`, `architecture`, and the measured `memory_gib`, `context` and `decode_tok_s` the Local AI cards show.

The panel acts only through `omarchy-agent-local`: `start --setup <recipe>`, `stop <recipe>`, `remove <recipe>`, `status --write` (when a model shows as not fitting on open) and `use <recipe>` in a floating terminal. The engine's units call `omarchy-agent-local status --write` from their start and stop hooks.
