# Testing

How the non-graphical test suites are organized: what each runner owns, the
protocol test files speak, and the conventions that keep them runnable on any
machine — including headless CI sandboxes with no compositor. The graphical
acceptance suite is a separate thing that drives a live session in a disposable
VM; see [`agents/skills/acceptance-tests.md`](../agents/skills/acceptance-tests.md).

## Suite map

`./test/all` runs both suites below and keeps going when one fails, so a single
failure cannot hide the other suite behind it. It reports the failed suites at
the end and exits non-zero.

- **`./test/cli`** — one big script, one suite. It owns the CLI router: help
  and group rendering, route resolution, aliases, hidden commands, and the
  guarantee that a trailing `--help` never executes the target. It also owns
  the metadata lint — every `omarchy-*` executable under `bin/` is checked for a
  `# omarchy:summary=` header and against removed or redundant fields — plus
  the theme pipeline: template rendering (`omarchy-theme-set-templates`,
  `omarchy-theme-color`, `omarchy-theme-osc`), the theme sync commands
  (tmux, GNOME, VS Code, Pi, Claude) run against stub binaries and a fake
  `$HOME`.
- **`./test/shell`** — runs every `test/shell.d/*-test.sh` (except
  `base-test.sh` itself). Each file is an independent suite covering one area:
  a shell plugin, a `bin/` command, or a config invariant. This is where new tests go.
- **Acceptance** — everything that needs a real desktop doing real things.
  Deliberately excluded from `./test/all`; it runs in a VM, not the
  development session.

A new shell test only needs the right name: drop `<area>-test.sh` into
`test/shell.d/` and `./test/shell` picks it up automatically. Shared fixtures
live under `test/shell.d/fixtures/`.

## The base-test.sh contract

Every shell test starts the same way:

```bash
#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
```

`base-test.sh` refuses to be executed directly — it is a library. It discovers
the repo root from its own location and exports it as `ROOT`, so tests
reference files as `$ROOT/bin/...` and never depend on the caller's working
directory or an installed Omarchy.

Assertions are TAP-flavored and blunt:

- `pass "description"` prints `ok - description`.
- `skip "description"` prints `ok - description # SKIP`. Include why the check could not run. Like `pass`, it returns normally; use `exit 0` afterwards only when the rest of the file cannot run either.
- `fail "description" [detail]` prints the optional detail and
  `not ok - description` to stderr, then **exits the file**. There is no
  counting or continuing within a file: the first failed assertion ends it,
  which keeps later assertions from reporting against state the failure
  already invalidated.
- `require_command <cmd>` fails the file when a needed tool is absent.

The runner compensates for that early exit: `./test/shell` continues past a failing file and summarizes the failures at the end. Aborting the whole run at the first bad file once let a single packaging failure mask 114 of 134 files. Failure granularity is therefore per file inside a run, per assertion inside a file.

Each file's output is kept in a fresh directory under `$TMPDIR` (`omarchy-test-shell.*`), whose path the runner prints at the end, next to each failed file. Read a failure from its log there; running the suite again only to see output is never needed.

Two harnesses cover tests that start Quickshell. Both sit behind `require_quickshell "description"`, which needs a compositor, `quickshell` and `jq`, and skips the file without the first two.

- `run_qml_fixture <fixture> <description> [Ui|Commons|services ...]` runs `fixtures/<fixture>/*.qml` as a Quickshell config, with those `shell/` directories linked in and a scratch `HOME`, and passes when the fixture writes `{"ok": true}` to `$OMARCHY_QML_TEST_RESULT`. Otherwise it fails with the fixture's result and log. Extra environment goes before the call (`FOO=bar run_qml_fixture ...`); stubs go in `$QML_FIXTURE_TMP/bin` after `qml_fixture_scratch`; the log stays at `$QML_FIXTURE_LOG` for checks after it.
- `setup_scratch_shell` builds a second Omarchy shell on a scratch copy of `shell/` and a scratch `HOME`, with stay-awake set and stubs that keep it off the real session's watchers, power profile and login-shell `PATH` reset. `start_scratch_shell`, `wait_scratch_shell`, `scratch_ipc` and `wait_scratch_layer <namespace> mapped|absent` drive it; `reset_scratch_home` empties `HOME` for a cold start; on exit it is stopped along with every process it left behind.

`base-test.sh` unsets `XDG_CONFIG_HOME`, `XDG_CACHE_HOME`, `XDG_DATA_HOME` and `XDG_STATE_HOME`, so a test that points `HOME` at a scratch directory cannot reach the real home through them; a desktop session exports all four. A test that needs one sets it itself.

The runner also lists files with skipped checks, including files that ran some checks or later failed. Skips do not fail a run. When no files fail, a run with skips is reported as completed without failures rather than having passed every check.

## Compositor-dependent tests

Some tests launch Quickshell or query Hyprland, but the suite must stay green on headless machines. `require_compositor "description"` handles this: when no compositor answers it calls `skip` with the reason and exits 0, and otherwise returns so the file proceeds. The skip marker lets the runner distinguish unavailable runtime coverage from checks that passed.

The probe is more than an environment check, because `WAYLAND_DISPLAY` only
proves the variable was inherited. Sandboxes pass the environment through
while blocking `$XDG_RUNTIME_DIR`, so Quickshell clears a bare variable check
and then aborts inside QGuiApplication — a core dump per launch where a skip
belonged. So `compositor_reachable` checks the socket actually exists, then
asks Hyprland itself (`hyprctl -j monitors`, retried, and only when
`HYPRLAND_INSTANCE_SIGNATURE` makes it askable), since a compositor that died
mid-session leaves its socket behind. When the compositor is reachable,
`require_compositor` also sets `ulimit -c 0`: Quickshell leaves through
`qFatal()` if its connection drops mid-run, and the test should fail without
writing a core dump as debris.

Gate only what needs gating — put `require_compositor` in files whose runtime
half needs a live session, and keep static analysis of the same area in code
that runs unconditionally before or beside it.

## Performance guards

A handful of tests fail when a fast path gets slow again. Each prefers a count that is the same on every machine over a wall-clock time. Where it has to time something it takes the fastest of several runs, and either compares two paths timed in the same run or scales its budget with `process_speed_percent` from `base-test.sh`: how long 100 fork/execs take here against the 25ms they take on the laptop the budgets were set on. A machine more than 8x slower skips the timing (`require_comparable_speed`) rather than guess.

- `test/shell.d/shell-idle-spawn-test.sh` starts a second shell on the default config, waits for its startup work to go quiet, then fails if it starts any process over 30 idle seconds, naming each command line. A preloaded shim (`fixtures/idle-shell/exec-log.c`, built with `cc` at test time) logs every exec, fork and spawn the shell and its descendants make, so a probe that lives for a millisecond is caught, and nothing outside the shell's process tree can be. A command that legitimately runs while idle is allowed with `allow` in that file, only while its reason holds and at most as often as the reason implies. The test watches Hyprland, UPower and NetworkManager events meanwhile; a spawn that coincides with one is given a second window before it fails, and the events are printed with it. The test shell gets stubs for everything that would act on the session (signals, power profiles, `bash -l`). Compositor-gated, and skipped without a C compiler.
- `test/cli` times `omarchy screenshot` against help for it on a copy of the real command table, and fails unless the alias dispatch costs under a quarter of the full load (13ms against 190ms today).
- `test/shell.d/menu-guard-budget-test.sh` runs the shipped menu's guard batch on this machine's real hardware: the batch within 200ms (about 50ms today) and each guard alone within 100ms (the slowest is about 30ms), scaled to the machine, listing the slowest guards when either fails. Skipped without `$XDG_RUNTIME_DIR`, which holds the package snapshot the menu relies on.
- `test/shell.d/theme-set-budget-test.sh` runs the whole `omarchy-theme-set` in a scratch home where every app is a stub given its real cost (a running Hunk, VS Code's Electron boot, three tmux sessions). It fails when either theme's switch takes over 500ms scaled to the machine (about 80ms today), starts more than a handful of tmux clients, starts VS Code to list its extensions, or waits for Hunk's settle nudge.
- `test/shell.d/bar-startup-budget-test.sh` starts a scratch shell through `bin/omarchy-launch-shell`, as uwsm does at login, on an empty home, and times it until the compositor maps the default bar at a real size: the fastest of three cold starts within 750ms scaled to the machine (about 280ms today). Greetd and the compositor's own start are left to acceptance testing. Compositor-gated, and it reads the live session, so a busy desktop can fail it.
- `test/shell.d/lock-appear-budget-test.sh` times the lock preview surface, which renders the real LockView without engaging the session lock: the lock service answering within 750ms of shell start and the first appearance within 300ms, each the fastest of three cold starts, and a reappearance within 150ms, the faster of two, all scaled to the machine (about 130ms first and 45ms again today). Compositor-gated, and it reads the live session, so a busy desktop can fail it.
- `test/shell.d/menu-open-budget-test.sh` times a warm menu summon until the compositor maps its surface at a real size: the fastest of three within 150ms scaled to the machine (about 40ms today). Compositor-gated, and it reads the live session, so a busy desktop can fail it.
- `test/shell.d/panel-open-budgets-test.sh` times each bar panel (audio, Bluetooth, monitor, network, and power where there is a battery) from its IPC open until the compositor maps it: the first open, which builds the panel's content, within 400ms and the faster of two reopens within 150ms, scaled to the machine (about 30 to 60ms for both today). Compositor-gated, and it reads the live session, so a busy desktop can fail it.

Override a budget through the environment variable named at the top of each file when measuring something slower on purpose.

## Companion checkouts

Some checks hold Omarchy's scripts against the packages in the separate omarchy-pkgs repository. `find_omarchy_pkgs` sets `OMARCHY_PKGS_ROOT` to that checkout's `pkgbuilds/` directory. When `OMARCHY_PKGS_PATH` is set, only it (the checkout or its `pkgbuilds/`) is tried, and an override that doesn't resolve fails the test, so a typo never turns package checks into skips. Without the override, the usual places beside this checkout and `~/Work/omacom` are tried; finding none returns 1, and the test skips only the checks that need it, the same way a missing compositor is handled, so the suite stays green on a machine with just this repository. Point `OMARCHY_PKGS_PATH` at the checkout when running from a worktree or an unusual location.

## Unit-testing shell JavaScript from bash

The Quickshell plugins keep their logic in plain `.js` modules
(`shell/plugins/menu/MenuModel.js`, `bar/BarModel.js`, ...) that end in a
guarded `if (typeof module !== "undefined") module.exports = {...}` block. QML
imports them directly and ignores the guard; Node loads them as CommonJS. That
dual citizenship is what makes the shell's model logic unit-testable without a
compositor.

`run_node_test` is the bridge: it prepends a JS prelude to a heredoc and pipes
the result into `node`. The prelude mirrors the bash assertion protocol
(`pass`, `fail`, `assert`, `assertEqual`, `assertDeepEqual` — same
`ok`/`not ok` lines, same exit-on-first-failure) and provides `root` (from the
exported `ROOT`), `path`, and `requireFromRoot(relativePath)`:

```bash
run_node_test <<'JS'
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')

const parsed = menu.parseMenuJsonc('{ "items": { "root": { "label": "Go" }, }, }')
assertEqual(parsed.length, 1, 'menu parses JSONC with trailing commas')
JS
```

Roughly a quarter of the shell test files use this to test parsing, merging,
and layout logic as pure functions, reserving compositor-gated tests for what
only a live session can prove.

## Agent usage collector tests

The collectors behind the agents panel (`bin/omarchy-agent-usage-*`, see [`agent-usage-collectors.md`](agent-usage-collectors.md)) share two layers of tests, and every collector's own test builds on two shared helpers rather than its own copies.

The shared layer covers what every collector does the same way. `agent-usage-shared-test.sh` holds the shared module, `shell/plugins/agents/collectors.py`, to the contract directly: untrusted numbers and times, the record's shape, the scan and limits caches and their locks, HTTP failure classes, and the pi, omp, opencode, Claude Code and Cursor readers, with the rule that says who bills a Claude Code reply. `agent-usage-partition-test.sh` runs every collector against one machine holding usage on every provider, so it holds each one to the unused-machine record and to counting its own provider's tokens exactly once from every root and store, and each Claude Code reply once behind every endpoint Claude Code can be sent to. A collector's own test doesn't repeat either; it covers its own sources, its credentials, how it reads its service's answer, and its adapter for the contract checks below.

`test/shell.d/agent-usage-helpers.sh` is sourced after `base-test.sh`. It is not named `*-test.sh`, so the runner never runs it on its own.

- `agent_sandbox` creates `$SANDBOX` with one EXIT trap (which also stops processes handed to `track_pid <pid>...`), exports `HOME` and every `XDG_*` directory under it, unsets every developer variable naming an agent credential or store (any `*_API_KEY`, and prefixes like `CLAUDE_`, `CURSOR_`, `PI_CODING_AGENT_`, `OPENCODE_`, `MISE_`; the bash and Python lists are checked to match), points HTTP proxies at a dead port so nothing reaches a real service, and puts the Python fixtures on `PYTHONPATH`.
- `new_home [name]` prints a fresh home under the sandbox with its XDG directories and a `bin/` for stubs.
- `run_collector <home> <id> [VAR=value ...] [-- args...]` runs a collector as a process under `env -i`, seeing only that home, `OMARCHY_PATH`, the caller's `TZ`, the dead proxy, the given variables, and a `PATH` of `<home>/bin` plus python3, rg, jq and sqlite3. It runs with `--force` unless arguments follow `--`, prints the record, and leaves stderr in `<home>/.run/<id>.err`.
- `expect_jq "<description>" '<filter>' '<expected>' "$json"` passes when `jq -c` of the filter prints exactly the expected text, and fails showing both and the JSON.
- `stub_cli <home> <name>` writes `<home>/bin/<name>` from the body on stdin, and `fake_codex <home> [mode]` a stand-in Codex app-server whose answer `CODEX_FAKE` picks (`ok`, `backend`, `auth`, `empty`, `died`, `crashed`, `silent`, `stall`), logging every start to `<home>/codex-starts`.
- `age_scan_cache <file-or-id> <seconds>` moves a scan cache's stamp into the past (or, negative, the future), and `edit_limits_cache <id> <jq-filter>` rewrites every limits cache of a collector with `$now_ms`, `$past` and `$future` at hand, so no test sleeps for a window to pass.

`test/shell.d/agent_usage_fixtures.py` is the Python half, imported from a heredoc with `from agent_usage_fixtures import *`. It finds files through `ROOT` and `OMARCHY_PATH`, never its own location or `HOME`, and writes no bytecode.

- `check(description, condition, detail="")` and `expect(description, actual, expected, record=None)` print the same TAP lines as the bash assertions and end the test on the first failure.
- `sandbox(root=None)` points `HOME` and every XDG directory at a fresh directory and drops the developer variables; `home()`, `data_home()`, `config_home()`, `state_home()` and `cache_root()` name its places.
- `load_collector(id)` loads a collector as a fresh module, `run_main(module, *args)` runs its `main()` and returns the record it printed, and `collect(id, *args)` does both.
- `FakeHttp(routes, mode="up")` replaces `urllib.request.urlopen`, the one door every collector request goes through. Routes map a URL substring to a payload, raw bytes, an HTTP status, an exception, or a callable taking the request; `mode` fails every request at once (`down`, `timeout`, `reset`, `cut`, `garbage`, or a status), and `requests` logs each one. `stub_server(handler, tls=False)` serves a real loopback socket instead, carrying every `https://` request to it with `tls=True`.
- Builders for what collectors read: `iso_in`, `ms_in`, `today_stamp` and `jwt`; `pi_reply` and `write_pi_session`; `claude_code_session` (a Claude Code transcript, and where `ANTHROPIC_BASE_URL` sends it); `oc_v1`, `oc_v2`, `opencode_db` and `oc_add`; `cursor_state_db`, `pi_auth`, `opencode_auth`, `registry` and `write_json`; and `limits_cache_files`, `scan_cache_files`, `edit_limits_cache`, `age_scan_cache` and `edit_scan_cache` for the caches.

A collector test describes its collector once, as an `Adapter`, and hands it to `check_limits_contract` and `check_scan_cache`. The adapter names the collector, a `plant()` that signs the sandbox in, and the healthy service's `answer` as FakeHttp routes; a collector that talks to a socket, a CLI or a file it reads instead passes `serve(mode)` and `count()`, and `skip` names any check that can't apply, with the reason beside it. `check_limits_contract` then drives `main()` through a fresh probe, the 15-second reuse for a normal and a `--limits-only` run, `--force`, a failed check kept stale, unreachable service with `retryAdvised`, a reply cut short and a garbage body kept stale with no retry (`cut` in `skip`, and `serve(mode)` gets `cut` and `garbage`), kept windows whose reset passed coming back at zero, and a refused credential, asserting on the printed record so every collector is held to the same field names, and returns the fresh record for the test's own reading of its answer. `check_scan_cache` grows the collector's local usage with the adapter's `grow()` between runs and rewrites the cache's stamps, holding it to the 20-second, 900-second and `--force` reuse windows and to missing a scan from another day or the future, and, given `pi_root`, to never caching a scan that couldn't read the pi sessions. `agent-usage-grok-test.sh` is the worked example.

A test whose fixtures are dated today calls `freeze_today()` (and stamps rows with `fixture_now()`), so a run that crosses local midnight still sees the day it began; `check_scan_cache` freezes it on its own. Collectors run as processes under `run_collector` aren't reached by it, so a test that runs them that way and dates its rows today waits for the new day when it would start within two minutes of local midnight, as the partition test does.

## Conventions worth copying

- **Redirect background output.** Send background fixtures' stdout to a log or `/dev/null` and clean up the processes on exit. An inherited output pipe can hold the runner open after the test exits.
- **Stub the world, run the real code.** Tests build a scratch `bin/` of stub
  executables (`sudo`, `tmux`, `gsettings`, helper commands) that log their
  arguments to a file, prepend it to `PATH`, and then run the real script
  under test. Assertions grep the call log and the files the script wrote.
- **Login shells drop the stubs.** A `bash -l` rereads `/etc/profile`, which resets `OMARCHY_PATH` from `/etc/omarchy.conf` and puts that checkout's `bin/` ahead of the stub directory, so a command run through one reaches the real commands again. Commands that start `bash -lc` (`omarchy-theme-set` runs its app retints that way) need a `bash` stub that drops the `-l`.
- **Fake `$HOME`, real `$OMARCHY_PATH`.** Anything touching user state runs
  with `HOME` pointed at a `mktemp -d` directory (cleaned up via
  `trap ... EXIT`) and `OMARCHY_PATH="$ROOT"`, so tests exercise the checkout
  without touching the developer's machine.
- **Migrations get no suite test.** A migration runs once per machine and is frozen once it ships, so a test of it guards nothing for long. Check it by hand against a scratch `$HOME` while writing it (see [`agents/skills/migrations.md`](../agents/skills/migrations.md)). When a migration needs logic worth a test, put that logic in a `bin/` command and test the command. Tests of `omarchy-migrate`, the login notifier, and `omarchy-upgrade-to-quattro` stay.
- **Assert the invariant, not the snapshot.** Config tests pin the property a
  test is named for (this widget stays adjacent to that one) rather than whole
  structures, so unrelated churn does not fail them.
