# Plan: Local models — `omarchy agent local use <recipe>`

Revision 4.

- Revision 2 tightened lifecycle, endpoint security, client selection, memory checks, supply chain and config ownership after a review pass.
- Revision 3 generalized the container contract after running halogen, a closed-source third-party engine, through it: backends are described by runtime definitions that map the standard inputs onto each image's own interface, declare allowlisted run options and their health probe, and carry a trust tier.
- Revision 4 adds `use best`, a curated per-machine-class recommendation; moves recipes, runtimes and the recommendation into a separately updated, signed catalog repo, `basecamp/omarchy-local-ai`; keeps weights on Hugging Face rather than hosting them; records the hand-measured llama.cpp vs halogen comparison; and moves phase 1 onto the halogen runtime.

## Problem

A 128GB unified-memory machine (Strix Halo, DGX Spark/GB10) can now run open models that are genuinely useful as coding agents: Qwen3.8 Flash Next, GLM-5.3-Flash, DeepSeek V4.1 Flash in pruned form. Getting one running is still an afternoon of archaeology. You pick from a dozen community quants of the same model, find the one llama.cpp branch or fork that supports its architecture, install build dependencies by trial and error (cmake, vulkan-headers, then spirv-headers when configure fails), raise kernel GPU memory limits, copy a 15-flag command line out of a gist, and then wire the endpoint into every agent CLI's own provider config by hand. None of it is reproducible: the next machine, or the same machine after a rebuild, starts from zero.

The work that makes these models fast already exists as recipes: curated quant + runtime + flag combinations published by people like Mia (mia-ai.net/models) and 0xSero, plus community builds tuned for a specific chip. What's missing is a way to run a recipe as one command, get the same result every time, and have Omarchy's agents and agent panel see it.

## Shape

- `omarchy agent local use best` picks the recipe Omarchy recommends for this exact machine — GPU family, memory, platform — and runs it. `use <recipe>` runs a specific one.
- `omarchy agent local use <recipe>` checks the machine can hold the model right now, pulls the runtime's container image pinned by digest, downloads pinned and verified model weights from Hugging Face, and starts the model as a rootless Podman container under a systemd user unit.
- Every backend (llama.cpp Vulkan/ROCm/CUDA, halogen, vLLM, SGLang, …) is a container image with the same shape, so the framework only ever starts and stops containers. Swapping backend is one line in a recipe.
- The active model is served at `127.0.0.1:11435` with an OpenAI-compatible API behind a per-user key.
- Launching an agent in local mode points it at that endpoint and the active recipe's model, through launch-time config Omarchy owns, never by rewriting the agent's own config files. OpenCode first; other clients once each has a supported overlay.
- The agent panel shows whether a local model is running and can switch or stop it.

## Rejected approaches

- **Native builds per machine**: what validating this plan took by hand (clone, cmake, three rounds of missing headers, a fork for unmerged architecture support). Every recipe that needs a different fork or branch multiplies it. Containers move the build to CI, once.
- **Distro packages per backend** (`llama.cpp-vulkan` in the Omarchy repo): solves llama.cpp only. Halogen, EngramHalo.cpp, ROCm forks and unmerged PR branches are exactly what the best recipes depend on, and they will never all be packaged. A package also pins one version system-wide, while recipes need different runtime revisions side by side.
- **Docker**: in base already, but needs a root daemon and the docker group or sudo for a per-user model server. Podman runs rootless and Quadlet turns a container into an ordinary systemd user unit.
- **Ollama / LM Studio as the runtime**: both stay installable from the menu, but they lag on new architectures and don't expose the flags (speculative-decoding drafts, KV cache types, tensor placement) that recipes are made of.
- **Hosting weights ourselves as OCI artifacts**: Podman 6 can pull and mount model artifacts natively through Quadlet `.artifact` units, which would make a recipe a single registry reference. Not worth it: Hugging Face at a pinned revision with hash verification is already repeatable, while hosting means ~95GB per model variant, re-splitting 50GB shards to suit registry blob limits, and a redistribution review for every model's weights. Recipes reference Hugging Face; only runtime images come from a container registry.
- **Recipes shipped inside the Omarchy repo**: the best recipe for a machine changes weekly; tying it to Omarchy releases would leave every user on a stale recommendation. The catalog is a separate, signed, frequently updated repo; Omarchy keeps the mechanism and the security boundary.
- **Computing "best" from a score**: which model is best on a machine is a judgment about quality and speed tradeoffs (a C-tier model at 2 bits vs a D-tier model at 4 bits), not something derivable from parameter counts. `best` resolves through a curated, ordered list.
- **A model zoo UI that browses Hugging Face**: thousands of quants, most broken or untested on a given chip. A recipe is a curated, measured claim — "this runs on this hardware at this speed" — which is the actual value.
- **Merging provider blocks into agents' config files**: even a "merge" rewrites the file, loses JSONC comments and TOML formatting, races the client's own writes, collides with user-owned `llamacpp` entries, and misses Codex's per-account homes (`bin/omarchy-agent` sets `CODEX_HOME` per account). Launch-time overlays avoid all of it.

## Design

### Recipes

A recipe is data, one TOML file per model setup: recipes come from the catalog (see Recipe catalog), user recipes from `~/.config/omarchy/agent-local/recipes/` (same id overrides). Recipe ids match `^[a-z0-9][a-z0-9.-]*$`; anything else is rejected before it reaches a path, a unit name or a Quadlet specifier.

```toml
name = "Qwen3.8 Flash Next"
summary = "125B MoE, ~6B active, 4-bit, MTP drafting."

runtime = "halogen"                   # a runtime definition, see below

[[hardware]]                          # tested qualifications, not guesses
platform = "x86"
gpu = "amd-strix-halo"
memory_gib = 128                      # the machine class it was measured on
measured = "measurements/qwen3.8-flash-next-halogen-strix-halo-128.toml"

[model]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "<commit sha>"
include = ["UD-IQ4_XS/*"]
main = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf"

[[model.extra]]                       # artifacts the runtime needs beside the weights
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "<commit sha>"
include = ["qwen38-flash-next-mtp.hgn", "tokenizer/*"]
draft = "qwen38-flash-next-mtp.hgn"

[[variant]]                           # validated context sizes with measured peak memory
ctx = 131072
peak_gpu_gib = 72                     # locked: halogen pins its weights
peak_host_gib = 13

[sampling]                            # server-side defaults; a client's explicit values win
temperature = 1.0
top_p = 0.95
top_k = 20
```

- Reproducibility comes from three pins: image digest, model revision, flags. Two qualified machines running the same recipe run the same bytes with the same arguments.
- `hardware` replaces a bare platform list: `x86` alone admits machines with no usable GPU. Each entry names the platform (`omarchy-hw-platform` names), the GPU family, the memory class it was measured on, and a measurement record. A recipe only claims hardware someone measured. The same runtime image runs on every machine of a GPU family; whether a recipe fits is a question of memory, so the same model on a 64GB machine of the same family is a different qualification (and usually a different recipe).
- A measurement record captures exact artifacts, peak GPU and host memory, prefill and decode speed at stated context depths, and the llama-bench or equivalent command that produced them. Performance numbers in recipes, menus and docs come from these records, not from gists.
- `sampling` is passed to the server as its defaults through the runtime's input mapping (`--temp`, `--top-p`, `--top-k` for llama.cpp), so every client gets sane values without client config. A runtime without a mapping for sampling defaults leaves them to the client.
- `[server] args` are runtime-specific extras appended after the mapped inputs; a recipe for a runtime that takes no arguments has none.
- Generated server arguments are built as an argument array and escaped for Quadlet; a test feeds hostile values (spaces, `%`, quotes) through the generator.

### Recipe catalog: `basecamp/omarchy-local-ai`

The recommendation for a machine changes far faster than Omarchy releases: a new quant lands, a runtime gets 30% faster, a new model beats the old best. So recipes, runtime definitions, `best.toml` and measurement records live in their own repo, `basecamp/omarchy-local-ai`, and Omarchy fetches it.

The split keeps trust where it is today:

- **Omarchy owns the mechanism**: the commands, the machine profile, Quadlet generation, the run-option allowlist, the security defaults every container gets (read-only root, dropped capabilities, loopback-only port, key as a secret), and the catalog schema it understands. A catalog entry can never get more than this allows: a runtime definition asking for an option outside the allowlist is refused by Omarchy, whatever the catalog says.
- **The catalog owns data and evidence**: `recipes/`, `runtimes/`, `best.toml`, `measurements/`, plus the Containerfiles and CI for `omarchy`-tier images.

```
omarchy-local-ai/
  catalog.toml          # schema version
  best.toml
  recipes/qwen3.8-flash-next-halogen.toml
  runtimes/halogen.toml
  runtimes/llama.cpp-vulkan.toml
  measurements/qwen3.8-flash-next-halogen-strix-halo-128.toml
  images/llama.cpp-vulkan/Containerfile
```

**Fetching.**

- `use`, `list` and `status` refresh the catalog when the cached copy is older than a few hours, and `omarchy-update` refreshes it too. There is no timer of its own. Offline, the cached catalog is used and the command says how old it is.
- The fetch is a shallow git fetch of the branch for the schema this Omarchy understands (`schema-1`, …), into `~/.local/state/omarchy/agent-local/catalog/<commit>/`, with a `current` pointer switched only after verification. A schema change gets a new branch, so older Omarchy installs keep receiving updates in the schema they can read.
- The fetched commit must be signed by a key in an allowed-signers file shipped with Omarchy (`git verify-commit` with SSH signatures). An unsigned commit or unknown signer is refused and the previous catalog stays current. Merging to the catalog is therefore a release, and the catalog cannot be changed by anyone who can only push to GitHub.

**Repeatability.**

- Everything a recipe runs is pinned (image digest, Hugging Face revision, flags), and the catalog itself is pinned by commit. `use` records both the concrete recipe id and the catalog commit it came from. `status` shows them, and `use <recipe> --catalog <commit>` reproduces any earlier run exactly, on any machine of that class.
- `use best` on the same machine against the same catalog commit always resolves the same way. A newer catalog may resolve differently; that change is visible, never automatic (see below).
- A user can point at a fork or a pinned commit in `~/.config/omarchy/agent-local/catalog.toml` (`url`, `ref`). A non-default source skips signature verification, says so on every `use`, and is the way to test a catalog change before proposing it.

**Contributing.** A recipe or a new hardware class comes in as a pull request with its measurement record. `omarchy agent local bench` produces one: it runs a fixed prompt set (a short prompt and a ~32K-token prompt of real code, greedy, thinking off) against the running model and records artifacts, digests, catalog commit, machine profile, peak memory, time to first token, prefill and decode. Catalog CI checks every change:

- schema validity, and runtime definitions using only allowlisted run options
- that every image digest, Hugging Face revision and file exists
- that every recipe named in `best.toml` for a class has a measurement record from that class
- that third-party runtimes carry a license review

### Choosing for the machine: `best`

`omarchy agent local use best` resolves to one concrete recipe for this machine.

The machine profile comes from `omarchy-agent-local-profile`, built on the existing helpers:

- platform from `omarchy-hw-platform`
- GPU family from the GPU itself (gfx target for AMD, e.g. `gfx1151` → `amd-strix-halo`; GB10 from its platform)
- GPU-addressable memory (on AMD, `mem_info_gtt_total`) and total RAM, rounded to a memory class (64, 96, 128, …)

The recommendation is a curated, ordered list in the catalog's `best.toml`, one entry per hardware class:

```toml
[[class]]
gpu = "amd-strix-halo"
memory_gib = 128
recipes = ["qwen3.8-flash-next-halogen", "qwen3.8-flash-next-llama.cpp"]

[[class]]
gpu = "amd-strix-halo"
memory_gib = 64
recipes = ["qwen3.8-27b-halogen", "qwen3.6-35b-a3b-llama.cpp"]

[[class]]
platform = "aarch64-gb10"
memory_gib = 128
recipes = ["…"]
```

- Resolution takes the most specific class matching the profile, then the first recipe in its list that is compatible with this machine (qualified hardware, measured peaks within the GPU-addressable memory). Later entries are fallbacks for a reason that's static: a runtime that can't run on this GPU, a GTT limit set lower than the default.
- Headroom is not a reason to fall back. If the best recipe is compatible but memory is busy right now, `use best` says what's holding memory instead of quietly starting a worse model.
- `use best` prints what it resolved to and why, and records the concrete recipe id as active, never `best`. Repeatability follows: the same machine against the same catalog commit resolves to the same recipe, which pins the same image digest, Hugging Face revision and flags.
- A newer catalog may change the recommendation. `status` shows when the active recipe is no longer the current `best`, and running `use best` again moves to it; nothing switches models on its own.
- No class or no compatible recipe: `use best` names the machine profile it saw and lists the recipes that come closest, so a missing class is visible and easy to report.
- Adding a class is curation work backed by measurement records. The list only names recipes measured on that class.

### The backend container contract

The contract is the container's outside shape, not its insides. Omarchy must not need to rebuild a third-party image to wrap it, so everything an image does differently is described by its runtime definition instead of required of the image. Every backend image provides:

| | Contract |
|---|---|
| API | OpenAI-compatible on one container port: `/v1/models`, `/v1/chat/completions` with streaming and tool calls through the model's chat template. Admin and web UI routes are disabled or unpublished |
| Auth | Requires a bearer key that it can read from an environment variable or a file; unauthenticated requests are rejected |
| Health | An HTTP endpoint that returns 200 only once the model is loaded; it may stay open without the key |
| Models | Works from a read-only mount of only the selected recipe's model directory; nothing is written into it |
| Inputs | Takes the model path, draft path, context size, served model id and key in some form, CLI arguments or environment variables |

"OpenAI-compatible" is defined by an acceptance check rather than assumed: a streamed completion, a tool call round trip, and a chat-template sanity check run against every runtime and recipe before either is published.

### Runtime definitions

A runtime definition describes one backend image and how to drive it, so many recipes share it. Runtimes come from the catalog's `runtimes/`, user runtimes from `~/.config/omarchy/agent-local/runtimes/`. Omarchy generates the Quadlet unit from recipe plus runtime.

```toml
# runtimes/llama.cpp-vulkan.toml — built by Omarchy
image = "ghcr.io/omarchy/llama.cpp-vulkan@sha256:…"   # per-arch digest, never an index
tier = "omarchy"
port = 8080
health = { path = "/health", probe = ["/usr/local/bin/omarchy-health"] }
run = { devices = ["render"] }

[inputs]                              # standard input → how this image takes it
model = { arg = "--model" }
draft = { arg = "--model-draft" }
ctx = { arg = "--ctx-size" }
alias = { arg = "--alias" }
key = { env = "LLAMA_API_KEY" }
temperature = { arg = "--temp" }
top_p = { arg = "--top-p" }
top_k = { arg = "--top-k" }
```

```toml
# runtimes/halogen.toml — third-party, closed source
image = "ghcr.io/peonist-ai/halogen-flash-server@sha256:273714cc…"
tier = "third-party"
publisher = "Peonist, LLC"
license = "https://github.com/peonist-ai/halogen-flash-server/blob/main/LICENSE.md"
license_reviewed = "2026-11-01: free for any use, no telemetry, no network calls unless HALOGEN_DOWNLOAD is set, benchmarking permitted"
port = 8731
health = { path = "/health", probe = ["/usr/local/bin/python3", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8731/health', timeout=4)"] }
run = { devices = ["render", "kfd"], group_add = "keep-groups", ipc = "host", memlock = "unlimited" }

[inputs]
model = { env = "HALOGEN_CHECKPOINT" }
draft = { env = "HALOGEN_MTP_HEAD" }
ctx = { env = "HALOGEN_CTX" }
alias = { env = "HALOGEN_MODEL_ID" }
key = { env = "HALOGEN_API_KEY" }
```

- **Inputs** map each standard input to a CLI argument or an environment variable. Paths are rewritten to their location under `/models`. The key is always delivered from the Podman secret, as an environment variable or a mounted file, never on the command line where `ps` would show it. A standard input the runtime has no mapping for is an error if the recipe sets it.
- **Health** names the endpoint the contract requires and the probe command that runs inside the container, since images don't ship the same tools: halogen has no `curl`, only `python3`. The probe is what `HealthCmd` runs; `Notify=healthy` and `HealthOnFailure=kill` work the same for every runtime.
- **Run options** come from a fixed allowlist, each mapped to one Quadlet key, so a runtime file can't smuggle in arbitrary `podman run` flags:

| Option | Values | Quadlet |
|---|---|---|
| `devices` | `render` (the GPU's own render node), `kfd`, `cdi-nvidia` | `AddDevice=` |
| `group_add` | `keep-groups` | `GroupAdd=keep-groups` |
| `ipc` | `host` | `PodmanArgs=--ipc=host` |
| `memlock` | `unlimited` | `Ulimit=memlock=-1:-1` |
| `shm_size` | size | `ShmSize=` |

  `ipc = "host"` shares the host's IPC namespace with the container and weakens isolation; it's allowed because ROCm engines use it for large shared allocations, and the definition review notes why each runtime needs it. Read-only root, dropped capabilities, `no-new-privileges` and the loopback-only port aren't options; every runtime gets them. Anything not on the allowlist goes through review as an addition to the allowlist, not as a one-off in a runtime file.
- **Extra artifacts** a runtime needs beside the weights (halogen's own MTP head and tokenizer, 1.4 GiB, when serving a GGUF) are listed in the recipe's `[model]` include patterns and downloaded by `use` like any other weights, because the model mount is read-only and images must not fetch at startup. A runtime whose image downloads on first start has that switched off (`HALOGEN_DOWNLOAD` stays unset).

### Images and supply chain

Runtimes come in two trust tiers, recorded in the runtime definition and shown wherever a recipe is chosen.

**`omarchy` tier** — images Omarchy builds:

- Built in CI in a dedicated repo from Containerfiles that pin the base image by digest, the backend by upstream commit, and Mesa/ROCm/CUDA by version. One image per backend × GPU flavor × architecture.
- Signed with build provenance. A Podman `policy.json` scoped to `ghcr.io/omarchy` requires the signature, so a digest is both the exact bytes and proof of who built them.

**`third-party` tier** — vetted images published by someone else, like halogen. Some of the fastest engines are closed source or ship only as their author's container, and rebuilding them isn't possible or allowed:

- Pinned by digest exactly like Omarchy's own images, so the bytes never change under a recipe.
- Admitted by review, not by publishing: the definition records the publisher, the license URL, and a dated summary of what the review checked — permitted use, telemetry and network calls, redistribution. A license change seen at a digest bump is re-reviewed before the new digest ships.
- Signatures are verified when the publisher signs; otherwise the reviewed digest is the trust anchor, and the definition says so.
- Third-party runtimes get the same read-only root, dropped capabilities, loopback-only port and allowlisted run options as Omarchy's own; review is about who wrote the code inside, not a looser sandbox.
- `list` and the menu label third-party runtimes with their publisher, and the first `use` of one names the publisher and license before pulling it.

For both tiers:

- Recipes pin per-architecture digests, not a multi-arch index, so the digest names the same bytes on every machine that uses it.
- Security and Mesa updates produce new images; they reach users only when the runtime definition's digest is updated in the catalog and the user runs `use` again. Running models never float. Mesa updates matter: Vulkan and ROCm images carry their userspace driver and only the kernel driver comes from the host, and Strix Halo performance still moves with Mesa.
- Containers run with a read-only root, all capabilities dropped, `no-new-privileges`, and no outbound network beyond the published port where the network mode allows it.
- User-supplied Containerfiles are out of scope until this pipeline exists.

### Rootless GPU

- Podman and crun join `omarchy-base.packages`, with a migration (via the migration helper, using `omarchy-pkg-add`, idempotent, failing synchronously) that installs them on existing machines. Commands then treat Podman as a runtime invariant and never check for it. Cost is about 107 MiB installed: podman 83 MiB, netavark and aardvark-dns 13 MiB, crun and its checkpoint/restore dependencies 9 MiB, the rest under 2 MiB; everything else in its tree is already on the base system.
- Devices are minimal and come from the runtime's `devices` option: the GPU's own render node (not all of `/dev/dri`), plus `/dev/kfd` for ROCm engines, plus CDI `nvidia.com/gpu=all` for CUDA. Where a node is group-owned rather than world-accessible, the runtime needs `group_add = "keep-groups"`, which requires the user systemd manager to hold that group.
- `use` runs a preflight before downloading anything: subordinate ID ranges exist, every device the runtime asks for is accessible to the user manager, and a throwaway container from the runtime's image with the same devices and options can open them. Failures say what to fix. `use` never changes device permissions or groups itself.
- Privileged one-time setup lives in its own command, `omarchy-setup-agent-local-gpu`, run with sudo from a terminal: group membership where needed, and on CUDA platforms CDI spec generation into `/etc/cdi` plus a pacman hook that regenerates it when the NVIDIA driver changes.

### Running it: Podman Quadlet

`use` generates one Quadlet file from recipe plus runtime definition and restarts one unit. For the llama.cpp-Vulkan runtime it looks like this; the halogen runtime differs only in the image, the environment variables its inputs map to, its probe, and its allowlisted run options:

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

- `use best` — resolve the recommended recipe for this machine (see above), then `use` it.
- `use <recipe> [--ctx <variant>]` — validate the recipe, check compatibility and headroom, preflight the GPU, pull and verify the image, download and verify the model, generate the unit, switch, verify the endpoint.
- `list` — recipes, marking which are qualified for this machine, which is `best`, and which is active.
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

Pinned memory isn't reclaimable even when the kernel reports it as cache. halogen locks its weights (hence its `memlock = "unlimited"`) and warns that `free` and `MemAvailable` overstate what's left: about 72 GiB pinned, 23.7 GiB truly available, on the measured run. Headroom checks for the running model use the runtime's own reported figures or `Mlocked`/cgroup accounting for the unit, never `MemAvailable` alone; measurement records note whether a runtime pins its weights.

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

Recipes change with the catalog, so the menu doesn't list them statically. `default/omarchy/omarchy-menu.jsonc` gets two entries next to Ollama and LM Studio: "Local model (best for this machine)", running `omarchy-agent-local-use best`, and "Choose local model…", a picker fed by a menu provider that reads the cached catalog and compatibility result `list` writes. Neither probes hardware or the network on menu open, keeping within the menu guard budgets in `docs/menu.md`. In the picker, recipes not qualified for this machine are shown disabled with the reason, not hidden.

## First recipes

Survey for a 128GB Strix Halo, November 2026. Every number here is a community report and becomes a recipe only after our own measurement record reproduces it:

- **Qwen3.8 Flash Next, UD-IQ4_XS** — 125B MoE, ~6B active. The phase 1 recipe and the 128GB Strix Halo `best`. Measured by hand on a Ryzen AI Max+ 395 / 128GB on 2026-11-01 with the same GGUF and the same prompts (greedy, thinking off; a 41-token prompt and a 31,705-token prompt of shell scripts, 512 tokens out):

  | 31,705-token prompt | llama.cpp Vulkan (`-lm mmap`, MTP draft) | halogen 0.18.22 (GGUF + its MTP head) |
  |---|---|---|
  | Time to first token | 131.5 s | 26.6 s |
  | Prefill | 241 tok/s | 1,194 tok/s |
  | Decode | 19.9 tok/s | 36.5 tok/s |
  | Whole turn | 157 s | 40.5 s |
  | Load | 32 s | 12 s |
  | Memory | 67 GiB GTT; ~48 GB left available, Engram table as reclaimable cache | ~72 GiB locked; ~24 GiB truly available |

  Short-prompt decode was close (40.4 vs 44.7 tok/s). halogen is the recipe's runtime; llama.cpp is its fallback for machines where halogen can't run. These become the measurement record once repeated through the generated units with recorded digests. Halogen's own published numbers on its native checkpoint are higher (1,740 tok/s prefill at 32K) and point to a later variant of this recipe.
- **GLM-5.3-Flash, AJ-IQ2_XXS** — 320B / 18B active, 87GB; long context is cheap (131K adds ~1.5GB). Stronger model, heavy compression (1.88× perplexity vs BF16); needs llama.cpp from unmerged PR #27752 ([model card](https://huggingface.co/aj9o9/GLM-5.3-Flash-GGUF)). A good second recipe: proves an image pinned to an unmerged branch.
- **DeepSeek V4.1 Flash** — only fits as a pruned 1–2 bit community build on a fork, untested on Strix Halo ([model card](https://huggingface.co/Harsha001/DeepSeek-V4.1-Flash-1017-StrixHalo-GGUF)). Not shipped.

Mia's recipes ([mia-ai.net/models](https://mia-ai.net/models)) are EXL3 + TensorFold/vLLM on 1–4 DGX Sparks or RTX PRO 6000s; they land with the CUDA images and GB10 qualification.

## Rollout

- **Phase 1** — one Strix Halo recipe end to end, on the halogen runtime so no image pipeline of our own is needed yet:
  - podman and crun in base, plus the install migration
  - the container contract, runtime definitions with the run-option allowlist, and the halogen definition as the first third-party-tier runtime
  - the `basecamp/omarchy-local-ai` catalog repo with its `schema-1` branch, CI checks and commit signing; catalog fetch and signature verification in Omarchy
  - machine profile, `best.toml` with the 128GB Strix Halo class, and `use best`
  - the measurement record for Qwen3.8 Flash Next on halogen, reproducing the hand-measured numbers through the generated unit
  - rootless preflight and GPU self-test
  - Quadlet generation with explicit autostart, health and restart behavior
  - per-user key and endpoint verification
  - staged, verified downloads and transactional switching
  - `use`, `stop`, `status`, `list`, `autostart`
  - OpenCode local launch through `OPENCODE_CONFIG`
- **Phase 2** — `omarchy agent local bench` for contributed measurement records; the `omarchy`-tier image pipeline (CI, pinned Containerfiles, signing) with a llama.cpp-Vulkan image as the first, so the 128GB class gets its fallback and recipes can use quants halogen refuses; the 64GB Strix Halo class; the panel's Local card with lifecycle state and actions; menu entries; `remove`; GLM-5.3-Flash as a further recipe.
- **Phase 3** — ROCm and CUDA images, the privileged GPU setup command, GB10 classes with recipes adapted from Mia's, more clients as overlays allow, live metrics.

halogen's fit with the design is already proven by hand: it runs from the generated Quadlet with a read-only model mount, the key as a Podman secret, read-only root, dropped capabilities, loopback-only port and `Notify=healthy`, and pi uses it through a provider entry.
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

1. Which signing scheme Podman verifies for `omarchy`-tier images (sigstore signatures vs GPG); the Containerfiles and CI live in the catalog repo.
2. Is one managed active model the right limit long term? A small fast model next to a big one (completion vs agent) is plausible on 128GB once headroom checks exist.
3. Should the model store share Hugging Face's cache (`~/.cache/huggingface`) so weights downloaded for other tools are reused, at the cost of Omarchy not owning deletion?
4. Should a recipe's `ctx` variants grow automatically as measurements come in for machines with less memory (64GB Strix Halo), or stay hand-curated?
