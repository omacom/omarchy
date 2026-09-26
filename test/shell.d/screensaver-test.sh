#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command rg

if rg -q 'read -n1 -t 1 \|\| ! screensaver_in_focus' "$ROOT/bin/omarchy-screensaver"; then
  fail "screensaver does not treat the first unfocused poll as dismissal"
fi
grep -Fq 'read -n1 -t 1 || screensaver_lost_focus' "$ROOT/bin/omarchy-screensaver" ||
  fail "screensaver watchdog dismisses through screensaver_lost_focus"
grep -Fq 'omarchy-launch-screensaver --idle' "$ROOT/shell/plugins/services/idle/Service.qml" ||
  fail "idle cycle launches the screensaver with --idle"
grep -Fq 'omarchy-screensaver --idle' "$ROOT/bin/omarchy-launch-screensaver" ||
  fail "screensaver launcher forwards --idle"
pass "screensaver does not treat the first unfocused poll as dismissal"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
window_file="$test_tmp/window.json"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == activewindow && $2 == -j ]]; then
  cat "$HYPRCTL_WINDOW"
  exit 0
fi
exit 0
SH
chmod +x "$mock_bin/hyprctl"

write_window() {
  printf '{"class":"%s"}\n' "$1" >"$window_file"
}

export PATH="$mock_bin:$PATH"
export HYPRCTL_WINDOW="$window_file"
source "$ROOT/bin/omarchy-screensaver"

write_window foot
screensaver_seen_focus=0
if screensaver_lost_focus; then
  fail "screensaver stays up before it has been focused"
fi
if screensaver_lost_focus; then
  fail "screensaver stays up across repeated unfocused polls before first focus"
fi
pass "screensaver stays up before it has been focused"

write_window org.omarchy.screensaver
if screensaver_lost_focus; then
  fail "screensaver stays up once it is focused"
fi
(( screensaver_seen_focus == 1 )) || fail "screensaver records that it has been focused"
pass "screensaver stays up once it is focused"

write_window foot
if screensaver_lost_focus; then
  pass "screensaver dismisses after losing focus"
else
  fail "screensaver dismisses after losing focus"
fi

write_window foot
screensaver_seen_focus=0
screensaver_unfocused_polls=0
screensaver_idle=0
gave_up=0
for ((i = 0; i < screensaver_unfocused_limit; i++)); do
  if screensaver_lost_focus; then
    gave_up=1
    break
  fi
done
((gave_up == 1)) || fail "manual screensaver gives up when it never receives focus"
pass "manual screensaver gives up when it never receives focus"

write_window foot
screensaver_seen_focus=0
screensaver_unfocused_polls=0
screensaver_idle=1
for ((i = 0; i < screensaver_unfocused_limit + 2; i++)); do
  if screensaver_lost_focus; then
    fail "idle screensaver keeps waiting for focus"
  fi
done
pass "idle screensaver keeps waiting for focus"
