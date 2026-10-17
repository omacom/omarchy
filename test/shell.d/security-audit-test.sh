#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export fixture
mkdir -p "$fixture/bin" "$fixture/etc/sudoers.d" "$fixture/etc/pam.d"
sed "s#/etc/#$fixture/etc/#g" "$ROOT/bin/omarchy-setup-security-audit" >"$fixture/command"
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
[[ -s $fixture/etc/audit/rules.d/99-omarchy-hardening.rules ]] || fail "configuration exists: audit/rules.d/99-omarchy-hardening.rules"
cat "$fixture/etc/audit/rules.d/99-omarchy-hardening.rules" >"$fixture/before"
grep -Fxq -- "-w $fixture/etc/sudoers.d -p wa -k omarchy-config" "$fixture/before" || fail "audit directory watch exists"
grep -Fxq -- "-w $fixture/etc/pam.d -p wa -k omarchy-config" "$fixture/before" || fail "audit directory watch exists"
grep -Fxq -- '-a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc' "$fixture/before" || fail "required policy is present: -a always,exit -F arch=b64 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc"
grep -Fxq -- '-a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc' "$fixture/before" || fail "required policy is present: -a always,exit -F arch=b32 -S execve -C uid!=euid -F euid=0 -k omarchy-priv-esc"
bash "$fixture/command" >/dev/null
cat "$fixture/etc/audit/rules.d/99-omarchy-hardening.rules" >"$fixture/after"
cmp "$fixture/before" "$fixture/after" || fail "repeat setup preserves policy"
grep -Fq 'systemctl enable --now auditd.service' "$fixture/calls" || fail "activation is exercised"
if FAIL_COMMAND=install bash "$fixture/command" >/dev/null 2>&1; then
  fail "install failures propagate"
fi
if FAIL_COMMAND=augenrules bash "$fixture/command" >/dev/null 2>&1; then
  fail "augenrules failures propagate"
fi
ARM=1 bash "$fixture/command" >/dev/null
if grep -Fq 'arch=b32' "$fixture/etc/audit/rules.d/99-omarchy-hardening.rules"; then
  fail "ARM does not receive x86 compat rules"
fi
if grep -Fq '/etc/sysctl.conf' "$fixture/etc/audit/rules.d/99-omarchy-hardening.rules"; then
  fail "absent optional files are not watched"
fi
rm -rf "$fixture/etc"
if DEPENDENCIES_MISSING=1 bash "$fixture/command" >/dev/null 2>&1; then
  fail "missing optional dependencies are rejected"
fi
[[ ! -e $fixture/etc ]] || fail "missing dependencies have no side effects"
pass "optional audit setup, repeat runs and failures"
