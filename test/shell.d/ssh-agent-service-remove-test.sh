#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# A user manager with systemd's two environment blocks: set-environment's, which
# outlives the socket that wrote it, and the generator's, re-read from
# environment.d on every reload, which disable triggers.
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
state=$OMARCHY_TEST_MANAGER
case $2 in
  disable)
    if [[ -f $HOME/.config/environment.d/90-gcr-ssh-agent.conf ]]; then
      echo "SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh" >"$state/generated"
    else
      : >"$state/generated"
    fi
    ;;
  unset-environment) : >"$state/explicit" ;;
  show-environment) cat "$state/generated" "$state/explicit" ;;
esac
exit 0
SH
chmod +x "$mock_bin/systemctl"

run_remove() {
  local explicit="$1"

  export HOME="$test_tmp/home" XDG_RUNTIME_DIR="$test_tmp/run" OMARCHY_TEST_MANAGER="$test_tmp/manager"
  rm -rf "$HOME" "$OMARCHY_TEST_MANAGER"
  mkdir -p "$HOME/.config/environment.d" "$OMARCHY_TEST_MANAGER"
  echo 'SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh' >"$HOME/.config/environment.d/90-gcr-ssh-agent.conf"
  echo "SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/gcr/ssh" >"$OMARCHY_TEST_MANAGER/generated"
  echo "$explicit" >"$OMARCHY_TEST_MANAGER/explicit"

  PATH="$mock_bin:$PATH" "$ROOT/bin/omarchy-remove-service-ssh-agent" >/dev/null
  PATH="$mock_bin:$PATH" systemctl --user show-environment
}

env_after=$(run_remove "SSH_AUTH_SOCK=$test_tmp/run/gcr/ssh")
[[ -z $env_after ]] || fail "removal leaves no SSH_AUTH_SOCK pointing at the stopped agent" "$env_after"
pass "removal leaves no SSH_AUTH_SOCK pointing at the stopped agent"

env_after=$(run_remove "SSH_AUTH_SOCK=$test_tmp/run/other-agent.sock")
[[ $env_after == "SSH_AUTH_SOCK=$test_tmp/run/other-agent.sock" ]] || fail "removal keeps an SSH_AUTH_SOCK another agent set" "$env_after"
pass "removal keeps an SSH_AUTH_SOCK another agent set"
