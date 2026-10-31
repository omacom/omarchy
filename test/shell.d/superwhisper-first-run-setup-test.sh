#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

first_run_step="$ROOT/install/user/first-run/setup-superwhisper.sh"
migration="$ROOT/migrations/1792143467.sh"

[[ -f $first_run_step ]] || fail "first-run Superwhisper step exists"
[[ -f $migration ]] || fail "migration for already-installed hosts exists"

# omarchy-provision-first-run must invoke the step, or a fresh install never
# sets the profile up.
grep -q "first-run/setup-superwhisper.sh" "$ROOT/bin/omarchy-provision-first-run" ||
  fail "omarchy-provision-first-run runs the Superwhisper setup step"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
shims="$test_dir/bin"
mkdir -p "$shims" "$home"

# A setup-user that records it ran and creates the app/current symlink the
# real one creates, which the profile-already-set-up guard checks.
setup_user="$test_dir/setup-user"
cat >"$setup_user" <<STUB
#!/bin/bash
echo run >>"$test_dir/setup-runs"
mkdir -p "\$HOME/.local/share/superwhisper/app" "\$HOME/.local/share/superwhisper/real"
ln -sfn "\$HOME/.local/share/superwhisper/real" "\$HOME/.local/share/superwhisper/app/current"
STUB
chmod +x "$setup_user"

# The superwhisper CLI starts with the conflicting default profile: RightAlt
# hold, no toggle, exactly what the installer has to move away from.
cat >"$shims/superwhisper" <<STUB
#!/bin/bash
echo "\$*" >>"$test_dir/superwhisper-calls"
if [[ \$1 == shortcuts && \$2 == show ]]; then
  echo '{"shortcuts":{"hold":"RightAlt","toggle":""}}'
fi
STUB

cat >"$shims/omarchy-pkg-missing" <<'STUB'
#!/bin/bash
[[ $OMARCHY_TEST_PKG_PRESENT == 1 ]] && exit 1
exit 0
STUB

cat >"$shims/omarchy-default-dictation" <<'STUB'
#!/bin/bash
echo "${OMARCHY_TEST_DICTATION:-}"
STUB

chmod +x "$shims/"*

run_step() {
  HOME="$home" \
  OMARCHY_SUPERWHISPER_SETUP="$setup_user" \
  OMARCHY_TEST_PKG_PRESENT="${OMARCHY_TEST_PKG_PRESENT:-1}" \
  OMARCHY_TEST_DICTATION="${OMARCHY_TEST_DICTATION:-superwhisper}" \
  PATH="$shims:$PATH" \
  bash -e "$first_run_step"
}

superwhisper_calls() { cat "$test_dir/superwhisper-calls" 2>/dev/null || true; }
setup_runs() { wc -l <"$test_dir/setup-runs" 2>/dev/null || echo 0; }

# The preset, installed, never-set-up case is what fresh installs ship: the
# step must run setup-user and reseed the conflicting shortcuts.
run_step
[[ $(setup_runs) == 1 ]] || fail "step runs setup-user for a preset install"
pass "step runs setup-user for a preset install"

grep -q "shortcuts set hold RightSuper" <<<"$(superwhisper_calls)" ||
  fail "step moves the conflicting RightAlt hold aside" "$(superwhisper_calls)"
grep -q "shortcuts set toggle Alt+Space" <<<"$(superwhisper_calls)" ||
  fail "step sets the Omarchy toggle shortcut" "$(superwhisper_calls)"
pass "step reseeds the conflicting shortcuts"

# Re-running does nothing once the profile exists: setup-user must not run
# again and reseed preferences over the user's own.
: >"$test_dir/superwhisper-calls"
run_step
[[ $(setup_runs) == 1 ]] || fail "step skips an already-set-up profile"
[[ -z $(superwhisper_calls) ]] || fail "step leaves shortcuts alone once set up"
pass "step skips an already-set-up profile"

# A host that chose another backend is left alone even though the package is
# installed.
rm -rf "$home/.local/share/superwhisper"
: >"$test_dir/superwhisper-calls"
OMARCHY_TEST_DICTATION=voxtype run_step
[[ $(setup_runs) == 1 ]] || fail "step skips a host that chose another backend"
[[ -z $(superwhisper_calls) ]] || fail "step leaves another backend's shortcuts alone"
pass "step skips a host that chose another backend"

# A host without the package is left alone.
: >"$test_dir/superwhisper-calls"
OMARCHY_TEST_PKG_PRESENT=0 run_step
[[ $(setup_runs) == 1 ]] || fail "step skips a host without superwhisper-bin"
pass "step skips a host without superwhisper-bin"

# The migration reaches hosts whose first run already completed. It runs the
# same step, so the whole scenario replays through the migration itself.
run_migration() {
  HOME="$home" \
  OMARCHY_PATH="$ROOT" \
  OMARCHY_SUPERWHISPER_SETUP="$setup_user" \
  OMARCHY_TEST_PKG_PRESENT=1 \
  OMARCHY_TEST_DICTATION=superwhisper \
  PATH="$shims:$PATH" \
  bash -euo pipefail "$migration" >/dev/null
}

before=$(setup_runs)
run_migration
[[ $(setup_runs) == $((before + 1)) ]] ||
  fail "migration finishes an unset preset profile"
pass "migration finishes an unset preset profile"

run_migration
[[ $(setup_runs) == $((before + 1)) ]] || fail "migration is idempotent"
pass "migration is idempotent"

# The migration is inert on hosts that do not need it: no package, no preset,
# or a profile that is already set up.
: >"$test_dir/superwhisper-calls"
OMARCHY_TEST_PKG_PRESENT=0 run_migration
OMARCHY_TEST_DICTATION=voxtype run_migration
run_migration
[[ $(setup_runs) == $((before + 1)) ]] || fail "migration skips hosts that do not need it"
[[ -z $(superwhisper_calls) ]] || fail "migration touches no shortcuts on hosts that do not need it"
pass "migration skips hosts that do not need it"
