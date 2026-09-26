#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command sha256sum

helper="$ROOT/install/hardware/apple/brcmfmac-43602.sh"
source "$helper"
[[ $(grep -c '^brcmfmac43602_stable_mac()' "$helper") == 1 ]] || fail "there is one stable-MAC implementation"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export OMARCHY_BRCMFMAC_MACHINE_ID="$test_tmp/machine-id"
export OMARCHY_BRCMFMAC_DMI_PRODUCT="$test_tmp/product"
printf '%s\n' '0123456789abcdef0123456789abcdef' >"$OMARCHY_BRCMFMAC_MACHINE_ID"

for model in MacBookPro13,3 MacBookPro14,2 MacBookPro14,3; do
  printf '%s\n' "$model" >"$OMARCHY_BRCMFMAC_DMI_PRODUCT"
  if [[ $model == "MacBookPro13,3" ]]; then
    expected=02:7a:7d:ca:68:5d
  else
    expected=02:d4:33:4a:68:62
  fi
  actual=$(brcmfmac43602_stable_mac)
  [[ $actual == "$expected" ]] || fail "$model preserves its established salt" "$actual"
  [[ $(brcmfmac43602_stable_mac) == "$actual" ]] || fail "$model fallback is repeatable"
  [[ $actual =~ ^02:([0-9a-f]{2}:){4}[0-9a-f]{2}$ ]] || fail "$model fallback is locally administered and unicast"
  pass "$model preserves the established deterministic local/unicast address"

  printf '%s\n' 'abcdef0123456789abcdef0123456789' >"$OMARCHY_BRCMFMAC_MACHINE_ID"
  other=$(brcmfmac43602_stable_mac)
  [[ $other != "$actual" ]] || fail "$model distinct fixture IDs produce distinct addresses"
  printf '%s\n' '0123456789abcdef0123456789abcdef' >"$OMARCHY_BRCMFMAC_MACHINE_ID"
  [[ $(brcmfmac43602_stable_mac) == "$actual" ]] || fail "$model restoring the same ID preserves identity"
  pass "$model distinguishes IDs but cannot distinguish clones of the same ID"
done

assert_rejected() {
  local label=$1 output
  if output=$(brcmfmac43602_stable_mac); then
    fail "$label must not generate a fallback" "$output"
  fi
  [[ -z $output ]] || fail "$label must not emit a usable-looking MAC" "$output"
  pass "$label is rejected without a MAC"
}

for model in MacBookPro13,3 MacBookPro14,3; do
  printf '%s\n' "$model" >"$OMARCHY_BRCMFMAC_DMI_PRODUCT"
  for invalid in '' ' ' uninitialized 1234 00000000000000000000000000000000 \
    0123456789ABCDEF0123456789ABCDEF 0123456789abcdef0123456789abcdef0 \
    '0123456789abcdef0123456789abcdef ' $'0123456789abcdef\n0123456789abcdef'; do
    printf '%s' "$invalid" >"$OMARCHY_BRCMFMAC_MACHINE_ID"
    assert_rejected "$model invalid machine-id [$invalid]"
  done
  rm -f "$OMARCHY_BRCMFMAC_MACHINE_ID"
  assert_rejected "$model missing machine-id"
done

printf '%s\n' '0123456789abcdef0123456789abcdef' >"$OMARCHY_BRCMFMAC_MACHINE_ID"
mkdir "$test_tmp/bin"
cat >"$test_tmp/bin/sha256sum" <<'SH'
#!/bin/bash
cat >/dev/null
printf '%064d  -\n' 0
exit 42
SH
chmod +x "$test_tmp/bin/sha256sum"
PATH="$test_tmp/bin:$PATH" assert_rejected "hash command failure even with a digest on stdout"
cat >"$test_tmp/bin/sha256sum" <<'SH'
#!/bin/bash
cat >/dev/null
printf 'not-a-digest\n'
SH
PATH="$test_tmp/bin:$PATH" assert_rejected "malformed hash output"
