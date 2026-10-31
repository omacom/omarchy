#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "idle lock wake test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping idle lock wake test"
  exit 0
fi

require_command jq

TMPDIR=$(mktemp -d)
result="$TMPDIR/result.json"
log="$TMPDIR/quickshell.log"
wake_runs="$TMPDIR/wake-runs"
lock_mode="$TMPDIR/lock-mode"
config_dir="$TMPDIR/idle-lock-wake"
fake_bin="$TMPDIR/bin"
mkdir -p "$config_dir" "$TMPDIR/home" "$fake_bin"
cp "$SHELL_TEST_DIR/fixtures/idle-lock-wake/shell.qml" "$config_dir/shell.qml"
ln -s "$ROOT/shell/Commons" "$config_dir/Commons"

# The lock state is the compositor's to answer at wake time, so the boundary is
# the PATH: the helper answers from the mode file the fixture flips, and the
# wake records a run instead of lighting a real display.
cat >"$fake_bin/omarchy-hyprland-session-locked" <<SH
#!/bin/bash
case \$(cat "$lock_mode" 2>/dev/null) in
  locked) exit 0 ;;
  undetermined) exit 2 ;;
  *) exit 1 ;;
esac
SH

cat >"$fake_bin/omarchy-system-wake" <<SH
#!/bin/bash
printf 'run\n' >> "$wake_runs"
SH
chmod +x "$fake_bin/omarchy-hyprland-session-locked" "$fake_bin/omarchy-system-wake"

# The idle service spawns its commands through a login shell, and the profile
# of a machine dev-linked to another checkout puts that checkout's bin first.
# Refuse to run the real helper or wake against the developer's session.
for command in omarchy-hyprland-session-locked omarchy-system-wake; do
  resolved=$(HOME="$TMPDIR/home" PATH="$fake_bin:$ROOT/bin:$PATH" bash -lc "command -v $command" 2>/dev/null || true)
  if [[ $resolved != "$fake_bin/$command" ]]; then
    skip "login shell resolves $command to ${resolved:-nothing}; skipping idle lock wake test"
    exit 0
  fi
done

IDLE_LOCK_WAKE_MODE="$lock_mode" \
OMARCHY_PATH="$ROOT" \
OMARCHY_QML_TEST_RESULT="$result" \
HOME="$TMPDIR/home" \
XDG_CONFIG_HOME="$TMPDIR/home/.config" \
XDG_CACHE_HOME="$TMPDIR/home/.cache" \
XDG_STATE_HOME="$TMPDIR/home/.local/state" \
QML2_IMPORT_PATH="$ROOT/shell${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}" \
QML_IMPORT_PATH="$ROOT/shell${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \
PATH="$fake_bin:$ROOT/bin:$PATH" \
  timeout 30 quickshell -p "$config_dir" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..150}; do
  [[ -s $result ]] && break
  if ! kill -0 "$QS_PID" 2>/dev/null; then
    sed -n '1,220p' "$log" >&2
    fail "idle lock wake quickshell exited before writing result"
  fi
  sleep 0.2
done

[[ -s $result ]] || {
  sed -n '1,220p' "$log" >&2
  fail "idle lock wake test timed out"
}

if ! jq -e '.ok == true' "$result" >/dev/null; then
  printf 'Idle lock wake result:\n' >&2
  jq . "$result" >&2
  printf 'Idle lock wake log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "idle wake asks the compositor before waking the display"
fi

# The marker is the wake command actually running: once unlocked and once for
# an undetermined answer, never while the compositor said locked.
runs=0
[[ -f $wake_runs ]] && runs=$(wc -l <"$wake_runs")
if (( runs != 2 )); then
  printf 'Idle lock wake log:\n' >&2
  sed -n '1,220p' "$log" >&2
  fail "omarchy-system-wake ran $runs times, wanted exactly 2 (unlocked and undetermined)"
fi

pass "idle wake asks the compositor and leaves a locked session's display to the lock screen"
