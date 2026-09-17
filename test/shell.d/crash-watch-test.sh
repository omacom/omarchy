#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

sent="$tmpdir/sent"
: >"$sent"

stub() { # name body
  printf '#!/bin/bash\n%s\n' "$2" >"$tmpdir/$1"
  chmod +x "$tmpdir/$1"
}

# journalctl -f replays these and exits, which ends the watch loop. Two crashes
# of one program a moment apart: the case a crash loop produces.
cat >"$tmpdir/journal" <<JSON
{"_UID":"$UID","COREDUMP_COMM":"mldr","COREDUMP_PID":"101","COREDUMP_EXE":"/usr/libexec/darling/mldr","COREDUMP_SIGNAL_NAME":"SIGSEGV"}
{"_UID":"$UID","COREDUMP_COMM":"mldr","COREDUMP_PID":"102","COREDUMP_EXE":"/usr/libexec/darling/mldr","COREDUMP_SIGNAL_NAME":"SIGABRT"}
{"_UID":"$UID","COREDUMP_COMM":"omarchy-agent-c","COREDUMP_PID":"103","COREDUMP_EXE":"/usr/bin/omarchy-agent-crash","COREDUMP_SIGNAL_NAME":"SIGSEGV"}
JSON

stub journalctl 'cat "$OMARCHY_TEST_JOURNAL"'
stub omarchy-default-agent 'echo claude'
stub omarchy-notification-wait 'exit 0'
# One argument per line, each send closed by a marker line.
stub omarchy-notification-send 'printf "%s\n" "$@" @@ >>"$OMARCHY_TEST_SENT"'

# A HOME of its own, so a program the developer muted can't hide a crash here,
# and the checkout's helpers ahead of any installed copy.
mkdir -p "$tmpdir/home"
OMARCHY_TEST_JOURNAL="$tmpdir/journal" OMARCHY_TEST_SENT="$sent" HOME="$tmpdir/home" PATH="$tmpdir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-crash-watch"

sends=$(grep -cFx @@ "$sent" || true)
((sends == 2)) || fail "crash watcher announces every crash of a program, and never its own machinery" "$(cat "$sent")"
pass "crash watcher announces every crash, leaving repeats to the shell's grouping"

second=$(awk 'BEGIN { RS = "@@\n" } NR == 2' "$sent")

# The value that follows a flag in the recorded argv.
value_after() { # flag
  grep -A1 -Fx -- "$1" <<<"$second" | sed -n 2p
}

[[ $(value_after --group) == "crash:mldr" ]] ||
  fail "crash watcher groups crash toasts by program" "$second"
pass "crash watcher groups crash toasts by program"

[[ $(value_after --urgency) == "critical" ]] && grep -Fxq -- --expire-critical <<<"$second" &&
  [[ $(value_after --expire-time) == "60000" ]] ||
  fail "crash watcher sends critical toasts that expire after a minute" "$second"
pass "crash watcher sends critical toasts that expire after a minute"

[[ $(grep -A5 -Fx -- --exec <<<"$second" | tr '\n' ' ') == "--exec omarchy-agent-crash 102 mldr /usr/libexec/darling/mldr SIGABRT " ]] ||
  fail "crash watcher points the toast's click at the newest crash" "$second"
pass "crash watcher points the toast's click at the newest crash"
