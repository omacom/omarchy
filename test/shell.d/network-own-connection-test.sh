#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A child's new network is created as their own (connection.permissions),
# which NetworkManager lets them do without an administrator, and its
# password reaches nmcli only on stdin.

require_command node
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
cat >"$tmp/bin/nmcli" <<'SH'
#!/bin/bash
echo "ARGS: $*" >>"$LOG"
[[ $1 == connection && $2 == edit ]] && sed 's/^/STDIN: /' >>"$LOG"
[[ $1 == connection && $2 == up && -n ${FAIL_UP:-} ]] && exit 4
true
SH
printf '#!/bin/bash\necho uuid-1\n' >"$tmp/bin/uuidgen"
chmod +x "$tmp/bin/"*

model=$ROOT/shell/plugins/panels/network/Model.js
script=$(node -e 'process.stdout.write(require(process.argv[1]).ownConnectScript)' "$model")
connect() {
  printf '%s\n' "$1" | LOG=$tmp/log USER=emma PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-own "$2" "$3"
}

: >"$tmp/log"
connect 'school pass' SchoolNet wpa-psk
grep -qx 'ARGS: connection add type wifi con-name SchoolNet ssid SchoolNet connection.uuid uuid-1 connection.permissions user:emma wifi-sec.key-mgmt wpa-psk' "$tmp/log" || fail "a child's network is created as theirs" "$(cat "$tmp/log")"
grep -qx 'STDIN: set wifi-sec.psk school pass' "$tmp/log" || fail "the password is set over stdin"
! grep '^ARGS:' "$tmp/log" | grep -q 'school pass' || fail "the password never reaches argv"
pass "a child's new password network is created as theirs, with the password only on stdin"

: >"$tmp/log"
connect '' CafeOpen ''
[[ $(grep -c '^ARGS:' "$tmp/log") == 2 ]] && ! grep -q 'key-mgmt\|edit' "$tmp/log" || fail "an open network takes no security settings" "$(cat "$tmp/log")"
pass "a child's new open network is created as theirs without security settings"

: >"$tmp/log"
if FAIL_UP=1 connect 'wrong pass' SchoolNet wpa-psk; then
  fail "a failed connection reports failure"
fi
grep -qx 'ARGS: connection delete uuid uuid-1' "$tmp/log" || fail "a failed connection removes the profile it made"
pass "a failed connection removes the profile it made"

keymgmt() {
  node -e 'const m = require(process.argv[1]); const t = { Open: 1, Owe: 2, Sae: 3, WpaPsk: 4, Wpa2Psk: 5, StaticWep: 6 }; process.stdout.write(String(m.ownKeyMgmt(t[process.argv[2]], t)))' "$model" "$1"
}
[[ $(keymgmt Open) == "" && $(keymgmt Owe) == "owe" && $(keymgmt Sae) == "sae" && $(keymgmt Wpa2Psk) == "wpa-psk" && $(keymgmt StaticWep) == "null" ]] ||
  fail "key management follows the network's security"
pass "key management follows the network's security, and WEP keeps the shared path"
