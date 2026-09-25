#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1790343618.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
bin_dir="$home/.local/bin"
mkdir -p "$bin_dir"

# The migration calls omarchy-mise-install to rewrite a wrapper, so the real
# one has to be reachable: this proves the template it writes today, not a
# copy of it that could drift.
run_migration() {
  HOME="$home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

# The form omarchy-mise-install wrote before wrappers resolved the bin to an
# absolute path.
write_stale_wrapper() {
  local command=$1 package=$2 bin=$3

  cat >"$bin_dir/$command" <<EOF
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "$package" || exit 1
exec mise x "$package" -- "$bin" "\$@"
EOF
  chmod +x "$bin_dir/$command"
}

write_stale_wrapper claude claude claude
write_stale_wrapper omp github:can1357/oh-my-pi omp

run_migration

grep -qF 'bin_path=$(mise which --tool "claude" "claude") || exit 1' "$bin_dir/claude" ||
  fail "migration resolves a stale wrapper's bin to an absolute path"
grep -qF 'exec mise x "claude" -- "$bin_path" "$@"' "$bin_dir/claude" ||
  fail "migration execs the resolved path in a stale wrapper"
pass "migration rewrites a wrapper that execs a bare command name"

grep -qF 'bin_path=$(mise which --tool "github:can1357/oh-my-pi" "omp") || exit 1' "$bin_dir/omp" ||
  fail "migration keeps a wrapper's package and bin when the command name differs"
pass "migration preserves package and bin names"

[[ -x $bin_dir/claude ]] || fail "migration leaves the rewritten wrapper executable"
pass "migration leaves the rewritten wrapper executable"

# Running twice must not touch an already-resolving wrapper.
before=$(cat "$bin_dir/claude")
run_migration
[[ $(cat "$bin_dir/claude") == "$before" ]] || fail "migration is idempotent"
pass "migration is idempotent"

# A generated wrapper someone added a line to is not the exact stale form;
# regenerating would drop that line, so the file is left alone.
cat >"$bin_dir/customized" <<'EOF'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
export SOME_TOKEN=abc123
mise use -g --quiet "customized" || exit 1
exec mise x "customized" -- "customized" "$@"
EOF
printf '#!/bin/bash\necho hi\n' >"$bin_dir/unrelated"
# uv and uvx land in ~/.local/bin from the Python dev env. A wrapper is a few
# short lines, so a real binary must be skipped on size, never read in whole.
head -c 5000000 /dev/urandom >"$bin_dir/uv"
chmod +x "$bin_dir/uv"
ln -s "$bin_dir/claude" "$bin_dir/linked"

customized_before=$(cat "$bin_dir/customized")
unrelated_before=$(cat "$bin_dir/unrelated")

run_migration

[[ $(cat "$bin_dir/customized") == "$customized_before" ]] ||
  fail "migration leaves a generated wrapper a user has added a line to alone"
[[ $(cat "$bin_dir/unrelated") == "$unrelated_before" ]] ||
  fail "migration leaves an unrelated script alone"
[[ -L $bin_dir/linked ]] || fail "migration leaves a symlink alone"
[[ $(stat -c%s "$bin_dir/uv") -eq 5000000 ]] || fail "migration leaves a native binary alone"
pass "migration only rewrites wrappers it recognizes"

# A machine with no ~/.local/bin at all must not fail the run.
empty_home="$test_dir/empty-home"
mkdir -p "$empty_home"
HOME="$empty_home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null ||
  fail "migration succeeds when ~/.local/bin is missing"
pass "migration succeeds when ~/.local/bin is missing"
