# Local AI

A bar widget that runs a model validated for each GPU in the machine, or across several of one kind, and opens a coding agent on it. It is these files:

| File | Role |
|---|---|
| `bin/omarchy-local-ai` | The backend: detect GPUs, download and check weights, start and stop containers, open agents, print a snapshot |
| `shell/plugins/panels/local-ai/Model.js` | Pure functions: snapshot and ui state in, a view (rows and actions) out |
| `shell/plugins/panels/local-ai/Panel.qml` | Draws the view; turns an action (`verb\|arg\|arg`) into a backend verb |
| `shell/plugins/panels/local-ai/recipes.json` | The vendored recipes, one card kind per line: from [local-ai-registry](https://github.com/0xSero/local-ai-registry)'s `plugin/v2/recipes.json`, every recipe of each kind, best first: the first on one card is the kind's recommended model, and the rest are what a card's Config offers, on one card or across several (a group) |

## Flow

The widget polls `omarchy-local-ai snapshot` (every 1.5 s while something starts, 5 s while open, 30 s closed). The snapshot joins the GPUs (`nvidia-smi`, the Arc Pro B70's PCI id and hwmon, `amd-smi`), the recipes and one folder per running model, `~/.local/state/omarchy/local-ai/deploy/<recipe>/` with `config.json` (cards, port, agent, folder) and `status.json` (step, detail, percent, error). `Model.build()` turns that into the page; nothing in the view model has side effects.

`run <recipe> <gpu>[,<gpu>...]` claims the cards and a port under a lock, writes `config.json`, and starts a detached worker. The worker downloads the weights as the user and checks every file's size and sha256 against the Hub listing at the pinned revision, starts the engine and a keyed gateway, waits for the model, and sends one request to check it answers at GPU speed. Each step writes `status.json` and a desktop notification says when it starts, is ready, or failed and why.

The gateway (`ghcr.io/0xsero/gateway`, pinned by digest) listens on `127.0.0.1` only, requires a per-install bearer key, translates the Anthropic and Responses APIs to chat completions for Claude Code and Codex, and writes one usage line per answer. The widget's tokens, speeds, charts and activity grid come from those lines: each model keeps `summary.json` beside its log (tokens per hour, and the counts and sums the averages need), brought up to date from only the lines added since, so once built it costs a snapshot about the same with a million answers as with ten (building it from a large existing log takes a few seconds per 100,000 lines, once).

`open <recipe>` starts the chosen agent in a terminal, in the chosen folder, pointed at the gateway. The key is passed in the agent's environment or in a config file under the state folder that only the user can read; nothing in the agent's own config is changed.

## Privilege

Omarchy keeps users out of the docker group, so starting containers needs root. The backend follows `omarchy-windows-vm`: when `omarchy-sudo-docker` says Docker needs sudo, it runs `pkexec /usr/bin/omarchy-local-ai __<phase>` (start, stop, share or purge), after checking that the command and every directory above it are root-owned. As root it pins `PATH` and the locale, resolves the caller from `PKEXEC_UID` and the account database, re-reads the recipe from the root-owned install rather than taking it as an argument, checks every recipe string with `policy()`, and mounts only paths that resolve to themselves and belong to the caller. Engine containers run with `no-new-privileges` and carry the caller's uid as a label, so stop and remove touch only that user's containers. Sharing on the tailnet (`tailscale serve`) uses the same path when the user is not the tailnet's operator. `etc/polkit-1/actions/org.omarchy.local-ai.policy` gives each phase a plain message, so the password prompt says what it is for rather than showing the command line.

## Why it is shaped this way

- **Validated models, vendored.** Every recipe was accepted on its exact card, or cards: download, load, a correctness check, speed at several context lengths. Shipping them inside Omarchy means root reads a file that root owns; a recipe fetched at runtime could never be trusted in the privileged step. A card without an accepted recipe shows Coming soon and links the list in `supported/`.
- **EXL3 first, engines that serve it in-process.** The registry recommends, per card, EXL3 weights on SGLang or vLLM ahead of TabbyAPI and llama.cpp, then vision, context and measured decode. On a 3090 that is Qwen3.8-27B at 200K context and about 90 tok/s.
- **Containers, not packages.** Engines need exact CUDA, ROCm or oneAPI stacks; an image pinned by digest is the smallest thing that reproduces the accepted run.
- **A gateway in front.** Engines differ in API and none checks a key; the gateway gives every engine the same keyed endpoint and the same usage accounting.
- **The view is data.** `Model.js` is plain functions over the snapshot, so every page (home, a running model, a card's Config, a group, all GPUs, Coming soon) is a function of state and can be rendered without the backend.
- **Color is picked by contrast, not by hand.** `Model.tones` derives four tones from the theme with APCA: ink (Lc 90) for what matters now (a model's name, the primary action, a choice made), a value tone (Lc 80) for what a label names, one label tone (Lc 60) for every label and heading, and a rule tone (Lc 15) for lines that are not text. Each is measured on the card surface, the lighter of the panel's two backgrounds, so any theme stays readable; a theme whose foreground cannot reach Lc 90 is pushed toward white or black.
- **One grid.** Text starts and ends on a single gutter; surfaces sit 8 in from the edge so the text inside them lands on the same gutter. Two sizes: the model's name, and everything else. Rows in a group touch, a heading sits on its rows, groups are a clear gap apart, so what belongs together reads together before any word is read.

## Limits

- AMD cards are found through `amd-smi`, which comes with ROCm; without it they show Coming soon.
- In the prompt path the backend cannot read Docker, so a crashing engine is reported when its 30-minute wait ends rather than on its second restart.
- The widget does not remove itself from the bar; Remove deletes models, containers, engine images, weights and settings.
