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
  row's tooltip names it. A lapsed or missing Claude, Codex, or Grok sign-in
  shows a _Sign-in required_ link that signs that account in again from the
  panel; any other agent's sign-in trouble, and other endpoint trouble, shows
  under the name in the urgent color, with what to do on hover. Limits kept
  from an earlier check after a failed one look the same, and their tooltip
  says how old they are.
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

Adding an agent needs no QML changes: ship a collector that follows the contract in [`docs/agent-usage-collectors.md`](../../../docs/agent-usage-collectors.md) (the `claude` collector is the reference), built on the plumbing the collectors share in `collectors.py` beside this README, and the panel gains a section. An `assets/<id>.svg` mark is optional, with an `assets/<id>-light.svg` twin if the mark needs a dark variant for light surfaces; the bar glyph stands in when there is none.

| Collector | Limits | Local stats |
|---|---|---|
| `claude` | Anthropic's OAuth usage endpoint (5-hour session, 7-day weekly, and any model-scoped windows) | `~/.claude/projects` transcripts, pi/omp sessions and opencode sessions on an Anthropic provider, plus `stats-cache.json` and `history.jsonl` as fallback |
| `codex` | The Codex app-server's `account/rateLimits/read`, every bucket (general windows plus any model's own) | native Codex CLI session files on the built-in `openai` provider, pi/omp sessions on `openai-codex`, and opencode sessions on the `openai` provider |
| `grok` | The credits endpoint behind Grok's `/usage` view (the billing period's included usage) | Each session's `usage.json` (the ledger `grok usage` prints: tokens by model per finished turn), plus `summary.json` for sessions |
| `kimi` | Kimi Code quotas (5-hour session, weekly, and monthly allowances) | none; quota only |
| `cursor` | Cursor's dashboard RPCs: the included total for the billing month, with the auto-model, named-model, and on-demand meters attached to it | the same dashboard RPCs, one call per day for the last week |
| `grokbot` | Grok Bot's weekly included usage from Cursor's `GetSandUsageStatus` RPC, asked as the Cursor sign-in | none; limit only |
| `copilot` | Account-wide AI credit allowance (GitHub quota endpoint, or estimated locally) | the Copilot CLI session store's `assistant_usage_events`, with `~/.copilot/session-state` transcripts as fallback |
| `muse` | The client's key endpoint (session + weekly percents), else local metering only — never estimated | native `muse` CLI session files, with prompt and session counts from its `session-index.db`, plus pi/omp and opencode sessions on the `meta` provider |
| `agy` | Google's Cloud Code API (`loadCodeAssist` for the plan, `retrieveUserQuotaSummary` for the 5-hour and weekly windows and any touched Claude/GPT allowance), asked with the sign-in agy, omp, pi, or opencode's Antigravity plugin keeps | `history.jsonl`, `conversation_summaries.db`, and each conversation's `transcript.jsonl` under `~/.gemini/antigravity-cli/` (`AGY_DIR`), plus pi, omp, and OpenClaw sessions on the `google-antigravity` provider and opencode's `antigravity-` models |
| `kimchi` | The plan, prepaid credits, and any spend budgets from the gateway's `/v1/credits` and `/v1/budget`, the endpoints Kimchi's own status line reads | Kimchi's pi session files under `~/.config/kimchi/harness/sessions` (`KIMCHI_CODING_AGENT_DIR`): tokens by model per assistant reply |
| `hermes` | None (Hermes has no subscription of its own) | `state.db` in Hermes' home and in each named profile under `~/.hermes/profiles`, read-only, scanned once per refresh window |
| `devin` | The daily and weekly quota (plus credit buckets on credit plans) from the GetUserStatus answer the Devin CLI caches in `$XDG_CACHE_HOME/devin/cli/user_status.*.bin`; no network call | the CLI's `$XDG_DATA_HOME/devin/cli/sessions.db` (per-message metrics and `prompt_history`), plus pi/omp and opencode sessions on the `devin` provider |
| `vibe` | None (Mistral publishes no usage limits) | Vibe's per-session `meta.json` under `~/.vibe/logs/session` (`VIBE_HOME`), only sessions on a Mistral-served model, plus pi/omp and opencode sessions on the `mistral` provider |
| `qwen` | None (Qwen Code reads no quota) | Session transcripts under `~/.qwen/projects/*/chats` (`QWEN_HOME`, `QWEN_RUNTIME_DIR`, `advanced.runtimeOutputDir`): billed API responses and typed prompts |
| `opencode` | OpenCode Go's usage endpoint (rolling + weekly + monthly), with an API key or the Console session; a key without a Go plan shows local usage alone | pi and omp sessions (profiles included) on the Zen and Go providers, plus opencode's own `message` and `session_message` stores |
| `zai` | Z.ai's coding-plan monitor endpoint (5-hour session + 7-day weekly), for keys that carry a GLM Coding Plan | pi, omp, and opencode sessions on the `zai` and `zhipu` providers (`glm-*` models) |
| `ollama` | Ollama Cloud's usage endpoint (5-hour session + 7-day weekly, without reset times) | pi, omp, and opencode sessions on the `ollama-cloud` provider, plus cloud-tagged models reached through the local daemon's `ollama` provider |
| `minimax` | MiniMax Token Plan API (5-hour session + 7-day weekly) | MiniMax Code's session files under `~/.minimax/v2/sessions`, plus pi, omp, and opencode sessions on a MiniMax provider |
| `openrouter` | Prepaid balance from `/credits`, key-limit meter from `/key`, each kept stale past a failed check | opencode and pi/omp sessions on the OpenRouter provider, with or without a key, or the `/activity` billing API with a management key |
| `deepseek` | Live prepaid balance from `GET https://api.deepseek.com/user/balance`, kept stale past a failed check, with the optional `fundedAmount` estimate for the funded-versus-spent line | pi/omp session files (profiles included) whose assistant messages ran on the deepseek provider, opencode sessions on a deepseek provider, and DeepSeek Harness (`dsh`) session logs on its DeepSeek routes |
| `fireworks` | Prepaid balance: the live ledger when the key can read it, else configured funding minus rated account costs; kept stale past a failed check | Fireworks billing API, grouped by day and model for the last 30 days, cached per key and account |
| `synthetic` | Synthetic's `GET /v2/quotas`: rolling five-hour requests, weekly credits, hourly search, free tool calls | pi/omp sessions and opencode messages on the `synthetic` provider |
| `local` | None (self-hosted work has no meter) | Codex rollouts, pi/omp sessions and opencode messages on a local runtime, a provider named in `local.json`, or a Codex provider whose `base_url` is on the LAN, never a provider id another collector counts |

Every collector follows the same rules, so the same situation reads the same for every agent: a recent answer is reused for 15 seconds unless refresh is pressed, each credential or account keeps its own last good answer, a failed check keeps it with its age on hover and windows that have since reset back at zero, an endpoint that can't be reached is retried soon, and an agent the machine doesn't use stays out of the panel. Tokens are counted once, under the provider that bills them: pi, omp, and opencode sessions are split by provider into the matching collector. pi and omp sessions are read from every profile, and from `PI_CODING_AGENT_DIR` and `PI_CODING_AGENT_SESSION_DIR` as well as the defaults when set, a forked session's copied messages once; opencode is read from both its `message` and V2 `session_message` stores in the database `OPENCODE_DB` names, a message migrated into both once and a fork's copied history not at all. A machine with none of an agent's home, CLI, or usage prints an empty record the panel skips; one that has them but no sign-in says it is waiting for one. The sections below cover where each agent's sign-in and data come from.

When `~/.local/state/omarchy/agents/accounts/<claude|codex|grok>.json` registers more than one account, the `claude`, `codex`, and `grok` records also carry `accounts: [{ id, label, email, plan, active, primary, limits, stale, fetchedAt, retryAdvised, usageStatusText, authHelpText }]`, each account probed with its own sign-in (each account caches its own last limits; Codex runs one app-server per account home), and `accountSwitch: { mode, threshold }`. The record's top-level `limits` and `tierLabel` keep describing the active account, and local stats stay one set, since every account shares the primary home's history. After each run, `omarchy-agent-usage-update` hands the fresh limits to `omarchy-agent-account-state autoswitch`, which notifies or switches when the active account crosses its threshold, and re-collects the record if the active account changed.

### Claude Code

Limits come from Anthropic's OAuth usage endpoint, asked with the access token the Claude Code CLI keeps in `.credentials.json` under `CLAUDE_CONFIG_DIR` (default `~/.claude`); the plan comes from the CLI's profile, else the credentials. Only the CLI refreshes that token, so one left to lapse reads "Limits paused" and keeps the last numbers until Claude Code runs again; a lapsed refresh token reads "Sign-in expired". Without credentials the panel says so and falls back to local stats only.

Local stats come from the CLI's transcripts under `projects/`, falling back to `stats-cache.json` and `history.jsonl`, plus pi and omp sessions (honouring `PI_CODING_AGENT_DIR` and `PI_CODING_AGENT_SESSION_DIR`) and opencode sessions on the `anthropic` provider.

### Codex

Limits and the plan come from the Codex CLI's own app-server (`codex app-server`, `account/rateLimits/read`), started in each account's home (`CODEX_HOME`, default `~/.codex`) so it answers for that login and refreshes its tokens there. Every rate-limit bucket is read: the general windows, and any model's own allowance shown beside the window of the same span. A home with no `auth.json` under the file store and no `CODEX_ACCESS_TOKEN` reads "Waiting for auth" without starting the app-server.

Each login keeps its last good limits, keyed by the workspace and user in `auth.json` (or the access token); a keyring login can't be told apart and keeps none. A stalled app-server, or one that couldn't reach OpenAI, is retried soon.

Local stats come from native session files on the built-in `openai` provider, pi and omp sessions on `openai-codex` (honouring `PI_CODING_AGENT_DIR` and `PI_CODING_AGENT_SESSION_DIR`), and opencode sessions on `openai`, from both of opencode's message stores and the database `OPENCODE_DB` names.

Codex CLI will front any OpenAI-compatible backend — `--oss`, or a custom `model_provider` in `config.toml` aimed at Ollama, LM Studio, or a gateway — and those rollouts sit in the same sessions directory as OpenAI-backed ones. The Codex collector skips a rollout whose first `session_meta.model_provider` names anything but the built-in `openai` provider. Rollouts written before Codex recorded that field carry no provider and still count.

### Grok

The plan comes from the settings Grok caches in its home (`GROK_HOME`, default `~/.grok`), and the limit from the credits endpoint its own `/usage` view reads, asked with each account's sign-in from `auth.json`. A lapsed access token with a live refresh token is routine: Grok renews it when it starts, so the last credits stand until then. A refused sign-in, or one past Grok's 30 days, reads "Sign-in expired". Local stats come from each session's `usage.json` and `summary.json`; sessions on disk count Grok as in use even without a sign-in.

### Kimi

Kimi reads `KIMI_API_KEY` first, then `credentials/kimi-code.json` under an explicit `KIMI_CODE_HOME`. Without that override it prefers `~/.kimi-code/credentials/kimi-code.json`, with the legacy `~/.kimi/credentials/kimi-code.json` as a compatibility fallback. An explicit home never borrows another home's sign-in. Its record reports account quotas, without local token or prompt statistics, so Kimi counts as in use when it has a credential or a Kimi home; a home without a sign-in waits for one, and a machine with neither stays hidden.

Expired tokens are refreshed under the current CLI's renewable directory lock at `<home>/oauth/kimi-code.lock`; legacy credentials use their sibling file lock. The rotated token pair is flushed and published atomically with private permissions. Credentials are reread after the exchange so a sign-in or logout completed during the request takes precedence. A failed lock prevents refresh, and credentials are sent only to trusted Kimi HTTPS hosts without following redirects. A refused token or refresh reads as Sign-in expired: run `kimi login`, or update or unset an overriding `KIMI_API_KEY`. Cache identity follows the token used by the request, and a refresh this collector performs carries the same account's previous limits forward. Different credentials or endpoints never share cached quota.

### Cursor

Cursor keeps no token counts on disk, so everything comes from the dashboard RPCs the Cursor CLI itself calls, asked with `CURSOR_API_KEY`, else the sign-in `cursor-agent login` stores in `~/.config/cursor/auth.json`, else the editor's in `~/.config/Cursor/User/globalStorage/state.vscdb` (read-only); `CURSOR_API_ENDPOINT` moves the endpoint. A sign-in that has lapsed gives way to the next one that hasn't; with all of them lapsed the limits read "Limits paused" until the CLI or editor renews its token. A machine with Cursor installed but signed in nowhere says it is waiting for a sign-in; one without Cursor stays out of the panel.

The week of tokens is reused for 20 seconds (15 minutes on a near-limit refresh). A failed check keeps the account's last good meters, plan, and week of tokens. Tokens by day and by model cover the last seven local days, one aggregation call per day.

The meters are Cursor's own percentages, so they always agree with the Cursor dashboard. The included total is the Monthly row; the auto-bucket and named model meters and the on-demand budget run on the same billing cycle and show in its tooltip. Spend is never divided into an allowance here: bonus usage the model providers hand out is spend with no allowance behind it, so dollars over the plan limit read far past 100% while Cursor's own meters do not. The on-demand meter is the exception and is a real ratio: dollars spent against the on-demand limit the account sets.

### Grok Bot

Grok Bot runs on a Cursor account, but its weekly allowance is metered apart from Cursor's plan: the dashboard's `GetSandUsageStatus` RPC says how much of this week's included usage is gone, when it resets, and the Grok plan. It is asked as the same account the Cursor collector reads, found the same way (`CURSOR_API_KEY`, then the CLI's `auth.json`, then the editor's `state.vscdb`, read-only). Grok Bot keeps nothing countable on disk, so the record carries the limit alone, and an account without a Grok Bot allowance, or a machine without a Cursor sign-in, stays out of the panel.

### Copilot

GitHub exposes no supported personal-account usage API — its Copilot REST endpoints are organization- or enterprise-scoped — so the token sections come from what the Copilot CLI keeps under `~/.copilot` (or `COPILOT_HOME`). Its session store (`session-store.db`) records every billed request in an `assistant_usage_events` table: day, model, session, the token split, and the cost in nano AI units (1e9 nano units = 1 AI credit ≈ $0.01). A row is a billed request rather than a prompt, so the store's counts stay out of the panel's prompt totals. CLI versions whose store predates it are served by the session transcripts under `session-state` instead, whose `session.shutdown` events carry the same per-model token split and cost.

The monthly meter is the account-wide allowance of AI credits from GitHub's internal quota endpoint (the same one the editor plugins ask), which counts every machine, IDE, and agent on the entitlement and names the plan and the reset date. It needs a token from `COPILOT_QUOTA_TOKEN`, `GH_TOKEN`, `GITHUB_TOKEN`, or `gh auth token`, and only runs where the Copilot CLI has been used, so a machine with `gh` signed in but no Copilot stays out of the panel. Each account keeps its own last answer, `gh`'s keyed by the user its `hosts.yml` names, so a reused answer doesn't run `gh` at all. Without any token the section says it is waiting for a sign-in. When the endpoint can't be asked at all, a budget in `~/.config/omarchy/agents/copilot.json` gives a meter labeled "(est.)" from this machine's CLI spend alone:

```json
{
  "monthlyCredits": 1500,
  "remote": true
}
```

`remote` set to `false` turns the quota probe off (and the sign-in reminder with it), and `true` runs it even without a Copilot CLI home. The estimated window resets on the 1st of each month at 00:00 UTC, GitHub's own boundary.

### Muse

Muse reads native CLI sessions from `$XDG_DATA_HOME/muse/sessions` (defaulting to `~/.local/share/muse/sessions`, and overridable via `MUSE_DATA_DIR`), with the real prompt and session counts from the CLI's `session-index.db` beside them (completions stand in when it is missing, and for a session it has no row for yet; since the index keeps each session's running prompt count, today's prompts are what each count grew by since the last scan before today), plus pi, omp, and opencode sessions on the `meta` provider. Muse Spark through the OpenCode Zen gateway counts in the `opencode` record instead. The OAuth token comes from `MUSE_AUTH_PATH` when set, otherwise from `~/.config/muse/auth.json` (which `muse login` creates); the file is only ever read, never refreshed or rewritten. A Muse CLI set up on the machine without a login waits for one.

The collector asks the client's own key endpoint for the subscription's session and weekly percents with reset times — the same figures the TUI's `/usage` overlay shows. Minting is idempotent (the same Model API key comes back every call), so polling is safe; the token travels only in the `Authorization` header and neither it nor the returned key is persisted. Pay-as-you-go accounts have no subscription windows and no plan name, so the tab shows measured local usage with no meters — never estimated, never zeroed. An active plan that returns no `subs_usage` (Muse Code Power Usage answers this way on every probe) behaves the same way, except the tab keeps the plan name.

### Antigravity

The record's id is `agy`, the name the default agent knows it by. The plan and limits are asked of Google's Cloud Code API with whichever Antigravity sign-in is on the machine: the one `agy` keeps in the Secret Service keyring (service `gemini`, username `antigravity`) or, without a keyring, in `antigravity-oauth-token` under `AGY_DIR`; omp's `google-antigravity` sign-in in `~/.omp/agent/agent.db`; pi's in `auth.json` (under `PI_CODING_AGENT_DIR` when set); and opencode's `google` sign-in, only when the Antigravity plugin's `antigravity-accounts.json` is there. The token refreshed most recently is asked first, and one Google refuses gives way to the next. Those stores are only ever read. A lapsed token shows the last limits as paused until the harness that owns it runs again; a lapsed omp sign-in is asked through `omp usage`, which renews it. Each Google account keeps its own last answer, so another account's limits never stand in. `CLOUD_CODE_URL` moves the endpoint, over https only.

Local stats count `agy`'s history prompts, its conversations (a subagent's conversation counts toward the one that spawned it), and the tokens each transcript step reports, under the model the step or the last Model Selection names. Antigravity answers that pi, omp, OpenClaw (`OPENCLAW_STATE_DIR`), and opencode's plugin recorded count too, a forked copy once. No other collector counts these.

### Kimchi

Kimchi reads `KIMCHI_API_KEY` first, then the key in `~/.config/kimchi/config.json`, and asks the gateway its region names (or `KIMCHI_BASE_URL`); its sessions follow `KIMCHI_CODING_AGENT_DIR`. The credits answer says how much remains but not how much was bought, so the balance shows the remaining figure without a funded meter; a spend budget's cap is what may be spent, not what was bought, so it never stands in. Every budget is a limit line that resets when its period ends, titled Monthly or Weekly when the period is one, with each capped provider inside it a tick on that line (or a line of its own in a period of another length). Each endpoint falls back on its own: when one can't be reached, its last answer stays up beside the other's fresh one. A rejected key reads as Sign-in expired; sign in again through Kimchi's own CLI. Sessions on disk without a key wait for one. An account out of credits reads "Out of credits, rate limited", the gateway's own signal.

### Hermes

Hermes Agent keeps its sessions in `state.db` in its home (`HERMES_HOME`, else `~/.hermes`) and in each named profile under `~/.hermes/profiles`, which Hermes anchors there whatever `HERMES_HOME` says. The collector reads them read-only: sessions, user prompts, and per-session, per-model token usage, including chats that arrived over messaging gateways. A session's tokens land on the day it started. Hermes has no subscription, so the tab shows local stats only. Without any `state.db` the tab stays hidden; a database that can't be read shows "Hermes unavailable" with the file and error on hover, while the other profiles still count.

### Devin

Devin's quota comes from the cache the Devin CLI writes each time it starts, `$XDG_CACHE_HOME/devin/cli/user_status.*.bin` (`DEVIN_CACHE_DIR`): the GetUserStatus answer it fetched, the same numbers its `/usage` command shows. The collector never makes a request of its own. Of the caches fetched since `credentials.toml` was last written, the newest wins, so a sign-in to another account never shows the last one's quota; until the CLI runs again after a sign-in, the panel says so. A cache more than fifteen minutes old still shows, marked stale with its age, and a window that reset since reads zero. The daily and weekly windows show unless the plan hides them, and a credit plan's prompt, flow and flex credits show as meters that reset when the plan period ends.

Local stats come from the CLI's `$XDG_DATA_HOME/devin/cli/sessions.db` (`DEVIN_DATA_DIR`), read-only: tokens by model from each assistant message's metrics, prompts and sessions from `prompt_history`. Builds that kept `cli_sessions.db` or `sessions.db` straight under `$XDG_DATA_HOME/devin` are read only when the CLI's own database is absent; they keep one lifetime total per session, which lands on its last active day. pi, omp, and opencode sessions on the `devin` provider count too.

### Mistral Vibe

Vibe writes a `meta.json` per session under `~/.vibe/logs/session` (moved by `VIBE_HOME`, or by `session_logging.save_dir` in Vibe's `config.toml`) with the session's running token totals and the config it ran with. Vibe drives other providers too, a local llama.cpp server out of the box, so a session only counts when the model it resolved to is served by Mistral's API: a provider with Vibe's `mistral` backend or a mistral.ai host. Totals are booked on the day a session started, a subagent's on the session that spawned it, and prompts are the user messages Vibe didn't inject itself. pi, omp, and opencode sessions on the `mistral` provider count here too. The plan is the one Vibe last cached from Mistral's whoami answer in `whoami_cache.json`, named as Vibe names it. Mistral publishes no usage limits, so the section shows local stats only.

### Qwen Code

Qwen Code writes each session to `projects/<project>/chats/<session>.jsonl` under `~/.qwen` (`QWEN_HOME`), or under `QWEN_RUNTIME_DIR` or the `advanced.runtimeOutputDir` setting when either moves it. Every billed API response is a telemetry line there with the model and the provider's token counts, the same lines Qwen Code's own usage statistics are rebuilt from, read by the same rules: the prompt count includes its cached part, and thinking is added to output only where the provider counts it apart. Typed prompts come from the user lines, and a branched session's repeated lines count once. Qwen Code reads no quota of its own, so there is no meter.

### OpenCode

One record covers the OpenCode subscription, Zen and Go together: usage on the `opencode` and `opencode-go` providers. opencode sessions on an Anthropic or OpenAI provider stay in the `claude` and `codex` records, so nothing counts twice. Both of opencode's message stores are read (`message` and V2's `session_message`, deduplicated by message id, leaving out the copies a fork makes), from the database `OPENCODE_DB` names when set.

The Go meters read `OPENCODE_API_KEY` or `OPENCODE_GO_API_KEY` first, then the keys opencode keeps in its database and `auth.json`, then pi's, and last the OpenCode Console session, which asks Console's own endpoint with its workspace id. A refused credential hands over to the next one, and when every one is refused the record asks for a new sign-in. A rate-limited window reads as full. A key without a Go plan (Zen pay-as-you-go) is no trouble: the panel shows local token usage alone, and that key isn't asked again for an hour. Without any key, local usage shows the same way.

### Z.ai

Z.ai limits need a key that carries a GLM Coding Plan. A pay-as-you-go key reports "no coding plan", which is no trouble: the panel shows local stats alone. The key comes from `~/.config/omarchy/agents/zai.json`, then `ZAI_API_KEY` / `ZHIPU_API_KEY` in the environment, then pi/omp's `.env`, then the key pi or omp saved in `auth.json`. Set `platform` to `"zhipu"` in the config for the China (`open.bigmodel.cn`) host. Local stats count pi, omp, and opencode sessions on the `zai` and `zhipu` providers.

### Ollama Cloud

Ollama Cloud reads `OLLAMA_API_KEY` first, then `apiKey` in `~/.config/omarchy/agents/ollama.json`, then the key pi or omp signed in with in `~/.pi/agent/auth.json` (or under `PI_CODING_AGENT_DIR`) or `~/.omp/agent/auth.json`. Each key keeps its own last good limits and plan.

Ollama's usage endpoint reports the account's session and weekly usage as 0..1 fractions but not the reset times, so those windows show no reset time rather than a guessed one. The limits cover the whole account — every model the key can reach — while the local stats count pi, omp, and opencode sessions on the `ollama-cloud` provider, and cloud-tagged models (`glm-4.6:cloud`, `gpt-oss:120b-cloud`) reached through the local daemon's `ollama` provider, which run on Ollama's servers too. To count only the Claude models Ollama Cloud serves, set a model prefix in `~/.config/omarchy/agents/ollama.json`:

```json
{
  "modelPrefix": "claude",
  "apiKey": ""
}
```

`modelPrefix` restricts the local stats to models whose name starts with the prefix (empty means every model); `apiKey` is a key of its own, used when `OLLAMA_API_KEY` is unset.

### MiniMax

MiniMax reads `MINIMAX_API_KEY` first, then the API key or OAuth session saved by MiniMax's own `mmx` CLI if you use it, then the key opencode, pi, or omp stores when MiniMax is signed in there. It uses the region and resource URL saved by `mmx` (or the China host for a `minimax-cn` key), or the global `https://api.minimax.io` endpoint by default; `MINIMAX_BASE_URL` overrides both. The quota request never follows a redirect, so the key stays with MiniMax's host. Local stats count MiniMax Code's own sessions under `MINIMAX_DATA_DIR`, `MAVIS_DATA_DIR`, or `~/.minimax` (user messages as prompts, assistant replies as tokens), plus pi, omp, and opencode sessions on a MiniMax provider. Without a key the panel still shows that local usage and waits for one to show the limits.

### OpenRouter

OpenRouter reads `OPENROUTER_API_KEY` first, then the key opencode stores in `~/.local/share/opencode/auth.json`, then the key pi (`~/.pi/agent/auth.json`, honoring `PI_CODING_AGENT_DIR`) or omp (`~/.omp/agent/auth.json`) saved when OpenRouter is signed in there, then `apiKey` in `~/.config/omarchy/agents/openrouter.json`. Without any key, the local pi, omp, and opencode usage on the OpenRouter provider still shows, and the panel waits for a key to show the balance and meter. A management key in `OPENROUTER_MANAGEMENT_KEY` (or `managementKey` in that file, from `openrouter.ai/settings/management-keys`) switches the token history from the local scan to the account-global `/activity` API; on its own it also reads the balance, with no key-limit meter.

The collector reads the prepaid ledger from `GET /api/v1/credits` (`remaining = total_credits - total_usage`) and reports it as a live, non-estimated balance. A key with a credit limit additionally gets a draining key-limit meter from `GET /api/v1/key`, labeled with how often the limit starts over. Each key keeps its own last good meter and balance.

Token history comes in two tiers, selected automatically by key type:

```json
{
  "apiKey": "",
  "managementKey": ""
}
```

Without a management key, tokens come from the local opencode database (`providerID == "openrouter"`, read-only) and from pi/omp sessions whose assistant messages ran on the `openrouter` provider. With `OPENROUTER_MANAGEMENT_KEY` (or `managementKey` in `~/.config/omarchy/agents/openrouter.json`), the last 30 days come from `GET /api/v1/activity` instead: account-global per-day/per-model tokens that cover every machine and client. That record carries `"scope": "account"` and `hasPromptStats: false`, like Fireworks, so synced aggregation merges it by widest value instead of summing it.

### DeepSeek

DeepSeek reads `DEEPSEEK_API_KEY` first, then the key pi stores in `~/.pi/agent/auth.json`, then the key opencode stores in its own `auth.json` when DeepSeek is signed in there, and last the key DeepSeek Harness keeps in `$DSH_HOME/.credentials.yaml` (or the `.env` beside it; `$DSH_HOME` defaults to `~/.dsh`). Each key keeps its own last balance. Local usage also counts dsh's own session logs under `$DSH_HOME/sessions` on its DeepSeek routes, leaving out the history a forked session inherits. Its `fundedAmount` estimate lives in `~/.config/omarchy/agents/deepseek.json`, the same shape the fireworks collector uses; without it the panel shows the live remaining credit and skips the funded-versus-spent line.

### Fireworks

Fireworks reads `FIREWORKS_API_KEY` and `FIREWORKS_ACCOUNT_ID` first, then `~/.fireworks/auth.ini` (which `firectl set-api-key` creates), then the key pi stores in `~/.pi/agent/auth.json` when Fireworks is signed in there (honoring `PI_CODING_AGENT_DIR`, and pi's literal and `$ENV_VAR` key forms), and finally the key opencode stores in `~/.local/share/opencode/auth.json`.

The collector first asks the account's `:getBalance` endpoint for the real prepaid ledger. That endpoint exists but is permission-gated, and as of August 2026 no console-issued API key passes it — Fireworks appears to reserve it for the dashboard session. The probe stays because it is cheap and the live figure lights up automatically if Fireworks ever opens it to keys. Until then the collector falls back to estimating the balance from configuration in `~/.config/omarchy/agents/fireworks.json`:

```json
{
  "accountId": "",
  "fundedAmount": 20,
  "fundedAt": "2026-07-01"
}
```

Set `fundedAmount` to the credits purchased and optionally `fundedAt` to the purchase date; with no date, the collector uses the account creation time. It subtracts rated account costs and the panel labels the result as estimated. For a later top-up, increase `fundedAmount` by the new credit while keeping the original `fundedAt`, so both the funding and spend still cover the same period. `accountId` only matters when one API key can access several accounts. Without a configured `fundedAmount` the tab still shows token usage, just no balance. With a live ledger, `fundedAmount` is optional and only adds the meter and the spent-of-funded line under the real figure.

Each API key keeps its account's last good usage rows and balance; another key or account never shows them. Usage is re-read at most every 20 seconds (15 minutes on the panel's near-limit refresh). A rejected key reads as an expired sign-in; with no key anywhere the tab stays hidden. Its stats come from the account's billing API, so they already include this machine's pi and opencode use, and no local scan adds them again.

### Synthetic

Synthetic reads `SYNTHETIC_API_KEY` first, then the key pi stores in `~/.pi/agent/auth.json` (honoring `PI_CODING_AGENT_DIR` and `$ENV_VAR` keys), then omp's `~/.omp/agent/auth.json`, then opencode's `auth.json`. The collector asks the documented `GET https://api.synthetic.new/v2/quotas`, which doesn't count against the quotas. The rolling five-hour request limit and the weekly credits regenerate a little at a time, so they show how much is used with no reset time; hourly search and free tool calls reset when Synthetic says they renew. An account without the credit system shows the documented subscription request bucket instead. Local stats count pi and omp sessions and opencode messages on the `synthetic` provider.

### Local models

The Local models section counts work that ran on hardware you own: Codex rollouts, pi and omp sessions, and opencode messages whose provider is a well-known local runtime (Ollama, LM Studio, llama.cpp, vLLM, ...), a provider named in `~/.config/omarchy/agents/local.json`, or a Codex `model_providers` entry whose `base_url` is on a loopback, private, link-local or LAN address:

```json
{ "providers": ["homelab", "my-gateway"] }
```

It is the exact complement of the provider collectors: a provider id another collector counts is never counted here, whatever `local.json` says, and the Codex collector keeps every rollout on the built-in `openai` provider. Two providers are claimed only for some models, and only those rows are left out: Ollama's cloud models (a `:cloud` or `-cloud` tag) run on Ollama's servers even through the local daemon, so they count under Ollama Cloud instead, and opencode's Antigravity plugin records a `google` provider with `antigravity-` models, which the Antigravity collector counts. There are no limits or balance.

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
  "fireworks": { "enabled": true },
  "kimchi": { "enabled": true }
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
