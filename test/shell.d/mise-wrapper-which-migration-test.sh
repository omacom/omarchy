#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1790702027.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
bin_dir="$home/.local/bin"
mkdir -p "$bin_dir"

# The migration calls omarchy-mise-install to rewrite a wrapper, so the real
# one has to be reachable: this proves the template it writes today.
run_migration() {
  HOME="$home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

write_quiet_wrapper() {
  local command=$1 package=$2 bin=$3

  cat >"$bin_dir/$command" <<EOT
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "$package" || exit 1
exec mise x "$package" -- "$bin" "\$@"
EOT
  chmod +x "$bin_dir/$command"
}

write_quiet_wrapper gh gh gh
write_quiet_wrapper omp github:can1357/oh-my-pi omp

# A generated wrapper someone added a line to keeps that line.
cat >"$bin_dir/customized" <<'EOT'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
export SOME_TOKEN=abc123
mise use -g --quiet "customized" || exit 1
exec mise x "customized" -- "customized" "$@"
EOT
printf '#!/bin/bash\necho hi\n' >"$bin_dir/unrelated"
customized_before=$(cat "$bin_dir/customized")
unrelated_before=$(cat "$bin_dir/unrelated")

run_migration

grep -qF 'bin=$(mise which --tool "gh" "gh") || exit 1' "$bin_dir/gh" ||
  fail "migration resolves a wrapper's bin with mise which" "$(cat "$bin_dir/gh")"
grep -qF 'exec mise x "gh" -- "$bin" "$@"' "$bin_dir/gh" ||
  fail "migration runs the resolved bin" "$(cat "$bin_dir/gh")"
pass "migration moves a wrapper onto mise which"

grep -qF 'bin=$(mise which --tool "github:can1357/oh-my-pi" "omp") || exit 1' "$bin_dir/omp" ||
  fail "migration keeps package and bin names when the command name differs"
[[ -x $bin_dir/omp ]] || fail "migration leaves the rewritten wrapper executable"
pass "migration preserves package and bin names"

before=$(cat "$bin_dir/gh")
run_migration
[[ $(cat "$bin_dir/gh") == "$before" ]] || fail "migration is idempotent"
pass "migration is idempotent"

[[ $(cat "$bin_dir/customized") == "$customized_before" ]] ||
  fail "migration leaves a wrapper a user has added a line to alone"
[[ $(cat "$bin_dir/unrelated") == "$unrelated_before" ]] ||
  fail "migration leaves an unrelated script alone"
pass "migration only rewrites wrappers it recognizes"

empty_home="$test_dir/empty-home"
mkdir -p "$empty_home"
HOME="$empty_home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null ||
  fail "migration succeeds when ~/.local/bin is missing"
pass "migration succeeds when ~/.local/bin is missing"
