#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
runtime_dir="$test_tmp/run"
mkdir -p "$mock_bin" "$runtime_dir"

cat >"$mock_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'start %s\n' "$*" >>"$TEST_SYSTEMCTL_LOG"
if [[ -n ${TEST_SYSTEMCTL_SLEEP:-} ]]; then
  sleep "$TEST_SYSTEMCTL_SLEEP"
fi
printf 'done %s\n' "$*" >>"$TEST_SYSTEMCTL_LOG"
STUB
chmod +x "$mock_bin/systemctl"

run_use_gtk_chooser() {
  local config_home="$1"
  local log="$2"
  local delay="${3:-}"
  XDG_CONFIG_HOME="$config_home" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$mock_bin:$PATH" TEST_SYSTEMCTL_LOG="$log" TEST_SYSTEMCTL_SLEEP="$delay" \
    python3 - "$ROOT/bin/omarchy-file-select" <<'PY'
import importlib.machinery
import importlib.util
import sys

loader = importlib.machinery.SourceFileLoader("omarchy_file_select", sys.argv[1])
spec = importlib.util.spec_from_loader("omarchy_file_select", loader)
module = importlib.util.module_from_spec(spec)
loader.exec_module(module)
module.use_gtk_chooser()
PY
}

# 1. Commented legacy setting stays commented and does not restart the portal.
cfg="$test_tmp/cfg-comment"
log="$test_tmp/log-comment"
mkdir -p "$cfg/xdg-desktop-portal"
: >"$log"
cat >"$cfg/xdg-desktop-portal/hyprland-portals.conf" <<'CONF'
[preferred]
default=hyprland;gtk
# org.freedesktop.impl.portal.FileChooser=folio;gtk
org.freedesktop.impl.portal.Secret=gnome-keyring
CONF
expected=$(<"$cfg/xdg-desktop-portal/hyprland-portals.conf")
run_use_gtk_chooser "$cfg" "$log"
[[ $(<"$cfg/xdg-desktop-portal/hyprland-portals.conf") == "$expected" ]] ||
  fail "commented FileChooser line must stay untouched" "$(<"$cfg/xdg-desktop-portal/hyprland-portals.conf")"
[[ ! -s $log ]] || fail "commented FileChooser line must not restart the portal" "$(<"$log")"
pass "commented legacy FileChooser line stays commented without restarting the portal"

# 2. Custom FileChooser=folio setting is untouched and does not restart the portal.
cfg="$test_tmp/cfg-custom"
log="$test_tmp/log-custom"
mkdir -p "$cfg/xdg-desktop-portal"
: >"$log"
cat >"$cfg/xdg-desktop-portal/hyprland-portals.conf" <<'CONF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=folio
CONF
expected=$(<"$cfg/xdg-desktop-portal/hyprland-portals.conf")
run_use_gtk_chooser "$cfg" "$log"
[[ $(<"$cfg/xdg-desktop-portal/hyprland-portals.conf") == "$expected" ]] ||
  fail "custom FileChooser=folio line must stay untouched" "$(<"$cfg/xdg-desktop-portal/hyprland-portals.conf")"
[[ ! -s $log ]] || fail "custom FileChooser=folio line must not restart the portal" "$(<"$log")"
pass "custom FileChooser=folio line stays untouched without restarting the portal"

# 3. Exact uncommented legacy line is rewritten to gtk and restarts the portal once.
cfg="$test_tmp/cfg-legacy"
log="$test_tmp/log-legacy"
mkdir -p "$cfg/xdg-desktop-portal"
: >"$log"
cat >"$cfg/xdg-desktop-portal/hyprland-portals.conf" <<'CONF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=folio;gtk
org.freedesktop.impl.portal.Secret=gnome-keyring
CONF
run_use_gtk_chooser "$cfg" "$log"
grep -qx 'org\.freedesktop\.impl\.portal\.FileChooser=gtk' "$cfg/xdg-desktop-portal/hyprland-portals.conf" ||
  fail "legacy FileChooser line is updated to gtk" "$(<"$cfg/xdg-desktop-portal/hyprland-portals.conf")"
(( $(grep -c '^start --user restart xdg-desktop-portal.service$' "$log") == 1 )) ||
  fail "legacy FileChooser repair restarts the portal once" "$(<"$log")"
run_use_gtk_chooser "$cfg" "$log"
(( $(grep -c '^start --user restart xdg-desktop-portal.service$' "$log") == 1 )) ||
  fail "subsequent invocation does not restart the portal again" "$(<"$log")"
pass "exact uncommented legacy line is rewritten to gtk and restarts the portal once"

# 4. Concurrent pickers serialize under the lock, restart only once, and wait until restart finishes.
cfg="$test_tmp/cfg-concurrent"
log="$test_tmp/log-concurrent"
mkdir -p "$cfg/xdg-desktop-portal"
: >"$log"
cat >"$cfg/xdg-desktop-portal/hyprland-portals.conf" <<'CONF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=folio;gtk
CONF

(
  run_use_gtk_chooser "$cfg" "$log" 0.3
  printf 'picker-done\n' >>"$log"
) &
p1=$!
(
  run_use_gtk_chooser "$cfg" "$log" 0.3
  printf 'picker-done\n' >>"$log"
) &
p2=$!
wait "$p1" "$p2"

(( $(grep -c '^start --user restart xdg-desktop-portal.service$' "$log") == 1 )) ||
  fail "concurrent pickers restart the portal only once" "$(<"$log")"
# Both pickers must finish only after the single restart completed.
first_done_line=$(grep -n '^done --user restart xdg-desktop-portal.service$' "$log" | cut -d: -f1)
first_picker_line=$(grep -n '^picker-done$' "$log" | head -n 1 | cut -d: -f1)
(( first_done_line < first_picker_line )) ||
  fail "second concurrent picker must wait until the portal restart completes" "$(<"$log")"
pass "concurrent pickers serialize repair, restart once, and wait for restart completion"
