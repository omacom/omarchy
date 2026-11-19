#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

installer="$ROOT/bin/omarchy-install-virt-manager"
setup="$installer"
remover="$ROOT/bin/omarchy-remove-virt-manager"

test_tmp=$(mktemp -d)
fake_bin="$test_tmp/bin"
calls="$test_tmp/calls"
output="$test_tmp/output"
mkdir -p "$fake_bin"
trap 'rm -rf "$test_tmp"' EXIT
export TEST_HOOK="$test_tmp/50-omarchy-virt-manager-python.hook"

cat >"$fake_bin/install" <<'SH'
#!/bin/bash
[[ $TEST_FAILURE == "hook-install" ]] && exit 1
(( $# == 3 )) || exit 1
[[ $1 == "-Dm644" && $3 == "/etc/pacman.d/hooks/50-omarchy-virt-manager-python.hook" ]] || exit 1
exec /usr/bin/install "$1" "$2" "$TEST_HOOK"
SH

cat >"$fake_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$fake_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
[[ $TEST_FAILURE == "pkg-drop" ]] && exit 1
exit 0
SH

cat >"$fake_bin/sudo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_CALLS"
exec "$@"
SH

cat >"$fake_bin/omarchy-install-virt-manager" <<'SH'
#!/bin/bash
[[ $TEST_FAILURE == "python-helper" ]] && exit 1
exit 0
SH

cat >"$fake_bin/systemctl" <<'SH'
#!/bin/bash
[[ $TEST_FAILURE == "systemctl" ]] && exit 1
exit 0
SH

cat >"$fake_bin/virsh" <<'SH'
#!/bin/bash
case "$1" in
  net-autostart)
    [[ $TEST_FAILURE == "net-autostart" ]] && exit 1
    exit 0
    ;;
  net-info)
    [[ $TEST_FAILURE == "net-info" ]] && exit 1
    printf 'Active: no\n'
    ;;
  net-start)
    [[ $TEST_FAILURE == "net-start" ]] && exit 1
    exit 0
    ;;
esac
SH

cat >"$fake_bin/ufw" <<'SH'
#!/bin/bash
[[ $TEST_FAILURE == "ufw" ]] && exit 1
printf 'ufw %s\n' "$*" >>"$TEST_CALLS"
SH

chmod +x "$fake_bin"/*

for failure in hook-install python-helper systemctl net-autostart net-info net-start; do
  : >"$calls"
  if TEST_CALLS="$calls" TEST_FAILURE="$failure" PATH="$fake_bin:$PATH" "$setup" >"$output" 2>&1; then
    fail "virt-manager reports $failure setup failures" "Expected $setup to return a failure when $failure fails."
  fi

  case "$failure" in
    hook-install)
      expected_error="Failed to install the virt-manager Python upgrade hook"
      ;;
    python-helper)
      expected_error="Failed to configure virt-manager to use the system Python"
      ;;
    systemctl)
      expected_error="Failed to enable libvirt services"
      ;;
    net-autostart)
      expected_error="Failed to enable the default libvirt network"
      ;;
    net-info)
      expected_error="Failed to check the default libvirt network"
      ;;
    net-start)
      expected_error="Failed to start the default libvirt network"
      ;;
  esac

  if ! rg -Fq "$expected_error" "$output"; then
    fail "virt-manager explains $failure setup failures" "Expected $setup to report why $failure failed."
  fi

  if rg -Fq 'ufw ' "$calls"; then
    fail "virt-manager stops setup after $failure fails" "Expected $setup not to apply firewall rules after $failure fails."
  fi
done
pass "virt-manager reports setup failures before firewall configuration"

: >"$calls"
if TEST_CALLS="$calls" TEST_FAILURE="ufw" PATH="$fake_bin:$PATH" "$setup" >"$output" 2>&1; then
  fail "virt-manager reports firewall setup failures" "Expected $setup to return a failure when UFW configuration fails."
fi

if ! rg -Fq 'Failed to allow DNS over TCP for virtual machines' "$output"; then
  fail "virt-manager explains firewall setup failures" "Expected $setup to explain the UFW configuration failure."
fi
pass "virt-manager explains firewall setup failures"

: >"$calls"
if ! TEST_CALLS="$calls" TEST_FAILURE="" PATH="$fake_bin:$PATH" "$setup" >"$output" 2>&1; then
  fail "virt-manager configures guest networking" "Expected $setup to succeed when all setup commands succeed."
fi

last_private_deny=$(rg -n '^ufw route deny in on virbr0 to ' "$calls" | tail -n1 | cut -d: -f1)
forward_allow=$(rg -n '^ufw route allow in on virbr0 comment omarchy-libvirt-forward$' "$calls" | head -n1 | cut -d: -f1)
if [[ -z $last_private_deny || -z $forward_allow ]] || (( last_private_deny >= forward_allow )); then
  fail "virt-manager blocks private networks before internet forwarding" "Expected private-network denies to be added before the guest internet-forwarding rule."
fi
pass "virt-manager blocks private networks before internet forwarding"

if ! cmp -s "$ROOT/install/virt-manager/50-omarchy-virt-manager-python.hook" "$TEST_HOOK"; then
  fail "virt-manager installs its upgrade hook" "Expected setup to install the shipped hook for future package upgrades."
fi
pass "virt-manager installs its upgrade hook"

: >"$calls"
if TEST_CALLS="$calls" TEST_FAILURE="pkg-drop" PATH="$fake_bin:$PATH" "$remover" >"$output" 2>&1; then
  fail "virt-manager reports package removal failures" "Expected $remover to return a failure when package removal fails."
fi

if ! rg -Fq 'Package removal failed' "$output" || rg -Fq 'QEMU and Virtual Machine Manager have been removed.' "$output"; then
  fail "virt-manager does not report failed removal as complete" "Expected $remover to report the package failure without its success message."
fi

if rg -q '^ufw ' "$calls"; then
  fail "virt-manager preserves guest networking on removal failure" "Expected $remover not to change firewall rules when package removal fails."
fi
pass "virt-manager reports package removal failures without claiming success"

: >"$calls"
if ! TEST_CALLS="$calls" TEST_FAILURE="" PATH="$fake_bin:$PATH" "$remover" >"$output" 2>&1; then
  fail "virt-manager removes packages and firewall rules" "Expected $remover to succeed when package removal succeeds."
fi
if ! rg -Fq "ufw --force delete route allow in on virbr0 comment omarchy-libvirt-forward" "$calls"; then
  fail "virt-manager removes owned firewall rules after package removal" "Expected $remover to clean up its forwarding rule after successful package removal."
fi
pass "virt-manager removes owned firewall rules after package removal"

cat >"$fake_bin/sed" <<'SH'
#!/bin/bash
if (( $# != 3 )) || [[ $1 != "-i" || $2 != '/env python3/ c\#!/bin/python3' || $3 != "/usr/bin/virt-manager" ]]; then
  exit 1
fi
exec /usr/bin/sed "$1" "$2" "$TEST_LAUNCHER"
SH
chmod +x "$fake_bin/sed"

launcher="$test_tmp/virt-manager"
printf '#!/usr/bin/env python3\nprint("fixture")\n' >"$launcher"
if ! TEST_LAUNCHER="$launcher" PATH="$fake_bin:$PATH" "$installer" --fix-python >"$output" 2>&1; then
  fail "virt-manager pins system Python after upgrades" "Expected the real --fix-python mode to edit the isolated launcher."
fi

if [[ $(head -n 1 "$launcher") != "#!/bin/python3" ]] || ! rg -Fxq 'print("fixture")' "$launcher"; then
  fail "virt-manager pins system Python after upgrades" "Expected the isolated launcher to use system Python without changing its body."
fi
pass "virt-manager pins system Python after upgrades"
