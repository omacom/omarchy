#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1791210803.sh"
shipped="$ROOT/config/fcitx5/config"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

# The shipped list keeps Ctrl+Space for the tmux and herdr prefix and switches
# on the dedicated Japanese and Korean keys.
triggers=$(sed -n '/^\[Hotkey\/TriggerKeys\]$/,/^\[/p' "$shipped" | grep -E '^[0-9]+=')
[[ $triggers == $'0=Zenkaku_Hankaku\n1=Hangul' ]] ||
  fail "fcitx5 switches on the 全角/半角 and 한/영 keys only" "$triggers"
grep -Fq 'set -g prefix C-Space' "$ROOT/config/tmux/tmux.conf" ||
  fail "tmux still uses the Ctrl+Space prefix the fcitx5 config leaves free"
grep -Fq 'prefix = "ctrl+space"' "$ROOT/config/herdr/config.toml" ||
  fail "herdr still uses the Ctrl+Space prefix the fcitx5 config leaves free"
pass "fcitx5 trigger keys leave Ctrl+Space to tmux and herdr"

mkdir -p "$test_dir/bin"
cat >"$test_dir/bin/fcitx5-remote" <<'STUB'
#!/bin/bash

printf '%s\n' "$*" >>"$FCITX_CALLS"
case "$1" in
  --check) [[ ${FCITX_RUNNING:-true} == "true" ]] ;;
  -r) [[ ${FCITX_RELOAD_FAILS:-false} == "false" ]] ;;
esac
STUB
chmod +x "$test_dir/bin/fcitx5-remote"
export PATH="$test_dir/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export FCITX_CALLS="$test_dir/calls"

run_migration() {
  : >"$FCITX_CALLS"
  HOME="$1" bash -euo pipefail "$migration" >/dev/null
}

single_profile=$'[Groups/0]\nName=Default\nDefault Layout=us\nDefaultIM=keyboard-us\n\n[Groups/0/Items/0]\nName=keyboard-us\nLayout=\n\n[GroupOrder]\n0=Default\n'

home="$test_dir/fresh"
mkdir -p "$home/.config/fcitx5"
printf '%s' "$single_profile" >"$home/.config/fcitx5/profile"
run_migration "$home"
cmp -s "$shipped" "$home/.config/fcitx5/config" ||
  fail "migration seeds the shipped trigger keys for a single input method"
grep -Fxq -- '-r' "$FCITX_CALLS" ||
  fail "migration reloads a running fcitx5 so it does not write the old keys back" "$(cat "$FCITX_CALLS")"
run_migration "$home"
cmp -s "$shipped" "$home/.config/fcitx5/config" ||
  fail "migration leaves its own config alone on a rerun"
pass "migration seeds the trigger keys where switching does nothing yet"

home="$test_dir/no-profile"
mkdir -p "$home"
FCITX_RUNNING=false run_migration "$home"
cmp -s "$shipped" "$home/.config/fcitx5/config" ||
  fail "migration seeds the trigger keys before fcitx5 has written a profile"
! grep -Fxq -- '-r' "$FCITX_CALLS" ||
  fail "migration does not reload an fcitx5 that is not running"
pass "migration covers users without an fcitx5 profile"

home="$test_dir/customized"
mkdir -p "$home/.config/fcitx5"
printf '[Hotkey/TriggerKeys]\n0=Control+space\n' >"$home/.config/fcitx5/config"
run_migration "$home"
[[ $(cat "$home/.config/fcitx5/config") == $'[Hotkey/TriggerKeys]\n0=Control+space' ]] ||
  fail "migration keeps an existing fcitx5 config" "$(cat "$home/.config/fcitx5/config")"

home="$test_dir/linked"
mkdir -p "$home/.config/fcitx5"
ln -s "$test_dir/missing-target" "$home/.config/fcitx5/config"
run_migration "$home"
[[ -L $home/.config/fcitx5/config && ! -e $test_dir/missing-target ]] ||
  fail "migration does not write through a symlinked fcitx5 config"

home="$test_dir/multilingual"
mkdir -p "$home/.config/fcitx5"
printf '%s' "$single_profile" | sed 's/^\[GroupOrder\]$/[Groups\/0\/Items\/1]\nName=mozc\nLayout=\n\n[GroupOrder]/' >"$home/.config/fcitx5/profile"
run_migration "$home"
[[ ! -e $home/.config/fcitx5/config ]] ||
  fail "migration leaves Ctrl+Space alone for someone already switching between input methods"
pass "migration keeps every switching key someone may already rely on"

home="$test_dir/reload-fails"
mkdir -p "$home"
: >"$FCITX_CALLS"
status=0
HOME="$home" FCITX_RELOAD_FAILS=true bash -euo pipefail "$migration" >/dev/null 2>&1 || status=$?
(( status != 0 )) ||
  fail "migration stays pending when fcitx5 cannot reload"
[[ ! -e $home/.config/fcitx5/config ]] ||
  fail "migration takes its config back out when the reload fails"
run_migration "$home"
cmp -s "$shipped" "$home/.config/fcitx5/config" && grep -Fxq -- '-r' "$FCITX_CALLS" ||
  fail "migration seeds and reloads on the retry after a failed reload" "$(cat "$FCITX_CALLS")"
pass "migration retries the reload instead of skipping it"

# The quattro upgrade fills in missing defaults before migrations run, so it
# must leave this file to the migration or the profile check never happens.
upgrade_copy=$(sed -n '/^copy_missing_config_defaults() {$/,/^}$/p' "$ROOT/bin/omarchy-upgrade-to-quattro")
[[ -n $upgrade_copy ]] || fail "the upgrade still has copy_missing_config_defaults"
home="$test_dir/upgrade"
mkdir -p "$home/.config/fcitx5"
printf '%s' "$single_profile" | sed 's/^\[GroupOrder\]$/[Groups\/0\/Items\/1]\nName=chewing\nLayout=\n\n[GroupOrder]/' >"$home/.config/fcitx5/profile"
(
  is_retired_config_file() { return 1; }
  eval "$upgrade_copy"
  copy_missing_config_defaults "$ROOT/config" "$home/.config"
)
[[ ! -e $home/.config/fcitx5/config ]] ||
  fail "the quattro upgrade leaves the fcitx5 config to its migration"
[[ -f $home/.config/fcitx5/conf/xcb.conf ]] ||
  fail "the quattro upgrade still fills in the other missing fcitx5 defaults"
run_migration "$home"
[[ ! -e $home/.config/fcitx5/config ]] ||
  fail "an upgraded user already switching input methods keeps Ctrl+Space"
pass "the quattro upgrade defers the fcitx5 config to its migration"
