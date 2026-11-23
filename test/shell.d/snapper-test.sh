#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

template="$ROOT/default/snapper/root"
home_template="$ROOT/default/snapper/home"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/snapper" <<'STUB'
#!/bin/bash
printf 'snapper %s\n' "$*" >>"$TEST_LOG"
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
[[ $HOME_SUBVOLUME == "yes" ]]
STUB
chmod +x "$fake_bin/btrfs"

configure() {
  local etc="$1" home="$2" subvolume="$3"

  HOME_SUBVOLUME="$subvolume" \
  TEST_LOG="$etc/calls.log" \
  PATH="$fake_bin:$PATH" \
  OMARCHY_SNAPPER_CONFIGURE_TEST=1 \
  OMARCHY_PATH="$ROOT" \
  OMARCHY_SNAPPER_CONFIG_PATH="$etc/snapper/configs/root" \
  OMARCHY_SNAPPER_HOME_CONFIG_PATH="$etc/snapper/configs/home" \
  OMARCHY_SNAPPER_CONF_PATH="$etc/conf.d/snapper" \
  OMARCHY_SNAPPER_HOME="$home" \
    bash -euo pipefail "$ROOT/install/config/snapper.sh" >/dev/null
}

etc="$test_tmp/etc"
home="$test_tmp/home"
mkdir -p "$etc" "$home/.snapshots"
chmod 0750 "$home/.snapshots"
configure "$etc" "$home" yes

cmp -s "$template" "$etc/snapper/configs/root" || fail "snapshot configure installs the Omarchy Snapper template"
cmp -s "$home_template" "$etc/snapper/configs/home" || fail "snapshot configure installs the /home Snapper template"
grep -Fx 'SNAPPER_CONFIGS="root home"' "$etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists both configs in /etc/conf.d/snapper"
[[ $(stat -c %a "$home/.snapshots") == "755" ]] || fail "snapshot configure lets people read /home/.snapshots" "$(stat -c %a "$home/.snapshots")"
grep -Fx 'systemctl try-restart snapperd.service' "$etc/calls.log" >/dev/null || fail "snapshot configure restarts a running snapperd onto the new configs"
grep -Fx 'systemctl enable --now snapper-timeline.timer snapper-cleanup.timer limine-snapper-sync.service' "$etc/calls.log" >/dev/null ||
  fail "snapshot configure enables timeline snapshots, cleanup and Limine snapshot sync"
pass "snapshot configure normalizes Snapper policy and services"

# Root keeps only its pre-update snapshots; /home is snapshotted hourly, and
# snapper thins by free space only where a limit is a range.
grep -Fx 'TIMELINE_CREATE="no"' "$template" >/dev/null || fail "root config creates no timeline snapshots"
grep -Fx 'TIMELINE_CREATE="yes"' "$home_template" >/dev/null || fail "/home config creates timeline snapshots"
grep -Fx 'NUMBER_CLEANUP="no"' "$home_template" >/dev/null || fail "/home config takes no pre-update snapshots to clean up"
(( $(grep -cE '^TIMELINE_LIMIT_(HOURLY|DAILY)="[0-9]+-[0-9]+"$' "$home_template") == 2 )) ||
  fail "/home config gives hourly and daily limits as ranges, so free space can thin them"
grep -Eq '^FREE_LIMIT=' "$home_template" || fail "/home config sets a free space limit"
pass "/home snapshots are hourly and thinned by free space, without quotas"

etc="$test_tmp/etc-flat"
home="$test_tmp/home-flat"
mkdir -p "$etc" "$home"
configure "$etc" "$home" no

[[ ! -e $etc/snapper/configs/home ]] || fail "snapshot configure leaves /home alone when it is not a subvolume"
grep -Fx 'SNAPPER_CONFIGS="root"' "$etc/conf.d/snapper" >/dev/null || fail "snapshot configure lists only root when /home is part of /"
pass "snapshot configure snapshots /home only when it is a subvolume of its own"
