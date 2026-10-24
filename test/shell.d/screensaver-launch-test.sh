#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
mock_bin="$test_dir/bin"
screensaver_pid=""
launcher_pid=""
cleanup() {
  local effect_pid
  for effect_file in "$test_dir"/effect-*; do
    if [[ -f $effect_file ]]; then
      effect_pid=$(<"$effect_file")
      kill "$effect_pid" 2>/dev/null || true
    fi
  done
  [[ -z $screensaver_pid ]] || kill "$screensaver_pid" 2>/dev/null || true
  [[ -z $launcher_pid ]] || kill "$launcher_pid" 2>/dev/null || true
  rm -rf "$test_dir"
}
trap cleanup EXIT
mkdir -p "$mock_bin"
mkfifo "$test_dir/input"
exec {input}<>"$test_dir/input"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "activewindow" ]]; then
  focused=$(<"$SCREENSAVER_TEST_DIR/focus")
  printf '%s\n' "$focused" >>"$SCREENSAVER_TEST_DIR/samples"
  printf '{"class":"%s"}\n' "$focused"
elif [[ $1 == "monitors" ]]; then
  echo '[{"name":"DP-1"},{"name":"DP-2"}]'
elif [[ $1 == "dispatch" ]]; then
  printf '%s\n' "$2" >>"$SCREENSAVER_TEST_DIR/dispatches"
fi
SH
cat >"$mock_bin/ttfx" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$SCREENSAVER_TEST_DIR/effect-$$"
exec sleep 30
SH
cat >"$mock_bin/pkill" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SCREENSAVER_TEST_DIR/kills"
SH
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ $1 != "-f" ]]
SH
printf '#!/bin/bash\necho "30 100"\n' >"$mock_bin/stty"
printf '#!/bin/bash\necho /dev/pts/test\n' >"$mock_bin/tty"
chmod +x "$mock_bin/"*

wait_for_exit() {
  local attempt
  for attempt in {1..50}; do
    if ! kill -0 "$screensaver_pid" 2>/dev/null; then
      wait "$screensaver_pid"
      screensaver_pid=""
      return 0
    fi
    sleep 0.1
  done
  fail "screensaver exits after launch completes and focus leaves"
}

# Use a separate process for the launch lifetime so its exit can be controlled.
sleep 30 &
launcher_pid=$!
printf 'org.omarchy.screensaver\n' >"$test_dir/focus"
env PATH="$mock_bin:$PATH" SCREENSAVER_TEST_DIR="$test_dir" OMARCHY_SCREENSAVER_LAUNCH_PID="$launcher_pid" \
  "$ROOT/bin/omarchy-screensaver" <&"$input" >"$test_dir/output" 2>&1 &
screensaver_pid=$!
for attempt in {1..50}; do
  [[ -f $test_dir/samples ]] && break
  sleep 0.1
done
[[ -f $test_dir/samples ]] || fail "screensaver samples focus during launch"
grep -Fqx 'org.omarchy.screensaver' "$test_dir/samples" || fail "screensaver observes initial focus"
printf 'normal.window\n' >"$test_dir/focus"
sleep 1.5
kill -0 "$screensaver_pid" 2>/dev/null || fail "screensaver survives a monitor switch after its first focus sample"
[[ ! -e $test_dir/kills ]] || fail "launch-time focus changes do not kill sibling windows"
pass "screensaver retains launch protection after observing focus"

kill "$launcher_pid"
wait "$launcher_pid" 2>/dev/null || true
launcher_pid=""
wait_for_exit
grep -Fqx -- '-f [o]rg.omarchy.screensaver' "$test_dir/kills" ||
  fail "focus loss after launch still closes screensaver windows"
pass "screensaver exits on focus loss after the launcher finishes"

rm "$test_dir/kills"
sleep 30 &
launcher_pid=$!
env PATH="$mock_bin:$PATH" SCREENSAVER_TEST_DIR="$test_dir" OMARCHY_SCREENSAVER_LAUNCH_PID="$launcher_pid" \
  "$ROOT/bin/omarchy-screensaver" <&"$input" >"$test_dir/output" 2>&1 &
screensaver_pid=$!
sleep 0.2
printf 'x' >&"$input"
wait_for_exit
pass "keyboard input can still dismiss the screensaver during launch"

printf '#!/bin/bash\nexit 1\n' >"$mock_bin/omarchy-toggle-enabled"
printf '#!/bin/bash\necho DP-1\n' >"$mock_bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho org.wezfurlong.wezterm.desktop\n' >"$mock_bin/xdg-terminal-exec"
cat >"$mock_bin/socat" <<'SH'
#!/bin/bash
printf 'openwindow>>1,1,org.omarchy.screensaver,Screensaver\nopenwindow>>2,2,org.omarchy.screensaver,Screensaver\n'
SH
chmod +x "$mock_bin/"*
env PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_dir" HYPRLAND_INSTANCE_SIGNATURE=test \
  SCREENSAVER_TEST_DIR="$test_dir" "$ROOT/bin/omarchy-launch-screensaver" force
mapfile -t launch_ids < <(grep -oE 'OMARCHY_SCREENSAVER_LAUNCH_PID=[0-9]+' "$test_dir/dispatches")
(( ${#launch_ids[@]} == 2 )) || fail "launcher passes its lifetime to every screensaver"
[[ ${launch_ids[0]} == "${launch_ids[1]}" ]] || fail "all instances track the same launcher"
[[ $(tail -n 1 "$test_dir/dispatches") == 'hl.dsp.focus({ monitor = "DP-1" })' ]] ||
  fail "launcher restores the original monitor before exiting"
pass "launcher passes its PID to every monitor and restores focus before exit"
