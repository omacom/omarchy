#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/state"
export NMCLI_STATE=$tmp/state

cat >"$tmp/bin/nmcli" <<'EOF'
#!/bin/bash
set -euo pipefail
state=${NMCLI_STATE:?}
echo "$*" >>"$state/log"

profile_get() {
  local uuid=$1
  local key=$2
  local file=$state/profile.$uuid
  [[ -f $file ]] || return 0
  awk -F= -v k="$key" '$1 == k { print substr($0, index($0, "=") + 1); exit }' "$file"
}

profile_set() {
  local uuid=$1
  local key=$2
  local value=$3
  local file=$state/profile.$uuid
  local tmpf=$state/profile.$uuid.tmp
  if [[ -f $file ]]; then
    awk -F= -v k="$key" '$1 != k { print }' "$file" >"$tmpf"
  else
    : >"$tmpf"
  fi
  printf '%s=%s\n' "$key" "$value" >>"$tmpf"
  mv "$tmpf" "$file"
}

if [[ $1 == "-t" && $2 == "-f" && $3 == "UUID,TYPE" ]]; then
  if [[ -f $state/fail-list ]]; then
    echo "Error: NetworkManager is not running." >&2
    exit 8
  fi
  while IFS= read -r uuid; do
    [[ -n $uuid ]] || continue
    printf '%s:802-11-wireless\n' "$uuid"
  done <"$state/wifi-uuids"
  exit 0
fi

if [[ $1 == "-g" && $3 == "connection" && $4 == "show" && $5 == "uuid" ]]; then
  case "$2" in
    802-11-wireless-security.key-mgmt) profile_get "$6" key-mgmt ;;
    802-1x.auth-timeout) profile_get "$6" auth-timeout ;;
  esac
  exit 0
fi

if [[ $1 == "connection" && $2 == "modify" && $3 == "uuid" ]]; then
  uuid=$4
  shift 4
  while (( $# >= 2 )); do
    [[ $1 == "802-1x.auth-timeout" ]] && profile_set "$uuid" auth-timeout "$2"
    shift 2
  done
  exit 0
fi

echo "unexpected nmcli: $*" >&2
exit 99
EOF
chmod +x "$tmp/bin/nmcli"

profile_field() {
  awk -F= -v k="$2" '$1 == k { print substr($0, index($0, "=") + 1); exit }' "$tmp/state/profile.$1"
}

seed() {
  printf '%s\n' "$1" >>"$tmp/state/wifi-uuids"
  cat >"$tmp/state/profile.$1" <<PROF
key-mgmt=$2
auth-timeout=$3
PROF
}

: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
seed stale-eap wpa-eap 8
seed already-ok wpa-eap 0
seed psk-home wpa-psk 8

PATH="$tmp/bin:$PATH" bash "$ROOT/migrations/1789647821.sh" >/dev/null

[[ $(profile_field stale-eap auth-timeout) == "0" ]] || fail "migration clears auth-timeout 8 on wpa-eap profiles"
[[ $(profile_field already-ok auth-timeout) == "0" ]] || fail "migration leaves auth-timeout 0 alone"
[[ $(profile_field psk-home auth-timeout) == "8" ]] || fail "migration ignores non-enterprise profiles"
pass "migration clears only stale enterprise auth-timeout values"

modify_count=$(grep -c 'connection modify' "$tmp/state/log" || true)
PATH="$tmp/bin:$PATH" bash "$ROOT/migrations/1789647821.sh" >/dev/null
[[ $(grep -c 'connection modify' "$tmp/state/log" || true) == "$modify_count" ]] ||
  fail "second migration run must not issue another connection modify"
pass "migration is idempotent"

: >"$tmp/state/fail-list"
set +e
PATH="$tmp/bin:$PATH" bash "$ROOT/migrations/1789647821.sh" >/dev/null 2>"$tmp/state/fail.err"
list_rc=$?
set -e
(( list_rc != 0 )) || fail "failed connection list must exit non-zero so the migrate marker stays unset"
grep -q 'leaving migration pending' "$tmp/state/fail.err" ||
  fail "failed connection list should say the migration stays pending"
[[ $(profile_field stale-eap auth-timeout) == "0" ]] || fail "failed list must not undo a prior successful repair"
pass "failed connection list leaves the migration retryable"
