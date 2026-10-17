#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
toggle_log="$tmpdir/toggle.log"
notification_log="$tmpdir/notification.log"
mkdir -p "$stub_dir"

cat >"$stub_dir/hyprctl" <<'STUB'
#!/bin/bash

if [[ $1 == "activeworkspace" ]]; then
  case ${HYPR_LAYOUT:-dwindle} in
    broken) printf '{}\n' ;;
    *) printf '{"tiledLayout":"%s"}\n' "$HYPR_LAYOUT" ;;
  esac
fi
STUB
chmod +x "$stub_dir/hyprctl"

cat >"$stub_dir/omarchy-hyprland-toggle-disabled" <<'STUB'
#!/bin/bash
[[ $1 == "single-window-aspect-ratio" ]] || exit 1
[[ ${TOGGLE_ENABLED:-false} != "true" ]]
STUB
chmod +x "$stub_dir/omarchy-hyprland-toggle-disabled"

cat >"$stub_dir/omarchy-hyprland-toggle" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TOGGLE_LOG"
printf '%s\n' "${TOGGLE_RESULT:-on}"
STUB
chmod +x "$stub_dir/omarchy-hyprland-toggle"

cat >"$stub_dir/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFICATION_LOG"
STUB
chmod +x "$stub_dir/omarchy-notification-send"

run_toggle() {
  : >"$toggle_log"
  : >"$notification_log"

  HYPR_LAYOUT="$1" \
    TOGGLE_RESULT="${2:-on}" \
    TOGGLE_ENABLED="${3:-false}" \
    TOGGLE_LOG="$toggle_log" \
    NOTIFICATION_LOG="$notification_log" \
    PATH="$stub_dir:$PATH" \
    "$ROOT/bin/omarchy-hyprland-window-single-square-aspect-toggle"
}

run_toggle scrolling

[[ ! -s $toggle_log ]] ||
  fail "single-window aspect stays disabled on scrolling workspaces"
grep -F "Single-window square aspect does not apply to scrolling workspaces" "$notification_log" >/dev/null ||
  fail "single-window aspect explains why it is unavailable on scrolling workspaces"
pass "single-window aspect stays disabled with feedback on scrolling workspaces"

run_toggle scrolling off true

grep -Fx "single-window-aspect-ratio" "$toggle_log" >/dev/null ||
  fail "single-window aspect can be disabled from a scrolling workspace"
grep -F "Disable single-window square aspect ratio" "$notification_log" >/dev/null ||
  fail "single-window aspect reports disabling from a scrolling workspace"
pass "single-window aspect disables from a scrolling workspace"

run_toggle dwindle on

grep -Fx "single-window-aspect-ratio" "$toggle_log" >/dev/null ||
  fail "single-window aspect toggles on dwindle workspaces"
grep -F "Enable single-window square aspect ratio" "$notification_log" >/dev/null ||
  fail "single-window aspect reports enabling on dwindle workspaces"
pass "single-window aspect enables on dwindle workspaces"

run_toggle dwindle off

grep -F "Disable single-window square aspect ratio" "$notification_log" >/dev/null ||
  fail "single-window aspect reports disabling on dwindle workspaces"
pass "single-window aspect disables on dwindle workspaces"

run_toggle master on

grep -Fx "single-window-aspect-ratio" "$toggle_log" >/dev/null ||
  fail "single-window aspect toggles on master workspaces"
grep -F "Enable single-window square aspect ratio" "$notification_log" >/dev/null ||
  fail "single-window aspect reports enabling on master workspaces"
pass "single-window aspect enables on master workspaces"

if run_toggle broken; then
  fail "single-window aspect fails when workspace layout is unavailable"
fi

[[ ! -s $toggle_log ]] ||
  fail "single-window aspect does not toggle when workspace layout is unavailable"
[[ ! -s $notification_log ]] ||
  fail "single-window aspect does not report success when workspace layout is unavailable"
pass "single-window aspect fails safely when workspace layout is unavailable"
