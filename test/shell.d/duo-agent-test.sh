#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export OMARCHY_PATH="$ROOT"
export DUO_TEST_LOG="$test_tmp/calls"
export DUO_TEST_ARGS="$test_tmp/args"
export DUO_TEST_BINARY="$test_tmp/duo"
unset GLAB_DUO_CLI_BINARY_PATH
mkdir -p "$HOME/.config/omarchy/defaults" "$test_tmp/bin"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

cat >"$test_tmp/bin/glab" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$DUO_TEST_LOG"
case "$*" in
  --version) echo "glab ${DUO_TEST_VERSION:-1.117.0} (test)" ;;
  "config get duo_cli_binary_path --global") echo "$DUO_TEST_BINARY" ;;
  "config get client_id"*) echo "${DUO_TEST_CLIENT_ID:-}" ;;
  "auth login"*) exit "${DUO_TEST_AUTH_STATUS:-0}" ;;
  "duo cli --install --yes")
    [[ ${DUO_TEST_INSTALL_FAIL:-false} == "false" ]] || exit 1
    touch "$DUO_TEST_BINARY"
    chmod +x "$DUO_TEST_BINARY"
    ;;
  "duo cli"*)
    printf '%s\0' "$@" >"$DUO_TEST_ARGS"
    exit "${DUO_TEST_RUN_STATUS:-0}"
    ;;
esac
SH
cat >"$test_tmp/bin/mise" <<'SH'
#!/bin/bash
printf 'mise %s\n' "$*" >>"$DUO_TEST_LOG"
exit 1
SH
cat >"$test_tmp/bin/gum" <<'SH'
#!/bin/bash
case "$*" in
  *"Application ID"*) echo "test-application-id" ;;
  *) echo "${DUO_TEST_HOST:-gitlab.com}" ;;
esac
SH
cat >"$test_tmp/bin/omarchy-launch-tui" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$DUO_TEST_ARGS"
SH
cat >"$test_tmp/bin/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$DUO_TEST_ARGS"
SH
chmod +x "$test_tmp/bin/"*

assert_args() {
  local actual=() expected=("$@") index
  mapfile -d '' -t actual <"$DUO_TEST_ARGS"
  (( ${#actual[@]} == ${#expected[@]} )) || fail "Duo argument count" "${actual[*]}"
  for ((index = 0; index < ${#expected[@]}; index++)); do
    [[ ${actual[index]} == "${expected[index]}" ]] || fail "Duo literal argument $index" "${actual[*]}"
  done
}

if omarchy-install-duo-cli --check; then
  fail "glab alone must not count as an installed Duo"
fi
touch "$DUO_TEST_BINARY"
chmod +x "$DUO_TEST_BINARY"
omarchy-install-duo-cli --check || fail "supported glab and executable Duo count as installed"
if DUO_TEST_VERSION=1.106.0 omarchy-install-duo-cli --check; then
  fail "old glab must not count as supported"
fi
if DUO_TEST_VERSION=invalid omarchy-install-duo-cli --check; then
  fail "unrecognized glab version must not count as supported"
fi
pass "Duo presence checks its executable and glab version without installing"

printf 'opencode\n' >"$HOME/.config/omarchy/defaults/agent"
rm "$DUO_TEST_BINARY"
omarchy-default-agent duo
assert_args omarchy-default-agent --install duo
[[ $(omarchy-default-agent) == "opencode" ]] || fail "cold Duo selection waits for setup"

for failure in DUO_TEST_AUTH_STATUS=1 DUO_TEST_INSTALL_FAIL=true; do
  : >"$DUO_TEST_ARGS"
  if env "$failure" omarchy-default-agent --install duo >"$test_tmp/failure" 2>&1; then
    fail "failed Duo setup must fail selection"
  fi
  [[ $(omarchy-default-agent) == "opencode" ]] || fail "failed Duo setup preserves the default"
  [[ ! -s $DUO_TEST_ARGS ]] || fail "failed Duo setup must not launch"
done
pass "Duo setup failures preserve the default and do not launch"

: >"$DUO_TEST_LOG"
omarchy-default-agent --install duo >"$test_tmp/install-output"
[[ $(omarchy-default-agent) == "duo" ]] || fail "successful setup selects Duo"
grep -Fx 'auth login --hostname gitlab.com --web' "$DUO_TEST_LOG" >/dev/null || fail "setup uses OAuth"
grep -Fx 'config set host gitlab.com --global' "$DUO_TEST_LOG" >/dev/null || fail "setup saves desktop fallback host"
assert_args duo cli --yes --dangerously-skip-permissions
pass "first selection installs Duo through glab and launches inline after OAuth"

: >"$DUO_TEST_LOG"
omarchy-default-agent duo
assert_args --app-id=org.omarchy.agent omarchy-launch-duo
if grep -Eq 'auth login|duo cli --install|mise use' "$DUO_TEST_LOG"; then
  fail "installed Duo selection must not repeat setup"
fi
pass "installed Duo selects without repeating OAuth or installation"

: >"$DUO_TEST_LOG"
omarchy-setup-duo gitlab.example.com >"$test_tmp/self-managed-output"
grep -Fx 'config set client_id test-application-id --host gitlab.example.com' "$DUO_TEST_LOG" >/dev/null || fail "self-managed saves application ID per host"
grep -Fx 'auth login --hostname gitlab.example.com --web' "$DUO_TEST_LOG" >/dev/null || fail "self-managed uses browser OAuth"
grep -Fx 'config set host gitlab.example.com --global' "$DUO_TEST_LOG" >/dev/null || fail "self-managed sets fallback host"
: >"$DUO_TEST_LOG"
DUO_TEST_CLIENT_ID=existing omarchy-setup-duo gitlab.example.com >/dev/null
if grep -q 'config set client_id' "$DUO_TEST_LOG"; then
  fail "setup must preserve an existing client ID"
fi
: >"$DUO_TEST_LOG"
if DUO_TEST_AUTH_STATUS=1 omarchy-setup-duo gitlab.example.com >/dev/null; then
  fail "failed OAuth must fail setup"
fi
if grep -q 'config set host' "$DUO_TEST_LOG"; then
  fail "failed OAuth must preserve the fallback host"
fi
if omarchy-setup-duo 'https://gitlab.example.com/path' >/dev/null 2>&1; then
  fail "setup must reject URLs where a hostname is required"
fi
pass "self-managed OAuth preserves existing client IDs and changes host only after success"

for prompt in '--update' '--yes' 'help' $'--goal !Crash {$(touch must-not-run)}\ntrailing\\ '; do
  omarchy-agent-prompt "$prompt"
  assert_args --app-id=org.omarchy.agent omarchy-launch-duo --hold --prompt "$prompt"
  omarchy-agent-prompt --inline "$prompt"
  assert_args duo cli --yes --dangerously-skip-permissions run "--goal=$prompt"
done
pass "Duo keeps option-like and multiline prompts literal through both launch paths"

status=0
DUO_TEST_RUN_STATUS=65 omarchy-agent-prompt --inline "Review this project" || status=$?
(( status == 65 )) || fail "inline prompt must preserve Duo's failure status"
status=0
DUO_TEST_RUN_STATUS=65 omarchy-launch-duo --hold --prompt "Review this project" <<<"" >"$test_tmp/held-output" || status=$?
(( status == 65 )) || fail "held prompt must preserve Duo's failure status"
grep -F 'Press Enter to close.' "$test_tmp/held-output" >/dev/null || fail "graphical prompt must retain the result"
pass "prompt launches retain results and preserve exit status"
