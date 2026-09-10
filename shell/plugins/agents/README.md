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
- **Tokens by day** — one row per day for the last week, with today bolded at the bottom. Native local Codex rows append estimated API-equivalent USD cost to the token value; hover a row for component prices, provenance, assumptions, and missing coverage.
- **Tokens by model** — non-Codex providers retain their token-only model rows. Codex uses its native 30-local-day buckets for one combined token/known-API-cost-estimate table: the four heaviest models followed by Today, 7 days, and 30 days summaries. Window totals include every model even when only four fit on screen. A visible note names excluded missing-price models when known; hover retains detailed priced-token coverage.

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

Native Codex `dailyUsage` records use the shared public `ApiCost.js` interface to build the seven displayed calendar-day rows. Each value keeps the existing token abbreviation and adds a no-space cost suffix: `2.4M/$8.20` for a known amount or known subtotal, or `2.4M/—` when no cost can be established. When any amount is incomplete, a visible note says costs exclude usage with missing prices or token details. A known zero tariff remains `$0.00`. Labels and token-based bars preserve the corresponding numeric `recentDays` total even when one native bucket has only independently measured categories and a null total; `dailyUsage` then supplies the explicitly partial price rather than replacing or shrinking the visible consumption.

The daily heading says `API COST UNAVAILABLE` when every displayed cost is unknown, while retaining the token values and `/—` markers. A known zero or any known subtotal keeps the USD estimate heading.

Bundled rates are versioned fallback data, not a claim that they were confirmed today. The bundled catalog records the official OpenAI source URL, retrieval timestamp, SHA-256, and original price date. Its 2026-09-09 GPT-6 Astra standard short-context rates per one million tokens are $10 input, $50 output, $1 cache read, and $12.50 cache write. Tooltips label the result as an API-equivalent estimate in USD rather than a subscription bill and expose the effective tariff, source, price date, fallback or override origin, component costs, assumptions, and missing coverage.

Only exact bundled model IDs and provider-documented exact aliases resolve. Similar prefixes and unknown suffixes remain unpriced. Missing request-level tariff/context metadata permits a disclosed standard short-context estimate; an observed processing mode without a validated applicable tariff makes its affected cost components unknown. Legacy-only and synchronized token totals have no matching versioned pricing scope in this ticket, so they retain their tokens and show unknown cost rather than reusing a local subtotal.

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
- Panel: `h`/`l` switch subscription, `j`/`k` scroll, `r` or Enter refresh,
  Tab moves to the neighboring bar panel, Esc closes.
- IPC: `omarchy-shell omarchy.agents <open|close|toggle|refresh|next>`.

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
