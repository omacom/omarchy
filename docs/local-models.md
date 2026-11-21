# Local models

Local models run open models on the machine for the coding agents. The work happens in the `omarchy-local-ai` package, built from [omacom/omarchy-local-ai](https://github.com/omacom/omarchy-local-ai): its engine, the curated recipe catalog it reads from its own install directory, and their reference (`docs/engine.md` there, `/usr/share/doc/omarchy-local-ai/` once installed). It is a base package, so the panel can tell on every machine whether a recipe fits; Podman and crun, which run the models, are base packages too, and an NVIDIA machine gets nvidia-container-toolkit with its driver, for the CDI spec that hands the GPU to the containers; a machine installed without them gets what's missing the first time a model is set up. A recipe or engine change is a GitHub release of that repository, which the omarchy-pkgs recipe follows and builds from its tag.

## What stays in Omarchy

| Path | Role |
|---|---|
| `bin/omarchy-models` | The routed command (`omarchy models <command>`). Runs `omarchy-local-ai`; `use` installs Podman and crun, plus nvidia-container-toolkit where `omarchy-hw-nvidia` finds a GPU, first when they're missing: with `omarchy-pkg-add` in a terminal, or through `pkexec` for `use --detach`, which the local models panel runs with no terminal and follows on the setup's own line |
| `shell/plugins/local-models/Models.qml` | The plugin's service, one for the whole shell: watches the engine's `status.json` (`localModel`), `list.json` (`localRecipes`) and the tailnet survey, runs setups and pairings, reads the listing once at startup, and memory (`/proc/meminfo`, `omarchy-models memory --json`) while the panel is open |
| `shell/plugins/local-models/Panel.qml` | The `omarchy.local-models` bar icon and panel: the memory bar, a line per model, and +; what each shows and when the icon appears is in the plugin's [README](../shell/plugins/local-models/README.md) |
| `bin/omarchy-agent` | `--local` and `--local-model <recipe>` ask `omarchy-models overlay` for the agent's launch overlay; `--prefer-local` does so only while a model is running (the Quake console seeds with it), and otherwise launches the usual agent |
| `shell/plugins/agents/Main.qml` | Reads `status.json` only to hand the starter prompts to a running model |
| `install/omarchy-base.packages`, `migrations/1793563475.sh` | Install `omarchy-local-ai` on every machine |
| `manual/17-ai.md` | The user-facing guide |

## The contract with the package

The panel reads two files under `~/.local/state/omarchy/agent-local/`, written atomically by the engine:

- `status.json`: `{models: {<recipe>: {...}}, last, ram_total_gib, best}`. Each model has `unit` (`active`, `activating`, `inactive`, `failed`, `deactivating` or `removing`), `since_ms`, `expected_load_seconds`, `expected_stop_seconds`, `expected_remove_seconds`, `fits`, `error`, `vendor`, `observed` (its `ram_used_gib` is what loading the model took; the memory bar shows what `memory --json` measures it holding now), its endpoint, `update` (null, or which of its `image`, `weights` and `settings` the catalog has newer than it was set up with, and its `download_bytes` once sized) and `updating`. `Models.qml` keeps the last valid copy and accepts only those unit states.
- `list.json`: the recipes as this machine sees them, with `available`, `installed`, `best`, `vendor`, `architecture`, and the measured `memory_gib`, `context` and `decode_tok_s` the + list shows.

The memory bar reads free memory as the engine's `start_fit` does, `MemAvailable` plus `GPUReclaim`; whether a stopped model fits stays the engine's `fits`, and the bar only shows by how much.

The panel acts only through `omarchy-models`: `start <recipe>`, `stop <recipe>`, `remove <recipe>`, `update --detach <recipe>`, `logs <recipe>` then `dismiss <recipe>` in a floating terminal (opening a failed model's logs forgets the failure, so its error leaves the line), `status --write` (when a model shows as not fitting on open) and `use <recipe>` in a floating terminal. The engine's units call `omarchy-models status --write` from their start and stop hooks.
