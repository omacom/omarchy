#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

installer="$ROOT/bin/omarchy-install-virt-manager"
setup="$installer"
remover="$ROOT/bin/omarchy-remove-virt-manager"
python_hook="$ROOT/default/libalpm/hooks/50-omarchy-virt-manager-python.hook"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"

if ! rg -Fq 'Target = virt-manager' "$python_hook" || ! rg -Fq 'Operation = Upgrade' "$python_hook" || ! rg -Fq 'Exec = /usr/bin/omarchy-install-virt-manager --fix-python' "$python_hook" || ! rg -Fq "sed -i '/env python3/ c\\#!/bin/python3' /usr/bin/virt-manager" "$installer"; then
  fail "virt-manager uses the system Python after upgrades" "Expected $python_hook to run the shebang helper after package upgrades."
fi
pass "virt-manager uses the system Python after upgrades"

if ! rg -Fxq 'set -e' "$setup"; then
  fail "virt-manager stops after setup failures" "Expected $setup to stop when a required setup command fails."
fi
pass "virt-manager stops after setup failures"

if ! rg -Fq 'if ! omarchy-pkg-add dnsmasq qemu-desktop virt-manager; then' "$installer"; then
  fail "virt-manager aborts when package installation fails" "Expected $installer to abort if required packages cannot be installed."
fi
pass "virt-manager aborts when package installation fails"

if ! rg -Fq 'if [[ $1 == "--fix-python" ]]; then' "$installer"; then
  fail "virt-manager keeps Python setup in the installer" "Expected $installer to provide the hook's Python-fix mode."
fi
pass "virt-manager keeps Python setup in the installer"

if ! rg -Fq 'sudo systemctl enable --now virtqemud.socket virtstoraged.socket virtnetworkd.socket' "$setup"; then
  fail "virt-manager starts required libvirt daemons" "Expected $setup to enable virtqemud.socket, virtstoraged.socket, and virtnetworkd.socket."
fi
pass "virt-manager starts required libvirt daemons"

if ! rg -Fq "sudo ufw allow in on virbr0 to any port 67 proto udp comment 'omarchy-libvirt-dhcp'" "$setup"; then
  fail "virt-manager allows DHCP from guests" "Expected $setup to allow DHCP requests on virbr0."
fi
pass "virt-manager allows DHCP from guests"

if ! rg -Fq "sudo ufw allow in on virbr0 to any port 53 proto udp comment 'omarchy-libvirt-dns'" "$setup" || ! rg -Fq "sudo ufw allow in on virbr0 to any port 53 proto tcp comment 'omarchy-libvirt-dns'" "$setup"; then
  fail "virt-manager allows DNS from guests" "Expected $setup to allow TCP and UDP DNS requests on virbr0."
fi
pass "virt-manager allows DNS from guests"

if ! rg -Fq "sudo ufw route deny in on virbr0 to 10.0.0.0/8 comment 'omarchy-libvirt-private'" "$setup" || ! rg -Fq "sudo ufw route deny in on virbr0 to 172.16.0.0/12 comment 'omarchy-libvirt-private'" "$setup" || ! rg -Fq "sudo ufw route deny in on virbr0 to 192.168.0.0/16 comment 'omarchy-libvirt-private'" "$setup"; then
  fail "virt-manager protects private networks" "Expected $setup to deny guest forwarding to RFC1918 networks."
fi
pass "virt-manager protects private networks"

if ! rg -Fq "sudo ufw route allow in on virbr0 comment 'omarchy-libvirt-forward'" "$setup"; then
  fail "virt-manager allows guest internet access" "Expected $setup to allow forwarded traffic from virbr0 after private-network denies."
fi
pass "virt-manager allows guest internet access"

if ! rg -Fq '"setup.virt-manager"' "$menu" || ! rg -Fq '"when":"omarchy-pkg-present virt-manager"' "$menu" || ! rg -Fq 'omarchy-install-virt-manager' "$menu"; then
  fail "virt-manager setup can be retried from the menu" "Expected Setup to offer virt-manager configuration whenever virt-manager is installed."
fi
pass "virt-manager setup can be retried from the menu"

if rg -Fq 'systemctl disable --now virtqemud.socket virtstoraged.socket virtnetworkd.socket' "$remover"; then
  fail "virt-manager preserves shared libvirt sockets" "Expected $remover not to disable sockets that other VM clients may use."
fi
pass "virt-manager preserves shared libvirt sockets"

if ! rg -Fq "sudo ufw --force delete allow in on virbr0 to any port 67 proto udp comment 'omarchy-libvirt-dhcp'" "$remover"; then
  fail "virt-manager removes its DHCP firewall rule" "Expected $remover to remove only Omarchy's DHCP rule for virbr0."
fi
pass "virt-manager removes its DHCP firewall rule"

if ! rg -Fq "sudo ufw --force delete route allow in on virbr0 comment 'omarchy-libvirt-forward'" "$remover"; then
  fail "virt-manager removes its forwarding firewall rule" "Expected $remover to remove only Omarchy's forwarding rule for virbr0."
fi
pass "virt-manager removes its forwarding firewall rule"

if ! rg -Fq "sudo ufw --force delete route deny in on virbr0 to 10.0.0.0/8 comment 'omarchy-libvirt-private'" "$remover" || ! rg -Fq "sudo ufw --force delete route deny in on virbr0 to 172.16.0.0/12 comment 'omarchy-libvirt-private'" "$remover" || ! rg -Fq "sudo ufw --force delete route deny in on virbr0 to 192.168.0.0/16 comment 'omarchy-libvirt-private'" "$remover"; then
  fail "virt-manager removes its private-network firewall rules" "Expected $remover to remove only Omarchy's private-network deny rules."
fi
pass "virt-manager removes its private-network firewall rules"

test_tmp=$(mktemp -d)
fake_bin="$test_tmp/bin"
calls="$test_tmp/calls"
output="$test_tmp/output"
mkdir -p "$fake_bin"
trap 'rm -rf "$test_tmp"' EXIT

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

for failure in python-helper systemctl net-autostart net-info net-start; do
  : >"$calls"
  if TEST_CALLS="$calls" TEST_FAILURE="$failure" PATH="$fake_bin:$PATH" "$setup" >"$output" 2>&1; then
    fail "virt-manager reports $failure setup failures" "Expected $setup to return a failure when $failure fails."
  fi

  case "$failure" in
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

: >"$calls"
if TEST_CALLS="$calls" TEST_FAILURE="pkg-drop" PATH="$fake_bin:$PATH" "$remover" >"$output" 2>&1; then
  fail "virt-manager reports package removal failures" "Expected $remover to return a failure when package removal fails."
fi

if ! rg -Fq 'Package removal failed' "$output" || rg -Fq 'QEMU and Virtual Machine Manager have been removed.' "$output"; then
  fail "virt-manager does not report failed removal as complete" "Expected $remover to report the package failure without its success message."
fi

if ! rg -Fq "ufw --force delete route allow in on virbr0 comment omarchy-libvirt-forward" "$calls"; then
  fail "virt-manager removes only owned firewall rules on failure" "Expected $remover to keep the Omarchy ownership marker while cleaning up its firewall rule."
fi
pass "virt-manager reports package removal failures without claiming success"

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
