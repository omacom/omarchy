#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/unmount-fuse"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
mkdir -p "$mock_bin"
: >"$call_log"

for cmd in systemd-run sudo; do
  cat >"$mock_bin/$cmd" <<SH
#!/bin/bash
printf '%s %s\n' "$cmd" "\$*" >>"$call_log"
SH
  chmod +x "$mock_bin/$cmd"
done

# systemd kills whatever a sleep hook leaves in the sleep service's cgroup, so
# nothing of the hook may outlive it; a leftover child would hold this pipe open.
if ! PATH="$mock_bin:$PATH" timeout 2 bash -o pipefail -c 'bash "$1" post suspend | cat' _ "$hook" >/dev/null; then
  fail "resume leaves nothing running behind the hook" "calls: $(<"$call_log")"
fi
pass "resume leaves nothing running behind the hook"

# sudo goes through PAM, which can stall on a fingerprint prompt nobody is there to answer.
if grep -q '^sudo ' "$call_log"; then
  fail "resume never goes through sudo" "calls: $(<"$call_log")"
fi
pass "resume never goes through sudo"

buses=0
for uid_dir in /run/user/*; do
  if [[ -S $uid_dir/bus ]]; then
    buses=$((buses + 1))
    grep -q -- "^systemd-run .*--no-block .*--on-active=5 --timer-property=AccuracySec=1s --uid=${uid_dir##*/} .*systemctl --user restart gvfs-daemon.service" "$call_log" ||
      fail "resume schedules a gvfs restart for each user bus" "calls: $(<"$call_log")"
  fi
done

if (( buses > 0 )); then
  pass "resume schedules a gvfs restart for each user bus"
else
  skip "no user bus under /run/user; skipping the gvfs restart scheduling check"
fi
