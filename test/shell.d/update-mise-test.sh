#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-update-mise"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

run_case() {
  local name="$1"
  local configured_version="$2"
  local bundled_version="$3"
  local migrated="$4"
  local fail_retarget="$5"
  local case_dir="$test_tmp/$name"
  local home="$case_dir/home"
  local state="$case_dir/state"
  local packages="$case_dir/packages"
  local mock_bin="$case_dir/bin"
  local log="$case_dir/mise.log"

  mkdir -p "$home/.config/mise" "$state/omarchy" "$packages" "$mock_bin"
  printf '[tools]\nnode = "%s"\n' "$configured_version" >"$home/.config/mise/config.toml"

  if [[ -n $bundled_version ]]; then
    touch "$packages/node-v${bundled_version}-linux-x64.tar.gz"
  fi
  if [[ $migrated == true ]]; then
    touch "$state/omarchy/iso-node-mise-policy-migrated"
  fi

  cat >"$mock_bin/omarchy-cmd-present" <<'EOF'
#!/bin/bash
exit 0
EOF

  cat >"$mock_bin/mise" <<'EOF'
#!/bin/bash
printf '%s\t%s\n' "${MISE_MINIMUM_RELEASE_AGE:-unset}" "$*" >>"$MISE_TEST_LOG"
if [[ ${MISE_TEST_FAIL_RETARGET:-false} == true && $* == "use -g node@latest" ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$mock_bin/omarchy-cmd-present" "$mock_bin/mise"

  HOME="$home" \
    XDG_STATE_HOME="$state" \
    OMARCHY_PROVISIONING_PACKAGES_DIR="$packages" \
    MISE_TEST_LOG="$log" \
    MISE_TEST_FAIL_RETARGET="$fail_retarget" \
    PATH="$mock_bin:$PATH" \
    bash "$script" >/dev/null 2>"$case_dir/stderr"
}

run_case iso-pin 26.7.0 26.7.0 false false
grep -Fx $'unset\tuse -g node@latest' "$test_tmp/iso-pin/mise.log" >/dev/null ||
  fail "mise update retargets an exact Node pin that matches the bundled ISO tarball"
grep -Fx $'0\tup' "$test_tmp/iso-pin/mise.log" >/dev/null ||
  fail "mise update still upgrades tools after retargeting the ISO Node pin"
[[ -f $test_tmp/iso-pin/state/omarchy/iso-node-mise-policy-migrated ]] ||
  fail "mise update records the completed ISO Node policy migration"
pass "mise update retargets the bundled ISO Node pin once"

run_case manual-pin 24.0.0 26.7.0 false false
if grep -Fq $'\tuse -g node@latest' "$test_tmp/manual-pin/mise.log"; then
  fail "mise update preserves an exact Node pin that does not match the bundled ISO"
fi
grep -Fx $'0\tup' "$test_tmp/manual-pin/mise.log" >/dev/null ||
  fail "mise update still upgrades other tools with a manual Node pin"
[[ -f $test_tmp/manual-pin/state/omarchy/iso-node-mise-policy-migrated ]] ||
  fail "mise update closes the legacy ISO check after preserving a manual pin"
pass "mise update preserves a manual exact Node pin"

run_case already-migrated 26.7.0 26.7.0 true false
if grep -Fq $'\tuse -g node@latest' "$test_tmp/already-migrated/mise.log"; then
  fail "mise update does not reinterpret later Node pins after migration"
fi
pass "mise update leaves later user pins alone after migration"

run_case no-iso-state 26.7.0 '' false false
if grep -Fq $'\tuse -g node@latest' "$test_tmp/no-iso-state/mise.log"; then
  fail "mise update does not retarget exact pins on non-ISO installs"
fi
[[ ! -f $test_tmp/no-iso-state/state/omarchy/iso-node-mise-policy-migrated ]] ||
  fail "mise update does not create an ISO migration marker without provisioning packages"
pass "mise update ignores exact pins on non-ISO installs"

run_case retry-after-failure 26.7.0 26.7.0 false true
[[ ! -f $test_tmp/retry-after-failure/state/omarchy/iso-node-mise-policy-migrated ]] ||
  fail "mise update leaves a failed ISO retarget eligible for retry"
grep -Fq 'will retry on the next update' "$test_tmp/retry-after-failure/stderr" ||
  fail "mise update reports a deferred ISO Node retarget"
pass "mise update retries a failed ISO Node retarget later"
