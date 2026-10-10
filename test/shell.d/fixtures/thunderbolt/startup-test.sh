#!/bin/bash

set -euo pipefail
source "$ROOT/test/shell.d/base-test.sh"
fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT
for name in admin approve daemon; do
  # Map the security library and stop before service work, including when the
  # suite itself runs as root. Startup checks remain the production code.
  sed -e "s|source /usr/bin/omarchy-security-functions|source $ROOT/bin/omarchy-security-functions|" \
    -e 's|source /usr/share/omarchy/install/helpers/thunderbolt-policy.sh|exit 126|' \
    "$ROOT/bin/omarchy-thunderbolt-authorization-$name" > "$fixture/entry"
  chmod 755 "$fixture/entry"
  printf 'set -p\n' > "$fixture/decoy"
  if BASH_ENV="$fixture/decoy" /usr/bin/bash "$fixture/entry" -p; then
    fail "$name accepts ordinary Bash with a decoy -p"
  fi
  printf 'touch "%s"\n' "$fixture/injected" > "$fixture/startup"
  # The entrypoint must suppress startup files and exported functions before
  # checking EUID or reaching the fixture's service-work boundary.
  if BASH_ENV="$fixture/startup" "$fixture/entry" >/dev/null 2>&1; then
    fail "$name passed the fixture service-work boundary"
  fi
  [[ ! -e $fixture/injected ]] || fail "$name executed BASH_ENV"
  if /usr/bin/env 'BASH_FUNC_source%%=() { echo injected > "$TB_TEST_INJECTED"; }' \
    TB_TEST_INJECTED="$fixture/injected" "$fixture/entry" >/dev/null 2>&1; then
    fail "$name passed the fixture boundary with an exported function"
  fi
  [[ ! -e $fixture/injected ]] || fail "$name imported an exported function"
  pass "Thunderbolt $name rejects unsafe Bash startup"
done
