#!/bin/bash
#
# Hibernation setup makes a laptop hibernate on critical battery, and removing
# hibernation takes that back. /etc paths are redirected into a scratch root;
# sudo runs the file operations there and records service restarts.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

[[ -f /sys/power/image_size ]] || { skip "no hibernation support to exercise"; exit 0; }

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/etc/mkinitcpio.conf.d"
export CALL_LOG="$scratch/calls"
export OMARCHY_PATH="$ROOT"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat > "$scratch/bin/sudo" <<'STUB'
#!/bin/bash
case "$1" in
  systemctl) echo "systemctl ${*:2}" >> "$CALL_LOG" ;;
  /usr/bin/install)
    args=()
    while (($# > 1)); do
      shift
      case "$1" in -o | -g) shift ;; *) args+=("$1") ;; esac
    done
    exec /usr/bin/install "${args[@]}"
    ;;
  *) exec "$@" ;;
esac
STUB
printf '#!/bin/bash\n[[ ${BATTERY:-1} == 1 ]]\n' > "$scratch/bin/omarchy-battery-present"
printf '#!/bin/bash\nexit 0\n' > "$scratch/bin/gum"
printf '#!/bin/bash\necho "btrfs $*" >> "$CALL_LOG"\nexit 1\n' > "$scratch/bin/btrfs"
chmod +x "$scratch/bin/"*

redirect() {
  sed -e "s|/etc/|$scratch/etc/|g" -e "s|\"/swap|\"$scratch/swap|g" "$ROOT/bin/$1" > "$scratch/$1"
}
redirect omarchy-hibernation-setup
redirect omarchy-hibernation-remove

drop_in="$scratch/etc/UPower/UPower.conf.d/70-omarchy-critical-hibernate.conf"
echo "HOOKS+=(resume)" > "$scratch/etc/mkinitcpio.conf.d/omarchy_resume.conf"

: > "$CALL_LOG"
bash "$scratch/omarchy-hibernation-setup" --no-rebuild > "$scratch/out" 2>&1 ||
  fail "setup on an already-hibernating laptop succeeds" "$(<"$scratch/out")"
cmp -s "$ROOT/default/upower/omarchy-critical-hibernate.conf" "$drop_in" ||
  fail "a laptop set up earlier gets the critical battery action" "$(<"$scratch/out")"
grep -qx 'systemctl try-restart upower.service' "$CALL_LOG" || fail "UPower is restarted to read the new action"
pass "rerunning setup on a laptop installs the critical battery hibernate action"

grep -qx 'CriticalPowerAction=Hibernate' "$drop_in" || fail "the critical action is Hibernate"
pass "the critical battery action is Hibernate, not suspend-then-hibernate"

: > "$CALL_LOG"
bash "$scratch/omarchy-hibernation-setup" --no-rebuild > "$scratch/out" 2>&1
[[ ! -s $CALL_LOG ]] || fail "an unchanged drop-in does not restart UPower" "$(<"$CALL_LOG")"
pass "an installed action is left alone"

rm -rf "$scratch/etc/UPower"
BATTERY=0 bash "$scratch/omarchy-hibernation-setup" --no-rebuild > "$scratch/out" 2>&1
[[ ! -e $drop_in ]] || fail "a desktop gets no battery action"
pass "a machine without a battery gets no battery action"

bash "$scratch/omarchy-hibernation-setup" --no-rebuild > /dev/null 2>&1
printf '#!/bin/bash\nexit 0\n' > "$scratch/bin/limine-mkinitcpio"
printf '#!/bin/bash\nexit 1\n' > "$scratch/bin/swapon"
chmod +x "$scratch/bin/limine-mkinitcpio" "$scratch/bin/swapon"
: > "$CALL_LOG"
bash "$scratch/omarchy-hibernation-remove" > "$scratch/out" 2>&1 || fail "remove succeeds" "$(<"$scratch/out")"
[[ ! -e $drop_in ]] || fail "removing hibernation removes the critical battery action"
grep -qx 'systemctl try-restart upower.service' "$CALL_LOG" || fail "UPower is restarted after the action is removed"
pass "removing hibernation removes the critical battery action"
