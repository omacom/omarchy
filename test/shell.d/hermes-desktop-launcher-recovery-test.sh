#!/bin/bash

set -euo pipefail

# Exercises migrations/1791324018.sh: installs a 5-tuple-safe hermes-desktop
# override, skips when already good, links the recovery skill, and leaves
# machines without hermes-desktop alone.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791324018.sh"
[[ -f $migration ]] || fail "Hermes desktop launcher recovery migration exists"
[[ $(stat -c %a "$migration") == "644" ]] || fail "migration is a plain 0644 file"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/omarchy/default/agents/skills/hermes-desktop-recovery"
printf '# recovery skill\n' >"$test_tmp/omarchy/default/agents/skills/hermes-desktop-recovery/SKILL.md"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == 1 ]]
SH
chmod +x "$mock_bin/omarchy-pkg-present"

run_migration() {
  OMARCHY_TEST_DESKTOP_INSTALLED="${OMARCHY_TEST_DESKTOP_INSTALLED:-1}" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_tmp/home" \
    OMARCHY_PATH="$test_tmp/omarchy" \
    bash -euo pipefail "$migration" >/dev/null
}

wrapper="$test_tmp/home/.config/omarchy/bin/hermes-desktop"
skill_link="$test_tmp/home/.hermes/skills/hermes-desktop-recovery"

OMARCHY_TEST_DESKTOP_INSTALLED=0 run_migration || fail "migration exits clean without Hermes Desktop"
[[ ! -e $wrapper ]] || fail "a machine without Hermes Desktop is left alone"
[[ ! -e $skill_link ]] || fail "skill is not linked without Hermes Desktop"
pass "migration only applies where Omarchy installed Hermes Desktop"

rm -rf "$test_tmp/home"
mkdir -p "$test_tmp/home"
run_migration || fail "migration exits clean with Hermes Desktop installed"
[[ -x $wrapper ]] || fail "wrapper is installed executable"
grep -q 'renderer_a11y' "$wrapper" || fail "wrapper unpacks renderer_a11y / 5-tuple"
grep -qE 'HERMES_DESKTOP_DISABLE_GPU|memory\.total' "$wrapper" || fail "wrapper includes weak-NVIDIA / software-GPU handling"
! grep -q '^export HERMES_DESKTOP_IGNORE_EXISTING=1' "$wrapper" || fail "wrapper must not export IGNORE_EXISTING=1"
[[ -L $skill_link && $(readlink "$skill_link") == "$test_tmp/omarchy/default/agents/skills/hermes-desktop-recovery" ]] ||
  fail "recovery skill is linked into ~/.hermes/skills"
pass "migration installs 5-tuple wrapper and links recovery skill"

# Idempotent: good wrapper is left alone (content stamp)
stamp=$(cksum "$wrapper")
run_migration || fail "migration is idempotent on a good wrapper"
[[ $(cksum "$wrapper") == "$stamp" ]] || fail "migration does not rewrite a good wrapper"
pass "migration is idempotent when the override is already good"

# Broken stock-style override (IGNORE_EXISTING + 4-tuple) is replaced
rm -rf "$test_tmp/home"
mkdir -p "$test_tmp/home/.config/omarchy/bin"
cat >"$wrapper" <<'BROKEN'
#!/bin/bash
export HERMES_DESKTOP_IGNORE_EXISTING=1
flags, gpu, store, ozone = opts
BROKEN
chmod +x "$wrapper"
run_migration || fail "migration exits clean when replacing a broken wrapper"
grep -q 'renderer_a11y' "$wrapper" || fail "broken wrapper is replaced with 5-tuple-safe launcher"
! grep -q '^export HERMES_DESKTOP_IGNORE_EXISTING=1' "$wrapper" || fail "replacement drops IGNORE_EXISTING"
pass "migration replaces IGNORE_EXISTING / 4-tuple stock wrappers"

# Install helper prefers user override path
install_ai="$ROOT/bin/omarchy-install-ai-hermes"
grep -q 'HOME/.config/omarchy/bin/hermes-desktop' "$install_ai" ||
  fail "omarchy-install-ai-hermes prefers the user-PATH hermes-desktop override"
! grep -qE 'uwsm-app -- /usr/bin/hermes-desktop' "$install_ai" ||
  fail "omarchy-install-ai-hermes no longer hardcodes only /usr/bin/hermes-desktop"
pass "install-ai-hermes launches via user override when present"

# Skill references exist
skill_dir="$ROOT/default/agents/skills/hermes-desktop-recovery"
for ref in fast-fix.md desktop-recovery-checklist.md wrapper-5-tuple.md; do
  [[ -f $skill_dir/references/$ref ]] || fail "skill reference $ref exists"
done
pass "hermes-desktop-recovery skill ships all referenced docs"
