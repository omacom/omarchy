#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
export OMARCHY_PATH="$ROOT"
source "$ROOT/bin/omarchy-lab-vm"
test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT
STATE_DIR="$test_tmp/state"
mkdir -p "$test_tmp/db/sync"
pacman-conf() {
  case $1 in
    DBPath) echo "$test_tmp/db/" ;;
    --repo-list) printf '%s\n' core extra custom ;;
  esac
}
omarchy-pkg-add() { printf 'packages %s\n' "$*" >>"$test_tmp/calls"; }
omarchy-update() { echo "update $*" >>"$test_tmp/calls"; }

omarchy-hw-aarch64() { return 1; }
ensure_hypervisor_packages
[[ $(head -1 "$test_tmp/calls") == 'update -y' ]] || fail 'fresh database must update before dependencies'
rg -q 'packages qemu-full edk2-ovmf .*openbsd-netcat' "$test_tmp/calls" || fail 'missing x86 hypervisor packages'
[[ ! -f $STATE_DIR/package-update-required ]] || fail 'successful update marker leaked'
pass 'missing enabled repositories trigger a full Omarchy update before installing dependencies'

for repository in core extra custom; do printf db >"$test_tmp/db/sync/$repository.db"; done
: >"$test_tmp/calls"
ensure_install_packages
[[ $(wc -l <"$test_tmp/calls") == 1 ]] || fail 'existing repositories unnecessarily upgraded the host'
pass 'populated repositories use the normal package helper without a system upgrade'

(
  : >"$test_tmp/db/sync/custom.db"
  : >"$test_tmp/calls"
  omarchy-update() { printf db >"$test_tmp/db/sync/custom.db"; return 9; }
  if ensure_install_packages; then fail 'failed update reported success'; fi
  [[ ! -s $test_tmp/calls && -f $STATE_DIR/package-update-required ]] || fail 'failed update installed packages or lost retry state'
)
: >"$test_tmp/calls"
ensure_install_packages
[[ $(head -1 "$test_tmp/calls") == 'update -y' ]] || fail 'retry skipped unfinished update after databases appeared'
pass 'update failure blocks dependencies and retries the full update even after databases were downloaded'
(
  omarchy-pkg-add() { return 8; }
  if ensure_install_packages; then fail 'package failure reported success'; fi
)
pass 'dependency failure is propagated'

(
  omarchy-hw-aarch64() { return 0; }
  ensure_aarch64_uefi() { echo firmware >>"$test_tmp/calls"; }
  : >"$test_tmp/calls"
  ensure_hypervisor_packages
  rg -q '^packages qemu-desktop .*openbsd-netcat' "$test_tmp/calls" || fail 'missing ARM hypervisor packages'
  if rg -q 'qemu-full|edk2-ovmf' "$test_tmp/calls"; then fail 'ARM requested x86 dependencies'; fi
  [[ $(tail -1 "$test_tmp/calls") == firmware ]] || fail 'ARM setup skipped firmware'
)
pass 'ARM installs native QEMU with SPICE support and prepares aarch64 UEFI'

(
  omarchy-hw-aarch64() { return 0; }
  share="$test_tmp/share"
  mkdir -p "$share/edk2/aarch64" "$share/AAVMF"
  touch "$share/edk2/aarch64/QEMU_EFI.fd" "$share/AAVMF/AAVMF_VARS.fd"
  if aarch64_uefi_firmware "$share"; then fail 'firmware accepted a mismatched pair'; fi
  touch "$share/edk2/aarch64/QEMU_VARS.fd"
  aarch64_uefi_firmware "$share" || fail 'complete Arch firmware pair not found'

  iso="$test_tmp/omarchy-4.5.0-aarch64.iso"
  cidata="$test_tmp/cidata.iso"
  mapfile -d '' -t args < <(virt_install_args 4096 4 "$iso" "$test_tmp/gold.qcow2" "$cidata")
  boot_args=$(printf '%s\n' "${args[@]}")
  [[ $boot_args == *$'--arch\naarch64\n--virt-type\nkvm\n--machine\nvirt\n'* ]] || fail 'ARM did not select its native KVM machine'
  [[ $boot_args == *'gic.version=host,pmu.state=off'* && $boot_args == *'--qemu-commandline=-machine msi=gicv2m'* ]] ||
    fail 'ARM machine options are incomplete'
  [[ $boot_args == *"loader=$UEFI_CODE,"*"nvram.template=$UEFI_VARS"* && $boot_args == *'model=tpm-tis'* ]] || fail 'ARM firmware or TPM is wrong'
  [[ $boot_args == *"path=$iso,device=cdrom,bus=scsi,readonly=yes"*"path=$cidata,device=cdrom,bus=scsi,readonly=yes"*$'--install\nbootdev=cdrom'* ]] ||
    fail 'ARM media order or first-boot mode is wrong'

  write_cidata_files "$test_tmp/answers" lab hash omarchy-lab UTC us 85899345920 "fixture key" "$iso"
  jq -e '.omarchy_install.boot.efi_binary == "limine_aa64.efi"
    and .omarchy_install.storage.kernel == "linux-omarchy"
    and .kernels == ["linux-omarchy"]
    and .disk_config.device_modifications[0].device == "/dev/vda"
    and .mirror_config.custom_servers == [{url:"https://arm-mirror.omarchy.org/$arch/$repo"}]' \
    "$test_tmp/answers/user_configuration.json" >/dev/null || fail 'ARM unattended answers would install the wrong system'
)
pass 'ARM uses paired UEFI, KVM interrupt settings, SCSI media and matching unattended answers'

(
  iso="$test_tmp/omarchy-4.5.0-x86.iso"
  write_cidata_files "$test_tmp/answers" lab hash omarchy-lab UTC us 85899345920 "fixture key" "$iso"
  jq -e '.omarchy_install.boot.efi_binary == "limine_x64.efi" and .kernels == ["linux-omarchy"]' \
    "$test_tmp/answers/user_configuration.json" >/dev/null || fail 'current x86 media must use the Omarchy kernel'
  write_cidata_files "$test_tmp/answers" lab hash omarchy-lab UTC us 85899345920 "fixture key" "${iso%-x86.iso}.iso"
  jq -e '.omarchy_install.boot.efi_binary == "limine_x64.efi" and .kernels == ["linux"]' \
    "$test_tmp/answers/user_configuration.json" >/dev/null || fail 'legacy media must keep the stock x86 kernel'
)
pass 'current and legacy x86 media use their respective installed kernels'

(
  lab_ssh_quiet() { return 0; }
  configure_guest_sudo() { fail 'healthy guest must not rewrite sudo policy'; }
  install_guest_display_resize() { fail 'healthy guest must not reinstall or update'; }
  lab_ssh() {
    [[ $1 == *'sudo -n systemctl start spice-vdagentd.socket'* ]] || fail 'SPICE socket not started'
    [[ $1 == *'systemctl --user start spice-vdagent.service omarchy-lab-display-resize.service'* ]] || fail 'both guest session services must start without reboot'
  }
  ensure_guest_display_resize
)
pass 'healthy display integration starts services without reinstalling packages'

(
  lab_ssh_quiet() { return 1; }
  guest_user() { echo lab; }
  configure_guest_sudo() { echo sudo >>"$test_tmp/display-calls"; }
  install_guest_display_resize() { echo install >>"$test_tmp/display-calls"; }
  lab_ssh() { echo start >>"$test_tmp/display-calls"; }
  ensure_guest_display_resize
  [[ $(paste -sd ' ' "$test_tmp/display-calls") == 'sudo install start' ]] || fail 'legacy guest repair order'
  install_guest_display_resize() { return 8; }
  lab_ssh() { fail 'failed repair must not continue'; }
  if ensure_guest_display_resize; then fail 'failed display installation accepted'; fi
  configure_guest_sudo() { return 9; }
  install_guest_display_resize() { fail 'failed sudo must not install'; }
  if ensure_guest_display_resize; then fail 'failed guest authentication accepted'; fi
)
pass 'legacy gold display tools are repaired with explicit failure propagation'

(
  lab_ssh_quiet() { return 1; }
  lab_ssh() { fail 'noninteractive repair must not ask for a password'; }
  if configure_guest_sudo lab; then fail 'guest without passwordless sudo accepted'; fi
)
(
  lab_ssh() { return 7; }
  lab_ssh_quiet() { fail 'failed asset upload must stop provisioning'; }
  if install_guest_display_resize; then fail 'failed asset upload accepted'; fi
)
pass 'display repair cannot hang on a sudo prompt or swallow asset upload failures'

(
  is_tty() { return 0; }
  sudo() { :; }
  have_domain() { return 0; }
  find_pool() { echo test-pool; }
  domain_running() { return 1; }
  restore_gold_network() { :; }
  run_virsh() { :; }
  CONFIG_FILE="$test_tmp/no-config"
  KNOWN_HOSTS="$test_tmp/no-known-hosts"
  wait_ssh() { echo ssh >>"$test_tmp/reset-calls"; }
  wait_hypr() { echo hypr >>"$test_tmp/reset-calls"; }
  ensure_guest_display_resize() { echo repair >>"$test_tmp/reset-calls"; }
  guest_ip() { echo 192.0.2.2; }
  reset_lab >"$test_tmp/reset-output"
  [[ $(paste -sd ' ' "$test_tmp/reset-calls") == 'ssh hypr repair' ]] || fail 'reset must repair the restored guest'
  ensure_guest_display_resize() { return 8; }
  if reset_lab >"$test_tmp/reset-output"; then fail 'reset ignored failed display repair'; fi
  [[ ! -s $test_tmp/reset-output ]] || fail 'reset falsely reported success'
)
pass 'reset repairs integration on the restored overlay and cannot report a failed repair as success'

routes='[{"dst":"default","dev":"eth0"},{"dst":"192.168.122.0/24","dev":"eth0"},{"dst":"192.168.124.0/23","dev":"vpn0"}]'
if lab_subnet_available 192.168.122.1 "$routes"; then fail 'nested subnet overlap accepted'; fi
if lab_subnet_available 192.168.125.1 "$routes"; then fail 'larger VPN route overlap accepted'; fi
lab_subnet_available 192.168.126.1 "$routes" || fail 'unused subnet rejected'
lab_subnet_available 192.168.124.1 '[{"dst":"192.168.124.0/24","dev":"virbr0"}]' || fail 'own bridge considered a conflict'
pass 'subnet selection handles nested networks, larger CIDRs, and its own bridge'

network_xml="<network><name>default</name>
<ip address='192.168.122.1' netmask='255.255.255.0'>
<dhcp><range start='192.168.122.2' end='192.168.122.254'/></dhcp></ip></network>"
active=false
used=false
fixture_routes=$routes
ip() { printf '%s\n' "$fixture_routes"; }
run_virsh() {
  case $1 in
    net-dumpxml) printf '%s\n' "$network_xml" ;;
    net-list) if $active; then echo default; fi ;;
    list) if $used; then echo other-vm; fi ;;
    dumpxml) echo "<domain><interface><source network='default'/></interface></domain>" ;;
    net-define) network_xml=$(cat); printf '%s\n' "$network_xml" >"$test_tmp/defined.xml" ;;
    *) fail "unexpected virsh action $*" ;;
  esac
}
(
  active=true
  if ensure_default_network; then fail 'active network renumbered'; fi
  [[ ! -e $test_tmp/defined.xml ]] || fail 'active network changed'
)
(
  used=true
  if ensure_default_network; then fail 'existing VM network renumbered'; fi
  [[ ! -e $test_tmp/defined.xml ]] || fail 'existing VM network changed'
)
ensure_default_network
[[ $LIBVIRT_NET == '192.168.126.1' ]] || fail 'wrong non-overlapping gateway'
rg -q '192.168.126.254' "$test_tmp/defined.xml" || fail 'DHCP range not moved with gateway'
rg -q '192.168.122.1' "$STATE_DIR/default-network-before-lab.xml" || fail 'original definition not preserved'
pass 'only an unused conflicting default network is renumbered, with a backup and matching DHCP range'
