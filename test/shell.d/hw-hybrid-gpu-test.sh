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

# lspci reads config space and wakes a runtime-suspended dGPU, so the count
# must come from sysfs alone: a stub that fails loudly proves it is never run.
cat >"$fake_bin/lspci" <<'STUB'
#!/bin/bash
echo "lspci ran" >>"$LSPCI_LOG"
exit 1
STUB


# The products bound supergfxctl queries at 1s/3s (plus a 1s kill-after);
# shorten those bounds here instead of waiting them out against the
# blocked stubs. Other durations pass through untouched.
cat >"$fake_bin/timeout" <<'STUB'
#!/bin/bash
args=()
for arg in "$@"; do
  case $arg in
    --kill-after=1s) arg="--kill-after=0.2s" ;;
    1s | 3s) arg="0.2s" ;;
  esac
  args+=("$arg")
done
exec /usr/bin/timeout "${args[@]}"
STUB

chmod +x "$fake_bin"/*

export LSPCI_LOG="$test_tmp/lspci.log"

# A PCI bus with GPU_COUNT display controllers (VGA, 3D, and plain Display
# classes in turn) beside an audio device and a bridge that are not GPUs.
pci_devices() {
  local dir="$test_tmp/pci-${GPU_COUNT:-1}" classes=(0x030000 0x030200 0x038000) i
  rm -rf "$dir"
  for ((i = 0; i < ${GPU_COUNT:-1}; i++)); do
    mkdir -p "$dir/0000:0$i:00.0"
    echo "${classes[i % 3]}" >"$dir/0000:0$i:00.0/class"
  done
  mkdir -p "$dir/0000:10:00.1" "$dir/0000:11:00.0"
  echo 0x040300 >"$dir/0000:10:00.1/class"
  echo 0x060400 >"$dir/0000:11:00.0/class"
  echo "$dir"
}

hybrid_gpu() {
  OMARCHY_PCI_DEVICES_PATH="$(pci_devices)" PATH="$fake_bin:$PATH" timeout --kill-after=1s 10s bash "$ROOT/bin/omarchy-hw-hybrid-gpu"
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

GPU_COUNT=1 hybrid_gpu
status=$?
((status == 1)) ||
  fail "hybrid GPU detection sees one GPU beside other PCI devices as non-hybrid" "exit status: $status"
pass "hybrid GPU detection sees one GPU beside other PCI devices as non-hybrid"

GPU_COUNT=3 hybrid_gpu ||
  fail "hybrid GPU detection counts 3D and Display controllers as GPUs"
pass "hybrid GPU detection counts 3D and Display controllers as GPUs"

[[ ! -e $LSPCI_LOG ]] ||
  fail "hybrid GPU detection never runs lspci, which wakes a suspended dGPU"
pass "hybrid GPU detection never runs lspci, which wakes a suspended dGPU"
