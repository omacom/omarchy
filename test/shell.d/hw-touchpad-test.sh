#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
devices_json="$tmp_dir/devices.json"
mkdir -p "$stub_bin"

cat >"$stub_bin/hyprctl" <<EOF
#!/bin/bash
if [[ \$1 == devices && \$2 == -j ]]; then
  cat "$devices_json"
  exit 0
fi
exit 1
EOF
chmod +x "$stub_bin/hyprctl"

hw_touchpad() {
  PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-hw-touchpad"
}

write_devices() {
  cat >"$devices_json"
}

write_devices <<'JSON'
{
  "mice": [
    {"name": "elan-internal-touchpad"}
  ],
  "touch": [],
  "tablets": []
}
JSON
device=$(hw_touchpad)
[[ $device == "elan-internal-touchpad" ]] || fail "a lone laptop touchpad is used" "actual: $device"
pass "a lone laptop touchpad is used"

write_devices <<'JSON'
{
  "mice": [
    {"name": "elan9008:00-04f3:4447-touchpad"},
    {"name": "elan9009:00-04f3:4448-touchpad"},
    {"name": "asus-zenbook-duo-keyboard-mouse"},
    {"name": "asus-zenbook-duo-keyboard-touchpad"}
  ],
  "touch": [
    {"name": "elan9008:00-04f3:4447"},
    {"name": "elan9009:00-04f3:4448"}
  ],
  "tablets": [
    {"name": "elan9008:00-04f3:4447-stylus"},
    {"name": "elan9009:00-04f3:4448-stylus"}
  ]
}
JSON
device=$(hw_touchpad)
[[ $device == "asus-zenbook-duo-keyboard-touchpad" ]] ||
  fail "a keyboard cover trackpad wins over screen digitizers" "actual: $device"
pass "a keyboard cover trackpad wins over screen digitizers"

write_devices <<'JSON'
{
  "mice": [
    {"name": "elan9008:00-04f3:4447-touchpad"},
    {"name": "elan9009:00-04f3:4448-touchpad"}
  ],
  "touch": [
    {"name": "elan9008:00-04f3:4447"},
    {"name": "elan9009:00-04f3:4448"}
  ],
  "tablets": []
}
JSON
if hw_touchpad >/dev/null 2>&1; then
  fail "screen digitizers alone are not a trackpad"
fi
pass "screen digitizers alone are not a trackpad"

write_devices <<'JSON'
{
  "mice": [
    {"name": "elan-internal-touchpad"},
    {"name": "logitech-keyboard-touchpad"}
  ],
  "touch": [],
  "tablets": []
}
JSON
device=$(hw_touchpad)
[[ $device == "elan-internal-touchpad" ]] ||
  fail "an internal pad still wins when a keyboard pad is also present" "actual: $device"
pass "an internal pad still wins when a keyboard pad is also present"

write_devices <<'JSON'
{
  "mice": [
    {"name": "apple-inc.-magic-trackpad"}
  ],
  "touch": [],
  "tablets": []
}
JSON
device=$(hw_touchpad)
[[ $device == "apple-inc.-magic-trackpad" ]] || fail "a trackpad name is used" "actual: $device"
pass "a trackpad name is used"

write_devices <<'JSON'
{
  "mice": [
    {"name": "tk-ms317-5.0"}
  ],
  "touch": [],
  "tablets": []
}
JSON
if hw_touchpad >/dev/null 2>&1; then
  fail "a plain mouse is not a trackpad"
fi
pass "a plain mouse is not a trackpad"
