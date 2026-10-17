#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
bin_dir="$test_home/.local/bin"
mkdir -p "$bin_dir"
migration="$ROOT/migrations/1791640215.sh"

stale_wrapper() {
  local command=$1 package=$2 bin=$3
  printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"\n' "$package" "$package" "$bin" >"$bin_dir/$command"
  chmod +x "$bin_dir/$command"
}

stale_wrapper claude claude claude
stale_wrapper alias npm:example tool
stale_wrapper customized npm:example tool
printf '# custom environment\n' >>"$bin_dir/customized"
stale_wrapper mismatched one tool
sed -i 's/exec mise x "one"/exec mise x "other"/' "$bin_dir/mismatched"
stale_wrapper target npm:example tool
mv "$bin_dir/target" "$test_dir/target"
ln -s "$test_dir/target" "$bin_dir/linked"
printf '#!/bin/bash\necho custom\n' >"$bin_dir/unrelated"
truncate -s 2048 "$bin_dir/binary"

run_migration() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null
}

before=$(sha256sum "$bin_dir/customized" "$bin_dir/mismatched" "$test_dir/target" "$bin_dir/unrelated" "$bin_dir/binary")
run_migration
grep -qF 'mise which --tool "claude" "claude"' "$bin_dir/claude" || fail "migration repairs existing wrappers"
grep -qF 'mise which --tool "npm:example" "tool"' "$bin_dir/alias" || fail "migration preserves aliases and package names"
[[ -x $bin_dir/claude && -x $bin_dir/alias ]] || fail "repaired wrappers remain executable"
[[ $(sha256sum "$bin_dir/customized" "$bin_dir/mismatched" "$test_dir/target" "$bin_dir/unrelated" "$bin_dir/binary") == "$before" && -L $bin_dir/linked ]] ||
  fail "migration leaves custom scripts, symlinks, and binaries intact"
pass "migration repairs shipped wrappers and aliases while preserving user files"

before=$(sha256sum "$bin_dir/claude" "$bin_dir/alias")
run_migration
[[ $(sha256sum "$bin_dir/claude" "$bin_dir/alias") == "$before" ]] || fail "migration is idempotent"
pass "migration leaves repaired wrappers unchanged on a second run"

HOME="$test_dir/absent" OMARCHY_PATH="$ROOT" bash -euo pipefail "$migration" >/dev/null || fail "migration tolerates a missing bin directory"
pass "migration tolerates a missing bin directory"
