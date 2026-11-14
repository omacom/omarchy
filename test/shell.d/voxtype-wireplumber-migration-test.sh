#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1793360325.sh"
stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin"

# Voxtype is installed whenever the migration runs.
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-cmd-present"
chmod +x "$stub_bin/omarchy-cmd-present"

run_migration() {
  local test_home=$1

  env -i \
    HOME="$test_home" \
    XDG_CONFIG_HOME="$test_home/.config" \
    PATH="$stub_bin:$ROOT/bin:/usr/bin" \
    TEST_LOG="$calls" \
    bash -euo pipefail "$migration"
}

# A live user manager: systemctl answers, and enable writes the wants link the
# new [Install] section asks for, the way the real systemctl would.
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$TEST_LOG"
[[ $2 == enable ]] || exit 0
wants="${XDG_CONFIG_HOME:?}/systemd/user/wireplumber.service.wants"
mkdir -p "$wants"
ln -sfn /usr/lib/systemd/user/voxtype.service "$wants/voxtype.service"
SH
chmod +x "$stub_bin/systemctl"

enabled_home="$test_tmp/enabled"
mkdir -p "$enabled_home"
: >"$calls"
run_migration "$enabled_home" >/dev/null 2>&1 ||
  fail "migration completes with a live user manager"
grep -Fx 'systemctl --user enable voxtype.service' "$calls" >/dev/null ||
  fail "migration re-enables an enabled Voxtype with a live user manager"
[[ -L $enabled_home/.config/systemd/user/wireplumber.service.wants/voxtype.service ]] ||
  fail "migration leaves WirePlumber wanting an enabled Voxtype"
pass "migration re-enables an enabled Voxtype with a live user manager"

# Enabled without a user manager, where systemctl only ever fails: the enabled
# state shows in the wants links alone, and the migration hand-writes the new
# one pointed wherever the unit the old enable used really lives.
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin/systemctl"

offline_home="$test_tmp/offline"
mkdir -p "$offline_home/.config/systemd/user/default.target.wants"
printf '#!/bin/bash\n' >"$offline_home/.config/systemd/user/voxtype.service"
old_link="$offline_home/.config/systemd/user/default.target.wants/voxtype.service"
ln -s "$offline_home/.config/systemd/user/voxtype.service" "$old_link"
run_migration "$offline_home" >/dev/null 2>&1 ||
  fail "migration completes without a user manager"
wants_link="$offline_home/.config/systemd/user/wireplumber.service.wants/voxtype.service"
[[ -L $wants_link ]] ||
  fail "migration writes the WirePlumber wants link without a user manager"
[[ $(readlink -- "$wants_link") == "$(readlink -f -- "$old_link")" ]] ||
  fail "migration keeps the unit target the old enable used"
pass "migration writes the WirePlumber wants link without a user manager"
pass "migration keeps the unit target the old enable used"

# A disabled unit with no manager and no wants links: the migration writes the
# drop-in but must not re-enable the service behind the user's back.
disabled_home="$test_tmp/disabled"
mkdir -p "$disabled_home"
: >"$calls"
run_migration "$disabled_home" >/dev/null 2>&1 ||
  fail "migration completes for a disabled Voxtype"
[[ -f $disabled_home/.config/systemd/user/voxtype.service.d/omarchy-restart-with-wireplumber.conf ]] ||
  fail "migration writes the WirePlumber drop-in for a disabled Voxtype"
! grep -Fx 'systemctl --user enable voxtype.service' "$calls" >/dev/null ||
  fail "migration leaves a disabled Voxtype disabled"
[[ ! -e $disabled_home/.config/systemd/user/wireplumber.service.wants ]] ||
  fail "migration leaves a disabled Voxtype disabled"
pass "migration leaves a disabled Voxtype disabled"
