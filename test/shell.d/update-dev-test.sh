#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
git_log="$test_tmp/git.log"
git_env_log="$test_tmp/git.env.log"
checkout="$test_tmp/checkout"
mkdir -p "$stub_bin" "$checkout"

cat >"$stub_bin/git" <<'SH'
#!/bin/bash

printf '%s\n' "$*" >>"$TEST_GIT_LOG"

[[ $1 == "-C" ]] || exit 1
shift 2

case "$1" in
  rev-parse)
    case "$2" in
      --is-inside-work-tree)
        [[ ${TEST_GIT_CHECKOUT:-yes} == "yes" ]] || exit 1
        echo true
        ;;
      --abbrev-ref)
        [[ ${TEST_GIT_UPSTREAM:-origin/quattro} != "none" ]] || exit 1
        echo "${TEST_GIT_UPSTREAM:-origin/quattro}"
        ;;
      *)
        exit 1
        ;;
    esac
    ;;
  pull)
    printf 'GIT_TERMINAL_PROMPT=%s\n' "${GIT_TERMINAL_PROMPT-<unset>}" >>"$TEST_GIT_ENV_LOG"
    printf 'GIT_ASKPASS=%s\n' "${GIT_ASKPASS-<unset>}" >>"$TEST_GIT_ENV_LOG"
    printf 'GIT_SSH_COMMAND=%s\n' "${GIT_SSH_COMMAND-<unset>}" >>"$TEST_GIT_ENV_LOG"
    if [[ ${TEST_GIT_PULL:-ok} == "fail" ]]; then
      echo "fatal: pull failed (stub)" >&2
      exit 1
    fi
    [[ $2 == "--ff-only" ]]
    ;;
  *)
    exit 1
    ;;
esac
SH
chmod +x "$stub_bin/git"

run_dev_update() {
  OMARCHY_PATH="$1" \
    TEST_GIT_LOG="$git_log" \
    TEST_GIT_ENV_LOG="$git_env_log" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-update-dev"
}

: >"$git_log"
run_dev_update /usr/share/omarchy
[[ ! -s $git_log ]] || fail "package-backed updates do not invoke git" "$(cat "$git_log")"
pass "package-backed updates skip the dev checkout step"

: >"$git_log"
run_dev_update "$checkout"
grep -Fx -- "-C $checkout pull --ff-only" "$git_log" >/dev/null ||
  fail "dev checkout update pulls its upstream with fast-forward only" "$(cat "$git_log")"
pass "dev checkout update pulls its configured upstream"

: >"$git_log"
TEST_GIT_UPSTREAM=none run_dev_update "$checkout"
if grep -q ' pull ' "$git_log"; then
  fail "dev checkout without an upstream is not pulled" "$(cat "$git_log")"
fi
pass "dev checkout without an upstream is skipped safely"

: >"$git_log"
if TEST_GIT_CHECKOUT=no run_dev_update "$checkout" >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"; then
  fail "invalid dev checkout fails the update"
fi
grep -F "OMARCHY_PATH is not a git checkout: $checkout" "$test_tmp/invalid.err" >/dev/null ||
  fail "invalid dev checkout reports the configured path" "$(cat "$test_tmp/invalid.err")"
pass "invalid dev checkout fails with a useful error"

grep -qE '^ *omarchy-update-dev$' "$ROOT/bin/omarchy-update" ||
  fail "top-level update includes the dev checkout step"
pass "top-level update includes the dev checkout step"

: >"$git_log"
: >"$git_env_log"
( unset OMARCHY_UPDATE_UNATTENDED GIT_TERMINAL_PROMPT GIT_ASKPASS GIT_SSH_COMMAND
  run_dev_update "$checkout" >/dev/null 2>&1 )
[[ $(cat "$git_env_log") == *"GIT_TERMINAL_PROMPT=<unset>"* ]] ||
  fail "interactive dev pull does not export GIT_TERMINAL_PROMPT" "$(cat "$git_env_log")"
[[ $(cat "$git_env_log") == *"GIT_ASKPASS=<unset>"* ]] ||
  fail "interactive dev pull does not export GIT_ASKPASS" "$(cat "$git_env_log")"
[[ $(cat "$git_env_log") == *"GIT_SSH_COMMAND=<unset>"* ]] ||
  fail "interactive dev pull does not export GIT_SSH_COMMAND" "$(cat "$git_env_log")"
pass "interactive dev pull exports nothing new"

: >"$git_log"
: >"$git_env_log"
( unset GIT_TERMINAL_PROMPT GIT_ASKPASS GIT_SSH_COMMAND
  OMARCHY_UPDATE_UNATTENDED=1 run_dev_update "$checkout" >/dev/null 2>&1 )
grep -Fx "GIT_TERMINAL_PROMPT=0" "$git_env_log" >/dev/null ||
  fail "unattended dev pull disables terminal prompts" "$(cat "$git_env_log")"
grep -Fx "GIT_ASKPASS=" "$git_env_log" >/dev/null ||
  fail "unattended dev pull clears GIT_ASKPASS to fail closed" "$(cat "$git_env_log")"
grep -F "GIT_SSH_COMMAND=" "$git_env_log" | grep -F -- "-oBatchMode=yes" >/dev/null ||
  fail "unattended dev pull forces SSH BatchMode" "$(cat "$git_env_log")"
pass "unattended dev pull exports nonprompting git transport env"

: >"$git_log"
: >"$git_env_log"
( unset GIT_TERMINAL_PROMPT GIT_ASKPASS
  OMARCHY_UPDATE_UNATTENDED=1 GIT_SSH_COMMAND=custom-ssh run_dev_update "$checkout" >/dev/null 2>&1 )
grep -Fx "GIT_SSH_COMMAND=custom-ssh" "$git_env_log" >/dev/null ||
  fail "explicit user GIT_SSH_COMMAND is preserved unattended" "$(cat "$git_env_log")"
pass "unattended dev pull preserves explicit user GIT_SSH_COMMAND"

: >"$git_log"
: >"$git_env_log"
if ( unset OMARCHY_UPDATE_UNATTENDED; TEST_GIT_PULL=fail run_dev_update "$checkout" >"$test_tmp/pull-fail.out" 2>"$test_tmp/pull-fail.err" ); then
  fail "dev pull failure exits nonzero" "$(cat "$test_tmp/pull-fail.out" "$test_tmp/pull-fail.err")"
fi
pass "dev pull failure propagates nonzero"
