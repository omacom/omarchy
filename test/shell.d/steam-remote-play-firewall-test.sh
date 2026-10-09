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
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_LOG="$test_tmp/ufw.log"
export PATH="$mock_bin:$PATH"

profile="$ROOT/default/ufw/applications.d/omarchy-steam"

expect_logged() {
  local line="$1"
  local message="$2"

  grep -Fxq "$line" "$OMARCHY_TEST_LOG" || fail "$message" "$(<"$OMARCHY_TEST_LOG")"
}

grep -Fxq 'ports=27036/tcp|27031:27036/udp|10400:10401/udp' "$profile" ||
  fail "the Omarchy Steam profile declares the documented Remote Play and Steam Link VR ports" "$(<"$profile")"
grep -Fxq '[Omarchy Steam]' "$profile" ||
  fail "the UFW profile is named Omarchy Steam" "$(<"$profile")"
pass "the Omarchy Steam UFW application profile declares the port set"

: >"$OMARCHY_TEST_LOG"
bash "$ROOT/bin/omarchy-install-gaming-steam" >/dev/null

expect_logged "sudo:install -Dm644 $profile /etc/ufw/applications.d/omarchy-steam" \
  "install copies the Omarchy Steam profile into /etc/ufw/applications.d"
expect_logged "sudo:ufw app update Omarchy Steam" \
  "install refreshes any existing rules against the profile"
for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
  expect_logged "sudo:ufw allow in from $cidr to any app Omarchy Steam" \
    "install allows the Omarchy Steam app for $cidr"
done
if grep -q 'tailscale0' "$OMARCHY_TEST_LOG"; then
  fail "install skips the Tailscale rule when tailscale0 is absent" "$(<"$OMARCHY_TEST_LOG")"
fi
expect_logged "sudo:ufw reload" "install reloads UFW after adding rules"
pass "install opens the Omarchy Steam app ports for private LANs"

: >"$OMARCHY_TEST_LOG"
OMARCHY_TEST_TAILSCALE=1 bash "$ROOT/bin/omarchy-install-gaming-steam" >/dev/null
expect_logged "sudo:ufw allow in on tailscale0 to any app Omarchy Steam" \
  "install allows the Omarchy Steam app on tailscale0"
pass "install opens the Omarchy Steam app ports on Tailscale when present"

: >"$OMARCHY_TEST_LOG"
OMARCHY_TEST_UFW_MISSING=1 bash "$ROOT/bin/omarchy-install-gaming-steam" >/dev/null
if grep -q '^sudo:' "$OMARCHY_TEST_LOG"; then
  fail "install skips firewall rules when UFW is not installed" "$(<"$OMARCHY_TEST_LOG")"
fi
pass "install skips firewall rules when UFW is not installed"

: >"$OMARCHY_TEST_LOG"
bash "$ROOT/bin/omarchy-remove-gaming-steam" >/dev/null
for cidr in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
  expect_logged "sudo:ufw --force delete allow in from $cidr to any app Omarchy Steam" \
    "remove deletes the Omarchy Steam rule for $cidr"
done
expect_logged "sudo:ufw --force delete allow in on tailscale0 to any app Omarchy Steam" \
  "remove deletes the Omarchy Steam rule on tailscale0"
expect_logged "sudo:rm -f /etc/ufw/applications.d/omarchy-steam" \
  "remove deletes the Omarchy Steam profile after its rules"
expect_logged "sudo:ufw reload" "remove reloads UFW after deleting rules"
pass "remove closes the Omarchy-managed Steam Remote Play ports"
