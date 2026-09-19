#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789490499.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
bin_dir="$test_home/.local/bin"
mkdir -p "$bin_dir"

# The real omarchy-mise-install is on PATH, so the migration writes today's
# wrapper rather than a copy of what this test thinks it writes.
run_migration() {
  HOME="$test_home" PATH="$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null 2>&1
}

write_stale() {
  local command="$1" package="$2" bin="$3"

  cat >"$bin_dir/$command" <<EOF
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g "$package" || exit 1
exec mise x "$package" -- "$bin" "\$@"
EOF
  chmod +x "$bin_dir/$command"
}

write_stale gh gh gh
run_migration || fail "the migration regenerates a stale wrapper"
grep -qF 'mise use -g --quiet "gh"' "$bin_dir/gh" ||
  fail "the regenerated wrapper quiets mise"
pass "the migration quiets a stale wrapper"

# The whole point of the bug: nothing may reach stdout on a normal run. Asserted
# against a mise that is loud exactly where the real one is — on `use` without
# --quiet — so this checks how the wrapper calls mise rather than reinstalling a
# tool, and cannot pass by the wrapper simply failing.
mock_bin="$test_tmp/mock-bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
if [[ $1 == "use" ]]; then
  for arg in "$@"; do
    [[ $arg == "--quiet" ]] && exit 0
  done
  echo "mise ~/.config/mise/config.toml tools: gh@2.100.0"
  exit 0
fi
[[ $1 == "x" ]] && echo "gh version 2.100.0"
SH
chmod +x "$mock_bin/mise"

noise=$(PATH="$mock_bin:$PATH" bash "$bin_dir/gh" --version </dev/null 2>/dev/null)
[[ $noise == "gh version 2.100.0" ]] ||
  fail "the regenerated wrapper leaves stdout to the tool" "got: $noise"
pass "the regenerated wrapper leaves stdout to the tool"

# The same probe against a stale wrapper, so the assertion above is known to be
# capable of failing.
write_stale loud loud loud
noise=$(PATH="$mock_bin:$PATH" bash "$bin_dir/loud" --version </dev/null 2>/dev/null)
[[ $noise == *"tools:"* ]] ||
  fail "the probe detects the banner a stale wrapper prints" "got: $noise"
pass "the probe detects a stale wrapper's banner"
rm -f "$bin_dir/loud"

before=$(cat "$bin_dir/gh")
run_migration || fail "rerunning the migration succeeds"
[[ $(cat "$bin_dir/gh") == "$before" ]] || fail "rerunning the migration rewrites a current wrapper"
pass "the migration is idempotent"

# Regenerating from the command name alone would install the wrong package
# under the right name, so the spec has to be read back out of the wrapper.
write_stale ghui "npm:@kitlangton/ghui" ghui
write_stale hunk "aqua:modem-dev/hunk" hunk
write_stale omp "github:can1357/oh-my-pi" omp
run_migration || fail "the migration regenerates wrappers with backend specs"
grep -qF 'mise use -g --quiet "npm:@kitlangton/ghui"' "$bin_dir/ghui" ||
  fail "the migration preserves an npm backend spec"
grep -qF 'mise use -g --quiet "aqua:modem-dev/hunk"' "$bin_dir/hunk" ||
  fail "the migration preserves an aqua backend spec"
grep -qF 'mise use -g --quiet "github:can1357/oh-my-pi"' "$bin_dir/omp" ||
  fail "the migration preserves a github backend spec"
pass "the migration preserves backend specs"

# A bin name that differs from the command name has to survive too.
write_stale muse "http:muse[url=https://example.test/m.sh,bin=muse]" muse
run_migration || fail "the migration regenerates a wrapper with a bracketed spec"
grep -qF 'http:muse[url=https://example.test/m.sh,bin=muse]' "$bin_dir/muse" ||
  fail "the migration preserves a bracketed backend spec"
pass "the migration preserves a bracketed backend spec"

# Anything in ~/.local/bin that Omarchy did not write stays exactly as it is.
foreign_ran="$test_tmp/foreign-ran"
foreign_body="#!/bin/bash
touch $foreign_ran
echo foreign"
printf '%s\n' "$foreign_body" >"$bin_dir/foreign"
chmod +x "$bin_dir/foreign"
run_migration || fail "the migration succeeds alongside a foreign command"
[[ $(cat "$bin_dir/foreign") == "$foreign_body" ]] ||
  fail "the migration leaves a foreign command alone"
[[ ! -e $foreign_ran ]] || fail "the migration does not run a foreign command"
pass "the migration preserves a foreign command"

# A wrapper whose arguments were %q-escaped rather than double-quoted is left
# alone: skipping one is a stale wrapper, misparsing one is a broken command.
escaped_body='#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g npm:pkg\$odd || exit 1
exec mise x npm:pkg\$odd -- odd "$@"'
printf '%s\n' "$escaped_body" >"$bin_dir/odd"
chmod +x "$bin_dir/odd"
run_migration || fail "the migration succeeds over an escaped wrapper"
[[ $(cat "$bin_dir/odd") == "$escaped_body" ]] ||
  fail "the migration leaves an escaped wrapper alone"
pass "the migration preserves an escaped wrapper"

# A non-executable file is not a command anyone is running.
write_stale notrun notrun notrun
chmod -x "$bin_dir/notrun"
run_migration || fail "the migration succeeds over a non-executable file"
grep -qF 'mise use -g "notrun"' "$bin_dir/notrun" ||
  fail "the migration rewrites a non-executable file"
pass "the migration skips a non-executable file"

# An empty ~/.local/bin, and a missing one, are both normal.
rm -rf "${bin_dir:?}"/*
run_migration || fail "the migration succeeds with an empty bin directory"
pass "the migration handles an empty bin directory"

rm -rf "$bin_dir"
run_migration || fail "the migration succeeds with no bin directory"
pass "the migration handles a missing bin directory"
