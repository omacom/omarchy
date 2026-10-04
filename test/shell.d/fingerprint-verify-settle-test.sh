#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-setup-security-fingerprint"
function_source=$(sed -n '/^verify_fingerprint() {/,/^}/p' "$script")
[[ -n $function_source ]] || fail "fingerprint verify helper exists"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

cat >"$scratch/bin/sleep" <<'STUB'
#!/bin/bash
printf 'sleep %s\n' "$*" >>"$VERIFY_LOG"
STUB

cat >"$scratch/bin/fprintd-verify" <<'STUB'
#!/bin/bash
count=0
[[ -f $VERIFY_COUNT ]] && read -r count <"$VERIFY_COUNT"
(( count += 1 ))
printf '%s\n' "$count" >"$VERIFY_COUNT"
printf 'verify %s\n' "$count" >>"$VERIFY_LOG"

case "$VERIFY_MODE" in
  claim-then-match)
    if (( count < 3 )); then
      echo 'failed to claim device: GDBus.Error:net.reactivated.Fprint.Error.Internal: Open failed'
      exit 1
    fi
    echo 'verify-match'
    ;;
  no-match)
    echo 'verify-no-match'
    exit 1
    ;;
  always-busy)
    echo 'device busy'
    exit 1
    ;;
  *)
    echo "unknown VERIFY_MODE=$VERIFY_MODE" >&2
    exit 2
    ;;
esac
STUB
chmod +x "$scratch/bin/"*

run_verify() {
  local mode="$1"
  : >"$scratch/log"
  rm -f "$scratch/count"
  VERIFY_MODE="$mode" VERIFY_LOG="$scratch/log" VERIFY_COUNT="$scratch/count"     PATH="$scratch/bin:$PATH"     bash -c "$function_source; verify_fingerprint"
}

run_verify claim-then-match >/dev/null || fail "claim failures eventually reach a successful verify"
[[ $(<"$scratch/count") == 3 ]] || fail "claim failure retry count" "count=$(<"$scratch/count")"
(( $(grep -c '^sleep 0.5$' "$scratch/log") == 3 )) || fail "claim failures settle before verify and between retries" "$(cat "$scratch/log")"
pass "claim failures retry after the enroll handoff"

if run_verify no-match >/dev/null 2>&1; then
  fail "verify-no-match must fail"
fi
[[ $(<"$scratch/count") == 1 ]] || fail "verify-no-match is not retried" "count=$(<"$scratch/count")"
(( $(grep -c '^sleep 0.5$' "$scratch/log") == 1 )) || fail "verify-no-match only pays the initial settle" "$(cat "$scratch/log")"
pass "a wrong fingerprint fails immediately"

if run_verify always-busy >/dev/null 2>&1; then
  fail "permanently busy reader must eventually fail"
fi
[[ $(<"$scratch/count") == 5 ]] || fail "busy retry budget is bounded" "count=$(<"$scratch/count")"
(( $(grep -c '^sleep 0.5$' "$scratch/log") == 5 )) || fail "bounded busy retries sleep only between attempts" "$(cat "$scratch/log")"
pass "claim retry budget is bounded"
