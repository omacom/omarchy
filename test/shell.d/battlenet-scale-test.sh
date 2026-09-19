#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
fake_pids=()
cleanup() {
  (( ${#fake_pids[@]} )) && kill "${fake_pids[@]}" 2>/dev/null
  rm -rf "$test_tmp"
}
trap cleanup EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
home="$test_tmp/home"
prefix="$home/Games/battlenet"
mkdir -p "$mock_bin" "$prefix"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
[[ ${HYPR_DOWN:-0} == "1" ]] && exit 1

if [[ $* == *"force_zero_scaling"* ]]; then
  printf '{"option": "xwayland:force_zero_scaling", "bool": %s, "set": true }\n' "${ZERO_SCALING:-true}"
else
  printf '[{"name": "DP-1", "focused": true, "scale": %s}]\n' "${MONITOR_SCALE:-2}"
fi
SH

# wineboot -k ends the session, so it takes the stand-in processes down with it.
cat >"$mock_bin/umu-run" <<'SH'
#!/bin/bash
printf '%s | %s\n' "$WINEPREFIX" "$*" >>"$CALL_LOG"

if [[ $* == "wineboot -k" && -s $FAKE_PIDS ]]; then
  xargs kill <"$FAKE_PIDS" 2>/dev/null
fi
exit 0
SH

chmod +x "$mock_bin"/*

# user.reg as Wine writes it: the desktop key only exists once a DPI was chosen,
# and Wine mirrors the DPI in effect under its own Fonts key either way.
write_prefix_dpi() {
  local hex="$1"

  {
    printf 'WINE REGISTRY Version 2\n\n'
    if [[ -n $hex ]]; then
      printf '[Control Panel\\\\Desktop] 1789520096\n"LogPixels"=dword:%s\n\n' "$hex"
    fi
    printf '[Software\\\\Wine\\\\Fonts] 1789520096\n"LogPixels"=dword:00000060\n'
  } >"$prefix/user.reg"
}

# A process the way the helper sees one from a live prefix session: tagged with
# the prefix in its environment and carrying a Windows command line.
fake_session_process() {
  local name="$1"

  STEAM_COMPAT_DATA_PATH="$prefix" bash -c 'exec -a "$0" sleep 60' "$name" &
  fake_pids+=("$!")
  printf '%s\n' "$!" >>"$test_tmp/fake-pids"
  sleep 0.2
}

run_scale() {
  : >"$call_log"
  CALL_LOG="$call_log" FAKE_PIDS="$test_tmp/fake-pids" HOME="$home" \
    PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-games-battlenet-scale"
}

write_prefix_dpi ""
run_scale
grep -F "$prefix | reg add HKCU\\Control Panel\\Desktop /v LogPixels /t REG_DWORD /d 192 /f" "$call_log" >/dev/null ||
  fail "a 2x monitor sets an untouched prefix to 192 DPI" "$(cat "$call_log")"
pass "a 2x monitor sets an untouched prefix to 192 DPI"

MONITOR_SCALE=1.6 run_scale
grep -F "/d 154 /f" "$call_log" >/dev/null || fail "a fractional scale rounds to the nearest DPI" "$(cat "$call_log")"
pass "a fractional scale rounds to the nearest DPI"

write_prefix_dpi "000000c0"
run_scale
[[ ! -s $call_log ]] || fail "a prefix already at the monitor's DPI is left alone" "$(cat "$call_log")"
pass "a prefix already at the monitor's DPI is left alone"

MONITOR_SCALE=1 run_scale
grep -F "/d 96 /f" "$call_log" >/dev/null || fail "moving to an unscaled monitor drops the prefix back to 96 DPI" "$(cat "$call_log")"
pass "moving to an unscaled monitor drops the prefix back to 96 DPI"

ZERO_SCALING=false run_scale
grep -F "/d 96 /f" "$call_log" >/dev/null || fail "Wine stays at 96 DPI when Hyprland scales XWayland itself" "$(cat "$call_log")"
pass "Wine stays at 96 DPI when Hyprland scales XWayland itself"

HYPR_DOWN=1 run_scale
[[ ! -s $call_log ]] || fail "the prefix is left alone outside Hyprland" "$(cat "$call_log")"
pass "the prefix is left alone outside Hyprland"

write_prefix_dpi ""
fake_session_process 'C:\windows\system32\services.exe'
fake_session_process 'C:\Program Files (x86)\World of Warcraft\_retail_\Wow.exe'
run_scale
[[ ! -s $call_log ]] || fail "a session running a game is never interrupted" "$(cat "$call_log")"
pass "a session running a game is never interrupted"
kill "${fake_pids[@]}" 2>/dev/null
wait "${fake_pids[@]}" 2>/dev/null || true
fake_pids=()
: >"$test_tmp/fake-pids"

fake_session_process 'C:\windows\system32\services.exe'
fake_session_process 'C:/ProgramData/Battle.net/Agent/Agent.9775/Agent.exe'
run_scale
[[ $(sed -n 1p "$call_log") == "$prefix | wineboot -k" ]] || fail "a session only the agent holds open is stopped first" "$(cat "$call_log")"
[[ $(sed -n 2p "$call_log") == *"/d 192 /f" ]] || fail "the DPI is written once the agent's session is gone" "$(cat "$call_log")"
pass "a session only the agent holds open is stopped before the DPI is written"
fake_pids=()

for script in omarchy-launch-battlenet omarchy-install-gaming-battlenet; do
  scale_line=$(grep -n '^ *omarchy-games-battlenet-scale$' "$ROOT/bin/$script" | cut -d : -f 1)
  run_line=$(grep -n 'umu-run' "$ROOT/bin/$script" | tail -n 1 | cut -d : -f 1)
  [[ -n $scale_line ]] && (( scale_line < run_line )) || fail "$script scales the prefix before starting Wine"
done
pass "the launcher and the installer scale the prefix before starting Wine"
