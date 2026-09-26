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
cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
printf 'gum %s\n' "$*" >>"${CALL_LOG:?}"
[[ ${TEST_CONFIRM:-no} == "yes" ]]
STUB
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${CALL_LOG:?}"
STUB
cat >"$stub_bin/gsettings" <<'STUB'
#!/bin/bash
printf 'gsettings %s\n' "$*" >>"${CALL_LOG:?}"
if [[ $1 == "get" ]]; then
  echo "${TEST_FONT-'Adwaita Sans 11'}"
fi
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

config=$(config_of jis)
grep -A1 -Fx '[Hotkey/TriggerKeys]' <<<"$config" | grep -Fx '0=Zenkaku_Hankaku' >/dev/null &&
  grep -A1 -Fx '[Hotkey/ActivateKeys]' <<<"$config" | grep -Fx '0=Henkan' >/dev/null &&
  grep -A1 -Fx '[Hotkey/DeactivateKeys]' <<<"$config" | grep -Fx '0=Muhenkan' >/dev/null ||
  fail "a JIS keyboard switches input with Henkan and Muhenkan" "$config"
pass "a JIS keyboard switches input with Henkan and Muhenkan"

if grep -F 'Hotkey/' <<<"$(config_of us)" >/dev/null; then
  fail "other keyboards keep the fcitx5 default hotkeys" "$(config_of us)"
fi
pass "other keyboards keep the fcitx5 default hotkeys"

# Ctrl + Space has to leave the toggle list, not just gain company, or it keeps
# eating the tmux and Herdr prefix.
home="$test_dir/jis-existing/home"
mkdir -p "$home/.config/fcitx5"
printf '[Hotkey/TriggerKeys]\n0=Control+space\n1=Zenkaku_Hankaku\n2=Hangul\n\n[Behavior]\nShareInputState=No\n' >"$home/.config/fcitx5/config"
TEST_LAYOUT=jp run_setup jis-existing
config=$(config_of jis-existing)
if grep -F 'Control+space' <<<"$config" >/dev/null; then
  fail "a JIS keyboard frees Ctrl + Space from the input method toggle" "$config"
fi
grep -Fx 'ShareInputState=No' <<<"$config" >/dev/null ||
  fail "replacing hotkey lists keeps the other sections" "$config"
pass "a JIS keyboard frees Ctrl + Space from the input method toggle"

before=$(config_of jis-existing)
TEST_LAYOUT=jp run_setup jis-existing
[[ $(config_of jis-existing) == "$before" ]] ||
  fail "replacing hotkey lists is idempotent" "$before"$'\n---\n'"$(config_of jis-existing)"
pass "replacing hotkey lists is idempotent"

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

# The system language is offered, never assumed.
TEST_CONFIRM=no run_setup locale-declined
if grep -F 'sudo' "$test_dir/locale-declined.calls" >/dev/null; then
  fail "declining the Japanese system language changes nothing" "$(<"$test_dir/locale-declined.calls")"
fi
pass "declining the Japanese system language changes nothing"

TEST_CONFIRM=yes run_setup locale-accepted
calls=$(grep -F 'sudo' "$test_dir/locale-accepted.calls")
expected="sudo sed -i -E s/^#[[:space:]]*(ja_JP\.UTF-8 UTF-8)/\1/ /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=ja_JP.UTF-8"
[[ $calls == "$expected" ]] ||
  fail "accepting the Japanese system language generates and sets ja_JP.UTF-8" "$calls"
pass "accepting the Japanese system language generates and sets ja_JP.UTF-8"

TEST_CONFIRM=yes TEST_LANG=ja_JP.UTF-8 run_setup locale-present
if grep -E '^(gum|sudo) ' "$test_dir/locale-present.calls" >/dev/null; then
  fail "a Japanese system language is not offered again" "$(<"$test_dir/locale-present.calls")"
fi
pass "a Japanese system language is not offered again"

# The expression the command hands to sed enables the stock Arch entry.
if sed --version >/dev/null 2>&1; then
  printf '#ja_JP.EUC-JP EUC-JP\n#ja_JP.UTF-8 UTF-8\n#ka_GE.UTF-8 UTF-8\n' >"$test_dir/locale.gen"
  sed -i -E 's/^#[[:space:]]*(ja_JP\.UTF-8 UTF-8)/\1/' "$test_dir/locale.gen"
  [[ $(<"$test_dir/locale.gen") == $'#ja_JP.EUC-JP EUC-JP\nja_JP.UTF-8 UTF-8\n#ka_GE.UTF-8 UTF-8' ]] ||
    fail "only the ja_JP.UTF-8 entry is enabled in locale.gen" "$(<"$test_dir/locale.gen")"
  pass "only the ja_JP.UTF-8 entry is enabled in locale.gen"
else
  skip "no GNU sed; skipping the locale.gen expression check"
fi

# The interface font names the Japanese CJK face and keeps its size.
TEST_FONT="'Adwaita Sans 12.5'" run_setup font
grep -Fx 'gsettings set org.gnome.desktop.interface font-name Noto Sans CJK JP 12.5' "$test_dir/font.calls" >/dev/null ||
  fail "the interface font switches to Noto Sans CJK JP at its current size" "$(<"$test_dir/font.calls")"
pass "the interface font switches to Noto Sans CJK JP at its current size"

TEST_FONT="" run_setup font-unset
grep -Fx 'gsettings set org.gnome.desktop.interface font-name Noto Sans CJK JP 11' "$test_dir/font-unset.calls" >/dev/null ||
  fail "an unreadable interface font falls back to size 11" "$(<"$test_dir/font-unset.calls")"
pass "an unreadable interface font falls back to size 11"
