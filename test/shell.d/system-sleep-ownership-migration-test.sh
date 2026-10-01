#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1788662350.sh"
test_tmp=$(mktemp -d -p /tmp)
trap 'rm -rf "$test_tmp"' EXIT

mock_omarchy="$test_tmp/omarchy"
sleep_dir="$test_tmp/system-sleep"
systemd_dir="$test_tmp/systemd"
drop_in="$systemd_dir/supergfxd.service.d/delay-start.conf"
quarantine="$test_tmp/quarantine"
reload_needed_marker="$test_tmp/reload-needed"
migration_copy="$test_tmp/migration.sh"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls"

mkdir -p "$mock_omarchy/default/systemd/system-sleep" \
  "$mock_omarchy/default/systemd/system/supergfxd.service.d" \
  "$sleep_dir" "${drop_in%/*}" "$stub_bin"
cp "$ROOT/default/systemd/system-sleep/keyboard-backlight" \
  "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight"
cp "$ROOT/default/systemd/system-sleep/force-igpu" \
  "$mock_omarchy/default/systemd/system-sleep/force-igpu"
cp "$ROOT/default/systemd/system/supergfxd.service.d/delay-start.conf" \
  "$mock_omarchy/default/systemd/system/supergfxd.service.d/delay-start.conf"

[[ $(grep -Fxc 'system_sleep_dir=/usr/lib/systemd/system-sleep' "$migration") == 1 ]] ||
  fail "migration fixes one literal system-sleep directory"
[[ $(grep -Fxc 'supergfxd_drop_in=/etc/systemd/system/supergfxd.service.d/delay-start.conf' "$migration") == 1 ]] ||
  fail "migration fixes one literal supergfxd drop-in"

sed \
  -e "s|system_sleep_dir=/usr/lib/systemd/system-sleep|system_sleep_dir=$sleep_dir|" \
  -e "s|supergfxd_drop_in=/etc/systemd/system/supergfxd.service.d/delay-start.conf|supergfxd_drop_in=$drop_in|" \
  -e "s|quarantine_root=/var/lib/omarchy/migrations/1788662350-system-sleep|quarantine_root=$quarantine|" \
  -e "s|/var/lib/omarchy/migrations/1788662350-systemd-reload-needed|$reload_needed_marker|" \
  -e "s|/usr/bin/stat|$stub_bin/stat|g" \
  -e "s|/usr/bin/readlink|$stub_bin/readlink|g" \
  "$migration" >"$migration_copy"

cat >"$stub_bin/stat" <<'SH'
#!/bin/bash

path=${!#}
if [[ :${INACCESSIBLE_AS_USER:-}: == *":$path:"* && ${FAKE_SUDO:-0} == 0 ]]; then
  exit 13
fi

actual_file_mode=$(/usr/bin/stat -c '%f' -- "$path") || exit 1
actual_mode=$(/usr/bin/stat -c '%a' -- "$path") || exit 1

if [[ :${FAKE_ROOT_DIRS:-}: == *":$path:"* ]]; then
  uid=0
  gid=0
  mode=$(printf '%o' "$((8#$actual_mode & ~8#022))")
elif [[ :${FAKE_ROOT_FILES:-}: == *":$path:"* ]]; then
  uid=0
  gid=${FAKE_ROOT_GID:-0}
  mode=${FAKE_ROOT_MODE:-$actual_mode}
else
  exec /usr/bin/stat "$@"
fi

file_type=$((16#$actual_file_mode & 16#f000))
file_mode=$(printf '%x' "$((file_type | 8#$mode))")

case "$*" in
  *"%f %u %g %a"*) printf '%s %s %s %s\n' "$file_mode" "$uid" "$gid" "$mode" ;;
  *"%u %g %a"*) printf '%s %s %s\n' "$uid" "$gid" "$mode" ;;
  *"%a"*) printf '%s\n' "$mode" ;;
  *) exec /usr/bin/stat "$@" ;;
esac
SH

cat >"$stub_bin/readlink" <<'SH'
#!/bin/bash

path=${!#}
if [[ :${INACCESSIBLE_AS_USER:-}: == *":$path:"* && ${FAKE_SUDO:-0} == 0 ]]; then
  exit 13
fi

exec /usr/bin/readlink "$@"
SH
chmod +x "$stub_bin/stat" "$stub_bin/readlink"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

set -euo pipefail

printf 'sudo' >>"$CALLS"
printf '\t%s' "$@" >>"$CALLS"
printf '\n' >>"$CALLS"

case "$1" in
  */stat | */readlink)
    FAKE_SUDO=1 exec "$@"
    ;;
  /usr/bin/test)
    shift
    if [[ $1 == "-x" && :${FAKE_ROOT_DIRS:-}: == *":$2:"* ]]; then
      exit 0
    else
      exec /usr/bin/test "$@"
    fi
    ;;
  /usr/bin/mktemp | /usr/bin/mv | /usr/bin/chmod | /usr/bin/cp | /usr/bin/rm)
    exec "$@"
    ;;
  /usr/bin/systemctl)
    if [[ -n ${SYSTEMCTL_FAIL_ONCE_FILE:-} && -e $SYSTEMCTL_FAIL_ONCE_FILE ]]; then
      /usr/bin/rm -f -- "$SYSTEMCTL_FAIL_ONCE_FILE"
      exit 1
    fi
    exit 0
    ;;
  /usr/bin/install)
    shift
    args=()
    while (($#)); do
      case "$1" in
        -o | -g)
          shift 2
          ;;
        *)
          args+=("$1")
          shift
          ;;
      esac
    done
    exec /usr/bin/install "${args[@]}"
    ;;
  *)
    printf 'unexpected sudo command: %s\n' "$*" >&2
    exit 97
    ;;
esac
SH
chmod +x "$stub_bin/sudo"

run_migration() {
  local fake_root_dirs

  : >"$calls"
  fake_root_dirs="/:/tmp:$test_tmp:$sleep_dir:$systemd_dir:${drop_in%/*}"
  [[ -z ${EXTRA_FAKE_ROOT_DIRS:-} ]] || fake_root_dirs+=":$EXTRA_FAKE_ROOT_DIRS"

  CALLS="$calls" \
    FAKE_ROOT_DIRS="$fake_root_dirs" \
    FAKE_ROOT_FILES="${FAKE_ROOT_FILES:-${2:-}}" \
    FAKE_ROOT_MODE="${FAKE_ROOT_MODE:-${3:-}}" \
    FAKE_ROOT_GID="${FAKE_ROOT_GID:-0}" \
    INACCESSIBLE_AS_USER="${INACCESSIBLE_AS_USER:-}" \
    SYSTEMCTL_FAIL_ONCE_FILE="${SYSTEMCTL_FAIL_ONCE_FILE:-}" \
    OMARCHY_PATH="$mock_omarchy" \
    PATH="$stub_bin:$PATH" bash -euo pipefail "$migration_copy" >/dev/null
}

printf 'attacker keyboard\n' >"$sleep_dir/keyboard-backlight"
printf 'attacker gpu\n' >"$sleep_dir/force-igpu"
printf 'attacker drop-in\n' >"$drop_in"
chmod 0777 "$sleep_dir/keyboard-backlight" "$sleep_dir/force-igpu"
chmod 0666 "$drop_in"
exec 9>>"$sleep_dir/keyboard-backlight"

run_migration Integrated
printf 'write through stale attacker descriptor\n' >&9
exec 9>&-

cmp -s "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" "$sleep_dir/keyboard-backlight" ||
  fail "migration replaces the user-owned keyboard hook with trusted content"
cmp -s "$mock_omarchy/default/systemd/system-sleep/force-igpu" "$sleep_dir/force-igpu" ||
  fail "migration replaces the user-owned GPU hook with trusted content"
cmp -s "$mock_omarchy/default/systemd/system/supergfxd.service.d/delay-start.conf" "$drop_in" ||
  fail "migration replaces the user-owned root service drop-in with trusted content"
[[ $(stat -c '%a' "$sleep_dir/keyboard-backlight") == 755 ]] ||
  fail "migration activates the repaired keyboard hook"
[[ $(stat -c '%a' "$sleep_dir/force-igpu") == 755 ]] ||
  fail "migration activates force-igpu only in Integrated mode"
[[ $(stat -c '%a' "$drop_in") == 644 ]] ||
  fail "migration installs the service drop-in as configuration"
grep -Fx $'sudo\t/usr/bin/systemctl\tdaemon-reload' "$calls" >/dev/null ||
  fail "migration reloads systemd after repairing its root service drop-in"
[[ ! -e $reload_needed_marker ]] ||
  fail "migration leaves a reload marker after systemd accepted the repaired drop-in"
[[ $(stat -c '%a' "$quarantine") == 700 ]] ||
  fail "migration keeps preserved unsafe custom content in a root-only directory"
keyboard_backup=$(find "$quarantine" -path '*/keyboard-backlight.*/original' -type f -print -quit)
force_backup=$(find "$quarantine" -path '*/force-igpu.*/original' -type f -print -quit)
drop_in_backup=$(find "$quarantine" -path '*/delay-start.conf.*/original' -type f -print -quit)
grep -Fxq 'attacker keyboard' "$keyboard_backup" ||
  fail "migration preserves unknown keyboard-hook content before replacing it"
grep -Fxq 'attacker gpu' "$force_backup" ||
  fail "migration preserves unknown force-iGPU content before replacing it"
grep -Fxq 'attacker drop-in' "$drop_in_backup" ||
  fail "migration preserves unknown service-drop-in content before replacing it"
pass "migration replaces writable privileged files with trusted root-owned copies"

backup_count=$(find "$quarantine" -mindepth 2 -maxdepth 2 -name original | wc -l)
FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
[[ ! -s $calls ]] ||
  fail "migration changes already-repaired privileged files on a second run" "$(<"$calls")"
[[ $(find "$quarantine" -mindepth 2 -maxdepth 2 -name original | wc -l) == "$backup_count" ]] ||
  fail "migration creates duplicate quarantines on a second run"
pass "migration is idempotent after repairing unsafe privileged files"

printf 'attacker drop-in\n' >"$drop_in"
chmod 0666 "$drop_in"
reload_failure="$test_tmp/fail-systemd-reload-once"
touch "$reload_failure"
set +e
SYSTEMCTL_FAIL_ONCE_FILE="$reload_failure" \
  FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu" \
  run_migration Integrated
reload_status=$?
set -e
(( reload_status != 0 )) ||
  fail "migration reports success after systemd rejects the repaired drop-in"
cmp -s "$mock_omarchy/default/systemd/system/supergfxd.service.d/delay-start.conf" "$drop_in" ||
  fail "migration does not repair the drop-in before the simulated reload failure"
[[ -e $reload_needed_marker && $(stat -c '%a' "$reload_needed_marker") == 644 ]] ||
  fail "migration does not persist the reload requirement before replacing the drop-in"

FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
grep -Fx $'sudo\t/usr/bin/systemctl\tdaemon-reload' "$calls" >/dev/null ||
  fail "migration does not retry a failed reload after the drop-in is already safe"
[[ ! -e $reload_needed_marker ]] ||
  fail "migration does not clear the reload requirement after a successful retry"

FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
[[ ! -s $calls ]] ||
  fail "migration repeats a successfully completed reload repair" "$(<"$calls")"
pass "migration persists and retries systemd reload after failure or interruption"

keyboard_backup_count=$(find "$quarantine" -path '*/keyboard-backlight.*/original' | wc -l)
cp "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" \
  "$sleep_dir/keyboard-backlight"
chmod 0644 "$sleep_dir/keyboard-backlight"
FAKE_ROOT_FILES="$sleep_dir/force-igpu:$drop_in" run_migration Integrated
[[ $(stat -c '%a' "$sleep_dir/keyboard-backlight") == 755 ]] ||
  fail "migration does not safely activate a user-owned canonical hook"
[[ $(find "$quarantine" -path '*/keyboard-backlight.*/original' | wc -l) == "$keyboard_backup_count" ]] ||
  fail "migration quarantines an exact legacy artifact as administrator content"
pass "migration replaces exact vulnerable installer artifacts without inventing backups"

legacy_keyboard="$test_tmp/legacy-keyboard-backlight"
cat >"$legacy_keyboard" <<'SH'
#!/bin/bash

# Turn off keyboard backlight before hibernate to prevent hang on power-off.
# The ASUS keyboard controller can block S4 shutdown if LEDs are active.

if [[ $1 == "pre" && $2 == "hibernate" ]]; then
  device=""
  for candidate in /sys/class/leds/*kbd_backlight*; do
    if [[ -e "$candidate" ]]; then
      device="$(basename "$candidate")"
      break
    fi
  done

  if [[ -n "$device" ]]; then
    brightnessctl -d "$device" set 0 >/dev/null 2>&1
  fi
fi
SH
[[ $(sha256sum "$legacy_keyboard" | cut -d' ' -f1) == f313a81e47401f0d38b8602e5997f52c5286d5e97f74027564ddd515b3d16511 ]] ||
  fail "keyboard-backlight legacy fixture no longer matches the migration fingerprint"
keyboard_backup_count=$(find "$quarantine" -path '*/keyboard-backlight.*/original' | wc -l)
cp "$legacy_keyboard" "$sleep_dir/keyboard-backlight"
chmod 0644 "$sleep_dir/keyboard-backlight"
FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
cmp -s "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" "$sleep_dir/keyboard-backlight" ||
  fail "migration does not upgrade the released keyboard-backlight hook"
[[ $(stat -c '%a' "$sleep_dir/keyboard-backlight") == 755 ]] ||
  fail "migration leaves the released keyboard-backlight hook non-executable"
[[ $(find "$quarantine" -path '*/keyboard-backlight.*/original' | wc -l) == "$keyboard_backup_count" ]] ||
  fail "migration quarantines the released keyboard hook as administrator content"
pass "migration activates the released root-owned keyboard-backlight hook"

cp "$legacy_keyboard" "$sleep_dir/keyboard-backlight"
chmod 0755 "$sleep_dir/keyboard-backlight"
FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
cmp -s "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" "$sleep_dir/keyboard-backlight" ||
  fail "migration mistakes executable released hook bytes for a current artifact"
pass "migration refreshes recognized legacy hook contents at the final mode"

printf 'attacker gpu\n' >"$sleep_dir/force-igpu"
chmod 0777 "$sleep_dir/force-igpu"
run_migration Hybrid
[[ $(stat -c '%a' "$sleep_dir/force-igpu") == 755 ]] ||
  fail "migration does not activate the trusted self-guarding force-igpu hook"
pass "migration repairs force-igpu without depending on a live GPU-mode query"

printf 'administrator customization\n' >"$sleep_dir/keyboard-backlight"
chmod 0755 "$sleep_dir/keyboard-backlight"
run_migration Integrated "$sleep_dir/keyboard-backlight" 755
grep -Fxq 'administrator customization' "$sleep_dir/keyboard-backlight" ||
  fail "migration preserves a secure administrator-owned custom hook"

cp "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" "$sleep_dir/keyboard-backlight"
chmod 0644 "$sleep_dir/keyboard-backlight"
run_migration Integrated "$sleep_dir/keyboard-backlight" 644
[[ $(stat -c '%a' "$sleep_dir/keyboard-backlight") == 755 ]] ||
  fail "migration leaves an exact packaged keyboard hook non-executable"

printf 'administrator customization\n' >"$sleep_dir/keyboard-backlight"
chmod 0644 "$sleep_dir/keyboard-backlight"
run_migration Integrated "$sleep_dir/keyboard-backlight" 644
[[ $(stat -c '%a' "$sleep_dir/keyboard-backlight") == 644 ]] ||
  fail "migration changes the mode of a safe noncanonical administrator hook"
grep -Fxq 'administrator customization' "$sleep_dir/keyboard-backlight" ||
  fail "migration replaces a safe noncanonical administrator hook"
pass "migration activates only exact packaged hooks while preserving safe custom files"

legacy_force_igpu="$test_tmp/legacy-force-igpu"
cat >"$legacy_force_igpu" <<'SH'
#!/bin/bash

# Use the Vfio to Integrated trick to turn off NVIDIA dgpu when in integrated mode
# without needing to restart the computer. This is needed because computers like the Asus G14
# will wake after suspend in Hybrid mode, even if the system was in Integrated mode before
# suspending.

case "$1" in
  pre)
    # Before hibernating, switch to Vfio so the nvidia driver is detached from the dGPU.
    # Without this, hibernate resume fails because the nvidia driver can't freeze a
    # powered-off dGPU (returns -EIO), which aborts the entire resume.
    if [[ $2 == "hibernate" ]]; then
      /usr/bin/supergfxctl -m Vfio
      sleep 1
    fi
    ;;
  post)
    # small delay so the device is fully re-enumerated
    sleep 4

    # force-bind dGPU to vfio (fully detached from nvidia)
    /usr/bin/supergfxctl -m Vfio
    sleep 1

    # then go back to Integrated, which powers it off again
    /usr/bin/supergfxctl -m Integrated
    ;;
esac
SH
[[ $(sha256sum "$legacy_force_igpu" | cut -d' ' -f1) == d604e7c4903829563e45fc52188fc5602c3f1bc66e247f0a2cc0a974ed6e57db ]] ||
  fail "force-igpu legacy fixture no longer matches the migration fingerprint"
cp "$legacy_force_igpu" "$sleep_dir/force-igpu"
chmod 0644 "$sleep_dir/force-igpu"
FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
cmp -s "$mock_omarchy/default/systemd/system-sleep/force-igpu" "$sleep_dir/force-igpu" ||
  fail "migration does not upgrade the exact legacy force-igpu hook"
[[ $(stat -c '%a' "$sleep_dir/force-igpu") == 755 ]] ||
  fail "migration leaves the exact legacy force-igpu hook non-executable"
pass "migration activates the exact legacy force-igpu artifact with its new guard"

printf 'wheel-managed customization\n' >"$sleep_dir/keyboard-backlight"
chmod 0755 "$sleep_dir/keyboard-backlight"
FAKE_ROOT_FILES="$sleep_dir/keyboard-backlight:$sleep_dir/force-igpu:$drop_in" \
  FAKE_ROOT_GID=10 run_migration Integrated
grep -Fxq 'wheel-managed customization' "$sleep_dir/keyboard-backlight" ||
  fail "migration replaces a safe root:wheel administrator hook"
[[ ! -s $calls ]] ||
  fail "migration escalates while preserving safe root:wheel entries"
pass "migration treats non-writable root-owned files as safe regardless of group"

admin_dir="$test_tmp/admin-hooks"
admin_keyboard="$admin_dir/keyboard"
admin_delay="$admin_dir/delay.conf"
mkdir -p "$admin_dir"
printf 'protected keyboard customization\n' >"$admin_keyboard"
printf 'protected delay customization\n' >"$admin_delay"
chmod 0755 "$admin_keyboard"
chmod 0644 "$admin_delay"
rm -f "$sleep_dir/keyboard-backlight" "$drop_in"
ln -s "$admin_keyboard" "$sleep_dir/keyboard-backlight"
ln -s "$admin_delay" "$drop_in"

EXTRA_FAKE_ROOT_DIRS="$admin_dir" \
  FAKE_ROOT_FILES="$admin_keyboard:$admin_delay:$sleep_dir/force-igpu" \
  FAKE_ROOT_GID=10 run_migration Integrated
[[ -L $sleep_dir/keyboard-backlight && $(readlink "$sleep_dir/keyboard-backlight") == "$admin_keyboard" ]] ||
  fail "migration replaces a safe administrator-managed keyboard-hook symlink"
[[ -L $drop_in && $(readlink "$drop_in") == "$admin_delay" ]] ||
  fail "migration replaces a safe administrator-managed service-drop-in symlink"
[[ ! -s $calls ]] ||
  fail "migration escalates while preserving safe administrator symlinks"
pass "migration preserves symlinks whose full target paths are root-controlled"

dangling_target="$admin_dir/future-keyboard"
rm -f "$sleep_dir/keyboard-backlight" "$dangling_target"
ln -s "$dangling_target" "$sleep_dir/keyboard-backlight"

EXTRA_FAKE_ROOT_DIRS="$admin_dir" \
  FAKE_ROOT_FILES="$admin_delay:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
[[ -L $sleep_dir/keyboard-backlight && $(readlink "$sleep_dir/keyboard-backlight") == "$dangling_target" ]] ||
  fail "migration replaces a safe dangling administrator symlink"
[[ ! -s $calls ]] ||
  fail "migration asks for sudo to verify an absent target below a searchable root-controlled directory"
pass "migration handles safe dangling administrator symlinks without sudo"

escaping_user_dir="$test_tmp/escaping-user-hooks"
escaping_user_hook="$escaping_user_dir/keyboard"
escaping_missing_dir="$admin_dir/future"
escaping_target="$escaping_missing_dir/../../escaping-user-hooks/keyboard"
mkdir -p "$escaping_user_dir"
printf 'future unsafe keyboard customization\n' >"$escaping_user_hook"
chmod 0755 "$escaping_user_hook"
rm -f "$sleep_dir/keyboard-backlight"
ln -s "$escaping_target" "$sleep_dir/keyboard-backlight"

EXTRA_FAKE_ROOT_DIRS="$admin_dir" \
  FAKE_ROOT_FILES="$admin_delay:$sleep_dir/force-igpu:$drop_in" \
  run_migration Integrated
[[ ! -L $sleep_dir/keyboard-backlight ]] ||
  fail "migration trusts a dangling symlink whose unresolved suffix escapes to a user-controlled path"
cmp -s "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" \
  "$sleep_dir/keyboard-backlight" ||
  fail "migration does not replace a future user-controlled dangling symlink"
pass "migration resolves the full dangling-symlink suffix before trusting it"

protected_dir="$test_tmp/root-only-hooks"
protected_target="$protected_dir/target"
protected_bridge="$protected_dir/bridge"
mkdir -p "$protected_dir"
printf 'root-only administrator customization\n' >"$protected_target"
ln -s "$protected_target" "$protected_bridge"
chmod 0700 "$protected_dir"
rm -f "$sleep_dir/keyboard-backlight"
ln -s "$protected_bridge" "$sleep_dir/keyboard-backlight"

EXTRA_FAKE_ROOT_DIRS="$admin_dir:$protected_dir" \
  FAKE_ROOT_FILES="$protected_target:$admin_delay:$sleep_dir/force-igpu:$drop_in" \
  INACCESSIBLE_AS_USER="$protected_bridge:$protected_target" \
  run_migration Integrated
[[ -L $sleep_dir/keyboard-backlight && $(readlink "$sleep_dir/keyboard-backlight") == "$protected_bridge" ]] ||
  fail "migration replaces a safe symlink whose target is hidden by a root-only directory"
grep -q $'^sudo\t.*/stat\t-c\t%f %u %g %a\t--\t.*/root-only-hooks/bridge$' "$calls" ||
  fail "migration does not inspect inaccessible symlink metadata with privilege"
grep -q $'^sudo\t.*/readlink\t--\t.*/root-only-hooks/bridge$' "$calls" ||
  fail "migration does not resolve an inaccessible administrator symlink with privilege"
grep -q $'^sudo\t.*/stat\t-c\t%f %u %g %a\t--\t.*/root-only-hooks/target$' "$calls" ||
  fail "migration does not inspect an inaccessible administrator target with privilege"
pass "migration preserves root-controlled symlink chains hidden from the invoking user"

protected_dangling_dir="$test_tmp/root-only-dangling"
protected_dangling_target="$protected_dangling_dir/future-keyboard"
mkdir -p "$protected_dangling_dir"
chmod 0000 "$protected_dangling_dir"
rm -f "$sleep_dir/keyboard-backlight"
ln -s "$protected_dangling_target" "$sleep_dir/keyboard-backlight"

EXTRA_FAKE_ROOT_DIRS="$admin_dir:$protected_dangling_dir" \
  FAKE_ROOT_FILES="$admin_delay:$sleep_dir/force-igpu:$drop_in" \
  INACCESSIBLE_AS_USER="$protected_dangling_target" \
  run_migration Integrated
[[ -L $sleep_dir/keyboard-backlight && $(readlink "$sleep_dir/keyboard-backlight") == "$protected_dangling_target" ]] ||
  fail "migration replaces a safe dangling symlink below a root-only directory"
grep -q $'^sudo\t.*/stat\t-c\t%f %u %g %a\t--\t.*/root-only-dangling/future-keyboard$' "$calls" ||
  fail "migration does not inspect a protected dangling target with privilege"
grep -q $'^sudo\t/usr/bin/test\t-x\t.*/root-only-dangling$' "$calls" ||
  fail "migration does not distinguish a protected missing target from an inaccessible parent"
pass "migration preserves dangling administrator symlinks below root-only directories"

user_dir="$test_tmp/user-hooks"
user_keyboard="$user_dir/keyboard"
mkdir -p "$user_dir"
printf 'unsafe symlink customization\n' >"$user_keyboard"
chmod 0755 "$user_keyboard"
rm -f "$sleep_dir/keyboard-backlight"
ln -s "$user_keyboard" "$sleep_dir/keyboard-backlight"

EXTRA_FAKE_ROOT_DIRS="$admin_dir" \
  FAKE_ROOT_FILES="$admin_delay:$sleep_dir/force-igpu" run_migration Integrated
[[ ! -L $sleep_dir/keyboard-backlight ]] ||
  fail "migration leaves a user-controlled keyboard-hook symlink active"
cmp -s "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" \
  "$sleep_dir/keyboard-backlight" ||
  fail "migration does not replace an unsafe symlink with trusted hook content"
symlink_backup=$(find "$quarantine" -path '*/keyboard-backlight.*/original' -type l -print -quit)
[[ -n $symlink_backup && $(readlink "$symlink_backup") == "$user_keyboard" ]] ||
  fail "migration discards an unsafe custom symlink instead of preserving it"
pass "migration quarantines unsafe symlinks outside the active systemd directory"

bridge="$user_dir/bridge"
ln -s "$admin_keyboard" "$bridge"
rm -f "$sleep_dir/keyboard-backlight"
ln -s "$bridge" "$sleep_dir/keyboard-backlight"

EXTRA_FAKE_ROOT_DIRS="$admin_dir" \
  FAKE_ROOT_FILES="$admin_keyboard:$admin_delay:$sleep_dir/force-igpu" \
  run_migration Integrated
[[ ! -L $sleep_dir/keyboard-backlight ]] ||
  fail "migration trusts a symlink chain routed through a user-controlled directory"
cmp -s "$mock_omarchy/default/systemd/system-sleep/keyboard-backlight" \
  "$sleep_dir/keyboard-backlight" ||
  fail "migration does not repair an indirectly user-controlled symlink"
pass "migration checks every intermediate component in a symlink chain"

hook_copy="$test_tmp/force-igpu-hook"
hook_calls="$test_tmp/force-igpu-calls"
hook_queries="$test_tmp/force-igpu-queries"
hook_config="$test_tmp/supergfxd.conf"
hook_marker="$test_tmp/force-igpu-restore"
hook_pending="$test_tmp/force-igpu-pending"
sed \
  -e "s|/usr/bin/supergfxctl|$stub_bin/hook-supergfxctl|g" \
  -e "s|/usr/bin/install|$stub_bin/hook-install|g" \
  -e "s|/etc/supergfxd.conf|$hook_config|g" \
  -e "s|/run/omarchy-force-igpu-integrated|$hook_marker|g" \
  "$ROOT/default/systemd/system-sleep/force-igpu" >"$hook_copy"
cat >"$stub_bin/hook-supergfxctl" <<'SH'
#!/bin/bash

case "$1" in
  -m)
    printf '%s\n' "$*" >>"$HOOK_CALLS"
    if [[ ${HOOK_BLOCK_MODE:-} == "$2" ]]; then
      trap '' TERM
      /usr/bin/sleep 30
    fi
    current=$(sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HOOK_CONFIG")
    if [[ $current != "$2" ]]; then
      printf '%s %s\n' "$2" "${HOOK_CONFIRM_AFTER:-1}" >"$HOOK_PENDING"
    fi
    ;;
  -g)
    printf '%s\n' "$*" >>"$HOOK_QUERIES"
    if [[ -f $HOOK_PENDING ]]; then
      read -r pending remaining <"$HOOK_PENDING"
      if [[ ${HOOK_FAIL_MODE:-} != "$pending" ]]; then
        remaining=$((remaining - 1))
        if (( remaining <= 0 )); then
          sed -i "s/\"mode\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"mode\": \"$pending\"/" "$HOOK_CONFIG"
          rm -f -- "$HOOK_PENDING"
        else
          printf '%s %s\n' "$pending" "$remaining" >"$HOOK_PENDING"
        fi
      fi
    fi
    sed -n 's/.*"mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$HOOK_CONFIG"
    ;;
esac
SH
cat >"$stub_bin/hook-install" <<'SH'
#!/bin/bash
args=()
while (($#)); do
  case "$1" in
    -o | -g)
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done
exec /usr/bin/install "${args[@]}"
SH
cat >"$stub_bin/sleep" <<'SH'
#!/bin/bash
:
SH
chmod +x "$stub_bin/hook-supergfxctl" "$stub_bin/hook-install" "$stub_bin/sleep"

hook_env=(
  "HOOK_CALLS=$hook_calls"
  "HOOK_QUERIES=$hook_queries"
  "HOOK_CONFIG=$hook_config"
  "HOOK_PENDING=$hook_pending"
  "PATH=$stub_bin:$PATH"
)

printf '{ "mode": "Hybrid" }\n' >"$hook_config"
env "${hook_env[@]}" bash "$hook_copy" pre suspend
env "${hook_env[@]}" bash "$hook_copy" post suspend
[[ ! -e $hook_calls ]] || fail "force-igpu runs while the root-owned config says Hybrid"
[[ ! -e $hook_marker ]] || fail "force-igpu records restore intent while configured for Hybrid mode"

rm -f "$hook_config"
env "${hook_env[@]}" bash "$hook_copy" pre suspend
env "${hook_env[@]}" bash "$hook_copy" post suspend
[[ ! -e $hook_calls ]] || fail "force-igpu runs when its mode config is unavailable"
[[ ! -e $hook_marker ]] || fail "force-igpu records restore intent without a mode config"

printf '{ "mode": "Integrated" }\n' >"$hook_config"
env "${hook_env[@]}" bash "$hook_copy" pre suspend
[[ -f $hook_marker && $(stat -c '%a' "$hook_marker") == 600 ]] ||
  fail "force-igpu does not securely record Integrated restore intent during pre-suspend"
HOOK_CONFIRM_AFTER=2 env "${hook_env[@]}" bash "$hook_copy" post suspend
[[ $(wc -l <"$hook_calls") == 2 ]] ||
  fail "force-igpu does not run both GPU transitions in Integrated mode"
grep -Fqx -- '-m Integrated' "$hook_calls" ||
  fail "force-igpu does not restore Integrated mode after suspend"
[[ ! -e $hook_marker ]] || fail "force-igpu leaves stale restore intent after suspend"
(( $(wc -l <"$hook_queries") >= 4 )) ||
  fail "force-igpu does not wait for asynchronous GPU transitions"
pass "force-igpu confirms asynchronous transitions for Integrated sleep cycles"

: >"$hook_calls"
: >"$hook_queries"
printf '{ "mode": "Integrated" }\n' >"$hook_config"
env "${hook_env[@]}" bash "$hook_copy" pre suspend
set +e
HOOK_CONFIRM_AFTER=2 HOOK_FAIL_MODE=Integrated env "${hook_env[@]}" \
  bash "$hook_copy" post suspend >/dev/null 2>&1
restore_status=$?
set -e
(( restore_status != 0 )) || fail "force-igpu reports success without confirming Integrated mode"
grep -Fq '"mode": "Vfio"' "$hook_config" ||
  fail "force-igpu failure test does not leave the transition in Vfio mode"
[[ -f $hook_marker ]] || fail "force-igpu discards restore intent after an asynchronous transition failure"
HOOK_CONFIRM_AFTER=2 env "${hook_env[@]}" bash "$hook_copy" post suspend
grep -Fq '"mode": "Integrated"' "$hook_config" ||
  fail "force-igpu does not recover the Integrated transition on the next sleep cycle"
[[ ! -e $hook_marker ]] || fail "force-igpu leaves restore intent after a confirmed retry"
pass "force-igpu retains restore intent until Integrated mode is confirmed"

: >"$hook_calls"
: >"$hook_queries"
printf '{ "mode": "Integrated" }\n' >"$hook_config"
env "${hook_env[@]}" bash "$hook_copy" pre suspend
set +e
HOOK_BLOCK_MODE=Vfio env "${hook_env[@]}" \
  bash "$hook_copy" post suspend >/dev/null 2>&1
blocked_request_status=$?
set -e
(( blocked_request_status != 0 )) || fail "force-igpu waits forever for a blocked GPU transition request"
[[ -f $hook_marker ]] || fail "force-igpu discards restore intent after a blocked transition request"
[[ ! -s $hook_queries ]] || fail "force-igpu polls before a blocked transition request returns"
env "${hook_env[@]}" bash "$hook_copy" post suspend
[[ ! -e $hook_marker ]] || fail "force-igpu cannot retry after a blocked transition request"
pass "force-igpu bounds blocked transition requests and retains retry intent"

: >"$hook_calls"
printf '{ "mode": "Integrated" }\n' >"$hook_config"
env "${hook_env[@]}" bash "$hook_copy" pre hibernate
grep -Fq '"mode": "Vfio"' "$hook_config" ||
  fail "force-igpu test double does not model the pre-hibernate Vfio persistence"
[[ -f $hook_marker ]] || fail "force-igpu loses restore intent during the Vfio transition"
env "${hook_env[@]}" bash "$hook_copy" post hibernate
[[ $(wc -l <"$hook_calls") == 3 ]] ||
  fail "force-igpu skips the post-hibernate transitions after Vfio changes the config"
[[ $(tail -1 "$hook_calls") == "-m Integrated" ]] ||
  fail "force-igpu does not finish post-hibernate restoration in Integrated mode"
grep -Fq '"mode": "Integrated"' "$hook_config" ||
  fail "force-igpu leaves supergfxd configured for Vfio after hibernation"
[[ ! -e $hook_marker ]] || fail "force-igpu leaves stale restore intent after hibernation"
pass "force-igpu restores Integrated mode after pre-hibernate persists Vfio"

: >"$hook_calls"
printf '{ "mode": "Integrated" }\n' >"$hook_config"
SYSTEMD_SLEEP_ACTION=suspend env "${hook_env[@]}" bash "$hook_copy" pre suspend-then-hibernate
SYSTEMD_SLEEP_ACTION=suspend env "${hook_env[@]}" bash "$hook_copy" post suspend-then-hibernate
[[ $(wc -l <"$hook_calls") == 2 ]] ||
  fail "force-igpu does not complete the initial suspend phase of suspend-then-hibernate"
SYSTEMD_SLEEP_ACTION=hibernate env "${hook_env[@]}" bash "$hook_copy" pre suspend-then-hibernate
[[ $(wc -l <"$hook_calls") == 3 && $(tail -1 "$hook_calls") == "-m Vfio" ]] ||
  fail "force-igpu skips the Vfio transition before compound hibernation"
grep -Fq '"mode": "Vfio"' "$hook_config" ||
  fail "force-igpu does not detach the dGPU during the hibernate phase"
[[ -f $hook_marker ]] || fail "force-igpu loses restore intent during compound hibernation"
SYSTEMD_SLEEP_ACTION=hibernate env "${hook_env[@]}" bash "$hook_copy" post suspend-then-hibernate
[[ $(wc -l <"$hook_calls") == 5 && $(tail -1 "$hook_calls") == "-m Integrated" ]] ||
  fail "force-igpu does not restore Integrated mode after compound hibernation"
grep -Fq '"mode": "Integrated"' "$hook_config" ||
  fail "force-igpu leaves supergfxd configured for Vfio after compound hibernation"
[[ ! -e $hook_marker ]] || fail "force-igpu leaves stale restore intent after compound hibernation"
pass "force-igpu handles both phases of suspend-then-hibernate"

keyboard_hook_copy="$test_tmp/keyboard-backlight-hook"
keyboard_calls="$test_tmp/keyboard-backlight-calls"
keyboard_led_dir="$test_tmp/leds"
mkdir -p "$keyboard_led_dir/asus::kbd_backlight"
sed "s|/sys/class/leds/\*kbd_backlight\*|$keyboard_led_dir/*kbd_backlight*|" \
  "$ROOT/default/systemd/system-sleep/keyboard-backlight" >"$keyboard_hook_copy"
cat >"$stub_bin/brightnessctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$KEYBOARD_CALLS"
SH
chmod +x "$stub_bin/brightnessctl"

SYSTEMD_SLEEP_ACTION=suspend KEYBOARD_CALLS="$keyboard_calls" PATH="$stub_bin:$PATH" \
  bash "$keyboard_hook_copy" pre suspend-then-hibernate
[[ ! -e $keyboard_calls ]] || fail "keyboard-backlight runs during the suspend phase of compound sleep"
SYSTEMD_SLEEP_ACTION=hibernate KEYBOARD_CALLS="$keyboard_calls" PATH="$stub_bin:$PATH" \
  bash "$keyboard_hook_copy" pre suspend-then-hibernate
grep -Fqx -- '-d asus::kbd_backlight set 0' "$keyboard_calls" ||
  fail "keyboard-backlight skips the hibernate phase of compound sleep"
pass "keyboard-backlight handles the hibernate phase of suspend-then-hibernate"
