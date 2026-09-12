#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command tail

TEST_HOME=$(mktemp -d)
FAKE_BIN="$TEST_HOME/bin"
CURRENT_THEME="$TEST_HOME/.local/state/omarchy/current/theme"
mkdir -p "$FAKE_BIN" "$CURRENT_THEME" "$TEST_HOME/.config/opencode"

SERVE_PID=""
TUI_PID=""

# shellcheck disable=SC2329
cleanup() {
  kill "$SERVE_PID" "$TUI_PID" 2>/dev/null || true
  rm -rf "$TEST_HOME"
}
trap cleanup EXIT

# pgrep shim: report only PIDs this test controls, never real processes.
cat >"$FAKE_BIN/pgrep" <<'EOF'
#!/bin/bash
cat "$PGREP_PID_FILE" 2>/dev/null || true
EOF
chmod +x "$FAKE_BIN/pgrep"
PGREP_PID_FILE="$TEST_HOME/pgrep-pids"
: >"$PGREP_PID_FILE"
export PGREP_PID_FILE

# Fake opencode processes: same process name, but only one carries the
# background service command line.
start_fake_processes() {
  kill "$SERVE_PID" "$TUI_PID" 2>/dev/null || true
  ln -sf "$(command -v tail)" "$FAKE_BIN/opencode"
  "$FAKE_BIN/opencode" -f /dev/null -- serve --service 2>/dev/null &
  SERVE_PID=$!
  "$FAKE_BIN/opencode" -f /dev/null 2>/dev/null &
  TUI_PID=$!
  printf '%s\n%s\n' "$SERVE_PID" "$TUI_PID" >"$PGREP_PID_FILE"
}

printf '{"background": "#15191d"}\n' >"$CURRENT_THEME/opencode.json"

start_fake_processes
TRACE="$TEST_HOME/trace.log"
PATH="$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" bash -x "$ROOT/bin/omarchy-theme-set-opencode" "some-theme" 2>"$TRACE" || fail "opencode theme sync exits zero with processes running"
grep -Fq "kill -SIGUSR2 $TUI_PID" "$TRACE" || fail "opencode theme sync refreshes the running TUI"
grep -Fq "kill -SIGUSR2 $SERVE_PID" "$TRACE" && fail "opencode theme sync never signals the background service"

start_fake_processes
: >"$TRACE"
PATH="$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" bash -x "$ROOT/bin/omarchy-restart-opencode" 2>"$TRACE" || fail "opencode restart exits zero with processes running"
grep -Fq "kill -SIGUSR2 $TUI_PID" "$TRACE" || fail "opencode restart refreshes the running TUI"
grep -Fq "kill -SIGUSR2 $SERVE_PID" "$TRACE" && fail "opencode restart never signals the background service"

pass "opencode refresh signals only the TUI"
