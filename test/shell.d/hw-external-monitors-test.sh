#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

drm_path="$test_tmp/drm"

write_connectors() {
  rm -rf "$drm_path"
  mkdir -p "$drm_path"

  local connector state
  while (( $# )); do
    connector="$1"
    state="$2"
    mkdir -p "$drm_path/card0-$connector"
    printf '%s\n' "$state" >"$drm_path/card0-$connector/status"
    shift 2
  done
}

# A copy of the pattern helper reads its platform file from a fixture root
# (none unless a case writes one).
platform_root="$test_tmp/platform"
mkdir -p "$platform_root" "$test_tmp/bin"
platform_root_copy "$ROOT/bin/omarchy-hw-display-builtin-pattern" \
  "$test_tmp/bin/omarchy-hw-display-builtin-pattern" "$platform_root"

has_external_monitor() {
  OMARCHY_DRM_PATH="$drm_path" PATH="$test_tmp/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-hw-external-monitors"
}

write_connectors
set +e
empty_error=$(has_external_monitor 2>&1 >/dev/null)
empty_status=$?
set -e

(( empty_status != 0 )) || fail "an empty DRM tree has no external display"
[[ -z $empty_error ]] || fail "an empty DRM tree is handled quietly" "$empty_error"
pass "physical monitor detection handles an empty DRM tree"

for connector in eDP-1 LVDS-1 DSI-1; do
  write_connectors "$connector" connected

  if has_external_monitor; then
    fail "$connector is treated as an internal display"
  fi
done
pass "physical monitor detection ignores common internal panel connectors"

write_connectors LVDS-1 connected DP-1 connected
has_external_monitor || fail "external display is found alongside an LVDS panel"
pass "physical monitor detection finds an external display alongside an LVDS panel"

write_connectors eDP-1 connected HDMI-A-1 disconnected
if has_external_monitor; then
  fail "a disconnected external display is not reported as connected"
fi
pass "physical monitor detection ignores disconnected external displays"

write_connectors DP-1 connected
has_external_monitor || fail "external-only systems still report a connected display"
pass "physical monitor detection still supports external-only systems"

# A panel on a firmware framebuffer is an Unknown connector: external until
# the platform names it, then built in, on any card.
write_connectors Unknown-1 connected
has_external_monitor || fail "an unnamed Unknown connector counts as external"
printf 'builtin-connector Unknown-1\n' >"$platform_root/displays.conf"
if has_external_monitor; then
  fail "a platform-named built-in connector is not an external display"
fi
write_connectors Unknown-1 connected DP-1 connected
has_external_monitor || fail "external display is found alongside a platform-named panel"
write_connectors Unknown-1 connected Unknown-2 connected
has_external_monitor || fail "only the named connector is built in"
rm -f "$platform_root/displays.conf"
pass "physical monitor detection honours a platform-named built-in connector"
