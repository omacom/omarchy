#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
stub="$tmp/bin"
mkdir -p "$stub"
log="$tmp/log"

cat >"$stub/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$LOG"
if [[ $1 == "--user" && $2 == "is-active" ]]; then
  [[ ${HEX_ACTIVE:-0} == 1 ]]
  exit
fi
if [[ $1 == "--user" && $2 == "show" ]]; then
  printf '%s\n' "${HEX_PID:-0}"
  exit 0
fi
if [[ $1 == "--user" && $2 == "try-restart" ]]; then
  exit 0
fi
echo "unexpected systemctl $*" >&2
exit 1
STUB

cat >"$stub/readlink" <<'STUB'
#!/bin/bash
printf '%s\n' "${HEX_EXE:-}"
STUB
chmod +x "$stub/systemctl" "$stub/readlink"

run() {
  : >"$log"
  LOG="$log" HEX_ACTIVE="${1:-0}" HEX_PID="${2:-0}" HEX_EXE="${3:-}" \
    PATH="$stub:$PATH" "$ROOT/bin/omarchy-update-restart-hex"
}

run 1 4242 "/usr/bin/hex (deleted)" || fail "a replaced Hex reports a restart failure"
grep -q '^systemctl --user try-restart hex.service$' "$log" ||
  fail "a replaced Hex is not restarted" "$(cat "$log")"
pass "a Hex still running the binary an update replaced is restarted"

run 1 4242 "/usr/bin/hex" || fail "a current Hex reports a restart failure"
if grep -q 'try-restart' "$log"; then
  fail "a current Hex is restarted" "$(cat "$log")"
fi
pass "a Hex already on the installed binary is left running"

run 0 4242 "/usr/bin/hex (deleted)" || fail "an inactive Hex reports a restart failure"
if grep -q 'try-restart' "$log"; then
  fail "an inactive Hex is restarted" "$(cat "$log")"
fi
pass "Hex is left alone when its service is not running"
