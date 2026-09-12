#!/bin/bash

source "$(dirname "$0")/base-test.sh"

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

chmod +x "$fake_bin"/*

# The detector counts display-class devices from sysfs rather than parsing lspci, so the
# GPU count is expressed as PCI device fixtures. 0x0300 is VGA, 0x0380 Display; 0x0200
# (ethernet) is present throughout to prove non-display devices are not counted.
write_pci_devices() {
  local count=${GPU_COUNT:-1} index=0

  rm -rf "$test_tmp/devices"
  mkdir -p "$test_tmp/devices/0000:00:1f.6"
  printf '0x8086\n' >"$test_tmp/devices/0000:00:1f.6/vendor"
  printf '0x020000\n' >"$test_tmp/devices/0000:00:1f.6/class"

  while ((index < count)); do
    local slot
    slot=$(printf '0000:%02x:00.0' "$index")
    mkdir -p "$test_tmp/devices/$slot"
    printf '0x10de\n' >"$test_tmp/devices/$slot/vendor"
    printf '0x030000\n' >"$test_tmp/devices/$slot/class"
    index=$((index + 1))
  done
}

hybrid_gpu() {
  write_pci_devices
  PATH="$fake_bin:$PATH" OMARCHY_PCI_DEVICES_PATH="$test_tmp/devices" \
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

GPU_COUNT=2 hybrid_gpu ||
  fail "hybrid GPU detection counts GPUs from sysfs without reading PCI config space"
pass "hybrid GPU detection counts GPUs from sysfs without reading PCI config space"

# Comments in the detector explain why lspci is avoided, so only inspect real code.
grep -v '^[[:space:]]*#' "$ROOT/bin/omarchy-hw-hybrid-gpu" | grep -q 'lspci' &&
  fail "hybrid GPU detection avoids lspci, which resumes a suspended GPU"
pass "hybrid GPU detection avoids lspci, which resumes a suspended GPU"
