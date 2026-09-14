#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_dir="$tmpdir/bin"
mkdir -p "$stub_dir"

cat >"$stub_dir/hyprctl" <<'EOF'
#!/bin/bash
if [[ $1 == devices && $2 == -j ]]; then
  cat "$HYPRCTL_DEVICES_JSON"
  exit 0
fi
exit 1
EOF
chmod +x "$stub_dir/hyprctl"

hw_touchscreen() {
  PATH="$stub_dir:$PATH" HYPRCTL_DEVICES_JSON="$tmpdir/devices.json" \
    "$ROOT/bin/omarchy-hw-touchscreen"
}

printf '%s\n' '{"touch":[{"name":"elan9008:00-04f3:4447"},{"name":"elan9009:00-04f3:4448"}],"tablets":[{"name":"elan9008:00-04f3:4447-stylus"}]}' >"$tmpdir/devices.json"
[[ $(hw_touchscreen) == $'elan9008:00-04f3:4447\nelan9009:00-04f3:4448' ]] ||
  fail "every touch digitizer is listed" "$(hw_touchscreen)"
pass "every touch digitizer is listed"

printf '%s\n' '{"touch":[],"tablets":[{"name":"wacom-hid-52eb-pen"}]}' >"$tmpdir/devices.json"
[[ $(hw_touchscreen) == "wacom-hid-52eb-pen" ]] ||
  fail "tablet names are used when no touch devices exist" "$(hw_touchscreen)"
pass "tablet names are used when no touch devices exist"

printf '%s\n' '{"touch":[],"tablets":[]}' >"$tmpdir/devices.json"
if hw_touchscreen >/dev/null 2>&1; then
  fail "no touchscreen device reports failure"
fi
pass "no touchscreen device reports failure"
