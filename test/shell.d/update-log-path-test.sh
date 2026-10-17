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

printf 'Updating linux initcpios\n' >"/tmp/omarchy-update-$UID.log"
out=$(env -u XDG_RUNTIME_DIR "$SUDO_TEST_ROOT/bin/omarchy-update-analyze-logs")
[[ $out == *"Initramfs generation may have failed"* ]] ||
  fail "analyze-logs reads the /tmp fallback transcript" "got: $out"
rm -f -- "/tmp/omarchy-update-$UID.log"

pass "update transcript path is per-user"
