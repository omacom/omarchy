#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home" "$tmp_dir/modules"
cat >"$tmp_dir/bin/uname" <<'STUB'
#!/bin/bash
echo "$TEST_RUNNING_KERNEL"
STUB
cat >"$tmp_dir/bin/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Qo" ]] && grep -Fxq "$2" "$TEST_OWNED_FILES"
STUB
cat >"$tmp_dir/bin/gum" <<'STUB'
#!/bin/bash
printf 'prompt:%s\n' "$*" >>"$TEST_LOG"
exit 1
STUB
cat >"$tmp_dir/bin/pgrep" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$tmp_dir/bin"/*

export TEST_OWNED_FILES="$tmp_dir/owned" TEST_LOG="$tmp_dir/log"

# kernel VERSION FILE...: a modules directory holding the given package-owned files
kernel() {
  local version=$1 file
  shift
  rm -rf "$tmp_dir/modules"
  mkdir -p "$tmp_dir/modules/$version"
  : >"$TEST_OWNED_FILES"
  for file in "$@"; do
    touch "$tmp_dir/modules/$version/$file"
    echo "$tmp_dir/modules/$version/$file" >>"$TEST_OWNED_FILES"
  done
}

prompts() {
  : >"$TEST_LOG"
  TEST_RUNNING_KERNEL=$1 OMARCHY_KERNEL_MODULES_PATH="$tmp_dir/modules" HOME="$tmp_dir/home" \
    PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-update-restart" --reboot-only >/dev/null 2>&1
  cat "$TEST_LOG"
}

kernel 7.2.8-1-aarch64-ARCH modules.builtin
[[ -z $(prompts 7.2.8-1-aarch64-ARCH) ]] || fail "a running Arch Linux ARM kernel, which ships no vmlinuz, asks for a reboot"
pass "a running Arch Linux ARM kernel does not ask for a reboot"

kernel 7.2.8-arch1-1 modules.builtin vmlinuz
[[ -z $(prompts 7.2.8-arch1-1) ]] || fail "a running Arch kernel asks for a reboot"
pass "a running Arch kernel does not ask for a reboot"

kernel 7.2.9-1-aarch64-ARCH modules.builtin
grep -Fxq "prompt:confirm Linux kernel has been updated. Reboot?" <<<"$(prompts 7.2.8-1-aarch64-ARCH)" ||
  fail "an updated kernel asks for a reboot"
pass "an updated kernel asks for a reboot"

kernel 7.2.8-1-aarch64-ARCH
touch "$tmp_dir/modules/7.2.8-1-aarch64-ARCH/modules.builtin"
grep -Fxq "prompt:confirm Linux kernel has been updated. Reboot?" <<<"$(prompts 7.2.8-1-aarch64-ARCH)" ||
  fail "a leftover directory no package owns asks for a reboot"
pass "a leftover directory no package owns asks for a reboot"
