#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1789200000.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
bin_dir="$home/.local/bin"
mkdir -p "$bin_dir" "$test_dir/bin"

# Stub mise so omarchy-mise-install can pin during rewrite.
cat >"$test_dir/bin/mise" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$test_dir/bin/mise"

run_migration() {
  HOME="$home" PATH="$test_dir/bin:$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

write_mutating_wrapper() {
  local command=$1 package=$2 bin=$3
  cat >"$bin_dir/$command" <<EOF
#!/bin/bash
mise use -g --quiet "$package" || exit 1
exec mise x "$package" -- "$bin" "\$@"
EOF
  chmod +x "$bin_dir/$command"
}

write_mutating_wrapper claude claude claude
write_mutating_wrapper omp github:can1357/oh-my-pi omp

# Already exec-only: migration must leave it alone.
cat >"$bin_dir/already-clean" <<'EOF'
#!/bin/bash
exec mise x "npm:clean" -- "clean" "$@"
EOF
chmod +x "$bin_dir/already-clean"
cp "$bin_dir/already-clean" "$test_dir/already-clean.before"

# A large non-wrapper binary must not be rewritten.
dd if=/dev/zero of="$bin_dir/big-tool" bs=2048 count=1 status=none 2>/dev/null ||
  dd if=/dev/zero of="$bin_dir/big-tool" bs=2048 count=1 2>/dev/null
chmod +x "$bin_dir/big-tool"
cp "$bin_dir/big-tool" "$test_dir/big-tool.before"

run_migration

grep -qF 'exec mise x "claude" -- "claude" "$@"' "$bin_dir/claude" ||
  fail "migration rewrites a mutating wrapper to exec-only"
if grep -q '^mise use -g' "$bin_dir/claude"; then
  fail "rewritten wrapper must not call mise use"
fi
pass "migration rewrites a mutating wrapper to exec-only"

grep -qF 'exec mise x "github:can1357/oh-my-pi" -- "omp" "$@"' "$bin_dir/omp" ||
  fail "migration keeps package and bin names across rewrite"
pass "migration preserves package and bin names"

cmp -s "$test_dir/already-clean.before" "$bin_dir/already-clean" ||
  fail "migration leaves an already exec-only wrapper alone"
pass "migration leaves an already exec-only wrapper alone"

cmp -s "$test_dir/big-tool.before" "$bin_dir/big-tool" ||
  fail "migration does not rewrite a large non-wrapper binary"
pass "migration does not rewrite a large non-wrapper binary"
