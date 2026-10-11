#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/dev-unlink.log"
conf_file="$test_tmp/omarchy.conf"
mkdir -p "$stub_bin" "$test_tmp/home"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$OMARCHY_DEV_UNLINK_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_UNLINK_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_UNLINK_TEST_LOG"

case "$1" in
  tee) cat >"$OMARCHY_DEV_UNLINK_TEST_CONF" ;;
  install) install "$2" "$3" "${@: -2:1}" "$OMARCHY_DEV_UNLINK_TEST_CONF" ;;
esac
SH
chmod +x "$stub_bin/sudo"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash

printf 'gum' >>"$OMARCHY_DEV_UNLINK_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_UNLINK_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_UNLINK_TEST_LOG"
SH
chmod +x "$stub_bin/gum"

cat >"$stub_bin/omarchy-system-reboot" <<'SH'
#!/bin/bash

printf 'reboot\n' >>"$OMARCHY_DEV_UNLINK_TEST_LOG"
SH
chmod +x "$stub_bin/omarchy-system-reboot"

run_unlink() {
  HOME="$test_tmp/home" \
    OMARCHY_DEV_UNLINK_TEST_LOG="$log_file" \
    OMARCHY_DEV_UNLINK_TEST_CONF="$conf_file" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-dev-unlink" "$@"
}

: >"$log_file"
run_unlink --no-reboot

[[ $(<"$conf_file") == 'export OMARCHY_PATH="/usr/share/omarchy"' ]] ||
  fail "dev unlink writes the package path guard" "$(<"$conf_file")"

# Left behind, it keeps sudo running a checkout nothing else points at.
grep -Fx $'sudo\trm\t-f\t/etc/sudoers.d/omarchy-dev-path' "$log_file" >/dev/null ||
  fail "dev unlink drops the sudo secure_path drop-in" "$(cat "$log_file")"
pass "dev unlink drops the sudo secure_path drop-in"

if grep -Eq '^(gum|reboot)' "$log_file"; then
  fail "dev unlink --no-reboot skips the reboot prompt" "$(cat "$log_file")"
fi
pass "dev unlink --no-reboot skips the reboot prompt"

: >"$log_file"
run_unlink

grep -Fx $'gum\tconfirm\tReboot now to activate?' "$log_file" >/dev/null ||
  fail "interactive dev unlink still prompts for reboot" "$(cat "$log_file")"
grep -Fx 'reboot' "$log_file" >/dev/null ||
  fail "interactive dev unlink still reboots after confirmation" "$(cat "$log_file")"
pass "interactive dev unlink keeps its reboot prompt"

if run_unlink --invalid >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"; then
  fail "dev unlink rejects unknown arguments"
fi
grep -F 'Usage: omarchy dev unlink [--no-reboot]' "$test_tmp/invalid.err" >/dev/null ||
  fail "dev unlink explains valid arguments" "$(cat "$test_tmp/invalid.err")"
pass "dev unlink rejects unknown arguments"

for config_state in missing unreadable symlink hardlink directory-symlink; do
  rm -f "$conf_file"
  victim="$test_tmp/victim-$config_state"
  printf 'private fixture\n' >"$victim"
  chmod 600 "$victim"
  victim_dir="$test_tmp/directory-$config_state"
  mkdir -p "$victim_dir"
  chmod 700 "$victim_dir"
  case "$config_state" in
    unreadable)
      touch "$conf_file"
      chmod 600 "$conf_file"
      ;;
    symlink) ln -s "$victim" "$conf_file" ;;
    hardlink) ln "$victim" "$conf_file" ;;
    directory-symlink) ln -s "$victim_dir" "$conf_file" ;;
  esac
  (umask 077; run_unlink --no-reboot >/dev/null)
  [[ -f $conf_file && ! -L $conf_file && $(stat -c '%a' "$conf_file") == "644" ]] ||
    fail "dev unlink replaces the $config_state config with a readable file under umask 077"
  [[ $(<"$conf_file") == 'export OMARCHY_PATH="/usr/share/omarchy"' ]] ||
    fail "dev unlink preserves generated config contents under umask 077"
  [[ $(<"$victim") == "private fixture" && $(stat -c '%a' "$victim") == "600" ]] ||
    fail "dev unlink leaves the $config_state referent contents and mode unchanged"
  [[ $(stat -c '%a' "$victim_dir") == "700" && -z $(find "$victim_dir" -mindepth 1 -print -quit) ]] ||
    fail "dev unlink writes nothing inside a symlinked directory"
  pass "dev unlink replaces the $config_state config without changing its referent"
done

rm -f "$conf_file"
mkdir "$conf_file"
chmod 700 "$conf_file"
: >"$log_file"
if run_unlink --no-reboot >/dev/null 2>"$test_tmp/directory.err"; then
  fail "dev unlink refuses a directory at the config path"
fi
[[ -d $conf_file && $(stat -c '%a' "$conf_file") == "700" && -z $(find "$conf_file" -mindepth 1 -print -quit) ]] ||
  fail "dev unlink leaves the config directory untouched"
if grep -F '/etc/sudoers.d/omarchy-dev-path' "$log_file" >/dev/null; then
  fail "dev unlink changes no sudoers file after the config write fails"
fi
pass "dev unlink refuses a directory at the config path"

grep -Fx $'sudo\tinstall\t-Dm644\t-T\t-o\troot\t-g\troot\t/dev/stdin\t/etc/omarchy.conf' "$log_file" >/dev/null ||
  fail "dev-unlink installs the config root-owned with mode 0644" "$(cat "$log_file")"
pass "dev-unlink installs the config root-owned with mode 0644"
