#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-update
copy_boundary_file bin/omarchy-update-analyze-logs
stub_bin="$SUDO_TEST_ROOT/bin"
test_tmp="$boundary_tmp"

# script(1) stands in for the real transcript wrapper: record the typescript
# path it was handed and stop there, so the re-exec replaces the updater
# without running a whole update.
cat >"$stub_bin/script" <<'STUB'
#!/bin/bash
printf '%s\n' "${@: -1}" >"$SCRIPT_PATH_RECORD"
STUB
chmod +x "$stub_bin/script"

recorded_log_path() {
  SCRIPT_PATH_RECORD="$test_tmp/record" \
    PATH="$stub_bin:$PATH" \
    "$SUDO_TEST_ROOT/bin/omarchy-update" >"$test_tmp/out" 2>"$test_tmp/err"
}

runtime_dir="$test_tmp/runtime"
mkdir -m 700 -- "$runtime_dir"

# A user's transcript lands in their own runtime directory, never in the
# shared /tmp path two accounts used to fight over (#15679).
SCRIPT_PATH_RECORD="$test_tmp/record" \
  XDG_RUNTIME_DIR="$runtime_dir" \
  PATH="$stub_bin:$PATH" \
  recorded_log_path
[[ $(cat "$test_tmp/record") == "$runtime_dir/omarchy-update-$UID.log" ]] ||
  fail "update logs under XDG_RUNTIME_DIR" "got: $(cat "$test_tmp/record")"

(
  unset XDG_RUNTIME_DIR
  SCRIPT_PATH_RECORD="$test_tmp/record" \
    PATH="$stub_bin:$PATH" \
    recorded_log_path
)
[[ $(cat "$test_tmp/record") == "/tmp/omarchy-update-$UID.log" ]] ||
  fail "update logs under a per-user /tmp path without a runtime directory" "got: $(cat "$test_tmp/record")"

# omarchy-update-analyze-logs reads the same transcript, with and without a
# runtime directory.
printf 'Updating linux initcpios\n' >"$runtime_dir/omarchy-update-$UID.log"
out=$(XDG_RUNTIME_DIR="$runtime_dir" "$SUDO_TEST_ROOT/bin/omarchy-update-analyze-logs")
[[ $out == *"Initramfs generation may have failed"* ]] ||
  fail "analyze-logs reads the runtime-directory transcript" "got: $out"

# The copy falls back to this test's directory, not the real /tmp, so a
# transcript an earlier update left there is never touched.
sed -i \
  -e "s|:-/tmp}|:-$test_tmp}|" \
  -e "s|/tmp/omarchy-update.log|$test_tmp/omarchy-update.log|" \
  "$SUDO_TEST_ROOT/bin/omarchy-update-analyze-logs"
printf 'Updating linux initcpios\n' >"$test_tmp/omarchy-update-$UID.log"
out=$(env -u XDG_RUNTIME_DIR "$SUDO_TEST_ROOT/bin/omarchy-update-analyze-logs")
[[ $out == *"Initramfs generation may have failed"* ]] ||
  fail "analyze-logs reads the /tmp fallback transcript" "got: $out"

rm -f -- "$runtime_dir/omarchy-update-$UID.log" "$test_tmp/omarchy-update-$UID.log"
printf 'Updating linux initcpios\n' >"$test_tmp/omarchy-update.log"
out=$(XDG_RUNTIME_DIR="$runtime_dir" "$SUDO_TEST_ROOT/bin/omarchy-update-analyze-logs" 2>&1)
[[ $out == *"Initramfs generation may have failed"* && $out != *"No such file"* ]] ||
  fail "analyze-logs falls back to the legacy /tmp/omarchy-update.log transcript" "got: $out"

rm -f -- "$test_tmp/omarchy-update.log"
out=$(XDG_RUNTIME_DIR="$runtime_dir" "$SUDO_TEST_ROOT/bin/omarchy-update-analyze-logs" 2>&1)
[[ -z $out ]] ||
  fail "analyze-logs exits quietly when no transcript exists" "got: $out"

pass "update transcript path is per-user"
