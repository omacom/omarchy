# Local models

Local models run open models on the machine for the coding agents. The work happens in the `omarchy-local-ai` package, built from [omacom/omarchy-local-ai](https://github.com/omacom/omarchy-local-ai): its engine, the curated recipe catalog it reads from its own install directory, and their reference (`docs/engine.md` there, `/usr/share/doc/omarchy-local-ai/` once installed). It is a base package, so the agents panel can tell on every machine whether a recipe fits; Podman and crun, which run the models, are base packages too, and an NVIDIA machine gets nvidia-container-toolkit with its driver, for the CDI spec that hands the GPU to the containers; a machine installed without them gets what's missing the first time a model is set up. A recipe or engine change is a GitHub release of that repository, which the omarchy-pkgs recipe follows and builds from its tag.

## What stays in Omarchy

| Path | Role |
|---|---|
| `bin/omarchy-models` | The routed command (`omarchy models <command>`). Runs `omarchy-local-ai`; `use` installs Podman and crun, plus nvidia-container-toolkit where `omarchy-hw-nvidia` finds a GPU, first when they're missing: with `omarchy-pkg-add` in a terminal, or through `pkexec` for `use --detach`, which the agents panel runs with no terminal and follows on the setup's own row |
| `shell/plugins/local-models/Models.qml` | A service-only plugin, one for the whole shell: watches the engine's `status.json` (`localModel`), `list.json` (`localRecipes`) and the tailnet survey, runs the setups the agents panel starts, announces a coding model it set up once it's ready, keeps the launchers in step, reads the listing once at startup, and, only when a panel asks (`readMemory()`), what each running model holds (`omarchy-models memory --json`) |
| `shell/plugins/agents/Panel.qml` | The coding models' lines in the agents panel and their offers under +; what each shows is in the plugin's [README](../shell/plugins/agents/README.md). Image, video and music models have no shell UI: Fantasi and Flowtunes manage them, as `omarchy models` does |
| `bin/omarchy-agent` | `--local`, `--local-model <recipe>` and a default agent of `local` ask `omarchy-models overlay` for pi's launch overlay; a model that is set up but stopped is started first |
| `shell/plugins/agents/Main.qml` | Keeps which local models were added to the panel, in `~/.local/state/omarchy/agents/local-models.json` |
| `install/omarchy-base.packages`, `migrations/1793563475.sh` | Install `omarchy-local-ai` on every machine |
| `manual/17-ai.md` | The user-facing guide |

## The contract with the package

The agents panel reads two files under `~/.local/state/omarchy/agent-local/`, written atomically by the engine:

- `status.json`: `{models: {<recipe>: {...}}, last, ram_total_gib, best}`. Each model has `unit` (`active`, `activating`, `inactive`, `failed`, `deactivating` or `removing`), `since_ms`, `expected_load_seconds`, `expected_stop_seconds`, `expected_remove_seconds`, `fits`, `error`, `vendor`, `observed` (its `ram_used_gib` is what loading the model took), its endpoint, `update` (null, or which of its `image`, `weights` and `settings` the catalog has newer than it was set up with, and its `download_bytes` once sized) and `updating`. `Models.qml` keeps the last valid copy and accepts only those unit states.
- `list.json`: the recipes as this machine sees them, with `available`, `installed`, `best`, `vendor`, `architecture`, and the measured `memory_gib`, `context` and `decode_tok_s` the + list shows.

Whether a stopped model fits is the engine's `fits`: a line that doesn't greys out its play button and says there isn't enough memory.

The agents panel acts only through `omarchy-models`: `start <recipe>`, `stop <recipe>`, `share <recipe> [--off]`, `remove <recipe>`, `update --detach <recipe>`, `use --detach <recipe>` (through the service), `network --write` while it's open, `logs <recipe>` then `dismiss <recipe>` in a floating terminal (opening a failed model's logs forgets the failure, so its error leaves the line), and `link setup` in a floating terminal for a cabled DGX Spark. Pairing with another machine is `omarchy models pair`'s alone. The engine's units call `omarchy-models status --write` from their start and stop hooks.
