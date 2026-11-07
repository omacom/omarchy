#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/install/hardware/asus/fix-asus-vivobook-s15.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

bash -n "$setup" || fail "ASUS Vivobook S 15 hardware script has valid syntax"

matching="$scratch/matching"
mkdir -p "$matching"
(
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-hw-match() { [[ $1 == "S5507" ]]; }

  OMARCHY_VIVOBOOK_S15_MKINITCPIO_DIR="$matching/mkinitcpio.conf.d" \
    OMARCHY_VIVOBOOK_S15_LIMINE_CONFIG_DIR="$matching/limine-entry-tool.d" \
    OMARCHY_VIVOBOOK_S15_SLEEP_CONFIG_DIR="$matching/sleep.conf.d" \
    OMARCHY_VIVOBOOK_S15_UDEV_RULES_DIR="$matching/udev.rules.d" \
    OMARCHY_VIVOBOOK_S15_WIREPLUMBER_DIR="$matching/wireplumber.conf.d" \
    source "$setup"
)

grep -Fxq 'MemorySleepMode=s2idle' "$matching/sleep.conf.d/asus-vivobook-s15.conf" ||
  fail "ASUS Vivobook S 15 setup configures s2idle sleep"

grep -q 'splash plymouth.use-simpledrm' "$matching/limine-entry-tool.d/asus-vivobook-s15.conf" ||
  fail "ASUS Vivobook S 15 setup enables SimpleDRM for Plymouth unlock"

grep -q 'asus_keyboard' "$matching/udev.rules.d/70-asus-vivobook.rules" ||
  fail "ASUS Vivobook S 15 setup adds keyboard udev rule"

grep -Fq 'lpass-*-macro' "$matching/udev.rules.d/90-qualcomm-lpass-audio.rules" ||
  fail "ASUS Vivobook S 15 setup adds LPASS power-management udev rule"

grep -q 'ov02c10' "$matching/wireplumber.conf.d/51-default-camera-rgb.conf" ||
  fail "ASUS Vivobook S 15 setup prioritizes RGB webcam in WirePlumber"

# Non-matching hardware must not write configs
non_matching="$scratch/non-matching"
mkdir -p "$non_matching"
(
  omarchy-hw-aarch64-qualcomm() { return 0; }
  omarchy-hw-match() { return 1; }

  OMARCHY_VIVOBOOK_S15_MKINITCPIO_DIR="$non_matching/mkinitcpio.conf.d" \
    OMARCHY_VIVOBOOK_S15_LIMINE_CONFIG_DIR="$non_matching/limine-entry-tool.d" \
    OMARCHY_VIVOBOOK_S15_SLEEP_CONFIG_DIR="$non_matching/sleep.conf.d" \
    OMARCHY_VIVOBOOK_S15_UDEV_RULES_DIR="$non_matching/udev.rules.d" \
    OMARCHY_VIVOBOOK_S15_WIREPLUMBER_DIR="$non_matching/wireplumber.conf.d" \
    source "$setup"
)

[[ ! -d "$non_matching/sleep.conf.d" ]] ||
  fail "non-matching hardware does not write Vivobook S 15 sleep configuration"
