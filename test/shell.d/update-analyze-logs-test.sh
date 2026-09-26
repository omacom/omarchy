#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

write_log() {
  local name="$1"
  cat >"$test_tmp/$name"
}

analyze() {
  OMARCHY_UPDATE_LOG="$test_tmp/$1" "$ROOT/bin/omarchy-update-analyze-logs"
}

assert_quiet() {
  local name="$1" description="$2" output
  output=$(analyze "$name")
  [[ -z $output ]] || fail "$description" "$output"
  pass "$description"
}

assert_warns() {
  local name="$1" description="$2" output
  output=$(analyze "$name")
  [[ $output == *"Initramfs generation may have failed"* ]] || fail "$description" "$output"
  pass "$description"
}

write_log hook-only <<'EOF'
(5/5) Updating linux initcpios...
EOF
assert_quiet hook-only "initramfs hook banner without a generation is not a failure"

write_log succeeded <<'EOF'
(5/5) Updating linux initcpios...
==> Building image from preset: /etc/mkinitcpio.d/linux-asahi.preset: 'default'
==> Initcpio image generation successful
EOF
assert_quiet succeeded "successful initramfs generation is not a failure"

write_log both-presets <<'EOF'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
==> Initcpio image generation successful
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'fallback'
==> Initcpio image generation successful
EOF
assert_quiet both-presets "every started preset succeeding is not a failure"

write_log uki <<'EOF'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
==> Unified kernel image generation successful
EOF
assert_quiet uki "a successful unified kernel image is not a failure"

write_log skipped <<'EOF'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
==> WARNING: No kernel version specified. Skipping image 'default'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'fallback'
==> WARNING: No image or UKI specified. Skipping image 'fallback'
EOF
assert_quiet skipped "a preset mkinitcpio skips is not a failure"

write_log started <<'EOF'
(5/5) Updating linux initcpios...
==> Building image from preset: /etc/mkinitcpio.d/linux-asahi.preset: 'default'
EOF
assert_warns started "a started generation without success is a failure"

write_log skipped-then-stuck <<'EOF'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
==> WARNING: No kernel version specified. Skipping image 'default'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'fallback'
EOF
assert_warns skipped-then-stuck "a skipped preset does not hide a generation that never finished"

write_log partial <<'EOF'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
==> Initcpio image generation successful
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'fallback'
==> ERROR: Initcpio image generation FAILED: 'bsdtar' reported an error
EOF
assert_warns partial "one failed preset is a failure even when another succeeded"

write_log incomplete <<'EOF'
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
==> WARNING: errors were encountered during the build. The image may not be complete.
EOF
assert_warns incomplete "an incomplete initramfs image is a failure"
