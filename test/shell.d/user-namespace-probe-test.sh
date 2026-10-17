#!/bin/bash
# A test that probes for a user namespace must skip cleanly where none can be
# made. util-linux unshare forks a helper to write --map-users, --map-groups and
# --map-auto mappings before it calls unshare(2), and when that call fails the
# helper is left behind, blocked for good with the caller's stdout open: the
# file skips and exits, and ./test/shell's tee waits on the pipe forever.

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command timeout

stub_dir=$(mktemp -d)
trap 'rm -rf "$stub_dir"' EXIT

# Stand in for unshare in a sandbox that refuses user namespaces, as Docker's
# default seccomp profile does: every form fails, and the mapping forms leave a
# process behind on stdout the way util-linux does. It is bounded, so a
# regression costs this file a timeout rather than the run.
cat >"$stub_dir/unshare" <<'STUB'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == --map-users* || $arg == --map-groups* || $arg == "--map-auto" ]]; then
    sleep 30 &
    break
  fi
done
echo "unshare: unshare failed: Operation not permitted" >&2
exit 1
STUB
chmod +x "$stub_dir/unshare"

# Read the boundary probe through a pipe, as ./test/shell does. timeout signals
# its whole process group when it fires, the stray helper included, so a
# regression fails here instead of hanging this file as well. As root the probe
# never calls unshare and goes straight to its mounts, so it is not run from here.
if (( EUID == 0 )); then
  skip "running as root; the Windows VM boundary probe only reaches unshare for an unprivileged runner"
else
  status=0
  output=$(
    PATH="$stub_dir:$PATH" timeout 10 \
      bash -o pipefail -c 'bash "$1" | cat' _ "$SHELL_TEST_DIR/windows-vm-mount-boundary-test.sh" 2>&1
  ) || status=$?

  (( status != 124 )) ||
    fail "Windows VM boundary probe leaves nothing holding the runner's pipe when user namespaces are refused" "$output"
  (( status == 0 )) || fail "Windows VM boundary probe exits cleanly when user namespaces are refused" "$output"
  [[ $output == *"# SKIP"* ]] || fail "Windows VM boundary probe reports a skip when user namespaces are refused" "$output"
  pass "Windows VM boundary probe skips without holding the runner's pipe when user namespaces are refused"
fi

# The stub proves one probe end to end; hold the others to the same guard by
# name. A file that maps ids with unshare must call user_namespace_available,
# since its first mapping unshare is the probe that would hang. This checks the
# call is there, not that it comes first.
for test_file in "$SHELL_TEST_DIR"/*-test.sh; do
  grep -qE -- '--map-(users|groups|auto)' "$test_file" || continue
  grep -q 'user_namespace_available' "$test_file" ||
    fail "$(basename -- "$test_file") calls user_namespace_available when it maps ids with unshare"
done
pass "every test that maps ids with unshare calls user_namespace_available"
