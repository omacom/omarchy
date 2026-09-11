#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

timezone_menu="$ROOT/bin/omarchy-menu-timezone"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-tzupdate"

grep -F '%wheel ALL=(root) NOPASSWD: /usr/bin/timedatectl ^set-timezone [A-Za-z0-9_+][A-Za-z0-9_+.-]*(/[A-Za-z0-9_+][A-Za-z0-9_+.-]*)*$' "$sudoers_file" >/dev/null ||
  fail "timezone sudoers rule allows passwordless timedatectl timezone changes"

! grep -F 'set-timezone *' "$sudoers_file" >/dev/null ||
  fail "timezone sudoers rule uses a bare wildcard that admits extra arguments like -H and -M"

! grep -F 'tzupdate' "$sudoers_file" >/dev/null ||
  fail "timezone sudoers rule does not grant passwordless tzupdate"

grep -F 'sudo -n -l -l "$TIMEDATECTL" set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu checks whether its exact command has a passwordless sudo grant"

grep -F 'sudo "$TIMEDATECTL" set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu uses sudo when the scoped passwordless rule is active"

grep -F 'pkexec "$TIMEDATECTL" set-timezone "$timezone"' "$timezone_menu" >/dev/null ||
  fail "timezone menu falls back to graphical authentication without the sudoers rule"

grep -F 'omarchy-shell -q omarchy.clock refresh' "$timezone_menu" >/dev/null ||
  fail "timezone menu refreshes the namespaced clock IPC target"

pass "timezone menu refreshes clock after timezone changes"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-menu-select" <<'SH'
#!/bin/bash
echo America/Chicago
SH

for command in omarchy-shell omarchy-notification-send; do
  cat >"$stub_bin/$command" <<'SH'
#!/bin/bash
:
SH
  chmod +x "$stub_bin/$command"
done

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
if [[ $1 == -n && $2 == -l ]]; then
  if [[ ${SUDO_GRANTED:-1} == 1 ]]; then
    echo "    Options: !authenticate"
  fi
  exit 0
fi
printf 'sudo %s\n' "$*" >"$ELEVATION_LOG"
SH

cat >"$stub_bin/pkexec" <<'SH'
#!/bin/bash
printf 'pkexec %s\n' "$*" >"$ELEVATION_LOG"
SH
chmod +x "$stub_bin"/*

run_timezone() {
  : >"$test_tmp/elevation"
  ELEVATION_LOG="$test_tmp/elevation" \
    SUDO_GRANTED="$1" \
    PATH="$stub_bin:$PATH" \
    bash "$timezone_menu" >/dev/null
  cat "$test_tmp/elevation"
}

[[ $(run_timezone 1) == "sudo /usr/bin/timedatectl set-timezone America/Chicago" ]] ||
  fail "timezone uses sudo while its passwordless grant is active"
[[ $(run_timezone 0) == "pkexec /usr/bin/timedatectl set-timezone America/Chicago" ]] ||
  fail "timezone uses polkit when required sudo authentication disables the grant"

pass "timezone chooses an authentication path that works with either policy"
