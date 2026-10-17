#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

user_home=$test_tmp/home/player
root_home=$test_tmp/root
shim_bin=$test_tmp/shims
event_log=$test_tmp/events

heroic_dirs=(
  .config/heroic
  .local/share/heroic
  .local/state/Heroic
  .cache/heroic
  .cache/heroic_gogdl
  Games/Heroic
)

seed_heroic_dirs() {
  local home dir
  for home in "$user_home" "$root_home"; do
    for dir in "${heroic_dirs[@]}"; do
      mkdir -p "$home/$dir"
      touch "$home/$dir/data"
    done
  done
  : >"$event_log"
}

mkdir -p "$shim_bin"

cat >"$shim_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
echo "omarchy-pkg-drop $*" >>"$EVENT_LOG"
SH

# Resolve the fake invoking user by name or uid without touching /etc/passwd
cat >"$shim_bin/getent" <<'SH'
#!/bin/bash
[[ $1 == "passwd" ]] || exit 2
case $2 in
  player|4242) echo "player:x:4242:4242::$USER_HOME:/bin/bash" ;;
  *) exit 2 ;;
esac
SH

chmod +x "$shim_bin/omarchy-pkg-drop" "$shim_bin/getent"

run_remove() {
  env -i PATH="$shim_bin:/usr/bin:/bin" HOME="$root_home" USER=root \
    EVENT_LOG="$event_log" USER_HOME="$user_home" "$@" \
    "$ROOT/bin/omarchy-remove-gaming-heroic" >/dev/null
}

assert_user_cleaned() {
  local via="$1" dir

  grep -qx "omarchy-pkg-drop heroic-games-launcher-bin" "$event_log" ||
    fail "removing Heroic under $via drops the package" "$(cat "$event_log")"

  for dir in "${heroic_dirs[@]}"; do
    [[ ! -e $user_home/$dir ]] ||
      fail "removing Heroic under $via cleans the invoking user's ~/$dir"
    [[ -e $root_home/$dir ]] ||
      fail "removing Heroic under $via leaves root's ~/$dir alone"
  done
}

seed_heroic_dirs
run_remove SUDO_USER=player || fail "removing Heroic under sudo succeeds"
assert_user_cleaned sudo
pass "removing Heroic under sudo cleans the invoking user's home, not root's"

seed_heroic_dirs
run_remove PKEXEC_UID=4242 || fail "removing Heroic under pkexec succeeds"
assert_user_cleaned pkexec
pass "removing Heroic under pkexec cleans the invoking user's home, not root's"

seed_heroic_dirs
run_remove OMARCHY_INSTALL_USER=player SUDO_USER=root PKEXEC_UID=0 ||
  fail "removing Heroic during install succeeds"
assert_user_cleaned install
pass "removing Heroic during install cleans the install user's home ahead of sudo and pkexec"

seed_heroic_dirs
if run_remove SUDO_USER=ghost 2>/dev/null; then
  fail "removing Heroic fails when the invoking user has no home"
fi
[[ -e $root_home/.config/heroic ]] ||
  fail "removing Heroic for an unknown user leaves root's home alone"
! grep -q "omarchy-pkg-drop" "$event_log" ||
  fail "removing Heroic for an unknown user keeps the package"
pass "removing Heroic for an unknown user fails without touching root's home"

seed_heroic_dirs
if run_remove PKEXEC_UID=9999 2>/dev/null; then
  fail "removing Heroic fails when the pkexec uid cannot be resolved"
fi
for dir in "${heroic_dirs[@]}"; do
  [[ -e $root_home/$dir ]] ||
    fail "removing Heroic for an unresolvable pkexec uid leaves root's ~/$dir alone"
done
! grep -q "omarchy-pkg-drop" "$event_log" ||
  fail "removing Heroic for an unresolvable pkexec uid keeps the package"
pass "removing Heroic for an unresolvable pkexec uid fails without touching root's home"

# Unelevated, the caller is the user, so $HOME is used without a lookup
seed_heroic_dirs
env -i PATH="$shim_bin:/usr/bin:/bin" HOME="$user_home" USER=nobody-here \
  EVENT_LOG="$event_log" USER_HOME="$user_home" \
  "$ROOT/bin/omarchy-remove-gaming-heroic" >/dev/null ||
  fail "removing Heroic unelevated succeeds"
for dir in "${heroic_dirs[@]}"; do
  [[ ! -e $user_home/$dir ]] || fail "removing Heroic unelevated cleans ~/$dir"
done
pass "removing Heroic unelevated cleans \$HOME"
