#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)
test_omarchy_path=$(mktemp -d)
log_file=$(mktemp)
confirm_queue=$(mktemp)

cleanup() {
  rm -rf "$test_home" "$test_bin" "$test_omarchy_path"
  rm -f "$log_file" "$confirm_queue"
}
trap cleanup EXIT

mkdir -p "$test_omarchy_path/default/voxtype"
cp "$ROOT/default/voxtype/config.toml" "$test_omarchy_path/default/voxtype/config.toml"

cat >"$test_bin/gum" <<'SH'
#!/bin/bash
if [[ $1 == "confirm" ]]; then
  answer=$(head -n1 "$CONFIRM_QUEUE")
  sed -i '1d' "$CONFIRM_QUEUE"
  [[ $answer == "yes" ]]
  exit $?
fi
exit 0
SH

for cmd in omarchy-pkg-add omarchy-restart-shell omarchy-notification-send voxtype hyprctl; do
  cat >"$test_bin/$cmd" <<EOF
#!/bin/bash
echo "$cmd:\$*" >>"\$TEST_LOG"
EOF
done

cat >"$test_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
exit 1
SH

cat >"$test_bin/omarchy-hw-apple-silicon" <<'SH'
#!/bin/bash
exit "${APPLE_SILICON:-1}"
SH

cat >"$test_bin/pactl" <<'SH'
#!/bin/bash
[[ $* == "list short sources" ]] || exit 1
printf '%s\n' "$PACTL_SOURCES"
exit "${PACTL_STATUS:-0}"
SH

chmod +x "$test_bin"/*

for scenario in usb similar failed; do
  case $scenario in
    usb) sources=$'1\talsa_input.usb-microphone\tPipeWire\ts16le 2ch 48000Hz\tRUNNING'; status=0 ;;
    similar) sources=$'1\tomarchy_asahi_mic.monitor.extra\tPipeWire\ts16le 2ch 48000Hz\tRUNNING'; status=0 ;;
    failed) sources=$'1\tomarchy_asahi_mic.monitor\tPipeWire\ts16le 2ch 48000Hz\tRUNNING'; status=1 ;;
  esac

  printf 'pcm.custom { type null }\n# preserve without final newline' >"$test_home/.asoundrc"
  cp "$test_home/.asoundrc" "$test_home/asoundrc.expected"
  : >"$log_file"
  printf 'yes\n' >"$confirm_queue"
  APPLE_SILICON=0 PACTL_SOURCES="$sources" PACTL_STATUS="$status" \
    HOME="$test_home" OMARCHY_PATH="$test_omarchy_path" \
    PATH="$test_bin:$PATH" TEST_LOG="$log_file" CONFIRM_QUEUE="$confirm_queue" \
    bash "$ROOT/bin/omarchy-voxtype-install" >/dev/null

  grep -q 'device = "default"' "$test_home/.config/voxtype/config.toml" ||
    fail "Apple Silicon install keeps default capture for $scenario source query"
  cmp -s "$test_home/asoundrc.expected" "$test_home/.asoundrc" ||
    fail "Apple Silicon install preserves .asoundrc for $scenario source query"
  grep -qx 'voxtype:setup systemd' "$log_file" ||
    fail "Apple Silicon install completes for $scenario source query"
  pass "Apple Silicon Voxtype install preserves default capture and .asoundrc for $scenario source query"
done

rm -rf "$test_home/.config" "$test_home/.asoundrc"
export PACTL_SOURCES=$'1\tomarchy_asahi_mic.monitor\tPipeWire\ts16le 2ch 48000Hz\tRUNNING'

printf 'yes\n' >"$confirm_queue"
APPLE_SILICON=0 HOME="$test_home" OMARCHY_PATH="$test_omarchy_path" \
  PATH="$test_bin:$PATH" TEST_LOG="$log_file" CONFIRM_QUEUE="$confirm_queue" \
  bash "$ROOT/bin/omarchy-voxtype-install" >/dev/null

grep -q 'device = "asahimic"' "$test_home/.config/voxtype/config.toml" ||
  fail "Apple Silicon install pins Voxtype to asahimic"
grep -q 'pcm.asahimic' "$test_home/.asoundrc" ||
  fail "Apple Silicon install writes the asahimic ALSA PCM"
grep -q 'omarchy_asahi_mic.monitor' "$test_home/.asoundrc" ||
  fail "asahimic PCM targets omarchy_asahi_mic.monitor"
pass "Apple Silicon Voxtype install pins capture to the Asahi mic map"

rm -rf "$test_home/.config" "$test_home/.asoundrc"
: >"$log_file"
printf 'yes\n' >"$confirm_queue"
APPLE_SILICON=1 HOME="$test_home" OMARCHY_PATH="$test_omarchy_path" \
  PATH="$test_bin:$PATH" TEST_LOG="$log_file" CONFIRM_QUEUE="$confirm_queue" \
  bash "$ROOT/bin/omarchy-voxtype-install" >/dev/null

grep -q 'device = "default"' "$test_home/.config/voxtype/config.toml" ||
  fail "non-Apple install keeps device = default"
if [[ -f $test_home/.asoundrc ]] && grep -q 'pcm.asahimic' "$test_home/.asoundrc"; then
  fail "non-Apple install must not write asahimic"
fi
pass "non-Apple Voxtype install leaves audio.device on default"

mkdir -p "$test_home/.local/state/wireplumber" "$test_home/.config/voxtype"
printf '%s\n' \
  'Input/Audio:application.name:PipeWire ALSA [voxtype-cpu]={"target":"alsa_input.platform-sound.HiFi__Headset__source"}' \
  'OtherApp=keep' \
  >"$test_home/.local/state/wireplumber/stream-properties"
printf '%s\n' \
  '# BEGIN omarchy-voxtype-asahi-mic' \
  'pcm.asahimic { }' \
  '# END omarchy-voxtype-asahi-mic' \
  'keep' \
  >"$test_home/.asoundrc"

cat >"$test_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == voxtype ]]
SH
cat >"$test_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
echo "omarchy-pkg-drop:$*" >>"$TEST_LOG"
SH
cat >"$test_bin/systemctl" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$test_bin/voxtype" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_bin/omarchy-cmd-present" "$test_bin/omarchy-pkg-drop" "$test_bin/systemctl" "$test_bin/voxtype"

: >"$log_file"
HOME="$test_home" PATH="$test_bin:$PATH" TEST_LOG="$log_file" \
  bash "$ROOT/bin/omarchy-voxtype-remove" >/dev/null

grep -qi voxtype "$test_home/.local/state/wireplumber/stream-properties" &&
  fail "remove clears Voxtype WirePlumber stream pins"
grep -q 'OtherApp=keep' "$test_home/.local/state/wireplumber/stream-properties" ||
  fail "remove preserves unrelated WirePlumber stream pins"
grep -q 'pcm.asahimic' "$test_home/.asoundrc" &&
  fail "remove clears the asahimic asoundrc block"
grep -qx 'omarchy-pkg-drop:voxtype-bin voxtype' "$log_file" ||
  fail "remove drops both voxtype-bin and voxtype" "log: $(< "$log_file")"
pass "Voxtype remove clears Asahi mic pins and both packages"
