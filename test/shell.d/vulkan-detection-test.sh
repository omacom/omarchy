#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

vulkan="$ROOT/install/hardware/vulkan.sh"
migration="$ROOT/migrations/1790666010.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
export TEST_LOG="$test_tmp/calls.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/lspci" <<'SH'
#!/bin/bash

cat "$LSPCI_FIXTURE"
SH

cat >"$stub_bin/uname" <<'SH'
#!/bin/bash

echo "$TEST_ARCH"
SH

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash

printf 'pacman %s\n' "$*" >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash

(( ${ASAHI_INSTALLED:-0} == 1 ))
SH

for helper in omarchy-pkg-add omarchy-pkg-drop; do
  cat >"$stub_bin/$helper" <<SH
#!/bin/bash

printf '$helper %s\n' "\$*" >>"\$TEST_LOG"
SH
done

chmod +x "$stub_bin"/*

t2_mac="$test_tmp/t2-mac"
cat >"$t2_mac" <<'TXT'
00:02.0 VGA compatible controller: Intel Corporation Iris Plus Graphics G7 (rev 07)
e6:00.1 Non-VGA unclassified device: Apple Inc. T2 Bridge Controller (rev 01)
e6:00.2 Non-VGA unclassified device: Apple Inc. T2 Secure Enclave Processor (rev 01)
TXT

hybrid="$test_tmp/hybrid"
cat >"$hybrid" <<'TXT'
00:02.0 VGA compatible controller: Intel Corporation UHD Graphics 630 (rev 02)
01:00.0 Display controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 14 [Radeon Pro 5500M] (rev 40)
e6:00.1 Non-VGA unclassified device: Apple Inc. T2 Bridge Controller (rev 01)
TXT

run_vulkan() {
  : >"$TEST_LOG"
  (PATH="$stub_bin:$PATH" LSPCI_FIXTURE=$1 source "$vulkan")
}

run_migration() {
  : >"$TEST_LOG"
  PATH="$stub_bin:$PATH" TEST_ARCH=$1 ASAHI_INSTALLED=$2 bash -euo pipefail "$migration" >/dev/null
}

run_vulkan "$t2_mac"
[[ $(<"$TEST_LOG") == "omarchy-pkg-add vulkan-intel" ]] ||
  fail "T2 Mac installs only vulkan-intel" "$(<"$TEST_LOG")"
pass "the T2 chip is not mistaken for an Apple GPU"

run_vulkan "$hybrid"
grep -q 'vulkan-intel' "$TEST_LOG" && grep -q 'vulkan-radeon' "$TEST_LOG" && ! grep -q 'vulkan-asahi' "$TEST_LOG" ||
  fail "hybrid T2 Mac installs Intel and Radeon Vulkan only" "$(<"$TEST_LOG")"
pass "VGA and Display controllers are still detected"

run_migration x86_64 1
grep -qx 'omarchy-pkg-drop vulkan-asahi' "$TEST_LOG" ||
  fail "migration drops vulkan-asahi on x86_64" "$(<"$TEST_LOG")"
pass "migration removes the stray Apple Silicon driver on x86_64"

run_migration x86_64 0
[[ ! -s $TEST_LOG ]] || fail "migration is a no-op when vulkan-asahi is absent" "$(<"$TEST_LOG")"
pass "migration is idempotent"

run_migration aarch64 1
[[ ! -s $TEST_LOG ]] || fail "migration leaves vulkan-asahi alone on aarch64" "$(<"$TEST_LOG")"
pass "migration leaves Apple Silicon installs alone"
