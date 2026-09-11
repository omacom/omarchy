#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
fixture_pids=()
cleanup() {
  if ((${#fixture_pids[@]})); then
    kill "${fixture_pids[@]}" 2>/dev/null || true
    wait "${fixture_pids[@]}" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
}
trap cleanup EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home"

# Leave the desktop untouched. Any attempt to reboot fails the test even if
# a later command masks the exit status.
for command in sudo omarchy-system-reboot omarchy-state; do
  cat >"$test_tmp/bin/$command" <<'STUB'
#!/bin/bash
echo "$0 $*" >>"$TEST_TMP/unexpected"
exit 1
STUB
done
printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/omarchy-restart-shell"
# Make kernel detection independent of the host's installed modules. The gum
# stub declines its separate prompt; only compositor prompts are counted below.
printf '#!/bin/bash\nexit 1\n' >"$test_tmp/bin/pacman"
cat >"$test_tmp/bin/gum" <<'STUB'
#!/bin/bash
[[ $* != "confirm Linux kernel has been updated. Reboot?" ]] || exit 1
printf '%s\n' "$*" >>"$TEST_TMP/prompts"
exit 1
STUB
cat >"$test_tmp/bin/pgrep" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/pgrep-args"
[[ -z $TEST_PIDS ]] || printf '%s\n' "$TEST_PIDS"
STUB
chmod +x "$test_tmp/bin/"*

# Real processes and /proc links reproduce package replacement without running
# a compositor: unlinking a copied sleep executable leaves its old inode live.
for name in first second; do
  mkdir "$test_tmp/$name"
  executable="$test_tmp/$name/Hyprland"
  cp "$(command -v sleep)" "$executable"
  "$executable" 300 &
  fixture_pids+=("$!")
  for ((attempt = 0; attempt < 100; attempt++)); do
    [[ $(readlink "/proc/$!/exe") == "$executable" ]] && break
    sleep 0.01
  done
  [[ $(readlink "/proc/$!/exe") == "$executable" ]] || fail "fixture process starts"
done

run_restart() {
  : >"$test_tmp/prompts"
  env HOME="$test_tmp/home" PATH="$test_tmp/bin:$PATH" \
    TEST_TMP="$test_tmp" TEST_PIDS="$1" \
    bash "$ROOT/bin/omarchy-update-restart" >"$test_tmp/output"
  [[ ! -e $test_tmp/unexpected ]] || fail "restart test attempted a system mutation"
  [[ $(cat "$test_tmp/pgrep-args") == "-u $(id -u) -x Hyprland" ]] ||
    fail "restart detection includes another user's compositor"
}

assert_prompts() {
  local count
  count=$(wc -l <"$test_tmp/prompts")
  ((count == $1)) || fail "$2" "Expected $1 prompts, got $count"
  if ((count)); then
    [[ $(cat "$test_tmp/prompts") == "confirm Hyprland has been updated. Reboot?" ]] ||
      fail "restart prompt identifies the changed compositor"
  fi
  pass "$2"
}

run_restart "${fixture_pids[0]}"
assert_prompts 0 "an unchanged running compositor needs no reboot"

rm "$test_tmp/first/Hyprland"
cp "$(command -v sleep)" "$test_tmp/first/Hyprland"
run_restart "${fixture_pids[0]}"
assert_prompts 0 "an identical reinstall needs no reboot despite a deleted executable"

rm "$test_tmp/second/Hyprland"
cp "$(command -v sleep)" "$test_tmp/second/Hyprland"
printf 'changed binary\n' >>"$test_tmp/second/Hyprland"
run_restart "$(printf '%s\n' "${fixture_pids[@]}")"
assert_prompts 1 "a changed executable among multiple compositors requests one reboot"

printf 'changed binary\n' >>"$test_tmp/first/Hyprland"
run_restart "$(printf '%s\n' "${fixture_pids[@]}")"
assert_prompts 1 "multiple changed compositors request only one reboot"

rm "$test_tmp/first/Hyprland"
run_restart "${fixture_pids[0]}"
assert_prompts 1 "an unavailable replacement conservatively requests a reboot"

run_restart ""
assert_prompts 0 "a session with no compositor needs no compositor reboot"
