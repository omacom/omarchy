#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

findmnt() {
  [[ $* == "-no SOURCE /" ]] || return 99
  printf '%s\n' "$root_source"
}
lsblk() {
  [[ ${*: -1} == "/dev/mapper/root" ]] || return 98
  printf '%s\n' "$*" >>"$test_tmp/lsblk-calls"
  [[ $disk_state != "failure" ]] || return 1
  if [[ $disk_state == "lvm" ]]; then
    printf '/dev/mapper/root btrfs\n/dev/mapper/cryptlvm LVM2_member\n/dev/nvme0n1p2 crypto_LUKS\n/dev/nvme0n1 \n'
  elif [[ $disk_state == "encrypted" ]]; then
    if [[ $1 == -*r* ]]; then
      printf '/dev/mapper/root btrfs\n/dev/nvme0n1p6 crypto_LUKS\n/dev/nvme0n1 \n'
    else
      printf '/dev/mapper/root btrfs\n└─/dev/nvme0n1p6 crypto_LUKS\n  └─/dev/nvme0n1 \n'
    fi
  else
    printf '/dev/mapper/root btrfs\n/dev/nvme0n1p6 ext4\n'
  fi
}

for script in omarchy-provision-owner omarchy-system-factory-reset; do
  # Load only this read-only helper, never the provisioning/reset entrypoint.
  sed -n '/^luks_device() {/,/^}/p' "$ROOT/bin/$script" |
    sed "s|/proc/cmdline|$test_tmp/cmdline|g" >"$test_tmp/helper"
  [[ -s $test_tmp/helper ]] || fail "$script exposes its LUKS lookup"
  source "$test_tmp/helper"
  printf 'root=/dev/mapper/root rd.luks.name=fixture=root\n' >"$test_tmp/cmdline"
  root_source='/dev/mapper/root[/@]'
  disk_state=encrypted
  actual=$(luks_device) || fail "$script resolves a crypttab root"
  [[ $actual == "/dev/nvme0n1p6" ]] || fail "$script returns the raw partition path" "$actual"
  pass "$script strips the btrfs subvolume and returns the LUKS parent without tree glyphs"

  disk_state=lvm
  actual=$(luks_device) || fail "$script resolves a root on LVM on LUKS"
  [[ $actual == "/dev/nvme0n1p2" ]] || fail "$script walks past the LVM layer to the LUKS partition" "$actual"
  pass "$script finds the LUKS partition beneath an LVM volume group"

  for disk_state in plain failure; do
    if actual=$(luks_device); then
      fail "$script rejects $disk_state ancestry" "$actual"
    fi
    [[ -z $actual ]] || fail "$script emits no device on $disk_state ancestry"
  done
  root_source=""
  if luks_device; then fail "$script rejects a missing root source"; fi

  for spec in UUID=fixture PARTUUID=fixture LABEL=fixture PARTLABEL=fixture /dev/nvme0n1p6; do
    case $spec in
      UUID=*) expected=/dev/disk/by-uuid/fixture ;;
      PARTUUID=*) expected=/dev/disk/by-partuuid/fixture ;;
      LABEL=*) expected=/dev/disk/by-label/fixture ;;
      PARTLABEL=*) expected=/dev/disk/by-partlabel/fixture ;;
      *) expected=$spec ;;
    esac
    : >"$test_tmp/lsblk-calls"
    printf 'cryptdevice=%s:root root=/dev/mapper/root\n' "$spec" >"$test_tmp/cmdline"
    actual=$(luks_device) || fail "$script preserves $spec lookup"
    [[ $actual == "$expected" && ! -s $test_tmp/lsblk-calls ]] || fail "$script prefers the explicit cryptdevice"
  done
  pass "$script preserves explicit cryptdevice lookup and rejects unencrypted or missing roots"
done
