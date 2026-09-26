#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'pkg %s\n' "$*" >>"${CALL_LOG:?}"
STUB
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >>"${CALL_LOG:?}"
STUB
cat >"$stub_bin/pkill" <<'STUB'
#!/bin/bash
printf 'pkill %s\n' "$*" >>"${CALL_LOG:?}"
STUB
cat >"$stub_bin/localectl" <<'STUB'
#!/bin/bash
[[ $1 == "status" ]] || exit 2
echo "   System Locale: LANG=${TEST_LANG:-en_US.UTF-8}"
echo "       VC Keymap: ${TEST_KEYMAP:-us}"
echo "      X11 Layout: ${TEST_LAYOUT:-us}"
[[ -z ${TEST_VARIANT:-} ]] || echo "     X11 Variant: $TEST_VARIANT"
STUB
chmod +x "$stub_bin"/*

run_setup() {
  local scenario="$1"
  local home="$test_dir/$scenario/home"

  mkdir -p "$home"
  : >"$test_dir/$scenario.calls"

  HOME="$home" CALL_LOG="$test_dir/$scenario.calls" PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-setup-japanese" >"$test_dir/$scenario.out" 2>&1 ||
    fail "setup japanese runs for $scenario" "$(<"$test_dir/$scenario.out")"
}

profile_of() {
  cat "$test_dir/$1/home/.config/fcitx5/profile"
}

config_of() {
  cat "$test_dir/$1/home/.config/fcitx5/config"
}

# US keyboard: Mozc joins the US keyboard.
TEST_LAYOUT=us run_setup us
grep -Fx 'pkg fcitx5-mozc fcitx5-configtool' "$test_dir/us.calls" >/dev/null ||
  fail "setup installs Mozc and the fcitx5 config tool" "$(<"$test_dir/us.calls")"
pass "setup installs Mozc and the fcitx5 config tool"

grep -Fx 'Name=keyboard-us' <<<"$(profile_of us)" >/dev/null &&
  grep -Fx 'Name=mozc' <<<"$(profile_of us)" >/dev/null &&
  grep -Fx 'Default Layout=us' <<<"$(profile_of us)" >/dev/null ||
  fail "a US keyboard gets Mozc after keyboard-us" "$(profile_of us)"
pass "a US keyboard gets Mozc after keyboard-us"

grep -Fx 'resetStateWhenFocusIn=No' <<<"$(config_of us)" >/dev/null ||
  fail "Japanese input survives focus changes" "$(config_of us)"
pass "Japanese input survives focus changes"

calls=$(<"$test_dir/us.calls")
stop_line=$(grep -n 'systemctl --user stop omarchy-fcitx5.service' <<<"$calls" | cut -d: -f1)
start_line=$(grep -n 'systemctl --user start omarchy-fcitx5.service' <<<"$calls" | cut -d: -f1)
[[ -n $stop_line && -n $start_line ]] && (( stop_line < start_line )) ||
  fail "fcitx5 is down while its profile is rewritten" "$calls"
pass "fcitx5 is down while its profile is rewritten"

# JIS keyboard: the group follows the Japanese layout, variant included.
TEST_LAYOUT=jp TEST_KEYMAP=jp106 run_setup jis
grep -Fx 'Name=keyboard-jp' <<<"$(profile_of jis)" >/dev/null &&
  grep -Fx 'Default Layout=jp' <<<"$(profile_of jis)" >/dev/null ||
  fail "a JIS keyboard gets Mozc after keyboard-jp" "$(profile_of jis)"
pass "a JIS keyboard gets Mozc after keyboard-jp"

TEST_LAYOUT=us TEST_VARIANT=intl run_setup variant
grep -Fx 'Name=keyboard-us-intl' <<<"$(profile_of variant)" >/dev/null ||
  fail "the keyboard input method keeps the layout variant" "$(profile_of variant)"
pass "the keyboard input method keeps the layout variant"

# A profile that already has Mozc is the user's own and is left alone, and
# existing fcitx5 settings survive.
home="$test_dir/existing/home"
mkdir -p "$home/.config/fcitx5"
printf '[Groups/0]\nName=Mine\n\n[Groups/0/Items/0]\nName=mozc\n' >"$home/.config/fcitx5/profile"
printf '[Hotkey]\nEnumerateWithTriggerKeys=True\n\n[Behavior]\nActiveByDefault=False\nresetStateWhenFocusIn=All\n' >"$home/.config/fcitx5/config"
TEST_LAYOUT=us run_setup existing

grep -Fx 'Name=Mine' <<<"$(profile_of existing)" >/dev/null ||
  fail "an existing Mozc profile is kept" "$(profile_of existing)"
pass "an existing Mozc profile is kept"

config=$(config_of existing)
grep -Fx 'EnumerateWithTriggerKeys=True' <<<"$config" >/dev/null &&
  grep -Fx 'ActiveByDefault=False' <<<"$config" >/dev/null &&
  grep -Fx 'resetStateWhenFocusIn=No' <<<"$config" >/dev/null &&
  ! grep -Fx 'resetStateWhenFocusIn=All' <<<"$config" >/dev/null ||
  fail "setup changes only its own fcitx5 settings" "$config"
pass "setup changes only its own fcitx5 settings"

# A profile without Mozc is backed up before it is replaced.
home="$test_dir/backup/home"
mkdir -p "$home/.config/fcitx5"
printf '[Groups/0]\nName=Default\n\n[Groups/0/Items/0]\nName=keyboard-de\n' >"$home/.config/fcitx5/profile"
TEST_LAYOUT=us run_setup backup
compgen -G "$home/.config/fcitx5/profile.bak.*" >/dev/null ||
  fail "a profile without Mozc is backed up before it is replaced"
pass "a profile without Mozc is backed up before it is replaced"

# Running it twice changes nothing.
before=$(profile_of us; config_of us)
TEST_LAYOUT=us run_setup us
[[ $(profile_of us; config_of us) == "$before" ]] ||
  fail "setup is idempotent" "$(config_of us)"
pass "setup is idempotent"
