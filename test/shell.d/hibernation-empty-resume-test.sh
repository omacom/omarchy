#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-hibernation-setup"
[[ -f $setup ]] || fail "hibernation setup is present"

# Must require both device and offset before writing the drop-in.
grep -Eq '\[\[ -z \$RESUME_DEVICE \|\| -z \$RESUME_OFFSET \]\]' "$setup" ||
  fail "setup refuses an empty resume device or offset" "$(grep -n RESUME_ "$setup" | head -20)"

# Writing the drop-in must follow the dual check (not an offset-only gate).
awk '
  /\[\[ -z \$RESUME_DEVICE \|\| -z \$RESUME_OFFSET \]\]/ { guarded=1 }
  /KERNEL_CMDLINE\[default\].*resume=\$RESUME_DEVICE/ {
    if (!guarded) { print "unguarded write at line " NR; exit 1 }
  }
' "$setup" || fail "resume.conf write is guarded by the empty device/offset check"

grep -Fq 'resume=[[:space:]]+resume_offset=' "$setup" ||
  fail "setup detects the empty-device drop-in pattern on re-entry"

mig="$ROOT/migrations/1789972000.sh"
[[ -f $mig ]] || fail "migration 1789972000.sh exists"
grep -Fq 'resume=[[:space:]]+resume_offset=' "$mig" ||
  fail "migration removes empty resume= drop-ins"

pass "hibernation setup and migration refuse empty resume= device"
