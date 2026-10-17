#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_compositor "agents resume runtime test"
require_command quickshell
require_command python3
require_command jq

test_tmp=$(mktemp -d)
test_root="$test_tmp/omarchy"
test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
log="$test_tmp/quickshell.log"
qs_pid=""

cleanup() {
  local environ pid
  if [[ -n $qs_pid ]]; then
    kill "$qs_pid" 2>/dev/null || true
    wait "$qs_pid" 2>/dev/null || true
  fi
  # Stop this shell's remaining event readers, including reparented children.
  while IFS= read -r environ; do
    pid=${environ#/proc/}
    kill "${pid%/environ}" 2>/dev/null || true
  done < <(grep -lzxF "OMARCHY_PATH=$test_root" /proc/[0-9]*/environ 2>/dev/null || true)
  rm -f "$(shell_ipc_socket "$test_root")"
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mkdir -p "$test_root" "$stub_bin" "$test_home/.config/omarchy" "$test_home/.local/state/omarchy/agents/usage"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$ROOT/default" "$ROOT/bin" "$test_root/"

# Keep this full shell focused on agents and idle, with no live authentication,
# clipboard, power, network, or background services competing with the session.
ROOT="$ROOT" TEST_ROOT="$test_root" TEST_HOME="$test_home" python3 - <<'PY'
import datetime as dt, json, os, pathlib, re
root = pathlib.Path(os.environ['ROOT'])
test_root = pathlib.Path(os.environ['TEST_ROOT'])
home = pathlib.Path(os.environ['TEST_HOME'])
config = json.loads((root / 'config/omarchy/shell.json').read_text())
config['bar']['layout'] = {'left': [], 'center': [{'id': 'omarchy.agents'}], 'right': []}
config['bar']['centerAnchor'] = 'omarchy.agents'
config['idle'] = {'screensaver': 0, 'lock': 0}
config['plugins'] = [{'id': json.loads(p.read_text())['id'], 'enabled': False}
                     for p in (root / 'shell/plugins').rglob('manifest.json')
                     if json.loads(p.read_text())['id'] not in ('omarchy.bar', 'omarchy.agents', 'omarchy.idle')]
(home / '.config/omarchy/shell.json').write_text(json.dumps(config))
record = {'id': 'claude', 'name': 'Claude Code', 'ready': True, 'tierLabel': 'Pro',
          'limits': [{'label': 'Session (5-hour)', 'percent': .95,
                      'resetsAt': (dt.datetime.now(dt.timezone.utc) - dt.timedelta(hours=1)).isoformat()}]}
(home / '.local/state/omarchy/agents/usage/claude.json').write_text(json.dumps(record))

# Freeze the captured panel clock as though the machine slept for eight hours.
# Test-only IPC exposes state without replacing any production event handler.
panel = test_root / 'shell/plugins/agents/Panel.qml'
source = panel.read_text()
clock_tick = re.search(r'interval: 30000[\s\S]*?onTriggered: ([^\n]+)', source)[1]
reset_tick = re.search(r'id: resetTimer\n\s+onTriggered: ([^\n]+)', source)[1]
needle = '    function open(): void { root.open() }'
assert source.count(needle) == 1
source = source.replace(needle, '''    function testSleep(): string {
      root.nowMs = Date.now() - 8 * 3600000
      resetTimer.stop()
      return "ok"
    }
    function testState(): string {
      return JSON.stringify({ alarming: root.alarming, due: root.resetDueMs,
        providers: root.providers.length, now: root.nowMs })
    }
''' + '    function testClockTick(): string { ' + clock_tick + '; return "ok" }\n'
    + '    function testResetTick(): string { ' + reset_tick + '; return "ok" }\n' + needle)
panel.write_text(source)

# Observe the actual host-created narrow proxy as well as the built-in panel.
host = test_root / 'shell/shell.qml'
source = host.read_text()
pos = source.rfind('}')
source = source[:pos] + '''
  property int testResumeCount: 0
  readonly property var testIdleProxy: shell.pluginFirstPartyServiceFor("resume-test", "resume-test", "omarchy.idle")
  Connections {
    target: shell.testIdleProxy
    function onResumed() { shell.testResumeCount++ }
  }
  ShellIpc {
    target: "resume-test"
    function count(): string { return String(shell.testResumeCount) }
  }
''' + source[pos:]
host.write_text(source)
PY

mkfifo "$test_root/sleep-events"
exec 8<>"$test_root/sleep-events"
cat >"$stub_bin/dbus-monitor" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_PATH/sleep-monitor-starts"
exec cat "$OMARCHY_PATH/sleep-events"
SH
cat >"$stub_bin/omarchy-agent-usage-update" <<'SH'
#!/bin/bash
if [[ ${1:-} == "--limits-only" ]]; then
  printf '%s\n' limits >>"$OMARCHY_PATH/limit-fetches"
fi
SH
chmod +x "$stub_bin/dbus-monitor" "$stub_bin/omarchy-agent-usage-update"

shell_ipc() {
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" "$@"
}
fail_with_log() {
  tail -100 "$log" >&2
  fail "$1"
}

OMARCHY_PATH="$test_root" HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" XDG_CACHE_HOME="$test_home/.cache" XDG_STATE_HOME="$test_home/.local/state" \
PATH="$stub_bin:$ROOT/bin:$PATH" QS_DISABLE_FILE_WATCHER=1 QS_NO_RELOAD_POPUP=1 \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
qs_pid=$!

for _ in {1..100}; do
  state=$(shell_ipc omarchy.agents testState 2>/dev/null || true)
  jq -e '.providers == 1' <<<"$state" >/dev/null 2>&1 && break
  kill -0 "$qs_pid" 2>/dev/null || fail_with_log "resume test shell exited before the agents loaded"
  sleep 0.1
done
jq -e '.providers == 1' <<<"$state" >/dev/null || fail_with_log "resume test loads the actual agents panel"
[[ $(shell_ipc omarchy.agents testSleep) == "ok" ]] || fail_with_log "test captures the pre-suspend clock"
jq -e '.alarming and .due > 0' <<<"$(shell_ipc omarchy.agents testState)" >/dev/null ||
  fail_with_log "the pre-suspend clock keeps the elapsed window's alarm lit"

printf '%s\n' '   boolean true' '   boolean false' >&8
for _ in {1..100}; do
  state=$(shell_ipc omarchy.agents testState)
  if jq -e '.alarming == false and .due == 0' <<<"$state" >/dev/null && [[ -s $test_root/limit-fetches ]]; then
    break
  fi
  sleep 0.1
done
jq -e '.alarming == false and .due == 0' <<<"$state" >/dev/null || fail_with_log "resume clears the elapsed alarm immediately"
[[ $(wc -l <"$test_root/limit-fetches") == "1" ]] || fail_with_log "resume fetches the missed reset exactly once"
[[ $(shell_ipc resume-test count) == "1" ]] || fail_with_log "resume crosses the real narrow proxy exactly once"
[[ $(wc -l <"$test_root/sleep-monitor-starts") == "1" ]] || fail_with_log "one monitor serves the whole shell"
grep -qF "type='signal',sender='org.freedesktop.login1',path='/org/freedesktop/login1',interface='org.freedesktop.login1.Manager',member='PrepareForSleep'" \
  "$test_root/sleep-monitor-starts" || fail_with_log "the monitor filters logind sleep signals at the bus"
pass "logind resume clears the actual panel alarm and fetches once through one shared monitor"
pass "the host forwards resume to the narrow idle proxy"

shell_ipc shell rescanPlugins >/dev/null
printf '%s\n' '   boolean false' >&8
for _ in {1..80}; do
  [[ $(shell_ipc resume-test count) == "2" ]] && break
  sleep 0.1
done
[[ $(shell_ipc resume-test count) == "2" ]] || fail_with_log "resume proxy survives a plugin rescan"
[[ $(wc -l <"$test_root/limit-fetches") == "1" ]] || fail_with_log "a repeated resume with no pending reset does not fetch"
[[ $(wc -l <"$test_root/sleep-monitor-starts") == "1" ]] || fail_with_log "plugin rescan keeps the existing monitor"
pass "plugin rescan keeps the monitor and proxy without duplicate resume fetches"

# Dispatch the real clock handler before a queued reset handler, with both due.
# Its clock assignment makes QML rebind the deadline and cancel the old timer.
[[ $(shell_ipc omarchy.agents testSleep) == "ok" ]] || fail_with_log "test captures another expired deadline"
[[ $(shell_ipc omarchy.agents testClockTick) == "ok" ]] || fail_with_log "test dispatches the actual panel clock handler"
for _ in {1..80}; do
  [[ $(wc -l <"$test_root/limit-fetches") == "2" ]] && break
  sleep 0.1
done
[[ $(wc -l <"$test_root/limit-fetches") == "2" ]] || fail_with_log "a clock tick before the reset timer must fetch the expired window"
[[ $(shell_ipc omarchy.agents testResetTick) == "ok" ]] || fail_with_log "test dispatches the queued reset handler"
jq -e '.alarming == false and .due == 0' <<<"$(shell_ipc omarchy.agents testState)" >/dev/null ||
  fail_with_log "the clock tick clears the expired alarm"
[[ $(wc -l <"$test_root/limit-fetches") == "2" ]] || fail_with_log "the queued timer must not duplicate the clock tick's fetch"
pass "the actual QML clock tick fetches a crossed deadline before a queued reset callback"
