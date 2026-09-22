#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

update="$ROOT/bin/omarchy-update"
analyze="$ROOT/bin/omarchy-update-analyze-logs"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

# script(1) is where omarchy-update re-execs itself. Recording its arguments and
# stopping there is enough to assert which path the transcript would be written
# to, without running an update.
cat >"$stub_bin/script" <<'STUB'
#!/bin/bash
printf '%s\n' "${@: -1}" >>"${SCRIPT_CALLS:?}"
STUB
chmod +x "$stub_bin"/*

script_calls="$test_dir/script-calls"

run_update() {
  rm -f "$script_calls"
  : >"$script_calls"
  env -u OMARCHY_UPDATE_LOGGED -u OMARCHY_UPDATE_LOG -u XDG_RUNTIME_DIR "$@" \
    SCRIPT_CALLS="$script_calls" PATH="$stub_bin:$PATH" \
    bash "$update" >/dev/null 2>&1 || true
}

# The transcript belongs in the per-user runtime directory. A fixed path in
# world-writable /tmp lets any other local user pre-create the file, and
# fs.protected_regular then refuses this user's open, blocking the update.
run_update XDG_RUNTIME_DIR="$test_dir/run"
grep -qxF "$test_dir/run/omarchy-update.log" "$script_calls" ||
  fail "update writes its transcript under XDG_RUNTIME_DIR" "$(cat "$script_calls")"
pass "update writes its transcript under XDG_RUNTIME_DIR"

if grep -qxF "/tmp/omarchy-update.log" "$script_calls"; then
  fail "update no longer uses the shared /tmp/omarchy-update.log" "$(cat "$script_calls")"
fi
pass "update no longer uses the shared /tmp/omarchy-update.log"

# Without a runtime directory there is nowhere better to fall back to, but the
# root refusal above is what stops the common way a root-owned file lands there.
run_update
grep -qxF "/tmp/omarchy-update.log" "$script_calls" ||
  fail "update falls back to /tmp when no runtime dir is set" "$(cat "$script_calls")"
pass "update falls back to /tmp when no runtime dir is set"

# An explicit override wins, so a caller can direct the transcript somewhere else.
run_update XDG_RUNTIME_DIR="$test_dir/run" OMARCHY_UPDATE_LOG="$test_dir/explicit.log"
grep -qxF "$test_dir/explicit.log" "$script_calls" ||
  fail "update honours an explicit OMARCHY_UPDATE_LOG" "$(cat "$script_calls")"
pass "update honours an explicit OMARCHY_UPDATE_LOG"

# Running the whole update as root would write a root-owned transcript that the
# ordinary user can no longer open. Every step sudo's for itself, so root is
# refused outright, the same way omarchy-dev-link does.
root_out=$(fakeroot env -u OMARCHY_UPDATE_LOGGED PATH="$stub_bin:$PATH" \
  SCRIPT_CALLS="$script_calls" bash "$update" 2>&1 || true)
grep -q "not under sudo" <<<"$root_out" ||
  fail "update refuses to run as root" "$root_out"
pass "update refuses to run as root"

# --- the consumer reads the same path ---

log="$test_dir/analyze.log"

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
