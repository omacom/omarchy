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
- **One section per subscription** — an agent with limits, a balance, a plan,
  or accounts to show gets one; local history alone only feeds the hero's
  line. Its mark, name, and plan, then a compact line
  per limit window: its meter and the time until it resets (the exact percentage
  on hover). A model-scoped allowance on the same clock (Claude's Fable weekly
  limit) is a tick on that window's meter rather than a line of its own; the
  row's tooltip names it. A lapsed or missing Claude, Codex, or Grok sign-in
  shows a _Sign-in required_ link that signs that account in again from the
  panel. Any other trouble — a paused token, another agent's sign-in, an
  endpoint that didn't answer — leaves the last known limits on show, with a
  small info mark beside the name whose tooltip says why they aren't current
  and what to do; each meter's tooltip says how old it is.
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
| `codex` | The Codex app-server's `account/rateLimits/read`, every bucket (general windows plus any model's own), plus an individual spend cap and its reported reset time when present | native Codex CLI session files on the built-in `openai` provider, pi/omp sessions on `openai-codex`, and opencode sessions on the `openai` provider |
| `grok` | The credits endpoint behind Grok's `/usage` view (the billing period's included usage), plus the monthly included quota of a unified-billing account | Each session's `usage.json` (the ledger `grok usage` prints: tokens by model per finished turn, one turn per typed prompt, a fork's copied turns counted once), plus `summary.json` for sessions |
| `kimi` | Kimi Code quotas (5-hour session, weekly, and monthly allowances) | Kimi Code's per-agent `wire.jsonl` session logs under its home on Kimi's routes, pi, omp, and opencode sessions on the Kimi Code plan (`kimi-coding`, `kimi-code`, `kimi-code-plan-global`, `kimi-code-plan-cn`) or Moonshot's API (`moonshotai`, `moonshotai-cn`, `moonshot`), plus Claude Code turns sent to Kimi's or Moonshot's API or answered by a `kimi-*` or `moonshot*` model |
| `cursor` | Cursor's dashboard RPCs: the included total for the billing month, with the auto-model, named-model, and on-demand meters attached to it | the same dashboard RPCs, one call per day for the last week |
| `grokbot` | Grok Bot's weekly included usage from Cursor's `GetSandUsageStatus` RPC, asked as the Cursor sign-in | none; limit only |
| `copilot` | Account-wide AI credit allowance (GitHub quota endpoint, or estimated locally) | the Copilot CLI session store's `assistant_usage_events`, with `~/.copilot/session-state` transcripts as fallback |
| `muse` | The client's key endpoint (session + weekly percents), else local metering only — never estimated | native `muse` CLI session files, with prompt and session counts from its `session-index.db`, plus pi/omp and opencode sessions on the `meta` provider and omp's `muse-code` |
| `agy` | Google's Cloud Code API (`loadCodeAssist` for the plan, `retrieveUserQuotaSummary` for the 5-hour and weekly windows and any touched Claude/GPT allowance), asked with the sign-in agy, omp, pi, or opencode's Antigravity plugin keeps | `history.jsonl`, `conversation_summaries.db`, and each conversation's `transcript.jsonl` under `~/.gemini/antigravity-cli/` (`AGY_DIR`), plus pi, omp, and OpenClaw sessions on the `google-antigravity` provider and opencode's `antigravity-` models |
| `kimchi` | The plan, prepaid credits, and any spend budgets from the gateway's `/v1/credits` and `/v1/budget`, the endpoints Kimchi's own status line reads | Kimchi's pi session files under `~/.config/kimchi/harness/sessions` (`KIMCHI_CODING_AGENT_DIR`): tokens by model per assistant reply on Kimchi's own `kimchi` and `kimchi-dev` routes; a session `--provider openrouter` is OpenRouter's, and one on a custom provider counts nowhere. Also pi/omp sessions and opencode replies on those provider ids, and Claude Code turns and Codex rollouts sent to Kimchi's gateway (`llm.kimchi.dev`, `llm.eu.kimchi.dev`), as `kimchi claudecode` and `kimchi codex` set them up |
| `hermes` | None (Hermes has no subscription of its own) | `state.db` in Hermes' home and in each named profile under its root's `profiles/`, read-only, scanned once per refresh window: the sessions Nous Portal billed, and those from before Hermes kept the route |
| `devin` | The daily and weekly quota (plus credit buckets on credit plans) from the GetUserStatus answer the Devin CLI caches in `$XDG_CACHE_HOME/devin/cli/user_status.*.bin`; no network call | the CLI's `$XDG_DATA_HOME/devin/cli/sessions.db` (per-message metrics and `prompt_history`), plus pi/omp and opencode sessions on the `devin` provider |
| `vibe` | None (Mistral publishes no usage limits) | Vibe's Unified Harness store under `~/.vibe/logs/session/unified` and older releases' per-session `meta.json` under `~/.vibe/logs/session` (`VIBE_HOME`), only sessions on a Mistral-served model, plus pi/omp and opencode sessions on the `mistral` provider |
| `qwen` | None (neither Qwen Code nor Alibaba publishes a way to read a Coding Plan or Token Plan quota) | Session transcripts under `~/.qwen/projects/*/chats` (`QWEN_HOME`, `QWEN_RUNTIME_DIR`, `advanced.runtimeOutputDir`): billed API responses on Alibaba's routes and typed prompts, plus pi, omp, and opencode sessions on Alibaba's Coding Plan, Token Plan, and Qwen OAuth providers |
| `opencode` | OpenCode Go's usage endpoint (rolling + weekly + monthly), with an API key or the Console session; a key without a Go plan shows local usage alone | pi and omp sessions (profiles included) on the Zen and Go providers, plus opencode's own `message` and `session_message` stores |
| `zai` | Z.ai's coding-plan monitor endpoint (5-hour session + 7-day weekly), for keys that carry a GLM Coding Plan | pi, omp, and opencode sessions on Z.ai's and Zhipu's providers (`zai`, `zhipu`, pi's `zai-coding-cn`, omp's `zhipu-coding-plan`, opencode's `zhipuai`, `zai-coding-plan` and `zhipuai-coding-plan`; `glm-*` models), plus Claude Code turns sent to Z.ai or answered by a `glm-*` model |
| `ollama` | Ollama Cloud's balance endpoint (5-hour session + 7-day weekly on a legacy plan, or the monthly included credits), plus any purchased credits left as a balance | pi, omp, and opencode sessions on the `ollama-cloud` provider, plus cloud-tagged models reached through the local daemon's `ollama` provider (Codex `--oss` rollouts included), Codex rollouts on a `model_providers` entry at ollama.com, and Claude Code turns sent to ollama.com or answered by a cloud-tagged model |
| `minimax` | MiniMax Token Plan API (5-hour session + 7-day weekly) | MiniMax Code's session files under `~/.minimax/v2/sessions`, plus pi, omp, and opencode sessions on a MiniMax provider, and Claude Code turns sent to MiniMax or answered by a `MiniMax-*` model |
| `openrouter` | Prepaid balance from `/credits`, key-limit meter from `/key`, each kept stale past a failed check | opencode and pi/omp sessions on the OpenRouter provider, Kimchi sessions run with `--provider openrouter`, DeepSeek Harness's `openrouter` route, MiniMax Code custom providers at openrouter.ai, and Claude Code turns sent to OpenRouter, with or without a key, or the `/activity` billing API with a management key |
| `deepseek` | Live prepaid balance from `GET https://api.deepseek.com/user/balance`, kept stale past a failed check, with the optional `fundedAmount` estimate for the funded-versus-spent line | pi/omp session files (profiles included) whose assistant messages ran on the deepseek provider, opencode sessions on a deepseek provider, DeepSeek Harness (`dsh`) session logs on its DeepSeek routes, and Claude Code turns sent to DeepSeek or answered by a `deepseek-*` model |
| `fireworks` | Prepaid balance: the live ledger when the key can read it, else configured funding minus rated account costs; kept stale past a failed check | Fireworks billing API, grouped by day and model for the last 30 days, cached per key and account |
| `synthetic` | Synthetic's `GET /v2/quotas`: rolling five-hour requests, weekly credits, hourly search, free tool calls | pi/omp sessions and opencode messages on the `synthetic` provider; Claude Code, MiniMax Code and Codex sent to `api.synthetic.new`, and Claude Code replies by `hf:`/`syn:` models with no override |
| `local` | None (self-hosted work has no meter) | Codex rollouts, pi/omp sessions and opencode messages on a local runtime, a provider named in `local.json`, or a Codex provider whose `base_url` is on the LAN, never a provider id another collector counts, plus Claude Code turns while `ANTHROPIC_BASE_URL` is self-hosted (not Claude models or cloud-tagged ones), and Kimi Code, Qwen Code, Hermes and Mistral Vibe requests sent to a self-hosted base URL |

Every collector follows the same rules, so the same situation reads the same for every agent: a recent answer is reused for 15 seconds unless refresh is pressed, each credential or account keeps its own last good answer, a failed check keeps it with its age on hover and windows that have since reset back at zero, an endpoint that can't be reached is retried soon, and an agent the machine doesn't use stays out of the panel. Tokens are counted once, under the provider that bills them: pi, omp, and opencode sessions are split by provider into the matching collector. A pi compaction's usage counts, but omp records only the context's size before and after one, not what its summary request used, so omp's compactions are missing from the tokens. pi and omp sessions are read from every profile, and from `PI_CODING_AGENT_DIR`, `PI_CODING_AGENT_SESSION_DIR`, and a `settings.json` `sessionDir` as well as the defaults when set, a forked session's copied messages once; opencode is read from both its `message` and V2 `session_message` stores in the database `OPENCODE_DB` names, a message migrated into both once and a fork's copied history not at all. A machine with none of an agent's home, CLI, or usage prints an empty record the panel skips; one that has them but no sign-in says it is waiting for one. The sections below cover where each agent's sign-in and data come from.

When `~/.local/state/omarchy/agents/accounts/<claude|codex|grok>.json` registers more than one account, the `claude`, `codex`, and `grok` records also carry `accounts: [{ id, label, email, plan, active, primary, limits, stale, fetchedAt, retryAdvised, usageStatusText, authHelpText }]`, each account probed with its own sign-in (each account caches its own last limits; Codex runs one app-server per account home), and `accountSwitch: { mode, threshold }`. The record's top-level `limits` and `tierLabel` keep describing the active account, and local stats stay one set, since every account shares the primary home's history. After each run, `omarchy-agent-usage-update` hands the fresh limits to `omarchy-agent-account-state autoswitch`, which notifies or switches when the active account crosses its threshold, and re-collects the record if the active account changed.

### Claude Code

Limits come from Anthropic's OAuth usage endpoint, asked with the access token the Claude Code CLI keeps in `.credentials.json` under `CLAUDE_CONFIG_DIR` (default `~/.claude`); the plan comes from the CLI's profile, else the credentials. Only the CLI refreshes that token, so one left to lapse reads "Limits paused" and keeps the last numbers until Claude Code runs again; a lapsed refresh token reads "Sign-in expired". Without credentials the panel says so and falls back to local stats only.

Local stats come from the CLI's transcripts under `projects/`, falling back to `stats-cache.json` and `history.jsonl` (the cache's days are UTC dates that stop at yesterday, so its daily tokens are approximate and rarely cover today), plus pi and omp sessions (honouring `PI_CODING_AGENT_DIR` and `PI_CODING_AGENT_SESSION_DIR`) and opencode sessions on the `anthropic` provider.

Only what Anthropic served counts here, and the collector that bills the rest counts it by the same rule (`claude_code_owner` in `collectors.py`), with the prompts it answered. Claude Code sends to whatever `ANTHROPIC_BASE_URL` names, and Z.ai, Ollama, MiniMax, DeepSeek, Kimi, OpenRouter, Alibaba's Model Studio ([Qwen](#qwen-code)), [Synthetic](#synthetic) and [Kimchi](#kimchi) (`kimchi claudecode`) document pointing it at their own APIs. A transcript doesn't record where it was sent, so while the `env` in `settings.json` (else the environment) points `ANTHROPIC_BASE_URL` at one of those providers' hosts, every reply is that provider's, earlier ones included. Otherwise the model that answered decides: a Claude model is Claude's (through a proxy or a local gateway too), an Ollama `:cloud` tag is Ollama Cloud's, a self-hosted base URL (Ollama's `localhost:11434`) makes any other model the `local` collector's, and with no override `glm-*` is Z.ai's, `MiniMax-*` MiniMax's, `deepseek-*` DeepSeek's, `kimi-*` and `moonshot*` Kimi's, and `hf:*` and `syn:*` Synthetic's. Any other model with no override (`qwen3-coder`), and any non-Claude model behind a host that can't be placed, counts nowhere. The `stats-cache.json` fallback drops non-Claude models the same way; the other collectors read only the transcripts.

A reply counts once by its message and request ids, across the transcripts a resume or fork copies it into; a `/btw` side question's sidechain replay of its parent's message, a whole copy under a new request id, counts under the parent, while a subagent's own reply counts even when a gateway gave it its parent's message id. A prompt is one a person sent: a main-thread user line that isn't a tool's result, Claude Code's own meta line, a compaction summary, a task notification, a local command's output, or a built-in that runs locally (`/model`, `/clear`, `/compact`, `/exit`, any command Claude Code answers with a `local-command-stdout` or `-stderr` line), plus a prompt typed mid-turn, which Claude Code queues as a `queued_command` attachment; a custom slash command or skill asks the model, and counts. Each counts once by its uuid, which a resumed or forked transcript keeps, so a tool loop's API requests are tokens, not prompts. Some requests have no reply line: a compaction (a `compact_boundary` line records only the context's size), the session title, and side queries such as Haiku's. Some replies are understated: a subagent's reply can be written with only its `message_start` usage (`stop_reason` null, a few output tokens), and its real output never is. Claude Code 2.1.278 and later write `cost-state` lines in some sessions, not all, the running totals per model of a process's cost lineage (its `startTime`, which a resume or `--fork-session` carries on), and what those hold beyond the replies of the lineage's sessions (subagents included) counts too, once per lineage, under the collector that bills that model, on the day of the cost-state that first holds it, not the day of the requests it makes up for. A process still running counts that usage when it next saves its cost, and a session with no cost-state, as every one before 2.1.278 is, has its compactions and understated subagent replies missing from the tokens.

Every collector reading the transcripts shares one index of them, which one brings up to date at a time while the others wait for it and then read it; an index that already holds every transcript as it is is read without waiting.

### Codex

Limits and the plan come from the Codex CLI's own app-server (`codex app-server`, `account/rateLimits/read`), started in each account's home (`CODEX_HOME`, default `~/.codex`) so it answers for that login and refreshes its tokens there. Every rate-limit bucket is read: the general windows, and any model's own allowance shown beside the window of the same span. An individual spend cap, such as a Business seat's, is its own "Spend limit" meter, the share of the cap spent with the reset time the app-server reports, since it names no period; it can come without any rate window. The plan reads as Codex's own `/status` names it (`pro` is Pro 200, `promax` Pro 500, `team` Business), and a plan newer than that table keeps its wire name. A home with no `auth.json` under the file store and no `CODEX_ACCESS_TOKEN` reads "Waiting for auth" without starting the app-server. An API-key login (`auth_mode` `apikey` in `auth.json`, or, with no `auth_mode`, an `OPENAI_API_KEY` there, ChatGPT tokens beside it or not, as Codex itself reads it) has no plan limits to read, so it starts no app-server either and shows local stats alone, with nothing to sign in to.

Each login keeps its last good limits, keyed by the workspace and user in `auth.json` (or the access token); a keyring login can't be told apart and keeps none. A stalled app-server, or one that couldn't reach OpenAI, is retried soon.

Local stats come from native session files on the built-in `openai` provider, pi and omp sessions on `openai-codex` (honouring `PI_CODING_AGENT_DIR` and `PI_CODING_AGENT_SESSION_DIR`), and opencode sessions on `openai`, from both of opencode's message stores and the database `OPENCODE_DB` names. A native session's tokens are its responses: one `token_usage_record` line each from Codex 0.163 on, a remote compaction's included, and before that each `token_count` event's last request. The thread-title requests interactive Codex sends are written to no rollout, so their (small) tokens are missing; `codex exec` sends none. A native session's prompts are the ones typed (a `UserMessage` item, or a legacy rollout's `user_message` event), not the requests that answered them, and a subagent's or guardian's thread types none and starts no session: its tokens count under the session that started it (its `session_id`, else its `parent_thread_id`).

Codex CLI will front any OpenAI-compatible backend — `--oss`, or a custom `model_provider` in `config.toml` aimed at Ollama, LM Studio, or a gateway — and those rollouts sit in the same sessions directory as OpenAI-backed ones. The Codex collector skips a rollout whose first `session_meta.model_provider` names anything but the built-in `openai` provider. Rollouts written before Codex recorded that field carry no provider and still count. A skipped rollout on a `model_providers` entry whose `base_url` is a provider's API (Z.ai, OpenRouter, DeepSeek, Moonshot or Kimi, Alibaba's Model Studio, MiniMax, ollama.com, [Synthetic](#synthetic), [Kimchi](#kimchi)'s gateway as `kimchi codex` sets it up) counts under that provider's collector, whatever the entry's id; one on your own hardware under Local models; and one behind a gateway nothing can place nowhere.

Codex also sends the built-in `openai` provider wherever `openai_base_url` in `/etc/codex/config.toml` or `config.toml` says (`OPENAI_BASE_URL` in the environment does nothing), and those rollouts still name only `openai`. While that `openai_base_url` names a provider's API, every built-in rollout counts under that provider's collector instead, earlier ones included. A profile's `<name>.config.toml` applies only to a run given `--profile`, so its `openai_base_url` decides only for the model it sets, when that is neither an OpenAI model nor the one `config.toml` sets: a profile naming a provider's API moves only that model's rollouts. Behind any other base URL OpenAI's own models (`gpt-*` but `gpt-oss`, `*codex*`, `o3`) still count here, since a proxy may forward them to OpenAI; any other model counts under Local models when the URL is self-hosted and nowhere when it is a gateway nothing can place. The current config decides; once the key goes, every built-in rollout is Codex's again.

### Grok

The plan comes from the settings Grok caches in its home (`GROK_HOME`, default `~/.grok`), and the limit from the credits endpoint its own `/usage` view reads, asked with each account's sign-in from `auth.json`. A lapsed access token with a live refresh token is routine: Grok renews it when it starts, so until then the limits read "Limits paused" with the last credits kept stale. A refused sign-in, or one past Grok's 30 days, reads "Sign-in expired". Local stats come from each session's `usage.json` and `summary.json`: a turn is a typed prompt, except in a subagent's session, and the turns a fork copies from its source count once; sessions on disk count Grok as in use even without a sign-in.

### Kimi

Kimi reads `KIMI_API_KEY` first, then `credentials/kimi-code.json` under an explicit `KIMI_CODE_HOME`. Without that override it prefers `~/.kimi-code/credentials/kimi-code.json`, with the legacy kimi-cli's `credentials/kimi-code.json` under `KIMI_SHARE_DIR` (else `~/.kimi`) as a compatibility fallback. An explicit home never borrows another home's sign-in. Kimi counts as in use when it has a credential or a Kimi home; a home without a sign-in waits for one, and a machine with neither stays hidden.

Local stats come from the log Kimi Code 2.x keeps for each agent of a session, subagents included, at `sessions/<workspace>/<session>/agents/<agent>/wire.jsonl` under its home (`KIMI_CODE_HOME`, else `~/.kimi-code`): every `usage.record` is one billed model request, compactions included, and every `turn.prompt` or `turn.steer` someone typed, slash commands included, is a prompt. A fork copies its source's log before marking it forked, so the copies count once, under the source's session. A request counts here when Kimi billed it: its model alias resolves through `config.toml` (`[models.<alias>]`'s provider, its `base_url` or the `*_BASE_URL` in its `env` table, or the model's own `base_url`), and Kimi's or Moonshot's API, a `kimi` provider with no `base_url`, or an alias the config doesn't name is Kimi's. A request on a server you run counts under Local models, and one on Anthropic's, OpenAI's or Google's API or a gateway nowhere. Each prompt goes with the next request sent for it, answered or not, else with the alias its agent was bound to, so a prompt a server you run refused counts under Local models too. The log records only the alias, so the current `config.toml` decides for every earlier request too. The legacy kimi-cli's own session logs aren't read. pi, omp, and opencode sessions on the Kimi Code plan count too: pi's own `kimi-coding` provider and omp's `kimi-code` (the plan's `api.kimi.com/coding/v1`) and models.dev's `kimi-code-plan-global` and `kimi-code-plan-cn`; Moonshot's pay-as-you-go API (`moonshotai`, `moonshotai-cn`, omp's `moonshot`) counts here too, although these limits don't meter it. Claude Code turns sent to `api.kimi.com`, `api.kimi.ai` or `api.moonshot.*`, or answered by a `kimi-*` or `moonshot*` model with no `ANTHROPIC_BASE_URL`, count here too, by the [Claude Code](#claude-code) rule, and that usage alone puts Kimi in use.

Expired tokens are refreshed under the current CLI's renewable directory lock at `<home>/oauth/kimi-code.lock`; legacy credentials use their sibling file lock. The rotated token pair is flushed and published atomically with private permissions. Credentials are reread after the exchange so a sign-in or logout completed during the request takes precedence. A failed lock prevents refresh, and credentials are sent only to trusted Kimi HTTPS hosts without following redirects. A refused token or refresh reads as Sign-in expired: run `kimi login`, or update or unset an overriding `KIMI_API_KEY`. Cache identity follows the token used by the request, and a refresh this collector performs carries the same account's previous limits forward. Different credentials or endpoints never share cached quota.

### Cursor

Cursor keeps no token counts on disk, so everything comes from the dashboard RPCs the Cursor CLI itself calls, asked with `CURSOR_AUTH_TOKEN`, else, with `CURSOR_API_KEY` exported, the access token the CLI traded that key for (the key itself is never sent), else the sign-in `cursor-agent login` stores in `~/.config/cursor/auth.json`, else the editor's in `~/.config/Cursor/User/globalStorage/state.vscdb` (read-only); `CURSOR_API_ENDPOINT` moves the endpoint, over https only (plain http only to this machine). A sign-in that has lapsed gives way to the next one that hasn't; with all of them lapsed the limits read "Limits paused" until the CLI or editor renews its token. A machine with Cursor installed but signed in nowhere says it is waiting for a sign-in; one without Cursor stays out of the panel.

The week of tokens is reused for 20 seconds (15 minutes on a near-limit refresh). A failed check keeps the account's last good meters, plan, and week of tokens. Tokens by day and by model cover the last seven local days, one aggregation call per day.

The meters are Cursor's own percentages, so they always agree with the Cursor dashboard. The included total is the Monthly row; the auto-bucket and named model meters and the on-demand budget run on the same billing cycle and show in its tooltip. Spend is never divided into an allowance here: bonus usage the model providers hand out is spend with no allowance behind it, so dollars over the plan limit read far past 100% while Cursor's own meters do not. The on-demand meter is the exception and is a real ratio: dollars spent against the on-demand limit the account sets.

### Grok Bot

Grok Bot runs on a Cursor account, but its weekly allowance is metered apart from Cursor's plan: the dashboard's `GetSandUsageStatus` RPC says how much of this week's included usage is gone, when it resets, and the Grok plan. It is asked as the same account the Cursor collector reads, found the same way (`CURSOR_AUTH_TOKEN`, the token traded for `CURSOR_API_KEY`, then the CLI's `auth.json`, then the editor's `state.vscdb`, read-only). Grok Bot keeps nothing countable on disk, so the record carries the limit alone, and an account without a Grok Bot allowance, or a machine without a Cursor sign-in, stays out of the panel.

### Copilot

GitHub exposes no supported personal-account usage API — its Copilot REST endpoints are organization- or enterprise-scoped — so the token sections come from what the Copilot CLI keeps under `~/.copilot` (or `COPILOT_HOME`). Its session store (`session-store.db`) records every billed request in an `assistant_usage_events` table: day, model, session, the token split, and the cost in nano AI units (1e9 nano units = 1 AI credit ≈ $0.01). A row is a billed request rather than a prompt; a current CLI marks the ones a typed prompt started (`initiator` "user", the agent's own follow-up calls "agent"), and those are the prompts, while an older store's counts stay out of the panel's prompt totals. A request sent to a custom provider (BYOK, `COPILOT_PROVIDER_BASE_URL`) carries no GitHub usage report and isn't Copilot's to count; the store doesn't say where it went, so it counts nowhere. CLI versions whose store predates it are served by the session transcripts under `session-state` instead, whose `session.shutdown` events carry the same per-model token split and cost.

The monthly meter is the account-wide allowance of AI credits from GitHub's internal quota endpoint (the same one the editor plugins ask), which counts every machine, IDE, and agent on the entitlement and names the plan and the reset date. It needs a token from `COPILOT_QUOTA_TOKEN`, `GH_TOKEN`, `GITHUB_TOKEN`, or `gh auth token`, and only runs where the Copilot CLI has been used, so a machine with `gh` signed in but no Copilot stays out of the panel. Each account keeps its own last answer, `gh`'s keyed by the user its `hosts.yml` names, so a reused answer doesn't run `gh` at all. Without any token the section says it is waiting for a sign-in. When the endpoint can't be asked at all, a budget in `~/.config/omarchy/agents/copilot.json` gives a meter labeled "(est.)" from this machine's CLI spend alone:

```json
{
  "monthlyCredits": 1500,
  "remote": true
}
```

`remote` set to `false` turns the quota probe off (and the sign-in reminder with it), and `true` runs it even without a Copilot CLI home. The estimated window resets on the 1st of each month at 00:00 UTC, GitHub's own boundary.

### Muse

Muse reads native CLI sessions from `$XDG_DATA_HOME/muse/sessions` (defaulting to `~/.local/share/muse/sessions`, and overridable via `MUSE_DATA_DIR`), with the real prompt and session counts from the CLI's `session-index.db` beside them (completions stand in when it is missing, and for a session it has no row for yet; since the index keeps each session's running prompt count, today's prompts are what each count grew by since the last scan before today), plus pi, omp, and opencode sessions on the `meta` provider and omp's `muse-code` (its Muse Code sign-in). Muse Spark through the OpenCode Zen gateway counts in the `opencode` record instead. The OAuth token comes from `MUSE_AUTH_PATH` when set, otherwise from `~/.config/muse/auth.json` (which `muse login` creates); the file is only ever read, never refreshed or rewritten. A Muse CLI set up on the machine without a login waits for one.

A session's subagent logs roll up into it. Every billed call a child agent made counts too: most children keep a log of their own, and one that doesn't (a skill reminder) is counted from the `goal_usage_attribution` record the session's log keeps for it, on the session's model, answering no prompt.

The collector asks the client's own key endpoint for the subscription's session and weekly percents with reset times — the same figures the TUI's `/usage` overlay shows. Minting is idempotent (the same Model API key comes back every call), so polling is safe; the token travels only in the `Authorization` header and neither it nor the returned key is persisted. `MUSE_KEY_ENDPOINT` moves the endpoint, over https only (plain http only to this machine). Pay-as-you-go accounts have no subscription windows and no plan name, so the tab shows measured local usage with no meters — never estimated, never zeroed. An active plan that returns no `subs_usage` (Muse Code Power Usage answers this way on every probe) behaves the same way, except the tab keeps the plan name.

### Antigravity

The record's id is `agy`, the name the default agent knows it by. The plan and limits are asked of Google's Cloud Code API with whichever Antigravity sign-in is on the machine: the one `agy` keeps in the Secret Service keyring (service `gemini`, username `antigravity`) or, without a keyring, in `antigravity-oauth-token` under `AGY_DIR`; omp's `google-antigravity` sign-in in `~/.omp/agent/agent.db`; pi's in `auth.json` (under `PI_CODING_AGENT_DIR` when set); and opencode's `google` sign-in, only when the Antigravity plugin's `antigravity-accounts.json` is there. The token refreshed most recently is asked first, and one Google refuses gives way to the next. Those stores are only ever read. A lapsed token shows the last limits as paused until the harness that owns it runs again; a lapsed omp sign-in is asked through `omp usage`, which renews it. Each Google account keeps its own last answer, so another account's limits never stand in. `CLOUD_CODE_URL` moves the endpoint, over https only.

Local stats count `agy`'s history prompts, its conversations (a subagent's conversation counts toward the one that spawned it), and the tokens each transcript step reports, under the model the step or the last Model Selection names. Antigravity answers that pi, omp, OpenClaw (`OPENCLAW_STATE_DIR`), and opencode's plugin recorded count too, a forked copy once. No other collector counts these.

### Kimchi

Kimchi reads `KIMCHI_API_KEY` first, then the key in `~/.config/kimchi/config.json`, and asks the gateway its region names (or `KIMCHI_BASE_URL`), which for a self-hosted login is `<selfHostedUrl>/llm` (or `KIMCHI_SELF_HOSTED_URL`), and with no host saved is nowhere: that key is never sent to the public gateway; its sessions follow `KIMCHI_CODING_AGENT_DIR`. The credits answer says how much remains but not how much was bought, so the balance shows the remaining figure without a funded meter; a spend budget's cap is what may be spent, not what was bought, so it never stands in. Every budget is a limit line that resets when its period ends, titled Monthly or Weekly when the period is one, with each capped provider inside it a tick on that line (or a line of its own in a period of another length). Each endpoint falls back on its own: when one can't be reached, its last answer stays up beside the other's fresh one. A rejected key reads as Sign-in expired; sign in again through Kimchi's own CLI. Sessions on disk without a key wait for one. Only sessions on Kimchi's own gateway routes count here; one run with `--provider openrouter` counts under OpenRouter, and one on a custom provider in `harness/models.json` counts nowhere. Usage other agents send through Kimchi's gateway counts here too: pi and omp sessions and opencode replies on the `kimchi`, `kimchi-dev` or `kimchi-experimental` provider, and Claude Code and Codex as `kimchi claudecode` and `kimchi codex` configure them, whatever the model, Claude and Kimi ones included. `kimchi claude` points only the Claude Code it starts at the gateway, through its environment, so those transcripts can't be told apart and count by their model's name (a `kimi-*` reply under Kimi, say); run `kimchi claudecode` once to have them count here. A self-hosted Kimchi gateway's host isn't recognized as Kimchi's, so Claude Code or Codex sent there counts as through any other gateway. An account out of credits keeps its balance shown and reads as Out of credits in the urgent color, with its help saying the gateway is rate limiting it until it has credits again.

### Hermes

Hermes Agent keeps its sessions in `state.db` in its home (`HERMES_HOME` with `~` and `$VAR`s expanded, else `~/.hermes` plus `HERMES_DATA_DIR_SUFFIX`) and in each named profile under its root's `profiles/`. The root is the default home unless `HERMES_HOME` lies outside it: then a `<root>/profiles/<name>` home makes `<root>` the root, and any other home is its own. The root is the default profile, so its own `state.db` counts even while `HERMES_HOME` points at a named profile. The default home `~/.hermes` is read as well, whole: its own `state.db` beside its `profiles/`. The collector reads them read-only: sessions, user prompts, and per-session, per-model token usage, including chats that arrived over messaging gateways. A session's tokens land on the day it started. Hermes records the provider and base URL each session and request was billed through, so the tab counts those Nous Portal billed, and those from before Hermes kept the route (a session with none goes where its first request did); a server you run counts under Local models, and any other provider, Hermes' `custom` gateways included, nowhere. Hermes has no subscription, so the tab shows local stats only. Without any `state.db` the tab stays hidden; a database that can't be read shows "Hermes unavailable" with the file and error on hover, while the other profiles still count.

### Devin

Devin's quota comes from the cache the Devin CLI writes each time it starts, `$XDG_CACHE_HOME/devin/cli/user_status.*.bin` (`DEVIN_CACHE_DIR`): the GetUserStatus answer it fetched, the same numbers its `/usage` command shows. The collector never makes a request of its own. Of the caches fetched since `credentials.toml` was last written, the newest wins, so a sign-in to another account never shows the last one's quota; until the CLI runs again after a sign-in, the panel says so. A cache more than fifteen minutes old still shows, marked stale with its age, and a window that reset since reads zero. The daily and weekly windows show unless the plan hides them, and a credit plan's prompt, flow and flex credits show as meters that reset when the plan period ends.

Local stats come from the CLI's `$XDG_DATA_HOME/devin/cli/sessions.db` (`DEVIN_DATA_DIR`), read-only: tokens by model from each assistant message's metrics, prompts and sessions from `prompt_history`. Builds that kept `cli_sessions.db` or `sessions.db` straight under `$XDG_DATA_HOME/devin` are read only when the CLI's own database is absent; they keep one lifetime total per session, which lands on its last active day. pi, omp, and opencode sessions on the `devin` provider count too.

### Mistral Vibe

Vibe saves sessions under `~/.vibe/logs/session` (moved by `VIBE_HOME`, or by `session_logging.save_dir` in Vibe's `config.toml`). Current Vibe runs every session on its Unified Harness, which keeps each one under `unified/<session id>/`: the running token totals are in the public state of the generation `CURRENT` names, with its journal folded in, and the session's `meta.json` names the model's alias, resolved against `config.toml`'s models and providers over Vibe's built-in default. Older releases wrote a `session_*` folder per session whose `meta.json` holds the running totals and the whole config it ran with, and those still count. Vibe drives other providers too, a local llama.cpp server out of the box, so a session only counts when the model it resolved to is served by Mistral's API: a provider with Vibe's `mistral` backend or a mistral.ai host. A session on a self-hosted `api_base` counts under Local models, and one on another provider's host or a gateway nowhere; a Unified Harness session's provider comes from the current `config.toml`, so it decides for earlier sessions too, while an older folder keeps the config it ran with. Totals are booked on the day a session started, a subagent's on the session that spawned it, and prompts are the user messages Vibe didn't inject itself (in a fork, not the history it copied). pi, omp, and opencode sessions on the `mistral` provider count here too. The plan is the one Vibe last cached from Mistral's whoami answer in `whoami_cache.json`, named as Vibe names it. Mistral publishes no usage limits, so the section shows local stats only.

### Qwen Code

Qwen Code writes each session to `projects/<project>/chats/<session>.jsonl` under `~/.qwen` (`QWEN_HOME`), or under `QWEN_RUNTIME_DIR` or the `advanced.runtimeOutputDir` setting when either moves it. Every billed API response is a telemetry line there with the model and the provider's token counts, the same lines Qwen Code's own usage statistics are rebuilt from, read by the same rules: the prompt count includes its cached part, and thinking is added to output only where the provider counts it apart. Typed prompts come from the user lines, and a branched session's repeated lines count once. A reply counts here when Alibaba billed it: Qwen Code records only its auth type, so its model's `baseUrl` in `settings.json`'s `modelProviders` says where it went, else the base URL Qwen Code resolves from the environment (`OPENAI_BASE_URL`, or `ANTHROPIC_BASE_URL` for its Anthropic auth type, read from `QWEN_HOME/.env`, `~/.qwen/.env` or `~/.env` and `settings.json`'s `env`, a project's own `.env` and the `--openai-base-url` flag being out of reach), Alibaba's hosts (`*.aliyuncs.com`, `*.alibabacloud.com`, `qwen.ai`) and a Qwen OAuth reply being Qwen's. A reply on a server you run counts under Local models; one on Anthropic's, Gemini's or Vertex AI's API, another provider's host or a gateway counts nowhere, and so does an OpenAI-compatible reply with no base URL in reach, which Qwen Code sends to OpenAI's API by default: an `OPENAI_BASE_URL` exported only from a shell profile is out of reach, so set it in one of those files for its replies to count. Each prompt goes with the next request sent for it, answered or not, else with the model `settings.json` selects (`security.auth.selectedType` and `model.name`), so a prompt a server you run refused counts under Local models too. The current settings and `.env` files decide for every earlier reply too.

pi, omp, and opencode turns that Alibaba's Qwen plans bill count here too, on exact provider ids: the Model Studio Coding Plan as `alibaba-coding-plan` (opencode and omp) and `alibaba-coding-plan-cn` (opencode's mainland-China one), the Token Plan as `alibaba-token-plan` (opencode and omp), `alibaba-token-plan-cn` (opencode), or `qwen-token-plan`, `qwen-token-plan-cn`, and `qwen-token-plan-individual` (pi), and omp's Qwen OAuth sign-in as `qwen-portal`. Alibaba's pay-as-you-go `alibaba` and `alibaba-cn` keys carry no plan and stay out. Claude Code sent to Model Studio's Anthropic-compatible endpoint (an Alibaba host in `ANTHROPIC_BASE_URL`) counts here as well, by the [Claude Code](#claude-code) rule.

There is no meter. Alibaba shows a Coding Plan's 5-hour, weekly, and monthly request quotas only on its console page and documents no API to read them, and Qwen Code reads none of its own, so nothing waits on a credential and the tab shows sessions and tokens alone.

### OpenCode

One record covers the OpenCode subscription, Zen and Go together: usage on the `opencode` and `opencode-go` providers. opencode sessions on an Anthropic or OpenAI provider stay in the `claude` and `codex` records, so nothing counts twice. Both of opencode's message stores are read (`message` and V2's `session_message`, deduplicated by message id, leaving out the copies a fork makes), from the database `OPENCODE_DB` names when set.

The Go meters read `OPENCODE_API_KEY` or `OPENCODE_GO_API_KEY` first, then the keys opencode keeps in its database and `auth.json`, then pi's (under `PI_CODING_AGENT_DIR` when set), then omp's, and last the OpenCode Console session, which asks Console's own endpoint with its workspace id. A refused credential hands over to the next one, and when every one is refused the record asks for a new sign-in. A rate-limited window reads as full. A key without a Go plan (Zen pay-as-you-go) is no trouble: the panel shows local token usage alone, and that key isn't asked again for an hour. Without any key, local usage shows the same way.

### Z.ai

Z.ai limits need a key that carries a GLM Coding Plan. A pay-as-you-go key reports "no coding plan", which is no trouble: the panel shows local stats alone, and that key is asked again only hourly, a failed recheck staying quiet. The key comes from `~/.config/omarchy/agents/zai.json`, then `ZAI_API_KEY` / `ZHIPU_API_KEY` in the environment, then pi/omp's `.env`, then the key pi or omp saved in `auth.json`. Set `platform` to `"zhipu"` in the config for the China (`open.bigmodel.cn`) host. Local stats count pi, omp, and opencode sessions on Z.ai's and Zhipu's providers (`zai`, `zhipu`, `zai-coding-cn`, `zhipu-coding-plan`, `zhipuai`, `zai-coding-plan`, `zhipuai-coding-plan`), and Claude Code turns sent to `api.z.ai` or `open.bigmodel.cn`, or answered by a `glm-*` model with no `ANTHROPIC_BASE_URL`, by the [Claude Code](#claude-code) rule, and MiniMax Code replies on a custom provider (its Z.AI preset) at those hosts.

### Ollama Cloud

Ollama Cloud reads `OLLAMA_API_KEY` first, then `apiKey` in `~/.config/omarchy/agents/ollama.json`, then the key pi or omp signed in with in `~/.pi/agent/auth.json` (or under `PI_CODING_AGENT_DIR`) or `~/.omp/agent/auth.json`. Each key keeps its own last good limits and plan.

Ollama's balance endpoint (`/api/balance`) reports a legacy plan's session and weekly windows as the percent remaining with their reset times, and a current plan's included credits as a balance against the monthly allowance, shown as an Included credits meter that resets when the period ends. Credits bought on top of the plan (`purchased.balance_usd`, the unexpired ones left) show as a balance of what remains; the answer says nothing of how much was bought, so it raises no low-balance alarm. The limits cover the whole account — every model the key can reach — while the local stats count pi, omp, and opencode sessions on the `ollama-cloud` provider, and cloud-tagged models (`glm-4.6:cloud`, `gpt-oss:120b-cloud`) reached through the local daemon's `ollama` provider, which run on Ollama's servers too, from Codex's `--oss` rollouts as well (with the prompts typed in them, and any model on a Codex provider named `ollama-cloud`), and Claude Code turns sent to `ollama.com` or answered by a cloud-tagged model, by the [Claude Code](#claude-code) rule. To count only the Claude models Ollama Cloud serves, set a model prefix in `~/.config/omarchy/agents/ollama.json`:

```json
{
  "modelPrefix": "claude",
  "apiKey": ""
}
```

`modelPrefix` restricts the local stats to models whose name starts with the prefix (empty means every model); `apiKey` is a key of its own, used when `OLLAMA_API_KEY` is unset.

### MiniMax

MiniMax reads `MINIMAX_API_KEY` first, then the API key or OAuth session saved by MiniMax's own `mmx` CLI if you use it, then the key opencode, pi, or omp stores when MiniMax is signed in there. A key is only ever read from MiniMax's own provider ids, never a look-alike such as a custom gateway. The host follows where the key came from: `mmx`'s own key uses the host `mmx` itself asks (its `base_url`, then its OAuth resource URL, then its region, which `MINIMAX_REGION` overrides), an opencode, pi, or omp key on a `minimax-cn` provider uses the China host, and anything else uses the global `https://api.minimax.io`; `MINIMAX_BASE_URL` overrides them all. The quota request never follows a redirect, so the key stays with MiniMax's host. The windows are the `general` quota's (or the first non-media model's), skipping any model mmx would call not in plan; a window MiniMax marks exhausted reads as full whatever percentage it still carries, and an unlimited one shows no meter. Local stats count MiniMax Code's own sessions under `MINIMAX_DATA_DIR`, `MAVIS_DATA_DIR`, or `~/.minimax` (user messages as prompts, assistant replies as tokens), only replies on MiniMax's own routes (`minimax` and `minimax_api`) and the prompts they answered; a reply on one of MiniMax Code's custom providers (`custom_provider:<name>`, its Z.AI and OpenRouter presets included) is billed by whoever runs that provider's `options.baseURL` in `config.yaml`, so it counts here at MiniMax's own host, under Z.ai, Ollama Cloud, DeepSeek, Kimi or OpenRouter at theirs, under Local models on this machine or the LAN, and nowhere for a gateway that can't be placed or a provider gone from the config (the current config decides for every earlier reply too). pi, omp, and opencode sessions on a MiniMax provider count too. Without a key the panel still shows that local usage and waits for one to show the limits.

### OpenRouter

OpenRouter reads `OPENROUTER_API_KEY` first, then the key opencode stores in `~/.local/share/opencode/auth.json`, then the key pi (`~/.pi/agent/auth.json`, honoring `PI_CODING_AGENT_DIR`) or omp (`~/.omp/agent/auth.json`) saved when OpenRouter is signed in there, then `apiKey` in `~/.config/omarchy/agents/openrouter.json`. Without any key, the local pi, omp, and opencode usage on the OpenRouter provider still shows, and the panel waits for a key to show the balance and meter. A management key in `OPENROUTER_MANAGEMENT_KEY` (or `managementKey` in that file, from `openrouter.ai/settings/management-keys`) switches the token history from the local scan to the account-global `/activity` API; on its own it also reads the balance, with no key-limit meter. OpenRouter documents `/credits` as management-key only, so an inference key it answers with 403 shows its key-limit meter without a balance and is no sign-in to redo; with a management key as well, that key reads the balance instead.

The collector reads the prepaid ledger from `GET /api/v1/credits` (`remaining = total_credits - total_usage`) and reports it as a live, non-estimated balance. OpenRouter documents that endpoint as management-key only, so it is asked once per refresh, with the management key when there is one; an inference key alone asks until OpenRouter refuses it that way, which shows no balance rather than a refused key, and then isn't asked again for a day. A key with a credit limit additionally gets a draining key-limit meter from `GET /api/v1/key`, labeled with how often the limit starts over. Each key keeps its own last good meter and balance.

Token history comes in two tiers, selected automatically by key type:

```json
{
  "apiKey": "",
  "managementKey": ""
}
```

Without a management key, tokens come from the local opencode database (`providerID == "openrouter"`, read-only), from pi/omp sessions whose assistant messages ran on the `openrouter` provider (and Kimchi's harness sessions run with `--provider openrouter`), from DeepSeek Harness attempts on its pi-ai `openrouter` route, from MiniMax Code replies on a custom provider at `openrouter.ai`, and from Claude Code turns while `ANTHROPIC_BASE_URL` points at `openrouter.ai`, by the [Claude Code](#claude-code) rule. With `OPENROUTER_MANAGEMENT_KEY` (or `managementKey` in `~/.config/omarchy/agents/openrouter.json`), the last 30 days come from `GET /api/v1/activity` instead: account-global per-day/per-model tokens that cover every machine and client. That record carries `"scope": "account"` and `hasPromptStats: false`, like Fireworks, so synced aggregation merges it by widest value instead of summing it.

### DeepSeek

DeepSeek reads `DEEPSEEK_API_KEY` first, then the key pi stores in `~/.pi/agent/auth.json` (under `PI_CODING_AGENT_DIR` when set), then omp's `~/.omp/agent/auth.json`, never a `!command` or `$VAR` entry, then the key opencode stores in its own `auth.json` when DeepSeek is signed in there, and last the key DeepSeek Harness keeps in `$DSH_HOME/.credentials.yaml` (or the `.env` beside it; `$DSH_HOME` defaults to `~/.dsh`). Each key keeps its own last balance. DeepSeek answers one balance per currency (CNY or USD), and the panel shows the one holding credit, or the first when none does. When DeepSeek says the balance no longer covers API calls (`is_available` false), or it is spent, the status reads Out of credits in the urgent color. Local usage also counts dsh's own session logs under `$DSH_HOME/sessions` on its DeepSeek routes (`deepseek-official`, `deepseek-account`, and its pi-ai adapter's `deepseek` route), leaving out the history a forked session inherits, and Claude Code turns sent to `api.deepseek.com` or answered by a `deepseek-*` model, by the [Claude Code](#claude-code) rule. dsh's other pi-ai routes are billed by that provider: its `openrouter` route counts under OpenRouter, and a hand-declared gateway counts nowhere. Its `fundedAmount` estimate lives in `~/.config/omarchy/agents/deepseek.json`, the same shape the fireworks collector uses; without it the panel shows the live remaining credit and skips the funded-versus-spent line.

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

Synthetic reads `SYNTHETIC_API_KEY` first, then the key pi stores in `~/.pi/agent/auth.json` (honoring `PI_CODING_AGENT_DIR` and `$ENV_VAR` keys), then omp's `~/.omp/agent/auth.json`, then opencode's `auth.json`. The collector asks the documented `GET https://api.synthetic.new/v2/quotas`, which doesn't count against the quotas. The rolling five-hour request limit and the weekly credits regenerate a little at a time, so they show how much is used with no reset time; hourly search and free tool calls reset when Synthetic says they renew. An account without the credit system shows the documented subscription request bucket instead. Local stats count pi and omp sessions and opencode messages on the `synthetic` provider, and through `scan_routed()` the Claude Code, MiniMax Code and Codex usage sent to Synthetic's API at `api.synthetic.new` (its Anthropic-compatible `/anthropic` and OpenAI-compatible `/openai/v1`, as its guides set them up), plus Claude Code replies by an `hf:` or `syn:` model with no `ANTHROPIC_BASE_URL` override.

### Local models

The Local models section counts work that ran on hardware you own: Codex rollouts, pi and omp sessions, and opencode messages whose provider is a well-known local runtime (Ollama, LM Studio, llama.cpp, vLLM, ...), a provider named in `~/.config/omarchy/agents/local.json`, or a Codex `model_providers` entry whose `base_url` is on a loopback, private, link-local or LAN address:

```json
{ "providers": ["homelab", "my-gateway"] }
```

A Codex rollout records its provider's id but not the URL it reached, so the collector remembers each `model_providers` endpoint it has seen in `/etc/codex/config.toml`, `config.toml` or a profile's `<name>.config.toml` (in `~/.local/state/omarchy/agents/local-codex-providers.json`), and a provider's history stays local after it leaves the config. Every provider collector reads the same map, so an entry at a provider's API counts there instead, after it leaves the config too. A provider only ever given with `codex -c model_providers...` or in a project's `.codex/config.toml` is never seen there, so name it in `local.json`.

It is the exact complement of the provider collectors: a provider id another collector counts is never counted here, whatever `local.json` says (that collector counts it, once), but for a Codex `model_providers` entry, whose `base_url` decides whatever its id, so one under a claimed id on your own hardware (a self-hosted Kimchi gateway's `kimchi codex` setup) counts here; and the Codex collector keeps every rollout on the built-in `openai` provider, but for the models of one that a self-hosted `openai_base_url` served (see [Codex](#codex)). Two providers are claimed only for some models, and only those rows are left out: Ollama's cloud models (a `:cloud` or `-cloud` tag) run on Ollama's servers even through the local daemon, so they count under Ollama Cloud instead, and opencode's Antigravity plugin records a `google` provider with `antigravity-` models, which the Antigravity collector counts. A Codex rollout's prompts are the ones typed, and a subagent's or guardian's thread starts no session, read as the Codex collector reads them. Claude Code counts here while `ANTHROPIC_BASE_URL` is self-hosted (Ollama's `http://localhost:11434`, a LAN box), for every model but a Claude one, which a local gateway forwards on to Anthropic, and a cloud-tagged one, by the [Claude Code](#claude-code) rule; so do MiniMax Code replies on a custom provider whose `baseURL` is self-hosted, and, by the same rule, Kimi Code, Qwen Code, Hermes and Mistral Vibe requests whose recorded base URL is self-hosted, read by each one's own collector. There are no limits or balance.

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
