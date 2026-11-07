#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export fixture
mkdir -p "$fixture/bin" "$fixture/root" "$fixture/etc/ssh"
sed -e "s#/etc/#$fixture/etc/#g" -e "s# /root# $fixture/root#g" \
  "$ROOT/bin/omarchy-setup-security-permissions" >"$fixture/command"
cat >"$fixture/bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
[[ $1 == "chmod" && $3 == "$fixture/"* ]] || exit 99
[[ ${FAIL_PATH:-} != "$3" ]] || exit 1
printf '%s\n' "$*" >>"$fixture/calls"
"$@"
STUB
chmod +x "$fixture/bin/sudo"
export PATH="$fixture/bin:$PATH"
bash "$fixture/command" --help >/dev/null
[[ ! -e $fixture/calls ]] || fail "help has no side effects"
for file in shadow gshadow passwd group; do
  touch "$fixture/etc/$file"
  chmod 666 "$fixture/etc/$file"
done
chmod 777 "$fixture/root"
# The SSH file is optional; the first run must succeed without it.
bash "$fixture/command"
[[ $(stat -c %a "$fixture/root") == "700" ]] || fail "root is private"
for file in shadow gshadow; do
  [[ $(stat -c %a "$fixture/etc/$file") == "600" ]] || fail "$file is private"
done
for file in passwd group; do
  [[ $(stat -c %a "$fixture/etc/$file") == "644" ]] || fail "$file is not writable by other users"
done
pass "excessive modes are removed without requiring SSH"

chmod 600 "$fixture/etc/passwd"
chmod 640 "$fixture/etc/group"
touch "$fixture/etc/ssh/sshd_config"
chmod 666 "$fixture/etc/ssh/sshd_config"
bash "$fixture/command"
[[ $(stat -c %a "$fixture/etc/passwd") == "600" ]] || fail "strict passwd mode is preserved"
[[ $(stat -c %a "$fixture/etc/group") == "640" ]] || fail "strict group mode is preserved"
[[ $(stat -c %a "$fixture/etc/ssh/sshd_config") == "600" ]] || fail "SSH permissions are exercised"
stat -c '%a' "$fixture/root" "$fixture/etc/"{shadow,gshadow,passwd,group,ssh/sshd_config} >"$fixture/before"
bash "$fixture/command"
stat -c '%a' "$fixture/root" "$fixture/etc/"{shadow,gshadow,passwd,group,ssh/sshd_config} >"$fixture/after"
cmp "$fixture/before" "$fixture/after" || fail "repeat setup preserves modes"
pass "stricter administrator modes survive repeat setup"

if FAIL_PATH="$fixture/etc/shadow" bash "$fixture/command"; then
  fail "intermediate chmod errors propagate"
fi
pass "permission errors propagate"
