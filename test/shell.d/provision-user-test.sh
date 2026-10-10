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

# This helper also runs mise setup through OMARCHY_PATH, independently of the
# install suite below. Keep the fixture from invoking desktop/package setup.
omarchy-refresh-applications() { :; }
export -f omarchy-refresh-applications

# Provisioning prepends $OMARCHY_PATH/bin, which shadows a mock for anything
# Omarchy ships, so the install suite is stubbed out at its path instead. The
# real one rethemes the session it runs in: hyprctl reload against the live
# compositor, gsettings against the live desktop, and a global Node install.
mkdir -p "$test_tmp/install/user"
: >"$test_tmp/install/user/all.sh"

HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" bash "$ROOT/bin/omarchy-provision-user" >/dev/null ||
  fail "omarchy-provision-user finishes"

for skill in omarchy diagnose-crash; do
  link="$test_tmp/home/.gemini/config/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Antigravity"

  link="$test_tmp/home/.hermes/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for Hermes"

  link="$test_tmp/home/.hermes/profiles/james/skills/$skill"
  [[ -L $link && $(readlink "$link") == "$ROOT/default/agents/skills/$skill" ]] ||
    fail "omarchy-provision-user provisions the $skill skill for a Hermes profile"
done

pass "omarchy-provision-user provisions Antigravity and Hermes skills"

# Pi's config root is PI_CODING_AGENT_DIR when set; skills must land there too.
pi_home="$test_tmp/pi-agent"
rm -rf "$test_tmp/home/.pi" "$pi_home"
mkdir -p "$test_tmp/home" "$test_tmp/home/.hermes/profiles/james"
HOME="$test_tmp/home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_INSTALL="$test_tmp/install" PI_CODING_AGENT_DIR="$pi_home" \
  bash "$ROOT/bin/omarchy-provision-user" --force >/dev/null ||
  fail "omarchy-provision-user finishes with PI_CODING_AGENT_DIR set"
[[ -L $pi_home/skills/omarchy && $(readlink "$pi_home/skills/omarchy") == "$ROOT/default/agents/skills/omarchy" ]] ||
  fail "omarchy-provision-user links Pi skills into PI_CODING_AGENT_DIR"
[[ ! -e $test_tmp/home/.pi/agent/skills/omarchy ]] ||
  fail "omarchy-provision-user still writes the default Pi skills path when PI_CODING_AGENT_DIR is set"
pass "omarchy-provision-user links Pi skills into PI_CODING_AGENT_DIR"

# Exercise the real argument list across a filtered target-user environment,
# without executing the upgrade's system mutations or USER_SETUP body.
user_setup_env=$(awk '
  /^apply_user_transition\(\)/ { in_transition = 1 }
  in_transition && /run_as_user env/ { forwarding = 1 }
  forwarding && /bash <<.*USER_SETUP/ { exit }
  forwarding { print }
' "$ROOT/bin/omarchy-upgrade-to-quattro")
[[ -n $user_setup_env ]] || fail "upgrade user environment is found"
forwarded=$(
  target_home="$test_tmp/home"
  backup_suffix=fixture
  yes=1
  PI_CODING_AGENT_DIR="$test_tmp/custom pi root"
  run_as_user() { env -i PATH="$PATH" "$@"; }
  eval "$user_setup_env"$'\n''printenv PI_CODING_AGENT_DIR'
) || fail "upgrade forwards the Pi config directory"
[[ $forwarded == "$test_tmp/custom pi root" ]] || fail "upgrade preserves custom Pi directory across user environment filtering"
pass "upgrade forwards the custom Pi directory to target-user setup"
