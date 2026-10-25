#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
home_dir="$tmpdir/home"
log="$tmpdir/actions.log"
mkdir -p "$stub_dir" "$home_dir/.local/state/omarchy/toggles/hypr"

make_stub() {
  local name=$1
  local body=$2
  printf '#!/bin/bash\n%s\n' "$body" >"$stub_dir/$name"
  chmod +x "$stub_dir/$name"
}

make_stub omarchy-hyprland-monitor-laptop 'printf "eDP-1\n"'
make_stub omarchy-hyprland-monitor-external-active 'exit "${EXTERNAL_STATE:-2}"'
make_stub omarchy-hyprland-toggle-enabled 'exit 0'
make_stub omarchy-hyprland-toggle-disabled 'exit 1'
make_stub omarchy-hyprland-toggle 'printf "toggle %s %s\n" "$1" "$2" >>"$ACTION_LOG"; exit "${TOGGLE_STATUS:-0}"'
make_stub omarchy-notification-send ':'
make_stub hyprctl 'if [[ $1 == monitors ]]; then printf "[{\"name\":\"eDP-1\"},{\"name\":\"DP-1\"}]\n"; else printf "hyprctl %s\n" "$*" >>"$ACTION_LOG"; fi'

run_recover() {
  local command=$1
  local state=$2
  : >"$log"
  HOME="$home_dir" \
    ACTION_LOG="$log" \
    EXTERNAL_STATE="$state" \
    TOGGLE_STATUS="${TOGGLE_STATUS:-0}" \
    PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/$command" recover
}

assert_no_mutation() {
  local label=$1
  [[ ! -s $log ]] || fail "$label" "$(cat "$log")"
  pass "$label"
}

assert_internal_recovers() {
  grep -Fx 'toggle internal-monitor-disable off' "$log" >/dev/null ||
    fail "internal recovery clears its toggle on known false" "$(cat "$log")"
  grep -F 'hyprctl dispatch' "$log" >/dev/null ||
    fail "internal recovery wakes the display on known false" "$(cat "$log")"
  pass "internal recovery acts only on a known missing external display"
}

assert_mirror_recovers() {
  grep -Fx 'toggle internal-monitor-mirror off' "$log" >/dev/null ||
    fail "mirror recovery clears its toggle on known false" "$(cat "$log")"
  if grep -Fq 'hyprctl dispatch' "$log"; then
    fail "mirror recovery does not invent a display wake"
  fi
  pass "mirror recovery acts only on a known missing external display"
}

for command in omarchy-hyprland-monitor-internal omarchy-hyprland-monitor-internal-mirror; do
  run_recover "$command" 0
  assert_no_mutation "$command leaves toggles alone while an external display is active"

  run_recover "$command" 2
  assert_no_mutation "$command leaves toggles alone when external state is unknown"

  run_recover "$command" 124
  assert_no_mutation "$command leaves toggles alone when the external query times out"

  run_recover "$command" 1
  if [[ $command == omarchy-hyprland-monitor-internal ]]; then
    assert_internal_recovers
  else
    assert_mirror_recovers
  fi
done


for command in omarchy-hyprland-monitor-internal omarchy-hyprland-monitor-internal-mirror; do
  : >"$log"
  set +e
  TOGGLE_STATUS=1 run_recover "$command" 1
  status=$?
  set -e

  (( status != 0 )) ||
    fail "$command propagates a failed recovery mutation"

  grep -Fq 'toggle ' "$log" ||
    fail "$command attempted the recovery mutation before failing"

  if [[ $command == omarchy-hyprland-monitor-internal ]] && grep -Fq 'hyprctl dispatch' "$log"; then
    fail "internal recovery does not wake after its toggle removal failed" "$(cat "$log")"
  fi

  pass "$command preserves recovery mutation failures"
done
