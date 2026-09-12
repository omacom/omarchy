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
- **Period** — Day, Week, Month, or Total. Week is the default (last seven days). Total keeps the all-time model breakdown and does not reset with a quota window. `1`/`d`, `2`/`w`, `3`/`m`, `4`/`t` switch the filter.
- **Tokens by day** — one row per day in the selected period: day, bar, tokens, with today
  bolded at the bottom. Hover today for its prompt and session count. Hidden on Total, and on a harness that has no token history for the window.
- **Tokens by model** — tokens per model with the bar behind each row scaled
  to the heaviest model,
  the same way the weekly chart scales to its busiest day. Hover for the
  input / output / cache split.
- **All** — a first chip that sums every enabled harness: tokens by day and by model across Claude Code, Codex, Fireworks, Antigravity, Hermes, Grok, Cursor, OpenCode, Devin, and any other record that appears. Rate limits stay per-account and are not merged. Day / Week / Month never fall back to all-time or billing-cycle `modelUsage`, and leftover `today*` fields from a file that stopped being rewritten are not painted as calendar today.

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
| `antigravity` | `agy -p /usage --output-format json` (Gemini and Claude/GPT-OSS session + weekly pools) | `~/.gemini/antigravity-cli` `history.jsonl` and `conversation_summaries.db` |
| `hermes` | none (bring-your-own providers) | `~/.hermes/state.db` (`HERMES_HOME`), including `profiles/*/state.db` |
| `grok` | SuperGrok weekly pool via Grok ACP `_x.ai/billing` | `$GROK_HOME/sessions` (default `~/.grok/sessions`), plus pi/omp and opencode turns on an xAI provider |
| `cursor` | Plan & Usage meters from the same display sentences Cursor Settings shows (Cursor Models / Other Models). A prepaid balance appears only when `spendLimitUsage` has a real remaining + limit — Ultra's included cents are not a wallet | GetCurrentPeriodUsage / GetPlanInfo / GetAggregatedUsageEvents; optional local cloud-agent session count |
| `opencode` | none | completed assistant turns in `~/.local/share/opencode/opencode.db`, dated by the message clock — a missing stamp is dropped so old turns cannot land on today |
| `devin` | none | `~/.local/share/devin/cli/sessions.db` assistant `message_nodes`, deduplicated by `request_id` |

Claude limits need a signed-in CLI; without credentials the panel says so and
falls back to local stats only. A non-default Claude directory is honored via
`CLAUDE_CONFIG_DIR`, Codex via `CODEX_HOME`, Antigravity via
`ANTIGRAVITY_DATA_DIR`, Hermes via `HERMES_HOME`. Fireworks reads
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

### Antigravity quotas

The collector asks `agy` for the same `/usage` payload the CLI panel shows.
`agy` reports `remaining_fraction` (full → empty); the record inverts that to
percent-used so the meters climb toward 100% like Claude and Codex. Gemini
models share one session and one weekly pool; Claude and GPT-OSS share another.
A missing `agy` or a failed probe leaves the tab on local prompt counts only.

### Hermes tokens

Hermes has no account quota. The collector sums `session_model_usage` in
`~/.hermes/state.db` (and each `profiles/*/state.db`), skips archived sessions,
and folds reasoning tokens into output. Each API call is one prompt. An
optional `history` array on the record carries per-day model totals so Month
and Total can filter more than the last seven days.

### Cursor meters

Cursor Settings shows **Cursor Models** and **Other Models** as sentences
("You've used 1% of your included total usage"), not the raw
`autoPercentUsed` / `includedSpend` fractions. The collector parses those
display messages so the panel matches Plan & Usage. Ultra's
`includedAmountCents` is the plan allowance, not a prepaid pot — a balance
row appears only when `spendLimitUsage` has both `remaining` and `limit`.

### OpenCode dates

OpenCode stores turn timestamps in milliseconds on the message. A missing
stamp is dropped rather than dated as today, so a leftover `opencode.json`
from last week cannot mint a Today row of 500k tokens.

## Interactions

- Bar icon: left = panel, right = launch agent, middle = next subscription.
- Panel: `h`/`l` switch subscription, `j`/`k` scroll, `r` or Enter refresh,
  `1`/`d` Day, `2`/`w` Week, `3`/`m` Month, `4`/`t` Total,
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
  "fireworks": { "enabled": true },
  "antigravity": { "enabled": true },
  "hermes": { "enabled": true },
  "grok": { "enabled": true },
  "cursor": { "enabled": true },
  "opencode": { "enabled": true },
  "devin": { "enabled": true }
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

## Projects and live activity

The first navigation row contains All, Projetos and Tempo real. Provider tabs keep their quota meters and charts. Project and live views expand to at most 900 × 600 theme units, bounded by the monitor's available space.

Projetos groups usage by directory. Select a project to inspect its records. Tempo real shows today's latest records, with a pause control. Each page contains 25 records with time, project, agent, model, message preview and tokens. Select a row for details; closing the detail returns to the same list.

Previews come from the user messages already saved by each tool. The list reads up to 180 characters per record and the detail reads up to 1,200. The index stores message offsets, without copying conversation text. The tracking collector opens sources read-only and makes no network or model requests.

`bin/tracking.py` indexes appended JSONL bytes, reindexes replaced or truncated files, and scans SQLite metadata when its source changes. Unchanged files are skipped. Previews are read for the current page only and reused when several records refer to the same message. Detail reads do not scan the history.

Automatic refresh runs every 5 seconds in Tempo real and every 30 seconds in Projetos. It stops when these views close and respects pause. The local cache is `~/.local/state/omarchy/agents/tracking/ledger.sqlite`, created with mode 0600. Set `OMARCHY_TRACKING_STATE` to use a separate cache.

Sources are Codex, Claude, Grok, Hermes, OpenCode, Devin and local 9Router history. The collector does not capture every AI request on the computer. Codex prefers individual response usage records when present instead of adding quota counters again. Grok reports totals per turn. Hermes reports totals per session and model, dated by last activity, and previews the session's latest user message. Devin reads assistant `message_nodes` and deduplicates by `request_id`. The list and detail label these record types. Requests in progress may not have usage recorded yet. Sources currently use their default local storage paths.

Project attribution uses the session's directory. When Hermes omits it, the collector reads the initial working directory declared in its saved tool context. The detail shows the attribution source. Existing Git worktrees share their common repository root. Unknown directories appear as Sem projeto. Maestri workspace names are matched by directory; they do not establish which application initiated a call.

Token totals include input, output and cache, without counting cache already included in Codex or Grok input twice. They are not billing amounts. 9Router stays separate from the combined view to avoid counting requests already recorded by the tools. Message previews appear only when the source links a record to a message.

Run `python3 tests/test_tracking.py` from this directory, or `bash test/shell.d/agents-tracking-test.sh` from the repository root.

Run `python3 bin/benchmark-tracking.py --cold` here to build a disposable index, measure the first scan, five refreshes and one detail read, then remove the index. The September 6, 2026 measurement in `tests/benchmark-local.json` contains performance metrics only. Results depend on log volume and machine activity; the CPU percentage estimates one core from CPU time per refresh.
