#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/runtime"

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-toggle-enabled" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-hyprland-monitor-focused" <<'SH'
#!/bin/bash
printf 'DP-1\n'
SH
cat >"$mock_bin/xdg-terminal-exec" <<'SH'
#!/bin/bash
printf '%s\n' "$TEST_TERMINAL"
SH
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "monitors" ]]; then
  printf '[{"name":"DP-1"}]\n'
else
  printf '%s\n' "$*" >>"$CALL_LOG"
fi
SH
cat >"$mock_bin/socat" <<'SH'
#!/bin/bash
printf 'openwindow>>1,1,org.omarchy.screensaver,Screensaver\n'
SH
chmod +x "$mock_bin"/*

# Run the actual launcher with all compositor, process, and event-stream calls
# stubbed. Check the command it sends, rather than the array's source spelling.
for terminal in Alacritty ghostty foot kitty; do
  for mode in manual idle; do
    args=()
    [[ $mode == "idle" ]] && args=(--idle)
    : >"$call_log"
    HOME="$test_tmp/home" XDG_RUNTIME_DIR="$test_tmp/runtime" \
      HYPRLAND_INSTANCE_SIGNATURE=test OMARCHY_PATH="$ROOT" \
      PATH="$mock_bin:$PATH" TEST_TERMINAL="$terminal" CALL_LOG="$call_log" \
      bash "$ROOT/bin/omarchy-launch-screensaver" "${args[@]}"

    mapfile -t launches < <(rg 'hl\.dsp\.exec_cmd' "$call_log")
    (( ${#launches[@]} == 1 )) || fail "$terminal $mode launches one screensaver"
    if [[ $mode == "idle" ]]; then
      [[ ${launches[0]} == *"-e omarchy-screensaver --idle "* ]] ||
        fail "$terminal forwards --idle to the screensaver" "${launches[0]}"
    else
      [[ ${launches[0]} == *"-e omarchy-screensaver "* && ${launches[0]} != *"--idle"* ]] ||
        fail "$terminal manual launch stays on the manual path" "${launches[0]}"
    fi
    pass "$terminal $mode forwards the correct screensaver arguments"
  done
done
