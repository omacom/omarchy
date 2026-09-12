#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home"

for command in omarchy-pkg-add omarchy-pkg-drop omarchy-install-gaming-gpu-lib32 setsid; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
done

cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_UFW_MISSING:-0} == "1" ]]
SH

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/ip" <<'SH'
#!/bin/bash
[[ ${OMARCHY_TEST_TAILSCALE:-0} == "1" ]]
SH

chmod +x "$mock_bin"/*

export HOME="$test_home"
export OMARCHY_TEST_LOG="$test_tmp/ufw.log"
export PATH="$mock_bin:$PATH"

expect_logged() {
  local line="$1"
  local message="$2"

  grep -Fxq "$line" "$OMARCHY_TEST_LOG" || fail "$message" "$(<"$OMARCHY_TEST_LOG")"
}

: >"$OMARCHY_TEST_LOG"
bash "$ROOT/bin/omarchy-install-gaming-steam" >/dev/null

for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
  expect_logged "sudo:ufw allow in proto udp from $cidr to any port 27031:27036 comment omarchy-steam" \
    "install opens the Remote Play UDP range for $cidr"
  expect_logged "sudo:ufw allow in proto tcp from $cidr to any port 27036 comment omarchy-steam" \
    "install opens the Remote Play TCP port for $cidr"
  expect_logged "sudo:ufw allow in proto udp from $cidr to any port 10400:10401 comment omarchy-steam" \
    "install opens the Steam Link VR UDP ports for $cidr"
done
if grep -q 'tailscale0' "$OMARCHY_TEST_LOG"; then
  fail "install skips the Tailscale rules when tailscale0 is absent" "$(<"$OMARCHY_TEST_LOG")"
fi
expect_logged "sudo:ufw reload" "install reloads UFW after adding rules"
pass "install opens Steam Remote Play ports for private LANs"

: >"$OMARCHY_TEST_LOG"
OMARCHY_TEST_TAILSCALE=1 bash "$ROOT/bin/omarchy-install-gaming-steam" >/dev/null
expect_logged "sudo:ufw allow in on tailscale0 to any port 27031:27036 proto udp comment omarchy-steam" \
  "install opens the Remote Play UDP range on tailscale0"
expect_logged "sudo:ufw allow in on tailscale0 to any port 27036 proto tcp comment omarchy-steam" \
  "install opens the Remote Play TCP port on tailscale0"
expect_logged "sudo:ufw allow in on tailscale0 to any port 10400:10401 proto udp comment omarchy-steam" \
  "install opens the Steam Link VR UDP ports on tailscale0"
pass "install opens Steam Remote Play ports on Tailscale when present"

: >"$OMARCHY_TEST_LOG"
OMARCHY_TEST_UFW_MISSING=1 bash "$ROOT/bin/omarchy-install-gaming-steam" >/dev/null
if grep -q '^sudo:ufw' "$OMARCHY_TEST_LOG"; then
  fail "install skips firewall rules when UFW is not installed" "$(<"$OMARCHY_TEST_LOG")"
fi
pass "install skips firewall rules when UFW is not installed"

: >"$OMARCHY_TEST_LOG"
bash "$ROOT/bin/omarchy-remove-gaming-steam" >/dev/null
for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
  expect_logged "sudo:ufw --force delete allow in proto udp from $cidr to any port 27031:27036" \
    "remove closes the Remote Play UDP range for $cidr"
  expect_logged "sudo:ufw --force delete allow in proto tcp from $cidr to any port 27036" \
    "remove closes the Remote Play TCP port for $cidr"
  expect_logged "sudo:ufw --force delete allow in proto udp from $cidr to any port 10400:10401" \
    "remove closes the Steam Link VR UDP ports for $cidr"
done
expect_logged "sudo:ufw --force delete allow in on tailscale0 to any port 27031:27036 proto udp" \
  "remove closes the Remote Play UDP range on tailscale0"
expect_logged "sudo:ufw --force delete allow in on tailscale0 to any port 27036 proto tcp" \
  "remove closes the Remote Play TCP port on tailscale0"
expect_logged "sudo:ufw --force delete allow in on tailscale0 to any port 10400:10401 proto udp" \
  "remove closes the Steam Link VR UDP ports on tailscale0"
expect_logged "sudo:ufw reload" "remove reloads UFW after deleting rules"
pass "remove closes the Omarchy-managed Steam Remote Play ports"
