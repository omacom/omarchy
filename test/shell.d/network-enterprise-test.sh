#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercises Model.js's enterprise (802.1X) connect helper against a stand-in
# nmcli: the passphrase must travel over stdin (argv is world-readable), a
# failed activation must delete the profile this attempt created, and
# cancelling (SIGTERM, as Process::setRunning(false) sends) must kill the
# blocking `connection up` child and run the same cleanup -- otherwise a
# cancelled attempt leaves a profile in NetworkManager with no password on
# it. Pre-existing profiles are never enumerated by this helper (it always
# mints a fresh UUID), so they must survive every path below.
script=$(node -e "const m = require('$ROOT/shell/plugins/panels/network/Model.js'); process.stdout.write(m.enterpriseConnectScript)")

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/state"
export NMCLI_STATE="$tmp/state"

cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
state=${NMCLI_STATE:?}
echo "$*" >>"$state/argv"
case "$1 $2" in
  "connection add")
    uuid=""
    prev=""
    for arg in "$@"; do
      if [[ $prev == connection.uuid ]]; then uuid=$arg; fi
      prev=$arg
    done
    # SLOW_ADD parks setup in this step so TERM can land before activation.
    if [[ -f $state/slow-add ]]; then sleep 5; fi
    echo created >"$state/profile.$uuid"
    echo "$uuid" >>"$state/profiles"
    ;;
  "connection edit")
    uuid=$4
    while IFS= read -r line; do
      case "$line" in
        "set 802-1x.password "*) echo "${line#set 802-1x.password }" >"$state/stdin-pw.$uuid" ;;
      esac
    done
    ;;
  "connection up")
    uuid=$4
    # exec keeps the PID, so a lingering entry here proves the child survived.
    echo $$ >"$state/up-pid"
    if [[ -f $state/fail-up ]]; then echo "activation failed" >&2; exit 1; fi
    exec sleep 30
    ;;
  "connection delete")
    uuid=$4
    echo "$uuid" >>"$state/deleted"
    rm -f "$state/profile.$uuid"
    ;;
  *)
    echo "unexpected nmcli: $*" >&2
    exit 99
    ;;
esac
EOF
chmod +x "$tmp/bin/nmcli"

created_uuid() {
  tail -n 1 "$tmp/state/profiles"
}

# A failed activation deletes the profile this attempt created, keeps a
# pre-existing profile, and never leaks the secret through argv.
echo "existing" >"$tmp/state/profile.PRE-EXISTING"
touch "$tmp/state/fail-up"
: >"$tmp/state/argv"
status=0
printf 's3cret' | PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-eap "Campus" "user@campus.edu" || status=$?
new=$(created_uuid)
(( status != 0 )) || fail "failed enterprise activation exits non-zero"
[[ ! -f $tmp/state/profile.$new ]] || fail "failed enterprise activation deletes its own profile"
grep -qxF "$new" "$tmp/state/deleted" || fail "failed enterprise activation deletes only its own UUID"
[[ -f $tmp/state/profile.PRE-EXISTING ]] || fail "failed enterprise activation preserves pre-existing profiles"
grep -q "PRE-EXISTING" "$tmp/state/deleted" 2>/dev/null && fail "failed enterprise activation never deletes a pre-existing profile"
[[ $(<"$tmp/state/stdin-pw.$new") == "s3cret" ]] || fail "enterprise password reaches nmcli over stdin"
if grep -q "s3cret" "$tmp/state/argv"; then
  fail "enterprise password never appears in process arguments" "$(grep "s3cret" "$tmp/state/argv")"
fi
pass "failed enterprise activation cleans up its own profile with secrets on stdin"

# Cancelling during activation kills the blocking child and deletes the
# profile, exiting 143 (128 + SIGTERM) like a terminated helper.
rm -f "$tmp/state/fail-up" "$tmp/state/up-pid" "$tmp/state/deleted" "$tmp/state/profiles" "$tmp/state/stdin-pw."*
: >"$tmp/state/argv"
printf 's3cret' | PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-eap "Campus" "user@campus.edu" &
helper=$!
for _ in $(seq 1 100); do [[ -f $tmp/state/up-pid ]] && break; sleep 0.1; done
[[ -f $tmp/state/up-pid ]] || fail "enterprise activation reaches the blocking step" "$(cat "$tmp/state/argv")"
child=$(<"$tmp/state/up-pid")
kill -TERM "$helper"
status=0
wait "$helper" || status=$?
(( status == 143 )) || fail "cancelled enterprise activation exits 143" "status=$status"
if kill -0 "$child" 2>/dev/null; then
  fail "cancelled enterprise activation kills the blocking child" "child $child still alive"
fi
[[ ! -f $tmp/state/profile.$(created_uuid) ]] || fail "cancelled enterprise activation deletes its own profile"
pass "cancelled enterprise activation kills its child and cleans up"

# Cancelling during profile setup still deletes the half-built profile: bash
# runs the pending trap once the foreground step finishes.
touch "$tmp/state/slow-add"
rm -f "$tmp/state/deleted" "$tmp/state/profiles"
: >"$tmp/state/argv"
printf 's3cret' | PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-eap "Campus" "user@campus.edu" &
helper=$!
for _ in $(seq 1 100); do grep -q "connection add" "$tmp/state/argv" 2>/dev/null && break; sleep 0.1; done
grep -q "connection add" "$tmp/state/argv" || fail "enterprise setup reaches profile creation"
kill -TERM "$helper"
status=0
wait "$helper" || status=$?
rm -f "$tmp/state/slow-add"
(( status == 143 )) || fail "cancelled enterprise setup exits 143" "status=$status"
new=$(created_uuid)
[[ ! -f $tmp/state/profile.$new ]] || fail "cancelled enterprise setup deletes the half-built profile"
grep -qxF "$new" "$tmp/state/deleted" || fail "cancelled enterprise setup deletes only its own UUID"
pass "cancelled enterprise setup deletes the half-built profile"
