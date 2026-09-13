#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
drm_path="$test_tmp/drm"

mkdir -p "$stub_bin"

# The monitor list is whatever the test last wrote, so a case reads as the state
# Hyprland would report rather than as a stub rewrite.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

if [[ $1 == "monitors" && $2 == "all" && $3 == "-j" ]]; then
  cat "$OMARCHY_TEST_MONITORS"
else
  exit 1
fi
SH

cp "$ROOT/bin/omarchy-hyprland-monitor-physical" "$stub_bin/"
cp "$ROOT/bin/omarchy-hyprland-monitor-external-active" "$stub_bin/"
chmod +x "$stub_bin"/*

export OMARCHY_TEST_MONITORS="$test_tmp/monitors.json"

write_connectors() {
  rm -rf "$drm_path"
  mkdir -p "$drm_path"

  local connector
  for connector in "$@"; do
    mkdir -p "$drm_path/card1-$connector"
    printf 'connected\n' >"$drm_path/card1-$connector/status"
  done
}

write_monitors() {
  printf '%s' "$1" >"$OMARCHY_TEST_MONITORS"
}

physical_monitors() {
  PATH="$stub_bin:$PATH" OMARCHY_DRM_PATH="$drm_path" \
    "$ROOT/bin/omarchy-hyprland-monitor-physical"
}

external_active() {
  PATH="$stub_bin:$PATH" OMARCHY_DRM_PATH="$drm_path" \
    "$ROOT/bin/omarchy-hyprland-monitor-external-active"
}

# The bug this helper exists for: losing the last enabled monitor makes Hyprland
# bring up a headless output named FALLBACK, which reports disabled:false under a
# name no internal-panel pattern matches. Counting it leaves a laptop whose panel
# was disabled with no way back to a screen.
write_connectors eDP-1 HDMI-A-1
write_monitors '[{"name":"eDP-1","disabled":true},{"name":"FALLBACK","disabled":false}]'

[[ -z $(physical_monitors) ]] || fail "Hyprland's fallback output is not a physical monitor" "$(physical_monitors)"
if external_active; then
  fail "the fallback output does not stand in for the external monitor it replaced"
fi
pass "physical monitor helper ignores Hyprland's fallback output"

# An output created with `hyprctl output create` has no DRM connector either, and
# by the same rule cannot authorize disabling the only real panel.
write_monitors '[{"name":"eDP-1","disabled":false},{"name":"HEADLESS-1","disabled":false}]'

[[ $(physical_monitors) == "eDP-1" ]] || fail "a headless output is not a physical monitor" "$(physical_monitors)"
if external_active; then
  fail "a headless output is not an external display"
fi
pass "physical monitor helper ignores user-created headless outputs"

write_monitors '[{"name":"eDP-1","disabled":false},{"name":"HDMI-A-1","disabled":false}]'

[[ $(physical_monitors) == $'eDP-1\nHDMI-A-1' ]] || fail "both connected panels are physical" "$(physical_monitors)"
external_active || fail "a connected external display is still found"
pass "physical monitor helper finds displays backed by a DRM connector"

write_monitors '[{"name":"eDP-1","disabled":false},{"name":"HDMI-A-1","disabled":true}]'

[[ $(physical_monitors) == "eDP-1" ]] || fail "a disabled monitor is not active" "$(physical_monitors)"
if external_active; then
  fail "an external display disabled on purpose is not active"
fi
pass "physical monitor helper ignores monitors disabled on purpose"

# Mirrors are absent from plain `monitors`, so the helper has to ask for `all`;
# a mirrored external reported there is a real display and still counts.
write_monitors '[{"name":"eDP-1","disabled":false},{"name":"HDMI-A-1","disabled":false,"mirrorOf":"eDP-1"}]'

external_active || fail "a mirrored external display is still active"
pass "physical monitor helper sees mirrors"

# Failing this way round re-enables a panel that did not need it; failing the
# other way leaves the machine with no screen at all.
write_connectors
write_monitors '[{"name":"eDP-1","disabled":false},{"name":"HDMI-A-1","disabled":false}]'

set +e
empty_output=$(physical_monitors 2>"$test_tmp/empty-drm.err")
empty_status=$?
set -e

(( empty_status == 0 )) || fail "an unreadable DRM tree is handled quietly" "$(< "$test_tmp/empty-drm.err")"
[[ -z $empty_output ]] || fail "an unreadable DRM tree reports no physical monitor" "$empty_output"
[[ -z $(< "$test_tmp/empty-drm.err") ]] || fail "an unreadable DRM tree stays silent" "$(< "$test_tmp/empty-drm.err")"
pass "physical monitor helper reports nothing when the DRM tree is unreadable"
