#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"
export WATCH_LOG="$tmpdir/calls"
export SESSION_REPLY='o "/org/freedesktop/login1/session/c3"'
cat >"$tmpdir/bin/busctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$WATCH_LOG"
printf '%s\n' "$SESSION_REPLY"
SH
cat >"$tmpdir/bin/gdbus" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$WATCH_LOG"
SH
chmod +x "$tmpdir/bin/"*

helper="$ROOT/shell/plugins/lock/watch-login-session.sh"
PATH="$tmpdir/bin:$PATH" bash "$helper"
expected=$'call --allow-interactive-authorization=no org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager GetSession s auto\nmonitor --system --dest org.freedesktop.login1 --object-path /org/freedesktop/login1/session/c3'
[[ $(<"$WATCH_LOG") == "$expected" ]] || fail "watch only the resolved graphical session" "$(<"$WATCH_LOG")"
pass "watch only the resolved graphical session without BecomeMonitor"

for reply in 's "not-a-session"' 'o "/other/path"' ''; do
  : >"$WATCH_LOG"
  if PATH="$tmpdir/bin:$PATH" SESSION_REPLY="$reply" bash "$helper"; then
    fail "refuse an invalid session path"
  fi
  [[ $(<"$WATCH_LOG") != *monitor* ]] || fail "an invalid lookup must not watch every session"
done
pass "failed session lookup does not subscribe to other users' locks"

run_node_test <<'JS'
const fs = require('fs')
const qml = fs.readFileSync(path.join(root, 'shell/plugins/lock/Service.qml'), 'utf8')
const watch = qml.slice(qml.indexOf('id: loginWatchProc'), qml.indexOf('id: loginWatchRestartTimer'))
const body = watch.match(/onRead: function\(line\) \{([\s\S]*?)\n      \}/)[1]
let calls = 0, locked = false
const state = {currentlyLocked: () => locked, beginLock: () => { calls++; locked = true }}
const onRead = new Function('line', 'root', body)
onRead('/org/freedesktop/login1/session/c3: org.freedesktop.login1.Session.Lock ()', state)
assert(calls === 1, 'logind Lock locks the desktop')
onRead('/org/freedesktop/login1/session/c3: org.freedesktop.login1.Session.Lock ()', state)
assert(calls === 1, 'a repeated request does not restart a lock')
locked = false
onRead('/org/freedesktop/login1/session/c3: org.freedesktop.login1.Session.Unlock ()', state)
onRead('/org/freedesktop/login1/session/c3: org.freedesktop.DBus.Properties.PropertiesChanged ()', state)
assert(calls === 1, 'Unlock and unrelated signals do not authenticate or lock')
assert(watch.includes('running: true'), 'watch starts with the lock service')
assert(watch.includes('onExited: loginWatchRestartTimer.restart()'), 'watch reconnects after bus loss')
JS
