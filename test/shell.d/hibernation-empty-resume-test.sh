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

mig="$ROOT/migrations/1789972000.sh"
[[ -f $mig ]] || fail "migration 1789972000.sh exists"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export MIGRATION_LOG="$tmp/calls"
cat >"$tmp/omarchy-hibernation-setup" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MIGRATION_LOG"
exit 23
SH
chmod +x "$tmp/omarchy-hibernation-setup"
sed -e "s|/etc/limine-entry-tool.d/resume.conf|$tmp/resume.conf|" \
    -e "s|/var/lib/omarchy/hibernation-resume-rebuild|$tmp/pending|" "$mig" >"$tmp/migration"

line='KERNEL_CMDLINE[default]+=" resume= resume_offset=4242"'
printf '%s\n' "$line" >"$tmp/resume.conf"
status=0
PATH="$tmp:$PATH" bash "$tmp/migration" || status=$?
[[ $status == 23 && $(<"$MIGRATION_LOG") == --force && $(<"$tmp/resume.conf") == "$line" ]] ||
  fail "migration delegates repair and preserves a failed repair for retry"
pass "hibernation migration delegates repair and preserves an unsuccessful repair"
