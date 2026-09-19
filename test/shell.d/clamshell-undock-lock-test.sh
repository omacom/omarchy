#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

clamshell="$ROOT/bin/omarchy-hyprland-monitor-clamshell"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# closed/docked/external_active are exit codes for the hw and Hyprland helpers
# (0 = yes). Record whether clamshell asked for a lock.
setup_scenario() {
  scenario_dir="$tmpdir/$1"
  mock_bin="$scenario_dir/bin"
  call_log="$scenario_dir/calls"
  mkdir -p "$mock_bin" "$scenario_dir/home/.local/state/omarchy/toggles/hypr" \
    "$scenario_dir/home/.config/hypr"
  : >"$call_log"

  local closed="$2" docked="$3" external_active="$4"

  cat >"$mock_bin/omarchy-hw-laptop-closed" <<SH
#!/bin/bash
exit $closed
SH
  cat >"$mock_bin/omarchy-hw-external-monitors" <<SH
#!/bin/bash
exit $docked
SH
  cat >"$mock_bin/omarchy-hw-clamshell" <<'SH'
#!/bin/bash
omarchy-hw-laptop-closed && omarchy-hw-external-monitors
SH
  cat >"$mock_bin/omarchy-hyprland-monitor-external-active" <<SH
#!/bin/bash
exit $external_active
SH
  cat >"$mock_bin/omarchy-hyprland-monitor-laptop" <<'SH'
#!/bin/bash
echo eDP-1
SH
  cat >"$mock_bin/omarchy-hyprland-monitor-internal" <<'SH'
#!/bin/bash
exit 0
SH
  cat >"$mock_bin/omarchy-hyprland-monitor-internal-mirror" <<'SH'
#!/bin/bash
exit 0
SH
  cat >"$mock_bin/omarchy-system-lock" <<'SH'
#!/bin/bash
echo omarchy-system-lock >>"$CALL_LOG"
SH
  cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
exit 0
SH

  chmod +x "$mock_bin"/*
}

run_clamshell() {
  CALL_LOG="$call_log" \
    HOME="$scenario_dir/home" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$clamshell"
  mapfile -t calls <"$call_log"
}

# Closed lid + last external gone: must lock (the #9301 gap).
setup_scenario undocked_closed 0 1 1
run_clamshell

[[ ${calls[*]} == *omarchy-system-lock* ]] ||
  fail "closed lid with no external locks during clamshell reconcile" "calls: ${calls[*]}"
pass "closed lid with no external locks during clamshell reconcile"

# Still docked (clamshell in use): must not lock.
setup_scenario docked_closed 0 0 0
run_clamshell

[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "docked clamshell does not lock" "calls: ${calls[*]}"
pass "docked clamshell does not lock"

# Lid open, no external: never lock from clamshell.
setup_scenario open_undocked 1 1 1
run_clamshell

[[ ${calls[*]} != *omarchy-system-lock* ]] ||
  fail "open lid does not lock from clamshell" "calls: ${calls[*]}"
pass "open lid does not lock from clamshell"
