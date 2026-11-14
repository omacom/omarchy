#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1792244536.sh"
shipped="$ROOT/config/wireplumber/wireplumber.conf.d/bluetooth-a2dp-autoconnect.conf"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
STUB
chmod +x "$test_tmp/bin/systemctl"

# The rule every release through 4.0.4 shipped.
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

# What the a2dp_sink-only interim rule (#12642) replaces that copy with.
sink_only_rule='## Auto-connect the A2DP playback profile on Bluetooth devices.
## This helps speakers and receivers expose their audio profiles without
## requiring manual PipeWire/WirePlumber recovery. Not a2dp_source: that
## connects to phones as an audio source, and a refused transport there has
## been seen to stop WirePlumber linking any stream (#12642).

monitor.bluez.rules = [
  {
    matches = [
      {
        device.name = "~bluez_card.*"
      }
    ]
    actions = {
      update-props = {
        bluez5.auto-connect = [ a2dp_sink ]
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

restarts() {
  [[ -e $1 ]] && wc -l <"$1" || printf '0\n'
}

seed() {
  local home="$1" body="$2"
  mkdir -p "$(dirname "$(conf_in "$home")")"
  printf '%s\n' "$body" >"$(conf_in "$home")"
}

# The shipped rule itself.
grep -Fxq '        device.form-factor = "!~^(headphone|headset|hands-free|phone)$"' "$shipped" ||
  fail "the shipped rule leaves headphones, headsets, hands-free devices and phones alone"
grep -Fxq '        bluez5.auto-connect = [ a2dp_sink ]' "$shipped" ||
  fail "the shipped rule auto-connects only a2dp_sink"
grep -v '^#' "$shipped" | grep -q a2dp_source &&
  fail "the shipped rule never auto-connects a2dp_source" || true
pass "the shipped rule keeps speaker auto-connect and leaves headsets and phones alone"

stock="$test_tmp/stock"
seed "$stock" "$old_rule"
run_migration "$stock"
cmp -s "$shipped" "$(conf_in "$stock")" || fail "the migration replaces an untouched copy of the old rule"
[[ $(restarts "$stock/systemctl.log") == 1 ]] || fail "the migration restarts WirePlumber once after replacing the rule"
run_migration "$stock"
cmp -s "$shipped" "$(conf_in "$stock")" || fail "the migration leaves the replaced rule alone on a second run"
[[ $(restarts "$stock/systemctl.log") == 1 ]] || fail "the migration does not restart WirePlumber again"
pass "the migration replaces an untouched copy of the old rule and restarts WirePlumber once"

sink_only="$test_tmp/sink-only"
seed "$sink_only" "$sink_only_rule"
run_migration "$sink_only"
cmp -s "$shipped" "$(conf_in "$sink_only")" || fail "the migration replaces a copy left by the a2dp_sink-only rule"
pass "the migration replaces a copy left by the a2dp_sink-only rule"

edited="$test_tmp/edited"
seed "$edited" "${old_rule/a2dp_sink a2dp_source/a2dp_sink a2dp_source hfp_hf}"
cp "$(conf_in "$edited")" "$test_tmp/edited.expected"
run_migration "$edited"
cmp -s "$test_tmp/edited.expected" "$(conf_in "$edited")" || fail "the migration leaves an edited rule alone"
[[ $(restarts "$edited/systemctl.log") == 0 ]] || fail "the migration does not restart WirePlumber for an edited rule"
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
