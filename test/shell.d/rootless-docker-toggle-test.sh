#!/bin/bash
#
# Rootless Docker runs a per-user daemon next to the system one. Setup installs
# the rootless pieces, keeps the daemon alive with linger, enables the packaged
# user unit, and selects it through a docker context (not DOCKER_HOST, so
# `sudo docker` keeps reaching the system daemon). A failure after enabling the
# unit disables it again, so a rerun and the menu don't take it for finished.
# Remove cleans up whatever is left and leaves the system daemon alone, as well
# as a `rootless` context that points to another daemon. Linger is turned back
# off on rollback and removal only when setup is what turned it on.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
home="$test_dir/home"
runtime="$test_dir/run"
stub_bin="$test_dir/bin"
calls="$test_dir/calls"
subuid="$test_dir/subuid"
subgid="$test_dir/subgid"
linger_marker="$home/.local/state/omarchy/rootless-docker-linger"
mkdir -p "$home" "$runtime" "$stub_bin"

stub() { # name body
  printf '#!/bin/bash\n%s\n' "$2" >"$stub_bin/$1"
  chmod +x "$stub_bin/$1"
}

stub sudo 'exec "$@"'
stub sleep ':'
stub gum 'exit "${GUM_ANSWER:-0}"'
# Point the account files at fixtures instead of reading the host's.
stub grep '
args=()
for arg in "$@"; do
  case $arg in
  /etc/subuid) args+=("$SUBUID_FILE") ;;
  /etc/subgid) args+=("$SUBGID_FILE") ;;
  *) args+=("$arg") ;;
  esac
done
exec /usr/bin/grep "${args[@]}"'
stub omarchy-pkg-add 'echo "pkg-add $*" >>"$CALLS"'
stub omarchy-pkg-aur-add 'echo "aur-add $*" >>"$CALLS"'
stub loginctl '
echo "loginctl $*" >>"$CALLS"
[[ $1 == "show-user" ]] && echo "${LINGER:-no}"
exit 0'
stub systemctl '
echo "systemctl $*" >>"$CALLS"
case $* in
*is-enabled*) exit "${UNIT_ENABLED:-1}" ;;
*is-active*) exit "${UNIT_ACTIVE:-1}" ;;
*"enable --now docker.service"*)
  [[ ${DAEMON_STARTS:-1} == 1 ]] && python3 -c "import socket,sys; socket.socket(socket.AF_UNIX).bind(sys.argv[1])" "$XDG_RUNTIME_DIR/docker.sock"
  ;;
esac
exit 0'
stub docker '
echo "docker $*" >>"$CALLS"
if [[ "$1 $2" == "context inspect" ]]; then
  [[ ${CONTEXT_HOST:-} ]] || exit 1
  [[ $* == *--format* ]] && echo "$CONTEXT_HOST"
fi
exit 0'

# Variables: UNIT_ENABLED UNIT_ACTIVE GUM_ANSWER CONTEXT_HOST DAEMON_STARTS SUBUID SUBGID
# LINGER (yes|no, the state before the run) LINGER_MARKED (1 = setup turned it on earlier)
# Returns the command's exit status.
run() { # command
  rm -f "$calls" "$runtime/docker.sock" "$linger_marker"
  if [[ ${LINGER_MARKED:-0} == 1 ]]; then
    mkdir -p "${linger_marker%/*}"
    touch "$linger_marker"
  fi
  printf '%s\n' "${SUBUID-tester:100000:65536}" >"$subuid"
  printf '%s\n' "${SUBGID-tester:100000:65536}" >"$subgid"
  env HOME="$home" USER="tester" XDG_RUNTIME_DIR="$runtime" CALLS="$calls" \
    SUBUID_FILE="$subuid" SUBGID_FILE="$subgid" \
    UNIT_ENABLED="${UNIT_ENABLED:-1}" UNIT_ACTIVE="${UNIT_ACTIVE:-1}" GUM_ANSWER="${GUM_ANSWER:-0}" \
    CONTEXT_HOST="${CONTEXT_HOST:-}" DAEMON_STARTS="${DAEMON_STARTS:-1}" LINGER="${LINGER:-no}" \
    PATH="$stub_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/bin/$1" >/dev/null 2>&1
}

called() { grep -Fqx -- "$1" "$calls" 2>/dev/null; }
mentions() { grep -qE -- "$1" "$calls" 2>/dev/null; }

own_host="host=unix://$runtime/docker.sock"

# Setup, confirmed -> packages, linger, unit, context created and selected.
run omarchy-setup-security-rootless-docker || fail "setup succeeds"
called "pkg-add rootlesskit slirp4netns" || fail "setup installs rootlesskit and slirp4netns"
called "aur-add docker-rootless-extras" || fail "setup installs docker-rootless-extras from the AUR"
called "loginctl enable-linger tester" || fail "setup enables linger"
[[ -f $linger_marker ]] || fail "setup records that it turned linger on"
called "systemctl --user enable --now docker.service" || fail "setup enables the packaged user unit"
called "docker context create rootless --description Rootless Docker (tester) --docker $own_host" || fail "setup creates the rootless context on the user socket"
called "docker context use rootless" || fail "setup selects the rootless context"
! grep -E "^systemctl " "$calls" | grep -qv -- "--user" || fail "setup must not touch the system docker units"
pass "setup installs, enables the user daemon, and selects it through a context"

# Setup, context already on this socket -> reused, not recreated.
CONTEXT_HOST="unix://$runtime/docker.sock" run omarchy-setup-security-rootless-docker || fail "setup succeeds with a context already on this socket"
! mentions "context create" || fail "setup reuses a rootless context already on this socket"
called "docker context use rootless" || fail "setup selects the existing context"
pass "setup reuses a rootless context already on this socket"

# Setup, linger already on -> left as is and not recorded as ours.
LINGER=yes run omarchy-setup-security-rootless-docker || fail "setup succeeds with linger already on"
! mentions "enable-linger" || fail "setup does not enable a linger that is already on"
[[ ! -f $linger_marker ]] || fail "setup does not claim a linger that was already on"
pass "setup leaves a linger that was already on unrecorded"

# Setup, context named rootless aimed elsewhere -> refused before installing.
! CONTEXT_HOST="ssh://someone@elsewhere" run omarchy-setup-security-rootless-docker || fail "setup fails on a rootless context aimed at another daemon"
! mentions "pkg-add|aur-add|enable --now|context (create|use)" || fail "setup refuses a rootless context aimed at another daemon"
pass "setup refuses a rootless context that points to another daemon"

# Setup, daemon never comes up -> unit disabled again, no context selected.
! DAEMON_STARTS=0 run omarchy-setup-security-rootless-docker || fail "setup fails when the daemon does not start"
called "systemctl --user disable --now docker.service" || fail "setup disables the unit when the daemon does not start"
! mentions "context (create|use)" || fail "setup selects no context when the daemon does not start"
called "loginctl disable-linger tester" || fail "setup turns linger back off when the daemon does not start"
[[ ! -f $linger_marker ]] || fail "setup clears its linger record when the daemon does not start"
pass "setup rolls the unit and linger back when the daemon does not start"

# Setup, daemon never comes up, linger already on -> linger kept.
! LINGER=yes DAEMON_STARTS=0 run omarchy-setup-security-rootless-docker || fail "setup fails when the daemon does not start with linger already on"
! mentions "disable-linger" || fail "setup keeps a linger that was already on when rolling back"
pass "setup keeps a linger that was already on when rolling back"

# Setup, declined -> nothing installed or enabled.
GUM_ANSWER=1 run omarchy-setup-security-rootless-docker || fail "declined setup exits cleanly"
! mentions "pkg-add|aur-add|loginctl|enable --now|context" || fail "declined setup changes nothing"
pass "declined setup changes nothing"

# Setup, a missing subordinate UID or GID range -> stops before installing.
! SUBUID="someone-else:100000:65536" run omarchy-setup-security-rootless-docker || fail "setup fails without a subuid range"
! mentions "pkg-add|aur-add|enable --now" || fail "setup refuses without a subuid range"
! SUBGID="" run omarchy-setup-security-rootless-docker || fail "setup fails without a subgid range"
! mentions "pkg-add|aur-add|enable --now" || fail "setup refuses without a subgid range"
pass "setup refuses without a subordinate UID or GID range"

# Setup, already enabled -> no-op.
UNIT_ENABLED=0 run omarchy-setup-security-rootless-docker || fail "setup exits cleanly when already enabled"
! mentions "pkg-add|enable --now|context" || fail "setup is a no-op when already enabled"
pass "setup is a no-op when rootless Docker is already enabled"

# Remove -> unit disabled, default context back, rootless context removed.
UNIT_ENABLED=0 CONTEXT_HOST="unix://$runtime/docker.sock" run omarchy-remove-security-rootless-docker || fail "remove succeeds"
called "systemctl --user disable --now docker.service docker.socket" || fail "remove disables the user unit"
called "docker context use default" || fail "remove switches back to the default context"
called "docker context rm -f rootless" || fail "remove deletes the rootless context"
! mentions "disable-linger" || fail "remove keeps a linger setup did not turn on"
pass "remove disables the user daemon and restores the default context"

# Remove, linger turned on by setup -> turned back off.
UNIT_ENABLED=0 LINGER=yes LINGER_MARKED=1 CONTEXT_HOST="unix://$runtime/docker.sock" run omarchy-remove-security-rootless-docker || fail "remove succeeds with a linger setup turned on"
called "loginctl disable-linger tester" || fail "remove turns off the linger setup turned on"
[[ ! -f $linger_marker ]] || fail "remove clears the linger record"
pass "remove turns off the linger setup turned on"

# Remove, only the linger setup turned on is left -> still turned off.
LINGER=yes LINGER_MARKED=1 run omarchy-remove-security-rootless-docker || fail "remove succeeds with only linger left"
called "loginctl disable-linger tester" || fail "remove turns off a leftover linger"
pass "remove turns off a linger left behind on its own"

# Remove, unit disabled but still running -> still stopped and cleaned up.
UNIT_ACTIVE=0 CONTEXT_HOST="unix://$runtime/docker.sock" run omarchy-remove-security-rootless-docker || fail "remove succeeds on a disabled but running daemon"
called "systemctl --user disable --now docker.service docker.socket" || fail "remove stops a disabled but running daemon"
called "docker context use default" || fail "remove restores the default context of a disabled but running daemon"
pass "remove cleans up a daemon that is disabled but still running"

# Remove, unit enabled but the rootless context points elsewhere -> unit
# stopped, the user's context left alone.
UNIT_ENABLED=0 CONTEXT_HOST="ssh://someone@elsewhere" run omarchy-remove-security-rootless-docker || fail "remove succeeds next to a foreign rootless context"
called "systemctl --user disable --now docker.service docker.socket" || fail "remove still disables the user unit next to a foreign rootless context"
! mentions "context (use|rm)" || fail "remove leaves a rootless context aimed at another daemon alone"
pass "remove keeps a rootless context that points to another daemon"

# Remove, only a foreign rootless context left -> no-op.
CONTEXT_HOST="ssh://someone@elsewhere" run omarchy-remove-security-rootless-docker || fail "remove exits cleanly with only a foreign rootless context"
! mentions "disable|context (use|rm)" || fail "remove is a no-op when only a foreign rootless context exists"
pass "remove is a no-op when only a foreign rootless context exists"

# Remove, nothing left -> no-op.
run omarchy-remove-security-rootless-docker || fail "remove exits cleanly when rootless Docker is off"
! mentions "disable|context use" || fail "remove is a no-op when rootless Docker is off"
pass "remove is a no-op when rootless Docker is off"
