#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# 60-omarchy-io-scheduler.rules sets kyber on every whole disk. An empty USB
# card reader exposes a 0-byte disk whose queue is still coming up during
# probe: udev's scheduler write fails with EBUSY and is never retried, so the
# rule must skip zero-size disks and let the media-insert change event set
# the scheduler instead (#17500).

rules="$ROOT/etc/udev/rules.d/60-omarchy-io-scheduler.rules"

[[ -e $rules ]] || fail "io-scheduler rule file exists at $rules"

# udev's own parser must accept the file: a malformed rule silently matches
# nothing and every disk keeps its default scheduler. Skip on a systemd too
# old to have the verify subcommand.
if udevadm verify --help >/dev/null 2>&1; then
  if out=$(udevadm verify "$rules" 2>&1); then
    pass "udev parses the rule file"
  else
    fail "udev parses the rule file" "$out"
  fi
else
  skip "udevadm verify unavailable; skipping parse check"
fi

rule=$(grep -F 'ATTR{queue/scheduler}="kyber"' "$rules") ||
  fail "rule sets the kyber scheduler" "no queue/scheduler assignment in $rules"

if [[ $rule == *'ATTR{size}!="0"'* ]]; then
  pass "rule skips zero-size (no media) disks"
else
  fail "rule skips zero-size (no media) disks" "$rule"
fi
