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
# Note whether Mozc is in the profile and Henkan is in the config when fcitx5
# stops and starts, so the test can tell both were written while fcitx5 was
# down. fcitx5 only reads them when it starts.
cat >"$stub_bin/systemctl" <<'STUB'
#!/bin/bash
mozc=no henkan=no
grep -qx 'Name=mozc' "$HOME/.config/fcitx5/profile" 2>/dev/null && mozc=yes
grep -qx '0=Henkan' "$HOME/.config/fcitx5/config" 2>/dev/null && henkan=yes
printf 'systemctl %s (mozc: %s, henkan: %s)\n' "$*" "$mozc" "$henkan" >>"${CALL_LOG:?}"
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
STUB
chmod +x "$stub_bin"/*

# The layout comes from vconsole.conf, built from TEST_LAYOUT and TEST_VARIANT
# unless TEST_VCONSOLE gives the whole file, or "missing" for none at all.
run_setup() {
  local scenario="$1"
  local home="$test_dir/$scenario/home"
  local vconsole="$test_dir/$scenario/vconsole.conf"

  mkdir -p "$home"
  : >"$test_dir/$scenario.calls"

  rm -f "$vconsole"
  if [[ ! -v TEST_VCONSOLE ]]; then
    printf 'KEYMAP=%s\nXKBLAYOUT=%s\n' "${TEST_KEYMAP:-us}" "${TEST_LAYOUT:-us}" >"$vconsole"
    [[ -z ${TEST_VARIANT:-} ]] || echo "XKBVARIANT=$TEST_VARIANT" >>"$vconsole"
  elif [[ $TEST_VCONSOLE != "missing" ]]; then
    printf '%s' "$TEST_VCONSOLE" >"$vconsole"
  fi

  HOME="$home" CALL_LOG="$test_dir/$scenario.calls" PATH="$stub_bin:$PATH" OMARCHY_VCONSOLE_PATH="$vconsole" \
    bash "$ROOT/bin/omarchy-setup-japanese" >"$test_dir/$scenario.out" 2>&1 ||
    fail "setup japanese runs for $scenario" "$(<"$test_dir/$scenario.out")"
}

profile_of() {
  cat "$test_dir/$1/home/.config/fcitx5/profile"
}

config_of() {
  cat "$test_dir/$1/home/.config/fcitx5/config" 2>/dev/null || true
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

calls=$(<"$test_dir/us.calls")
grep -Fx 'systemctl --user stop omarchy-fcitx5.service (mozc: no, henkan: no)' <<<"$calls" >/dev/null &&
  grep -Fx 'systemctl --user start omarchy-fcitx5.service (mozc: yes, henkan: no)' <<<"$calls" >/dev/null ||
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

grep -Fx 'systemctl --user start omarchy-fcitx5.service (mozc: yes, henkan: yes)' "$test_dir/jis.calls" >/dev/null ||
  fail "fcitx5 starts after the JIS hotkeys are written" "$(<"$test_dir/jis.calls")"
pass "fcitx5 starts after the JIS hotkeys are written"

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

TEST_VCONSOLE=$'XKBLAYOUT="jp,us"\nXKBVARIANT=","\n' run_setup multi-layout
grep -Fx 'Name=keyboard-jp' <<<"$(profile_of multi-layout)" >/dev/null ||
  fail "only the leading layout joins the input methods, as in Hyprland" "$(profile_of multi-layout)"
pass "only the leading layout joins the input methods, as in Hyprland"

# vconsole.conf only guarantees KEYMAP, and it need not exist. Without a
# layout, fall back to us as Hyprland does (see default/hypr/input.lua), even
# where localectl reports the X11 layout as "(unset)".
TEST_VCONSOLE=$'KEYMAP=us\n' TEST_LAYOUT='(unset)' run_setup keymap-only
TEST_VCONSOLE=missing TEST_LAYOUT='(unset)' run_setup missing
for scenario in keymap-only missing; do
  grep -Fx 'Name=keyboard-us' <<<"$(profile_of $scenario)" >/dev/null &&
    ! grep -F '(unset)' <<<"$(profile_of $scenario)" >/dev/null ||
    fail "no keyboard layout falls back to keyboard-us ($scenario)" "$(profile_of $scenario)"
done
pass "no keyboard layout falls back to keyboard-us"

# A profile that already has Mozc is the user's own and is left alone, and
# existing fcitx5 settings survive.
home="$test_dir/existing/home"
mkdir -p "$home/.config/fcitx5"
printf '[Groups/0]\nName=Mine\n\n[Groups/0/Items/0]\nName=mozc\n' >"$home/.config/fcitx5/profile"
config='[Hotkey]
EnumerateWithTriggerKeys=True

[Behavior]
ActiveByDefault=False
resetStateWhenFocusIn=All'
printf '%s\n' "$config" >"$home/.config/fcitx5/config"
TEST_LAYOUT=us run_setup existing

grep -Fx 'Name=Mine' <<<"$(profile_of existing)" >/dev/null ||
  fail "an existing Mozc profile is kept" "$(profile_of existing)"
pass "an existing Mozc profile is kept"

[[ $(config_of existing) == "$config" ]] ||
  fail "outside JIS, setup leaves the fcitx5 settings alone" "$(config_of existing)"
pass "outside JIS, setup leaves the fcitx5 settings alone"

# A profile without Mozc keeps its input methods and gains Mozc after them.
home="$test_dir/append/home"
mkdir -p "$home/.config/fcitx5"
printf '[Groups/0]\nName=Default\nDefault Layout=us\nDefaultIM=pinyin\n\n[Groups/0/Items/0]\nName=keyboard-us\nLayout=\n\n[Groups/0/Items/1]\nName=pinyin\nLayout=\n\n[GroupOrder]\n0=Default\n' >"$home/.config/fcitx5/profile"
TEST_LAYOUT=us run_setup append
profile=$(profile_of append)
grep -A2 -Fx '[Groups/0/Items/0]' <<<"$profile" | grep -Fx 'Name=keyboard-us' >/dev/null &&
  grep -A2 -Fx '[Groups/0/Items/1]' <<<"$profile" | grep -Fx 'Name=pinyin' >/dev/null &&
  grep -A2 -Fx '[Groups/0/Items/2]' <<<"$profile" | grep -Fx 'Name=mozc' >/dev/null &&
  grep -Fx 'DefaultIM=pinyin' <<<"$profile" >/dev/null ||
  fail "a profile without Mozc keeps its input methods and gains Mozc" "$profile"
pass "a profile without Mozc keeps its input methods and gains Mozc"

TEST_LAYOUT=us run_setup append
[[ $(profile_of append) == "$profile" ]] ||
  fail "adding Mozc to an existing profile is idempotent" "$(profile_of append)"
pass "adding Mozc to an existing profile is idempotent"

# fcitx5 saves its profile when setup stops it, so a user who never picked
# input methods has fcitx5's own single keyboard-us group, even on JIS. That
# one takes the layout from vconsole.conf, which Mozc reads its kana table from.
home="$test_dir/stock/home"
mkdir -p "$home/.config/fcitx5"
printf '[Groups/0]\n# Group Name\nName=Default\n# Layout\nDefault Layout=us\n# Default Input Method\nDefaultIM=keyboard-us\n\n[Groups/0/Items/0]\n# Name\nName=keyboard-us\n# Layout\nLayout=\n\n[GroupOrder]\n0=Default\n' >"$home/.config/fcitx5/profile"
TEST_LAYOUT=jp run_setup stock
profile=$(profile_of stock)
grep -Fx 'Default Layout=jp' <<<"$profile" >/dev/null &&
  grep -Fx 'Name=keyboard-jp' <<<"$profile" >/dev/null &&
  grep -Fx 'Name=mozc' <<<"$profile" >/dev/null &&
  ! grep -Fx 'Name=keyboard-us' <<<"$profile" >/dev/null ||
  fail "fcitx5's own keyboard-us profile follows a JIS layout" "$profile"
if compgen -G "$home/.config/fcitx5/profile.bak.*" >/dev/null; then
  fail "fcitx5's own profile is not backed up"
fi
pass "fcitx5's own keyboard-us profile follows a JIS layout"

# A profile with no group to add to is replaced, and the user is told where the
# old one went.
home="$test_dir/backup/home"
mkdir -p "$home/.config/fcitx5"
printf '[GroupOrder]\n' >"$home/.config/fcitx5/profile"
TEST_LAYOUT=us run_setup backup
backup=$(compgen -G "$home/.config/fcitx5/profile.bak.*") ||
  fail "a profile without a group is backed up before it is replaced"
grep -F "$backup" "$test_dir/backup.out" >/dev/null &&
  grep -Fx 'Name=mozc' <<<"$(profile_of backup)" >/dev/null ||
  fail "replacing a profile names its backup" "$(<"$test_dir/backup.out")"
pass "a profile without a group is replaced, and its backup is named"

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
