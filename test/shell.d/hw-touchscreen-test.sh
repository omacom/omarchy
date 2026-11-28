#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

touchscreen="$ROOT/bin/omarchy-hw-touchscreen"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Hyprland's touch devices and tablets, in its order, from space-separated
# TOUCH and TABLETS.
cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash

jq -n --arg touch "${TOUCH:-}" --arg tablets "${TABLETS:-}" '{
  touch: [$touch | split(" ")[] | select(. != "") | {name: .}],
  tablets: [$tablets | split(" ")[] | select(. != "") | {name: .}]
}'
SH
chmod +x "$stub_bin"/*

detected() {
  TOUCH="$1" TABLETS="${2:-}" PATH="$stub_bin:$PATH" bash "$touchscreen"
}

[[ $(detected "elan-touchscreen") == "elan-touchscreen" ]] ||
  fail "a plain touchscreen is found" "$(detected "elan-touchscreen")"
pass "a plain touchscreen is found"

[[ $(detected "" "wacom-tablet") == "wacom-tablet" ]] ||
  fail "a tablet answers when there is no touchscreen" "$(detected "" "wacom-tablet")"
pass "a tablet answers when there is no touchscreen"

[[ -z $(detected "") ]] || fail "no touchscreen answers with an empty detection" "$(detected "")"
pass "no touchscreen answers with an empty detection"

# iptsd takes a Surface's raw SPI touchscreen and reports touches through its own
# virtual one; the raw one stays silent, so the virtual one is the one to toggle.
for touch in \
  "spi-045e:0c6e-touchscreen iptsd-virtual-touchscreen-045e:0c6e" \
  "iptsd-virtual-touchscreen-045e:0c6e spi-045e:0c6e-touchscreen"; do
  [[ $(detected "$touch" "iptsd-virtual-stylus-045e:0c6e") == "iptsd-virtual-touchscreen-045e:0c6e" ]] ||
    fail "the iptsd virtual touchscreen is preferred over the raw one" "$(detected "$touch")"
done
pass "the iptsd virtual touchscreen is preferred over the raw one"
