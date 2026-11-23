#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

template="$ROOT/default/snapper/root"
home_template="$ROOT/default/snapper/home"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

# create-config writes the config and the subvolume's .snapshots, as snapper
# does, except for /home when CREATE_FAILS (a .snapshots left from an earlier config).
cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
[[ $* == *create-config* ]] || exit 0
name=$2
[[ $1 == "--no-dbus" ]] && name=$3
[[ ${CREATE_FAILS:-} == "1" && $name == "home" ]] && exit 1
touch "$TEST_CONFIG_DIR/$name"
[[ ${!#} == "/" ]] || install -d -m 0750 "${!#}/.snapshots"
STUB
chmod +x "$fake_bin/snapper"

cat >"$fake_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_LOG"
STUB
chmod +x "$fake_bin/systemctl"

# /home is a subvolume of its own exactly when HOME_SUBVOLUME says so.
cat >"$fake_bin/btrfs" <<'STUB'
#!/bin/bash
printf 'btrfs %s\n' "$*" >>"$TEST_LOG"
case "$1 $2" in
  "subvolume show") [[ $HOME_SUBVOLUME == "yes" ]] ;;
  "subvolume create") [[ ${SUBVOLUME_FAILS:-} != "1" ]] && install -d -m 0700 "$3" ;;
esac
STUB
chmod +x "$fake_bin/btrfs"

# Configures a machine kept under $1, whose /home is a subvolume when $2 says yes.
configure() {
  local machine="$1" subvolume="$2"

  mkdir -p "$machine/etc/snapper/configs" "$machine/home"
  HOME_SUBVOLUME="$subvolume" \
  TEST_LOG="$machine/calls.log" \
  TEST_CONFIG_DIR="$machine/etc/snapper/configs" \
  PATH="$fake_bin:$PATH" \
  OMARCHY_PATH="$ROOT" \
  OMARCHY_SNAPPER_CONFIG_DIR="$machine/etc/snapper/configs" \
  OMARCHY_SNAPPER_CONF_PATH="$machine/etc/conf.d/snapper" \
  OMARCHY_SNAPPER_HOME="$machine/home" \
    bash -euo pipefail "$ROOT/install/config/snapper.sh" >/dev/null 2>"$machine/stderr"
}

machine="$test_tmp/fresh"
configure "$machine" yes

cmp -s "$template" "$machine/etc/snapper/configs/root" || fail "snapshot configure installs the Omarchy Snapper template"
cmp -s "$home_template" "$machine/etc/snapper/configs/home" || fail "snapshot configure installs the /home Snapper template"
grep -Fx "SNAPPER_CONFIGS=\"root home\"" "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists both configs in /etc/conf.d/snapper"
[[ $(stat -c %a "$machine/home/.snapshots") == "755" ]] || fail "snapshot configure lets people read /home/.snapshots" "$(stat -c %a "$machine/home/.snapshots")"
grep -Fx 'systemctl try-restart snapperd.service' "$machine/calls.log" >/dev/null || fail "snapshot configure restarts a running snapperd onto the new configs"
grep -Fx 'systemctl enable --now snapper-timeline.timer' "$machine/calls.log" >/dev/null || fail "snapshot configure enables timeline snapshots for /home"
grep -Fx 'systemctl enable --now snapper-cleanup.timer limine-snapper-sync.service' "$machine/calls.log" >/dev/null ||
  fail "snapshot configure enables cleanup and Limine snapshot sync"
pass "snapshot configure normalizes Snapper policy and services"

cp "$machine/etc/conf.d/snapper" "$test_tmp/first"
configure "$machine" yes
cmp -s "$test_tmp/first" "$machine/etc/conf.d/snapper" && cmp -s "$home_template" "$machine/etc/snapper/configs/home" ||
  fail "snapshot configure gives the same result run again"
pass "snapshot configure is idempotent"

# Root keeps only its pre-update snapshots; /home is snapshotted hourly, and
# snapper thins by free space only where a limit is a range.
grep -Fx 'TIMELINE_CREATE="no"' "$template" >/dev/null || fail "root config creates no timeline snapshots"
grep -Fx 'TIMELINE_CREATE="yes"' "$home_template" >/dev/null || fail "/home config creates timeline snapshots"
grep -Fx 'NUMBER_CLEANUP="no"' "$home_template" >/dev/null || fail "/home config takes no pre-update snapshots to clean up"
(( $(grep -cE '^TIMELINE_LIMIT_(HOURLY|DAILY)="[0-9]+-[0-9]+"$' "$home_template") == 2 )) ||
  fail "/home config gives hourly and daily limits as ranges, so free space can thin them"
grep -Eq '^FREE_LIMIT=' "$home_template" || fail "/home config sets a free space limit"
pass "/home snapshots are hourly and thinned by free space, without quotas"

# A factory reset brings back an empty @home under a root that has the config.
rm -rf "$machine/home/.snapshots"
configure "$machine" yes
grep -Fx "btrfs subvolume create $machine/home/.snapshots" "$machine/calls.log" >/dev/null ||
  fail "snapshot configure recreates a missing /home/.snapshots as a subvolume"
[[ $(stat -c %a "$machine/home/.snapshots") == "755" ]] || fail "a recreated /home/.snapshots is readable"
pass "snapshot configure repairs a /home config whose .snapshots is gone"

machine="$test_tmp/flat"
configure "$machine" no
[[ ! -e $machine/etc/snapper/configs/home ]] || fail "snapshot configure leaves /home alone when it is not a subvolume"
grep -Fx 'SNAPPER_CONFIGS="root"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists only root when /home is part of /"
! grep -q 'snapper-timeline.timer' "$machine/calls.log" || fail "snapshot configure leaves the timeline timer alone without /home"
pass "snapshot configure snapshots /home only when it is a subvolume of its own"

# Someone who already snapshots /home their own way keeps it, and other configs
# they run stay listed; a stray copy of a config that isn't listed is ignored.
machine="$test_tmp/theirs"
mkdir -p "$machine/etc/snapper/configs" "$machine/etc/conf.d"
printf 'SUBVOLUME="%s"\nTIMELINE_CREATE="yes"\n' "$machine/home" >"$machine/etc/snapper/configs/data"
printf 'SUBVOLUME="/srv"\n' >"$machine/etc/snapper/configs/srv"
cp "$machine/etc/snapper/configs/data" "$machine/etc/snapper/configs/data.bak"
printf 'SNAPPER_CONFIGS="root data srv"\n' >"$machine/etc/conf.d/snapper"
cp "$machine/etc/snapper/configs/data" "$test_tmp/data"
configure "$machine" yes
[[ ! -e $machine/etc/snapper/configs/home ]] || fail "snapshot configure adds no second config for /home"
cmp -s "$test_tmp/data" "$machine/etc/snapper/configs/data" || fail "snapshot configure leaves someone's own /home config as it was"
grep -Fx 'SNAPPER_CONFIGS="root data srv"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure keeps the configs someone runs listed" "$(cat "$machine/etc/conf.d/snapper")"
! grep -q 'snapper-timeline.timer' "$machine/calls.log" || fail "snapshot configure leaves their timeline timer as they set it"
pass "snapshot configure leaves an existing /home config of someone's own alone"

# Theirs may be called home too, as the Arch wiki has it: it isn't Omarchy's.
machine="$test_tmp/theirs-home"
mkdir -p "$machine/etc/snapper/configs" "$machine/etc/conf.d"
printf 'SUBVOLUME="%s"\nTIMELINE_LIMIT_HOURLY="10"\n' "$machine/home" >"$machine/etc/snapper/configs/home"
cp "$machine/etc/snapper/configs/home" "$test_tmp/their-home"
# Written without quotes, as snapper's own config allows.
printf 'SNAPPER_CONFIGS=root\\ home\n' >"$machine/etc/conf.d/snapper"
configure "$machine" yes
cmp -s "$test_tmp/their-home" "$machine/etc/snapper/configs/home" || fail "snapshot configure leaves someone's own config called home as it was"
grep -Fx 'SNAPPER_CONFIGS="root home"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure keeps someone's own config called home listed" "$(cat "$machine/etc/conf.d/snapper")"
! grep -q 'snapper-timeline.timer' "$machine/calls.log" || fail "snapshot configure leaves their timeline timer as they set it"
pass "snapshot configure tells someone's own config called home from Omarchy's"

# A .snapshots left from an earlier config makes create-config refuse; that
# must not stop the setup, or every later migration waits behind it.
machine="$test_tmp/leftover"
CREATE_FAILS=1 configure "$machine" yes || true
[[ -e $machine/etc/conf.d/snapper ]] || fail "snapshot configure finishes when /home's config can't be created" "$(cat "$machine/stderr")"
grep -Fx 'SNAPPER_CONFIGS="root"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists only root when /home's config can't be created"
grep -qF 'Could not set up Snapper for /home' "$machine/stderr" || fail "snapshot configure says /home isn't snapshotted"
pass "snapshot configure carries on, and says so, when /home's config can't be created"

# A .snapshots that can't be made skips /home with a note, like a config that
# can't be.
machine="$test_tmp/no-subvolume"
mkdir -p "$machine/etc/snapper/configs" "$machine/home"
cp "$ROOT/default/snapper/home" "$machine/etc/snapper/configs/home"
SUBVOLUME_FAILS=1 configure "$machine" yes || true
grep -Fx 'SNAPPER_CONFIGS="root"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists only root when /home/.snapshots can't be made" "$(cat "$machine/stderr")"
grep -qF 'Could not set up Snapper for /home' "$machine/stderr" || fail "snapshot configure says /home isn't snapshotted when .snapshots can't be made"
! grep -q 'snapper-timeline.timer' "$machine/calls.log" || fail "snapshot configure leaves the timeline timer off without a /home it set up"
pass "snapshot configure carries on, and says so, when /home/.snapshots can't be made"

# Two configs of someone's own for /home both stay listed.
machine="$test_tmp/two-of-theirs"
mkdir -p "$machine/etc/snapper/configs" "$machine/etc/conf.d"
printf 'SUBVOLUME="%s"\n' "$machine/home" >"$machine/etc/snapper/configs/home"
printf 'SUBVOLUME="%s"\n' "$machine/home" >"$machine/etc/snapper/configs/data"
printf 'SNAPPER_CONFIGS="root home data"\n' >"$machine/etc/conf.d/snapper"
configure "$machine" yes
grep -Fx 'SNAPPER_CONFIGS="root home data"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure keeps both of someone's own /home configs listed" "$(cat "$machine/etc/conf.d/snapper")"
pass "snapshot configure keeps every config of someone's own listed"

# Theirs called home, but for something other than /home, keeps its name and
# its settings; /home goes without rather than being listed twice.
machine="$test_tmp/home-elsewhere"
mkdir -p "$machine/etc/snapper/configs" "$machine/etc/conf.d"
printf 'SUBVOLUME="/home/david"\n' >"$machine/etc/snapper/configs/home"
cp "$machine/etc/snapper/configs/home" "$test_tmp/home-elsewhere.conf"
printf 'SNAPPER_CONFIGS="root home"\n' >"$machine/etc/conf.d/snapper"
configure "$machine" yes
cmp -s "$test_tmp/home-elsewhere.conf" "$machine/etc/snapper/configs/home" || fail "snapshot configure leaves a config of theirs called home for something else as it was"
grep -Fx 'SNAPPER_CONFIGS="root home"' "$machine/etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists a config called home once" "$(cat "$machine/etc/conf.d/snapper")"
pass "snapshot configure leaves a config of someone's own called home, whatever it snapshots"

