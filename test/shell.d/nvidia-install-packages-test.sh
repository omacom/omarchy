#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Stop at the driver transaction, before the setup script writes to /etc.
assert_packages() {
  local description="$1" architecture="$2" driver="$3" expected="$4"
  local actual
  actual=$(TEST_ARCH="$architecture" TEST_DRIVER="$driver" \
    bash -euo pipefail -c '
      lspci() { printf "%s\n" "3D controller: NVIDIA Corporation"; }
      omarchy-hw-aarch64-n1x() { return 1; }
      omarchy-hw-x86() { [[ $TEST_ARCH == "x86_64" ]]; }
      omarchy-hw-nvidia-gsp() { [[ $TEST_DRIVER == "gsp" ]]; }
      omarchy-hw-nvidia-without-gsp() { [[ $TEST_DRIVER == "legacy" ]]; }
      omarchy-pkg-nvidia-modules() { printf "modules %s\n" "$*"; }
      omarchy-pkg-add() {
        printf "%s\n" "$*"
        exit 0
      }
      source "$ROOT/install/hardware/nvidia.sh"
    ')
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected; actual: $actual"
  pass "$description"
}

assert_packages "ARM GSP selection uses native packages" aarch64 gsp \
  $'modules --install\nnvidia-utils libva-nvidia-driver'
assert_packages "ARM legacy selection omits x86 multilib" aarch64 legacy \
  'nvidia-580xx-dkms nvidia-580xx-utils'
assert_packages "x86 GSP package selection adds multilib" x86_64 gsp \
  $'modules --install\nnvidia-utils lib32-nvidia-utils libva-nvidia-driver'
assert_packages "x86 legacy package selection stays unchanged" x86_64 legacy \
  'nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils'

# omarchy-pkg-nvidia-modules picks the prebuilt module package of every
# installed kernel, and DKMS as soon as one kernel has none.
modules_fixture=$(mktemp -d)
trap 'rm -rf "$modules_fixture"' EXIT
mkdir -p "$modules_fixture/bin"
cat >"$modules_fixture/bin/pacman" <<'SH'
#!/bin/bash
if [[ $1 == "-Si" ]]; then
  grep -qxF -- "${@: -1}" "$FIXTURE/available"
else
  printf 'pacman %s\n' "$*" >>"$FIXTURE/calls"
fi
SH
cat >"$modules_fixture/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$modules_fixture/bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
grep -qxF -- "$1" "$FIXTURE/installed"
SH
cat >"$modules_fixture/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$FIXTURE/calls"
SH
chmod +x "$modules_fixture/bin/"*

# Kernels by pkgbase, the packages the repositories have, and what's installed.
modules_case() {
  local kernel
  rm -rf "$modules_fixture/modules" "$modules_fixture/calls"
  for kernel in $1; do
    mkdir -p "$modules_fixture/modules/$kernel-tree"
    printf '%s\n' "$kernel" >"$modules_fixture/modules/$kernel-tree/pkgbase"
  done
  printf '%s\n' $2 >"$modules_fixture/available"
  printf '%s\n' $3 >"$modules_fixture/installed"
  touch "$modules_fixture/calls"
}

run_modules() {
  FIXTURE="$modules_fixture" OMARCHY_MODULES_PATH="$modules_fixture/modules" \
    PATH="$modules_fixture/bin:$PATH" "$ROOT/bin/omarchy-pkg-nvidia-modules" "$@"
}

prebuilt="linux-omarchy-nvidia-open linux-omarchy-eevdf-nvidia-open"

modules_case "linux-omarchy linux-omarchy-eevdf" "$prebuilt" ""
actual=$(run_modules)
[[ $actual == $'linux-omarchy-eevdf-nvidia-open\nlinux-omarchy-nvidia-open' ]] \
  || fail "every kernel gets its prebuilt modules" "actual: $actual"
pass "every kernel gets its prebuilt modules"

modules_case "linux-omarchy linux" "$prebuilt" ""
if run_modules >/dev/null; then
  fail "a kernel without prebuilt modules needs DKMS" "listed prebuilt modules"
fi
pass "a kernel without prebuilt modules needs DKMS"

modules_case "linux-omarchy" "$prebuilt" "nvidia-open-dkms"
run_modules --install
actual=$(<"$modules_fixture/calls")
[[ $actual == "pacman -S --needed --noconfirm --ask 4 -- linux-omarchy-nvidia-open" ]] \
  || fail "prebuilt modules replace DKMS in one transaction" "actual: $actual"
pass "prebuilt modules replace DKMS in one transaction"

modules_case "linux-omarchy linux-lts" "$prebuilt" "nvidia-open-dkms"
run_modules --install
actual=$(<"$modules_fixture/calls")
[[ $actual == "pkg-add nvidia-open-dkms" ]] \
  || fail "DKMS stays when a kernel has no prebuilt modules" "actual: $actual"
pass "DKMS stays when a kernel has no prebuilt modules"
