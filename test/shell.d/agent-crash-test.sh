#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

# The agent only receives the prompt here. coredumpctl reports the time the dump
# finished and ends on the notice it prints while another dump is in progress;
# the journal holds when the process actually crashed.
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >"%s/prompt"\n' "$tmp" >"$tmp/bin/omarchy-agent"
cat >"$tmp/bin/coredumpctl" <<'SH'
#!/bin/bash
echo "Thu 2026-10-01 18:49:47 UTC 4242 1000 1000 SIGSEGV present /usr/bin/app 1.9M"
echo "-- Notice: 1 systemd-coredump@.service unit is running, output may be incomplete."
SH
cat >"$tmp/bin/journalctl" <<'SH'
#!/bin/bash
[[ ${JOURNAL_FAILS:-0} == 1 ]] && exit 1
[[ -n ${COREDUMP_TIMESTAMP:-} ]] && echo "{\"COREDUMP_TIMESTAMP\":\"$COREDUMP_TIMESTAMP\"}"
exit 0
SH
chmod +x "$tmp/bin/"*

crash_time() {
  TZ=UTC OMARCHY_PATH="$ROOT" PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-agent-crash" 4242 app /usr/bin/app SIGSEGV
  sed -n 's/^  time: *//p' "$tmp/prompt"
}

# 1790880529 is 2026-10-01 18:48:49 UTC, about a minute before the dump finished.
[[ $(COREDUMP_TIMESTAMP=1790880529000000 crash_time) == "Thu 2026-10-01 18:48:49 UTC" ]] ||
  fail "the crash time comes from COREDUMP_TIMESTAMP" "$(cat "$tmp/prompt")"
pass "the crash time comes from COREDUMP_TIMESTAMP, not when the dump finished"

[[ $(COREDUMP_TIMESTAMP="" crash_time) == "unknown" ]] ||
  fail "a crash without a journal entry has an unknown time" "$(cat "$tmp/prompt")"
[[ $(JOURNAL_FAILS=1 crash_time) == "unknown" ]] ||
  fail "an unreadable journal leaves the time unknown" "$(cat "$tmp/prompt")"
! grep -q "Notice" "$tmp/prompt" || fail "coredumpctl's notice never reaches the prompt"
pass "a missing or unreadable journal entry leaves the time unknown"
