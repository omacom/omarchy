#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
nm_dir="$test_tmp/nm"
udev_dir="$test_tmp/udev"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-hw-aarch64-qualcomm" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-hw-match" <<'SH'
#!/bin/bash
[[ ${1:-} == "UX3480QA" ]]
SH
chmod +x "$mock_bin/omarchy-hw-aarch64-qualcomm" "$mock_bin/omarchy-hw-match"

PATH="$mock_bin:$ROOT/bin:$PATH" \
  OMARCHY_ZENBOOK_UX3480QA_NM_CONF_DIR="$nm_dir" \
  OMARCHY_ZENBOOK_UX3480QA_UDEV_RULES_DIR="$udev_dir" \
  bash -eE -c 'source "$1"' bash "$ROOT/install/hardware/asus/fix-asus-zenbook-14-ux3480qa-power.sh"

rules="$udev_dir/90-asus-zenbook-14-ux3480qa-power.rules"
[[ -f $rules ]] || fail "UX3480QA power script must write 90-asus-zenbook-14-ux3480qa-power.rules"
grep -qF 'KERNEL=="a200000.usb", DRIVER=="dwc3-qcom"' "$rules" ||
  fail "rules must target internal a200000.usb controller" "$(cat "$rules")"
grep -qF 'KERNELS=="a200000.usb", DRIVER=="xhci-hcd"' "$rules" ||
  fail "rules must scope xhci-hcd runtime PM to a200000.usb child" "$(cat "$rules")"
grep -qF 'ATTR{power/wakeup}="disabled"' "$rules" ||
  fail "rules must disable wakeup on a200000.usb" "$(cat "$rules")"
! grep -qE 'qcom-qmp-combo-phy|qcom-qmp-usb-phy|autosuspend_delay_ms' "$rules" ||
  fail "rules must not enable runtime PM on Purwa external USB3 controllers or QMP PHYs" "$(cat "$rules")"
pass "UX3480QA power rules scope runtime PM and wakeup disable to internal a200000.usb only"
