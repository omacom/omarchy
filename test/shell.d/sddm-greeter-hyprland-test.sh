#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# SDDM's greeter compositor must wake DPMS on input and reconcile lid/clamshell
# the same way the user session does (issue #10403).

greeter="$ROOT/default/sddm/hyprland.lua"
[[ -f $greeter ]] || fail "packaged SDDM greeter Hyprland config exists"

# Presence of the three session behaviours the greeter was missing.
for needle in \
  'key_press_enables_dpms = true' \
  'mouse_move_enables_dpms = true' \
  'switch:on:Lid Switch' \
  'switch:off:Lid Switch' \
  'omarchy-hyprland-monitor-clamshell'; do
  grep -F "$needle" "$greeter" >/dev/null ||
    fail "SDDM greeter Hyprland config includes $needle"
done
pass "SDDM greeter enables DPMS on input and binds lid to clamshell"

# Must not pull the session lock path into the greeter (comments may name the
# forbidden commands when explaining why they are avoided).
code_only=$(grep -vE '^[[:space:]]*--' "$greeter" || true)
if grep -E 'omarchy-system-lid-close|omarchy-system-lock|omarchy-launch-shell' <<<"$code_only" >/dev/null; then
  fail "SDDM greeter must not lock a session or launch the shell" "$code_only"
fi
pass "SDDM greeter does not lock or launch the session shell"

# Startup must reconcile once so a lid-closed Log Out is not stuck until the
# next physical lid event.
grep -F 'hyprland.start' "$greeter" >/dev/null ||
  fail "SDDM greeter reconciles clamshell on hyprland.start"
pass "SDDM greeter reconciles clamshell on hyprland.start"

# Keep greeter config self-contained: no Omarchy bootstrap (helpers/o.bind).
if grep -E 'require\(|o\.bind|default\.hypr' <<<"$code_only" >/dev/null; then
  fail "SDDM greeter stays free of session bootstrap requires" "$code_only"
fi
pass "SDDM greeter stays free of session bootstrap requires"
