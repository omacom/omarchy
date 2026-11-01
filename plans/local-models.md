# Plan: Local models — `omarchy agent local use <recipe>`

Revision 1.

## Problem

A 128GB unified-memory machine (Strix Halo, DGX Spark/GB10) can now run open models that are genuinely useful as coding agents: Qwen3.8 Flash Next, GLM-5.3-Flash, DeepSeek V4.1 Flash in pruned form. Getting one running is still an afternoon of archaeology. You pick from a dozen community quants of the same model, find the one llama.cpp branch or fork that supports its architecture, install build dependencies by trial and error (cmake, vulkan-headers, then spirv-headers when configure fails), raise kernel GPU memory limits, copy a 15-flag command line out of a gist, and then wire the endpoint into every agent CLI's own provider config by hand. None of it is reproducible: the next machine, or the same machine after a rebuild, starts from zero.

The work that makes these models fast already exists as recipes: curated quant + runtime + flag combinations published by people like Mia (mia-ai.net/models) and 0xSero, plus community builds tuned for a specific chip. What's missing is a way to run a recipe as one command, get the same result every time, and have every Omarchy agent and the agent panel see it.

## Shape

- `omarchy agent local use <recipe>` checks the machine can hold the model, pulls a pinned backend container image, downloads pinned model weights, and starts the model as a rootless Podman container under a systemd user unit.
- Every backend (llama.cpp Vulkan/ROCm/CUDA, halogen, vLLM, SGLang, …) is a container image with the same shape, so the framework only ever starts and stops containers. Swapping backend is one line in a recipe.
- The active model is always served at `127.0.0.1:11435` with an OpenAI-compatible API. Agent CLIs are configured once against that address; switching recipes never touches their config again.
- The agent panel shows the local server — recipe, loading/ready, memory, tokens per second — and can switch or stop it.

## Rejected approaches

- **Native builds per machine**: what validating this plan took by hand (clone, cmake, three rounds of missing headers, a fork for unmerged architecture support). Every recipe that needs a different fork or branch multiplies it. Containers move the build to CI, once.
- **Distro packages per backend** (`llama.cpp-vulkan` in the Omarchy repo): solves llama.cpp only. Halogen, EngramHalo.cpp, ROCm forks and unmerged PR branches are exactly what the best recipes depend on, and they will never all be packaged. A package also pins one version system-wide, while recipes need different runtime revisions side by side.
- **Docker**: in base already, but needs a root daemon and the docker group or sudo for a per-user model server. Podman runs rootless and Quadlet turns a container into an ordinary systemd user unit, which gives readiness, logs and event-driven status for free.
- **Ollama / LM Studio as the runtime**: both are already installable from the menu and stay that way, but they lag on new architectures and don't expose the flags (speculative-decoding drafts, KV cache types, tensor placement) that recipes are made of.
- **A model zoo UI that browses Hugging Face**: thousands of quants, most broken or untested on a given chip. A recipe is a curated, tested claim — "this runs on this hardware at this speed" — which is the actual value.

## Design

### Recipes

A recipe is data, one TOML file per model setup: shipped recipes in `default/omarchy/agent-local/`, user recipes in `~/.config/omarchy/agent-local/` (same name overrides).

```toml
name = "Qwen3.8 Flash Next"
summary = "125B MoE, 6B active. ~20–40 tok/s on Strix Halo."
platforms = ["x86", "aarch64-gb10"]
gpu_memory_gib = 72

[runtime]
image = "ghcr.io/omarchy/llama.cpp-vulkan@sha256:…"
gpu = "vulkan"                       # vulkan | rocm | cuda

[model]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "<commit sha>"
include = ["UD-IQ4_XS/*"]
main = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf"
draft = "mtp-Qwen3.8-Flash-Next-Q8_0.gguf"

[server]
ctx = 131072
args = ["-fa", "on", "-ctk", "q8_0", "-ctv", "q8_0", "--spec-type", "draft-mtp", "--spec-draft-n-max", "4", "--jinja"]

[sampling]
temperature = 1.0
top_p = 0.95
top_k = 20
```

Reproducibility comes from three pins: image digest, model revision, flags. Two machines running the same recipe file run the same bytes with the same arguments. `platforms` uses the names from `omarchy-hw-platform`; `gpu_memory_gib` is what the model needs resident at the recipe's context.

### The backend container contract

Every backend image provides:

| | Contract |
|---|---|
| API | OpenAI-compatible on `:8080`: `/v1/chat/completions`, `/v1/models`, and `/health` returning 200 only once the model is loaded |
| Models | Read-only mount at `/models`; weights are never baked into images, so backends share one download |
| Entrypoint | Accepts `--model`, `--draft`, `--ctx`, `--alias`, then passes remaining recipe args through; a thin adapter in each image maps these onto the backend's own CLI |
| GPU | Declared by the recipe's `gpu`; Omarchy maps it to devices: `vulkan` → `/dev/dri`, `rocm` → `/dev/dri` + `/dev/kfd`, `cuda` → CDI `nvidia.com/gpu=all` |
| Metrics | Optional Prometheus `/metrics` for the panel's tokens per second and memory |

Images are built in CI from pinned upstream commits, one per backend × GPU flavor, published to `ghcr.io/omarchy/…` and referenced by digest. Vulkan and ROCm images carry their userspace driver (Mesa RADV, ROCm) and only the kernel driver comes from the host, so images are rebuilt on Mesa releases as well as backend releases — Strix Halo performance still moves with Mesa.

### Running it: Podman Quadlet

`use` generates one Quadlet file and restarts one unit:

```ini
# ~/.config/containers/systemd/omarchy-agent-local.container
[Unit]
Description=Omarchy local model: Qwen3.8 Flash Next

[Container]
Image=ghcr.io/omarchy/llama.cpp-vulkan@sha256:…
Label=org.omarchy.agent-local.recipe=qwen3.8-flash-next
AddDevice=/dev/dri
Volume=%h/.local/share/omarchy/models:/models:ro
PublishPort=127.0.0.1:11435:8080
Exec=--model /models/… --draft /models/… --ctx 131072 --alias qwen3.8-flash-next -fa on -ctk q8_0 -ctv q8_0 --spec-type draft-mtp --jinja
HealthCmd=curl -fs http://localhost:8080/health
HealthStartPeriod=5m
Notify=healthy

[Service]
TimeoutStartSec=15m

[Install]
WantedBy=default.target
```

- One fixed unit, `omarchy-agent-local.service`: only one model runs at a time, which is what fits in memory anyway. Switching recipe rewrites the file, `daemon-reload`, `restart`.
- `Notify=healthy` makes the unit go active only when the model has loaded, so systemd state *is* model readiness.
- Logs are `journalctl --user -u omarchy-agent-local`.
- Start-at-login is enabling the unit, left as the user's choice; by default a model starts when asked for.
- Podman (with `crun`) joins `omarchy-base.packages`, with a migration that installs it on existing machines, so `use` can treat it as a runtime invariant. It costs about 107 MiB installed: podman 83 MiB, netavark and aardvark-dns 13 MiB, crun and its checkpoint/restore dependencies 9 MiB, the rest under 2 MiB; everything else in its tree is already on the base system. On this Strix Halo the render node and `/dev/kfd` are 0666 and the user has subuid/subgid ranges, so rootless GPU passthrough needs no group changes. GB10 ships `nvidia-container-toolkit`; CUDA recipes run `nvidia-ctk cdi generate` once.

### Commands

All `omarchy-agent-local-*`, routed as `omarchy agent local …`:

- `use <recipe>` — validate platform and memory fit, pull image, download model (resumable, verified against the pinned revision), write the Quadlet, restart, wait for health, register agent providers.
- `list` — recipes, marking which fit this machine and which is active.
- `status` — active recipe, unit state, endpoint, memory in use.
- `stop` — stop the unit; keeps weights and image.
- `remove <recipe>` — delete its weights, and the image if no other recipe uses it.

The memory check compares `gpu_memory_gib` against what the GPU can address (GTT on unified-memory AMD, which defaults to roughly 100 GiB on a 128GB machine) and against total RAM minus a reserve for the desktop. A recipe that would need the GTT limit raised says so and points at the kernel parameter rather than silently failing to load.

### Wiring agents to it

- `use` registers the fixed endpoint as provider id `llamacpp` in the agent CLIs' own configs: opencode's `provider` block (`@ai-sdk/openai-compatible`), pi's `models.json`, Codex's `model_providers`. Each write merges a namespaced block; never rewrite another tool's file. This is the first place Omarchy writes provider config, so the merge helper gets real tests.
- `llamacpp` is already in the `local` usage collector's `KNOWN_LOCAL_PROVIDERS`, so token and prompt counting in the panel works with no collector changes.
- The model alias is the recipe name, so switching recipes changes the model id the agents see, not the endpoint.
- `omarchy-agent` launches agents exactly as today.

### Agent panel

- The `local` collector's record gains a `server` block: recipe, unit state (inactive, loading, ready, failed), endpoint, memory, tokens per second from `/metrics`.
- Today a provider card only appears when a record has limits, accounts or a balance; the Local card also appears when `server` is present.
- The card has a recipe picker and start/stop, calling `omarchy-agent-local-use` and `-stop`.
- Status is event-driven: the panel follows `omarchy-agent-local.service` state over systemd's user D-Bus, not a timer, per the shell's no-polling rule.

### Menu

`install.ai.local-model.<recipe>` entries generated from shipped recipes, guarded on platform and memory fit, next to the existing Ollama and LM Studio entries.

## First recipes

From the November 2026 survey for a 128GB Strix Halo (100 GiB GTT by default):

- **Qwen3.8 Flash Next, UD-IQ4_XS** — 125B MoE / ~6B active, ~70 GiB resident at 128K context, community reports 17–28 tok/s sustained and ~40 on code with MTP drafting. Leaves ~35GB for the desktop. The first recipe and the reference run for the llama.cpp-Vulkan image.
- **GLM-5.3-Flash, AJ-IQ2_XXS** — 320B / 18B active, 87GB, cheap long context (131K adds ~1.5GB). Stronger model, heavier compression (1.88× perplexity vs BF16); needs llama.cpp from unmerged PR #27752, which the image pins.
- **DeepSeek V4.1 Flash** — only fits as a pruned 1–2 bit community build on a fork, untested on Strix Halo. Not shipped; a good test of whether the contract handles a fork image.

Mia's recipes (EXL3 + TensorFold/vLLM) target 1–4 DGX Sparks or RTX PRO 6000s; the CUDA image flavor and the GB10 platform are where those land.

## Rollout

- Phase 1: podman and crun in `omarchy-base.packages` plus the install migration, the contract and one image (llama.cpp-Vulkan), Quadlet generation, `use`/`stop`/`status`/`list`, the Qwen3.8 Flash Next recipe, opencode provider registration. Validated on Strix Halo by hand first: native build with the recipe's exact flags, then the same flags inside the image through the generated unit.
- Phase 2: panel card and controls, pi and Codex provider registration, menu entries, `remove`.
- Phase 3: ROCm and CUDA images, a halogen image, GB10 recipes adapted from Mia's.
- Docs: a manual page for running local models; `docs/` reference for the recipe format and the container contract, so recipe and image authors have one spec.
- Tests: recipe parsing, platform and memory-fit guards, Quadlet generation from a recipe, provider-config merging (idempotent, never clobbers user entries). CLI metadata via `omarchy commands --check`. Panel card verified visually per the visual-verification skill.

## Open questions

1. Where images are built and who owns them: a `basecamp/omarchy-agent-local-images` repo with CI, or images built from recipes on the user's machine (reproducible from a Containerfile, but slow and back to needing a toolchain).
2. Should recipes accept a `Containerfile` instead of an image digest, so community recipes can bring a fork without Omarchy publishing an image for it?
3. Raising the GTT limit: leave it to the user with a clear message, or offer an `omarchy-setup-gpu-memory` that writes the `ttm.pages_limit` / `amdgpu.gttsize` kernel parameters?
4. Context length per machine: recipes pick one `ctx`, but the same model on a 64GB machine might fit only at shorter context. Should `ctx` be derived from free memory?
5. Is one active model the right limit forever? A small fast model next to a big one (completion vs agent) is plausible on 128GB.
6. Should the model store be shared with Hugging Face's cache (`~/.cache/huggingface`) so weights already downloaded for other tools are reused?
