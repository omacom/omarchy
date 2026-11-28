#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
sudo_log="$test_tmp/sudo.log"
drop_in="default/systemd/system/nordvpnd.service.d/10-omarchy.conf"
mkdir -p "$mock_bin"

# Record privileged calls instead of running them. Only `install` runs, and only
# into the temporary directory, so the tests can check the file it leaves;
# nothing touches the host.
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_LOG"
if [[ $1 == "install" && ${!#} == "$TEST_TMP"/* ]]; then
  exec "$@"
fi
SH
cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
[[ $1 == "nordvpn-bin" ]]
SH
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "nordvpn-bin" && ${OMARCHY_TEST_NORDVPN:-0} == "1" ]]
SH
cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

run() {
  : >"$sudo_log"
  TEST_TMP="$test_tmp" SUDO_LOG="$sudo_log" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" "$@" >/dev/null 2>&1
}

# The installed drop-in is a 0644 copy of the one Omarchy ships.
assert_installed() {
  [[ -f $OMARCHY_NORDVPN_DROP_IN_DST ]] && cmp -s "$ROOT/$drop_in" "$OMARCHY_NORDVPN_DROP_IN_DST" &&
    [[ $(stat -c %a "$OMARCHY_NORDVPN_DROP_IN_DST") == "644" ]] ||
    fail "$1" "$(ls -l "$OMARCHY_NORDVPN_DROP_IN_DST" 2>&1)"
}

# Stands in for an administrator's change to the drop-in.
customize_drop_in() {
  mkdir -p "$(dirname "$OMARCHY_NORDVPN_DROP_IN_DST")"
  printf '[Service]\n' >"$OMARCHY_NORDVPN_DROP_IN_DST"
}

assert_customized() {
  [[ $(cat "$OMARCHY_NORDVPN_DROP_IN_DST") == "[Service]" ]] || fail "$1" "$(cat "$OMARCHY_NORDVPN_DROP_IN_DST")"
}

grep -qx 'ExecStartPre=-/usr/bin/nm-online -s -q -t 15' "$ROOT/$drop_in" ||
  fail "the drop-in waits for NetworkManager startup, bounded and non-fatal"
pass "the nordvpnd drop-in waits for NetworkManager at most 15 s"

export OMARCHY_NORDVPN_DROP_IN_DST="$test_tmp/etc/nordvpnd.service.d/10-omarchy.conf"
install_line="install -Dm644 $ROOT/$drop_in $OMARCHY_NORDVPN_DROP_IN_DST"

installer="$ROOT/bin/omarchy-install-service-nordvpn"
grep -qF '${OMARCHY_NORDVPN_DROP_IN_DST:-/etc/systemd/system/nordvpnd.service.d/10-omarchy.conf}' "$installer" ||
  fail "the installer targets the system drop-in directory by default"

run "$installer" || true
mapfile -t calls <"$sudo_log"
[[ ${calls[0]:-} == "$install_line" && ${calls[1]:-} == "systemctl daemon-reload" &&
  ${calls[2]:-} == "systemctl enable --now nordvpnd" ]] ||
  fail "the installer adds the drop-in before enabling nordvpnd" "$(cat "$sudo_log")"
assert_installed "the installer installs the shipped drop-in with mode 0644"
pass "the installer adds the drop-in before enabling nordvpnd"

# Rerunning the installer (a reinstall) keeps an administrator's changes.
customize_drop_in
run "$installer" || true
mapfile -t calls <"$sudo_log"
[[ ${calls[0]:-} == "systemctl daemon-reload" && ${calls[1]:-} == "systemctl enable --now nordvpnd" ]] ||
  fail "the installer still enables nordvpnd with the drop-in present" "$(cat "$sudo_log")"
assert_customized "the installer keeps an existing drop-in"
pass "the installer keeps an existing drop-in"
rm -f "$OMARCHY_NORDVPN_DROP_IN_DST"

migration="$ROOT/migrations/1791153035.sh"

export OMARCHY_TEST_NORDVPN=1
run bash -euo pipefail "$migration" || fail "the migration succeeds with NordVPN installed" "$(cat "$sudo_log")"
mapfile -t calls <"$sudo_log"
[[ ${calls[0]:-} == "$install_line" && ${calls[1]:-} == "systemctl daemon-reload" ]] ||
  fail "the migration adds the drop-in for NordVPN users" "$(cat "$sudo_log")"
assert_installed "the migration installs the shipped drop-in with mode 0644"
pass "the migration adds the drop-in when NordVPN is installed"

# A drop-in already in place (another user ran the migration, or an
# administrator changed it) is left alone.
customize_drop_in
run bash -euo pipefail "$migration" || fail "the migration succeeds with the drop-in present"
[[ ! -s $sudo_log ]] || fail "the migration keeps an existing drop-in" "$(cat "$sudo_log")"
assert_customized "the migration keeps an existing drop-in"
pass "the migration keeps an existing drop-in"
rm -f "$OMARCHY_NORDVPN_DROP_IN_DST"

unset OMARCHY_TEST_NORDVPN
run bash -euo pipefail "$migration" || fail "the migration succeeds without NordVPN"
[[ ! -s $sudo_log && ! -e $OMARCHY_NORDVPN_DROP_IN_DST ]] ||
  fail "the migration leaves machines without NordVPN alone" "$(cat "$sudo_log")"
pass "the migration does nothing without NordVPN"
