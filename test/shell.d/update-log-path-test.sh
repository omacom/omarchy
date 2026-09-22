#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update

analyze="$ROOT/bin/omarchy-update-analyze-logs"
script_calls="$boundary_tmp/script-calls"

# omarchy-update runs with a privileged Bash startup and a sanitized PATH, so it
# has to be invoked through the boundary fixture rather than as `bash <file>`.
# script(1) is where it re-execs itself; recording the path it would write and
# stopping there is enough to assert which transcript it chose, without running
# an update.
cat >"$SUDO_TEST_ROOT/bin/script" <<'STUB'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"${SCRIPT_CALLS:?}"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/script"

run_update() {
  : >"$script_calls"
  env -u OMARCHY_UPDATE_LOGGED -u OMARCHY_UPDATE_LOG -u XDG_RUNTIME_DIR "$@" \
    SCRIPT_CALLS="$script_calls" "$SUDO_TEST_ROOT/bin/omarchy-update" \
    >/dev/null 2>&1 || true
}

# The transcript belongs in the per-user runtime directory. A fixed path in
# world-writable /tmp lets any other local user pre-create the file, and
# fs.protected_regular then refuses this user's open, blocking the update.
run_update XDG_RUNTIME_DIR="$boundary_tmp/run"
grep -qxF "$boundary_tmp/run/omarchy-update.log" "$script_calls" ||
  fail "update writes its transcript under XDG_RUNTIME_DIR" "$(cat "$script_calls")"
pass "update writes its transcript under XDG_RUNTIME_DIR"

if grep -qxF "/tmp/omarchy-update.log" "$script_calls"; then
  fail "update no longer uses the shared /tmp/omarchy-update.log" "$(cat "$script_calls")"
fi
pass "update no longer uses the shared /tmp/omarchy-update.log"

# Without a runtime directory there is nowhere better to fall back to, but the
# root refusal below is what stops the common way a root-owned file lands there.
run_update
grep -qxF "/tmp/omarchy-update.log" "$script_calls" ||
  fail "update falls back to /tmp when no runtime dir is set" "$(cat "$script_calls")"
pass "update falls back to /tmp when no runtime dir is set"

# An explicit override wins, so a caller can direct the transcript somewhere else.
run_update XDG_RUNTIME_DIR="$boundary_tmp/run" OMARCHY_UPDATE_LOG="$boundary_tmp/explicit.log"
grep -qxF "$boundary_tmp/explicit.log" "$script_calls" ||
  fail "update honours an explicit OMARCHY_UPDATE_LOG" "$(cat "$script_calls")"
pass "update honours an explicit OMARCHY_UPDATE_LOG"

# Running the whole update as root would write a root-owned transcript that the
# ordinary user can no longer open. Every step sudo's for itself, so root is
# refused outright, the same way omarchy-dev-link does.
: >"$script_calls"
root_out=$(fakeroot env -u OMARCHY_UPDATE_LOGGED -u OMARCHY_UPDATE_LOG \
  SCRIPT_CALLS="$script_calls" "$SUDO_TEST_ROOT/bin/omarchy-update" 2>&1 || true)
grep -q "not under sudo" <<<"$root_out" ||
  fail "update refuses to run as root" "$root_out"
pass "update refuses to run as root"

# sudo resets the environment by default, so a plain `sudo omarchy update`
# arrives without OMARCHY_PATH. The root refusal has to come before the
# source-root check, or that check fails on the missing variable and prints its
# own error instead. env -i stands in for sudo's reset; fakeroot makes it UID 0.
plain_sudo_out=$(env -i PATH=/usr/bin SCRIPT_CALLS="$script_calls" \
  fakeroot "$SUDO_TEST_ROOT/bin/omarchy-update" 2>&1 || true)
grep -q "not under sudo" <<<"$plain_sudo_out" ||
  fail "update refuses a plain sudo run (environment reset) as root" "$plain_sudo_out"
pass "update refuses a plain sudo run (environment reset) as root"

# --- the consumer reads the same path ---

log="$boundary_tmp/analyze.log"

printf 'Updating linux initcpios\nInitcpio image generation successful\n' >"$log"
out=$(OMARCHY_UPDATE_LOG="$log" bash "$analyze" 2>&1)
[[ -z $out ]] || fail "analyze stays quiet when initramfs generation succeeded" "$out"
pass "analyze stays quiet when initramfs generation succeeded"

printf 'Updating linux initcpios\n' >"$log"
out=$(OMARCHY_UPDATE_LOG="$log" bash "$analyze" 2>&1)
grep -q "Initramfs generation may have failed" <<<"$out" ||
  fail "analyze still reports a failed initramfs generation" "$out"
pass "analyze still reports a failed initramfs generation"

# A transcript that was never written is not an error: the update may have
# stopped before script(1) ran. Previously this produced a raw grep error.
rm -f "$log"
out=$(OMARCHY_UPDATE_LOG="$log" bash "$analyze" 2>&1)
status=$?
(( status == 0 )) || fail "analyze exits cleanly when no transcript exists" "status $status"
[[ -z $out ]] || fail "analyze is silent when no transcript exists" "$out"
pass "analyze exits cleanly and silently when no transcript exists"
