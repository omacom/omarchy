#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/install/hardware/apple/touchid-eligibility"
[[ -x $script ]] || fail "touchid-eligibility is executable"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin"
printf '%s\n' '#!/bin/bash' 'exit 0' >"$tmp/bin/omarchy-hw-apple-silicon"
chmod +x "$tmp/bin/omarchy-hw-apple-silicon"

write_board() {
  local chip=$1
  rm -rf "$tmp/tree"
  mkdir -p "$tmp/tree/soc/spi@1/fingerprint@0" "$tmp/tree/chosen"
  printf '%s\0%s\0' "apple,j313" "$chip" >"$tmp/tree/compatible"
  printf 'apple,mesa-fingerprint\0' >"$tmp/tree/soc/spi@1/fingerprint@0/compatible"
  printf 'okay\0' >"$tmp/tree/soc/spi@1/fingerprint@0/status"
}

eligibility() {
  PATH="$tmp/bin:$PATH" \
    OMARCHY_MAC_TOUCHID_TREE="$tmp/tree" \
    OMARCHY_MAC_TOUCHID_SEP_BIO="$tmp/sep-bio" \
    "$script"
}

write_board apple,t8103
rm -f "$tmp/sep-bio"
[[ $(eligibility) == available ]] || fail "an M1 sensor without sep-bio is available" "$(eligibility)"
pass "an M1 sensor without sep-bio is available"

: >"$tmp/sep-bio"
[[ $(eligibility) == ready ]] || fail "an M1 sensor with sep-bio is ready" "$(eligibility)"
[[ $(eligibility) != unsupported:m1-family ]] || fail "an M1 is not reported unsupported:m1-family"
pass "an M1 sensor with sep-bio is ready"

write_board apple,t6000
[[ $(eligibility) == ready ]] || fail "an M1 Pro sensor with sep-bio is ready" "$(eligibility)"
pass "an M1 Pro sensor with sep-bio is ready"

write_board apple,t6001
rm -f "$tmp/sep-bio"
[[ $(eligibility) == available ]] || fail "an M1 Max sensor without sep-bio is available" "$(eligibility)"
pass "an M1 Max sensor without sep-bio is available"

rm -rf "$tmp/tree/soc"
[[ $(eligibility) == none ]] || fail "no sensor node is none" "$(eligibility)"
pass "no sensor node is none"

write_board apple,t9999
[[ $(eligibility) == unsupported:board ]] || fail "an unknown board stays unsupported:board" "$(eligibility)"
pass "an unknown board stays unsupported:board"
