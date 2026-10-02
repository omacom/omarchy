# Agents

One bar icon and one panel for every AI coding subscription on the machine.
The panel is strictly a display: it watches the usage records that
`omarchy-agent-usage-update` writes to `~/.local/state/omarchy/agents/usage/`
and draws whatever appears there. `Panel.qml` owns the bar button and the
popup; `Main.qml` discovers and watches the records (and handles the optional
cross-device aggregation); `Agent.qml` is the per-record file watcher.

## Panel

Every subscription on one page, limits first.

- **Hero** — the agents robot, and a line that rotates through what the
  token counts add up to across every agent: tokens this week and today, the
  most used model, the busiest day, and today's prompts and sessions. Its
  corner has + to add a subscription and >_ to start the default agent.
- **One section per agent** — its mark, name, and plan, then a compact line
  per limit window: its meter and the time until it resets (the exact percentage
  on hover). A model-scoped allowance on the same clock (Claude's Fable weekly
  limit) is a tick on that window's meter rather than a line of its own; the
  row's tooltip names it. Sign-in and endpoint trouble shows under the name in the urgent
  color. Limits kept from an earlier check after a failed one dim, and their
  tooltip says how old they are.
- **Accounts** — an agent with more than one subscription account (see
  `omarchy agent account`) lists each: name and plan on one line (the email on hover), and its own limit
  lines. An _ACTIVE_ label marks the account new sessions start as; the
  others get a _Use_ link. Hovering the line also reveals Autoswitch, which
  moves new sessions over on their own once the active account reaches its
  threshold; while it's on it stands in for Use, which shows only when you're
  on the line, and clicking it again goes back to notifying. Click a name to
  rename the account in place.
- **Balance** — prepaid agents show a credit ledger instead of limits: a
  fuel-gauge meter that drains toward empty, the remaining credit, and
  funded-versus-spent detail.
- **Make something cool** — starter prompts (a new theme, plugin, or app) that
  start the default agent on the task through `omarchy agent prompt`.
- **Adding a subscription** — the + in the hero's corner swaps the page for
  Claude Code, Codex, and Grok as large marks, three across, with the first
  one focused, and the hero's line reads Add an account. The + becomes the
  X that goes back. An agent that can't be added is dimmed and says why on
  hover. A further account asks for a name first, and Enter signs it in. The
  panel then runs `omarchy-agent-account-add --events` and follows it: the
  status, the code Grok asks you to confirm in the browser, a field to paste
  Claude's code back if its page shows one instead of finishing, and a link to
  reopen the sign-in page. Esc or the X stops the login. The browser taking focus may close the panel; the sign-in
  carries on and its result arrives as a notification.

The icon is always in the bar. On a machine with no agent yet, the panel is
the blank slate for setting one up: it opens on the same choice of Claude,
Codex, or Grok, and the first agent signed in becomes the default agent if
none was picked. An agent appears once it is enabled in settings and has
recorded usage, on this machine or a synced one; a CLI installed
mid-session shows up at the next refresh. Drop the widget with
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
| `grok` | The credits endpoint behind Grok's `/usage` view (the billing period's included usage) | Each session's `usage.json` (the ledger `grok usage` prints: tokens by model per finished turn), plus `summary.json` for sessions |
| `cursor` | Cursor's dashboard RPCs: included, auto-model, named-model, and on-demand meters | the same dashboard RPCs, one call per day for the last week |
| `opencode` | OpenCode Go's usage endpoint (rolling + weekly + monthly), with an API key or the Console session | pi and omp sessions on the Zen and Go providers, plus opencode's own `message` and `session_message` stores |
| `fireworks` | Estimated prepaid balance: configured funding minus rated account costs | Fireworks billing API, grouped by day and model for the last 30 days |
| `copilot` | Account-wide AI credit allowance (GitHub quota endpoint, or estimated locally) | the Copilot CLI session store's `assistant_usage_events`, with `~/.copilot/session-state` transcripts as fallback |
| `muse` | The client's key endpoint (session + weekly percents), else local metering only — never estimated | native `muse` CLI session files plus opencode sessions on the `meta` provider |

When `~/.local/state/omarchy/agents/accounts/<claude|codex|grok>.json`
registers more than one account, the `claude`, `codex`, and `grok` records
also carry
`accounts: [{ id, label, email, plan, active, limits, stale, usageStatusText,
authHelpText }]`, each account probed with its own sign-in (Claude caches each
account's limits separately; Codex runs one app-server per account home), and
`accountSwitch: { mode, threshold }`. The record's top-level `limits` and
`tierLabel` keep describing the active account, and local stats stay one set,
since every account shares the primary home's history. After each run,
`omarchy-agent-usage-update` hands the fresh limits to
`omarchy-agent-account-state autoswitch`, which notifies or switches when the
active account crosses its threshold, and re-collects the record if the active
account changed.

Claude limits need a signed-in CLI; without credentials the panel says so and
falls back to local stats only. A non-default Claude directory is honored via
`CLAUDE_CONFIG_DIR`, Codex via `CODEX_HOME`, Grok via `GROK_HOME`. Grok's
plan comes from the settings it caches in its home, and its limit from the
credits endpoint its own `/usage` view reads, asked with each account's
sign-in; a sign-in left to lapse shows the last credits until Grok runs
again. Fireworks reads
`FIREWORKS_API_KEY` and `FIREWORKS_ACCOUNT_ID` first, then
`~/.fireworks/auth.ini` (which `firectl set-api-key` creates), then the key
opencode stores in `~/.local/share/opencode/auth.json` when Fireworks is
signed in there. Cursor reads `CURSOR_API_KEY` first, then the token
`cursor-agent login` stores in `~/.config/cursor/auth.json`, then the
editor's own sign-in in `~/.config/Cursor/User/globalStorage/state.vscdb`
(opened read-only), and honors `CURSOR_API_ENDPOINT`.

### Cursor

Cursor's session files on disk carry no token counts, so this is the one
collector with nothing to fall back on: without a credential the record stays
empty and the panel skips it rather than showing a week of zeros. A failed
check keeps the account's last good meters, dimmed, until its billing cycle
ends, and its last week of tokens (today cleared once the day turns over); a
refused sign-in also says so under the name. Tokens by day and by model cover
the last seven local days, one aggregation call per day.

The meters are Cursor's own percentages — included total, auto-bucket models,
and named models — so they always agree with the Cursor dashboard. Spend is
never divided into an allowance here: bonus usage the model providers hand out
is spend with no allowance behind it, so dollars over the plan limit read far
past 100% while Cursor's own meters do not. The on-demand row is the exception
and is a real ratio: dollars spent against the on-demand limit the account
sets.

### OpenCode

One record covers the OpenCode subscription, Zen and Go together: usage on
the `opencode` and `opencode-go` providers. opencode sessions on an Anthropic
or OpenAI provider stay in the `claude` and `codex` records, so nothing counts
twice. Both of opencode's message stores are read (`message` and V2's
`session_message`, deduplicated by message id, leaving out the copies a fork
makes), from the database `OPENCODE_DB` names when set.

The Go meters read `OPENCODE_API_KEY` first, then the keys opencode keeps in
its database and `auth.json`, then pi's, and last the OpenCode Console
session, which asks Console's own endpoint with its workspace id. A refused
credential hands over to the next one. A recent answer is reused for 15
seconds, each credential caches its own, a failed check keeps the last good
windows, dimmed, until they reset, and a rate-limited window reads as full.
Without a Go plan the panel still shows local token usage.

### Copilot allowance

GitHub exposes no supported personal-account usage API — its Copilot REST
endpoints are organization- or enterprise-scoped — so the token sections come
from what the Copilot CLI keeps under `~/.copilot` (or `COPILOT_HOME`). Its
session store (`session-store.db`) records every billed request in an
`assistant_usage_events` table: day, model, session, the token split, and the
cost in nano AI units (1e9 nano units = 1 AI credit ≈ $0.01). CLI versions
whose store predates it are served by the session transcripts under
`session-state` instead, whose `session.shutdown` events carry the same
per-model token split and cost.

The monthly meter is the account-wide allowance of AI credits from GitHub's
internal quota endpoint (the same one the editor plugins ask), which counts
every machine, IDE, and agent on the entitlement and names the plan and the
reset date. It needs a token from `COPILOT_QUOTA_TOKEN`, `GH_TOKEN`,
`GITHUB_TOKEN`, or `gh auth token`, and only runs where the Copilot CLI has
been used, so a machine with `gh` signed in but no Copilot stays out of the
panel. A failed check keeps the last answer, dimmed. When the endpoint can't
be asked at all, a budget in `~/.config/omarchy/agents/copilot.json` gives a
meter labeled "(est.)" from this machine's CLI spend alone:

```json
{
  "monthlyCredits": 1500,
  "remote": true
}
```

`remote` set to `false` turns the quota probe off, and `true` runs it even
without a Copilot CLI home. The estimated window resets on the 1st of each
month at 00:00 UTC, GitHub's own boundary.

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

### Muse limits

Muse reads native CLI sessions from `$XDG_DATA_HOME/muse/sessions`
(defaulting to `~/.local/share/muse/sessions`, and overridable via
`MUSE_DATA_DIR`) plus opencode sessions on the `meta` provider, from both of
opencode's message stores (deduplicated by message id). Muse Spark through
the OpenCode Zen gateway counts in the `opencode` record instead. The
OAuth token comes from `MUSE_AUTH_PATH` when set, otherwise from
`~/.config/muse/auth.json` (which `muse login` creates); the file is only
ever read, never refreshed or rewritten.

The collector asks the client's own key endpoint for the subscription's
session and weekly percents with reset times — the same figures the TUI's
`/usage` overlay shows. Minting is idempotent (the same Model API key comes
back every call), so polling is safe; the token travels only in the
`Authorization` header and neither it nor the returned key is persisted. A
failed check keeps the last good windows, dimmed, until they reset.
Pay-as-you-go accounts have no subscription windows, so the tab shows
measured local usage with no meters — never estimated, never zeroed. An
active plan that returns no `subs_usage` (Muse Code Power Usage answers this
way on every probe) behaves the same way, except the tab keeps the plan name.

## Interactions

- Bar icon: left = panel, right = launch agent, middle = refresh. It turns
  urgent when any account new sessions use is at 90% of a window, or a
  prepaid balance is down to its last 10%.
- Panel: the arrows (or `h`/`j`/`k`/`l`) walk a cursor over everything that
  does something, row by row: the hero's buttons, each agent's header, each
  switchable account (landing on Use, with Autoswitch to its left), and the
  starter tiles, or the agents to add. Ctrl+Up/Down (or Ctrl+`k`/`j`) moves the
  agent the cursor is in up or down the page; dragging an agent by its mark
  does the same, lighting the header it will land on. The order is kept in
  `~/.local/state/omarchy/agents/order.json`. Hovering moves the same cursor. Enter acts on it, or
  refreshes when nothing is lit; `r` refreshes, Tab moves to the neighboring
  bar panel, Esc closes.
- Accounts: `1`–`9` jump to an account across every agent, and Enter makes it
  active (picking alone never switches). `m` toggles automatic switching for
  the picked account's agent. While an agent
  with several accounts has its active one within 15 points of its switch
  threshold (80% at the default), the limits refresh every three minutes.
- IPC: `omarchy-shell omarchy.agents <open|close|toggle|refresh>`.

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
billing API, so their totals and day counts cover that window. Claude's and
Muse's cover every session still on disk.
