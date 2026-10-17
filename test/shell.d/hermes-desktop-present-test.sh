#!/bin/bash

set -euo pipefail

# omarchy-hermes-desktop-present decides whether a Hermes Desktop exists that
# the hermes-desktop package never installed. It is exercised here against
# throwaway HERMES_HOMEs, so both directions of the installer's home
# normalization and every file the installer's own completeness checks read --
# the runtime venv, the bootstrap marker, the native app -- have to agree
# before a standalone install counts as present.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

present() {
  PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-hermes-desktop-present"
}

build_install() {
  local home=$1 complete=${2:-1}

  mkdir -p "$home/hermes-agent/venv/bin" \
    "$home/hermes-agent/apps/desktop/release/linux-unpacked/resources"
  : >"$home/hermes-agent/.hermes-bootstrap-complete"
  : >"$home/hermes-agent/venv/bin/hermes"
  : >"$home/hermes-agent/venv/bin/python"
  chmod +x "$home/hermes-agent/venv/bin/hermes" "$home/hermes-agent/venv/bin/python"
  : >"$home/hermes-agent/apps/desktop/release/linux-unpacked/Hermes"
  chmod +x "$home/hermes-agent/apps/desktop/release/linux-unpacked/Hermes"
  : >"$home/hermes-agent/apps/desktop/release/linux-unpacked/resources/app.asar"
  : >"$home/hermes-agent/apps/desktop/release/linux-unpacked/resources/install-stamp.json"

  if [[ $complete != 1 ]]; then
    rm -f "$home/hermes-agent/$complete"
  fi
}

# The default home, complete: the standalone install the packaged app never
# made counts as present.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
build_install "$test_tmp/home/.hermes"
# HERMES_HOME emptied, so a developer whose shell exports it does not have
# this case read their own install instead of the fixture.
HOME="$test_tmp/home" HERMES_HOME= present || fail "a complete default-home install is recognized"
pass "a complete default-home install is recognized"

# A profile home flattens to the shared root above it, exactly as the
# installer normalizes it: a complete install there is recognized, and the
# profile directory itself is never inspected for a runtime.
build_install "$test_tmp/shared"
build_install "$test_tmp/profiles/ptah"
HOME="$test_tmp" HERMES_HOME="$test_tmp/profiles/ptah" present &&
  fail "a runtime under the profile directory is not the shared root's install"
HOME="$test_tmp" HERMES_HOME="$test_tmp/shared/profiles/ptah" present ||
  fail "a profile home is normalized to the shared root before checking"
pass "a profile home is normalized to the shared root before checking"

# The same tree found through HERMES_HOME without a profiles component.
build_install "$test_tmp/custom"
HOME="$test_tmp" HERMES_HOME="$test_tmp/custom" present ||
  fail "HERMES_HOME overrides the default home"
pass "HERMES_HOME overrides the default home"

# Every file the installer's readiness probes read must be there: dropping any
# one leaves an incomplete install the Install row must not treat as present.
for missing in .hermes-bootstrap-complete venv/bin/hermes venv/bin/python \
  apps/desktop/release/linux-unpacked/Hermes \
  apps/desktop/release/linux-unpacked/resources/app.asar \
  apps/desktop/release/linux-unpacked/resources/install-stamp.json; do
  build_install "$test_tmp/broken" "$missing"
  HOME="$test_tmp" HERMES_HOME="$test_tmp/broken" present &&
    fail "an install missing $missing is not reported present"
done
pass "an install missing any required file is not reported present"

# And nothing at all answers false: the row stays active on a clean machine.
HOME="$test_tmp" HERMES_HOME="$test_tmp/nothing" present &&
  fail "an absent install is not reported present"
pass "an absent install is not reported present"
