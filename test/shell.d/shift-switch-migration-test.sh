#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791676907.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
export CALL_LOG="$test_dir/calls"

# A live Fcitx is asked to reload; never reach the real session bus.
cat >"$test_dir/bin/busctl" <<'SH'
#!/bin/bash
printf 'busctl %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$test_dir/bin/busctl"

# Runs the migration twice, as a retried update would. The caller's own
# XDG_CONFIG_HOME would point at the developer's real config, so it is cleared
# unless a case sets MIGRATION_XDG_CONFIG_HOME.
migrate() {
  local home=$1
  for run in 1 2; do
    env -u XDG_CONFIG_HOME ${MIGRATION_XDG_CONFIG_HOME:+XDG_CONFIG_HOME="$MIGRATION_XDG_CONFIG_HOME"} \
      HOME="$home" PATH="$test_dir/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
  done
}

fresh_home() {
  rm -rf "$test_dir/home" "$CALL_LOG"
  mkdir -p "$test_dir/home/.config/fcitx5"
  printf '%s' "$1" >"$test_dir/home/.config/fcitx5/config"
}

fresh_home $'[Hotkey/TriggerKeys]\n0=Hangul\n\n[Hotkey/AltTriggerKeys]\n\n[Behavior]\nActiveByDefault=False\n'
migrate "$test_dir/home"
[[ $(<"$test_dir/home/.config/fcitx5/config") == $'[Hotkey/TriggerKeys]\n0=Hangul\n\n[Hotkey/AltTriggerKeys]\n0=Shift_L\n\n[Behavior]\nActiveByDefault=False' ]] ||
  fail "an empty list gets Shift_L once" "$(<"$test_dir/home/.config/fcitx5/config")"
[[ $(grep -c ReloadConfig "$CALL_LOG") == 1 ]] || fail "Fcitx reloads only when the list changes" "$(cat "$CALL_LOG")"
pass "an empty list gets Shift_L once, and Fcitx reloads once"

fresh_home $'[Hotkey/AltTriggerKeys]\n0=Shift_R\n'
migrate "$test_dir/home"
[[ $(<"$test_dir/home/.config/fcitx5/config") == $'[Hotkey/AltTriggerKeys]\n0=Shift_R' && ! -e $CALL_LOG ]] ||
  fail "a chosen key is kept" "$(<"$test_dir/home/.config/fcitx5/config")"
pass "a list the user filled is kept"

fresh_home $'[Behavior]\nActiveByDefault=False\n'
migrate "$test_dir/home"
[[ $(<"$test_dir/home/.config/fcitx5/config") == $'[Behavior]\nActiveByDefault=False' ]] ||
  fail "a missing list keeps Fcitx's own Shift_L default" "$(<"$test_dir/home/.config/fcitx5/config")"
rm -rf "$test_dir/home"
mkdir -p "$test_dir/home"
migrate "$test_dir/home"
[[ ! -e $test_dir/home/.config/fcitx5/config ]] || fail "no Fcitx config is created"
pass "a missing list or config is left to Fcitx's default"

fresh_home ""
mkdir -p "$test_dir/dotfiles"
printf '[Hotkey/AltTriggerKeys]\n\n' >"$test_dir/dotfiles/fcitx5-config"
ln -sf "$test_dir/dotfiles/fcitx5-config" "$test_dir/home/.config/fcitx5/config"
migrate "$test_dir/home"
[[ -L $test_dir/home/.config/fcitx5/config && $(grep -c '^0=Shift_L$' "$test_dir/dotfiles/fcitx5-config") == 1 ]] ||
  fail "a symlinked config stays linked and its target is updated" "$(ls -l "$test_dir/home/.config/fcitx5/config"; cat "$test_dir/dotfiles/fcitx5-config")"
pass "a symlinked config stays linked and its target is updated"

rm -rf "$test_dir/home" "$test_dir/xdg"
mkdir -p "$test_dir/home" "$test_dir/xdg/fcitx5"
printf '[Hotkey/AltTriggerKeys]\n' >"$test_dir/xdg/fcitx5/config"
MIGRATION_XDG_CONFIG_HOME="$test_dir/xdg" migrate "$test_dir/home"
[[ $(<"$test_dir/xdg/fcitx5/config") == $'[Hotkey/AltTriggerKeys]\n0=Shift_L' ]] ||
  fail "XDG_CONFIG_HOME is followed" "$(<"$test_dir/xdg/fcitx5/config")"
pass "the config under XDG_CONFIG_HOME is the one repaired"
