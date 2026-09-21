#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Verify the shipped template sets default_entry: 1
template="$ROOT/default/limine/limine.conf"
[[ -f $template ]] || fail "shipped limine.conf template exists"
grep -qE '^[[:space:]]*default_entry:[[:space:]]*1[[:space:]]*$' "$template" ||
  fail "shipped limine template sets default_entry: 1"
pass "shipped limine template defaults to first boot entry"

# Test the migration
migration="$ROOT/migrations/1789984529.sh"
[[ -f $migration ]] || fail "migration 1789984529.sh exists"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export PATH="$tmp_dir/bin:$PATH"

# Stub sudo to run commands directly without privileges in the test sandbox
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat > "$tmp_dir/bin/limine-enroll-config" <<'SH'
#!/bin/bash
printf 'enroll\n' >> "$ENROLL_LOG"
exit "${ENROLL_EXIT:-0}"
SH
chmod +x "$tmp_dir/bin/sudo" "$tmp_dir/bin/limine-enroll-config"
export ENROLL_LOG="$tmp_dir/enroll.log"
export HOME="$tmp_dir/home"
mkdir -p "$HOME"

# Scenario 1: default_entry: 2 gets updated to default_entry: 1
test_conf="$tmp_dir/limine.conf"
cat > "$test_conf" <<'EOF'
#timeout: 3
default_entry: 2
interface_branding: Omarchy Bootloader
EOF

OMARCHY_LIMINE_CONF="$test_conf" bash -euo pipefail "$migration" >/dev/null

grep -qE '^[[:space:]]*default_entry:[[:space:]]*1[[:space:]]*$' "$test_conf" ||
  fail "migration updates default_entry 2 to 1"
pass "migration updates default_entry from 2 to 1"

# Scenario 2: Idempotence - running again leaves it at 1
OMARCHY_LIMINE_CONF="$test_conf" bash -euo pipefail "$migration" >/dev/null
grep -qE '^[[:space:]]*default_entry:[[:space:]]*1[[:space:]]*$' "$test_conf" ||
  fail "migration is idempotent"
pass "migration is idempotent"

# Scenario 3: Custom default_entry (e.g. 3) is preserved
cat > "$test_conf" <<'EOF'
default_entry: 3
interface_branding: Omarchy Bootloader
EOF

OMARCHY_LIMINE_CONF="$test_conf" bash -euo pipefail "$migration" >/dev/null
grep -qE '^[[:space:]]*default_entry:[[:space:]]*3[[:space:]]*$' "$test_conf" ||
  fail "migration preserves custom default_entry"
pass "migration preserves custom default_entry"

# Scenario 4: Missing limine.conf (non-Limine systems) exits cleanly without error
missing_conf="$tmp_dir/nonexistent/limine.conf"
OMARCHY_LIMINE_CONF="$missing_conf" bash -euo pipefail "$migration" >/dev/null
pass "migration exits cleanly when limine.conf is missing"

# Multi-digit defaults must not be interpreted as entry 2.
for entry in 20 21 200; do
  printf 'default_entry: %s\n' "$entry" > "$test_conf"
  : > "$ENROLL_LOG"
  OMARCHY_LIMINE_CONF="$test_conf" bash -euo pipefail "$migration" >/dev/null
  [[ $(cat "$test_conf") == "default_entry: $entry" ]] || fail "migration preserves entry $entry"
  [[ ! -s $ENROLL_LOG ]] || fail "custom entries do not trigger enrollment"
done
pass "migration preserves multi-digit custom defaults"

printf 'default_entry: 2\n' > "$test_conf"
: > "$ENROLL_LOG"
if ENROLL_EXIT=1 OMARCHY_LIMINE_CONF="$test_conf" bash -euo pipefail "$migration" >/dev/null; then
  fail "failed enrollment keeps the migration pending"
fi
[[ $(cat "$test_conf") == "default_entry: 1" ]] || fail "config was updated before enrollment"
[[ $(cat "$ENROLL_LOG") == "enroll" ]] || fail "migration enrolls the modified config"
: > "$ENROLL_LOG"
OMARCHY_LIMINE_CONF="$test_conf" bash -euo pipefail "$migration" >/dev/null
[[ $(cat "$ENROLL_LOG") == "enroll" ]] || fail "retry enrolls an already-updated config"
pass "migration propagates enrollment failure and retries it"
