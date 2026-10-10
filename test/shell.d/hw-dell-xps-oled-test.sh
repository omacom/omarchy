#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-dell-xps-oled"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
drm_path="$test_tmp/drm"

cat >"$test_tmp/bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${TEST_PRODUCT_NAME:-} == *"$1"* ]]
SH

cat >"$test_tmp/bin/omarchy-hw-intel-ptl" <<'SH'
#!/bin/bash
(( ${TEST_PTL:-0} == 1 ))
SH

chmod +x "$test_tmp/bin"/*

write_modes() {
  local connector="$1" mode="$2"
  rm -rf "$drm_path"
  mkdir -p "$drm_path/card0-$connector"
  printf '%s\n' "$mode" >"$drm_path/card0-$connector/modes"
}

run_detector() {
  PATH="$test_tmp/bin:$PATH" \
    TEST_PRODUCT_NAME="${1-XPS 14 DA14260}" \
    TEST_PTL="${2-1}" \
    OMARCHY_DRM_PATH="$drm_path" \
    bash "$detector"
}

write_modes eDP-1 2880x1800
run_detector || fail "the detector matches XPS 14 OLED resolution"
pass "the detector matches XPS 14 OLED resolution"

write_modes eDP-1 3200x2000
run_detector "XPS 16 DA16260" || fail "the detector matches XPS 16 OLED resolution"
pass "the detector matches XPS 16 OLED resolution"

# Notebookcheck's XPS 16 IPS is LGD07C7: same manufacturer id 30e4 as the
# 14 OLED (LGD07C6), 1920x1200, 100% sRGB.
write_modes eDP-1 1920x1200
if run_detector; then
  fail "the detector rejects the LG IPS SKU"
fi
pass "the detector rejects the LG IPS SKU"

write_modes eDP-1 2880x1800
if run_detector "ThinkPad X1"; then
  fail "the detector rejects other machines"
fi
pass "the detector rejects other machines"

write_modes eDP-1 2880x1800
if run_detector "XPS 14 DA14260" 0; then
  fail "the detector requires Panther Lake"
fi
pass "the detector requires Panther Lake"

rm -rf "$drm_path"
if run_detector; then
  fail "the detector fails closed without an eDP mode list"
fi
pass "the detector fails closed without an eDP mode list"

write_modes HDMI-A-1 2880x1800
if run_detector; then
  fail "the detector ignores OLED-sized external outputs"
fi
pass "the detector ignores OLED-sized external outputs"
