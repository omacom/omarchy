#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
mkdir -p "$mock_bin"

export REAL_GREP
REAL_GREP=$(command -v grep)

cat >"$mock_bin/grep" <<'SH'
#!/bin/bash
if [[ $* == *"/proc/cpuinfo"* ]]; then
  [[ ${OMARCHY_TEST_AVX2:-false} == "true" ]]
else
  exec "$REAL_GREP" "$@"
fi
SH

for command in gum omarchy-pkg-add voxtype hyprctl omarchy-restart-shell omarchy-notification-send; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
printf '%s:%s\n' "$(basename "$0")" "$*" >>"$OMARCHY_TEST_CALL_LOG"
SH
done
cat >"$mock_bin/omarchy-hw-vulkan" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin"/*

HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALL_LOG="$call_log" \
  PATH="$mock_bin:$PATH" bash "$ROOT/bin/omarchy-voxtype-install"

grep -Fq "omarchy-pkg-add:wtype voxtype-bin" "$call_log" ||
  fail "Voxtype installer installs its packages on CPUs without AVX2" "$(cat "$call_log")"
grep -Fq "voxtype:setup --download --no-post-install" "$call_log" ||
  fail "Voxtype installer downloads its model on CPUs without AVX2" "$(cat "$call_log")"
grep -Fq "voxtype:setup systemd" "$call_log" ||
  fail "Voxtype installer enables its service on CPUs without AVX2" "$(cat "$call_log")"
if grep -Fq "voxtype:setup gpu" "$call_log"; then
  fail "Voxtype installer keeps the CPU build on CPUs without AVX2, even with Vulkan" "$(cat "$call_log")"
fi
pass "Voxtype installer keeps the CPU build on CPUs without AVX2"

: >"$call_log"
HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALL_LOG="$call_log" \
  OMARCHY_TEST_AVX2=true PATH="$mock_bin:$PATH" \
  bash "$ROOT/bin/omarchy-voxtype-install"

grep -Fq "gum:confirm Install Voxtype + AI model (~150MB) to enable dictation?" "$call_log" ||
  fail "Voxtype installer still prompts on AVX2 CPUs" "$(cat "$call_log")"
grep -Fq "omarchy-pkg-add:wtype voxtype-bin" "$call_log" ||
  fail "Voxtype installer still installs its packages on AVX2 CPUs" "$(cat "$call_log")"
grep -Fq "voxtype:setup --download --no-post-install" "$call_log" ||
  fail "Voxtype installer still downloads its model on AVX2 CPUs" "$(cat "$call_log")"
grep -Fq "voxtype:setup gpu --enable" "$call_log" ||
  fail "Voxtype installer still enables Vulkan on AVX2 CPUs" "$(cat "$call_log")"
pass "Voxtype installer keeps the existing setup flow on AVX2 CPUs"
