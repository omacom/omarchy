# Agent Usage Collectors

Every agent or provider in the agents panel is a collector: `bin/omarchy-agent-usage-<id>`, a Python script that prints one JSON record. `omarchy-agent-usage-update` finds collectors by globbing `bin/omarchy-agent-usage-*`, runs them, and the panel (`shell/plugins/agents/Main.qml`, `Panel.qml`) reads the records. This is the contract every collector follows, so that each agent behaves the same in the panel. `bin/omarchy-agent-usage-claude` is the reference implementation.

New collectors build on the shared module, [`shell/plugins/agents/collectors.py`](../shell/plugins/agents/collectors.py), which holds the parts of this contract every collector shares. A collector keeps only what is its own: its credentials, its endpoint and how to read it, its provider filter, and the specifics of its record.

## The command

- `#!/usr/bin/python3`, two-space indentation, and the header lines `# omarchy:summary=...`, `# omarchy:args=[--force] [--limits-only]`, and `# omarchy:hidden=true`.
- argparse accepts `--force` and `--limits-only`, and both mean something:
  - A normal run reuses a local scan for `SCAN_REUSE_SECONDS = 20` and a limits probe for `PROBE_MIN_INTERVAL_SECONDS = 15`.
  - `--limits-only` (the panel's near-limit refresh) reuses a local scan for `LIMITS_ONLY_REUSE_SECONDS = 900`, but asks for limits like a normal run.
  - `--force` (a person pressing refresh) reuses nothing.
- The record is printed on stdout. Diagnostics go to stderr and never carry a credential.
- A collector never writes to an agent's own files. Credentials are only read, and a token is refreshed only where the agent's own CLI does the same under its lock, never by rewriting another harness's store.

## The shared module

The module ships with the agents panel in the omarchy package. A collector loads it from `$OMARCHY_PATH`, never from a path derived from its own file or `$HOME`:

```python
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
from collectors import Stats, base_record, cached_scan, ...
```

Its main entry points, each documented where it is defined:

- `base_record(id, name, **fields)` and `emit(record)`: the record with every field and the zeroed stats block, as an unused machine prints it, and printing it.
- `Stats(today=None)`: `add(day, session, model, input, output, cache_read, cache_write, prompts=1)` tokens and the prompts they answered (or `add_row()` one row from a reader), `add_prompts(day, session, count=1)` prompts a store books apart from their tokens, and `snapshot()` the record's stats fields. A store that books prompts on their own passes `prompts=0` with the tokens; one keeping running totals passes how many prompts they cover. A `day` of `None` counts toward the lifetime totals alone, a `session` of `None` toward no session, and zero tokens make no model bucket. `today` dates the record against another day (a `date` or an ISO day).
- `cached_scan(id, sources, max_age, scan, match=None, with_complete=False)` with `scan_max_age(force, limits_only)`: the per-day scan cache under `flock`, reused for 20, 900, or 0 seconds, never caching an incomplete scan. `with_complete=True` answers `(stats, complete)`, a cached scan being a complete one.
- `scan_pi_sessions(pattern, accept, roots=None)` and `scan_opencode(providers, accept)`: the pi/omp and opencode readers, handing back deduplicated `UsageRow`s for the replies the collector's `accept(provider, model, entry)` takes. `roots` reads other pi-format trees instead of `pi_session_roots()` (a harness's own, or pi's and omp's with another beside them), through `canonical_roots()`; a collector that passes them keys its scan cache by the same roots.
- `LimitsCache(id, *identity, kind="limits")`: one credential's last good answer at `<id>-<kind>-<key>.json`, with elapsed windows zeroed, `fresh(force, seconds=15, allow_empty=False)` for the probe reuse, `kept()` for the stale fallback, and `save(limits, only_if_newer=False, **extra)`. `kind` keeps another answer beside the limits under the same key (credits, a balance, usage rows); `allow_empty=True` lets any answer stamped inside the age guard stand in, limits or none; `only_if_newer=True` leaves a file another run stamped later alone. `LimitsCache.at(path)` opens one under a name that predates the shared one.
- `open_json(request)` and `HttpError`: a request that refuses redirects and says whether a failure was a refusal (`status`, with its `headers`), a transport failure (`transport`, the only cause for `retryAdvised`), a reply cut short (`cut_short`), or an invalid answer. See [Limits](#limits) for where the line falls.
- `cursor_token(auth_path=None, state_db=None)`, with `jwt_claims()`, `token_lapsed()`, `account_key()` and `finite()`: the Cursor account the Cursor and Grok Bot collectors both ask as (an exported `CURSOR_API_KEY`, the CLI's `auth.json` at `CURSOR_AUTH_PATH` or its default, then the editor's `state.vscdb`, a lapsed sign-in giving way to one that isn't), and reading any JWT's claims, expiry and subject.
- `registered_accounts(id)` and `account_entry(account, limits, plan, **extra)`: the accounts `omarchy agent account` registered, and one entry of the record's `accounts`.
- `local_day()`, `token_count()`, `usage_tokens()`, `number()`, `now_ms()`, `stamp()`, `age_below()`, `read_json()`, `write_json()`, `cache_root()`: reading untrusted values and files the same way everywhere.

`test/shell.d/agent-usage-shared-test.sh` holds the module to this contract directly. Something goes in the module only once two collectors need it.

## The record

| Field | Meaning |
|---|---|
| `schemaVersion` | `1` |
| `id`, `name` | The id matches the filename; `name` is the product name |
| `updatedAt` | ISO time the record was made |
| `ready` | `true` once the agent is in use on this machine (a credential or local usage) |
| `tierLabel` | The plan as the service names it, or `""`; never a placeholder or a guess. `"Prepaid"` is special to the panel |
| `usageStatusText`, `authHelpText` | See [Status](#status) |
| `limits` | `[{label, percent, resetsAt, title?}]`, `percent` in 0..1, `resetsAt` ISO or `""`, never `null`. Add `title` (Session, Weekly, Monthly) when the label doesn't parse as one |
| `limitsStale`, `limitsFetchedAt` | Whether `limits` were kept past a failed check, and when they were measured (epoch ms, `0` when never) |
| `retryAdvised` | `true` only when the service couldn't be reached at all (DNS, connection, timeout), so the panel retries this agent in 30 seconds |
| `balance` | `{remaining, funded, spent, currency, estimated}` for prepaid accounts |
| `accounts`, `accountSwitch` | Only when two or more accounts are registered; each account carries `limits`, `stale`, `fetchedAt`, `usageStatusText`, `authHelpText` |
| `hasLocalStats` | Whether the stats below come from this machine |
| `hasPromptStats` | `false` when the source has no real prompt or session counts (an API that counts requests, not prompts) |
| `scope` | `"account"` when the stats are account-wide rather than this machine's |
| Stats | `todayPrompts`, `todaySessions`, `todayTotalTokens`, `todayTokensByModel`, `recentDays` (seven `{date, messageCount}`, where `messageCount` holds tokens), `totalPrompts`, `totalSessions`, `activeDays`, `activeDates` (every date), and `modelUsage` buckets of `inputTokens`, `outputTokens`, `cacheReadInputTokens`, `cacheCreationInputTokens` |

The full stats block is always present, zeroed when there is nothing. An agent the machine doesn't use prints `ready: false` with empty stats, no limits and no balance, and the panel skips it. That's the normal answer for a missing credential on an agent with no local usage; it isn't an error.

## Status

The panel acts on a small vocabulary in `usageStatusText`, so the same situation reads the same for every agent:

| Status | When |
|---|---|
| `""` | Healthy, or a failed check that kept the last good limits (`limitsStale` says the rest) |
| `"Waiting for auth"` | The agent is in use but has no credential for its limits |
| `"Sign-in expired"` | The credential was refused, or a refresh token lapsed; signing in again is needed |
| `"Limits paused"` | An access token lapsed that the agent's own CLI renews the next time it runs; signing in again is not needed |
| `"<Name> limits unavailable"` | A check failed with nothing kept to show |
| `"<Name> unavailable"` | The agent's stats source failed (an unreadable database, a billing API that answered nothing) with nothing kept to show |
| `"Balance unavailable"` | A prepaid balance couldn't be read and none was kept |

The detail goes in `authHelpText`: what failed and the one thing to do about it. It is `""` when healthy. A plan the service doesn't offer limits for (pay-as-you-go, no Go plan, a free tier) isn't trouble: the status stays `""` and local stats show alone. Any other status shows under the name in the urgent color, so collectors don't invent new ones.

## Limits

- Each credential or account caches its own last good answer at `cache_root() / "<id>-limits-<key>.json"`, `{fetchedAtMs, limits, ...}`, where `cache_root()` is `$XDG_CACHE_HOME/omarchy/agent-usage` and `<key>` is a short hash of who the credential signs in as (a JWT subject, an email, an account id) or of the credential itself. Another sign-in never shows this one's numbers. An answer of another kind from the same credential (credits, a balance) sits beside it as `<id>-<kind>-<key>.json`.
- An answer stands in for a probe for 15 seconds, even one with no windows (a plan without quotas, credits, a balance), so long as the collector keeps it. Refreshes can overlap, so an answer that only replaces one fetched before it never rolls a newer one back.
- Where a failed check falls decides `retryAdvised`:
  - A connection that fails or drops before any reply (no DNS, no route, refused, reset, a timeout, a server hanging up without a word) is transport: nothing answered, so `retryAdvised: true` asks the panel to try again soon.
  - A reply that arrived but was cut short or garbled on the way (`http.client.HTTPException`: an incomplete read, a bad status line) is an answer, `cut_short` and not `transport`, so there is no sooner retry. Neither is there for an error status or a body that isn't the expected JSON.
- The cache is read whatever its file time, so a clock that went back doesn't lose it, and every age check is `0 <= age < N`. Stamps are floored (`int(time.time() * 1000)`), never rounded: a stamp half a millisecond ahead reads as a clock that went back, and the next run probes again.
- A failed check keeps the cached limits with `limitsStale: true` and their `limitsFetchedAt`. The panel shows their age on hover.
- A kept window whose `resetsAt` has passed comes back at `percent: 0` with `resetsAt: ""`, never dropped: a reset allowance is untouched, not unknown. A window with no reset time is kept as it is. Reset times are only ever the service's own, never computed.
- A meter for a balance or allowance is a real ratio of the service's numbers, never estimated from local usage unless its label says `(est.)`.

## Local stats

- Tokens are counted once, under the provider that bills them. pi, omp, and opencode sessions are split by provider into the matching collector; there is no harness tab that counts them again.
- pi and omp sessions live under `~/.pi/agent/sessions` and `~/.omp/agent/sessions`, plus `profiles/<name>/agent/sessions` under each. `PI_CODING_AGENT_DIR`'s sessions and `PI_CODING_AGENT_SESSION_DIR` are read as well as those defaults, never instead of them; roots are compared by realpath, and one nested inside another is dropped. They are found with `rg --no-ignore`, since a `$HOME` that is a git checkout would otherwise hide them. A message is deduplicated by `(id, timestamp)` when it has both, so a forked session doesn't count its parent's messages again, and a line without an id always counts. A row with no time is today's; a row whose time is untrusted, zero included, counts nowhere.
- opencode is read from both its `message` store and V2's `session_message`, V2 first, deduplicated by message id, leaving out the copies a fork makes (`session_v2.fork_session_id`), with compactions counted like replies. The database is `OPENCODE_DB` when set (or the older `opencode-v2.db`), opened read-only. `scan_opencode` in the shared module is the reference reader, and `test/shell.d/agent-usage-partition-test.sh` holds every collector to it.
- Timestamps and token fields from disk are untrusted: a zero, huge, negative, `NaN`, boolean or non-numeric value skips that field or row, never the record.
- A scan is cached per day (`scanDate`) and rebuilt under `flock`, and a scan that couldn't read all its sources isn't cached.

## Assets, docs and tests

- `shell/plugins/agents/assets/<id>.svg`, plus `<id>-light.svg` when the mark is white and needs a dark twin for light surfaces.
- A provider entry in `shell/plugins/agents/manifest.json`, a row in the README's collector table, and a `###` section in the README naming where its credentials and data come from.
- `test/shell.d/agent-usage-<id>-*-test.sh` covering at least: the record an unused machine prints, fresh limits, stale limits after a failed check, an elapsed kept window at zero, the probe reuse and `--force`, and `retryAdvised` on an unreachable service.
