# Agents

One bar icon and one panel for every AI coding subscription on the machine.
The panel is strictly a display: it watches the usage records that
`omarchy-agent-usage-update` writes to `~/.local/state/omarchy/agents/usage/`
and draws whatever appears there. `Panel.qml` owns the bar button and the
popup; `Main.qml` discovers and watches the records (and handles the optional
cross-device aggregation); `Agent.qml` is the per-record file watcher.

## Panel

- **Hero** — the mark, the tool, and the plan it runs on ("Max 20x", "Pro").
  Auth and endpoint problems replace the plan line and repeat in a card.
- **Subscription switch** — one chip per enabled agent (`h`/`l` or click).
  It appears only when more than one agent is enabled.
- **Limits** — the percentage of each allowance used, a matching meter, and
  the time until the session or weekly window resets.
- **Balance** — prepaid agents report a credit ledger instead of limits:
  remaining credit, a fuel-gauge meter that drains toward empty, and
  funded-versus-spent detail.
- **Tokens by day** — one row per day for the last week, with today bolded at the bottom. Local Codex, Claude, and Kimi rows append estimated API-equivalent USD cost when an exact tariff is available; hover a row for component prices, provenance, assumptions, and missing coverage.
- **Tokens by model** — providers without local pricing coverage retain their token-only model rows. Local Codex, Claude, and Kimi sources use 30-local-day buckets for one combined token/known-API-cost-estimate table: the four heaviest models followed by Today, 7 days, and 30 days summaries. Window totals include every model even when only four fit on screen. A visible note names excluded missing-price models when known; hover retains detailed priced-token coverage.

Token and cost values use fixed, right-aligned columns, including one- through five-digit amounts. The panel uses the height of the largest provider page so switching subscriptions does not resize it; scrolling is needed only when the available screen cannot fit that content. Usage records are parsed and compacted in a background worker, and tab labels never traverse the full usage history. Reopening within 15 seconds reuses the current refresh; an explicit refresh still requests fresh data.

A subscription appears only when it is enabled in settings and has actually
recorded usage — on this machine or on a synced one. With one such agent
there is no switch row at all; with none, the module leaves the bar entirely
rather than sitting there with nothing to say. A CLI installed mid-session
shows up at the next refresh, so nothing polls the disk waiting for it.

That self-hiding is why the widget ships in the default bar layout: a machine
that has never run an AI coding agent draws nothing, and the icon arrives on
its own the first time a scan finds usage. Drop it with
`omarchy plugin disable omarchy.agents`.

## Data

Each agent is one JSON record in `~/.local/state/omarchy/agents/usage/`,
written by `omarchy-agent-usage-update`. That command runs one
`omarchy-agent-usage-<agent>` collector per agent; the widget invokes it
on its refresh timer and whenever you ask for a refresh, and picks up any
record that lands in the directory regardless of who wrote it.

Adding an agent therefore never touches this plugin: ship a collector that
prints the record contract (see the `claude` and `codex` collectors in
`bin/`), and the panel gains a tab. An `assets/<id>.svg` mark is optional —
with an `assets/<id>-light.svg` twin if the mark needs a dark variant for
light surfaces — and the bar glyph stands in when there is none.

| Collector | Limits | Local stats |
|---|---|---|
| `claude` | Anthropic's OAuth usage endpoint (5-hour session + 7-day weekly) | `~/.claude/projects` transcripts, opencode sessions on an Anthropic provider, plus `stats-cache.json` and `history.jsonl` as fallback |
| `codex` | The Codex app-server RPC | native Codex CLI session files (plus pi and opencode sessions) |
| `fireworks` | Estimated prepaid balance: configured funding minus rated account costs | Fireworks billing API, grouped by day and model for the last 30 days |

## API-equivalent daily cost

Prices are maintained manually. Edit the JSON file below for local changes; maintain the bundled table and its source/date metadata in `ApiCost.js` when updating shipped defaults. No scraper, network price lookup, or background price import runs.

Kimi uses the same public `dailyUsage` formatter and 7-/30-day presentation as Codex and Claude. Pricing requires a recorded raw model and an exact user tariff; current Wire records provide no model, so their cost remains unknown even when manual rates exist, and no bundled alias is inferred.

Codex and Claude `dailyUsage` records use the shared public `ApiCost.js` interface to build the seven displayed calendar-day rows. Native Codex; Pi/OMP records whose provider equals `openai-codex` or whose API begins with `openai-codex`; and OpenCode records whose provider equals `openai` retain their source, literal raw model, local day, and independently measured token categories in that record. Native Claude transcripts, Pi/OMP records whose provider equals `anthropic`, and OpenCode records whose provider equals `anthropic` do the same. Claude stats-cache token totals remain visible but unpriced when category splits are absent; history message counts are prompts, never tokens. Each value keeps the existing token abbreviation and adds a no-space cost suffix: `2.4M/$8.20` for a known amount or known subtotal, or `2.4M/—` when no cost can be established. When any amount is incomplete, a visible note says costs exclude usage with missing prices or token details. A known zero tariff remains `$0.00`. Labels and token-based bars preserve the corresponding numeric `recentDays` total even when a bucket has only independently measured categories and a null total; `dailyUsage` then supplies the explicitly partial price rather than replacing or shrinking the visible consumption.

The daily heading says `API COST UNAVAILABLE` when every displayed cost is unknown, while retaining the token values and `/—` markers. A known zero or any known subtotal keeps the USD estimate heading.

Bundled rates are versioned fallback data, not a claim that they were confirmed today. The bundled catalog records the official OpenAI and Claude Platform source URLs, retrieval timestamps, SHA-256 values, and price dates. Claude's standard catalog uses exact published model IDs and the documented `claude-sonnet-4-5` alias. Missing cache-duration metadata is disclosed as a standard 5-minute-write estimate. Recognized 5-minute or 1-hour metadata prices the measured cache-write total at its matching rate; mixed writes require a complete numeric 5-minute/1-hour split that reconciles to that total. Missing, invalid, conflicting, or unknown duration evidence leaves cache-write money unknown. An exact manual cache-write rate remains authoritative for valid 1-hour and reconciled mixed usage, with that applicability assumption disclosed. Tooltips label results as API-equivalent estimates in USD rather than subscription bills and expose the effective tariff, source, price date, fallback or override origin, component costs, assumptions, and missing coverage.

Exact bundled model IDs, provider-documented exact aliases, and the provisional Guardian estimate below resolve. Similar prefixes and unknown suffixes remain unpriced. Missing request-level tariff/context metadata permits a disclosed standard short-context estimate; an observed processing mode without a validated applicable tariff makes its affected cost components unknown. Legacy-only and synchronized token totals have no matching versioned pricing scope in this ticket, so they retain their tokens and show unknown cost rather than reusing a local subtotal.

For `codex-auto-review`, the user explicitly chose a provisional GPT-5.4 API-equivalent estimate on 2026-09-10. OpenAI's [Auto-review article](https://alignment.openai.com/auto-review/) dated 2026-04-30 names GPT-5.4 Thinking (low reasoning); this is not proof of the current underlying or billed model. The [official GPT-5.4 model page](https://developers.openai.com/api/docs/models/gpt-5.4), verified via Firecrawl on 2026-09-10, lists standard rates of $2.50 input, $15 output and $0.25 cached input per million tokens. Cache-write pricing remains unknown (`null`). This uses the existing standard short-context estimate, not special-tier or long-context billing. Existing tooltip assumptions disclose the provisional mapping; recorded model IDs stay unchanged. Exact manual rates or aliases for `codex-auto-review` take precedence.

`~/.config/omarchy/agents/pricing.json` can replace or extend exact model rates and add exact aliases. The panel validates every edit and notices both later saves and a file first created after login without requiring a shell restart:

```json
{
  "models": {
    "gpt-6-astra": { "input": 10, "output": 50, "cacheRead": 1, "cacheWrite": 12.5 }
  },
  "aliases": {
    "my-exact-agent-id": "gpt-6-astra"
  }
}
```

Rates are USD per one million tokens and must be finite, nonnegative JSON numbers. Explicit `cacheRead` and `cacheWrite` values, including zero, win. If either cache field is omitted from an otherwise valid manual tariff, the documented compatibility assumptions are cache read at one tenth of manual input and cache write equal to manual input; the tooltip identifies each assumption. An explicitly invalid field rejects that manual tariff, leaving a valid bundled fallback available. There is no automatic price refresh or provider import. Saving this local file reprices existing usage; it does not modify session history.

Claude limits need a signed-in CLI; without credentials the panel says so and
falls back to local stats only. A non-default Claude directory is honored via
`CLAUDE_CONFIG_DIR`, Codex via `CODEX_HOME`. Fireworks reads
`FIREWORKS_API_KEY` and `FIREWORKS_ACCOUNT_ID` first, then
`~/.fireworks/auth.ini` (which `firectl set-api-key` creates), then the key
opencode stores in `~/.local/share/opencode/auth.json` when Fireworks is
signed in there.

### Fireworks balance

The collector first asks the account's `:getBalance` endpoint for the real
prepaid ledger. That endpoint exists but is permission-gated, and as of
August 2026 no console-issued API key passes it — Fireworks appears to
reserve it for the dashboard session. The probe stays because it is cheap
and the live figure lights up automatically if Fireworks ever opens it to
keys. Until then the collector falls back to estimating the balance from
configuration in `~/.config/omarchy/agents/fireworks.json`:

```json
{
  "accountId": "",
  "fundedAmount": 20,
  "fundedAt": "2026-07-01"
}
```

Set `fundedAmount` to the credits purchased and optionally `fundedAt` to the
purchase date; with no date, the collector uses the account creation time. It
subtracts rated account costs and the panel labels the result as estimated.
For a later top-up, increase `fundedAmount` by the new credit while keeping
the original `fundedAt`, so both the funding and spend still cover the same
period. `accountId` only matters when one API key can access several
accounts. Without a configured `fundedAmount` the tab still shows token
usage, just no balance. With a live ledger, `fundedAmount` is optional and
only adds the meter and the spent-of-funded line under the real figure.

## Interactions

- Bar icon: left = panel, right = launch agent, middle = next subscription.
- Panel: Tab/Shift+Tab moves to the neighboring bar panel. `j`/`k` or Up/Down move between the provider selector, computer selector, settings gear, and usage rows; they also move through the focused usage rows without trapping at either end. `h`/`l` or Left/Right change the focused provider or computer. Enter opens usage details, activates settings, or refreshes the overview elsewhere; `r` refreshes explicitly. Comma opens computer settings. Esc returns or closes.
- Computer settings: `j`/`k` select, `n` adds, `e` renames, and `x` removes with Enter confirmation. Text fields use normal typing and Tab navigation; Enter saves and Esc cancels. All management actions work without a mouse.
- IPC: `omarchy-shell omarchy.agents <open|close|toggle|refresh|next|machines>`. `machines` opens computer settings directly, including for a user whose bar icon is hidden because there is neither local usage nor a saved remote computer yet. Run it from a terminal for that first setup; it does not add a global shortcut.

## Settings

Settings live in the widget's entry in `~/.config/omarchy/shell.json`. The
top-level keys can be set with
`omarchy bar set omarchy.agents <key> <value>`:

| Key | Default | What it does |
|---|---|---|
| `refreshIntervalSec` | `900` | How often the usage records regenerate |
| `syncMode` | `"Off"` | `"On"` writes this machine's snapshot and merges the others |
| `syncDir` | `""` | A folder synced by Syncthing, Dropbox, rsync, … |
| `syncFileName` | `<hostname>.json` | This machine's snapshot file |
| `syncDeviceId` | hostname | Stable device name inside the snapshot |

Numbers need `--json`, or they land in `shell.json` as strings:

```bash
omarchy bar set omarchy.agents refreshIntervalSec 300 --json
omarchy bar set omarchy.agents syncDir '~/Sync/agent-usage'
```

Per-agent enablement is nested, and `set` writes its key literally rather
than walking a dotted path — so pass the whole `providers` object as JSON (or
edit `shell.json` directly):

```bash
omarchy bar set omarchy.agents providers '{
  "claude": { "enabled": true },
  "codex": { "enabled": false },
  "fireworks": { "enabled": true }
}' --json
```

`enabled` defaults to `true` for every discovered agent; set it to `false` to
hide a subscription that is installed. Disabled agents are also skipped when
the records regenerate.

With `syncMode` on, every `*.json` snapshot in `syncDir` is merged, so today,
the last 7 days, and the all-time totals cover every machine you code on —
active days are unioned by date rather than summed. Rate limits stay
per-account and are never merged. A record may declare `"scope": "account"`
when its stats are account-global rather than machine-local (Fireworks'
billing API); those merge by taking the widest value instead of summing, so
the same account synced from two machines is not counted twice.

One caveat on "all-time": the Codex collector only reads native session files
touched in the last 30 days, and Fireworks requests the last 30 days from its
billing API, so their totals and day counts cover that window. Claude's cover
every transcript still on disk.

## Remote computers

The computer selector shows **All**, **This computer**, and your saved computers. **All** includes local usage and the last successful imports from the saved computers. Selecting one computer filters the token and API-equivalent cost views; the provider selector still selects Codex, Claude, or Kimi. The selector scrolls horizontally when names do not fit and keeps the keyboard selection visible. Five or ten computers use the same panel layout.

Account limits and balances continue to describe the provider account signed in on this computer. They are separate from the computer usage filter and are never added together. “Session” in an existing limit meter means a provider allowance window, not one open agent conversation.

### Connect and manage

Use the gear button or press comma in the panel. Use j/k or the arrow keys to select a computer, n to add, e to rename, and x to remove. Tab and Shift+Tab move through the form; Enter saves or confirms removal, and Escape cancels the form or returns to the usage view. Connection failures leave the form open for correction and retry. The CLI manages the same list:

```bash
omarchy agent machine add workbox --label Laptop
omarchy agent machine list
omarchy agent machine list --json
omarchy agent machine rename <id> --label Workstation
omarchy agent machine remove <id>
omarchy agent machine refresh --force
```

Linux and macOS targets use their existing OpenSSH/SFTP service. First establish normal SSH access and trust the host key in a terminal, for example `ssh workbox`. SSH config aliases and `ssh://user@host:port` targets are supported. Background imports require authentication without a prompt, typically a key loaded in your SSH agent. Passwords and private keys are not stored in the machine list. Nothing is installed on the target: no Agents helper, daemon, scheduled task, or cache. A machine is saved only after its identity and connected user can be verified. The verified account name and platform are shown in the panel and in `list`. Adding another alias for that same machine/user, reusing a saved SSH target, or adding the already locally counted account is rejected. Different accounts on the same remote machine have separate contributions. Verification needs read-only shell commands (`uname`, `id`, and `cat /etc/machine-id` on Linux or `ioreg` on macOS) in addition to SFTP; an SFTP-only account cannot be added. No remote Python, Node, or Agents installation is needed.

Only usage belonging to the **connected SSH user account** is included. Other user accounts on that computer are not scanned. This is not system-wide accounting.

The first remote version reads native Codex, Claude, Kimi, and Pi/OMP JSONL files in their usual directories under the connected user's home. Custom source paths, symlinked source trees, and Claude aggregate-only fallback files are not imported by the current preview. Remote OpenCode scope is still undecided: the preview does not read its SQLite database and marks a detected database as an incomplete import; this is not a final scope decision. Local OpenCode support is unchanged.

Agent session data must have been created independently on each computer. **Session directories copied or synchronized between computers are not supported**, and their combined totals are not guaranteed to be correct. This is distinct from repeatedly importing the same computer: repeated reads and duplicate connections do not add its usage twice.

### Cache, freshness, and removal

All usage parsing, pricing, and caches live on the displaying computer. Identity commands read only OS/account information; the target never parses usage metadata for Agents. Imports read source metadata and new log sections over SFTP; unchanged files reuse the local cache. Transferred log sections can contain conversation text, but only selected usage metadata is retained locally. Source files must report changed sizes or modification times when edited; manually preserving both while changing file contents is not supported. Partial final log lines are retried after completion, and detected truncations or replacements trigger a replacement scan.

The plugin attempts an import on startup and approximately hourly. Opening the panel or changing tabs does not trigger an import. An explicit refresh requests one immediately. At most two computers import concurrently; each pass has a time limit and a 64 MiB log-data budget. A large first import may require several passes; “importing” means it is still incomplete. Source listing, file reads, SSH encryption, and transfer still use resources on the target; caching reduces repeated work but does not make the initial import free.

An unavailable computer keeps its last successful values and timestamp. Provider sources and collectors are tracked separately: a stale or unavailable part keeps its previous timestamp, and a successful sibling provider does not make that part look fresh. Every successfully verified source pass is current and advances its source timestamp even when its files are unchanged. The status, rather than file-change age alone, determines whether a part is stale.

A computer or provider with no successful contribution is shown as unknown data, not a verified zero. When part of a provider is unavailable, **All** and the individual computer view identify the incomplete coverage. Existing local or retained remote values remain visible as a known subtotal; an entirely unknown contribution does not create synthetic zero day rows. Removing a computer excludes its entire cached contribution from **All**, including historical usage. Remote files are never deleted. Local per-profile cache files are retained after removal and are not reused for a new profile.

Today, seven days, and thirty days use the displaying computer's timezone. Missing timestamps, unknown models, or incomplete token categories remain visible as coverage gaps. Costs use the displaying computer's current tariff table and overrides, never a sum of rounded remote prices.

Linux and macOS identity/transport contracts are covered by local automated tests using a real read-only OpenSSH SFTP server and synthetic SSH/OS responses. These tests do not verify a real macOS computer or a real SSH connection to another host. Hardware verification must check account identity, host-key trust, first import, duplicate aliases, and unchanged remote session files.

The machine list is in `~/.config/omarchy/agents/machines.json`; imported state is in `~/.local/state/omarchy/agents/remote/`; metadata and read-position caches are in `~/.cache/omarchy/agents/remote/`. The corresponding XDG directories are honored. The SSH view requires the existing shared-folder **Synced aggregation** setting to be Off; mixing two transports without equivalent device identities could double-count usage. Existing shared-folder sync remains available independently.
