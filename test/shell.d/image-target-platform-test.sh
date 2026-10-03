#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-hw-platform answers with the image-target manifest while a root is
# being built, and with the hardware once it boots. Each world below is what one
# detector run sees: image/ is the root, proc/ its /proc (the host's device tree
# and PID 1), bin/ a uname for the CPU it runs on.

detector="$ROOT/bin/omarchy-hw-platform"
umask 022
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

apple_manifest=$'format=1\nplatform=apple-silicon\n'

# $1 world, $2 CPU, then the host's device-tree tokens (none: no device tree).
world() {
  local dir="$test_tmp/worlds/$1" cpu=$2
  shift 2
  rm -rf "$dir"
  mkdir -p "$dir/image" "$dir/proc" "$dir/bin" "$dir/host"
  if (( $# )); then
    mkdir -p "$dir/proc/device-tree"
    printf '%s\0' "$@" >"$dir/proc/device-tree/compatible"
  fi
  cat >"$dir/bin/uname" <<SH
#!/bin/bash
[[ \${1:-} == -m ]] && { echo $cpu; exit 0; }
exec /usr/bin/uname "\$@"
SH
  chmod +x "$dir/bin/uname"
}

# $1 world, $2 how PID 1 sees the root: chroot (PID 1 is the build host's),
# own (PID 1 runs in the root, as in a PID namespace or a booted system),
# hidden (PID 1 is visible but its root is not, as for a normal user); $3 what
# PID 1 is, systemd unless named. Without a call the world has no /proc/1, as
# in a root without /proc or behind hidepid.
pid1() {
  local dir="$test_tmp/worlds/$1"
  mkdir -p "$dir/proc/1"
  echo "${3:-systemd}" >"$dir/proc/1/comm"
  case $2 in
    chroot) ln -s ../../host "$dir/proc/1/root" ;;
    own) ln -s ../../image "$dir/proc/1/root" ;;
    hidden) ;;
  esac
}

systemd_runs() {
  mkdir -p "$test_tmp/worlds/$1/image/run/systemd/system"
}

# $1 world, $2 manifest body.
manifest() {
  local image_dir="$test_tmp/worlds/$1/image/var/lib/omarchy/image"
  mkdir -p "$image_dir"
  chmod 0755 "$image_dir"
  printf '%s' "$2" >"$image_dir/target"
  chmod 0644 "$image_dir/target"
}

in_world() {
  local dir="$test_tmp/worlds/$1"
  shift
  OMARCHY_PROC_ROOT="$dir/proc" OMARCHY_IMAGE_ROOT="$dir/image" PATH="$dir/bin:$ROOT/bin:$PATH" "$@"
}

detect() {
  in_world "$1" "$detector" 2>"$test_tmp/error"
}

expect() {
  local name=$1 expected=$2 description=$3 actual
  actual=$(detect "$name") || fail "$description" "$(cat "$test_tmp/error")"
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected
actual:   $actual"
  pass "$description"
}

expect_refused() {
  local name=$1 message=$2 description=$3
  if detect "$name" >/dev/null; then
    fail "$description"
  fi
  grep -Fq "$message" "$test_tmp/error" || fail "$description explains itself" "$(cat "$test_tmp/error")"
  pass "$description"
}

# --- Root reads only the live system -----------------------------------------

root_runner=()
if (( EUID != 0 )); then
  root_runner=(unshare --user --map-root-user)
fi
if (( EUID == 0 )) || unshare --user --map-root-user true 2>/dev/null; then
  live=$("${root_runner[@]}" "$detector") || fail "root detects the live platform"
  apple_live=0
  "${root_runner[@]}" "$ROOT/bin/omarchy-hw-apple-silicon" || apple_live=$?

  # A world that would make any environment-led detector answer with another
  # platform than the live one.
  if [[ $live == "apple-silicon" ]]; then
    hostile=qualcomm
    hostile_tokens=("lenovo,yoga-slim7x" "qcom,x1e80100")
  else
    hostile=apple-silicon
    hostile_tokens=("apple,j416c" "apple,t6021" "apple,arm-platform")
  fi
  world hostile aarch64 "${hostile_tokens[@]}"
  pid1 hostile chroot
  manifest hostile $'format=1\nplatform='"$hostile"$'\n'
  hostile_dir="$test_tmp/worlds/hostile"
  printf 'echo %s\nexit 0\n' "$hostile" >"$test_tmp/bash-env"

  # Exported functions shadow commands and even builtins in a plain bash, and
  # BASH_ENV runs before its first line; --clean-environment is what the
  # detector passes itself once it has restarted.
  hostile_env=(
    OMARCHY_PROC_ROOT="$hostile_dir/proc" OMARCHY_SYS_ROOT="$hostile_dir/sys" OMARCHY_IMAGE_ROOT="$hostile_dir/image"
    PATH="$hostile_dir/bin:$ROOT/bin:$PATH" BASH_ENV="$test_tmp/bash-env"
    'BASH_FUNC_uname%%=() { echo aarch64; }'
    'BASH_FUNC_mapfile%%=() { tokens=('"${hostile_tokens[0]}"'); }'
    'BASH_FUNC_stat%%=() { echo 0 644; }'
    'BASH_FUNC_dirname%%=() { echo '"$hostile_dir/bin"'; }'
  )
  printf '#!/bin/bash\necho %s\n' "$hostile" >"$hostile_dir/bin/omarchy-hw-platform"
  chmod +x "$hostile_dir/bin/omarchy-hw-platform"
  for flag in "" --clean-environment; do
    args=()
    [[ -z $flag ]] || args=("$flag")
    overridden=$(env "${hostile_env[@]}" "${root_runner[@]}" "$detector" "${args[@]}") ||
      fail "root detects the live platform with a hostile environment${flag:+ and $flag}"
    [[ $overridden == "$live" ]] ||
      fail "root ignores fixture roots, PATH, BASH_ENV and exported functions${flag:+ with $flag}" "live: $live
hostile: $overridden"
  done
  apple_hostile=0
  env "${hostile_env[@]}" "${root_runner[@]}" "$ROOT/bin/omarchy-hw-apple-silicon" || apple_hostile=$?
  (( apple_hostile == apple_live )) || fail "the Apple predicate ignores a hostile root environment"
  pass "root ignores fixture roots, PATH, BASH_ENV and exported functions"
else
  skip "no unprivileged user namespace; skipping the root environment probe"
fi

# Root with a manifest at the live path: a private mount namespace lays a
# fixture over /var/lib and /run, and in a PID namespace PID 1 is a copy of bash
# named for what it plays, the build or systemd, and runs the detector.
mkdir -p "$test_tmp/init"
cp "$BASH" "$test_tmp/init/bash"
cp "$BASH" "$test_tmp/init/systemd"
if (( EUID != 0 )) && "$test_tmp/init/bash" -c true 2>/dev/null &&
  unshare --user --map-root-user --mount --pid --fork --mount-proc true 2>/dev/null; then
  # $1 fixture, $2 PID 1 (bash or systemd), $3 a file to lay over the manifest.
  live_root() {
    local fixture=$1 init=$2 owner_file=${3:-}
    unshare --user --map-root-user --mount --pid --fork --mount-proc "$test_tmp/init/$init" -c '
      mount --bind "$1/var/lib" /var/lib && mount --bind "$1/run" /run || exit 99
      if [[ -n $3 ]]; then mount --bind "$3" /var/lib/omarchy/image/target || exit 99; fi
      "$2"
      status=$?
      exit "$status"
    ' "$init" "$fixture" "$detector" "$owner_file" 2>"$test_tmp/error"
  }
  baseline=$(unshare --user --map-root-user --mount --pid --fork --mount-proc "$detector") ||
    fail "root detects the live platform in a PID namespace"

  # A target the hardware would not give, so only the manifest can name it.
  target=apple-silicon
  [[ $baseline != "apple-silicon" ]] || target=qualcomm
  fixture="$test_tmp/live-root"
  mkdir -p "$fixture/var/lib/omarchy/image" "$fixture/run"
  printf 'format=1\nplatform=%s\n' "$target" >"$fixture/var/lib/omarchy/image/target"

  expect_live_manifest() {
    local description=$1 actual
    if [[ $(uname -m) == aarch64 ]]; then
      actual=$(live_root "$fixture" bash) || fail "$description" "$(cat "$test_tmp/error")"
      [[ $actual == "$target" ]] || fail "$description" "expected: $target
actual:   $actual"
    else
      if live_root "$fixture" bash >/dev/null; then
        fail "$description, and a $target target on $(uname -m) contradicts it"
      fi
      grep -Fq "/var/lib/omarchy/image/target names $target hardware but the CPU is" "$test_tmp/error" ||
        fail "$description" "$(cat "$test_tmp/error")"
    fi
    pass "$description"
  }
  expect_live_manifest "root answers with the live manifest in a build with a /run of its own"

  mkdir -p "$fixture/run/systemd/system"
  expect_live_manifest "root answers with the live manifest in a build whose PID 1 is not systemd, with systemd in /run"

  actual=$(live_root "$fixture" systemd) || fail "a booted root ignores the live manifest" "$(cat "$test_tmp/error")"
  [[ $actual == "$baseline" ]] || fail "a booted root ignores the live manifest" "expected: $baseline
actual:   $actual"
  pass "a booted root answers with its hardware despite a manifest"
  rmdir "$fixture/run/systemd/system"

  # A file the namespace's root does not own: the real root's, unmapped here.
  if live_root "$fixture" bash /etc/os-release >/dev/null; then
    fail "root refuses a manifest another user owns"
  fi
  grep -Fq "is not a root-owned regular file" "$test_tmp/error" || fail "root refuses a manifest another user owns" "$(cat "$test_tmp/error")"
  pass "root refuses a manifest another user owns"
else
  skip "no unprivileged user, mount and PID namespaces, or an executable temporary directory; skipping the live manifest probe"
fi

require_platform_fixtures "the image-target fixtures"

# --- Image builds -------------------------------------------------------------

# An Apple image built on an x86 host: the chroot runs under aarch64 emulation,
# the host has no device tree, and PID 1 is the host's.
world x86-host aarch64
pid1 x86-host chroot
manifest x86-host "$apple_manifest"
expect x86-host apple-silicon "an Apple image built in a chroot on an x86 host is Apple Silicon"

# The same with the host's /run bound into the chroot, systemd's directory and all.
systemd_runs x86-host
expect x86-host apple-silicon "a chroot build ignores the host's systemd in a bound /run"

# On a generic aarch64 host, whose own device tree the chroot can see.
world arm-host aarch64 linux,dummy-virt
pid1 arm-host chroot
manifest arm-host "$apple_manifest"
expect arm-host apple-silicon "an Apple image built in a chroot on a generic aarch64 host is Apple Silicon"

# The image builder's isolated chroot: a PID namespace whose PID 1 is the build.
world builder aarch64 raspberrypi,5-model-b brcm,bcm2712
pid1 builder own bash
manifest builder "$apple_manifest"
expect builder apple-silicon "an Apple image built in its own PID namespace is Apple Silicon"

# The same with the host's /run bound in: PID 1 is still not systemd.
systemd_runs builder
expect builder apple-silicon "a PID namespace build ignores the host's systemd in a bound /run"

# A root without /proc, with a /run of its own.
world no-proc aarch64
manifest no-proc "$apple_manifest"
expect no-proc apple-silicon "an Apple image built without /proc is Apple Silicon"

# The host never decides the target, even when it is a Mac or its tree is
# contradictory.
world on-a-mac aarch64 apple,j416c apple,t6021 apple,arm-platform
pid1 on-a-mac chroot
manifest on-a-mac $'format=1\nplatform=generic-aarch64\n'
expect on-a-mac generic-aarch64 "a generic aarch64 image built on a Mac is generic aarch64"
world odd-host aarch64 apple,j416c qcom,x1e80100
pid1 odd-host chroot
manifest odd-host $'format=1\nplatform=qualcomm\n'
expect odd-host qualcomm "a build never reads the host's device tree"

# Comments and keys a later format adds are ignored.
world commented aarch64
pid1 commented chroot
manifest commented $'# written by the image builder\nformat=1\nbuilder=ci\nplatform=apple-silicon\n'
expect commented apple-silicon "comments and unknown manifest keys are ignored"

# --- Booted systems -----------------------------------------------------------

# A booted Mac whose manifest outlived its first boot: the hardware decides, and
# not even a broken manifest stops it.
world booted-mac aarch64 apple,j416c apple,t6021 apple,arm-platform
pid1 booted-mac own
systemd_runs booted-mac
manifest booted-mac $'format=1\nplatform=generic-aarch64\n'
expect booted-mac apple-silicon "a booted Mac with a stale manifest is Apple Silicon"
manifest booted-mac "not a manifest"
expect booted-mac apple-silicon "a booted Mac ignores a malformed stale manifest"

world booted-qualcomm aarch64 lenovo,yoga-slim7x qcom,x1e80100
pid1 booted-qualcomm own
systemd_runs booted-qualcomm
manifest booted-qualcomm "$apple_manifest"
expect booted-qualcomm qualcomm "a booted Snapdragon laptop with an Apple manifest is Qualcomm"

world booted-x86 x86_64
pid1 booted-x86 own
systemd_runs booted-x86
manifest booted-x86 "$apple_manifest"
expect booted-x86 generic "a booted x86 machine with an Apple manifest is generic"

# An Apple image under VM acceptance, booted before its first-boot setup ran.
world booted-vm aarch64 linux,dummy-virt
pid1 booted-vm own
systemd_runs booted-vm
manifest booted-vm "$apple_manifest"
expect booted-vm generic-aarch64 "a booted VM with an Apple manifest is generic aarch64"

# What a normal user cannot see never makes a build: PID 1's root, or PID 1
# itself behind hidepid.
world user-view aarch64 apple,j416c apple,t6021 apple,arm-platform
pid1 user-view hidden
systemd_runs user-view
manifest user-view $'format=1\nplatform=generic-aarch64\n'
expect user-view apple-silicon "a booted system whose PID 1 root cannot be compared uses its hardware"
world hidepid aarch64 apple,j416c apple,t6021 apple,arm-platform
systemd_runs hidepid
manifest hidepid "not a manifest"
expect hidepid apple-silicon "a booted system whose PID 1 is hidden uses its hardware"

# --- No manifest --------------------------------------------------------------

# An installer on the target machine chroots into the new root with no
# manifest: the hardware it runs on is the target.
world installer aarch64 apple,j314s apple,t6000 apple,arm-platform
pid1 installer chroot
expect installer apple-silicon "a chroot without a manifest uses the hardware"

# A manifest retired by the first boot no longer names anything.
world retired aarch64 linux,dummy-virt
pid1 retired chroot
manifest retired "$apple_manifest"
mv "$test_tmp/worlds/retired/image/var/lib/omarchy/image/target" "$test_tmp/worlds/retired/image/var/lib/omarchy/image/target.booted"
expect retired generic-aarch64 "a retired manifest is not read"

# --- Invalid manifests stop a build -------------------------------------------

invalid() {
  local name=$1 body=$2 message=$3 description=$4
  world "$name" aarch64 linux,dummy-virt
  pid1 "$name" chroot
  manifest "$name" "$body"
  expect_refused "$name" "$message" "$description"
}

invalid no-format $'platform=apple-silicon\n' "is not format=1" "a manifest without a format is refused"
invalid format-2 $'format=2\nplatform=apple-silicon\n' "is not format=1" "a manifest of another format is refused"
invalid empty "" "is not format=1" "an empty manifest is refused"
invalid unknown $'format=1\nplatform=intel-mac\n' "names no known platform: intel-mac" "a manifest naming an unknown platform is refused"
invalid no-platform $'format=1\n' "names no known platform: none" "a manifest naming no platform is refused"
invalid bare-line $'format=1\napple-silicon\n' "is malformed: apple-silicon" "a manifest line without a key is refused"

world x86-cpu x86_64
pid1 x86-cpu chroot
manifest x86-cpu "$apple_manifest"
expect_refused x86-cpu "names apple-silicon hardware but the CPU is x86_64" "an Apple manifest on an x86 CPU contradicts it"
world arm-generic aarch64
pid1 arm-generic chroot
manifest arm-generic $'format=1\nplatform=generic\n'
expect_refused arm-generic "names generic hardware but the CPU is aarch64" "an x86 manifest on an aarch64 CPU contradicts it"

untrusted="is not a root-owned regular file"
world symlink aarch64
pid1 symlink chroot
manifest symlink "$apple_manifest"
image_dir="$test_tmp/worlds/symlink/image/var/lib/omarchy/image"
mv "$image_dir/target" "$image_dir/real-target"
ln -s real-target "$image_dir/target"
expect_refused symlink "$untrusted" "a symlinked manifest is refused"

world dangling aarch64
pid1 dangling chroot
mkdir -p "$test_tmp/worlds/dangling/image/var/lib/omarchy/image"
ln -s missing "$test_tmp/worlds/dangling/image/var/lib/omarchy/image/target"
expect_refused dangling "$untrusted" "a dangling manifest symlink is refused"

world directory aarch64
pid1 directory chroot
mkdir -p "$test_tmp/worlds/directory/image/var/lib/omarchy/image/target"
expect_refused directory "$untrusted" "a manifest that is a directory is refused"

world writable aarch64
pid1 writable chroot
manifest writable "$apple_manifest"
chmod 0664 "$test_tmp/worlds/writable/image/var/lib/omarchy/image/target"
expect_refused writable "$untrusted" "a group-writable manifest is refused"

world writable-dir aarch64
pid1 writable-dir chroot
manifest writable-dir "$apple_manifest"
chmod 0777 "$test_tmp/worlds/writable-dir/image/var/lib/omarchy/image"
expect_refused writable-dir "$untrusted" "a manifest in a world-writable directory is refused"

# Another owner: a fixture is trusted when the test's own user owns it, so a
# stat reporting root stands in for a file this user did not write.
world other-owner aarch64
pid1 other-owner chroot
manifest other-owner "$apple_manifest"
real_stat=$(command -v stat)
cat >"$test_tmp/worlds/other-owner/bin/stat" <<SH
#!/bin/bash
[[ \${!#} == */var/lib/omarchy/image/target ]] && { echo "0 644"; exit 0; }
exec $real_stat "\$@"
SH
chmod +x "$test_tmp/worlds/other-owner/bin/stat"
expect_refused other-owner "$untrusted" "a manifest another user owns is refused"

# --- What a build sets up from it ---------------------------------------------

# The Apple predicate of an Apple image built on an x86 host, and of a generic
# image built on a Mac.
in_world x86-host "$ROOT/bin/omarchy-hw-apple-silicon" || fail "the Apple predicate accepts an Apple image build"
if in_world on-a-mac "$ROOT/bin/omarchy-hw-apple-silicon"; then
  fail "the Apple predicate rejects a generic image built on a Mac"
fi
pass "the Apple predicate follows the image target"

packages=$(in_world x86-host env OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults") || fail "an Apple image build composes its packages"
[[ $packages == "$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults" apple-silicon)" ]] ||
  fail "an Apple image build installs the Apple Silicon package set"
packages=$(in_world on-a-mac env OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults") || fail "a generic image build composes its packages"
[[ $packages == "$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults" generic-aarch64)" ]] ||
  fail "a generic image built on a Mac installs the generic aarch64 package set"
packages=$(in_world odd-host env OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults") || fail "a Qualcomm image build composes its packages"
[[ $packages == "$(OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-pkg-defaults" qualcomm)" ]] ||
  fail "a Qualcomm image built on another host installs the Qualcomm package set"
pass "the default package set follows the image target"

# A caller in a private PID namespace looks like a build, so no unit may use one.
units=$(grep -rlE '^[[:space:]]*PrivatePIDs=' "$ROOT" --include='*.service' --include='*.conf' --exclude-dir=.git || true)
[[ -z $units ]] || fail "no unit runs in a private PID namespace" "$units"
pass "no unit runs in a private PID namespace"
