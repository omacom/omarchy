#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
task_tmp=$(mktemp -d)
trap 'rm -rf "$task_tmp"' EXIT
mkdir -p "$task_tmp/bin" "$task_tmp/drm/card0-USB-1"
printf 'connected\n' > "$task_tmp/drm/card0-USB-1/status"
export OMARCHY_DRM_PATH="$task_tmp/drm" LID_CALLS="$task_tmp/calls" LID_MONITORS="$task_tmp/monitors.json"
cat > "$task_tmp/bin/hyprctl" <<'STUB'
#!/bin/bash
[[ ${LID_QUERY_FAIL:-0} == 0 ]] || exit 1
cat "$LID_MONITORS"
STUB
cat > "$task_tmp/bin/omarchy-hw-laptop-closed" <<'STUB'
#!/bin/bash
exit "${LID_IS_OPEN:-0}"
STUB
for helper in omarchy-system-lock omarchy-hyprland-monitor-clamshell; do
  cat > "$task_tmp/bin/$helper" <<STUB
#!/bin/bash
printf '%s\n' '$helper' >> "\$LID_CALLS"
STUB
done
chmod +x "$task_tmp/bin/"*
export PATH="$task_tmp/bin:$ROOT/bin:$PATH"
case_check() {
  local description="$1" json="$2" wanted="$3"
  printf '%s\n' "$json" > "$LID_MONITORS"
  : > "$LID_CALLS"
  "${LID_CLOSE_SCRIPT:-$ROOT/bin/omarchy-system-lid-close}"
  if [[ $wanted == lock ]]; then
    [[ $(head -n1 "$LID_CALLS") == omarchy-system-lock ]] || fail "$description"
  else
    ! grep -q omarchy-system-lock "$LID_CALLS" || fail "$description"
  fi
  [[ $(tail -n1 "$LID_CALLS") == omarchy-hyprland-monitor-clamshell ]] || fail "display reconciliation remains last"
  pass "$description"
}
case_check "raw Touch Bar DRM without a compositor external display does not suppress locking" '[{"name":"eDP-1","disabled":false}]' lock
case_check "disabled external display does not suppress locking" '[{"name":"eDP-1","disabled":false},{"name":"DP-1","disabled":true}]' lock
case_check "active external display preserves clamshell use" '[{"name":"eDP-1","disabled":false},{"name":"DP-1","disabled":false}]' unlocked
case_check "a genuine compositor USB output preserves clamshell use" '[{"name":"USB-1","disabled":false}]' unlocked
LID_IS_OPEN=1 case_check "open lid never triggers locking" '[{"name":"eDP-1","disabled":false}]' unlocked
LID_QUERY_FAIL=1 case_check "failed compositor query errs toward locking a closed laptop" '[]' lock
