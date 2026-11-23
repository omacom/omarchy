#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf -- "$tmp"' EXIT
export CALLS="$tmp/calls"
export PATH="$tmp:$ROOT/bin:$PATH"

cat >"$tmp/omarchy-hw-x86" <<'SH'
#!/bin/bash
[[ $TEST_ARCH == "x86" ]]
SH

cat >"$tmp/systemd-detect-virt" <<'SH'
#!/bin/bash
[[ $* == "--vm" ]] || exit 1
printf '%s\n' "$TEST_VIRT"
[[ $TEST_VIRT != "none" ]]
SH

cat >"$tmp/pacman" <<'SH'
#!/bin/bash
[[ $* == "-Q -- virtualbox-guest-utils-nox" && $TEST_NOX == "1" ]]
SH

cat >"$tmp/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$CALLS"
exit "$TEST_PKG_STATUS"
SH

cat >"$tmp/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALLS"
SH

chmod +x "$tmp"/omarchy-hw-x86 "$tmp"/systemd-detect-virt "$tmp"/pacman "$tmp"/omarchy-pkg-add "$tmp"/sudo

check_setup() {
  local description=$1 arch=$2 virt=$3 nox=$4 deferred=$5 pkg_status=$6 expected_status=$7
  local status=0 expected= actual
  shift 7
  : >"$CALLS"
  TEST_ARCH=$arch TEST_VIRT=$virt TEST_NOX=$nox OMARCHY_IMAGE_DEFERRED_HARDWARE=$deferred TEST_PKG_STATUS=$pkg_status \
    bash -euo pipefail -c 'source "$1"' _ "$ROOT/install/hardware/virtualbox.sh" || status=$?
  [[ $status == "$expected_status" ]] || fail "$description" "expected status $expected_status, got $status"
  if (( $# )); then
    expected=$(printf '%s\n' "$@")
  fi
  actual=$(<"$CALLS")
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected; got: $actual"
  pass "$description"
}

install='pkg-add virtualbox-guest-utils'
enable='sudo systemctl enable vboxservice.service'
start='sudo systemctl start --no-block vboxservice.service'

check_setup 'x86 VirtualBox installs and enables guest utilities' x86 oracle 0 0 0 0 "$install" "$enable"
check_setup 'deferred VirtualBox setup starts the service immediately' x86 oracle 0 1 0 0 "$install" "$enable" "$start"
check_setup 'an installed nox package is kept' x86 oracle 1 0 0 0 "$enable"
check_setup 'deferred setup with nox still starts the service' x86 oracle 1 1 0 0 "$enable" "$start"
check_setup 'ARM VirtualBox does not install x86 guest utilities' aarch64 oracle 0 0 0 0
check_setup 'VMware is not treated as VirtualBox' x86 vmware 0 0 0 0
check_setup 'KVM is not treated as VirtualBox' x86 kvm 0 0 0 0
check_setup 'a failed package install does not enable the service' x86 oracle 0 0 1 1 "$install"
