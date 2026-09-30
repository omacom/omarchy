#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home" "$test_tmp/home/.hermes/profiles/james"

for command in xdg-user-dirs-update xdg-settings xdg-mime; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done
chmod +x "$mock_bin"/*

# Isolate both setup leaves and application refresh. Refresh also invokes the
# mise leaf through OMARCHY_PATH, independently of OMARCHY_INSTALL.
fixture="$test_tmp/omarchy"
mkdir -p "$fixture/bin" "$test_tmp/install/user"
cp "$ROOT/bin/omarchy-provision-user" "$ROOT/bin/omarchy-done" "$fixture/bin/"
ln -s "$ROOT/default" "$fixture/default"
printf '#!/bin/bash\nexit 0\n' >"$fixture/bin/omarchy-refresh-applications"
chmod +x "$fixture/bin/omarchy-refresh-applications"
: >"$test_tmp/install/user/all.sh"

provision() {
  HOME="$test_tmp/home" PATH="$mock_bin:$fixture/bin:$PATH" OMARCHY_PATH="$fixture" \
    OMARCHY_INSTALL="$test_tmp/install" bash "$fixture/bin/omarchy-provision-user" "$@" >/dev/null ||
    fail "omarchy-provision-user finishes"
}
provision

for skill in omarchy diagnose-crash; do
  link="$test_tmp/home/.gemini/config/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$fixture/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Antigravity"

  link="$test_tmp/home/.hermes/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$fixture/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Hermes"

  link="$test_tmp/home/.hermes/profiles/james/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$fixture/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for a Hermes profile"
done

pass "omarchy-provision-user provisions Antigravity and Hermes skills"

provision --force
for skill in omarchy diagnose-crash; do
  for directory in .agents/skills .claude/skills .codex/skills .pi/agent/skills .gemini/config/skills .hermes/skills .hermes/profiles/james/skills; do
    link="$test_tmp/home/$directory/$skill"
    [[ -L $link && $(readlink "$link") == "$fixture/default/agents/skills/$skill" ]] ||
      fail "forced provisioning keeps baseline, Antigravity, and Hermes skill links idempotent"
  done
done
pass "forced provisioning keeps baseline, Antigravity, and Hermes skill links idempotent"

rm -rf "$test_tmp/home"
mkdir -p "$test_tmp/home"
provision
[[ ! -e $test_tmp/home/.hermes/profiles ]] || fail "provisioning does not invent Hermes profiles"
pass "provisioning without existing profiles adds only the default skill homes"
