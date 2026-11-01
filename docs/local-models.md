# Local models

This reference describes the implementation in `shell/plugins/agents/agent_local.py` and the catalog checkout at `/home/dhh/src/omarchy-local-ai` as of November 1, 2026. For commands aimed at users, see [AI: Local models](../manual/17-ai.md#local-models). The design proposal is [plans/local-models.md](../plans/local-models.md); implementation differences are listed below.

## Overview and file map

Omarchy manages one active rootless Podman model server, exposed as an OpenAI-compatible endpoint at `http://127.0.0.1:11435/v1`. The catalog supplies recipes, runtime definitions and ordered recommendations; Omarchy resolves them, downloads weights, generates Quadlet units and checks the running endpoint. Catalog refresh never switches a running model.

| File or component | Responsibility |
|---|---|
| `shell/plugins/agents/agent_local.py` | Profile, validation, catalog acceptance, artifact storage, units, lifecycle, manifests, overlays and benchmarks |
| `bin/omarchy-agent-local-*` | Thin Python entry points importing the module through `$OMARCHY_PATH` |
| `bin/omarchy-agent` | `--local` launches the selected default agent using an Omarchy-owned overlay; currently only OpenCode is supported |
| `default/omarchy/omarchy-menu.jsonc` | Best-model action and recipe submenu under Install > AI |
| `shell/plugins/menu/Menu.qml`, `MenuModel.js` | `local-models` provider and unavailable-row presentation; see [Menu providers](menu.md#providers) |
| `shell/plugins/agents/Main.qml`, `Panel.qml` | Watch lifecycle status and display the model card and actions |
| `bin/omarchy-agent-usage-local` | Count historical usage separately from server lifecycle |
| `install/omarchy-base.packages`, `migrations/1793534376.sh` | Install Podman and crun; migration calls `omarchy-pkg-add podman crun` |
| `default/omarchy/agent-local/allowed_signers` | SSH catalog signing trust anchors; currently comments only, with no shipped signing key |
| `bin/omarchy-update` | Best-effort `omarchy-agent-local-refresh --quiet` when the user's catalog directory exists; failure warns without failing the update |

Visible commands are `use`, `list`, `status`, `stop`, `autostart`, `remove` and `bench`, routed under `omarchy agent local`. Hidden commands are `profile`, `refresh`, `validate` and `overlay`. `use` accepts `best` or a recipe id, `--ctx`, `--gpu`, `--catalog <commit>`, `--manifest <file>`, `--seed <directory>` and `--unqualified`. `list` supports `--json` and `--offline`; `status` supports `--json` and the internal `--write`; `refresh` supports `--quiet`; `validate <directory>` supports `--online`; `overlay` accepts only `opencode`; `bench` supports `--output <file>`.

The menu provider reads only cached `list.json`, with no hardware probe or catalog fetch. Its tab-delimited rows are `label`, `value`, `current`, optional search text and optional unavailable reason. Recommended rows get “ · best”, third-party rows name their publisher, and unavailable rows stay visible but cannot be selected. Without the cache, a refresh row runs `list` in a visible floating terminal. Selecting a recipe runs `use <id>` there.

The panel card appears once status names a configured recipe, independently of usage history. It shows recipe, runtime, unit state, endpoint and context while running, and a changed recommendation. Actions start the unit directly, stop it, launch `omarchy-agent --local`, open the menu picker, or run `use best` when the recommendation differs.

## Trust model

Catalog signers choose executable software: images, commands and health probes. Runtime `command` is an arbitrary string argv list and a probe executes inside the container; these are trusted release inputs, not a sandboxed recipe language. Image references must include a registry/path and a SHA-256 digest. The module does not verify image publisher signatures or distinguish image execution policy by tier.

Every generated container uses the internal `omarchy-agent-local` network, publishes only the loopback port, mounts only its recipe's model directory read-only at `/models`, sets a read-only root, drops all capabilities and enables no-new-privileges. Host networking, host IPC, privilege flags and arbitrary mounts are not configurable run options. Network restrictions apply to model containers; Git, Hugging Face downloads and image pulls happen on the host.

| Runtime `[run]` option | Allowed values | Generated Quadlet setting |
|---|---|---|
| `devices` | `render`, `kfd`, `cdi-nvidia` | `AddDevice=` for the selected render node, `/dev/kfd`, or `nvidia.com/gpu=all` |
| `group_add` | `keep-groups` | `GroupAdd=keep-groups` when the field equals this scalar |
| `memlock` | `unlimited` | `Ulimit=memlock=-1:-1` when the field equals this scalar |
| `shm_size_gib` | Number greater than zero and at most 16 | `ShmSize=` in integer MiB |

The validator accepts scalar or list values for the first three options, but device generation iterates `devices`, and group/memlock generation compares scalars. Catalog authors should use a list for `devices` and scalars for the other two, as the examples do.

Runtime inputs may map only `model`, `draft`, `ctx`, `alias`, `key`, `temperature`, `top_p` and `top_k`, each to exactly one valid argument name or uppercase environment name. Duplicate targets are rejected. `model`, `alias` and `key` are required; context and draft mappings are required when used. A runtime's `reserved` list protects its bind, port, download and auth controls: recipe arguments, including `--flag=value`, cannot use reserved or input-mapped argument names. An input cannot target a reserved name except for a key mapping whose target contains “key”. All key targets must contain “key”; `OMARCHY_LOCAL_KEY` is reserved for Omarchy. Recipe arguments cannot include `@OMARCHY_LOCAL_KEY@`. These checks depend on the runtime declaring its reserved names correctly.

Control characters are rejected in relevant strings. The generator quotes argv and environment values and escapes systemd percent and dollar substitutions; it does not interpolate a raw recipe fragment into the unit.

`ensure_key()` creates a random `token_urlsafe(32)` key, keeps `~/.config/omarchy/agent-local/key` at mode 0600, and creates/replaces the Podman secret `omarchy-agent-local-key`. The config directory is created with mode 0700 when creating a key. Units inject the secret as `OMARCHY_LOCAL_KEY` and, for an environment key mapping, as the runtime's key variable too. Key contents are absent from units, overlays and run manifests.

An argument key requires `key_on_cmdline = true` and `shell = "/bin/bash"` (the only supported shell). The generated bash entrypoint replaces an exact `@OMARCHY_LOCAL_KEY@` argv element with the secret inside the container, then execs the runtime. `use` warns that the resulting key is visible in the process list to other local users. Gufo uses this path; halogen takes an environment key.

After health readiness, `use` checks `/v1/models`: without a key it must return 401 or 403; with the key it must return 200 and list the recipe id. It does not test every route, a wrong key, or outbound connectivity at each start. Failed checks stop the candidate and restore the previous container unit, restarting it if it had been running.

## Catalog acceptance and refresh

Settings are in `~/.config/omarchy/agent-local/catalog.toml`:

```toml
url = "https://github.com/omacom/omarchy-local-ai"
ref = "schema-1"
trust = "official"
allowed_signers = ""
```

`official` requires an SSH signature allowed by the configured signers file, or by `$OMARCHY_PATH/default/omarchy/agent-local/allowed_signers` when empty. The shipped file currently has no keys, so a fresh official fetch fails closed until a key is supplied. `unsigned-dev` explicitly skips signature verification; `use` warns for this trust mode on the normal catalog path. A mirror or custom ref does not disable verification. Schema 1 is the only supported schema; `schema-<n>` branches let older readers remain on their supported format.

State lives in `~/.local/state/omarchy/agent-local/catalog/`: `repo.git` is the bare fetched repository, `trees/<commit>/` contains archived trees, and `state.json` records `current`, `url`, `trust` and `fetched_at`. Archives are extracted with Python's `data` filter through a `.partial` directory and renamed. Git runs without system/global config, hooks, credential helpers or interactive authentication; file transport is permitted for local development repositories.

`use` and normal `list` refresh after four hours, on a changed URL/trust setting, for a pin, or without a current catalog. Hidden `refresh` forces a refresh; the update hook invokes it. `list --offline`, `status`, the menu and panel do not fetch. Ref and signer changes alone do not trigger the source-changed branch of the freshness check.

Acceptance proceeds as follows:

1. Fetch the configured ref to `refs/omarchy/fetched`, or fetch an explicit 40-hex commit from `--catalog` or `ref`.
2. Require the object to be a commit and verify its SSH signature unless trust is `unsigned-dev`.
3. Unless pinned or URL/trust changed, require the candidate to descend from the accepted commit.
4. Export the tree and validate schema, runtimes, recipes and recommendations. Only then advance `current`.
5. Apply whole-file user overrides from `~/.config/omarchy/agent-local/{recipes,runtimes}/<id>.toml` and validate them on the ordinary non-pinned refresh return path. Overrides are recorded in manifests and recipe overrides marked in listings. There is no user `best.toml` override.

Fetch failure keeps an existing cached catalog with a note. Verification, ancestry or validation failure keeps the previous catalog when it is the same source and the request is not pinned; otherwise it raises. Explicit pins bypass ancestry and return the chosen catalog without replacing `current`, though they update `fetched_at`. Cached reads do not reverify signatures. `cached_catalog()` applies overrides without revalidating, and the pinned return path also omits validation after applying overrides; accepted base trees are validated before overrides in both cases.

## Catalog formats and examples

Recipe and runtime ids are filename stems matching `^[a-z0-9]+([.-][a-z0-9]+)*$`. Recipes require `name`, `summary`, a known runtime, at least one hardware entry, artifact and variant. Hardware entries require GPU family, one allowed RAM class and a relative measurement-file path; platform is optional. Validation checks that the measurement file exists, not its contents or whether the measurement was taken on the claimed hardware.

Artifacts specify a Hugging Face `owner/name`, 40-hex revision, license string and relative file patterns. Optional `dest` prefixes the full repository path; `model` and `draft` identify unique role files and must match their artifact's patterns. Paths reject absolute paths, empty components, `.` and `..`. Variants require a positive integer `ctx` and positive `peak_ram_gib` and `peak_gpu_gib`; `pins_memory` is accepted metadata but has no effect on memory accounting. Sampling accepts numeric temperature, top_p and top_k; unmapped sampling inputs are skipped with a note during `use`. `[server].args` supplies extra argv subject to reserved-name checks.

These two recipe files are copied from the catalog checkout:

### `recipes/qwen3.8-flash-next-halogen.toml`

```toml
name = "Qwen3.8 Flash Next"
summary = "125B MoE, ~6B active, 4-bit, MTP drafting on halogen. Fastest long-context agent turns on Strix Halo."
runtime = "halogen"

[[hardware]]
gpu = "amd-strix-halo"
ram_class = 128
measured = "measurements/qwen3.8-flash-next-halogen-strix-halo-128.toml"

[[artifacts]]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "766911a6b7369840a91dbcd95f9f997acaab6cd6"
license = "other (Qwen3.8-Flash-Next model license, see the model card)"
files = ["UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-0000?-of-00003.gguf"]
model = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
license = "apache-2.0 (derived from Qwen3.8-Flash-Next; upstream terms govern)"
files = ["qwen38-flash-next-mtp.hgn", "tokenizer/*"]
dest = "UD-IQ4_XS"
draft = "qwen38-flash-next-mtp.hgn"

[[variant]]
ctx = 131072
peak_ram_gib = 92
peak_gpu_gib = 22
pins_memory = true

[sampling]
temperature = 1.0
top_p = 0.95
top_k = 20
```

### `recipes/qwen3.8-27b-gufo.toml`

```toml
name = "Qwen3.8 27B"
summary = "27B dense, 8-bit, DFlash2 drafting on Gufo (open source). Higher precision, smaller footprint."
runtime = "gufo"

[[hardware]]
gpu = "amd-strix-halo"
ram_class = 128
measured = "measurements/qwen3.8-27b-gufo-strix-halo-128.toml"

[[artifacts]]
repo = "unsloth/Qwen3.8-27B-GGUF"
revision = "4ca720788d1e01f1bff70c033e0d0028fd02e502"
license = "apache-2.0"
files = ["Qwen3.8-27B-UD-Q8_K_XL.gguf"]
model = "Qwen3.8-27B-UD-Q8_K_XL.gguf"

[[artifacts]]
repo = "z-lab/Qwen3.8-27B-DFlash2-GGUF"
revision = "2d9571f8ce46e151f61c6499c99dee6079e1d610"
license = "apache-2.0"
files = ["Qwen3.8-27B-DFlash2-Q4_K_M.gguf"]
draft = "Qwen3.8-27B-DFlash2-Q4_K_M.gguf"

[[variant]]
ctx = 131072
peak_ram_gib = 48
peak_gpu_gib = 44

[sampling]
temperature = 1.0
top_p = 0.95
top_k = 20

[server]
args = ["--speculative", "dflash2", "--cache-ram-bytes", "4294967296"]
```

Runtime definitions pin an image, identify `omarchy` or `third-party` tier, declare the container port and health path/probe, and map standard inputs. `command` is optional (halogen uses the image's default entrypoint). `health.path` is validated but probes use the explicit `health.probe` argv; the host post-start check always uses `/v1/models`.

### `runtimes/halogen.toml`

```toml
# halogen: a closed-source Strix Halo engine for Qwen3.8 Flash Next. Configured by environment.
image = "ghcr.io/peonist-ai/halogen-flash-server@sha256:273714ccb64dabb7fac0418ee1b6dd83eb57d2fd44cf286eb68a7c694a27c203"
tier = "third-party"
review = "reviews/halogen-273714ccb64d.toml"
port = 8731
health = { path = "/health", probe = ["/usr/local/bin/python3", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8731/health', timeout=4)"] }
run = { devices = ["render", "kfd"], group_add = "keep-groups", memlock = "unlimited" }
reserved = ["HALOGEN_API_KEY", "HALOGEN_API_KEY_FILE", "HALOGEN_DOWNLOAD", "HALOGEN_BIND", "HALOGEN_PORT", "HALOGEN_API_PORT", "HALOGEN_GGUF_CACHE"]

[inputs]
model = { env = "HALOGEN_CHECKPOINT" }
draft = { env = "HALOGEN_MTP_HEAD" }
ctx = { env = "HALOGEN_CTX" }
alias = { env = "HALOGEN_MODEL_ID" }
key = { env = "HALOGEN_API_KEY" }
```

### `runtimes/gufo.toml`

```toml
# Gufo: the open-source (MIT) Strix Halo engine. Configured by arguments to `gufo serve llm`.
# It takes its key only as --api-key, so Omarchy substitutes it inside the container from the
# Podman secret; the key never reaches the unit file but is visible in the process list.
# Upstream request: an --api-key-file option or environment variable.
image = "ghcr.io/gufo-org/toolboxes/gufo-runtime@sha256:ec8c3f0bf06100304f5105590cfe98d62bf21ff133e8c2dea95955eb4028ddb2"
tier = "third-party"
review = "reviews/gufo-ec8c3f0bf061.toml"
port = 8080
command = ["gufo", "serve", "llm", "--host", "0.0.0.0", "--port", "8080"]
shell = "/bin/bash"
key_on_cmdline = true
health = { path = "/ready", probe = ["/bin/sh", "-c", "curl -fsS -o /dev/null -H \"Authorization: Bearer $OMARCHY_LOCAL_KEY\" http://127.0.0.1:8080/ready"] }
run = { devices = ["render", "kfd"], group_add = "keep-groups", memlock = "unlimited" }
reserved = ["--api-key", "--host", "-i", "--port", "-p", "--trace", "--cache-disk"]

[inputs]
model = { arg = "--model" }
draft = { arg = "--dflash-model" }
ctx = { arg = "--context" }
alias = { arg = "--served-model-name" }
key = { arg = "--api-key" }
temperature = { arg = "--temperature" }
top_p = { arg = "--top-p" }
top_k = { arg = "--top-k" }
```

### Review records

Third-party runtimes require a review file whose `image` exactly equals the runtime digest and whose `publisher`, `reviewer`, `date`, `license_url`, `license_sha256` and `checked` are nonempty. The validator does not fetch the license or verify its recorded hash. Source availability, version and behavioral statements are review evidence rather than runtime enforcement. Both current runtimes are third-party, including MIT-licensed Gufo.

`reviews/halogen-273714ccb64d.toml`:

```toml
image = "ghcr.io/peonist-ai/halogen-flash-server@sha256:273714ccb64dabb7fac0418ee1b6dd83eb57d2fd44cf286eb68a7c694a27c203"
publisher = "Peonist, LLC"
reviewer = "David Heinemeier Hansson"
date = "2026-11-01"
version = "0.18.22"
source = "closed"
license_url = "https://raw.githubusercontent.com/peonist-ai/halogen-flash-server/d64a2330f3f48ff0a447f3b03bddbe389fded982/LICENSE.md"
license_sha256 = "58f970ff94fb67d41146f1551a83fb208b5aee4d087224e2097b92850404f53b"
checked = [
  "license: free, perpetual, royalty-free use for any purpose including commercial; unmodified redistribution allowed with notices",
  "license: benchmarking and publishing results expressly permitted",
  "publisher statement: no telemetry, no license checks, no network calls unless HALOGEN_DOWNLOAD is set (recorded as a statement; the internal network enforces it)",
  "acceptance: starts and serves on the internal network with outbound connections failing, private IPC, read-only root, all capabilities dropped",
  "acceptance: rejects requests without the key on /v1/models; /health is open by design",
]
```

`reviews/gufo-ec8c3f0bf061.toml`:

```toml
image = "ghcr.io/gufo-org/toolboxes/gufo-runtime@sha256:ec8c3f0bf06100304f5105590cfe98d62bf21ff133e8c2dea95955eb4028ddb2"
publisher = "gufo-org"
reviewer = "David Heinemeier Hansson"
date = "2026-11-01"
version = "0.23.0 (1fafd5a)"
source = "open (MIT), https://github.com/gufo-org/gufo"
license_url = "https://raw.githubusercontent.com/gufo-org/gufo/8fec1ce96bffc728e03a9e271e787cef4a48bbda/LICENSE"
license_sha256 = "dc53ee4f56ce33a1587e64df04b0d9ace8abd3e875e2b00f6f9f292405bf1001"
checked = [
  "license: MIT for Gufo's code; adapted code and dependencies keep their notices",
  "behavior: loads models from local paths only; fetches client-supplied image URLs, which the internal network blocks",
  "auth: --api-key covers every route including health and readiness",
  "caveat: the key is a command-line argument, visible in the process list",
]
```

### Measurement records

`bench` warms up once, then streams a short prompt and the catalog's `bench/context.txt` plus a question (roughly 32K tokens), at temperature zero, thinking disabled and up to 512 output tokens. It records catalog commit, image, context, machine, load-time memory delta and duration, minimum available RAM sampled every 0.5 seconds, artifact hashes, and short/long timing and token rates. First-token time includes prefill; prefill rate is prompt tokens divided by that time. Decode uses completion tokens minus one over the remaining time, falling back to counted content chunks when usage is absent. It writes TOML to `--output` or prints it. This is a benchmark sampler, not a persistent desktop poller.

The halogen record below is copied in full. Gufo's current record is provisional publisher data for a different quant, not a local measurement of the Q8 recipe; file-existence validation still permits it.

### `measurements/qwen3.8-flash-next-halogen-strix-halo-128.toml`

```toml
recipe = "qwen3.8-flash-next-halogen"
measured_at = "2026-11-01"
catalog_commit = "106b9463be3f1608922eb486de16fd72566f19e8"
image = "ghcr.io/peonist-ai/halogen-flash-server@sha256:273714ccb64dabb7fac0418ee1b6dd83eb57d2fd44cf286eb68a7c694a27c203"
ctx = 131072
load_seconds = 122.0
method = "omarchy agent local bench: 1 warmup, then short and ~32K-token prompts from the catalog's bench/context.txt, temperature 0, enable_thinking false, 512 tokens out, streamed"

[machine]
platform = "x86"
gpu = "amd-strix-halo"
ram_class = 128
kernel = "7.2.14-1-omarchy"
cpu = "AMD RYZEN AI MAX+ PRO 395 w/ Radeon 8060S"

[memory]
observed_at_load_gib = 93.3
min_available_during_bench_gib = 20.5
total_gib = 125.1

[short]
prompt_tokens = 41
completion_tokens = 54
ttft_s = 0.51
prefill_tok_s = 80.0
decode_tok_s = 61.6
total_s = 1.37

[long]
prompt_tokens = 31705
completion_tokens = 512
ttft_s = 19.34
prefill_tok_s = 1639.2
decode_tok_s = 38.3
total_s = 32.69

[[artifacts]]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "766911a6b7369840a91dbcd95f9f997acaab6cd6"
path = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00001-of-00003.gguf"
sha256 = "5ce89370720f8bf90890f439361282104c1aa1482d4013bb9a50923e758e71a4"

[[artifacts]]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "766911a6b7369840a91dbcd95f9f997acaab6cd6"
path = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00002-of-00003.gguf"
sha256 = "577a38a2392b40ca2193cea502e1d92f60b8cd370675d308e0ec21885d9daaa7"

[[artifacts]]
repo = "unsloth/Qwen3.8-Flash-Next-GGUF"
revision = "766911a6b7369840a91dbcd95f9f997acaab6cd6"
path = "UD-IQ4_XS/Qwen3.8-Flash-Next-UD-IQ4_XS-00003-of-00003.gguf"
sha256 = "d4634e6d84f0ebb0940be15c90d3790bf6464e3dea3a1cddc567dc0e83ad8833"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "qwen38-flash-next-mtp.hgn"
sha256 = "0f50e9626df98168e7c6e0cc264e2a92b5184dd885a175a06628d979b5edceeb"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "tokenizer/chat_template.jinja"
git_oid = "c0c686f9c38d70d179fb7b5f5aa7530bc913dda3"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "tokenizer/generation_config.json"
git_oid = "023756cfadf88e5bf69eefeee3e172f38c448d64"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "tokenizer/merges.txt"
git_oid = "a494e019ca1502219fd0128658b979e5f05ae8e8"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "tokenizer/tokenizer.json"
sha256 = "0997f410c57a1f4e53b09e4be8f4a172d90edd9564368fb0847030937229b9f3"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "tokenizer/tokenizer_config.json"
git_oid = "5de744b3fca2129d7186979ae47c06be33903243"

[[artifacts]]
repo = "peonist-ai/halogen-qwen3.8-flash-next"
revision = "195697374b375f2133b2a61dc113e37b4b905ac6"
path = "tokenizer/vocab.json"
git_oid = "0aa0ce0658d60ac4a5d609f4eadb0e8e43514176"
```

### `measurements/qwen3.8-27b-gufo-strix-halo-128.toml`

```toml
recipe = "qwen3.8-27b-gufo"
status = "provisional: Gufo's published figures for Q4_K_XL; replace with `omarchy agent local bench` output for this recipe (Q8_K_XL)"
source = "https://github.com/gufo-org/gufo (README, 0.23.0)"

[machine]
gpu = "amd-strix-halo"
ram_class = 128

[published]
quant = "UD-Q4_K_XL"
prefill_tok_s = 648.89
decode_tok_s = 71.55
```

### `best.toml`

```toml
# The recommendation per hardware class, in order. `use best` picks the first recipe in the
# matching class that fits the machine; later entries are fallbacks for static reasons only.
# A recipe may be listed only for classes it has a measurement record for.

[[class]]
gpu = "amd-strix-halo"
ram_class = 128
recipes = ["qwen3.8-flash-next-halogen", "qwen3.8-27b-gufo"]
```

`best.toml` requires nonempty classes with an allowed RAM class, GPU or platform selector, and ordered recipe ids. Duplicate selector triples are rejected. Every recommended recipe needs a matching hardware declaration; this check does not parse measurement records. Runtime resolution catches equally ranked matching classes.

## Machine profile and best resolution

`machine_profile()` reads `MemTotal` from `/proc/meminfo`, asks `omarchy-hw-platform` for the platform (falling back to `x86` on failure or empty output), and discovers AMD GPUs through KFD topology `properties`. It converts `gfx_target_version` into a gfx name: `gfx1151` maps to `amd-strix-halo`, `gfx1150` to `amd-strix-point`, and other targets to `amd-<gfx>`. `drm_render_minor` selects `/dev/dri/renderD<minor>`; DRM sysfs supplies VRAM and GTT totals. Addressable memory is their sum, rounded to two decimals; VRAM below 4 GiB marks a GPU unified. Platform `aarch64-gb10` adds an NVIDIA GB10 unified GPU with installed RAM as addressable memory. There is no general NVIDIA discovery path.

RAM class rounds the unrounded installed GiB upward to 32, 64, 96, 128, 192, 256 or 512; values above 512 also return 512. The stored RAM amount is rounded to two decimals. Without `--gpu`, select the GPU with most addressable memory; equal maxima across different families require explicit selection. Within one family, including `--gpu <family>`, the largest GPU wins and a tie uses the first discovered.

1. Match exact RAM class and every specified GPU/platform selector. Rank by `(has_gpu, number_of_gpu_and_platform_selectors)`, descending: GPU+platform beats GPU-only, which beats platform-only. A tie for highest rank raises an ambiguity error.
2. Walk that class's recipes in order. AMD rejects runtimes requesting NVIDIA CDI; NVIDIA rejects render/KFD runtimes. Require a measured hardware declaration matching GPU family and RAM class, with absent or matching platform.
3. Sort variants by descending context. Choose the first whose GPU peak fits addressable memory and whose RAM peak plus the 8 GiB desktop reserve fits installed RAM. `--ctx` requires an exact declared context; a recipe without that context raises immediately rather than falling through to the next recipe.
4. For ordinary static incompatibility or no fitting variant, try the next recipe and report skipped reasons. There is no fallback to another class. Without a class, report the profile and recipes declaring the same GPU family.
5. After downloads and image preparation, stop the old model and check current headroom, up to 15 checks one second apart. RAM is raw `MemAvailable`; GPU free memory is total VRAM+GTT minus both used counters (or the profile's capacity when no sysfs path exists). Require RAM peak plus 8 GiB and the GPU peak. Failure names the three largest RSS processes and restores the old unit; it never selects a lower recommendation because memory is busy.

A named recipe normally uses the same compatibility checks. `--unqualified` can bypass qualification or runtime-support rejection but still requires static variant fit. Manifest replay validates its embedded recipe/runtime, reuses its files, roles and variant, and selects a GPU from the current profile; it does not redo catalog resolution, static fit or hardware qualification. Preflight and live headroom still run.

## Artifacts and storage

Hugging Face tree metadata at each pinned revision expands the file patterns. Each manifest file record contains repo, revision, original path, destination, size, license and either LFS `sha256` or regular-file `git_oid`. Git blob verification uses SHA-1 over `blob <size>\0` followed by contents, not SHA-1 of contents alone. Each pattern must match; unsafe returned paths and conflicting destinations are refused. Repeated destinations from the same repo/path are deduplicated.

The content-addressed store is `~/.local/share/omarchy/agent-local/blobs/{sha256,git}/<hash>`. Recipe trees under `models/<recipe>/` hard-link blobs into their expected paths. Existing blobs are reused by presence without rehashing. `--seed <directory>` verifies candidate files at their destination paths, then hard-links them into the blob store or copies across filesystems; a bad seed falls back to download.

Missing downloads require their full combined size plus 2 GiB free disk space. Four workers download into `staging/<hash>.part`, resuming with HTTP Range, restarting if a server ignores Range, and retrying up to five attempts. Size and hash must match before atomic rename into the blob store. Failed hashes are discarded. Existing staging sizes are not subtracted from the free-space requirement. Credentials come from `HF_TOKEN` or `~/.cache/huggingface/token` for Hugging Face access.

Materialization replaces obsolete links in the recipe directory. `remove <recipe>` refuses a running active recipe; otherwise it removes that recipe's tree and run records, deletes blobs whose only remaining link is the store entry, and tries to remove images no surviving run record names. Removing the active stopped recipe also removes its container unit and active manifest. It keeps the network unit, key and secret; it refreshes the list cache and rewrites `status.json`.

## Generated units and lifecycle

The following files were read from `~/.config/containers/systemd/` on this machine, without regenerating or editing them. This Gufo example has autostart off.

### `omarchy-agent-local.network`

```ini
[Quadlet]
DefaultDependencies=false

[Network]
NetworkName=omarchy-agent-local
Internal=true
```

`[Quadlet] DefaultDependencies=false` (in both files) drops Quadlet's default ordering after `podman-user-wait-network-online.service`. These units have no outside network to wait for, and on machines where the system's `network-online.target` never arrives every start otherwise sat out that service's 90-second timeout first.

### `omarchy-agent-local.container`

```ini
# Generated by omarchy-agent-local-use; changes are overwritten.
[Unit]
Description=Omarchy local model qwen3.8-27b-gufo
PartOf=graphical-session.target
After=graphical-session.target
StartLimitIntervalSec=10m
StartLimitBurst=3

[Quadlet]
DefaultDependencies=false

[Container]
ContainerName=omarchy-agent-local
Image=ghcr.io/gufo-org/toolboxes/gufo-runtime@sha256:ec8c3f0bf06100304f5105590cfe98d62bf21ff133e8c2dea95955eb4028ddb2
Label=org.omarchy.agent-local.recipe=qwen3.8-27b-gufo
Network=omarchy-agent-local.network
PublishPort=127.0.0.1:11435:8080
Volume=%h/.local/share/omarchy/agent-local/models/qwen3.8-27b-gufo:/models:ro
Secret=omarchy-agent-local-key,type=env,target=OMARCHY_LOCAL_KEY
AddDevice=/dev/dri/renderD128
AddDevice=/dev/kfd
GroupAdd=keep-groups
Ulimit=memlock=-1:-1
ReadOnly=true
DropCapability=all
NoNewPrivileges=true
Entrypoint=/bin/bash
Exec="-c" "a=(); for x in \"$$@\"; do [[ $$x == @OMARCHY_LOCAL_KEY@ ]] && x=$$OMARCHY_LOCAL_KEY; a+=(\"$$x\"); done; exec \"$${a[@]}\"" "omarchy-local" "gufo" "serve" "llm" "--host" "0.0.0.0" "--port" "8080" "--model" "/models/Qwen3.8-27B-UD-Q8_K_XL.gguf" "--dflash-model" "/models/Qwen3.8-27B-DFlash2-Q4_K_M.gguf" "--context" "131072" "--served-model-name" "qwen3.8-27b-gufo" "--api-key" "@OMARCHY_LOCAL_KEY@" "--temperature" "1" "--top-p" "0.95" "--top-k" "20" "--speculative" "dflash2" "--cache-ram-bytes" "4294967296"
HealthStartupCmd=["/bin/sh", "-c", "curl -fsS -o /dev/null -H \"Authorization: Bearer $$OMARCHY_LOCAL_KEY\" http://127.0.0.1:8080/ready"]
HealthStartupInterval=2s
HealthStartupRetries=300
HealthStartupSuccess=1
HealthCmd=["/bin/sh", "-c", "curl -fsS -o /dev/null -H \"Authorization: Bearer $$OMARCHY_LOCAL_KEY\" http://127.0.0.1:8080/ready"]
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
ExecStartPost=-omarchy-agent-local-status --write
ExecStopPost=-omarchy-agent-local-status --write
```

`write_unit_files()` writes both Quadlets and reloads the user manager. `Notify=healthy` keeps activation pending until the container health check passes. While loading, a startup check runs the same probe every 2 seconds (up to 300 tries, the ten-minute load budget), so the unit goes active within seconds of the model being ready rather than at the first 30-second regular probe: Gufo's 27B goes from start to active in about 6 seconds. Once it passes, regular probes run every 30 seconds, time out after five seconds, allow three failures and have a ten-minute startup grace period. Startup times out at twelve minutes. Health failure kills the container; systemd restarts failures after ten seconds, with three starts allowed per ten minutes. Logs are available through `journalctl --user -u omarchy-agent-local`.

`ExecStartPost` and `ExecStopPost` invoke `status --write` with failure ignored. These hooks update the panel on starts, stops and crashes without a shell polling timer; intermediate systemd states are not continuously observed. The start hook runs before the first successful `use` saves its new active manifest, so `use` writes status again after saving it.

Switching holds an advisory flock in the state directory. Downloads and image preparation precede stopping the old model. Activation remembers the previous container text and whether it was running, stops it with a warning that requests are interrupted, checks headroom, writes the new unit, resets failures, starts and verifies auth/model id. On handled startup or headroom failure it stops the candidate, restores the previous unit and restarts it if necessary. A successful run records observed load duration and before/after memory deltas, then saves manifests. `stop` keeps the configured recipe and downloads.

`PartOf=graphical-session.target` stops the model at logout. Autostart defaults off; `autostart on|off` creates/removes the state flag and regenerates the active container with or without `[Install]` / `WantedBy=graphical-session.target`. Quadlet applies this at generation time; `systemctl enable` is not the setting. Starting directly from the panel or via systemctl runs the generated unit and health checks, but does not run the Python activation headroom or post-start auth checks again.

## State files and clients

Paths below are relative to `~/.local/state/omarchy/agent-local/`. These lifecycle paths use the home directory directly, independently of XDG state overrides used by usage collectors. JSON writes use a temporary file and atomic replacement.

| File | Writer | Readers and contents |
|---|---|---|
| `status.json` | `status --write` hooks, successful `use`, `stop`, `autostart`, `refresh`, `remove` | `Main.qml` FileView watches it and feeds `Panel.qml`; unit/substate/result, endpoint, active recipe/runtime/image/context, catalog commits/age, autostart, best and observed load data |
| `list.json` | `list`, successful `use`, `refresh`, `remove` | Menu provider; recipe id/name/summary/runtime/tier/publisher, static availability/reason, best/active/override markers |
| `profile.json` | `profile`, `list`, `use` | Persisted platform/RAM/GPU diagnostic snapshot; the current menu reads list cache instead, and commands recompute profiles |
| `active.json` | `save_run()` after successful `use`; removed when removing that stopped recipe | Lifecycle commands, overlay and benchmark; full resolved manifest, not a symlink |
| `runs/<YYYYMMDDTHHMMSS>-<recipe>.json` | `save_run()` | `use --manifest`, removal/image retention and reproducibility; schema, catalog provenance/overrides, recipe/runtime copies, profile/GPU, variant, image, artifact files/roles, launch argv/env placeholders, creation time and observed load data |
| `autostart` | `autostart on|off` | Generator and status; existence is the enabled flag |
| `lock` | `use`, `autostart`, `remove` | Advisory mutation serialization; refresh, list and stop do not acquire it |

`status` without `--write` queries systemd and prints a fresh record but does not update `status.json`. `refresh` (including the one `omarchy update` runs) and `remove` rewrite it too, so a recommendation change or a removed recipe reaches the panel without waiting for the next start or stop. The FileView retains its last valid record on missing or invalid content and accepts only active, activating, inactive, failed and deactivating unit states.

OpenCode local launches generate `~/.config/omarchy/agent-local/opencode.json` with provider `llamacpp`, npm adapter `@ai-sdk/openai-compatible`, the loopback base URL, a `{file:<absolute-key-path>}` reference, and the active recipe's context limit (output limit 16384). `omarchy-agent` sets `OPENCODE_CONFIG` and passes `--model llamacpp/<recipe>`. It requires an active manifest and active/activating/reloading unit; it does not change the default agent or rewrite that agent's own settings. Other default agents currently fail with an unsupported-overlay message. Usage under `llamacpp` belongs to the `local` collector, independently of this lifecycle state.

## Tests

`test/shell.d/agent-local-test.sh` uses temporary home directories and fixtures. It covers recipe/runtime ids, reserved and conflicting mappings, forbidden run options, argument-key opt-in, path traversal and duplicate roles; recommendation qualification, duplicate selectors, ranking, ambiguity, largest fitting context, static fallback and multi-GPU ties; RAM/GPU capacity and busy-memory diagnostics; Hugging Face manifest expansion, destination conflicts and Git blob integrity; benchmark-shaped TOML round trips; hostile argv/environment/probe values through unit serialization; and local Git repositories exercising unsigned-dev, allowed SSH signatures, unknown/unsigned tips, invalid schema and rollback refusal without advancing current.

When installed, the real Podman Quadlet generator parses the fixture units in dry-run mode, checking restrictions, loopback publication and argument preservation; otherwise that part skips. This test does not start a model, test container egress, exercise transactional rollback/auth checks end to end, verify sysfs discovery, or test overlays. Menu and panel integration also have assertions in their existing area tests. Documentation-only edits do not require running these suites.

## Differs from the plan

- The panel watches `status.json` written by command and unit hooks, rather than subscribing to systemd D-Bus `PropertiesChanged`. It appears only after a recipe is configured, not as a pre-setup lifecycle card. Intermediate states and recommendation changes can remain absent or stale until a write.
- `status` never refreshes the catalog. The migration installs Podman/crun only; it does not populate profile or compatibility caches. The menu consumes prepared `list.json`, rather than combining a cached catalog and profile. Provider rows carry a fifth unavailable-reason field rather than an explicit availability flag.
- Headroom uses raw `MemAvailable` without subtracting locked/unevictable memory; `pins_memory` is informational. GPU free memory subtracts used VRAM and GTT from their combined total. The real recipe field is `peak_ram_gib`, not the proposal example's `peak_host_gib`.
- GPU preflight checks subordinate-ID entries and the invoking user's device access only. It does not start a throwaway container, inspect the user manager's group access, or configure groups/CDI; no privileged GPU setup command exists here.
- The official allowed-signers file currently has no keys. Image digest pinning is implemented, but publisher image-signature verification and the Omarchy-tier image build pipeline are not. Cached catalogs are not reverified; pinned catalogs bypass ancestry, and override validation has the gaps described above.
- Post-start auth accepts 401 or 403 and checks only `/v1/models`. It runs during `use`, not every systemd restart, and is not a full route or network-egress test.
- Manifests are timestamped JSON files plus a copied `active.json`, not TOML plus an active pointer. Replay uses the current GPU profile and embedded resolution without repeating static compatibility checks.
- `bench`, `remove`, panel controls and the menu provider are already implemented despite their phase-2 placement. The second recipe is open-source Gufo with Qwen3.8 27B, not a llama.cpp Flash Next fallback. Gufo's measurement is explicitly provisional publisher data for a different quant; validation checks measurement existence, not its evidence.
- Missing exact `--ctx` variants raise before trying later recommendations. General equally ranked class ambiguity is detected during resolution, while validation rejects identical selector triples only. Unmapped sampling defaults are reported during `use`, not in `status`.
- Existing blobs are reused without rehashing; artifact integrity includes Git blob OIDs for non-LFS files, rather than SHA-256 for every file. The focused suite covers validation, resolution, hashing, serialization and catalog trust, but not the proposed disposable-VM lifecycle/egress checks, rollback integration, locked-memory accounting or overlay generation.
