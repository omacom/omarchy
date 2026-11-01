#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
export FIXTURE=$workdir CALL_LOG=$workdir/calls
mock_bin=$workdir/bin
mkdir -p "$mock_bin"

# Rewrite fixed paths in a copy; production has no environment-controlled root.
sed -e "s|/etc/|$workdir/etc/|g" -e "s|/boot/|$workdir/boot/|g" -e "s|/usr/share/limine-entry-tool.d|$workdir/share/limine-entry-tool.d|g" \
  "$ROOT/bin/omarchy-server-remote-unlock" >"$workdir/command"
if grep -Eq '(^|[="[:space:]])/(etc|boot)/' "$workdir/command"; then
  fail "all system paths use the scratch fixture"
fi

# Only these commands may cross the privilege boundary, only inside scratch.
cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash
set -eu
command=$1
shift
case $command in
  mkdir|install|tee|rm)
    for arg in "$@"; do
      case $arg in
        -p|-m|-f) ;;
        600) [[ $command == "install" ]] || exit 98 ;;
        "$FIXTURE"/*) ;;
        *) echo "Unsafe privileged path: $arg" >&2; exit 98 ;;
      esac
    done
    ;;
  test) [[ $# == 2 && $1 == "-f" && $2 == "$FIXTURE"/* ]] || exit 98 ;;
  limine-entry-tool) [[ $# == 2 && $1 == "--get-cmdline" && $2 == "default" ]] || exit 98 ;;
  limine-mkinitcpio) (( $# == 0 )) || exit 98 ;;
  *) echo "Unexpected privileged command: $command" >&2; exit 98 ;;
esac
case $command in
  test|limine-entry-tool) ;;
  *) printf 'sudo %s\n' "$command" >>"$CALL_LOG" ;;
esac
"$command" "$@"
STUB
cat >"$mock_bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'packages %s\n' "$*" >>"$CALL_LOG"
STUB
cat >"$mock_bin/omarchy-lifecycle-dispatch" <<'STUB'
#!/bin/bash
[[ ${PLATFORM_FAILURE:-0} == "0" ]] || exit 1
printf '%s' "${PLATFORM_BOOT:-}"
STUB
cat >"$mock_bin/omarchy-hw-platform" <<'STUB'
#!/bin/bash
echo x86
STUB
cat >"$mock_bin/findmnt" <<'STUB'
#!/bin/bash
echo /dev/mapper/root
STUB
cat >"$mock_bin/lsblk" <<'STUB'
#!/bin/bash
if [[ ${HAS_CRYPT:-1} == "1" ]]; then echo crypt; else echo part; fi
STUB
cat >"$mock_bin/limine-entry-tool" <<'STUB'
#!/bin/bash
echo "${BOOT_CMDLINE-root=/dev/mapper/root cryptdevice=UUID=test:root}"
STUB
cat >"$mock_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
if [[ ${REBUILD_FAILURE:-0} == "1" ]]; then echo 'mkinitcpio failed for kernel linux'; fi
STUB
chmod +x "$mock_bin"/*
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_EDITION_FILE=$workdir/edition
printf 'server\n' >"$OMARCHY_EDITION_FILE"
mkdir -p "$workdir/etc/mkinitcpio.conf.d" "$workdir/etc/limine-entry-tool.d" "$workdir/boot" "$workdir/home/.ssh"
printf 'HOOKS=(base udev block encrypt filesystems)\nMODULES=()\nFILES=()\n' >"$workdir/etc/mkinitcpio.conf"
cp "$ROOT/etc/mkinitcpio.conf.d/00-omarchy-hooks.conf" "$workdir/etc/mkinitcpio.conf.d/"
sed "s|/etc/|$workdir/etc/|g" "$ROOT/etc/mkinitcpio.conf.d/omarchy_hooks.conf" >"$workdir/etc/mkinitcpio.conf.d/omarchy_hooks.conf"
touch "$workdir/boot/limine.conf"
: >"$CALL_LOG"

run_command() {
  HOME="$workdir/home" bash "$workdir/command" "$@"
}
reject() {
  local output
  : >"$CALL_LOG"
  if output=$(run_command "$@" 2>&1); then fail "reject $*" "$output"; fi
  [[ ! -s $CALL_LOG ]] || fail "reject $* before packages or privileged writes" "$(cat "$CALL_LOG")"
}

# Prove the boundary itself fails closed before exercising configuration writes.
if sudo tee /etc/omarchy-unsafe-test 2>/dev/null; then fail "sudo fixture refuses host paths"; fi
if sudo sh -c true 2>/dev/null; then fail "sudo fixture refuses unknown commands"; fi
pass "privilege fixture refuses host paths and unknown commands"

reject enable
printf 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBRvTqo1SiIK0JhWRAvt3Cw0l0zKQ5Dz6ZrT2mhxI0dd test\n' >"$workdir/home/.ssh/authorized_keys"
printf 'desktop\n' >"$OMARCHY_EDITION_FILE"
reject enable
printf 'server\n' >"$OMARCHY_EDITION_FILE"
HAS_CRYPT=0 reject enable
PLATFORM_BOOT=/usr/lib/platform/setup-boot reject enable
PLATFORM_FAILURE=1 reject enable
BOOT_CMDLINE='root=/dev/mapper/root' reject enable
printf 'HOOKS=(base systemd sd-encrypt filesystems)\n' >"$workdir/etc/mkinitcpio.conf.d/z-unsupported.conf"
reject enable
rm "$workdir/etc/mkinitcpio.conf.d/z-unsupported.conf"
mv "$workdir/boot/limine.conf" "$workdir/boot/saved"
reject enable
mv "$workdir/boot/saved" "$workdir/boot/limine.conf"
printf 'KERNEL_CMDLINE[fallback]="root=other"\n' >"$workdir/etc/limine-entry-tool.d/custom.conf"
reject enable
rm "$workdir/etc/limine-entry-tool.d/custom.conf"
mkdir -p "$workdir/etc/default"
printf 'KERNEL_CMDLINE[default]="root=other"\n' >"$workdir/etc/default/limine"
reject enable
rm "$workdir/etc/default/limine"
BOOT_CMDLINE='root=/dev/mapper/root cryptdevice=UUID=test:root ip=dhcp' reject enable
pass "prerequisites and conflicting Limine configuration reject before installation or writes"

reject bogus
reject enable --port=2222
reject status --static-ip=192.0.2.3/24
reject enable --static-ip=192.0.2.3/24
for address in 999.0.2.3/24 192.0.2.3/0 192.0.2.3/33 192.0.2.3/08 192.0.2.3 192.00.2.3/24 '192.0.2.3/24;touch bad'; do
  reject enable "--static-ip=$address" --interface=enp1s0
done
reject enable --interface='eth0;bad'
reject enable --gateway=192.0.2.1
reject enable --static-ip=192.0.2.3/24 --interface=enp1s0 --gateway=invalid
pass "invalid commands and boot network inputs reject before writes"

hook_conf=$workdir/etc/mkinitcpio.conf.d/zz-omarchy-remote-unlock.conf
network_conf=$workdir/etc/limine-entry-tool.d/zz-omarchy-remote-unlock.conf
check_generated() (
  local conf
  source "$workdir/etc/mkinitcpio.conf"
  for conf in "$workdir/etc/mkinitcpio.conf.d/"*.conf; do source "$conf"; done
  [[ " ${HOOKS[*]} " == *' block netconf dropbear encryptssh filesystems '* ]] || fail "replace encrypt after Omarchy hook baseline" "${HOOKS[*]}"
  [[ " ${HOOKS[*]} " != *' encrypt '* ]] || fail "encrypt is replaced"
  local first="${HOOKS[*]}"
  source "$hook_conf"
  [[ ${HOOKS[*]} == "$first" ]] || fail "hook transformation is idempotent"
  local key=default
  if (( BASH_VERSINFO[0] >= 4 )); then
    declare -A KERNEL_CMDLINE
  else
    local default=0
    key=$default
  fi
  KERNEL_CMDLINE[$key]="root=/dev/mapper/root cryptdevice=UUID=test:root quiet"
  source "$network_conf"
  [[ ${KERNEL_CMDLINE[$key]} == "root=/dev/mapper/root cryptdevice=UUID=test:root quiet ip=$1" ]] || fail "default boot networking" "${KERNEL_CMDLINE[$key]}"
)

run_command enable
cmp "$workdir/home/.ssh/authorized_keys" "$workdir/etc/dropbear/root_key" || fail "build hook key input matches authorized keys"
[[ $(ls -l "$workdir/etc/dropbear/root_key") == -rw-------* ]] || fail "keys mode is 600"
check_generated dhcp
BOOT_CMDLINE='root=/dev/mapper/root cryptdevice=UUID=test:root ip=dhcp' run_command enable
check_generated dhcp
run_command enable --static-ip=192.0.2.3/24 --interface=enp1s0 --gateway=192.0.2.1
check_generated '192.0.2.3::192.0.2.1:255.255.255.0::enp1s0:none'
run_command enable --static-ip=192.0.2.3/32 --interface=enp1s0
check_generated '192.0.2.3:::255.255.255.255::enp1s0:none'
run_command enable --interface=enp1s0
check_generated ':::::enp1s0:dhcp'
[[ $(run_command status) == *'Port: 22'* ]] || fail "status port matches packaged hook"
pass "enable writes usable key input, replaces hooks, and generates DHCP/static boot networking repeatedly"

if REBUILD_FAILURE=1 run_command enable; then fail "reported kernel rebuild failure rejects success"; fi
pass "kernel rebuild failure is detected even when tool returns zero"

printf 'keep\n' >"$workdir/etc/limine-entry-tool.d/unrelated.conf"
run_command disable
run_command disable
[[ ! -e $hook_conf && ! -e $network_conf ]] || fail "disable removes owned configuration"
[[ -s $workdir/etc/dropbear/root_key && -s $workdir/etc/limine-entry-tool.d/unrelated.conf ]] || fail "disable retains keys and unrelated configuration"
[[ $(run_command status) == *'Status: DISABLED'* ]] || fail "disabled status"
pass "repeated disable removes only owned drop-ins"
