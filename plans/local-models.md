# Plan: Local models — `omarchy agent local use <recipe>`

Revision 2. Revised after a review pass: lifecycle, endpoint security, client selection, memory checks, supply chain and config ownership tightened; phase 1 cut down.

## Problem

A 128GB unified-memory machine (Strix Halo, DGX Spark/GB10) can now run open models that are genuinely useful as coding agents: Qwen3.8 Flash Next, GLM-5.3-Flash, DeepSeek V4.1 Flash in pruned form. Getting one running is still an afternoon of archaeology. You pick from a dozen community quants of the same model, find the one llama.cpp branch or fork that supports its architecture, install build dependencies by trial and error (cmake, vulkan-headers, then spirv-headers when configure fails), raise kernel GPU memory limits, copy a 15-flag command line out of a gist, and then wire the endpoint into every agent CLI's own provider config by hand. None of it is reproducible: the next machine, or the same machine after a rebuild, starts from zero.

The work that makes these models fast already exists as recipes: curated quant + runtime + flag combinations published by people like Mia (mia-ai.net/models) and 0xSero, plus community builds tuned for a specific chip. What's missing is a way to run a recipe as one command, get the same result every time, and have Omarchy's agents and agent panel see it.

## Shape

- `omarchy agent local use <recipe>` checks the machine can hold the model right now, pulls a pinned and signed backend container image, downloads pinned and verified model weights, and starts the model as a rootless Podman container under a systemd user unit.
- Every backend (llama.cpp Vulkan/ROCm/CUDA, halogen, vLLM, SGLang, …) is a container image with the same shape, so the framework only ever starts and stops containers. Swapping backend is one line in a recipe.
- The active model is served at `127.0.0.1:11435` with an OpenAI-compatible API behind a per-user key.
- Launching an agent in local mode points it at that endpoint and the active recipe's model, through launch-time config Omarchy owns, never by rewriting the agent's own config files. OpenCode first; other clients once each has a supported overlay.
- The agent panel shows whether a local model is running and can switch or stop it.

## Rejected approaches

- **Native builds per machine**: what validating this plan took by hand (clone, cmake, three rounds of missing headers, a fork for unmerged architecture support). Every recipe that needs a different fork or branch multiplies it. Containers move the build to CI, once.
- **Distro packages per backend** (`llama.cpp-vulkan` in the Omarchy repo): solves llama.cpp only. Halogen, EngramHalo.cpp, ROCm forks and unmerged PR branches are exactly what the best recipes depend on, and they will never all be packaged. A package also pins one version system-wide, while recipes need different runtime revisions side by side.
- **Docker**: in base already, but needs a root daemon and the docker group or sudo for a per-user model server. Podman runs rootless and Quadlet turns a container into an ordinary systemd user unit.
- **Ollama / LM Studio as the runtime**: both stay installable from the menu, but they lag on new architectures and don't expose the flags (speculative-decoding drafts, KV cache types, tensor placement) that recipes are made of.
- **A model zoo UI that browses Hugging Face**: thousands of quants, most broken or untested on a given chip. A recipe is a curated, measured claim — "this runs on this hardware at this speed" — which is the actual value.
- **Merging provider blocks into agents' config files**: even a "merge" rewrites the file, loses JSONC comments and TOML formatting, races the client's own writes, collides with user-owned `llamacpp` entries, and misses Codex's per-account homes (`bin/omarchy-agent` sets `CODEX_HOME` per account). Launch-time overlays avoid all of it.

## Design

### Recipes

A recipe is data, one TOML file per model setup: shipped recipes in `default/omarchy/agent-local/`, user recipes in `~/.config/omarchy/agent-local/` (same id overrides). Recipe ids match `^[a-z0-9][a-z0-9.-]*$`; anything else is rejected before it reaches a path, a unit name or a Quadlet specifier.

```toml
name = "Qwen3.8 Flash Next"
summary = "125B MoE, ~6B active, 4-bit, MTP drafting."

[[hardware]]                          # tested qualifications, not guesses
platform = "x86"
gpu = "amd-strix-halo"
backend = "vulkan"
measured = "measurements/qwen3.8-flash-next-strix-halo.toml"

[runtime]
image = "ghcr.io/omarchy/llama.cpp-vulkan@sha256:…"   # per-arch digest, never an index

[model]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "<commit sha>"
include = ["UD-IQ4_XS/*", "mtp-Qwen3.8-Flash-Next-Q8_0.gguf"]
main = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf"
draft = "mtp-Qwen3.8-Flash-Next-Q8_0.gguf"

[[variant]]                           # validated context sizes with measured peak memory
ctx = 131072
peak_gpu_gib = 72
peak_host_gib = 6

[server]
args = ["-fa", "on", "-ctk", "q8_0", "-ctv", "q8_0", "--spec-type", "draft-mtp", "--spec-draft-n-max", "4", "--jinja"]

[sampling]                            # server-side defaults; a client's explicit values win
temperature = 1.0
top_p = 0.95
top_k = 20
```

- Reproducibility comes from three pins: image digest, model revision, flags. Two qualified machines running the same recipe run the same bytes with the same arguments.
- `hardware` replaces a bare platform list: `x86` alone admits machines with no usable GPU. Each entry names the platform (`omarchy-hw-platform` names), the GPU family and backend, and points at a measurement record. A recipe only claims hardware someone measured.
- A measurement record captures exact artifacts, peak GPU and host memory, prefill and decode speed at stated context depths, and the llama-bench or equivalent command that produced them. Performance numbers in recipes, menus and docs come from these records, not from gists.
- `sampling` is passed to the server as its defaults (`--temp`, `--top-p`, `--top-k` for llama.cpp, mapped by the image adapter), so every client gets sane values without client config.
- Generated server arguments are built as an argument array and escaped for Quadlet; a test feeds hostile values (spaces, `%`, quotes) through the generator.

### The backend container contract

Every backend image provides:

| | Contract |
|---|---|
| API | OpenAI-compatible on `:8080`: `/v1/models`, `/v1/chat/completions` with streaming and tool calls through the model's chat template. Admin and web UI routes are disabled |
| Auth | Requires a bearer key, read from a Podman secret; unauthenticated requests are rejected |
| Health | `/health` returns 200 only once the model is loaded; the image ships its own health-check executable |
| Models | Read-only mount of only the selected recipe's model directory at `/models` |
| Entrypoint | Accepts `--model`, `--draft`, `--ctx`, `--alias`, sampling defaults, then passes remaining recipe args through; a thin adapter maps these onto the backend's own CLI |
| GPU | Declares its backend; Omarchy maps it to the minimal devices (see Rootless GPU) |
| Smoke test | A `--self-test` entrypoint that lists the GPU device it sees and exits, used by preflight |

"OpenAI-compatible" is defined by an acceptance check rather than assumed: a streamed completion, a tool call round trip, and a chat-template sanity check run against every image and recipe before either is published.

### Images and supply chain

- Images are built in CI in a dedicated repo from Containerfiles that pin the base image by digest, the backend by upstream commit, and Mesa/ROCm/CUDA by version. One image per backend × GPU flavor × architecture.
- Images are signed and carry build provenance. A Podman `policy.json` scoped to `ghcr.io/omarchy` requires the signature, so a digest is both the exact bytes and proof of who built them.
- Recipes pin per-architecture digests, not a multi-arch index, so the digest names the same bytes on every machine that uses it.
- Security and Mesa updates produce new images; they reach users only when the shipped recipe's digest is updated through a normal Omarchy update. Installed recipes never float. Mesa updates matter: Vulkan and ROCm images carry their userspace driver and only the kernel driver comes from the host, and Strix Halo performance still moves with Mesa.
- Containers run with a read-only root, all capabilities dropped, `no-new-privileges`, and no outbound network beyond the published port where the network mode allows it.
- User-supplied Containerfiles are out of scope until this pipeline exists.

### Rootless GPU

- Podman and crun join `omarchy-base.packages`, with a migration (via the migration helper, using `omarchy-pkg-add`, idempotent, failing synchronously) that installs them on existing machines. Commands then treat Podman as a runtime invariant and never check for it. Cost is about 107 MiB installed: podman 83 MiB, netavark and aardvark-dns 13 MiB, crun and its checkpoint/restore dependencies 9 MiB, the rest under 2 MiB; everything else in its tree is already on the base system.
- Devices are minimal: the GPU's own render node (not all of `/dev/dri`), plus `/dev/kfd` for ROCm, plus CDI `nvidia.com/gpu=all` for CUDA. Where a node is group-owned rather than world-accessible, the unit uses `GroupAdd=keep-groups`, which requires the user systemd manager to hold that group.
- `use` runs a preflight before downloading anything: subordinate ID ranges exist, the render node is accessible to the user manager, and the image's `--self-test` sees the GPU from inside a container. Failures say what to fix. `use` never changes device permissions or groups itself.
- Privileged one-time setup lives in its own command, `omarchy-setup-agent-local-gpu`, run with sudo from a terminal: group membership where needed, and on CUDA platforms CDI spec generation into `/etc/cdi` plus a pacman hook that regenerates it when the NVIDIA driver changes.

### Running it: Podman Quadlet

`use` generates one Quadlet file and restarts one unit:

```ini
# ~/.config/containers/systemd/omarchy-agent-local.container
[Unit]
Description=Omarchy local model: Qwen3.8 Flash Next
PartOf=graphical-session.target
After=graphical-session.target

[Container]
Image=ghcr.io/omarchy/llama.cpp-vulkan@sha256:…
Label=org.omarchy.agent-local.recipe=qwen3.8-flash-next
AddDevice=/dev/dri/renderD128
Volume=%h/.local/share/omarchy/models/qwen3.8-flash-next:/models:ro
PublishPort=127.0.0.1:11435:8080
Secret=omarchy-agent-local-key,type=env,target=API_KEY
ReadOnly=true
DropCapability=all
NoNewPrivileges=true
Exec=--model /models/UD-IQ4_XS/… --draft /models/mtp-… --ctx 131072 --alias qwen3.8-flash-next --temp 1.0 --top-p 0.95 --top-k 20 -fa on -ctk q8_0 -ctv q8_0 --spec-type draft-mtp --spec-draft-n-max 4 --jinja
HealthCmd=/usr/local/bin/omarchy-health
HealthInterval=30s
HealthTimeout=5s
HealthRetries=3
HealthStartPeriod=10m
HealthOnFailure=kill
Notify=healthy

[Service]
TimeoutStartSec=12m
Restart=on-failure
RestartSec=10s
StartLimitBurst=3
StartLimitIntervalSec=10m
```

- No `[Install]` section: Quadlet applies `[Install]` at generation time and generated units can't be toggled with `systemctl enable`, so autostart is its own setting, `omarchy agent local autostart on|off`, which regenerates the file with or without `WantedBy=graphical-session.target`.
- `PartOf=graphical-session.target`: the model stops at logout and frees its memory, matching the repo's other session services.
- Readiness and health are both carried by the unit: `Notify=healthy` holds activation until the model is loaded; afterwards `HealthOnFailure=kill` turns a hung server into a failed unit that restarts, and three failures in ten minutes leave it failed rather than flapping. `TimeoutStartSec` sits above `HealthStartPeriod` so a slow first load fails as unhealthy, not as a timeout, with the reason in the journal.
- The health check is a periodic probe inside the container. It's a deliberate exception to the no-polling rule: the server has no change signal for "hung", and the probe runs in the container, not in the shell.
- Logs are `journalctl --user -u omarchy-agent-local`.

### Endpoint security

The endpoint receives source code and its output drives agents launched with permissive flags, so it's treated as sensitive:

- A per-user random key lives in `~/.config/omarchy/agent-local/key` (mode 0600) and in a Podman secret; the server rejects requests without it. This covers other local users and browser pages, which can reach loopback but not read the key.
- The backend's CORS is off and the server binds only the published loopback port; no admin or web UI routes are exposed.
- Podman refuses to start if `11435` is taken. After start, `use` verifies the endpoint by requesting `/v1/models` with the key and checking that the advertised model id matches the recipe, so a squatting process can't impersonate the server.

### Commands

All `omarchy-agent-local-*`, routed as `omarchy agent local …`:

- `use <recipe> [--ctx <variant>]` — validate the recipe, check compatibility and headroom, preflight the GPU, pull and verify the image, download and verify the model, generate the unit, switch, verify the endpoint.
- `list` — recipes, marking which are qualified for this machine and which is active.
- `status` — active recipe, unit state, endpoint, last failure reason.
- `stop` — stop the unit; keeps weights and image.
- `autostart on|off` — regenerate the unit with or without starting at login.
- `remove <recipe>` (phase 2) — delete weights no other installed recipe references, and the image if unused.

Mutations are serialized with a lock in `~/.local/state/omarchy/agent-local/`. Switching is transactional:

- Downloads go to a staging directory, are checked against the revision's published hashes, then renamed into place. A disk-space check runs before the download starts; interrupted downloads resume from staging.
- The current unit file is kept until the new recipe passes health and endpoint verification; on failure `use` restores and restarts the previous recipe and reports why.
- Switching interrupts in-flight requests; `use` says so before stopping a running model.

### Memory checks

Two separate questions, never conflated:

- **Compatibility** (static, cheap, cached): a `[[hardware]]` entry matches this machine, and the variant's measured peak fits the machine's GPU-addressable memory (on AMD, `mem_info_gtt_total` in sysfs, not a quoted default) and total RAM minus a desktop reserve. Used by `list` and menu guards.
- **Headroom** (at start time): after stopping the previous managed model, current `MemAvailable` and free GTT (`mem_info_gtt_total` − `mem_info_gtt_used`) must cover the variant's measured peaks plus the reserve. Ollama, LM Studio or anything else already holding memory counts against it; `use` names what's using it rather than starting a model that would OOM the desktop.

Estimates are reported as estimates. Automatic context sizing and changing kernel parameters (GTT limits) are out of scope; a recipe that needs a bigger GTT limit says so and links the manual page.

### Launching agents against it

- Registering the endpoint, selecting the model and choosing the default agent are separate steps. `use` only changes which recipe is active.
- Local mode is chosen per launch: `omarchy agent --local` (and a panel action) launches the default agent pointed at the active local model. Without it, agents launch exactly as today.
- Integration is a launch-time overlay Omarchy owns, never an edit to the client's files. For OpenCode, `omarchy-agent` sets `OPENCODE_CONFIG` to a generated `~/.config/omarchy/agent-local/opencode.json` declaring provider `llamacpp` (`@ai-sdk/openai-compatible`, base URL, `"apiKey": "{file:~/.config/omarchy/agent-local/key}"` so the key is never copied into the overlay) and passes `--model llamacpp/<recipe-id>`. OpenCode merges `OPENCODE_CONFIG` over the global config and under project config, so the user's own files are untouched; a `llamacpp` provider in their global config is overridden for local launches only.
- The model id is the recipe id, so usage history stays per model and resumed sessions name the model they actually used. The overlay is regenerated on each local launch, so it always matches the active recipe.
- Phase 1 supports OpenCode only, chosen because it has a supported config overlay. Pi, Codex and others are added one at a time, each only once it has an overlay or launch flag; Codex in particular needs to respect the per-account `CODEX_HOME` that `omarchy-agent` selects.
- `llamacpp` is already in the `local` usage collector's `KNOWN_LOCAL_PROVIDERS` (`bin/omarchy-agent-usage-local`), so OpenCode turns against it are counted with no collector change.

### Agent panel

Server lifecycle and usage history are different data with different owners and stay separate, even when shown in one card:

- Usage remains the `local` collector's job and stays read-only and history-based; its `ready` keeps meaning "has usage", and it gains no server fields.
- Server state comes straight from systemd: the panel subscribes to `omarchy-agent-local.service` on the user bus (`ActiveState`, `SubState`, `Result`), reads the active recipe from the state file `use` writes, and resubscribes when the bus reconnects. External changes (`systemctl --user stop`, a crash, logout) show up the same way.
- The Local card shows recipe, state (stopped, loading, ready, failed with reason) and start/stop/switch actions, and appears even before any usage exists. That means a separate visibility path in `Main.qml`: today providers are filtered before card filtering, display objects are built field by field, and cards need limits, accounts or a balance.
- Live memory and tokens per second are deferred. They change without any systemd signal, and backend metrics have no normalized names; when added they get a defined schema and one shared sampler that runs only while the panel is visible.

### Menu

Static entries in `default/omarchy/omarchy-menu.jsonc` for shipped recipes (`install.ai.local-model.<recipe>`), next to Ollama and LM Studio. Guards read the cached compatibility result `list` writes rather than probing hardware on every menu open, keeping within the menu guard budgets in `docs/menu.md`. Recipes not qualified for this machine are shown disabled with the reason, not hidden.

## First recipes

Survey for a 128GB Strix Halo, November 2026. Every number here is a community report and becomes a recipe only after our own measurement record reproduces it:

- **Qwen3.8 Flash Next, UD-IQ4_XS** — 125B MoE, ~6B active. Reported ~70 GiB GTT at 128K context and 17–28 tok/s sustained decode with MTP drafting ([gist](https://gist.github.com/chm123/b0b3eec2b7f68e09e5855e23fef44dba), [Unsloth discussion](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF/discussions/45)). Leaves ~35GB for the desktop. The phase 1 recipe.
- **GLM-5.3-Flash, AJ-IQ2_XXS** — 320B / 18B active, 87GB; long context is cheap (131K adds ~1.5GB). Stronger model, heavy compression (1.88× perplexity vs BF16); needs llama.cpp from unmerged PR #27752 ([model card](https://huggingface.co/aj9o9/GLM-5.3-Flash-GGUF)). A good second recipe: proves an image pinned to an unmerged branch.
- **DeepSeek V4.1 Flash** — only fits as a pruned 1–2 bit community build on a fork, untested on Strix Halo ([model card](https://huggingface.co/Harsha001/DeepSeek-V4.1-Flash-1017-StrixHalo-GGUF)). Not shipped.

Mia's recipes ([mia-ai.net/models](https://mia-ai.net/models)) are EXL3 + TensorFold/vLLM on 1–4 DGX Sparks or RTX PRO 6000s; they land with the CUDA images and GB10 qualification.

## Rollout

- **Phase 1** — one Strix Halo recipe end to end:
  - podman and crun in base, plus the install migration
  - the container contract and one signed, digest-pinned llama.cpp-Vulkan image, with the CI and signing pipeline behind it
  - a measurement record for Qwen3.8 Flash Next, made first on a native build with the recipe's exact flags, then reproduced through the image
  - rootless preflight and GPU self-test
  - Quadlet generation with explicit autostart, health and restart behavior
  - per-user key and endpoint verification
  - staged, verified downloads and transactional switching
  - `use`, `stop`, `status`, `list`, `autostart`
  - OpenCode local launch through `OPENCODE_CONFIG`
- **Phase 2** — the panel's Local card with lifecycle state and actions, menu entries, `remove`, GLM-5.3-Flash as the second recipe.
- **Phase 3** — ROCm and CUDA images, the privileged GPU setup command, GB10 recipes adapted from Mia's, a halogen image, more clients as overlays allow, live metrics.
- **Docs** — a manual page for running local models; `docs/` reference for the recipe format, the measurement record and the container contract.
- **Tests** — extending existing area tests where they exist, covering real logic only:
  - recipe parsing and id validation
  - argument escaping into Quadlet with hostile values
  - compatibility and headroom decisions against fixture sysfs and meminfo
  - rollback when the new recipe fails health
  - OpenCode overlay generation
  - CLI metadata via `omarchy commands --check`
  - no migration test
  - a disposable-VM lifecycle check for `use`/`stop`/`autostart` with a CPU-only test image; GPU paths need real hardware and are verified by hand per the visual-verification skill for the panel

## Open questions

1. Which repo owns the image Containerfiles and CI, and which signing scheme Podman verifies (sigstore signatures vs GPG).
2. Is one managed active model the right limit long term? A small fast model next to a big one (completion vs agent) is plausible on 128GB once headroom checks exist.
3. Should the model store share Hugging Face's cache (`~/.cache/huggingface`) so weights downloaded for other tools are reused, at the cost of Omarchy not owning deletion?
4. Should a recipe's `ctx` variants grow automatically as measurements come in for machines with less memory (64GB Strix Halo), or stay hand-curated?
