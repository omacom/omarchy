# Plan: Local models — `omarchy agent local use best`

Revision 5.

- Revision 2 tightened lifecycle, endpoint security, client selection, memory checks, supply chain and config ownership after a review pass.
- Revision 3 generalized the container contract after running halogen, a closed-source third-party engine, through it: backends are described by runtime definitions that map the standard inputs onto each image's own interface, declare allowlisted run options and their health probe, and carry a trust tier.
- Revision 4 added `use best`, a curated per-machine-class recommendation; moved recipes, runtimes and the recommendation into a separately updated, signed catalog repo, `basecamp/omarchy-local-ai`; kept weights on Hugging Face; recorded the hand-measured llama.cpp vs halogen comparison; and moved phase 1 onto the halogen runtime.
- Revision 5 answers a second review pass. The catalog is treated as a software release channel, not data, and Omarchy enforces outcomes instead of trusting inputs: an internal network with no egress (tested), a post-start auth check, typed field serialization, a per-file hash manifest, signed-catalog rollback protection, and a resolved manifest per run. `ipc=host` is gone after halogen ran without it at the same speed. `best` gets deterministic class rules.

## Problem

A 128GB unified-memory machine (Strix Halo, DGX Spark/GB10) can now run open models that are genuinely useful as coding agents: Qwen3.8 Flash Next, GLM-5.3-Flash, DeepSeek V4.1 Flash in pruned form. Getting one running is still an afternoon of archaeology. You pick from a dozen community quants of the same model, find the one llama.cpp branch or fork that supports its architecture, install build dependencies by trial and error (cmake, vulkan-headers, then spirv-headers when configure fails), raise kernel GPU memory limits, copy a 15-flag command line out of a gist, and then wire the endpoint into every agent CLI's own provider config by hand. None of it is reproducible: the next machine, or the same machine after a rebuild, starts from zero.

The work that makes these models fast already exists as recipes: curated quant + runtime + flag combinations published by people like Mia (mia-ai.net/models) and 0xSero, plus community builds tuned for a specific chip. What's missing is a way to run a recipe as one command, get the same result every time, and have Omarchy's agents and agent panel see it.

## Shape

- `omarchy agent local use best` picks the recipe recommended for this exact machine — GPU family, memory, platform — and runs it. `use <recipe>` runs a specific one.
- Recipes, runtime definitions and the recommendation come from a signed catalog repo, `basecamp/omarchy-local-ai`, updated far more often than Omarchy itself.
- `use` checks the machine can hold the model right now, pulls the runtime's container image pinned by digest, downloads pinned, hash-verified weights from Hugging Face, and starts the model as a rootless Podman container under a systemd user unit.
- Every backend (llama.cpp Vulkan/ROCm/CUDA, halogen, vLLM, SGLang, …) is a container with the same outside shape, so the framework only ever starts and stops containers.
- The active model is served at `127.0.0.1:11435` with an OpenAI-compatible API behind a per-user key. The container has no network access beyond answering on that port.
- Launching an agent in local mode points it at that endpoint through launch-time config Omarchy owns, never by rewriting the agent's own config files. OpenCode first; other clients once each has a supported overlay.
- The agent panel shows whether a local model is running and can switch or stop it.

## Rejected approaches

- **Native builds per machine**: what validating this plan took by hand (clone, cmake, three rounds of missing headers, a fork for unmerged architecture support). Every recipe that needs a different fork or branch multiplies it. Containers move the build to CI, once.
- **Distro packages per backend** (`llama.cpp-vulkan` in the Omarchy repo): solves llama.cpp only. Halogen, EngramHalo.cpp, ROCm forks and unmerged PR branches are exactly what the best recipes depend on, and they will never all be packaged. A package also pins one version system-wide, while recipes need different runtime revisions side by side.
- **Docker**: in base already, but needs a root daemon and the docker group or sudo for a per-user model server. Podman runs rootless and Quadlet turns a container into an ordinary systemd user unit.
- **Ollama / LM Studio as the runtime**: both stay installable from the menu, but they lag on new architectures and don't expose the flags (speculative-decoding drafts, KV cache types, tensor placement) that recipes are made of.
- **Hosting weights ourselves as OCI artifacts**: Podman 6 can pull and mount model artifacts natively through Quadlet `.artifact` units, which would make a recipe a single registry reference. Not worth it: Hugging Face at a pinned revision with per-file hash verification is already repeatable, while hosting means ~95GB per model variant, re-splitting 50GB shards to suit registry blob limits, and a redistribution review for every model's weights.
- **Recipes shipped inside the Omarchy repo**: the best recipe for a machine changes weekly; tying it to Omarchy releases would leave every user on a stale recommendation.
- **Computing "best" from a score**: which model is best on a machine is a judgment about quality and speed tradeoffs (a C-tier model at 2 bits vs a D-tier model at 4 bits), not something derivable from parameter counts. `best` resolves through a curated, ordered list.
- **A model zoo UI that browses Hugging Face**: thousands of quants, most broken or untested on a given chip. A recipe is a curated, measured claim — "this runs on this hardware at this speed" — which is the actual value.
- **Merging provider blocks into agents' config files**: even a "merge" rewrites the file, loses JSONC comments and TOML formatting, races the client's own writes, collides with user-owned `llamacpp` entries, and misses Codex's per-account homes (`bin/omarchy-agent` sets `CODEX_HOME` per account). Launch-time overlays avoid all of it.
- **Host IPC for ROCm engines**: halogen's quickstart passes `--ipc=host`. Run without it, with private IPC and on the internal network, it loaded, served and measured the same (40.3 s vs 40.5 s for the 32K turn). The option isn't offered at all.

## Design

### Trust model

The catalog decides which code runs: which image, which arguments, which weights. A catalog signer is therefore a software publisher for this feature, exactly like an Omarchy maintainer merging to `bin/`, and the plan doesn't pretend otherwise. What Omarchy owns is a boundary that holds even if a signed catalog entry is malicious or mistaken, enforced on outcomes rather than on trusting what the entry claims:

- **No network.** Every model container joins an `--internal` Podman network: the published loopback port still answers, and outbound connections fail with "network unreachable" (tested with the halogen image). A runtime can't exfiltrate code it's sent, whatever its license promises.
- **No host access beyond the model.** Read-only root, all capabilities dropped, `no-new-privileges`, a read-only mount of only the selected recipe's files, devices only from an allowlist.
- **No silent auth bypass.** After start, `use` requests `/v1/models` without the key and requires a 401, then with the key and requires the recipe's model id. A runtime that answers unauthenticated is stopped and reported, whatever its definition says.
- **No reserved knobs.** Runtime definitions can't set arbitrary environment variables or arguments; they can only map Omarchy's standard inputs, and recipes can add `[server] args` that are checked against the runtime's `reserved` list (its auth, bind, port and download switches). Duplicate or conflicting mappings are rejected.
- **Health probes are untrusted.** A probe runs inside the container and can only lie about the container's own health; the post-start checks above don't depend on it.

### Recipes

A recipe is one TOML file; its id is the filename stem and matches `^[a-z0-9]+([.-][a-z0-9]+)*$` (no `..`, no leading or trailing separator). Recipes come from the catalog's `recipes/`; user recipes in `~/.config/omarchy/agent-local/recipes/` override by id and are shown as local overrides.

```toml
# recipes/qwen3.8-flash-next-halogen.toml
name = "Qwen3.8 Flash Next"
summary = "125B MoE, ~6B active, 4-bit, MTP drafting."
runtime = "halogen"

[[hardware]]                          # tested qualifications, not guesses
gpu = "amd-strix-halo"
ram_class = 128
measured = "measurements/qwen3.8-flash-next-halogen-strix-halo-128.toml"

[[artifacts]]                         # every file the runtime reads, by role
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "<commit sha>"
license = "apache-2.0"
files = ["UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-0000[1-3]-of-00003.gguf"]
model = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "<commit sha>"
license = "apache-2.0 (derived from Qwen3.8-Flash-Next; upstream terms govern)"
files = ["qwen38-flash-next-mtp.hgn", "tokenizer/*"]
dest = "UD-IQ4_XS"                    # halogen expects these beside the GGUF
draft = "qwen38-flash-next-mtp.hgn"

[[variant]]                           # validated context sizes with measured peak memory
ctx = 131072
peak_gpu_gib = 72
peak_host_gib = 13
pins_memory = true                    # halogen locks its weights

[sampling]                            # server-side defaults where the runtime supports them
temperature = 1.0
top_p = 0.95
top_k = 20
```

- **Artifacts.** Each `[[artifacts]]` entry is one Hugging Face repo at one revision. `files` are expanded against that revision's file list, and each lands under the recipe's model directory at its repo path, or under `dest` when given. `dest` and every file path are checked for containment (no absolute paths, no `..`, no symlinks out); two entries producing the same path is an error. The roles `model` and `draft` name exactly one file across all entries; those are what the runtime's `model` and `draft` inputs receive.
- **Hashes.** At resolve time `use` builds a manifest from Hugging Face's own metadata for the pinned revision: every file's size and SHA-256 (its LFS object id). Downloads are checked against it, the disk-space check uses its total, and it's saved in the resolved manifest (see Repeatability).
- **Licenses.** Each artifact records its license, shown on first `use`; catalog CI checks it against the repo's declared license at that revision.
- **Hardware.** A `[[hardware]]` entry names the GPU family, the RAM class it was measured on, and its measurement record; optionally `platform` when the GPU family alone isn't enough. A recipe only claims hardware someone measured. The same runtime image runs on every machine of a GPU family; whether a recipe fits is a question of memory.
- **Sampling** is optional. Each key is passed as a server default if the runtime maps it, and otherwise skipped with a note in `status`, leaving it to the client. Every other standard input the recipe needs (`model`, `ctx`, `alias`, `key`, and `draft` when set) must be mapped by the runtime, or the recipe is invalid.
- **Measurement records** capture exact artifacts, digests, catalog commit, machine profile, peak GPU and host memory, time to first token, prefill and decode at stated context depths, and the command that produced them. Performance numbers in recipes, menus and docs come from these records, not from gists.

### Recipe catalog: `basecamp/omarchy-local-ai`

The recommendation for a machine changes far faster than Omarchy releases: a new quant lands, a runtime gets 30% faster, a new model beats the old best. So recipes, runtime definitions, `best.toml` and measurement records live in their own repo, `basecamp/omarchy-local-ai`.

```
omarchy-local-ai/
  catalog.toml          # schema version
  best.toml
  recipes/qwen3.8-flash-next-halogen.toml
  runtimes/halogen.toml
  runtimes/llama.cpp-vulkan.toml
  reviews/halogen-sha256-273714cc….toml
  measurements/qwen3.8-flash-next-halogen-strix-halo-128.toml
  images/llama.cpp-vulkan/Containerfile
```

Omarchy owns the mechanism and the boundary in the trust model; the catalog owns choices and evidence.

**Source, ref and trust are separate settings** in `~/.config/omarchy/agent-local/catalog.toml`:

- `url` — default `https://github.com/basecamp/omarchy-local-ai`; a mirror is fine.
- `ref` — default the branch for the schema this Omarchy reads (`schema-1`, …); or a pinned commit.
- `trust` — default `official`: every accepted commit must carry an SSH signature from a key in the allowed-signers file shipped with Omarchy, whatever the URL or ref. A fork can add its own allowed-signers file, or set `trust = "unsigned-dev"`, which every command then announces. Pinning or mirroring never turns verification off.

**Fetching.**

- `use`, `list` and `status` refresh the catalog when the cached copy is older than a few hours. `omarchy-update` gains a refresh step that is best-effort: a failure keeps the cache and never fails the system update. There is no timer of its own. Offline, the cached catalog is used and the command says how old it is.
- Git runs isolated from the user's configuration (`GIT_CONFIG_NOSYSTEM=1`, `GIT_CONFIG_GLOBAL=/dev/null`, no hooks, no credential helpers) into `~/.local/state/omarchy/agent-local/catalog/`.
- A fetched commit becomes `current` only if it is signed per `trust`, descends from the currently accepted commit (no silent rollback to an older signed commit), and passes full local schema validation, including the trust-model checks. Otherwise the previous catalog stays current and the reason is shown. Deliberate rollback is an explicit pin, and still signed.
- A schema change gets a new branch, so older Omarchy installs keep receiving updates in the schema they can read.
- Keys rotate and get revoked through the allowed-signers file shipped with Omarchy updates; a revoked key's commits stop being accepted as new tips.

**Contributing.** A recipe or a new hardware class comes in as a pull request with its measurement record, produced by `omarchy agent local bench` (phase 2): a fixed prompt set (a short prompt and a ~32K-token prompt of real code, greedy, thinking off) run against the running model. Catalog CI checks every change:

- schema validity, and the same trust-model checks Omarchy runs locally
- that every image digest, Hugging Face revision and file exists, with each artifact's declared license
- that every recipe named in `best.toml` for a class has a measurement record from that class
- that every third-party runtime digest has a review record
- that `best.toml` has no ambiguous classes

### Choosing for the machine: `best`

`omarchy-agent-local-profile` reads the machine once per command, from sysfs and the existing helpers, with no network:

- `platform` from `omarchy-hw-platform`
- `gpu`: the GPU family of each GPU, from its gfx target on AMD (`gfx1151` → `amd-strix-halo`) or the platform for GB10. With several GPUs, the one with the most addressable memory is used; a tie between different families requires `use best --gpu <family>`.
- `ram_class`: installed RAM (`MemTotal`) rounded up to the nearest of 32, 64, 96, 128, 192, 256, 512 GiB.
- `gpu_memory_gib`: memory the chosen GPU can address (`mem_info_gtt_total` plus VRAM on AMD). This is an eligibility constraint, never part of the class.

`best.toml` is an ordered list per class:

```toml
[[class]]
gpu = "amd-strix-halo"
ram_class = 128
recipes = ["qwen3.8-flash-next-halogen", "qwen3.8-flash-next-llama.cpp"]

[[class]]
gpu = "amd-strix-halo"
ram_class = 64
recipes = ["qwen3.8-27b-halogen", "qwen3.6-35b-a3b-llama.cpp"]

[[class]]
platform = "aarch64-gb10"
ram_class = 128
recipes = ["…"]
```

Resolution is deterministic:

1. **Class.** A class matches when every selector it names equals the profile's value. Precedence: a class naming `gpu` beats one naming only `platform`; among those, more selectors beats fewer. Two matching classes of equal precedence are a catalog error, caught by CI and refused locally.
2. **Recipe and variant.** Walk the class's list in order. For each recipe, choose its largest `[[variant]]` whose peaks fit `gpu_memory_gib` and installed RAM minus the desktop reserve; the first recipe with such a variant wins. Later recipes are fallbacks only for static reasons: a runtime unsupported on this GPU, or a GTT limit set lower than the default. `--ctx` overrides the variant choice.
3. **Headroom is not a fallback reason.** If the chosen recipe fits the machine but memory is busy right now, `use best` says what's holding memory instead of quietly starting a worse model.
4. **No match.** `use best` shows the profile it saw and the recipes that come closest, so a missing class is visible and easy to report.

`use best` prints what it resolved to and why, and records the concrete recipe as active, never `best`. A newer catalog may change the recommendation: `status` shows when the active recipe is no longer `best`, and running `use best` again moves to it. Nothing switches models on its own.

### Repeatability

Every `use` writes a resolved manifest, `~/.local/state/omarchy/agent-local/runs/<timestamp>.toml`, and points `active` at it:

- catalog URL and commit, and trust mode
- recipe and runtime ids, with any local overrides inlined in full
- chosen variant, the machine profile it was resolved against
- image digest, every artifact's repo, revision, path, size and SHA-256
- the complete generated argument and environment lists (key excluded)

`use --manifest <file>` reruns a manifest exactly, without consulting the catalog's current state, and manifests are kept, along with the catalog commits they reference, until `remove`. The promise is identical selected artifacts and launch configuration on a machine of the same class. Identical behavior also depends on the host's kernel, firmware and drivers, which a manifest records but can't pin.

### The backend container contract

The contract is the container's outside shape, not its insides. Omarchy must not need to rebuild a third-party image to wrap it, so everything an image does differently is described by its runtime definition instead of required of the image. Every backend image:

| | Contract |
|---|---|
| API | Serves an OpenAI-compatible API on one container port: `/v1/models`, `/v1/chat/completions` with streaming and tool calls through the model's chat template |
| Auth | Requires a bearer key, read from an environment variable or a file, on every route except health; there are no unauthenticated admin routes on that port |
| Health | Has an HTTP endpoint that returns 200 only once the model is loaded |
| Models | Works from a read-only mount; writes nothing there and fetches nothing at startup |
| Network | Works with no outbound network |
| Inputs | Takes model path, context size, served model id and key, and optionally a draft path, as CLI arguments or environment variables |

The acceptance check every runtime and recipe passes before publication: a streamed completion, a tool-call round trip, a chat-template sanity check, a 401 on every known route without the key, and a clean start on the internal network.

### Runtime definitions

A runtime definition describes one image and how to drive it, so many recipes share it. They come from the catalog's `runtimes/`; user runtimes in `~/.config/omarchy/agent-local/runtimes/` override by id.

```toml
# runtimes/halogen.toml — third-party, closed source
image = "ghcr.io/peonist-ai/halogen-flash-server@sha256:273714ccb64dabb7fac0418ee1b6dd83eb57d2fd44cf286eb68a7c694a27c203"
tier = "third-party"
review = "reviews/halogen-sha256-273714cc….toml"
port = 8731
health = { path = "/health", probe = ["/usr/local/bin/python3", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8731/health', timeout=4)"] }
run = { devices = ["render", "kfd"], group_add = "keep-groups", memlock = "unlimited" }
reserved = ["HALOGEN_API_KEY", "HALOGEN_API_KEY_FILE", "HALOGEN_DOWNLOAD", "HALOGEN_BIND", "HALOGEN_PORT", "HALOGEN_API_PORT"]

[inputs]
model = { env = "HALOGEN_CHECKPOINT" }
draft = { env = "HALOGEN_MTP_HEAD" }
ctx = { env = "HALOGEN_CTX" }
alias = { env = "HALOGEN_MODEL_ID" }
key = { env = "HALOGEN_API_KEY" }
```

```toml
# runtimes/llama.cpp-vulkan.toml — built by Omarchy (phase 2)
image = "ghcr.io/omarchy/llama.cpp-vulkan@sha256:…"
tier = "omarchy"
port = 8080
health = { path = "/health", probe = ["/usr/local/bin/omarchy-health"] }
run = { devices = ["render"] }
reserved = ["--api-key", "--api-key-file", "--host", "--port", "--webui", "-hf", "--hf-repo"]

[inputs]
model = { arg = "--model" }
draft = { arg = "--model-draft" }
ctx = { arg = "--ctx-size" }
alias = { arg = "--alias" }
key = { env = "LLAMA_API_KEY" }
temperature = { arg = "--temp" }
top_p = { arg = "--top-p" }
top_k = { arg = "--top-k" }
```

- **Inputs** map each standard input to one CLI argument or one environment variable. Paths are rewritten to their location under `/models`. The key is always delivered from the Podman secret, never on the command line where `ps` would show it.
- **Reserved** names are the runtime's own security- and network-relevant switches. Recipe `[server] args` can't use them, and no input mapping may target one except the key mapping to its own variable.
- **Health** names the endpoint and the probe command `HealthCmd` runs, since images don't ship the same tools: halogen has no `curl`, only `python3`.
- **Run options** come from a fixed allowlist, each mapped to one Quadlet key, so a runtime file can't add arbitrary `podman run` flags:

| Option | Values | Quadlet |
|---|---|---|
| `devices` | `render` (the chosen GPU's own render node), `kfd`, `cdi-nvidia` | `AddDevice=` |
| `group_add` | `keep-groups` | `GroupAdd=keep-groups` |
| `memlock` | `unlimited` | `Ulimit=memlock=-1:-1` |
| `shm_size` | size, at most 16 GiB | `ShmSize=` |

  `memlock = "unlimited"` lets a runtime pin its weights, which makes memory estimates matter more; it's only allowed for runtimes whose recipes declare `pins_memory`, and headroom checks treat those peaks as unreclaimable. Network mode, read-only root, dropped capabilities and `no-new-privileges` aren't options. An addition to the allowlist is a change to Omarchy, reviewed as such.

### Generating the unit safely

Every value written into the Quadlet file comes from a typed field and has one serialization rule; nothing is interpolated as free text:

- Control characters (including newlines) are rejected in every field, so no value can start a new directive.
- `%` is escaped as `%%` everywhere systemd expands specifiers.
- `Exec=` and `HealthCmd=` are written from argument arrays with systemd's quoting; `Environment=` values are quoted per key; image references must match `<registry>/<path>@sha256:<64 hex>`.
- `Description=` and labels use only the recipe id and a name limited to printable characters.
- Paths are built by Omarchy from validated ids and manifest paths, never taken from recipe text.

The test for this feeds hostile values (newlines, `%`, quotes, `..`, spaces) through the real generator and then through Quadlet's own parser (`podman-system-generator --user --dryrun`), asserting the generated unit is either refused or exactly what was intended.

### Images and supply chain

**`omarchy` tier** — images Omarchy builds, from phase 2:

- Built in the catalog repo's CI from Containerfiles that pin the base image by digest, the backend by upstream commit, and Mesa/ROCm/CUDA by version. One image per backend × GPU flavor × architecture.
- Signed with build provenance, and required to be by a Podman `policy.json` scoped to `ghcr.io/omarchy`.

**`third-party` tier** — vetted images published by someone else, like halogen. Some of the fastest engines are closed source or ship only as their author's container:

- Pinned by digest like Omarchy's own, so the bytes never change under a recipe.
- Admitted per digest by a review record: publisher, reviewer, date, the license text's SHA-256 at review time, the license URL at a fixed revision, and what was checked — permitted use, redistribution, stated network behavior, and that the image passes the acceptance check on the internal network. A digest bump needs a new review record; a changed license hash forces a fresh review.
- Publisher statements (halogen's license says no telemetry and no network calls unless `HALOGEN_DOWNLOAD` is set) are recorded as statements. The internal network is what enforces them.
- Signatures are verified when the publisher signs; otherwise the reviewed digest is the trust anchor, and the review says so.
- `list`, the menu and the first `use` show third-party runtimes with their publisher and license before pulling.

**Both tiers**: recipes pin per-architecture digests, not a multi-arch index. Security and Mesa updates reach users only when a new digest lands in the catalog and the user runs `use` again; running models never float. Mesa matters: Vulkan and ROCm images carry their userspace driver and only the kernel driver comes from the host. User-supplied Containerfiles are out of scope.

### Rootless GPU

- Podman and crun join `omarchy-base.packages`, with a migration (via the migration helper, using `omarchy-pkg-add`, idempotent, failing synchronously, no shell restart) that installs them on existing machines. Commands then treat Podman as a runtime invariant and never check for it. Cost is about 107 MiB installed: podman 83 MiB, netavark and aardvark-dns 13 MiB, crun and its checkpoint/restore dependencies 9 MiB, the rest under 2 MiB; everything else in its tree is already on the base system.
- Devices are minimal: the chosen GPU's own render node (not all of `/dev/dri`), `/dev/kfd` for ROCm engines, CDI `nvidia.com/gpu=all` for CUDA. Where a node is group-owned rather than world-accessible, the runtime needs `group_add = "keep-groups"`, which requires the user systemd manager to hold that group.
- `use` runs a preflight before downloading anything: subordinate ID ranges exist, every device the runtime asks for is accessible to the user manager, and a throwaway container from the runtime's image, with the same devices and options on the internal network, can open them. Failures say what to fix, and the remediation never makes a device world-writable. `use` never changes device permissions or groups itself.
- Privileged one-time setup lives in its own command, `omarchy-setup-agent-local-gpu`, run with sudo from a terminal: group membership where needed, and on CUDA platforms CDI spec generation into `/etc/cdi` plus a pacman hook that regenerates it when the NVIDIA driver changes.

### Running it: Podman Quadlet

`use` generates the internal network once and one container unit per switch:

```ini
# ~/.config/containers/systemd/omarchy-agent-local.network
[Network]
NetworkName=omarchy-agent-local
Internal=true
```

```ini
# ~/.config/containers/systemd/omarchy-agent-local.container  (halogen, as run by hand)
[Unit]
Description=Omarchy local model: qwen3.8-flash-next-halogen
PartOf=graphical-session.target
After=graphical-session.target
StartLimitIntervalSec=10m
StartLimitBurst=3

[Container]
ContainerName=omarchy-agent-local
Image=ghcr.io/peonist-ai/halogen-flash-server@sha256:273714ccb64dabb7fac0418ee1b6dd83eb57d2fd44cf286eb68a7c694a27c203
Label=org.omarchy.agent-local.recipe=qwen3.8-flash-next-halogen
Network=omarchy-agent-local.network
AddDevice=/dev/kfd
AddDevice=/dev/dri/renderD128
GroupAdd=keep-groups
Ulimit=memlock=-1:-1
Volume=%h/.local/share/omarchy/agent-local/models/qwen3.8-flash-next-halogen:/models:ro
PublishPort=127.0.0.1:11435:8731
Secret=omarchy-agent-local-key,type=env,target=HALOGEN_API_KEY
Environment=HALOGEN_CHECKPOINT=/models/UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf
Environment=HALOGEN_MTP_HEAD=/models/UD-IQ4_XS/qwen38-flash-next-mtp.hgn
Environment=HALOGEN_MODEL_ID=qwen3.8-flash-next-halogen
Environment=HALOGEN_CTX=131072
ReadOnly=true
DropCapability=all
NoNewPrivileges=true
HealthCmd=/usr/local/bin/python3 -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8731/health', timeout=4)"
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
```

- No `[Install]` section: Quadlet applies `[Install]` at generation time and generated units can't be toggled with `systemctl enable`, so autostart is its own setting, `omarchy agent local autostart on|off`, which regenerates the file with or without `WantedBy=graphical-session.target`.
- `PartOf=graphical-session.target`: the model stops at logout and frees its memory, matching the repo's other session services.
- Readiness: `Notify=healthy` holds activation until the probe passes, so a started unit is a loaded model. `TimeoutStartSec` (12 min) sits above `HealthStartPeriod` (10 min), so a slow first load fails as unhealthy with the reason in the journal rather than as a bare timeout.
- Failure: after startup, three failed probes 30 s apart make Podman kill the container, the unit fails, and systemd restarts it after 10 s. The restart budget counts starts: a fourth start within 10 minutes is refused and the unit stays failed, so a model that keeps hanging, or keeps failing to load, stops cycling within that window. `status` reports the last failure.
- The health check is a periodic probe inside the container, a deliberate exception to the no-polling rule: the server has no change signal for "hung", and the probe runs in the container, not in the shell.
- Logs are `journalctl --user -u omarchy-agent-local`.

### Endpoint security

The endpoint receives source code and its output drives agents launched with permissive flags:

- A per-user random key lives in `~/.config/omarchy/agent-local/key` (mode 0600) and in a Podman secret. This covers other local users and browser pages, which can reach loopback but can't read the key.
- Podman refuses to start if `11435` is taken. After start, `use` runs the auth check from the trust model — 401 without the key, the recipe's model id with it — so a squatting process can't impersonate the server, and a runtime that ignores the key is stopped.
- Every route on the port except health needs the key (part of the acceptance check); there are no separately "unpublished" routes, since one published port exposes them all.

### Commands

All `omarchy-agent-local-*`, routed as `omarchy agent local …`:

- `use best [--gpu <family>] [--ctx <n>]` — resolve the recommended recipe and variant for this machine, then `use` it.
- `use <recipe> [--ctx <n>] [--catalog <commit>]` — resolve, check compatibility and headroom, preflight the GPU, pull the image, download and verify the artifacts, write the resolved manifest, generate the unit, switch, run the post-start checks.
- `use --manifest <file>` — rerun a resolved manifest exactly.
- `list` — recipes, marking which are qualified for this machine, which is `best`, and which is active.
- `status` — active recipe and manifest, unit state, endpoint, catalog age and commit, last failure, and whether `best` has moved.
- `stop` — stop the unit; keeps weights, image and manifests.
- `autostart on|off` — regenerate the unit with or without starting at login.
- `remove <recipe>` (phase 2) — delete files no other kept manifest references, the image if unused, and its manifests.

Mutations are serialized with a lock in `~/.local/state/omarchy/agent-local/`. Switching is transactional:

- Downloads go to a staging directory and are checked against the manifest's sizes and hashes before being renamed into place. The disk-space check uses the manifest's total; interrupted downloads resume from staging.
- The current unit file is kept until the new recipe passes health and the post-start checks; on failure `use` restores and restarts the previous recipe and reports why.
- Switching interrupts in-flight requests; `use` says so before stopping a running model.

### Memory checks

Two separate questions, never conflated:

- **Compatibility** (static, cheap, cached): a `[[hardware]]` entry matches this machine, and a variant's measured peaks fit `gpu_memory_gib` and installed RAM minus a desktop reserve. Used by `best`, `list` and the menu.
- **Headroom** (at start time): after stopping the previous managed model, the variant's peaks plus the reserve must fit what's really free: free GTT (`mem_info_gtt_total` − `mem_info_gtt_used`) and available RAM, where available RAM doesn't count locked memory as reclaimable (`MemAvailable` minus `Mlocked` and unevictable pages). Ollama, LM Studio or anything else already holding memory counts against it; `use` names what's using it rather than starting a model that would OOM the desktop.

Pinned memory isn't reclaimable even when the kernel reports it as cache: halogen locks its ~72 GiB of weights and warns that `free` and `MemAvailable` overstate what's left (23.7 GiB truly available on the measured run). Recipes declare `pins_memory`, and measurement records note it.

Estimates are reported as estimates. Automatic context sizing and changing kernel parameters (GTT limits) are out of scope; a recipe that needs a bigger GTT limit says so and links the manual page.

### Launching agents against it

- Registering the endpoint, selecting the model and choosing the default agent are separate steps. `use` only changes which recipe is active.
- Local mode is chosen per launch: `omarchy agent --local` (and a panel action) launches the default agent pointed at the active local model. Without it, agents launch exactly as today.
- Integration is a launch-time overlay Omarchy owns, never an edit to the client's files. For OpenCode, `omarchy-agent` sets `OPENCODE_CONFIG` to a generated `~/.config/omarchy/agent-local/opencode.json` declaring provider `llamacpp` (`@ai-sdk/openai-compatible`, base URL, `"apiKey": "{file:~/.config/omarchy/agent-local/key}"` so the key is never copied into the overlay) and passes `--model llamacpp/<recipe-id>`. OpenCode merges `OPENCODE_CONFIG` over the global config and under project config, so the user's own files are untouched; a `llamacpp` provider in their global config is overridden for local launches only.
- The model id is the recipe id, so usage history stays per model and resumed sessions name the model they actually used. The overlay is regenerated on each local launch, so it always matches the active recipe.
- Phase 1 supports OpenCode only, chosen because it has a supported config overlay. Pi, Codex and others are added one at a time, each only once it has an overlay or launch flag; Codex in particular needs to respect the per-account `CODEX_HOME` that `omarchy-agent` selects. Pi has been verified by hand against the halogen endpoint through a `models.json` provider entry whose key is read with `!cat` from the key file, so it's the natural second client once a non-invasive way to supply that entry exists.
- `llamacpp` is already in the `local` usage collector's `KNOWN_LOCAL_PROVIDERS` (`bin/omarchy-agent-usage-local`), so OpenCode turns against it are counted with no collector change.

### Agent panel

Server lifecycle and usage history are different data with different owners and stay separate, even when shown in one card:

- Usage remains the `local` collector's job and stays read-only and history-based; its `ready` keeps meaning "has usage", and it gains no server fields.
- Server state comes straight from systemd: the panel reads the unit's `ActiveState`, `SubState` and `Result` once when it starts, then follows `PropertiesChanged` for `omarchy-agent-local.service` on the user bus, resubscribing and re-reading when the bus reconnects. The active recipe comes from the `active` manifest. External changes (`systemctl --user stop`, a crash, logout) show up the same way.
- The Local card shows recipe, state (stopped, loading, ready, failed with reason) and start/stop/switch actions, and appears even before any usage exists. That needs its own visibility path in `Main.qml`: today providers are filtered before card filtering, display objects are built field by field, and a card needs limits, accounts, a balance or a non-empty `tierLabel`.
- Live memory and tokens per second are deferred. They change without any systemd signal, and backend metrics have no normalized names; when added they get a defined schema and one shared sampler that runs only while the panel is visible.

### Menu

Recipes change with the catalog, so the menu doesn't list them statically. `default/omarchy/omarchy-menu.jsonc` gets two entries next to Ollama and LM Studio:

- "Local model (best for this machine)", running `omarchy-agent-local-use best`.
- "Choose local model…", a picker fed by a menu provider that reads the cached catalog and the cached machine profile. Profile and compatibility are written by any `omarchy-agent-local-*` command and by the migration that installs Podman, so the cache exists before the first menu open; if it's missing anyway, the picker shows one "Refresh local models" row running `list`. Nothing probes hardware or the network on menu open, keeping within the guard budgets in `docs/menu.md`.

Today's provider rows carry only `label`, `value`, `current` and search text (`docs/menu.md`), and generated rows are never disabled (`shell/plugins/menu/Menu.qml`), where "disabled" otherwise means "already installed" and gets a checkmark. So this needs a provider-row extension: an `available` flag and a `reason`, rendered as a dimmed row with the reason as its secondary text, distinct from the installed style. Recipes not qualified for this machine are shown that way, not hidden.

## First recipes

Survey for a 128GB Strix Halo, November 2026. A number becomes a recipe's claim only after a measurement record reproduces it:

- **Qwen3.8 Flash Next, UD-IQ4_XS on halogen** — 125B MoE, ~6B active. The phase 1 recipe and the 128GB Strix Halo `best`. Measured by hand on a Ryzen AI Max+ 395 / 128GB on 2026-11-01 with the same GGUF and the same prompts (greedy, thinking off; a 41-token prompt and a 31,705-token prompt of shell scripts, 512 tokens out):

  | 31,705-token prompt | llama.cpp Vulkan (`-lm mmap`, MTP draft) | halogen 0.18.22, host IPC | halogen 0.18.22, private IPC + internal network |
  |---|---|---|---|
  | Time to first token | 131.5 s | 26.6 s | 27.5 s |
  | Prefill | 241 tok/s | 1,194 tok/s | 1,154 tok/s |
  | Decode | 19.9 tok/s | 36.5 tok/s | 39.9 tok/s |
  | Whole turn | 157 s | 40.5 s | 40.3 s |
  | Load | 32 s | 12 s | 16 s |
  | Memory | 67 GiB GTT; ~48 GB available, Engram table as reclaimable cache | ~72 GiB locked; ~24 GiB truly available | same |

  The two halogen columns are within run-to-run noise, so the constrained configuration in this plan costs nothing measurable. Short-prompt decode: llama.cpp 40.4 tok/s, halogen 44.7–60.4 tok/s over a 54-token reply. halogen's own published numbers on its native checkpoint are higher (1,740 tok/s prefill at 32K) and point to a later variant.
- **Qwen3.8 Flash Next, UD-IQ4_XS on llama.cpp** — the open-source fallback for the 128GB class, arriving with the phase 2 image.
- **GLM-5.3-Flash, AJ-IQ2_XXS** — 320B / 18B active, 87GB; long context is cheap (131K adds ~1.5GB). Stronger model, heavy compression (1.88× perplexity vs BF16); needs llama.cpp from unmerged PR #27752 ([model card](https://huggingface.co/aj9o9/GLM-5.3-Flash-GGUF)). A good later recipe: proves an image pinned to an unmerged branch.
- **DeepSeek V4.1 Flash** — only fits as a pruned 1–2 bit community build on a fork, untested on Strix Halo ([model card](https://huggingface.co/Harsha001/DeepSeek-V4.1-Flash-1017-StrixHalo-GGUF)). Not shipped.

Mia's recipes ([mia-ai.net/models](https://mia-ai.net/models)) are EXL3 + TensorFold/vLLM on 1–4 DGX Sparks or RTX PRO 6000s; they land with the CUDA images and GB10 classes.

## Rollout

Phase 1 depends on a closed-source runtime and has no open-source fallback: if halogen's image or terms change in a way review rejects, the 128GB class has no recipe until phase 2's llama.cpp image lands. That's accepted for speed (4× per agent turn) and because the trust model doesn't rely on halogen's promises.

- **Phase 1** — one Strix Halo recipe end to end, on the halogen runtime:
  - podman and crun in base, plus the install migration
  - the trust model's enforcement: internal network, post-start auth check, reserved names, typed unit generation
  - runtime definitions with the run-option allowlist, and the halogen definition with its review record
  - the `basecamp/omarchy-local-ai` catalog repo with its `schema-1` branch, CI checks and commit signing; catalog fetch with signature, ancestry and schema verification in Omarchy
  - machine profile, `best.toml` with the 128GB Strix Halo class, and `use best`
  - artifact manifests from Hugging Face metadata, staged and verified downloads, resolved manifests, transactional switching
  - rootless preflight
  - Quadlet generation with explicit autostart, health and restart behavior
  - `use`, `stop`, `status`, `list`, `autostart`
  - OpenCode local launch through `OPENCODE_CONFIG`
  - the measurement record for Qwen3.8 Flash Next on halogen, reproducing the hand-measured numbers through the generated unit
- **Phase 2** — `omarchy agent local bench` for contributed measurement records; the `omarchy`-tier image pipeline with a llama.cpp-Vulkan image as the first, giving the 128GB class its open-source fallback and recipes for quants halogen refuses; the 64GB Strix Halo class; the panel's Local card; the menu entries and provider-row extension; `remove`; pi as the second client.
- **Phase 3** — ROCm and CUDA images, the privileged GPU setup command, GB10 classes with recipes adapted from Mia's, more clients as overlays allow, live metrics.
- **Docs** — a manual page for running local models; `docs/` reference for the trust model, recipe and runtime formats, measurement records and the container contract.
- **Tests** — extending existing area tests where they exist, covering real logic only:
  - recipe and runtime parsing, id validation, reserved-name and conflicting-mapping rejection
  - hostile values through the real generator and Quadlet's parser
  - `best` resolution against fixture profiles: class precedence, ambiguity, variant choice, static fallback, multi-GPU tie
  - catalog acceptance: unsigned, unknown signer, non-descendant and invalid-schema commits are refused and `current` is unchanged
  - compatibility and headroom decisions against fixture sysfs and meminfo, including locked memory
  - rollback when the new recipe fails health or the post-start auth check
  - OpenCode overlay generation
  - CLI metadata via `omarchy commands --check`
  - no migration test
  - a disposable-VM lifecycle check for `use`/`stop`/`autostart` with a CPU-only test image, including that the container can't reach the network; GPU paths need real hardware, and the panel card is verified per the visual-verification skill

halogen's fit with this design is already proven by hand: it runs from a Quadlet unit like the one above, with a read-only model mount, the key as a Podman secret, read-only root, dropped capabilities, private IPC, the internal network (outbound connections fail), a loopback-only port and `Notify=healthy`, and pi uses it.

## Open questions

1. Which signing scheme Podman verifies for `omarchy`-tier images (sigstore signatures vs GPG).
2. Is one managed active model the right limit long term? A small fast model next to a big one (completion vs agent) is plausible on 128GB once headroom checks exist.
3. Should the model store share Hugging Face's cache (`~/.cache/huggingface`) so weights downloaded for other tools are reused, at the cost of Omarchy not owning deletion?
4. Should a recipe's `ctx` variants grow automatically as measurements come in for smaller machines, or stay hand-curated?
5. Who holds catalog signing keys, and is one maintainer's signature enough for a `best.toml` change, or should changes that select a new third-party runtime need two?
