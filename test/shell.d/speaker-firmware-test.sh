#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
fixtures="$ROOT/test/shell.d/fixtures/speaker-firmware"

cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"$CALL_LOG"
[[ $* == "--user is-active --quiet "* && $# == 4 ]] || exit 99
[[ $4 != "${FAILED_UNIT:-}" ]]
SH

cat >"$test_tmp/bin/pactl" <<'SH'
#!/bin/bash
[[ $* == "--format=json list sinks" ]] || exit 99
cat "$SINKS_FILE"
exit "${PACTL_STATUS:-0}"
SH

cat >"$test_tmp/bin/journalctl" <<'SH'
#!/bin/bash
printf 'journalctl %s\n' "$*" >>"$CALL_LOG"
[[ $* == "--quiet --boot=0 --dmesg --output=cat --no-pager" ]] || exit 99
cat "$KERNEL_LOG"
exit "${JOURNAL_STATUS:-0}"
SH

chmod +x "$test_tmp/bin"/*
export CALL_LOG="$test_tmp/calls" SINKS_FILE="$test_tmp/sinks.json" KERNEL_LOG="$test_tmp/kernel.log"

reset_case() {
  cp "$fixtures/sinks.json" "$SINKS_FILE"
  cp "$fixtures/missing.log" "$KERNEL_LOG"
  : >"$CALL_LOG"
  unset FAILED_UNIT PACTL_STATUS JOURNAL_STATUS
}

assert_result() {
  local expected=$1 message=$2 description=$3 status=0 output
  output=$(PATH="$test_tmp/bin:$PATH" bash "$ROOT/test/audio" 2>&1) || status=$?
  (( status == expected )) || fail "$description" "expected status $expected, got $status: $output"
  grep -Fq -- "$message" <<<"$output" || fail "$description" "$output"
  pass "$description"
}

reset_case
assert_result 1 "FIRMWARE_MISSING" "a registered unmuted sink and running services do not hide missing amplifier firmware"
[[ $(grep -c '^systemctl ' "$CALL_LOG") == 3 ]] || fail "every audio service is checked separately"
pass "every audio service is checked separately"

for side in left right; do
  reset_case
  grep -v 'FIRMWARE_MISSING' "$fixtures/missing.log" >"$KERNEL_LOG"
  printf 'cs35l56 spi-cs35l56-%s: FIRMWARE_MISSING\n' "$side" >>"$KERNEL_LOG"
  assert_result 1 "spi-cs35l56-$side: FIRMWARE_MISSING" "a failure in only the $side amplifier is detected"
done

reset_case
# Synthetic successful initialization: a firmware revision is deliberately not
# pinned, since a future vendor firmware should not make the detector fail.
printf 'cs35l56 spi-cs35l56-left: DSP1: Firmware: 1a00d6 vendor: 0x2 v4.5.9, 42 algorithms\ncs35l56 spi-cs35l56-right: DSP1: Firmware: 1a00d6 vendor: 0x2 v4.5.9, 42 algorithms\n' >"$KERNEL_LOG"
assert_result 0 "Audible playback is not verified" "firmware initialization without known errors passes only the software checks"

printf 'unrelated-device: FIRMWARE_MISSING\n' >>"$KERNEL_LOG"
assert_result 0 "Audible playback is not verified" "unrelated firmware messages are not attributed to the speaker amplifiers"

cat "$fixtures/missing.log" >>"$KERNEL_LOG"
printf 'cs35l56 spi-cs35l56-left: DSP1: Firmware: 1a00d6 vendor: 0x2 v4.5.9, 42 algorithms\n' >>"$KERNEL_LOG"
assert_result 1 "FIRMWARE_MISSING" "a later firmware banner does not erase a current-boot firmware failure"

reset_case
jq '.[0].properties["alsa.components"] = "cfg-amp:1 mic:cs42l43-dmic spk:cs42l43-spk"' "$fixtures/sinks.json" >"$SINKS_FILE"
assert_result 0 "not applicable" "the restored direct speaker route ignores stale amplifier errors from before the reload"
grep -q '^journalctl ' "$CALL_LOG" && fail "the direct route does not require access to kernel logs"
pass "the direct route does not require access to kernel logs"

for unit in pipewire.service pipewire-pulse.service wireplumber.service; do
  reset_case
  export FAILED_UNIT=$unit
  assert_result 1 "$unit is running" "an inactive $unit fails even when the other services run"
done

reset_case
printf '[{"name":"auto_null","properties":{}}]\n' >"$SINKS_FILE"
assert_result 1 "physical built-in speaker output" "Dummy Output cannot satisfy the speaker test"

reset_case
jq '.[0].ports = [{"type":"HDMI"}]' "$fixtures/sinks.json" >"$SINKS_FILE"
assert_result 1 "physical built-in speaker output" "an HDMI output cannot satisfy the built-in speaker test"

reset_case
jq '.[0].properties["device.api"] = "bluez5"' "$fixtures/sinks.json" >"$SINKS_FILE"
assert_result 1 "physical built-in speaker output" "a Bluetooth speaker cannot hide a missing built-in speaker output"

reset_case
jq '.[0].properties["device.bus"] = "usb"' "$fixtures/sinks.json" >"$SINKS_FILE"
assert_result 1 "physical built-in speaker output" "a USB ALSA speaker cannot hide a missing built-in speaker output"

reset_case
printf '[]\n' >"$SINKS_FILE"
assert_result 1 "physical built-in speaker output" "no playback devices fails the speaker test"

reset_case
export PACTL_STATUS=1
assert_result 2 "could not query" "an unavailable audio server is reported as incomplete"

for invalid in 'not json' '{}' 'null'; do
  reset_case
  printf '%s\n' "$invalid" >"$SINKS_FILE"
  assert_result 2 "could not parse" "invalid sink data ($invalid) cannot produce a passing check"
done

reset_case
jq '.[0].properties["alsa.components"] = {}' "$fixtures/sinks.json" >"$SINKS_FILE"
assert_result 2 "could not parse speaker component metadata" "malformed component metadata cannot skip the firmware check"

reset_case
export JOURNAL_STATUS=1
assert_result 2 "could not read" "a failed kernel journal query is not a passing firmware check"

reset_case
: >"$KERNEL_LOG"
assert_result 2 "empty or inaccessible" "an empty journal is not a passing firmware check"

reset_case
printf 'unrelated kernel message\n' >"$KERNEL_LOG"
assert_result 2 "no CS35L56 firmware initialization" "a restricted or incomplete journal cannot prove firmware initialization"
