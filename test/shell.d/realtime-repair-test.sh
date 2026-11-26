#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
stub_bin="$test_dir/bin"
calls="$test_dir/calls"
mkdir -p "$stub_bin"
touch "$calls"

cat >"$stub_bin/id" <<'STUB'
#!/bin/bash
[[ $* == "-u" ]] || exit 2
echo 1000
STUB
cat >"$stub_bin/loginctl" <<'STUB'
#!/bin/bash
[[ $* == "show-user 1000 --property=Linger --value" ]] || exit 2
echo "${LINGER:-no}"
STUB
cat >"$stub_bin/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
[[ $* == "rtkit" ]] || exit 2
exit "${RTKIT_MISSING:-1}"
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
case $* in
  "--user show -p MainPID --value pipewire.service") echo 500 ;;
  "--user try-restart pipewire.service pipewire-pulse.service wireplumber.service")
    echo restart >>"$CALLS" ;;
  *) exit 2 ;;
esac
STUB
cat >"$stub_bin/ps" <<'STUB'
#!/bin/bash
[[ $* == "-L -o cls= -p 500" ]] || exit 2
echo "${PIPEWIRE_CLASSES:-TS}"
STUB
chmod +x "$stub_bin"/*

run_repair() {
  CALLS="$calls" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-realtime-repair" --after-login
}

LINGER=no run_repair || fail "a non-lingering login exits successfully"
[[ ! -s $calls ]] || fail "a non-lingering login does not restart audio"

LINGER=yes run_repair || fail "a lingering login exits successfully"
[[ $(<"$calls") == "restart" ]] || fail "a non-realtime PipeWire server restarts the audio units"
pass "login retries audio startup when linger started PipeWire without realtime scheduling"

: >"$calls"
LINGER=yes PIPEWIRE_CLASSES="TS RR" run_repair || fail "a realtime PipeWire server exits successfully"
[[ ! -s $calls ]] || fail "a realtime PipeWire server is left running"
pass "login leaves the audio units running when PipeWire already has realtime scheduling"
