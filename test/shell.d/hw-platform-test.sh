#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

detector="$ROOT/bin/omarchy-hw-platform"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

for platform in apple-silicon qualcomm generic-aarch64 generic; do
  fake_platform "$test_tmp/$platform" "$platform"
done

# A privileged caller reads the live device tree and the system uname, never
# the fixture roots or PATH its environment names. Run it as root when the suite
# is root and as namespaced root otherwise.
root_runner=()
if (( EUID != 0 )); then
  root_runner=(unshare --user --map-root-user)
fi
if (( EUID == 0 )) || unshare --user --map-root-user true 2>/dev/null; then
  live=$("${root_runner[@]}" "$detector") || fail "root detects the live platform"
  [[ $live =~ ^(apple-silicon|qualcomm|generic-aarch64|generic)$ ]] || fail "root detects the live platform" "live: $live"
  for platform in apple-silicon qualcomm generic-aarch64 generic; do
    fixture="$test_tmp/$platform"
    if [[ -f $fixture/proc/device-tree/compatible ]]; then
      mkdir -p "$fixture/sys/firmware/devicetree/base"
      cp "$fixture/proc/device-tree/compatible" "$fixture/sys/firmware/devicetree/base/compatible"
    fi
    overridden=$(OMARCHY_PROC_ROOT="$fixture/proc" OMARCHY_SYS_ROOT="$fixture/sys" PATH="$fixture/bin:$ROOT/bin:$PATH" \
      "${root_runner[@]}" "$detector") || fail "root detects the live platform with a $platform fixture in its environment"
    [[ $overridden == "$live" ]] ||
      fail "root ignores a $platform fixture in its environment" "live: $live
with fixture: $overridden"
  done
  pass "root ignores fixture roots and PATH when detecting the platform"
else
  skip "no unprivileged user namespace; skipping the root override probe"
fi

# -p in the shebang is what keeps exported functions and BASH_ENV out, so an
# ordinary Bash launch with a decoy -p argument is refused before it reads anything.
for command in omarchy-hw-platform omarchy-hw-apple-silicon; do
  if /usr/bin/bash "$ROOT/bin/$command" -p >/dev/null 2>"$test_tmp/error"; then
    fail "$command refuses an ordinary Bash launch"
  fi
  grep -Fq "Refusing an unsafe Bash startup" "$test_tmp/error" || fail "$command explains the refusal" "$(cat "$test_tmp/error")"
done
pass "the detector and the Apple predicate refuse an ordinary Bash launch with a decoy -p"

require_platform_fixtures "the platform fixtures"

# The four platforms every caller is written against.
for platform in apple-silicon qualcomm generic-aarch64 generic; do
  fixture="$test_tmp/$platform"
  actual=$(OMARCHY_PROC_ROOT="$fixture/proc" PATH="$fixture/bin:$ROOT/bin:$PATH" "$detector") ||
    fail "the $platform fixture is detected"
  [[ $actual == "$platform" ]] || fail "the $platform fixture is detected" "actual: $actual"

  apple_status=0
  OMARCHY_PROC_ROOT="$fixture/proc" PATH="$fixture/bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-hw-apple-silicon" || apple_status=$?
  if [[ $platform == "apple-silicon" ]]; then
    (( apple_status == 0 )) || fail "the Apple predicate accepts the Apple fixture"
  else
    (( apple_status != 0 )) || fail "the Apple predicate rejects the $platform fixture"
  fi
  pass "the $platform fixture is detected and the Apple predicate agrees"
done

# Systemd and the shell run the predicate by absolute path with whatever PATH
# they have; it must use the detector shipped beside it.
fixture="$test_tmp/apple-silicon"
OMARCHY_PROC_ROOT="$fixture/proc" PATH="$fixture/bin:/usr/bin:/bin" "$ROOT/bin/omarchy-hw-apple-silicon" ||
  fail "the Apple predicate finds its detector without Omarchy on PATH"
pass "the Apple predicate finds its detector without Omarchy on PATH"

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/uname" <<'SH'
#!/bin/bash
[[ ${1:-} == -m ]] && { printf '%s\n' "${TEST_ARCH:-aarch64}"; exit 0; }
exec /usr/bin/uname "$@"
SH
chmod +x "$stub_bin/uname"

# $1 names a case directory holding proc/ and sys/ roots; $2 is the CPU.
detect() {
  local case_dir="$test_tmp/cases/$1"
  TEST_ARCH="${2:-aarch64}" OMARCHY_PROC_ROOT="$case_dir/proc" OMARCHY_SYS_ROOT="$case_dir/sys" \
    PATH="$stub_bin:$ROOT/bin:$PATH" "$detector" 2>"$test_tmp/error"
}

# $1 case, $2 proc|sys, then the compatible tokens.
write_tree() {
  local case_dir="$test_tmp/cases/$1" tree="$2" file
  shift 2
  mkdir -p "$case_dir/proc" "$case_dir/sys"
  if [[ $tree == "proc" ]]; then
    file="$case_dir/proc/device-tree/compatible"
  else
    file="$case_dir/sys/firmware/devicetree/base/compatible"
  fi
  mkdir -p "$(dirname "$file")"
  printf '%s\0' "$@" >"$file"
}

expect() {
  local name="$1" machine="$2" expected="$3" description="$4" actual
  actual=$(detect "$name" "$machine") || fail "$description" "$(cat "$test_tmp/error")"
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected
actual:   $actual"
}

expect_contradiction() {
  local name="$1" machine="$2" description="$3"
  if detect "$name" "$machine" >/dev/null; then
    fail "$description"
  fi
  grep -Fq "contradictory platform identity" "$test_tmp/error" || fail "$description explains itself" "$(cat "$test_tmp/error")"
}

# Real boards: the M1 Pro and M2 Max test Macs, an M1 Mac mini, and the
# Snapdragon X laptops Dragon supports.
write_tree m1-pro proc apple,j314s apple,t6000 apple,arm-platform
write_tree m2-max proc apple,j416c apple,t6021 apple,arm-platform
write_tree m1-mini proc apple,j274 apple,t8103 apple,arm-platform
write_tree yoga-slim7x proc lenovo,yoga-slim7x qcom,x1e80100
write_tree xps13-9345 proc dell,xps13-9345 qcom,x1e80100
write_tree t14s proc lenovo,thinkpad-t14s qcom,x1e78100 qcom,x1e80100
for board in m1-pro m2-max m1-mini; do
  expect "$board" aarch64 apple-silicon "the $board device tree is Apple Silicon"
done
for board in yoga-slim7x xps13-9345 t14s; do
  expect "$board" aarch64 qualcomm "the $board device tree is Qualcomm"
done
pass "real Apple and Snapdragon device trees are recognised"

write_tree qemu-virt proc linux,dummy-virt
write_tree raspberry-pi proc raspberrypi,5-model-b brcm,bcm2712
mkdir -p "$test_tmp/cases/acpi/proc" "$test_tmp/cases/acpi/sys"
expect qemu-virt aarch64 generic-aarch64 "a QEMU virt board is generic aarch64"
expect raspberry-pi aarch64 generic-aarch64 "a Raspberry Pi is generic aarch64"
expect acpi aarch64 generic-aarch64 "an aarch64 machine without a device tree is generic aarch64"
expect acpi x86_64 generic "an x86 machine without a device tree is generic"
pass "unknown aarch64 and x86 machines are generic"

# Only a token's vendor prefix identifies the board; the old detector matched
# "apple," anywhere in the file.
write_tree substring proc pineapple,board acmeqcom,soc vendor,apple,x vendor,qcom,y
expect substring aarch64 generic-aarch64 "vendor names inside other tokens do not identify the board"
pass "only a token's vendor prefix identifies the board"

# /proc/device-tree is a link into sysfs; read sysfs when it is missing.
write_tree sysfs-qualcomm sys lenovo,yoga-slim7x qcom,x1e80100
write_tree sysfs-apple sys apple,j314s apple,t6000 apple,arm-platform
expect sysfs-qualcomm aarch64 qualcomm "sysfs identifies Qualcomm without /proc/device-tree"
expect sysfs-apple aarch64 apple-silicon "sysfs identifies Apple Silicon without /proc/device-tree"
write_tree agree proc apple,j314s apple,t6000 apple,arm-platform
write_tree agree sys apple,j314s apple,t6000 apple,arm-platform
expect agree aarch64 apple-silicon "matching proc and sysfs trees agree"
pass "sysfs is the fallback for the device tree"

write_tree both-vendors proc apple,j314s qcom,x1e80100
expect_contradiction both-vendors aarch64 "a device tree naming Apple and Qualcomm fails"
write_tree sources-disagree proc apple,j314s apple,t6000 apple,arm-platform
write_tree sources-disagree sys lenovo,yoga-slim7x qcom,x1e80100
expect_contradiction sources-disagree aarch64 "proc and sysfs naming different vendors fails"
write_tree vendor-vs-none proc apple,j314s apple,t6000 apple,arm-platform
write_tree vendor-vs-none sys linux,dummy-virt
expect_contradiction vendor-vs-none aarch64 "proc naming Apple while sysfs names nobody fails"
expect_contradiction m1-pro x86_64 "an Apple device tree on an x86 CPU fails"
expect_contradiction yoga-slim7x x86_64 "a Qualcomm device tree on an x86 CPU fails"
if TEST_ARCH=x86_64 OMARCHY_PROC_ROOT="$test_tmp/cases/m1-pro/proc" PATH="$stub_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-hw-apple-silicon" 2>/dev/null; then
  fail "the Apple predicate fails closed on contradictory identity"
fi
pass "contradictory identity fails with an explanation"

failing_uname="$test_tmp/failing-uname"
mkdir -p "$failing_uname"
printf '#!/bin/bash\nexit 1\n' >"$failing_uname/uname"
chmod +x "$failing_uname/uname"
if OMARCHY_PROC_ROOT="$test_tmp/cases/acpi/proc" PATH="$failing_uname:$PATH" "$detector" 2>"$test_tmp/error"; then
  fail "an unreadable CPU architecture fails instead of guessing generic"
fi
grep -Fq "cannot read the CPU architecture" "$test_tmp/error" || fail "an unreadable CPU architecture explains itself" "$(cat "$test_tmp/error")"
pass "an unreadable CPU architecture fails instead of guessing generic"

# Dragon's omarchy-hw-qualcomm-soc: any "qcom," token in the boot device tree.
dragon_qualcomm() {
  tr '\0' '\n' <"$1" | grep '^qcom,' >/dev/null
}
for case_dir in "$test_tmp"/cases/*; do
  name=$(basename "$case_dir")
  compatible="$case_dir/proc/device-tree/compatible"
  [[ -f $compatible && ! -f $case_dir/sys/firmware/devicetree/base/compatible ]] || continue
  platform=$(detect "$name" aarch64 2>/dev/null) || continue
  if dragon_qualcomm "$compatible"; then
    [[ $platform == "qualcomm" ]] || fail "Qualcomm detection matches Dragon on $name" "platform: $platform"
  else
    [[ $platform != "qualcomm" ]] || fail "Qualcomm detection matches Dragon on $name"
  fi
done
pass "Qualcomm detection matches Dragon's omarchy-hw-qualcomm-soc on every aarch64 fixture"
