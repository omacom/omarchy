#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791798291.sh"
shipped="$ROOT/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
STUB
chmod +x "$test_tmp/bin/systemctl"

# The rule as every release before this one shipped it.
old_rule='## Auto-connect A2DP playback/capture profiles on Bluetooth devices.
## This helps speakers and receivers expose their audio profiles without
## requiring manual PipeWire/WirePlumber recovery.

monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
      }
    ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink a2dp_source ]
      }
    }
  }
]'

run_migration() {
  local home="$1"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$PATH" SYSTEMCTL_LOG="$home/systemctl.log" \
    bash -euo pipefail "$migration" >/dev/null
}

conf_in() {
  printf '%s/.config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf\n' "$1"
}

grep -Fxq '        bluez5.auto-connect = [ a2dp_sink ]' "$shipped" ||
  fail "the shipped rule auto-connects only a2dp_sink"
[[ $(grep -v '^##' "$shipped") != *a2dp_source* ]] || fail "the shipped rule never auto-connects a2dp_source"
pass "the shipped rule auto-connects only a2dp_sink"

stock="$test_tmp/stock"
mkdir -p "$(dirname "$(conf_in "$stock")")"
printf '%s\n' "$old_rule" >"$(conf_in "$stock")"
run_migration "$stock"
run_migration "$stock"
cmp -s "$shipped" "$(conf_in "$stock")" || fail "the migration replaces an untouched copy of the old rule"
[[ $(grep -Fxc -- '--user try-restart wireplumber.service' "$stock/systemctl.log") == 1 ]] ||
  fail "the migration restarts WirePlumber once, and not again on a second run"
pass "the migration replaces an untouched copy of the old rule and can run twice"

edited="$test_tmp/edited"
mkdir -p "$(dirname "$(conf_in "$edited")")"
printf '%s\n' "${old_rule/a2dp_sink a2dp_source/a2dp_sink a2dp_source hfp_hf}" >"$(conf_in "$edited")"
cp "$(conf_in "$edited")" "$test_tmp/edited.expected"
run_migration "$edited"
cmp -s "$test_tmp/edited.expected" "$(conf_in "$edited")" || fail "the migration leaves an edited rule alone"
[[ ! -e $edited/systemctl.log ]] || fail "the migration does not restart WirePlumber for an edited rule"
pass "the migration leaves an edited rule alone"

linked="$test_tmp/linked"
mkdir -p "$(dirname "$(conf_in "$linked")")"
printf '%s\n' "$old_rule" >"$test_tmp/dotfiles.conf"
ln -s "$test_tmp/dotfiles.conf" "$(conf_in "$linked")"
run_migration "$linked"
[[ -L $(conf_in "$linked") ]] || fail "the migration keeps a symlinked rule a symlink"
[[ $(cat "$test_tmp/dotfiles.conf") == "$old_rule" ]] || fail "the migration does not write through a symlinked rule"
pass "the migration leaves a symlinked rule alone"

missing="$test_tmp/missing"
mkdir -p "$missing"
run_migration "$missing"
[[ ! -e $(conf_in "$missing") ]] || fail "the migration does not create a rule the user removed"
pass "the migration leaves a removed rule removed"
