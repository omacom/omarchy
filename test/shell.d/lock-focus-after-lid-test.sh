#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

clamshell="$ROOT/bin/omarchy-hyprland-monitor-clamshell"
service="$ROOT/shell/plugins/lock/Service.qml"
lock_view="$ROOT/shell/plugins/lock/LockView.qml"

grep -F 'omarchy-hyprland-session-locked' "$clamshell" >/dev/null ||
  fail "clamshell enable_internal consults the session-lock probe"
grep -F 'enable_internal_output' "$clamshell" >/dev/null ||
  fail "clamshell can re-enable the internal panel without reload"
# The locked branch must call enable_internal_output; the unlocked branch keeps reload.
awk '
  /enable_internal\(\)/ { in_fn=1 }
  in_fn {
    print
    if (/^}$/) exit
  }
' "$clamshell" >"$TMPDIR/enable-internal.txt"
grep -F 'omarchy-hyprland-session-locked' "$TMPDIR/enable-internal.txt" >/dev/null ||
  fail "enable_internal checks session lock before reload"
grep -F 'hyprctl reload' "$TMPDIR/enable-internal.txt" >/dev/null ||
  fail "enable_internal still reloads when unlocked"
grep -F 'enable_internal_output' "$TMPDIR/enable-internal.txt" >/dev/null ||
  fail "enable_internal re-enables in place when locked"
pass "clamshell skips hyprctl reload while the session is locked"

grep -F 'screen.name === "FALLBACK"' "$service" >/dev/null ||
  fail "hasRealScreen rejects the Quickshell FALLBACK placeholder"
pass "lock acquire ignores the FALLBACK placeholder screen"

grep -F 'passwordFocusRequest' "$service" >/dev/null ||
  fail "lock service exposes passwordFocusRequest for LockView"
grep -F 'forceLockPasswordFocus()' "$service" >/dev/null ||
  fail "lock service calls forceLockPasswordFocus"
grep -F 'root.forceLockPasswordFocus()' "$service" >/dev/null ||
  fail "onScreensChanged restores password focus"
grep -F 'passwordFocusRequest: root.passwordFocusRequest' "$service" >/dev/null ||
  fail "LockView binds passwordFocusRequest from Service"
grep -F 'onPasswordFocusRequestChanged' "$lock_view" >/dev/null ||
  fail "LockView observes passwordFocusRequest and focuses itself"
# Must not reach into the surface component by id (ReferenceError).
! grep -E 'lockView\.(forcePasswordFocus|forceActiveFocus)' "$service" >/dev/null ||
  fail "Service must not call into lockView across the surface id boundary"
pass "lock restores password focus after wake and screen changes"

grep -E 'focus: true' "$lock_view" >/dev/null ||
  fail "password field requests focus on creation"
pass "password field focuses without requiring a click"
