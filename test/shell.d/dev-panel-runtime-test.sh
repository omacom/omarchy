#!/bin/bash

# omarchy-dev-panel-capture and -tree against a real shell: the agents panel,
# fed one fake Claude record, is captured at the screen's pixels and at twice
# them, twice at once, and described from its scene; the clock panel, behind a
# Loader, is reached too.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=""
QS_PID=""

cleanup() {
  if [[ -n $QS_PID ]] && kill -0 "$QS_PID" 2>/dev/null; then
    # The shell's own processes, such as the plugin registry's inotifywait,
    # outlive it otherwise.
    pkill -P "$QS_PID" 2>/dev/null || true
    kill "$QS_PID" 2>/dev/null || true
    wait "$QS_PID" 2>/dev/null || true
  fi
  [[ -n ${test_root:-} ]] && rm -f "$(shell_ipc_socket "$test_root")"
  if [[ -n $TMPDIR && -d $TMPDIR ]]; then
    rm -rf "$TMPDIR"
  fi
}
trap cleanup EXIT

require_compositor "dev panel runtime test"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping dev panel runtime test"
  exit 0
fi

require_command hyprctl
require_command jq
require_command python3

TMPDIR=$(mktemp -d)
test_root="$TMPDIR/omarchy"
test_home="$TMPDIR/home"
stub_bin="$TMPDIR/bin"
log="$TMPDIR/quickshell.log"
usage_dir="$test_home/.local/state/omarchy/agents/usage"
mkdir -p "$test_root" "$stub_bin" "$usage_dir"
cp -a "$ROOT/shell" "$test_root/shell"
ln -s "$ROOT/config" "$test_root/config"
ln -s "$ROOT/bin" "$test_root/bin"

# Nothing may refresh the fake record or reach a real account.
for stub in omarchy-agent-usage-update omarchy-agent-account-state omarchy-launch-browser omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$stub"
  chmod +x "$stub_bin/$stub"
done

jq -n --arg s "$(date -u -d '+3 hours' +%Y-%m-%dT%H:%M:%SZ)" --arg w "$(date -u -d '+4 days' +%Y-%m-%dT%H:%M:%SZ)" '{
  schemaVersion: 1, id: "claude", name: "Claude Code", ready: true, hasLocalStats: true,
  todayPrompts: 72, todaySessions: 4, todayTotalTokens: 7435245, activeDays: 41,
  tierLabel: "Max 20x",
  limits: [
    {label: "Session (5-hour)", percent: 0.23, resetsAt: $s},
    {label: "Weekly (7-day)", percent: 0.41, resetsAt: $w}
  ],
  usageStatusText: "", authHelpText: ""
}' >"$usage_dir/claude.json"

fail_with_log() {
  sed -n '1,220p' "$log" >&2
  fail "$1"
}

dev_panel() {
  local command=$1
  shift
  OMARCHY_PATH="$test_root" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-dev-panel-$command" "$@"
}

png_size() {
  python3 -c 'import struct, sys; d = open(sys.argv[1], "rb").read(24); print(*struct.unpack(">II", d[16:24]))' "$1"
}

OMARCHY_PATH="$test_root" \
HOME="$test_home" \
XDG_CONFIG_HOME="$test_home/.config" \
XDG_CACHE_HOME="$test_home/.cache" \
XDG_STATE_HOME="$test_home/.local/state" \
PATH="$stub_bin:$ROOT/bin:$PATH" \
  quickshell -p "$test_root/shell" --no-color >"$log" 2>&1 &
QS_PID=$!

for _ in {1..80}; do
  OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" -q shell ping >/dev/null 2>&1 && break
  kill -0 "$QS_PID" 2>/dev/null || fail_with_log "dev panel test shell exited before IPC became available"
  sleep 0.1
done

# The plugin registry loads the bar's plugins after IPC is up.
for _ in {1..50}; do
  tree=$(dev_panel tree --json omarchy.agents 2>/dev/null) && break
  sleep 0.2
done
[[ -n $tree ]] || fail_with_log "panel tree describes the open agents panel"
jq -e '[.. | .text? // empty] | index("Max 20x") != null' <<<"$tree" >/dev/null ||
  fail "the agents panel tree shows the fake record's plan" "$tree"
pass "panel tree --json reads the agents panel from its scene"

card_width=$(jq .w <<<"$tree")
dev_panel capture omarchy.agents "$TMPDIR/one.png" >/dev/null || fail_with_log "panel capture saves the agents panel"
dev_panel capture --scale 2 omarchy.agents "$TMPDIR/two.png" >/dev/null || fail_with_log "panel capture saves the agents panel at scale 2"
read -r one_width _ < <(png_size "$TMPDIR/one.png")
read -r two_width _ < <(png_size "$TMPDIR/two.png")

# The default capture is the card at the screen's own pixels: its width over the
# card's logical width is some monitor's scale, not that scale squared.
hyprctl -j monitors | jq -e --argjson png "$one_width" --argjson card "$card_width" '
  any(.[]; ($png - $card * .scale) | fabs <= 2)' >/dev/null ||
  fail "a default capture is the card at the screen's pixels" "png $one_width, card $card_width, scales $(hyprctl -j monitors | jq -c 'map(.scale)')"
pass "a default capture is the card at the screen's pixels"

(( two_width >= 2 * one_width - 2 && two_width <= 2 * one_width + 2 )) ||
  fail "a capture at scale 2 is twice the default" "one $one_width, two $two_width"
pass "a capture at scale 2 is twice the default"

# Two captures asked for at once each get their own PNG.
dev_panel capture omarchy.agents "$TMPDIR/a.png" >/dev/null &
first=$!
dev_panel capture omarchy.agents "$TMPDIR/b.png" >/dev/null || fail_with_log "the second of two overlapping captures is saved"
wait "$first" || fail_with_log "the first of two overlapping captures is saved"
pass "overlapping captures each save their own PNG"

# The clock widget loads its panel through a Loader, which parents the panel
# to itself, so the card is among the Loader's data like any other.
clock_tree=$(dev_panel tree --json omarchy.clock) || fail_with_log "panel tree describes the clock panel, which a Loader loads"
jq -e '.w > 0 and (.children | length) > 0' <<<"$clock_tree" >/dev/null || fail "the clock panel tree has items" "$clock_tree"
dev_panel capture omarchy.clock "$TMPDIR/clock.png" >/dev/null || fail_with_log "panel capture saves the clock panel"
pass "panel tree and capture reach a panel a Loader loads"

# Opening the clock closed the agents panel. Opened again and captured at once,
# it's given time to settle; once it has, a capture doesn't wait. The margin is
# relative because the shell's timers run on its animation clock, which can
# run ahead of the wall clock.
capture_ms() {
  local start=${EPOCHREALTIME/./}
  dev_panel capture omarchy.agents "$1" >/dev/null || fail_with_log "panel capture saves the agents panel to $1"
  echo $(( (${EPOCHREALTIME/./} - start) / 1000 ))
}
OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" shell summon omarchy.agents "{}" >/dev/null || fail_with_log "the agents panel opens again"
just_opened=$(capture_ms "$TMPDIR/just-opened.png")
sleep 0.5
settled=$(capture_ms "$TMPDIR/settled.png")
(( just_opened > settled + 80 && settled < 300 )) ||
  fail "a capture waits only for a panel that just opened" "just opened ${just_opened}ms, open a while ${settled}ms"
pass "a capture waits for a panel that just opened to settle, and not for one open a while"

# The menu is a plugin, but no bar panel: it's refused up front rather than
# opened with nothing to capture.
if dev_panel capture omarchy.menu "$TMPDIR/menu.png" 2>"$TMPDIR/menu.err"; then fail "panel capture refuses a plugin that isn't a bar panel"; fi
grep -q "No bar panel for omarchy.menu" "$TMPDIR/menu.err" || fail "panel capture says the menu is no bar panel" "$(cat "$TMPDIR/menu.err")"
[[ $(OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" shell debugPanelTree omarchy.menu) == "unknown" ]] || fail "panel tree refuses a plugin that isn't a bar panel"
pass "a plugin that isn't a bar panel is refused, not opened"

[[ $(OMARCHY_PATH="$test_root" "$ROOT/bin/omarchy-shell" shell debugReload) == "ok" ]] || fail_with_log "a shell with its file watcher on reloads on request"
for _ in {1..50}; do
  (( $(grep -c "Configuration Loaded" "$log") >= 2 )) && break
  sleep 0.1
done
(( $(grep -c "Configuration Loaded" "$log") >= 2 )) || fail_with_log "the shell loads its config again after a reload"
pass "the reload IPC loads the config again"
