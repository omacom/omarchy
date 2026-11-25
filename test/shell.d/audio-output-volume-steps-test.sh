#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command flock

test_dir=$(mktemp -d)

cleanup() {
  rm -rf "$test_dir"
}
trap cleanup EXIT

mkdir -p "$test_dir/bin" "$test_dir/runtime"

cat >"$test_dir/bin/pactl" <<'STUB'
#!/bin/bash
case "$1" in
  get-sink-volume)
    volume=$(<"$TEST_DATA/volume")
    sleep 0.05
    printf 'Volume: front-left: 0 / %s%% / 0 dB,   front-right: 0 / %s%% / 0 dB\n' "$volume" "$volume"
    ;;
  set-sink-volume) printf '%s\n' "${3%\%}" >"$TEST_DATA/volume" ;;
  get-sink-mute) echo "Mute: no" ;;
  set-sink-mute) ;;
  *) exit 1 ;;
esac
STUB
cat >"$test_dir/bin/omarchy-audio-output-sink" <<'STUB'
#!/bin/bash
echo test_sink
STUB
cat >"$test_dir/bin/omarchy-osd" <<'STUB'
#!/bin/bash
touch "$TEST_DATA/osd/$$"
for _ in {1..300}; do
  osd_runs=("$TEST_DATA/osd/"*)
  ((${#osd_runs[@]} >= 10)) && exit 0
  sleep 0.01
done
exit 1
STUB
chmod +x "$test_dir/bin/"*

change_volume_concurrently() {
  local action="$1"
  local pid _
  local -a pids=()

  rm -rf "$test_dir/osd"
  mkdir "$test_dir/osd"

  for _ in {1..10}; do
    TEST_DATA="$test_dir" XDG_RUNTIME_DIR="$test_dir/runtime" PATH="$test_dir/bin:$PATH" \
      bash "$ROOT/bin/omarchy-audio-output-volume" "$action" &
    pids+=("$!")
    sleep 0.01
  done

  for pid in "${pids[@]}"; do
    wait "$pid" || fail "overlapping volume ${action}s all finish with their OSD shown together" "a run exited non-zero"
  done
}

printf '20\n' >"$test_dir/volume"
change_volume_concurrently raise
volume=$(<"$test_dir/volume")
((volume == 70)) || fail "overlapping volume raises each apply their step" "expected 70, got $volume"
pass "overlapping volume raises each apply their step"

change_volume_concurrently lower
volume=$(<"$test_dir/volume")
((volume == 20)) || fail "overlapping volume lowers each apply their step" "expected 20, got $volume"
pass "overlapping volume lowers each apply their step"
