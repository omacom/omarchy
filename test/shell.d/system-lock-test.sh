#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"

for command in omarchy-shell hyprctl pkill timeout; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s %s\n' "$(basename "$0")" "$*" >>"$CALL_LOG"
SH
done

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock"
mapfile -t shutdown < <(rg '^(pkill|timeout) ' "$call_log")

[[ ${shutdown[0]} == "pkill -x ttfx" ]] ||
  fail "system lock stops ttfx before closing its terminal" "calls: ${shutdown[*]}"
[[ ${shutdown[1]} == "timeout 1s pidwait -x ttfx" ]] ||
  fail "system lock waits for ttfx to exit" "calls: ${shutdown[*]}"
[[ ${shutdown[2]} == "pkill -f [o]rg.omarchy.screensaver" ]] ||
  fail "system lock closes the screensaver terminal after ttfx exits" "calls: ${shutdown[*]}"
pass "system lock waits for ttfx before closing its terminal"

[[ $(head -n1 "$call_log") == "omarchy-shell lock lock" ]] ||
  fail "ordinary locking uses the delayed entry point"
pass "ordinary locking uses the delayed entry point"
cp "$call_log" "$tmpdir/normal-calls"
: >"$call_log"
PATH="$mock_bin:$PATH" CALL_LOG="$call_log" "$ROOT/bin/omarchy-system-lock" --immediate
[[ $(head -n1 "$call_log") == "omarchy-shell lock lockImmediate" ]] ||
  fail "immediate locking uses the opt-in entry point"
tail -n +2 "$tmpdir/normal-calls" >"$tmpdir/normal-cleanup"
tail -n +2 "$call_log" >"$tmpdir/immediate-cleanup"
cmp -s "$tmpdir/normal-cleanup" "$tmpdir/immediate-cleanup" ||
  fail "immediate locking retains the ordinary lock cleanup"
pass "immediate locking changes only the IPC method, retaining cleanup"

# Run the production lock policy and IPC methods with Qt timers, without a
# compositor or a real session lock. Authentication and housekeeping effects
# are counted; the no-screen guard and both request paths are real code.
qml_runner=/usr/lib/qt6/bin/qmltestrunner
if [[ ! -x $qml_runner ]]; then
  skip "Qt Quick Test unavailable; skipping immediate lock runtime checks"
  exit 0
fi
cp "$SHELL_TEST_DIR/fixtures/lock-immediate/tst_lock.qml" "$tmpdir/"
python3 - "$ROOT/shell/plugins/lock/Service.qml" "$tmpdir/LockTiming.qml" <<'PYTHON'
import pathlib, re, sys
source = pathlib.Path(sys.argv[1]).read_text()
parts = []
for name in ("currentlyLocked", "realScreenCount", "hasRealScreen", "queueSessionLock", "requestSessionLock", "beginLock"):
    parts.append(re.search(r"^  function " + name + r"\(.*?^  \}", source, re.M | re.S).group())
for name in ("lock", "lockImmediate"):
    method = re.search(r"^    function " + name + r"\(.*?^    \}", source, re.M | re.S).group()
    parts.append(method.replace("function " + name + "(", "function api" + name[0].upper() + name[1:] + "("))
for name in ("sessionLockStabilizeTimer", "pendingSessionLockTimer"):
    parts.append(re.search(r"^  Timer \{\n    id: " + name + r"\n.*?^  \}", source, re.M | re.S).group())
policy = "\n".join(parts).replace("Quickshell.screens", "root.testScreens")
pathlib.Path(sys.argv[2]).write_text("""import QtQuick
Item {
  id: root
  property var testScreens: [{ name: "eDP-1", width: 1920, height: 1080 }]
  property bool lockRequested: false
  property bool pendingSessionLock: false
  property bool passwordPamConfigured: true
  property string lastEvent: ""
  property int authenticationResets: 0
  property int sleepRequests: 0
  property alias sessionLocked: sessionLock.locked
  function logEvent(event) { lastEvent = event }
  function resetAuthenticationState() { authenticationResets += 1 }
  function armBlankTimer() {}
  function refreshBackground() {}
  function refreshFingerprintStatus() {}
  function noteSleepRequested() { sleepRequests += 1 }
  QtObject {
    id: sessionLock
    property bool locked: false
    property bool secure: false
  }
""" + policy + "\n}\n")
PYTHON
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software QT_QPA_PLATFORMTHEME= \
  timeout 15 "$qml_runner" -input "$tmpdir" || fail "immediate lock runtime checks"
pass "immediate locking is opt-in and retains PAM, no-screen and pending-lock guards"
