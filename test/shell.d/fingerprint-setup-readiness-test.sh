#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

setup="$ROOT/bin/omarchy-setup-security-fingerprint"

tmp_dir=$(mktemp -d)
stub_bin="$tmp_dir/bin"
calls="$tmp_dir/calls.log"
mkdir -p "$stub_bin"
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$stub_bin/omarchy-hw-fingerprint" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-pkg-missing" <<'SH'
#!/bin/bash
# Keep the production package-install branch out of this unit test. The guard
# under test runs after package setup, regardless of whether packages were
# already present or installed in this invocation.
exit 1
SH

cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
printf 'busctl\t%s\n' "$*" >>"$CALLS"
[[ "${FPRINTD_DEVICE_AVAILABLE:-no}" == "yes" ]]
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo\t%s\n' "$*" >>"$CALLS"

# A successful readiness probe should reach the existing enrollment path. Stop
# there so this test never touches PAM or any real fingerprint service.
if [[ "${1:-}" == "fprintd-enroll" ]]; then
  exit 1
fi

exit 99
SH

chmod +x "$stub_bin"/*

run_setup() {
  local device_available="$1"

  : >"$calls"
  set +e
  RUN_OUTPUT=$(PATH="$stub_bin:$PATH" CALLS="$calls" FPRINTD_DEVICE_AVAILABLE="$device_available" USER=tester "$setup" 2>&1)
  RUN_STATUS=$?
  set -e
}

run_setup no

(( RUN_STATUS == 1 )) ||
  fail "fingerprint setup stops when fprintd exposes no usable device" "status: $RUN_STATUS"
[[ "$RUN_OUTPUT" == *"Fingerprint sensor detected, but fprintd did not expose a usable device."* ]] ||
  fail "fingerprint setup explains that the backend cannot expose the reader" "$RUN_OUTPUT"
[[ "$RUN_OUTPUT" != *"Let's setup your right index finger"* ]] ||
  fail "fingerprint setup does not ask for a finger before backend readiness is known" "$RUN_OUTPUT"
if grep -Fq $'sudo\tfprintd-enroll ' "$calls"; then
  fail "fingerprint setup does not call fprintd-enroll when the backend has no device" "$(cat "$calls")"
fi
pass "an unsupported fingerprint backend stops before enrollment"

run_setup yes

(( RUN_STATUS == 1 )) ||
  fail "supported-device test stops at the deliberately failed enrollment stub" "status: $RUN_STATUS"
[[ "$RUN_OUTPUT" == *"Let's setup your right index finger"* ]] ||
  fail "fingerprint setup keeps the enrollment prompt for a usable device" "$RUN_OUTPUT"
grep -Fq $'busctl\t--system call net.reactivated.Fprint /net/reactivated/Fprint/Manager net.reactivated.Fprint.Manager GetDefaultDevice' "$calls" ||
  fail "fingerprint setup probes the fprintd Manager for a default device" "$(cat "$calls")"
grep -Fq $'sudo\tfprintd-enroll tester' "$calls" ||
  fail "fingerprint setup reaches the existing enrollment command for a usable device" "$(cat "$calls")"
pass "a usable fprintd device keeps the existing enrollment path"
