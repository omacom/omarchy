#!/bin/bash

set -euo pipefail

# Omarchy ships hardening-adjacent sysctls in etc/sysctl.d/.
# dev.tty.ldisc_autoload=0 must stay present so unprivileged TIOCSETD cannot
# cold-load obscure line-discipline modules.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

conf="$ROOT/etc/sysctl.d/99-omarchy-sysctl.conf"
[[ -f $conf ]] || fail "99-omarchy-sysctl.conf is packaged under etc/sysctl.d"

grep -Eq '^[[:space:]]*dev\.tty\.ldisc_autoload[[:space:]]*=[[:space:]]*0[[:space:]]*$' "$conf" ||
  fail "99-omarchy-sysctl.conf sets dev.tty.ldisc_autoload=0" "$(grep ldisc "$conf" || true)"

! grep -Eq '^[[:space:]]*dev\.tty\.ldisc_autoload[[:space:]]*=[[:space:]]*1[[:space:]]*$' "$conf" ||
  fail "99-omarchy-sysctl.conf must not set ldisc_autoload=1"

pass "sysctl drop-in disables unprivileged TTY ldisc autoload"

migration="$ROOT/migrations/1790423600.sh"
[[ -f $migration ]] || fail "the dedicated ldisc migration exists"
case_root=$(mktemp -d)
trap 'rm -rf "$case_root"' EXIT
mkdir -p "$case_root/bin"
export TEST_CONFIG="$case_root/sysctl.conf" TEST_VALUE="$case_root/value"
export TEST_CALLS="$case_root/calls" TEST_REBOOT="$case_root/reboot"
# Only relocate the fixed system path. All control flow comes from the actual
# migration, while sudo/sysctl/state are stubs that cannot touch this host.
sed 's@^config=/etc/sysctl.d/99-omarchy-sysctl.conf$@config="$TEST_CONFIG"@' "$migration" >"$case_root/migration.sh"
cat >"$case_root/bin/sysctl" <<'SH'
#!/bin/bash
printf 'sysctl %s\n' "$*" >>"$TEST_CALLS"
if [[ $* == '-n dev.tty.ldisc_autoload' ]]; then
  if [[ $TEST_MODE == read-error ]]; then echo read-error >&2; exit 1; fi
  cat "$TEST_VALUE"
elif [[ ${TEST_SUDO:-} == 1 ]] && { [[ $* == '-w dev.tty.ldisc_autoload=0' ]] || [[ $1 == -p && $2 == "$TEST_CONFIG" ]]; }; then
  if [[ $TEST_MODE == apply-error ]]; then echo apply-error >&2; exit 1; fi
  if [[ $TEST_MODE != unchanged ]]; then printf '0\n' >"$TEST_VALUE"; fi
  if [[ $1 == -p ]] && grep -q 'unsupported.example' "$TEST_CONFIG"; then echo unsupported-key >&2; exit 1; fi
else
  echo unexpected-sysctl >&2
  exit 99
fi
SH
cat >"$case_root/bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$TEST_CALLS"
[[ $1 == sysctl ]] && { [[ $* == 'sysctl -w dev.tty.ldisc_autoload=0' ]] || [[ $2 == -p && $3 == "$TEST_CONFIG" ]]; } || exit 99
if [[ $TEST_MODE == sudo-error ]]; then echo sudo-error >&2; exit 1; fi
export TEST_SUDO=1
exec "$@"
SH
cat >"$case_root/bin/omarchy-state" <<'SH'
#!/bin/bash
[[ $* == 'set reboot-required' ]] || exit 99
touch "$TEST_REBOOT"
SH
chmod +x "$case_root/bin/"*

run_case() {
  local label=$1 contents=$2 value=$3 mode=$4 expected=$5 apply=$6 reboot=$7
  printf '%s\n' "$contents" >"$TEST_CONFIG"
  [[ $contents != missing ]] || rm "$TEST_CONFIG"
  printf '%s\n' "$value" >"$TEST_VALUE"
  : >"$TEST_CALLS"
  rm -f "$TEST_REBOOT"
  local status=0
  TEST_MODE="$mode" PATH="$case_root/bin:$PATH" bash -euo pipefail "$case_root/migration.sh" >"$case_root/output" 2>&1 || status=$?
  (( status == expected )) || fail "$label has the expected completion status" "$(cat "$case_root/output")"
  if (( apply )); then
    grep -Fq "sudo sysctl " "$TEST_CALLS" || fail "$label applies through sudo"
  else
    ! grep -q '^sudo ' "$TEST_CALLS" || fail "$label must not apply the drop-in"
  fi
  if (( reboot )); then
    [[ -e $TEST_REBOOT ]] || fail "$label requests a reboot"
  else
    [[ ! -e $TEST_REBOOT ]] || fail "$label must not request a reboot"
  fi
  if [[ $mode == *-error ]]; then
    grep -Fq "$mode" "$case_root/output" || fail "$label leaves diagnostics visible"
  fi
  pass "$label"
}

setting='dev.tty.ldisc_autoload=0'
run_case 'already applied setting avoids sudo' "$setting" 0 normal 0 0 0
run_case 'successful apply verifies the changed runtime value' "$setting" 1 normal 0 1 0
run_case 'sudo failure stays pending and visible' "$setting" 1 sudo-error 1 1 1
run_case 'apply failure stays pending and visible' "$setting" 1 apply-error 1 1 1
run_case 'successful command with unchanged value stays pending' "$setting" 1 unchanged 1 1 1
run_case 'unreadable runtime value stays pending' "$setting" 1 read-error 1 1 1
run_case 'missing drop-in stays pending' missing 1 normal 1 0 0
run_case 'edited drop-in without the key stays pending' 'vm.swappiness=100' 1 normal 1 0 0
run_case 'runtime zero cannot hide a missing persisted setting' 'vm.swappiness=100' 0 normal 1 0 0
run_case 'later conflicting assignment stays pending' "$setting"$'\ndev.tty.ldisc_autoload=1' 0 normal 1 0 0
run_case 'commented setting is not persistent protection' "# $setting" 0 normal 1 0 0
run_case 'whitespace and an inline comment are accepted' ' dev.tty.ldisc_autoload = 0 # hardened' 0 normal 0 0 0

run_case 'unrelated unsupported key does not block the owned setting' "$setting"$'\nunsupported.example=1' 1 normal 0 1 0
