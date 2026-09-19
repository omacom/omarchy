#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helper="$ROOT/bin/omarchy-pkg-linux-headers"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"

cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
if [[ $1 == -Qq && -n ${2:-} ]]; then
  grep -qx "$2" "$TEST_PACMAN_Q" && { printf '%s\n' "$2"; exit 0; }
  exit 1
fi
exit 1
SH
chmod +x "$test_tmp/bin/pacman"

installed() {
  printf '%s\n' "$@" >"$test_tmp/installed"
}

headers() {
  TEST_PACMAN_Q="$test_tmp/installed" PATH="$test_tmp/bin:$PATH" "$helper"
}

installed linux
[[ $(headers) == linux-headers ]] || fail "stock linux selects linux-headers"
pass "stock linux selects linux-headers"

installed linux linux-ptl
[[ $(headers) == linux-ptl-headers ]] || fail "linux-ptl wins over leftover stock linux"
pass "linux-ptl wins over leftover stock linux"

installed linux linux-t2
[[ $(headers) == linux-t2-headers ]] || fail "linux-t2 wins over leftover stock linux"
pass "linux-t2 wins over leftover stock linux"

installed linux-zen
[[ $(headers) == linux-zen-headers ]] || fail "linux-zen selects linux-zen-headers"
pass "linux-zen selects linux-zen-headers"

installed linux-lts linux-hardened
[[ $(headers) == linux-lts-headers ]] || fail "linux-lts is preferred over linux-hardened"
pass "linux-lts is preferred over linux-hardened"

: >"$test_tmp/installed"
[[ $(headers) == linux-headers ]] || fail "no kernel package still names linux-headers"
pass "no kernel package still names linux-headers"

for leaf in \
  install/hardware/nvidia.sh \
  install/hardware/fix-bcm43xx.sh \
  install/hardware/fix-yt6801-ethernet-adapter.sh \
  install/hardware/fix-tuxedo-backlight.sh \
  bin/omarchy-install-gaming-xbox-controllers
do
  grep -q 'omarchy-pkg-linux-headers' "$ROOT/$leaf" ||
    fail "$leaf asks the helper for kernel headers"
  if grep -F 'linux-headers' "$ROOT/$leaf" | grep -vq 'omarchy-pkg-linux-headers'; then
    fail "$leaf does not hardcode linux-headers next to DKMS"
  fi
done
pass "DKMS installers ask the helper instead of hardcoding linux-headers"
