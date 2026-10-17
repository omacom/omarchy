#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

cat >"$tmpdir/hyprctl" <<'BASH'
#!/bin/bash

if [[ $1 == "activewindow" && $2 == "-j" ]]; then
  [[ -n ${HYPR_FULLSCREEN:-} ]] || exit 1
  printf '{"fullscreen":%s}\n' "$HYPR_FULLSCREEN"
  exit 0
fi

if [[ $1 == "dispatch" ]]; then
  printf 'dispatch %s\n' "$2" >>"$LAUNCH_LOG"
  exit 0
fi

exit 1
BASH

cat >"$tmpdir/omarchy-cmd-default-browser" <<'BASH'
#!/bin/bash
echo chromium.desktop
BASH

cat >"$tmpdir/omarchy-cmd-browser-handoff" <<'BASH'
#!/bin/bash
printf 'launch %s\n' "$2" >>"$LAUNCH_LOG"
BASH

chmod +x "$tmpdir"/*

log="$tmpdir/launch.log"

launch_with_fullscreen() {
  : >"$log"
  PATH="$tmpdir:$PATH" LAUNCH_LOG="$log" HYPR_FULLSCREEN="$1" \
    "$ROOT/bin/omarchy-launch-webapp" https://example.com
}

# on_focus_under_fullscreen would hand a fullscreen window's state to the web app.
for state in 2 3; do
  launch_with_fullscreen "$state"
  [[ $(<"$log") == $'dispatch hl.dsp.window.fullscreen_state({ internal = 0, client = 0 })\nlaunch --app=https://example.com' ]] ||
    fail "launch-webapp clears fullscreen state $state before launching"
done
pass "launch-webapp clears fullscreen before launching"

# Maximized, not fullscreen, or no compositor to ask: launch without touching it.
for state in 1 0 ""; do
  launch_with_fullscreen "$state"
  [[ $(<"$log") == "launch --app=https://example.com" ]] ||
    fail "launch-webapp leaves fullscreen state '$state' alone"
done
pass "launch-webapp leaves maximized and windowed apps alone"

# Learn -> Omarchy still routes through the webapp launcher.
grep -q "omarchy-launch-webapp 'https://omarchy.org/manual/'" \
  "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "Learn -> Omarchy still uses omarchy-launch-webapp"
pass "Learn -> Omarchy still uses omarchy-launch-webapp"
