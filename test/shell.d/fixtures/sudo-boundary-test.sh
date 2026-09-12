#!/bin/bash

# Test the real orchestration with fixed privileged paths redirected to harmless
# stand-ins. No host sudo, package transaction, namespace root, or exploit runs.
boundary_tmp=$(mktemp -d)
trap 'rm -rf "$boundary_tmp"' EXIT
export SUDO_TEST_ROOT="$boundary_tmp/omarchy"
export SUDO_TEST_LOG="$boundary_tmp/events"
export SUDO_TEST_CACHE="$boundary_tmp/cache"
export OMARCHY_PATH="$SUDO_TEST_ROOT"
export SUDO_TEST_HOME="$boundary_tmp/home"
mkdir -p "$SUDO_TEST_HOME"
mkdir -p "$SUDO_TEST_ROOT/bin" "$SUDO_TEST_ROOT/mock" "$SUDO_TEST_ROOT/default/omarchy/sudo-no-update"
: >"$SUDO_TEST_LOG"

copy_boundary_file() {
  python3 - "$ROOT" "$SUDO_TEST_ROOT" "$1" <<'PY'
import sys
from pathlib import Path
source, target, name = map(Path,sys.argv[1:])
p=target/name
p.parent.mkdir(parents=True,exist_ok=True)
s=(source/name).read_text().replace('$HOME', '$SUDO_TEST_HOME')
for command in ['sudo','pkexec','pacman','omarchy-pkg-missing','systemd-inhibit','setpriv','snapper']:
 s=s.replace('/usr/bin/'+command, str(target/'mock'/command))
s=s.replace('PATH=/usr/bin:/usr/sbin:/bin:/sbin', 'PATH="'+str(target/'bin')+':/usr/bin:/usr/sbin:/bin:/sbin"')
p.write_text(s)
p.chmod((source/name).stat().st_mode & 0o777)
PY
}

copy_boundary_file bin/omarchy-security-functions
copy_boundary_file default/omarchy/sudo-no-update/sudo

cat >"$SUDO_TEST_ROOT/mock/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
printf 'sudo' >>"$SUDO_TEST_LOG"
printf ' %q' "$@" >>"$SUDO_TEST_LOG"
printf '\n' >>"$SUDO_TEST_LOG"
if [[ ${1:-} == "-h" ]]; then
  if [[ ${SUDO_TEST_UNSUPPORTED:-0} == "1" ]]; then
    echo 'usage: sudo [-ABbEHknPS] command'
  else
    echo 'usage: sudo [-ABbEHkNnPS] command'
  fi
  exit 0
fi
if [[ ${1:-} == "-k" || ${1:-} == "-K" ]]; then
  [[ ${SUDO_TEST_REVOKE_FAIL:-0} != "1" && ! -e $SUDO_TEST_ROOT/revoke-fail ]] || exit 1
  /usr/bin/rm -f "$SUDO_TEST_CACHE"
  exit 0
fi
if [[ ${1:-} == "-N" ]]; then
  shift
else
  touch "$SUDO_TEST_CACHE"
fi
[[ ${SUDO_TEST_SUDO_FAIL:-0} != "1" ]] || exit 1
background=0
while (( $# )); do
  case "$1" in
    -N|-n) shift ;;
    -b) background=1; shift ;;
    -v) exit 0 ;;
    -u|--user) shift 2 ;;
    --) shift; break ;;
    *) break ;;
  esac
done
(( $# )) || exit 0
if (( background )); then
  "$@" &
else
  "$@"
fi
STUB
chmod +x "$SUDO_TEST_ROOT/mock/sudo"

cat >"$SUDO_TEST_ROOT/bin/test-step" <<'STUB'
#!/bin/bash
set -euo pipefail
step=${0##*/}
printf 'step:%s %s\n' "$step" "$*" >>"$SUDO_TEST_LOG"
if [[ $step == "omarchy-hook" || $step == "omarchy-update-mise" ]]; then
  [[ ! -e $SUDO_TEST_CACHE ]] || exit 91
fi
if [[ ${SUDO_TEST_FAIL_STEP:-} == "$step" ]]; then
  # Model a misbehaving child leaving state behind, then failing. Cleanup must
  # still revoke it. This never invokes real sudo or exercises a privilege flaw.
  touch "$SUDO_TEST_CACHE"
  exit 17
fi
if [[ ${SUDO_TEST_SIGNAL_STEP:-} == "$step" ]]; then
  touch "$SUDO_TEST_CACHE"
  kill -TERM "$PPID"
  exit 0
fi
case "$step" in
  omarchy-update-system-pkgs|omarchy-update-keyring|omarchy-snapshot)
    sudo /usr/bin/true
    ;;
  pacman) exit 0 ;;
  yay)
    [[ $* == *"--sudo $OMARCHY_PATH/default/omarchy/sudo-no-update/sudo"* ]] || exit 92
    [[ $* == *"--sudoloop=false"* ]] || exit 93
    ;;
esac
STUB
chmod +x "$SUDO_TEST_ROOT/bin/test-step"
for step in omarchy-update-lock omarchy-update-requires-free-space omarchy-update-confirm omarchy-update-pkg-prune omarchy-snapshot omarchy-update-stay-awake omarchy-update-dev omarchy-update-keyring omarchy-update-system-pkgs omarchy-migrate omarchy-hook omarchy-update-aur-pkgs omarchy-update-mise omarchy-update-orphan-pkgs omarchy-update-analyze-logs omarchy-update-status omarchy-update-restart omarchy-pkg-aur-accessible omarchy-notification-dismiss pacman cp yay; do
  ln -s test-step "$SUDO_TEST_ROOT/bin/$step"
done
ln -s ../bin/test-step "$SUDO_TEST_ROOT/mock/pacman"

reset_boundary() {
  : >"$SUDO_TEST_LOG"
  /usr/bin/rm -f "$SUDO_TEST_CACHE" "$SUDO_TEST_ROOT/revoke-fail"
  unset SUDO_TEST_FAIL_STEP SUDO_TEST_SIGNAL_STEP SUDO_TEST_SUDO_FAIL SUDO_TEST_REVOKE_FAIL SUDO_TEST_UNSUPPORTED
}
assert_boundary_cold() {
  [[ ! -e $SUDO_TEST_CACHE ]] || fail "$1 left cached authorization"
  [[ $(tail -1 "$SUDO_TEST_LOG") == "sudo -k" ]] || fail "$1 did not revoke at exit" "$(<"$SUDO_TEST_LOG")"
}
