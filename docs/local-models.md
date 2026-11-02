# Local models

Local models run open models on the machine for the coding agents. The work happens in the `omarchy-local-ai` package, built from [omacom/omarchy-local-ai](https://github.com/omacom/omarchy-local-ai): its engine, the curated recipe catalog it reads from its own install directory, and their reference (`docs/engine.md` there, `/usr/share/doc/omarchy-local-ai/` once installed). It is a base package, so the panel can tell on every machine whether a recipe fits; Podman and crun, which run the models, are only optional dependencies, installed the first time a model is set up. A recipe or engine change is a GitHub release of that repository, which the omarchy-pkgs recipe follows and builds from its tag.

## What stays in Omarchy

| Path | Role |
|---|---|
| `bin/omarchy-agent-local` | The routed command (`omarchy agent local <command>`). Runs `omarchy-local-ai`; `use` installs Podman and crun with `omarchy-pkg-add` first when they're missing |
| `shell/plugins/agents/Main.qml` | Watches the engine's `status.json` (`localModel`) and `list.json` (`localRecipes`) |
| `shell/plugins/agents/Panel.qml` | Model lines (play/pause, terminal, memory meter, loading, stopping and removing bars, errors, Delete to remove) and Add another › Local AI, offered only when `list.json` has a recipe that fits this machine, and greyed out once every fitting recipe is set up |
| `bin/omarchy-agent` | `--local` and `--local-model <recipe>` ask `omarchy-agent-local overlay` for the agent's launch overlay |
| `shell/plugins/agents/Panel.qml` (Add another) | Runs `omarchy-agent-local refresh --quiet` whenever the picker shows, so Local AI lists what an upgraded package brought |
| `install/omarchy-base.packages`, `migrations/1793563475.sh` | Install `omarchy-local-ai` on every machine |
| `manual/17-ai.md` | The user-facing guide |

## The contract with the package

The panel reads two files under `~/.local/state/omarchy/agent-local/`, written atomically by the engine:

- `status.json`: `{models: {<recipe>: {...}}, last, ram_total_gib, best}`. Each model has `unit` (`active`, `activating`, `inactive`, `failed`, `deactivating` or `removing`), `since_ms`, `expected_load_seconds`, `expected_stop_seconds`, `expected_remove_seconds`, `fits`, `error`, `vendor`, `observed` and its endpoint. `Main.qml` keeps the last valid copy and accepts only those unit states.
- `list.json`: the recipes as this machine sees them, with `available`, `installed`, `best`, `vendor`, `architecture`, and the measured `memory_gib`, `context` and `decode_tok_s` the Local AI cards show.

The panel acts only through `omarchy-agent-local`: `start <recipe>`, `stop <recipe>`, `remove <recipe>`, `status --write` (when a model shows as not fitting on open) and `use <recipe>` in a floating terminal. The engine's units call `omarchy-agent-local status --write` from their start and stop hooks.
