#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf -- "$fixture"' EXIT

# A guarded entrypoint reduced to its startup check.
cat >"$fixture/entry" <<SH
#!/bin/bash -p
if [[ \$- != *p* ]]; then exit 126; fi
source $ROOT/bin/omarchy-security-functions || exit 126
omarchy_security_require_privileged_bash_startup || exit 126
echo started
SH
chmod 755 "$fixture/entry"

[[ $("$fixture/entry") == "started" ]] || fail "a #!/bin/bash -p entrypoint starts"
pass "a #!/bin/bash -p entrypoint starts"

if /usr/bin/bash "$fixture/entry" -p >/dev/null 2>&1; then
  fail "ordinary Bash with a decoy -p argument is refused"
fi
pass "ordinary Bash with a decoy -p argument is refused"

# arch-chroot runs the installer's commands in a PID namespace of their own,
# with the outer /proc mounted. A user namespace stands in for root here.
if ! unshare --user --map-root-user --fork --pid true 2>/dev/null; then
  pass "PID namespace cases skipped: this host allows no unprivileged namespaces"
  exit 0
fi

[[ $(unshare --user --map-root-user --fork --pid "$fixture/entry" 2>/dev/null) == "started" ]] ||
  fail "an entrypoint starts in a PID namespace with the outer /proc, as under arch-chroot"
pass "an entrypoint starts in a PID namespace with the outer /proc, as under arch-chroot"

if unshare --user --map-root-user --fork --pid /usr/bin/bash "$fixture/entry" -p >/dev/null 2>&1; then
  fail "a decoy -p is still refused in a PID namespace"
fi
pass "a decoy -p is still refused in a PID namespace"
