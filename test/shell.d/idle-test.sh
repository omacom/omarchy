#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const idle = requireFromRoot('shell/plugins/services/idle/IdleModel.js')

assertEqual(idle.secondsFromConfig('42.9', 10), 42, 'idle floors configured seconds')
assertEqual(idle.secondsFromConfig('-1', 10), 10, 'idle rejects negative seconds')
assertEqual(idle.secondsFromConfig('nope', 10), 10, 'idle rejects invalid seconds')
assertEqual(idle.secondsFromConfig(0, 300), 0, 'idle keeps an explicit zero timeout')
assertEqual(idle.firstIdleTimeout(150, 300), 150, 'idle uses the sooner of screensaver and lock')
assertEqual(idle.firstIdleTimeout(0, 300), 300, 'idle ignores a disabled screensaver when computing first idle')
assertEqual(idle.firstIdleTimeout(150, 0), 150, 'idle ignores a disabled lock when computing first idle')
assertEqual(idle.firstIdleTimeout(0, 0), 0, 'idle has no first-idle timeout when both actions are disabled')
assertEqual(idle.delayAfterFirstIdle(300, 150), 150, 'idle delays lock until its own timeout')
assertEqual(idle.delayAfterFirstIdle(150, 150), 0, 'idle fires an action immediately when it is the first timeout')
assertEqual(idle.delayAfterFirstIdle(0, 150), 0, 'idle does not schedule a disabled action')
JS

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
mkdir -p "$test_home"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" stay-awake >/dev/null
[[ -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists enabled state"

HOME="$test_home" "$ROOT/bin/omarchy-toggle-idle" allow-idle >/dev/null
[[ ! -f $test_home/.local/state/omarchy/indicators/stay-awake ]] || fail "Stay Awake toggle persists disabled state"

pass "Stay Awake toggle persists state"

require_quickshell "idle service runtime test"

qml_fixture_scratch
trap 'qml_fixture_cleanup; rm -rf "$test_tmp"' EXIT

# The service acts on the session once it goes idle; these keep it to itself.
for stub in omarchy-shell omarchy-launch-screensaver omarchy-system-lock omarchy-system-wake pkill; do
  printf '#!/bin/bash\n' >"$QML_FIXTURE_TMP/bin/$stub"
  chmod +x "$QML_FIXTURE_TMP/bin/$stub"
done
# It runs them under `bash -lc`, and a login shell resets PATH from
# /etc/omarchy.conf, which would put the real commands back ahead of the stubs.
printf '#!/bin/bash\n[[ ${1:-} == "-lc" ]] && shift && set -- -c "$@"\nexec /bin/bash "$@"\n' >"$QML_FIXTURE_TMP/bin/bash"
chmod +x "$QML_FIXTURE_TMP/bin/bash"

run_qml_fixture idle-service "idle service keeps reporting idle when its timings change on a running monitor, and applies them once the user is back" Commons
