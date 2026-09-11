#!/bin/bash

# Exercise complete production functions with private paths and harmless
# command stand-ins. Never install sudo policy or start a host timer.
test_tmp=$(mktemp -d)
children=()
cleanup_grant_fixture() {
  local status=$?
  trap - EXIT
  if (( ${#children[@]} )); then
    kill "${children[@]}" 2>/dev/null || true
    wait "${children[@]}" 2>/dev/null || true
  fi
  rm -rf "$test_tmp"
  exit "$status"
}
trap cleanup_grant_fixture EXIT
export TEST_GRANT_ROOT=$test_tmp
mkdir -p "$test_tmp/bin" "$test_tmp/etc/sudoers.d" "$test_tmp/etc/tmpfiles.d" "$test_tmp/run/lock" "$test_tmp/var/lib" "$test_tmp/hooks"
cat >"$test_tmp/bin/mock" <<'STUB'
#!/bin/bash
set -euo pipefail
name=${0##*/}
printf '%s %s\n' "$name" "$*" >>"$TEST_GRANT_ROOT/commands"
case "$name" in
  stat)
    path=${@: -1}
    owner=0
    mode=$(/usr/bin/stat -Lc '%a' -- "$path")
    [[ $path != /tmp ]] || mode=755
    [[ $path != "${TEST_BAD_PATH:-}" ]] || owner=1000
    case $2 in
      '%u') echo "$owner" ;;
      '%a') echo "$mode" ;;
      '%u %a') echo "$owner $mode" ;;
      *) exec /usr/bin/stat "$@" ;;
    esac
    ;;
  chown) exit 0 ;;
  install)
    args=()
    while (($#)); do
      case $1 in -o|-g) shift 2 ;; *) args+=("$1"); shift ;; esac
    done
    exec /usr/bin/install "${args[@]}"
    ;;
  rm)
    for path in "$@"; do
      if [[ ${TEST_DELETE_FAIL:-0} == 1 && $path == "$TEST_GRANT_ROOT/etc/sudoers.d/99-omarchy-nopasswd-1000" ]]; then exit 1; fi
    done
    exec /usr/bin/rm "$@"
    ;;
  mv)
    [[ ${TEST_PUBLISH_FAIL:-0} != 1 ]] || exit 1
    /usr/bin/mv "$@"
    [[ ${TEST_POST_PUBLISH_FAIL:-0} != 1 ]] || : >"$TEST_GRANT_ROOT/run/omarchy-sudo-passwordless-package-removing"
    ;;
  systemd-run)
    [[ ${TEST_TIMER_FAIL:-0} != 1 ]] || exit 1
    if [[ ${TEST_CANCEL_ENABLE:-0} == 1 ]]; then kill -TERM "$PPID"; fi
    ;;
  systemctl)
    [[ $1 != "is-active" || ${TEST_INACTIVE_TIMER:-0} != 1 ]]
    ;;
  date)
    if [[ ${TEST_EXPIRED:-0} == 1 && $* == '-u +%Y%m%d%H%M%SZ' ]]; then echo 99991231235959Z; else /usr/bin/date "$@"; fi
    ;;
  getent) printf '%s:x:1000:1000:Test:/nonexistent:/bin/bash\n' "${TEST_ACCOUNT:-audituser}" ;;
  sudo)
    if [[ ${1:-} == -h ]]; then echo 'usage: sudo [-N] command'; exit 0; fi
    if [[ ${1:-} == -k ]]; then exit 0; fi
    if [[ ${1:-} == -N ]]; then shift; fi
    if [[ ${1:-} == -- ]]; then shift; fi
    if [[ ${TEST_MIGRATION:-0} == 1 ]]; then
      [[ ${TEST_NO_SUDO:-0} != 1 ]] || exit 1
      TEST_EUID=0 /usr/bin/bash -p "$@"
    else
      [[ ${2:-} != __status ]] || exit "${TEST_STATUS:-3}"
    fi
    ;;
  gum) exit 1 ;;
  *) exit 99 ;;
esac
STUB
chmod +x "$test_tmp/bin/mock"
for name in stat chown install rm mv systemd-run systemctl date getent sudo gum; do
  ln -s mock "$test_tmp/bin/$name"
done

python3 - "$ROOT" "$test_tmp" <<'PY'
from pathlib import Path
import sys
root, temp = map(Path, sys.argv[1:])
for name in ('omarchy-sudo-passwordless', 'omarchy-security-functions'):
    text = (root/'bin'/name).read_text()
    for path in ('/etc/', '/var/lib', '/run/', '/usr/share/libalpm/hooks'):
        target = str(temp/'hooks') if path == '/usr/share/libalpm/hooks' else str(temp) + path
        text = text.replace(path, target)
    text = text.replace('((EUID == 0))', '((${TEST_EUID:-1} == 0))')
    for command in ('stat', 'chown', 'install', 'rm', 'mv', 'systemd-run', 'systemctl', 'date', 'getent', 'sudo', 'gum'):
        text = text.replace('/usr/bin/' + command, str(temp/'bin'/command))
    (temp/name).write_text(text)
    (temp/name).chmod(0o755)
PY
library="$test_tmp/functions.sh"
{
  printf 'source %q\n' "$test_tmp/omarchy-security-functions"
  awk '/^set -euo pipefail$/ { functions=1 } /^case "\$\{1:-\}" in$/ { exit } functions { print }' "$test_tmp/omarchy-sudo-passwordless"
} >"$library"
cp "$ROOT/default/libalpm/hooks/05-omarchy-passwordless-revoke.hook" "$test_tmp/hooks/"
sed "s|/etc/|$test_tmp/etc/|g" "$ROOT/etc/tmpfiles.d/omarchy-nopasswd-sudo.conf" >"$test_tmp/etc/tmpfiles.d/omarchy-nopasswd-sudo.conf"
: >"$test_tmp/commands"

# New subshell per case prevents one test's overrides and readonly constants
# from affecting the next. External commands log enough to verify ordering.
assert_status() {
  local expected=$1 actual=0
  shift
  "$@" || actual=$?
  (( actual == expected )) || fail "expected status $expected, got $actual from $*"
}
reset_grant() {
  rm -f "$test_tmp/etc/sudoers.d/99-omarchy-nopasswd-1000" "$test_tmp/run/omarchy-sudo-passwordless-package-removing"
  : >"$test_tmp/commands"
}
