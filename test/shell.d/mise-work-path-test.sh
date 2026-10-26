#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

install_home="$test_dir/install-home"
install_log="$test_dir/install-mise.log"
mkdir -p "$install_home" "$test_dir/bin"
cat >"$test_dir/bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MISE_TEST_LOG"
SH
chmod +x "$test_dir/bin/mise"

env \
  HOME="$install_home" \
  MISE_TEST_LOG="$install_log" \
  OMARCHY_SETUP_CONTEXT=runtime \
  PATH="$test_dir/bin:/usr/bin" \
  bash -euo pipefail -c 'source "$1"' bash "$ROOT/install/user/mise-work.sh"

[[ -d $install_home/Work/tries ]] || fail "installer creates the work and tries directories"
[[ ! -e $install_home/Work/.mise.toml ]] || fail "installer does not create a trusted Work Mise config"
[[ ! -e $install_log ]] || fail "installer leaves Node to the lazy system declaration"
pass "new installs do not add project bin directories to PATH"
