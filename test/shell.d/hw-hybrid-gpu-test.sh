#!/bin/bash

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d) || fail "test temp directory is available"
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
mkdir -p "$fake_bin"

cat >"$fake_bin/supergfxctl" <<'STUB'
#!/bin/bash

[[ $1 == "-s" ]] || exit 64

case "${BLOCKED:-no}" in
kill-only)
  trap '' TERM
  /usr/bin/sleep 30
  ;;
term)
  /usr/bin/sleep 30
  ;;
esac

((${FAIL_STATUS:-0})) && exit "$FAIL_STATUS"

printf '%s\n' "${SUPPORTED_MODES:-Integrated Hybrid}"
STUB

chmod +x "$fake_bin/supergfxctl"

devices_dir="$test_tmp/devices"

# Write N PCI display controllers as sysfs device directories. The class prefix
# 0x03 is what the detector counts and covers VGA, 3D, and Display controllers.
write_display_devices() {
  rm -rf "$devices_dir"
  mkdir -p "$devices_dir"

  local index=0
  for _ in $(seq "${1:-0}"); do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$devices_dir/$slot"
    printf '0x0000\n' >"$devices_dir/$slot/vendor"
    printf '0x030000\n' >"$devices_dir/$slot/class"
    index=$((index + 1))
  done
}

hybrid_gpu() {
  write_display_devices "${GPU_COUNT:-0}"
  PATH="$fake_bin:$PATH" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_PCI_DEVICES_PATH="$devices_dir" \
    timeout --kill-after=1s 10s bash "$ROOT/bin/omarchy-hw-hybrid-gpu"
}

hybrid_gpu ||
  fail "hybrid GPU detection sees a supported Hybrid mode"
pass "hybrid GPU detection sees a supported Hybrid mode"

SUPPORTED_MODES="Integrated Vfio" hybrid_gpu
status=$?
((status == 1)) ||
  fail "hybrid GPU detection trusts supergfxctl when Hybrid is unsupported" "exit status: $status"
pass "hybrid GPU detection trusts supergfxctl when Hybrid is unsupported"

FAIL_STATUS=2 GPU_COUNT=2 hybrid_gpu
status=$?
((status == 1)) ||
  fail "hybrid GPU detection hides on an ordinary supergfxctl failure" "exit status: $status"
pass "hybrid GPU detection hides on an ordinary supergfxctl failure"

BLOCKED=term GPU_COUNT=1 hybrid_gpu
status=$?
((status == 1)) ||
  fail "hybrid GPU detection sees one GPU as non-hybrid after a clean timeout" "exit status: $status"
pass "hybrid GPU detection sees one GPU as non-hybrid after a clean timeout"

BLOCKED=term GPU_COUNT=2 hybrid_gpu ||
  fail "hybrid GPU detection counts multiple GPUs after a clean timeout"
pass "hybrid GPU detection counts multiple GPUs after a clean timeout"

BLOCKED=kill-only GPU_COUNT=1 hybrid_gpu
status=$?
((status != 124 && status != 137)) ||
  fail "hybrid GPU detection stays bounded when supergfxd ignores the timeout signal"
((status == 1)) ||
  fail "hybrid GPU detection sees one GPU as non-hybrid when supergfxd is wedged" "exit status: $status"
pass "hybrid GPU detection stays bounded when supergfxd ignores the timeout signal"

BLOCKED=kill-only GPU_COUNT=2 hybrid_gpu ||
  fail "hybrid GPU detection counts multiple GPUs when supergfxd is wedged"
pass "hybrid GPU detection counts multiple GPUs when supergfxd is wedged"

cat >"$fake_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$fake_bin/omarchy-cmd-present"

GPU_COUNT=2 hybrid_gpu ||
  fail "hybrid GPU detection counts GPUs without supergfxctl"
pass "hybrid GPU detection counts GPUs without supergfxctl"
