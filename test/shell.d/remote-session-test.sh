#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const model = requireFromRoot('shell/plugins/services/remote-session/RemoteSessionModel.js')

assert(model.isCaptureEvent('screencast'), 'the screencast event triggers a probe')
assert(!model.isCaptureEvent('screencastv2'), 'the paired screencastv2 event does not double the probe')
assert(!model.isCaptureEvent('openwindow') && !model.isCaptureEvent(''), 'unrelated Hyprland events are ignored')

assertDeepEqual(model.stateFromOutput(''), { active: false, peers: [] }, 'no gliff-server means no session')
assertDeepEqual(model.stateFromOutput('\n'), { active: false, peers: [] }, 'blank output means no session')
assertDeepEqual(model.stateFromOutput('4321 \n'), { active: true, peers: [] }, 'a local server without ssh is a session with no known peer')
assertDeepEqual(model.stateFromOutput('4321 10.0.0.5\n'), { active: true, peers: ['10.0.0.5'] }, 'an ssh-spawned server reports the client address')
assertDeepEqual(model.stateFromOutput('1 10.0.0.5\n2 10.0.0.5\n3 fd00::9\n'), { active: true, peers: ['10.0.0.5', 'fd00::9'] }, 'peers are listed once each')
JS

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/bin" "$TMPDIR/proc/100" "$TMPDIR/proc/200"

probe_script="$ROOT/shell/plugins/services/remote-session/probe.sh"
bash -n "$probe_script" || fail "remote session probe is valid bash"
pass "remote session probe is valid bash"

cat >"$TMPDIR/bin/pgrep" <<'SH'
#!/bin/bash
[[ $1 == "-x" && $2 == "-u" && $3 == "$(id -u)" && $4 == "gliff-server" ]] || exit 2
[[ -n ${GLIFF_PIDS:-} ]] || exit 1
printf '%s\n' $GLIFF_PIDS
SH
chmod +x "$TMPDIR/bin/pgrep"

# The probe reads /proc/<pid>/environ; point a copy at fixtures instead.
sed "s|/proc/\$pid/environ|$TMPDIR/proc/\$pid/environ|" "$probe_script" >"$TMPDIR/probe.sh"
grep -q "$TMPDIR/proc" "$TMPDIR/probe.sh" || fail "probe reads the server environment from /proc"
pass "probe reads the server environment from /proc"

probe() {
  PATH="$TMPDIR/bin:$PATH" GLIFF_PIDS="${1:-}" bash "$TMPDIR/probe.sh"
}

[[ -z $(probe) ]] || fail "probe prints nothing without a gliff server"
pass "probe prints nothing without a gliff server"

printf 'HOME=/home/x\0SSH_CONNECTION=10.0.0.5 51234 10.0.0.1 22\0TERM=foot\0' >"$TMPDIR/proc/100/environ"
printf 'HOME=/home/x\0TERM=foot\0' >"$TMPDIR/proc/200/environ"

[[ $(probe "100") == "100 10.0.0.5" ]] || fail "probe reports the ssh client address of a spawned server"
pass "probe reports the ssh client address of a spawned server"

[[ $(probe "200") == "200 " ]] || fail "probe reports a local server with an empty peer"
pass "probe reports a local server with an empty peer"

(( $(probe "100 200" | wc -l) == 2 )) || fail "probe lists every server"
pass "probe lists every server"
