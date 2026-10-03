#!/bin/bash

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

# Every resume drop-in hibernation-setup writes must be removed again, or a
# later setup keeps the old swapfile's resume_offset and resume breaks.
for drop_in in /etc/mkinitcpio.conf.d/omarchy_resume.conf /etc/limine-entry-tool.d/resume.conf; do
  grep -F "$drop_in" "$ROOT/bin/omarchy-hibernation-setup" >/dev/null ||
    fail "hibernation setup writes $drop_in"
  grep -F "$drop_in" "$ROOT/bin/omarchy-hibernation-remove" >/dev/null ||
    fail "hibernation remove deletes $drop_in"
done
pass "hibernation remove deletes the resume drop-ins setup writes"

remove_line=$(grep -n 'sudo rm "$RESUME_DROP_IN"' "$ROOT/bin/omarchy-hibernation-remove" | cut -d: -f1)
rebuild_line=$(grep -n '^sudo limine-mkinitcpio' "$ROOT/bin/omarchy-hibernation-remove" | cut -d: -f1)
[[ -n $remove_line && -n $rebuild_line ]] ||
  fail "hibernation remove keeps recognizable drop-in removal and rebuild steps"
(( remove_line < rebuild_line )) ||
  fail "hibernation remove drops resume parameters before rebuilding the UKI"
pass "hibernation remove drops resume parameters before rebuilding the UKI"

# A machine that removed hibernation before remove cleaned up still has the old drop-in.
! grep -F '[[ ! -f $RESUME_DROP_IN ]]' "$ROOT/bin/omarchy-hibernation-setup" >/dev/null ||
  fail "hibernation setup rewrites a resume drop-in left by an earlier setup"
grep -F 'sudo tee "$RESUME_DROP_IN"' "$ROOT/bin/omarchy-hibernation-setup" >/dev/null ||
  fail "hibernation setup writes the resume drop-in"
grep -F 'sudo rm -f "$RESUME_DROP_IN"' "$ROOT/bin/omarchy-hibernation-setup" >/dev/null ||
  fail "hibernation setup drops a stale resume drop-in when it cannot find the offset"
pass "hibernation setup rewrites a resume drop-in left by an earlier setup"
