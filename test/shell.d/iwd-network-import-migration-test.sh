#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command nmcli
require_command python3

migration="$ROOT/migrations/1789547167.sh"
real_nmcli=$(command -v nmcli)

tmp_dir=$(mktemp -d)
trap 'chmod -R u+rw "$tmp_dir"; rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export PATH="$tmp_dir/bin:$PATH" REAL_NMCLI="$real_nmcli" CALL_LOG="$tmp_dir/calls"

# Privileged calls run unprivileged against temporary stores. Only the
# NetworkManager daemon is faked; --offline profile conversion is the real nmcli.
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$1" >> "$CALL_LOG"
"$@"
SH
cat > "$tmp_dir/bin/nmcli" <<'SH'
#!/bin/bash
case "$*" in
  --offline\ *) exec "$REAL_NMCLI" "$@" ;;
  "-t general status") [[ ${NM_RUNNING:-0} == 1 ]] ;;
  "-t -f TYPE,UUID connection show") [[ -z ${NM_KNOWN_SSID:-} ]] || echo 802-11-wireless:known-uuid ;;
  "--escape no -g 802-11-wireless.ssid connection show known-uuid") echo "$NM_KNOWN_SSID" ;;
  "connection load "*) printf 'load %s\n' "$#" >> "$CALL_LOG" ;;
  *) exit 1 ;;
esac
SH
chmod +x "$tmp_dir/bin/"*

# Prints a profile's decoded values the way NetworkManager reads them: GLib's
# keyfile parser, with an SSID written as a byte list turned back into bytes.
profile_value() {
  python3 - "$1" "$2" "$3" <<'PY'
import re, sys
from gi.repository import GLib
path, group, key = sys.argv[1:]
data = open(path, encoding="utf-8").read()
keyfile = GLib.KeyFile()
keyfile.load_from_data(data, len(data.encode()), GLib.KeyFileFlags.NONE)
try:
    value = keyfile.get_string(group, key)
except GLib.Error:
    print("<absent>")
    sys.exit()
if key == "ssid":
    raw = bytes(int(b) for b in value.rstrip(";").split(";")) if re.fullmatch(r"(\d{1,3};)+", value) else value.encode()
    print(raw.hex())
else:
    print(repr(value))
PY
}

setup_stores() {
  rm -rf "$tmp_dir/iwd" "$tmp_dir/nm" "$tmp_dir/marker"
  mkdir -p "$tmp_dir/iwd" "$tmp_dir/nm"
  export OMARCHY_IWD_DIR="$tmp_dir/iwd" OMARCHY_NM_CONNECTIONS_DIR="$tmp_dir/nm" OMARCHY_IWD_IMPORT_MARKER="$tmp_dir/marker"
  : > "$CALL_LOG"

  # A passphrase with a leading and trailing blank and a backslash, as iwd escapes it.
  printf '[Security]\nPassphrase=\\sit is\\\\secret  \nSAE-PT-Group19=00\n' > "$tmp_dir/iwd/Home Net.psk"
  # A non-alphanumeric SSID is stored hex-encoded; this one only has a derived key.
  printf '[Settings]\nHidden=true\nAutoConnect=false\n\n[Security]\nPreSharedKey=%s\n' "$(printf 'ab%.0s' {1..32})" > "$tmp_dir/iwd/=e29895.psk"
  printf '[Settings]\nAutoConnect=true\n' > "$tmp_dir/iwd/Cafe.open"
  printf '[Security]\nPassphrase=staticpass\n\n[IPv4]\nAddress=192.168.1.20\n' > "$tmp_dir/iwd/Static.psk"
  printf '[Security]\nEAP-Method=PEAP\n' > "$tmp_dir/iwd/Corp.8021x"
  printf '[Security]\nPassphrase=short\n' > "$tmp_dir/iwd/Short.psk"
  printf '[Settings]\nHidden=false\n' > "$tmp_dir/iwd/NoPassword.psk"
}

run_migration() {
  bash -euo pipefail "$migration"
}

setup_stores
output=$(NM_RUNNING=1 run_migration)

home="$tmp_dir/nm/iwd-$(printf 'Home Net' | od -An -v -tx1 | tr -d ' \n').nmconnection"
coffee="$tmp_dir/nm/iwd-e29895.nmconnection"
cafe="$tmp_dir/nm/iwd-43616665.nmconnection"
static="$tmp_dir/nm/iwd-537461746963.nmconnection"

for profile in "$home" "$coffee" "$cafe" "$static"; do
  [[ -f $profile ]] || fail "imported profile exists: $profile" "$output"
  [[ $(stat -c %a "$profile") == "600" ]] || fail "imported profiles are private"
done
(( $(find "$tmp_dir/nm" -type f | wc -l) == 4 )) || fail "only importable networks become profiles" "$(ls "$tmp_dir/nm")"
pass "open and WPA-Personal networks are imported as private profiles"

[[ $(profile_value "$home" wifi-security psk) == "' it is\\\\secret  '" ]] || fail "passphrase survives exactly" "$(profile_value "$home" wifi-security psk)"
[[ $(profile_value "$home" wifi ssid) == "486f6d65204e6574" ]] || fail "plain SSID bytes are kept"
[[ $(profile_value "$home" connection id) == "'Home Net'" ]] || fail "profile is named after the SSID"
[[ $(profile_value "$home" connection autoconnect) != "'false'" ]] || fail "networks autoconnect by default"
pass "escaped passphrases decode to the exact iwd secret"

[[ $(profile_value "$coffee" wifi ssid) == "e29895" ]] || fail "hex-encoded SSID bytes are kept" "$(profile_value "$coffee" wifi ssid)"
[[ $(profile_value "$coffee" connection id) == "'☕'" ]] || fail "hex-encoded SSID is decoded for the name"
[[ $(profile_value "$coffee" wifi-security psk) == "'$(printf 'ab%.0s' {1..32})'" ]] || fail "derived PSK is imported"
[[ $(profile_value "$coffee" wifi hidden) == "'true'" ]] || fail "hidden networks stay hidden"
[[ $(profile_value "$coffee" connection autoconnect) == "'false'" ]] || fail "autoconnect preference is kept"
pass "hex-named, hidden and manual networks keep their settings"

[[ $(profile_value "$cafe" wifi-security key-mgmt) == "<absent>" ]] || fail "open networks have no security"
grep -Fq "Importing Static without its custom addressing" <<<"$output" || fail "custom addressing is reported" "$output"
grep -Fq "Skipping Corp: add enterprise networks again" <<<"$output" || fail "enterprise networks are reported" "$output"
grep -Fq "Skipping Short: no usable saved password" <<<"$output" || fail "invalid passphrases are reported" "$output"
grep -Fq "Skipping NoPassword: no usable saved password" <<<"$output" || fail "missing passphrases are reported" "$output"
! grep -Fq "secret" <<<"$output" || fail "output never includes a passphrase"
pass "unsupported networks are reported without printing secrets"

grep -Fxq "load 6" "$CALL_LOG" || fail "a running NetworkManager loads the four new profiles" "$(cat "$CALL_LOG")"
[[ -e $tmp_dir/marker ]] || fail "completion is recorded machine-wide"
pass "a running NetworkManager picks up the imported networks"

: > "$CALL_LOG"
NM_RUNNING=1 run_migration >/dev/null
[[ ! -s $CALL_LOG ]] || fail "a completed import does not run again for another user" "$(cat "$CALL_LOG")"
rm "$tmp_dir/marker" "$cafe"
NM_RUNNING=1 run_migration >/dev/null
(( $(find "$tmp_dir/nm" -type f | wc -l) == 4 )) || fail "a retried import only adds what is missing"
grep -Fxq "load 3" "$CALL_LOG" || fail "a retried import only loads what it added" "$(cat "$CALL_LOG")"
pass "the import is idempotent"

setup_stores
NM_RUNNING=1 NM_KNOWN_SSID="Home Net" run_migration >/dev/null
[[ ! -e $home ]] || fail "a network NetworkManager already knows is not duplicated"
pass "networks already saved in NetworkManager are left alone"

setup_stores
NM_RUNNING=1 OMARCHY_UPGRADE_TO_QUATTRO_LIVE=1 run_migration >/dev/null
[[ -f $home ]] || fail "the live upgrade still writes profiles"
! grep -q '^load' "$CALL_LOG" || fail "the live upgrade leaves loading to the reboot so iwd keeps the connection"
setup_stores
NM_RUNNING=0 run_migration >/dev/null
[[ -f $home ]] || fail "a stopped NetworkManager still gets profiles"
! grep -q '^load' "$CALL_LOG" || fail "nothing is loaded into a stopped NetworkManager"
pass "profiles wait for the reboot while iwd or a stopped NetworkManager holds Wi-Fi"

setup_stores
rm -rf "$tmp_dir/iwd"
NM_RUNNING=1 run_migration >/dev/null
[[ ! -s $CALL_LOG && ! -e $tmp_dir/marker ]] || fail "machines without an iwd store are skipped without sudo"
pass "machines that never used iwd are skipped"

setup_stores
chmod 000 "$tmp_dir/iwd/Static.psk"
if NM_RUNNING=1 run_migration >/dev/null 2>&1; then
  fail "an unreadable iwd store must leave the migration pending"
fi
[[ ! -e $tmp_dir/marker ]] || fail "a failed import is not marked complete"
pass "storage errors leave the migration pending"
