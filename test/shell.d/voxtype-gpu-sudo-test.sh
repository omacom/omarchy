#!/bin/bash

# Voxtype GPU enable must run under sudo so /usr/bin/voxtype can be rewritten;
# a failed step must be visible rather than reported as a clean install (#11110).

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/bin/omarchy-voxtype-install"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
home="$test_tmp/home"
calls="$test_tmp/calls"
mkdir -p "$stub_bin" "$home" "$test_tmp/omarchy/default/voxtype"
: >"$test_tmp/omarchy/default/voxtype/config.toml"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALLS"
SH

cat >"$stub_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
# Exit 0 means Vulkan is available (same convention as the real helper).
exit "${HW_VULKAN_STATUS:-0}"
SH

cat >"$stub_bin/voxtype" <<'SH'
#!/bin/bash
printf 'voxtype %s\n' "$*" >>"$CALLS"
if [[ $1 == "setup" && $2 == "gpu" ]]; then
  # Only the elevated path may rewrite /usr/bin/voxtype.
  [[ ${VOXTYPE_AS_ROOT:-0} == 1 ]] || {
    echo "Failed to remove existing /usr/bin/voxtype (need sudo?): Permission denied" >&2
    exit 1
  }
  [[ ${GPU_ENABLE_FAIL:-0} == 1 ]] && exit 1
  exit 0
fi
exit 0
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALLS"
VOXTYPE_AS_ROOT=1 exec "$@"
SH

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf 'notify\n' >>"$CALLS"
SH

chmod +x "$stub_bin"/*

run_install() {
  : >"$calls"
  env "$@" \
    HOME="$home" \
    PATH="$stub_bin:$PATH" \
    OMARCHY_PATH="$test_tmp/omarchy" \
    CALLS="$calls" \
    bash "$script"
}

# Vulkan host: GPU enable must go through sudo so the symlink rewrite succeeds.
output=$(run_install HW_VULKAN_STATUS=0 2>&1)
grep -qx 'sudo voxtype setup gpu --enable' "$calls" ||
  fail "GPU enable runs under sudo on Vulkan hosts" "$(cat "$calls")"
# A bare user-level gpu call would appear without a preceding sudo line in CALLS;
# ensure every gpu enable was via sudo by requiring the sudo line above.
grep -q '^voxtype setup gpu --enable$' "$calls" ||
  fail "elevated voxtype gpu enable ran" "$(cat "$calls")"
grep -q '^notify$' "$calls" || fail "successful GPU enable still finishes install" "$output$(cat "$calls")"
pass "Vulkan install enables the GPU backend through sudo"

# Without Vulkan, skip the GPU step entirely.
run_install HW_VULKAN_STATUS=1 >/dev/null
! grep -q 'setup gpu' "$calls" || fail "non-Vulkan hosts skip GPU enable" "$(cat "$calls")"
pass "non-Vulkan install skips GPU enable"

# Elevated GPU enable still fails: warn instead of a silent CPU fallback.
output=$(run_install HW_VULKAN_STATUS=0 GPU_ENABLE_FAIL=1 2>&1)
grep -qx 'sudo voxtype setup gpu --enable' "$calls" ||
  fail "failed GPU enable was still attempted under sudo" "$(cat "$calls")"
[[ $output == *"could not enable the Voxtype GPU backend"* ]] ||
  fail "failed GPU enable prints a warning" "$output"
grep -q '^notify$' "$calls" || fail "failed GPU enable still completes dictation install" "$(cat "$calls")"
pass "failed GPU enable warns instead of silent CPU fallback"
