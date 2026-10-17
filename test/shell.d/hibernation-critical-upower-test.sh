#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dropin="$ROOT/default/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf"
setup="$ROOT/bin/omarchy-hibernation-setup"
remove="$ROOT/bin/omarchy-hibernation-remove"
migration=""
for path in "$ROOT"/migrations/*.sh; do
  if grep -Fq '70-omarchy-critical-hibernate.conf' "$path"; then
    migration=$path
    break
  fi
done

[[ -f $dropin ]] || fail "UPower critical-hibernate drop-in is present in default/"
grep -Fx 'CriticalPowerAction=Hibernate' "$dropin" >/dev/null ||
  fail "drop-in sets CriticalPowerAction=Hibernate"
grep -Fx 'PercentageCritical=8.0' "$dropin" >/dev/null ||
  fail "drop-in raises PercentageCritical above PercentageAction"
grep -Fx 'PercentageAction=5.0' "$dropin" >/dev/null ||
  fail "drop-in raises PercentageAction above the stock 2%"
pass "shipped UPower drop-in hibernates with margin above 2%"

grep -F 'install_critical_power_upower' "$setup" >/dev/null ||
  fail "hibernation setup installs the UPower critical-hibernate drop-in"
grep -F '/etc/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf' "$setup" >/dev/null ||
  fail "hibernation setup targets the UPower conf.d drop-in path"
grep -F 'install_root_file "$source" "$destination" 0644' "$setup" >/dev/null ||
  fail "hibernation setup installs the drop-in as root-owned 0644 configuration"

resume_marker_line=$(rg -n '^echo "HOOKS\+=\(resume\)"' "$setup" | cut -d: -f1)
upower_after_setup_line=$(rg -n '^if ! install_critical_power_upower; then' "$setup" | tail -1 | cut -d: -f1)
[[ -n $resume_marker_line && -n $upower_after_setup_line ]] ||
  fail "hibernation setup keeps recognizable resume and UPower install steps"
(( resume_marker_line < upower_after_setup_line )) ||
  fail "hibernation setup installs UPower drop-in only after the resume marker exists"

already_setup_upower_line=$(rg -n '^  if ! install_critical_power_upower; then' "$setup" | head -1 | cut -d: -f1)
already_setup_exit_line=$(rg -n '^  echo "Hibernation is already set up"' "$setup" | cut -d: -f1)
[[ -n $already_setup_upower_line && -n $already_setup_exit_line ]] ||
  fail "hibernation setup keeps the already-configured UPower repair path"
(( already_setup_upower_line < already_setup_exit_line )) ||
  fail "already-configured hibernation still installs the UPower drop-in"
pass "hibernation setup publishes the UPower drop-in with hibernation"

grep -F '/etc/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf' "$remove" >/dev/null ||
  fail "hibernation remove targets the UPower critical-hibernate drop-in"
grep -F 'sudo rm -f "$UPPOWER_DROP_IN"' "$remove" >/dev/null ||
  fail "hibernation remove deletes the UPower drop-in"
pass "hibernation remove clears the UPower critical-hibernate drop-in"

[[ -n $migration && -f $migration ]] || fail "migration installs the UPower critical-hibernate drop-in"
grep -F 'omarchy_resume.conf' "$migration" >/dev/null ||
  fail "migration gates on Omarchy hibernation resume configuration"
grep -F '70-omarchy-critical-hibernate.conf' "$migration" >/dev/null ||
  fail "migration installs the shipped UPower drop-in"
[[ $(stat -c '%a' "$migration") == 644 ]] ||
  fail "migration permissions are 0644"
! head -1 "$migration" | grep -q '^#!' ||
  fail "migration has no shebang"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/etc/mkinitcpio.conf.d" "$test_tmp/etc/UPower/UPower.conf.d" "$test_tmp/bin"
printf 'HOOKS+=(resume)\n' >"$test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf"

cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${SYSTEMCTL_LOG:?}"
exit 0
SH
chmod +x "$test_tmp/bin/sudo" "$test_tmp/bin/systemctl"

SYSTEMCTL_LOG="$test_tmp/systemctl.log"
destination="$test_tmp/etc/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf"

OMARCHY_PATH="$ROOT" \
  OMARCHY_MKINITCPIO_RESUME_CONF="$test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf" \
  OMARCHY_UPOWER_CRITICAL_HIBERNATE_CONF="$destination" \
  PATH="$test_tmp/bin:$PATH" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  bash -euo pipefail "$migration"

cmp -s "$dropin" "$destination" || fail "migration copies the shipped UPower drop-in into place"
grep -F 'try-restart upower.service' "$SYSTEMCTL_LOG" >/dev/null ||
  fail "migration restarts upower after installing the drop-in"

: >"$SYSTEMCTL_LOG"
OMARCHY_PATH="$ROOT" \
  OMARCHY_MKINITCPIO_RESUME_CONF="$test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf" \
  OMARCHY_UPOWER_CRITICAL_HIBERNATE_CONF="$destination" \
  PATH="$test_tmp/bin:$PATH" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  bash -euo pipefail "$migration"

[[ ! -s $SYSTEMCTL_LOG ]] || fail "idempotent migration does not restart upower when drop-in matches"
pass "migration installs UPower critical-hibernate only when hibernation is set up"

rm -f "$destination"
: >"$SYSTEMCTL_LOG"
printf '# no resume\n' >"$test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf"
OMARCHY_PATH="$ROOT" \
  OMARCHY_MKINITCPIO_RESUME_CONF="$test_tmp/etc/mkinitcpio.conf.d/omarchy_resume.conf" \
  OMARCHY_UPOWER_CRITICAL_HIBERNATE_CONF="$destination" \
  PATH="$test_tmp/bin:$PATH" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  bash -euo pipefail "$migration"

[[ ! -e $destination ]] || fail "migration skips machines without the Omarchy resume hook"
[[ ! -s $SYSTEMCTL_LOG ]] || fail "migration does not touch upower without hibernation"
pass "migration leaves desktops without hibernation on stock UPower Auto"
