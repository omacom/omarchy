#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1790604026.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
calls="$test_tmp/restart-calls"
mkdir -p "$stub_bin" "$test_tmp/home"

cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
case "$2" in
  call) exit 0 ;;
  status)
    [[ -n ${OWNER_PID:-} ]] || exit 1
    printf 'PID=%s\n' "$OWNER_PID"
    ;;
  *) exit 2 ;;
esac
SH

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
case "$2" in
  is-active) exit 0 ;;
  show) printf '42\n' ;;
  *) exit 2 ;;
esac
SH

cat >"$stub_bin/omarchy-restart-xcompose" <<'SH'
#!/bin/bash
printf 'restart\n' >>"$RESTART_CALLS"
SH
chmod +x "$stub_bin"/*

run_case() {
  local owner="$1" expected_restarts="$2" description="$3"
  : >"$calls"
  OWNER_PID="$owner" RESTART_CALLS="$calls" PATH="$stub_bin:$PATH" \
    HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null || fail "$description: migration exits successfully"
  (( $(wc -l <"$calls") == expected_restarts )) || fail "$description: expected $expected_restarts restarts, got $(wc -l <"$calls")"
  pass "$description"
}

run_case 42 0 "fcitx5 unit owns the bus name"
run_case 99 1 "another process owns the bus name"
run_case "" 0 "nobody owns the bus name"
