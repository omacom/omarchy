#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-hibernation-setup"
migration="$ROOT/migrations/1789568195.sh"
hibernate_policy="$ROOT/default/systemd/logind.conf.d/99-omarchy-lid-sleep.conf"
suspend_policy="$ROOT/default/systemd/logind.conf.d/99-omarchy-lid-sleep-no-hibernate.conf"

# Resuming from hibernate is broken on MacBookPro11,x (#11351 frozen lock screen
# with dead input, #7848 GPU session killed, plus a bricked 11,4), so those
# machines must not be sent into hibernate by an unattended lid-close. Both
# delivery paths — setup for new machines, the migration for existing ones —
# have to pick the battery-suspend variant, because the one that skips the other
# is the one that ships the regression.
[[ -f $suspend_policy ]] || fail "the battery-suspend lid variant exists" "$suspend_policy"
pass "the battery-suspend lid variant exists"

grep -q '^HandleLidSwitch=suspend$' "$suspend_policy" ||
  fail "the variant keeps battery lid-close in suspend"
pass "the variant keeps battery lid-close in suspend"

if grep -q '^HandleLidSwitch=suspend-then-hibernate$' "$suspend_policy"; then
  fail "the variant must not reach hibernate on battery"
fi
pass "the variant never reaches hibernate on battery"

grep -q '^HandleLidSwitchExternalPower=suspend$' "$suspend_policy" ||
  fail "the variant keeps AC lid-close in suspend"
pass "the variant keeps AC lid-close in suspend"

grep -q '^HandleLidSwitchDocked=ignore$' "$suspend_policy" ||
  fail "the variant keeps docked lid-close awake"
pass "the variant keeps docked lid-close awake"

grep -Fq 'omarchy-hw-match "MacBookPro11,"' "$setup" ||
  fail "hibernation setup gates the lid policy on the model"
pass "hibernation setup gates the lid policy on the model"

grep -Fq '99-omarchy-lid-sleep-no-hibernate.conf' "$setup" ||
  fail "hibernation setup installs the variant on broken-resume models"
pass "hibernation setup installs the variant on broken-resume models"

grep -Fq 'omarchy-hw-match "MacBookPro11,"' "$migration" ||
  fail "the migration gates the lid policy on the model"
pass "the migration gates the lid policy on the model"

grep -Fq '99-omarchy-lid-sleep-no-hibernate.conf' "$migration" ||
  fail "the migration installs the variant on broken-resume models"
pass "the migration installs the variant on broken-resume models"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

# sudo runs the real command so the install lands in the retargeted path, and
# records the call. Root-only ownership flags are dropped so the test can run
# unprivileged; the assertion below still checks the shipped migration asks for
# them, so what actually runs as root is unchanged.
cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash

printf 'sudo %s\n' "$*" >>"$CALLS"
args=()
skip=0
for arg in "$@"; do
  if (( skip )); then
    skip=0
    continue
  fi
  case "$arg" in
    -o | -g)
      skip=1
      continue
      ;;
  esac
  args+=("$arg")
done
exec "${args[@]}"
STUB

# Stands in for the DMI probe: FAKE_BROKEN_RESUME says whether this machine is
# one of the models whose hibernate resume is broken.
cat >"$test_dir/bin/omarchy-hw-match" <<'STUB'
#!/bin/bash

[[ "${FAKE_BROKEN_RESUME:-0}" == "1" ]]
STUB

cat >"$test_dir/bin/systemctl" <<'STUB'
#!/bin/bash

exit 0
STUB

cat >"$test_dir/bin/omarchy-state" <<'STUB'
#!/bin/bash

printf 'state %s\n' "$*" >>"$CALLS"
exit 0
STUB

chmod +x "$test_dir/bin/"*

export CALLS="$test_dir/calls"

resume_conf="$test_dir/mkinitcpio.conf.d/omarchy_resume.conf"
lid_dest="$test_dir/etc/systemd/logind.conf.d/99-omarchy-lid-sleep.conf"
sleep_dest="$test_dir/etc/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf"
legacy_logind="$test_dir/etc/systemd/logind.conf.d/99-suspend-then-hibernate.conf"
scratch_migration="$test_dir/migration.sh"

# The privileged destinations stay fixed literals in the shipped migration; an
# environment override would let the caller choose what root writes. Retarget a
# scratch copy so the unprivileged run installs somewhere it is allowed.
grep -Fxq 'MKINITCPIO_CONF="/etc/mkinitcpio.conf.d/omarchy_resume.conf"' "$migration" ||
  fail "the production resume marker path is a fixed literal"
grep -Fxq 'lid_dest="/etc/systemd/logind.conf.d/99-omarchy-lid-sleep.conf"' "$migration" ||
  fail "the production lid policy path is a fixed literal"
grep -Fxq 'sleep_dest="/etc/systemd/sleep.conf.d/10-omarchy-suspend-then-hibernate.conf"' "$migration" ||
  fail "the production sleep policy path is a fixed literal"

sed \
  -e "s|^MKINITCPIO_CONF=.*|MKINITCPIO_CONF=\"$resume_conf\"|" \
  -e "s|^lid_dest=.*|lid_dest=\"$lid_dest\"|" \
  -e "s|^sleep_dest=.*|sleep_dest=\"$sleep_dest\"|" \
  -e "s|^legacy_logind=.*|legacy_logind=\"$legacy_logind\"|" \
  "$migration" >"$scratch_migration"
pass "migration keeps privileged production paths caller-independent"

reset_machine() {
  rm -rf "$test_dir/mkinitcpio.conf.d" "$test_dir/etc"
  mkdir -p "$(dirname "$resume_conf")"
  # A real machine already has these directories: Omarchy ships other drop-ins
  # into them, and the migration installs rather than creates.
  mkdir -p "$(dirname "$lid_dest")" "$(dirname "$sleep_dest")"
  printf 'HOOKS+=(resume)\n' >"$resume_conf"
  : >"$CALLS"
}

run_migration() {
  OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$scratch_migration" >/dev/null
}

# A MacBookPro11,x that already hibernates: this migration is the thing that
# would otherwise hand it a policy that eats the session.
reset_machine
FAKE_BROKEN_RESUME=1 run_migration
[[ -f $lid_dest ]] || fail "migration installs a lid policy on a broken-resume machine" "$(cat "$CALLS")"
cmp -s "$suspend_policy" "$lid_dest" ||
  fail "a broken-resume model gets the battery-suspend variant" "$(cat "$lid_dest")"
pass "a broken-resume model gets the battery-suspend variant"

# A model whose resume works keeps the battery drain protection.
reset_machine
FAKE_BROKEN_RESUME=0 run_migration
cmp -s "$hibernate_policy" "$lid_dest" ||
  fail "a healthy model keeps suspend-then-hibernate" "$(cat "$lid_dest")"
pass "a healthy model keeps suspend-then-hibernate"

# A machine that already received the wrong variant is repaired, because the
# idempotence check compares against the model-appropriate source.
reset_machine
mkdir -p "$(dirname "$lid_dest")"
install -m 0644 "$hibernate_policy" "$lid_dest"
FAKE_BROKEN_RESUME=1 run_migration
cmp -s "$suspend_policy" "$lid_dest" ||
  fail "migration repairs a machine left on the hibernate variant" "$(cat "$lid_dest")"
pass "migration repairs a machine left on the hibernate variant"

# The migration asks root for the ownership it expects; the stub only dropped it
# so the test could run.
grep -q -- '-o root -g root' "$CALLS" ||
  fail "migration still installs as root-owned" "$(cat "$CALLS")"
pass "migration still installs as root-owned"

# No hibernation, no hibernate-shaped policy to choose.
reset_machine
rm -f "$resume_conf"
FAKE_BROKEN_RESUME=1 run_migration
[[ ! -e $lid_dest ]] || fail "migration installs a lid policy without hibernation"
[[ ! -s $CALLS ]] || fail "migration acts on a machine without hibernation" "$(cat "$CALLS")"
pass "migration leaves machines without hibernation alone"
