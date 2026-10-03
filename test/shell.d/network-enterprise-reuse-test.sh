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
  while IFS= read -r uuid; do
    [[ -n $uuid ]] || continue
    printf '%s:802-11-wireless\n' "$uuid"
  done <"$state/wifi-uuids"
  exit 0
fi

# nmcli -g escapes : and \ by default; -e no returns the raw SSID.
escape_nmcli_value() {
  local value=$1
  value=${value//\\/\\\\}
  value=${value//:/\\:}
  printf '%s\n' "$value"
}

if [[ $1 == "-e" && $2 == "no" && $3 == "-g" && $5 == "connection" && $6 == "show" && $7 == "uuid" ]]; then
  case "$4" in
    802-11-wireless.ssid) profile_get "$8" ssid ;;
    802-11-wireless-security.key-mgmt) profile_get "$8" key-mgmt ;;
  esac
  exit 0
fi

if [[ $1 == "-g" && $3 == "connection" && $4 == "show" && $5 == "uuid" ]]; then
  case "$2" in
    802-11-wireless.ssid) escape_nmcli_value "$(profile_get "$6" ssid)" ;;
    802-11-wireless-security.key-mgmt) profile_get "$6" key-mgmt ;;
  esac
  exit 0
fi

if [[ $1 == "connection" && $2 == "add" ]]; then
  uuid=""
  ssid=""
  identity=""
  i=1
  while (( i <= $# )); do
    arg=${!i}
    if [[ $arg == connection.uuid ]]; then
      (( i++ ))
      uuid=${!i}
    elif [[ $arg == ssid ]]; then
      (( i++ ))
      ssid=${!i}
    elif [[ $arg == 802-1x.identity ]]; then
      (( i++ ))
      identity=${!i}
    fi
    (( i++ )) || true
  done
  [[ -n $uuid && -n $ssid ]] || exit 1
  printf '%s\n' "$uuid" >>"$state/wifi-uuids"
  cat >"$state/profile.$uuid" <<PROF
ssid=$ssid
key-mgmt=wpa-eap
identity=$identity
created=1
PROF
  echo "$uuid" >"$state/last-created"
  exit 0
fi

if [[ $1 == "connection" && $2 == "edit" && $3 == "uuid" ]]; then
  uuid=$4
  while IFS= read -r line; do
    case "$line" in
      "set 802-1x.identity "*) profile_set "$uuid" identity "${line#set 802-1x.identity }" ;;
      "set 802-1x.password "*) profile_set "$uuid" password "${line#set 802-1x.password }" ;;
      save|quit) ;;
      *) ;;
    esac
  done
  exit 0
fi

if [[ $1 == "connection" && $2 == "up" && $3 == "uuid" ]]; then
  uuid=$4
  if [[ -f $state/fail-up ]]; then
    exit 1
  fi
  echo "$uuid" >"$state/last-up"
  exit 0
fi

if [[ $1 == "connection" && $2 == "delete" && $3 == "uuid" ]]; then
  uuid=$4
  echo "$uuid" >>"$state/deleted"
  rm -f "$state/profile.$uuid"
  if [[ -f $state/wifi-uuids ]]; then
    grep -vxF "$uuid" "$state/wifi-uuids" >"$state/wifi-uuids.tmp" || true
    mv "$state/wifi-uuids.tmp" "$state/wifi-uuids"
  fi
  exit 0
fi

echo "unexpected nmcli: $*" >&2
exit 99
EOF
chmod +x "$tmp/bin/nmcli"

seed() {
  printf '%s\n' "$1" >>"$tmp/state/wifi-uuids"
  cat >"$tmp/state/profile.$1" <<PROF
ssid=$2
key-mgmt=$3
identity=${4:-}
PROF
}

profile_field() {
  awk -F= -v k="$2" '$1 == k { print substr($0, index($0, "=") + 1); exit }' "$tmp/state/profile.$1"
}

script=$(node -e "const m=require('$ROOT/shell/plugins/panels/network/Model.js'); process.stdout.write(m.enterpriseConnectScript)")

run_script() {
  local ssid=$1 identity=$2 password=$3
  PATH="$tmp/bin:$PATH" bash -c "$script" nmcli-eap "$ssid" "$identity" <<<"$password"
}

: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/fail-up"
seed cat-eduroam eduroam wpa-eap user@school.edu
seed home-psk HomeNet wpa-psk

run_script eduroam user@school.edu 's3cret'
[[ $(<"$tmp/state/last-up") == cat-eduroam ]] || fail "reuses the existing wpa-eap profile UUID" "up=$(cat "$tmp/state/last-up" 2>/dev/null || true)"
[[ ! -e $tmp/state/last-created ]] || fail "does not create a second profile when one exists"
[[ $(profile_field cat-eduroam password) == s3cret ]] || fail "updates the password on the existing profile"
[[ $(profile_field cat-eduroam identity) == user@school.edu ]] || fail "updates the identity on the existing profile"
[[ ! -e $tmp/state/deleted ]] || fail "never deletes a pre-existing enterprise profile"
pass "reuses an existing wpa-eap profile"

: >"$tmp/state/log"
rm -f "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/deleted"
run_script campus campus-user 'newpass'
created=$(cat "$tmp/state/last-created")
[[ -n $created ]] || fail "creates a profile when none exists for the SSID"
[[ $(<"$tmp/state/last-up") == "$created" ]] || fail "activates the newly created profile"
[[ $(profile_field "$created" password) == newpass ]] || fail "stores the password on the new profile"
pass "creates a minimal profile when none exists"

: >"$tmp/state/log"
rm -f "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/deleted"
touch "$tmp/state/fail-up"
seed keep-me keepme wpa-eap keep@school.edu
status=0
run_script keepme keep@school.edu 'bad' || status=$?
(( status != 0 )) || fail "failed activation exits non-zero"
[[ ! -e $tmp/state/deleted ]] || fail "failed activation does not delete a pre-existing profile" "$(cat "$tmp/state/deleted" 2>/dev/null || true)"
[[ -f $tmp/state/profile.keep-me ]] || fail "pre-existing profile survives a failed reconnect"
pass "failed reconnect keeps the institutional profile"

rm -f "$tmp/state/fail-up"
: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state"/profile.* "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created"
touch "$tmp/state/fail-up"
status=0
run_script brand-new brand-user 'pw' || status=$?
(( status != 0 )) || fail "failed activation of a new profile exits non-zero"
created=$(cat "$tmp/state/last-created" 2>/dev/null || true)
[[ -n $created ]] || fail "records the UUID it created before activation failed"
grep -qxF "$created" "$tmp/state/deleted" || fail "failed activation deletes only the profile this attempt created" "deleted=$(cat "$tmp/state/deleted" 2>/dev/null || true)"
[[ ! -f $tmp/state/profile.$created ]] || fail "created profile file is gone after cleanup"
pass "failed brand-new connect cleans up its own UUID"

# Default nmcli -g escaping would turn these into Campus\:Secure / Campus\\Secure
# and miss the existing profile. The helper must query with -e no.
: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state"/profile.* "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created" "$tmp/state/fail-up"
seed cat-colon 'Campus:Secure' wpa-eap user@campus.edu
run_script 'Campus:Secure' user@campus.edu 's3cret'
[[ $(<"$tmp/state/last-up") == cat-colon ]] || fail "reuses a profile whose SSID contains a colon" "up=$(cat "$tmp/state/last-up" 2>/dev/null || true)"
[[ ! -e $tmp/state/last-created ]] || fail "does not synthesize a second profile for a colon SSID"
pass "reuses an existing profile when the SSID contains a colon"

: >"$tmp/state/wifi-uuids"
: >"$tmp/state/log"
rm -f "$tmp/state"/profile.* "$tmp/state/deleted" "$tmp/state/last-up" "$tmp/state/last-created"
seed cat-backslash 'Campus\Secure' wpa-eap user@campus.edu
run_script 'Campus\Secure' user@campus.edu 's3cret'
[[ $(<"$tmp/state/last-up") == cat-backslash ]] || fail "reuses a profile whose SSID contains a backslash" "up=$(cat "$tmp/state/last-up" 2>/dev/null || true)"
[[ ! -e $tmp/state/last-created ]] || fail "does not synthesize a second profile for a backslash SSID"
pass "reuses an existing profile when the SSID contains a backslash"
