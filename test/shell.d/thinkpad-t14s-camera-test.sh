#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$ROOT"
setup="$ROOT/install/hardware/lenovo/thinkpad-t14s-camera.sh"
migration="$ROOT/migrations/1791080527.sh"

# Exercise the real scripts, redirecting privileged writes to a temporary root.
omarchy-hw-aarch64-qualcomm() { [[ $soc == "qualcomm" ]]; }
omarchy-hw-match() { grep -qi -- "$1" <<<"$model"; }
omarchy-pkg-add() { printf '%s\n' "$*" >>"$scratch/packages"; }
sudo() {
  case "$1" in
    install) command install "$2" "$3" "$scratch$4" ;;
    udevadm) printf '%s\n' "$*" >>"$scratch/udev" ;;
    *) fail "unexpected privileged command" "$*" ;;
  esac
}

for entry in "$setup" "$migration"; do
  bash -n "$entry"
  for soc in qualcomm other; do
    for model in 21N10000US 21N20000US 83ED 21F60000US; do
      rm -f "$scratch/packages" "$scratch/udev" "$scratch/etc/udev/rules.d/70-thinkpad-t14s-camera.rules"
      source "$entry"
      if [[ $soc == "qualcomm" && $model == 21N[12]* ]]; then
        [[ $(cat "$scratch/packages") == "pipewire-libcamera" ]] || fail "camera backend is installed"
        cmp "$ROOT/default/udev/thinkpad-t14s-camera.rules" \
          "$scratch/etc/udev/rules.d/70-thinkpad-t14s-camera.rules" || fail "camera access rule is installed"
        [[ $(stat -c %a "$scratch/etc/udev/rules.d/70-thinkpad-t14s-camera.rules") == "644" ]] || fail "rule is not writable by other users"
        if [[ $entry == "$migration" ]]; then
          grep -Fxq 'udevadm trigger --action=add --subsystem-match=dma_heap --sysname-match=system' "$scratch/udev" || fail "migration only retriggers the system heap"
        else
          [[ ! -e $scratch/udev ]] || fail "installation does not contact the live udev daemon"
        fi
        source "$entry"
        cmp "$ROOT/default/udev/thinkpad-t14s-camera.rules" \
          "$scratch/etc/udev/rules.d/70-thinkpad-t14s-camera.rules" || fail "repeated setup preserves the rule"
      else
        [[ ! -e $scratch/packages && ! -e $scratch/etc/udev/rules.d/70-thinkpad-t14s-camera.rules && ! -e $scratch/udev ]] || fail "unmatched hardware is untouched"
      fi
    done
  done
done
pass "camera setup and migration are restricted to Snapdragon T14s models and can be rerun"

# The active-seat ACL must not grant access to CMA heaps or world-writable nodes.
rule=$(sed '/^#/d; /^$/d' "$ROOT/default/udev/thinkpad-t14s-camera.rules")
[[ $rule == 'SUBSYSTEM=="dma_heap", KERNEL=="system", TAG+="uaccess"' ]] || fail "access is restricted to the system heap via logind"
pass "DMA heap access uses a scoped active-seat ACL"

grep -Fxq 'pipewire-libcamera' "$ROOT/install/omarchy-other.packages" || fail "ISO can supply the camera backend offline"
pass "camera backend is included in the offline package inventory"
