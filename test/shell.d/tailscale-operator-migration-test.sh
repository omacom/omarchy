#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1787884977.sh"
[[ -f $migration ]] || fail "Tailscale operator migration is missing"
pass "Tailscale operator migration exists"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
CALL_LOG="$tmp_dir/call-log"
export RECEIVER_STATE="$tmp_dir/receiver-state"
export RECEIVER_ACTIVE="$tmp_dir/receiver-active"
printf 'enabled\n' >"$RECEIVER_STATE"
printf 'inactive\n' >"$RECEIVER_ACTIVE"

cat >"$tmp_dir/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALL_LOG"
if [[ $2 == "show" ]]; then
  if (( ${STUB_QUERY_STATUS:-0} != 0 )); then
    echo "Failed to connect to user bus" >&2
    exit "$STUB_QUERY_STATUS"
  fi
  cat "$RECEIVER_STATE"
fi
if [[ $2 == "start" || $2 == "enable" ]]; then
  if (( ${STUB_START_STATUS:-0} != 0 )); then
    echo "Failed to start receiver" >&2
    exit "$STUB_START_STATUS"
  fi
  if [[ $2 == "enable" ]]; then
    printf 'enabled\n' >"$RECEIVER_STATE"
  fi
  printf 'active\n' >"$RECEIVER_ACTIVE"
fi
if [[ $2 == "disable" ]]; then
  if (( ${STUB_DISABLE_STATUS:-0} == 0 )); then
    printf 'disabled\n' >"$RECEIVER_STATE"
    printf 'inactive\n' >"$RECEIVER_ACTIVE"
  fi
  exit "${STUB_DISABLE_STATUS:-0}"
fi
exit 0
SH

cat >"$tmp_dir/bin/tailscale" <<'SH'
#!/bin/bash
printf 'tailscale %s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "debug" && $2 == "prefs" ]]; then
  printf '{"OperatorUser":"%s"}\n' "${STUB_OPERATOR:-}"
  exit 0
fi
if [[ $1 == "set" ]]; then
  exit "${STUB_SET_STATUS:-0}"
fi
exit 0
SH

cat >"$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat >"$tmp_dir/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "tailscale" ]]
SH

chmod +x "$tmp_dir/bin/systemctl" "$tmp_dir/bin/tailscale" "$tmp_dir/bin/sudo" "$tmp_dir/bin/omarchy-cmd-present"

: >"$CALL_LOG"

USER=omarchy-test \
PATH="$tmp_dir/bin:$PATH" \
CALL_LOG="$CALL_LOG" \
  bash -euo pipefail "$migration" >/dev/null

printf '%s\n' \
  "tailscale debug prefs" \
  "tailscale set --operator=omarchy-test" \
  "systemctl --user show --property=UnitFileState --value omarchy-tailscale-receive.service" \
  "systemctl --user daemon-reload" \
  "systemctl --user start omarchy-tailscale-receive.service" >"$tmp_dir/expected"
cmp -s "$CALL_LOG" "$tmp_dir/expected" ||
  fail "migration does not set the operator before starting the enabled Taildrop receiver" "$(cat "$CALL_LOG")"
[[ $(cat "$RECEIVER_ACTIVE") == "active" ]] || fail "migration does not start the enabled receiver"
pass "migration sets the operator before starting the enabled Taildrop receiver"

: >"$CALL_LOG"

cat >"$tmp_dir/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$tmp_dir/bin/omarchy-cmd-present"

PATH="$tmp_dir/bin:$PATH" \
CALL_LOG="$CALL_LOG" \
  bash -euo pipefail "$migration" >/dev/null

if [[ -s $CALL_LOG ]]; then
  fail "migration talks to Tailscale when it is not installed"
fi
pass "migration leaves Tailscale alone when it is not installed"

cat >"$tmp_dir/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == "tailscale" ]]
SH
chmod +x "$tmp_dir/bin/omarchy-cmd-present"

: >"$CALL_LOG"

if USER=omarchy-test \
PATH="$tmp_dir/bin:$PATH" \
CALL_LOG="$CALL_LOG" \
STUB_SET_STATUS=1 \
  bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "migration treats a failed operator set as success"
fi
if grep -q 'systemctl' "$CALL_LOG"; then
  fail "migration touches the receiver after a failed operator set"
fi
pass "migration stays pending when setting the operator fails"

: >"$CALL_LOG"

USER=omarchy-test \
PATH="$tmp_dir/bin:$PATH" \
CALL_LOG="$CALL_LOG" \
STUB_OPERATOR=other-user \
  bash -euo pipefail "$migration" >/dev/null

printf '%s\n' \
  "tailscale debug prefs" \
  "systemctl --user disable --now omarchy-tailscale-receive.service" >"$tmp_dir/expected"
cmp -s "$CALL_LOG" "$tmp_dir/expected" ||
  fail "migration does not disable a leftover receiver when the operator belongs to someone else" "$(cat "$CALL_LOG")"
pass "migration disables a leftover receiver when the operator belongs to someone else"

: >"$CALL_LOG"

if USER=omarchy-test \
PATH="$tmp_dir/bin:$PATH" \
CALL_LOG="$CALL_LOG" \
STUB_OPERATOR=other-user \
STUB_DISABLE_STATUS=1 \
  bash -euo pipefail "$migration" >/dev/null 2>&1; then
  fail "migration treats a failed receiver disable as success"
fi
pass "migration stays pending when the leftover receiver cannot be disabled"

for receiver_state in disabled masked masked-runtime static linked linked-runtime generated ""; do
  for operator in "" omarchy-test; do
    : >"$CALL_LOG"
    printf '%s\n' "$receiver_state" >"$RECEIVER_STATE"
    printf 'inactive\n' >"$RECEIVER_ACTIVE"

    USER=omarchy-test \
    PATH="$tmp_dir/bin:$PATH" \
    CALL_LOG="$CALL_LOG" \
    STUB_OPERATOR="$operator" \
      bash -euo pipefail "$migration" >/dev/null

    [[ $(cat "$RECEIVER_STATE") == "$receiver_state" ]] || fail "migration changes receiver enablement: $receiver_state"
    [[ $(cat "$RECEIVER_ACTIVE") == "inactive" ]] || fail "migration starts a receiver that is not enabled: $receiver_state"
    if [[ -z $operator ]]; then
      grep -q '^tailscale set --operator=omarchy-test$' "$CALL_LOG" || fail "migration skips operator repair for a receiver that is not enabled"
    elif grep -q '^tailscale set' "$CALL_LOG"; then
      fail "migration resets the existing operator"
    fi
  done
done
pass "migration repairs the operator without starting or enabling opted-out receivers"

printf 'enabled-runtime\n' >"$RECEIVER_STATE"
printf 'inactive\n' >"$RECEIVER_ACTIVE"
for attempt in 1 2; do
  USER=omarchy-test \
  PATH="$tmp_dir/bin:$PATH" \
  CALL_LOG="$CALL_LOG" \
  STUB_OPERATOR=omarchy-test \
    bash -euo pipefail "$migration" >/dev/null
  [[ $(cat "$RECEIVER_STATE") == "enabled-runtime" ]] || fail "migration makes runtime-only enablement permanent"
  [[ $(cat "$RECEIVER_ACTIVE") == "active" ]] || fail "migration leaves runtime-enabled receiver stopped"
done
pass "migration preserves runtime-only receiver enablement on repeated runs"

for failure in query start; do
  : >"$CALL_LOG"
  printf 'enabled\n' >"$RECEIVER_STATE"
  printf 'inactive\n' >"$RECEIVER_ACTIVE"
  query_status=0
  start_status=0
  if [[ $failure == "query" ]]; then
    query_status=1
  else
    start_status=1
  fi

  if USER=omarchy-test \
  PATH="$tmp_dir/bin:$PATH" \
  CALL_LOG="$CALL_LOG" \
  STUB_OPERATOR=omarchy-test \
  STUB_QUERY_STATUS="$query_status" \
  STUB_START_STATUS="$start_status" \
    bash -euo pipefail "$migration" >"$tmp_dir/output" 2>&1; then
    fail "migration treats a failed receiver $failure as success"
  fi
  [[ $(cat "$RECEIVER_ACTIVE") == "inactive" ]] || fail "migration starts receiver after failed $failure"
  grep -q 'will be retried by omarchy-migrate' "$tmp_dir/output" || fail "migration does not explain retry after failed $failure"
done
pass "migration stays pending when receiver state cannot be read or the enabled receiver cannot start"
