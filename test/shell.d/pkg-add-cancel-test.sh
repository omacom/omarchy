#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash
if [[ $1 == "true" ]]; then
  if [[ -n ${TEST_SUDO_SLEEP:-} ]]; then
    : >"$TEST_SUDO_READY"
    sleep "$TEST_SUDO_SLEEP"
  fi
  exit "${TEST_SUDO_TRUE_STATUS:-1}"
fi
printf 'sudo %s\n' "$*" >>"$TEST_CALLS"
exec "$@"
STUB

cat >"$mock_bin/pacman" <<'STUB'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  exit 0
fi
printf 'pacman %s\n' "$*" >>"$TEST_CALLS"
exit 0
STUB

for helper in omarchy-plugin-enable uwsm-app systemctl tailscale omarchy-webapp-install; do
  cat >"$mock_bin/$helper" <<STUB
#!/bin/bash
printf '$helper %s\n' "\$*" >>"\$TEST_CALLS"
exit 0
STUB
done

chmod +x "$mock_bin"/*

# 1. Cancelling sudo in omarchy-pkg-add exits 130 and does not start pacman.
calls="$test_tmp/calls-pkg-add"
: >"$calls"
status=0
PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_TRUE_STATUS=1 \
  "$ROOT/bin/omarchy-pkg-add" demo-pkg >/dev/null 2>&1 || status=$?
(( status == 130 )) || fail "cancelled sudo in omarchy-pkg-add exits 130" "status=$status"
[[ ! -s $calls ]] || fail "cancelled sudo in omarchy-pkg-add must not start pacman" "$(<"$calls")"
pass "cancelling sudo in omarchy-pkg-add exits 130 without running pacman"

# 2. Cancelling sudo inside a service installer exits 130 and skips later service steps.
for installer in omarchy-install-service-dropbox omarchy-install-service-tailscale; do
  calls="$test_tmp/calls-$installer"
  : >"$calls"
  status=0
  PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_TRUE_STATUS=1 \
    "$ROOT/bin/$installer" >/dev/null 2>&1 || status=$?
  (( status == 130 )) || fail "cancelled sudo in $installer exits 130" "status=$status"
  [[ ! -s $calls ]] || fail "cancelled sudo in $installer must not run package install or later service steps" "$(<"$calls")"
done
pass "cancelling sudo in service installers exits 130 without running pacman or later service steps"

# 3. Interrupting omarchy-pkg-add with SIGINT while authenticating exits 130 without running pacman.
calls="$test_tmp/calls-sigint"
ready="$test_tmp/sudo-ready"
: >"$calls"
rm -f "$ready"
PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_SLEEP=10 TEST_SUDO_READY="$ready" \
  "$ROOT/bin/omarchy-pkg-add" demo-pkg >/dev/null 2>&1 &
child=$!
for _ in $(seq 1 50); do
  [[ -e $ready ]] && break
  sleep 0.05
done
[[ -e $ready ]] || fail "sudo authentication did not start in time"
kill -INT "$child"
status=0
wait "$child" || status=$?
(( status == 130 )) || fail "SIGINT during omarchy-pkg-add sudo prompt exits 130" "status=$status"
[[ ! -s $calls ]] || fail "SIGINT during sudo prompt must not run pacman" "$(<"$calls")"
pass "SIGINT during omarchy-pkg-add sudo prompt exits 130 without running pacman"

# 4. Succeeding sudo proceeds to install the package.
calls="$test_tmp/calls-ok"
: >"$calls"
PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_TRUE_STATUS=0 \
  "$ROOT/bin/omarchy-pkg-add" demo-pkg >/dev/null 2>&1
grep -Fx 'pacman -S --noconfirm --needed -- demo-pkg' "$calls" >/dev/null ||
  fail "authenticated omarchy-pkg-add installs the requested package" "$(<"$calls")"
pass "authenticated omarchy-pkg-add installs the requested package"
