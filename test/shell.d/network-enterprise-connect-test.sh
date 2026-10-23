#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command node

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

# Records each nmcli call's argv, quoted per argument, and the editor commands
# it reads on stdin. NMCLI_FAIL names one subcommand to fail.
cat >"$tmp/bin/nmcli" <<'NMCLI'
#!/bin/bash
printf 'argv:' >>"$NMCLI_LOG"; printf ' %q' "$@" >>"$NMCLI_LOG"; printf '\n' >>"$NMCLI_LOG"
[[ "$1 $2" == "connection edit" ]] && sed 's/^/stdin: /' >>"$NMCLI_LOG"
[[ "$1 $2" == "connection $NMCLI_FAIL" ]] && exit 4
exit 0
NMCLI
chmod +x "$tmp/bin/nmcli"

script=$(node -e 'process.stdout.write(require(process.argv[1]).enterpriseConnectScript)' "$ROOT/shell/plugins/panels/network/Model.js")

connect() {
  export NMCLI_LOG="$tmp/nmcli-${1:-none}.log" NMCLI_FAIL=${1:-}
  printf 'hunter2\n' | PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-eap "Campus WiFi" person@example.org
}

calls() {
  grep '^argv: ' "$tmp/nmcli-$1.log" | cut -d' ' -f2-3 | paste -sd,
}

connect || fail "enterprise connect succeeds when nmcli does" "$(cat "$tmp/nmcli-none.log")"
[[ $(calls none) == "connection add,connection edit,connection up,connection modify" ]] ||
  fail "enterprise connect adds, saves the password, activates, then enables autoconnect" "$(calls none)"
pass "enterprise connect adds, saves the password, activates, then enables autoconnect"

# NetworkManager can auto-activate a new autoconnect profile before the editor
# has saved its password, and fails that activation with no-secrets.
grep -q '^argv: connection add .* connection.autoconnect no ' "$tmp/nmcli-none.log" ||
  fail "enterprise profile is added with autoconnect off" "$(cat "$tmp/nmcli-none.log")"
grep -q '^argv: connection modify uuid [^ ]* connection.autoconnect yes$' "$tmp/nmcli-none.log" ||
  fail "enterprise profile autoconnects once it has connected" "$(cat "$tmp/nmcli-none.log")"
pass "enterprise profile autoconnects only once it has connected"

uuid=$(sed -n 's/^argv: connection add .* connection.uuid \([^ ]*\) .*/\1/p' "$tmp/nmcli-none.log")
[[ -n $uuid && $(grep -c "^argv: connection [a-z]* uuid $uuid\( \|$\)" "$tmp/nmcli-none.log") == 3 ]] ||
  fail "enterprise connect edits, activates and modifies the profile it added" "$(cat "$tmp/nmcli-none.log")"
pass "enterprise connect edits, activates and modifies the profile it added"

[[ $(grep '^stdin: ' "$tmp/nmcli-none.log") == $'stdin: set 802-1x.password hunter2\nstdin: save\nstdin: quit' ]] ||
  fail "enterprise password is saved through the editor" "$(cat "$tmp/nmcli-none.log")"
! grep -q '^argv: .*hunter2' "$tmp/nmcli-none.log" ||
  fail "enterprise password never reaches nmcli's argv" "$(cat "$tmp/nmcli-none.log")"
pass "enterprise password is saved through the editor, never argv"

! connect up || fail "enterprise connect fails when activation does"
[[ $(calls up) == "connection add,connection edit,connection up,connection delete" ]] ||
  fail "a failed enterprise activation deletes its profile without enabling autoconnect" "$(calls up)"
pass "a failed enterprise activation deletes its profile without enabling autoconnect"

connect modify || fail "enterprise connect still succeeds when enabling autoconnect fails"
[[ $(calls modify) == "connection add,connection edit,connection up,connection modify" ]] ||
  fail "a connected enterprise profile is kept when enabling autoconnect fails" "$(calls modify)"
pass "a connected enterprise profile is kept when enabling autoconnect fails"
