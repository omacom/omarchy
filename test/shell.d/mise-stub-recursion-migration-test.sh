#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1790544200.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
bin_dir="$home/.local/bin"
mkdir -p "$bin_dir"

run_migration() {
  HOME="$home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
}

write_unguarded_quiet() {
  local command=$1 package=$2 bin=$3

  cat >"$bin_dir/$command" <<EOF
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "$package" || exit 1
exec mise x "$package" -- "$bin" "\$@"
EOF
  chmod +x "$bin_dir/$command"
}

write_unguarded_quiet claude claude claude
write_unguarded_quiet omp github:can1357/oh-my-pi omp
write_unguarded_quiet ghui npm:@kitlangton/ghui ghui

# Already guarded: must be left alone.
cat >"$bin_dir/guarded" <<'EOF'
#!/bin/bash
# mise resolves the command below by PATH when the tool does not provide it,
# which finds this stub again. Fail fast rather than recursing until the machine
# runs out of processes.
if [ -n "$_OMARCHY_MISE_GUARD_GUARDED" ]; then
  printf '%s: mise could not provide "%s" from tool "%s" (is it installed?)\n' "guarded" "guarded" "guarded" >&2
  exit 127
fi
export _OMARCHY_MISE_GUARD_GUARDED=1
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "guarded" || exit 1
exec mise x "guarded" -- "guarded" "$@"
EOF
chmod +x "$bin_dir/guarded"
guarded_before=$(cat "$bin_dir/guarded")

run_migration

for spec in 'claude claude claude' 'omp github:can1357/oh-my-pi omp' 'ghui npm:@kitlangton/ghui ghui'; do
  read -r command package bin <<<"$spec"
  grep -Fq "mise which --tool \"$package\" -- \"$bin\"" "$bin_dir/$command" ||
    fail "migration preserves the package and bin in tool-scoped resolution"
  grep -Fq 'exec mise x' "$bin_dir/$command" || fail "migration retains mise execution environment"
  grep -Fq '"$bin_path" "$@"' "$bin_dir/$command" || fail "migration executes the absolute target with its arguments"
  grep -Fq '_OMARCHY_MISE_GUARD_' "$bin_dir/$command" && fail "migration must not leak a guard into real tools"
done
pass "migration replaces old wrappers with package-scoped absolute execution"

[[ $(cat "$bin_dir/guarded") == "$guarded_before" ]] ||
  fail "migration leaves an already-guarded wrapper alone"
pass "migration leaves an already-guarded wrapper alone"

before=$(cat "$bin_dir/claude")
run_migration
[[ $(cat "$bin_dir/claude") == "$before" ]] || fail "migration is idempotent"
pass "migration is idempotent"

# Hand-edited / unrelated files stay untouched.
cat >"$bin_dir/hand-written" <<'EOF'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "something" || exit 1
echo "and then something else entirely"
EOF
hand_written_before=$(cat "$bin_dir/hand-written")
run_migration
[[ $(cat "$bin_dir/hand-written") == "$hand_written_before" ]] ||
  fail "migration leaves a hand-written script alone"
pass "migration only rewrites unguarded quiet wrappers"

empty_home="$test_dir/empty-home"
mkdir -p "$empty_home"
HOME="$empty_home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null ||
  fail "migration succeeds when ~/.local/bin is missing"
pass "migration succeeds when ~/.local/bin is missing"
