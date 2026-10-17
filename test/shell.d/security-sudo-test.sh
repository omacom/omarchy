#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export fixture
mkdir -p "$fixture/bin" "$fixture/etc/sudoers.d" "$fixture/etc/pam.d"
sed "s#/etc/#$fixture/etc/#g" "$ROOT/bin/omarchy-setup-security-sudo" >"$fixture/command"
cat >"$fixture/bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
printf '%s\n' "$*" >>"$fixture/calls"
[[ ${FAIL_COMMAND:-} != "$1" ]] || exit 1
case "$1" in
  mkdir | tee | install)
    # Refuse any write outside the fixture or a mktemp input.
    for arg in "$@"; do
      if [[ $arg == /* && $arg != "$fixture/"* && $arg != /tmp/* ]]; then
        exit 99
      fi
    done
    "$@"
    ;;
  systemctl)
    case "$*" in
      'systemctl restart systemd-resolved' | 'systemctl daemon-reload' | 'systemctl enable --now auditd.service') ;;
      *) exit 99 ;;
    esac
    ;;
  visudo) [[ $2 == "-cf" && -s $3 ]] ;;
  augenrules) [[ $2 == "--load" ]] ;;
  sysctl) [[ $2 == "-p" && -s $3 ]] ;;
  limine-mkinitcpio) ;;
  *) exit 99 ;;
esac
STUB
cat >"$fixture/bin/systemctl" <<'STUB'
#!/bin/bash
[[ $* == "is-active --quiet systemd-resolved" && ${ACTIVE:-1} == "1" ]]
STUB
cat >"$fixture/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
[[ ${DEPENDENCIES_MISSING:-0} == "0" ]]
STUB
cat >"$fixture/bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
[[ ${DEPENDENCIES_MISSING:-0} == "1" ]]
STUB
cat >"$fixture/bin/omarchy-hw-x86" <<'STUB'
#!/bin/bash
[[ ${ARM:-0} == "0" ]]
STUB
chmod +x "$fixture/bin/"*
export PATH="$fixture/bin:$PATH"
bash "$fixture/command" --help >/dev/null
[[ ! -e $fixture/calls ]] || fail "help has no side effects"
if bash "$fixture/command" --invalid >/dev/null 2>&1; then
  fail "unknown arguments are rejected"
fi
bash "$fixture/command" >/dev/null
[[ -s $fixture/etc/sudoers.d/99-omarchy-hardening ]] || fail "configuration exists: sudoers.d/99-omarchy-hardening"
cat "$fixture/etc/sudoers.d/99-omarchy-hardening" >"$fixture/before"
grep -Fxq -- 'Defaults env_reset' "$fixture/before" || fail "required policy is present: Defaults env_reset"
grep -Fxq -- 'Defaults use_pty' "$fixture/before" || fail "required policy is present: Defaults use_pty"
bash "$fixture/command" >/dev/null
cat "$fixture/etc/sudoers.d/99-omarchy-hardening" >"$fixture/after"
cmp "$fixture/before" "$fixture/after" || fail "repeat setup preserves policy"
grep -Fq 'visudo -cf' "$fixture/calls" || fail "activation is exercised"
if FAIL_COMMAND=install bash "$fixture/command" >/dev/null 2>&1; then
  fail "install failures propagate"
fi
if FAIL_COMMAND=visudo bash "$fixture/command" >/dev/null 2>&1; then
  fail "visudo failures propagate"
fi
[[ $(stat -c %a "$fixture/etc/sudoers.d/99-omarchy-hardening") == "440" ]] || fail "sudoers mode is 440"
pass "optional sudo setup, repeat runs and failures"
