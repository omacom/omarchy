#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_platform_fixtures "platform package lists"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export OMARCHY_PATH="$ROOT"
export PATH="$ROOT/bin:$PATH"

names() {
  sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$@"
}

base=$(names "$ROOT/install/omarchy-base.packages")
aarch64=$(names "$ROOT/install/omarchy-aarch64.packages")

for platform in aarch64-apple aarch64 x86; do
  fake_platform "$work/$platform" "$platform"
  defaults=$(OMARCHY_PROC_ROOT="$work/$platform/proc" PATH="$work/$platform/bin:$ROOT/bin:$PATH" omarchy-pkg-defaults)
  [[ $defaults == "$(omarchy-pkg-defaults "$platform")" ]] ||
    fail "$platform: the detected platform selects its own list"
  printf '%s\n' "$defaults" >"$work/$platform.packages"

  [[ -z $(sort "$work/$platform.packages" | uniq -d) ]] || fail "$platform: each package is listed once"
  # aarch64 platforms leave out the base packages only x86_64 builds.
  expected_base=$base
  [[ $platform == "x86" ]] || expected_base=$(grep -vxF -f <(names "$ROOT/install/omarchy-x86_64-only.packages") <<<"$base")
  [[ $(head -n "$(wc -l <<<"$expected_base")" "$work/$platform.packages") == "$expected_base" ]] ||
    fail "$platform: the base list comes first, unchanged"

  case $platform in
    x86)
      [[ $defaults == "$base" ]] || fail "x86_64 installs exactly the base list"
      [[ $defaults == "$(grep -v '^#' "$ROOT/install/omarchy-base.packages" | grep -v '^$')" ]] ||
        fail "x86_64 installs what omarchy-reinstall-pkgs read from the base list before"
      ;;
    *)
      while IFS= read -r package; do
        grep -Fxq "$package" "$work/$platform.packages" || fail "$platform: aarch64 addition $package"
      done <<<"$aarch64"
      ;;
  esac

  # The Mac's packages, and wf-recorder, which records its screen: nothing else
  # captures on Apple Silicon.
  for package in omarchy-mac omarchy-mac-boot wf-recorder; do
    if [[ $platform == "aarch64-apple" ]]; then
      grep -Fxq "$package" "$work/$platform.packages" || fail "Apple Silicon adds $package"
    else
      ! grep -Fxq "$package" "$work/$platform.packages" || fail "$platform: no $package"
    fi
  done
done
pass "each platform composes the base, architecture and platform lists"

# A hardware family's own list joins only that family's set, after the base and
# architecture lists; plain aarch64 composes the others alone.
tree="$work/tree"
mkdir -p "$tree/install"
cp "$ROOT"/install/omarchy-*.packages "$tree/install/"
printf '# test addition\nexample-board-support\nzram-generator\n' >"$tree/install/omarchy-aarch64-apple.packages"
for platform in aarch64-apple aarch64 x86; do
  defaults=$(OMARCHY_PATH="$tree" omarchy-pkg-defaults "$platform")
  if [[ $platform == "aarch64-apple" ]]; then
    [[ $(tail -n 1 <<<"$defaults") == "example-board-support" ]] || fail "a platform list is added after the others" "$defaults"
    (( $(grep -cx zram-generator <<<"$defaults") == 1 )) || fail "a name in two lists is installed once" "$defaults"
  else
    ! grep -Fxq example-board-support <<<"$defaults" || fail "$platform: another platform's list stays out"
  fi
done
pass "a platform list joins only its own platform's set"

# Image builders written before the platform names settled pass the old names.
for legacy in apple-silicon:aarch64-apple generic-aarch64:aarch64 generic:x86; do
  [[ $(omarchy-pkg-defaults "${legacy%%:*}") == "$(omarchy-pkg-defaults "${legacy#*:}")" ]] ||
    fail "the old name ${legacy%%:*} composes the ${legacy#*:} set"
done
pass "the old platform names compose the same sets"

# Base packages that only x86_64 builds stay out of every aarch64 set.
for platform in aarch64-apple aarch64 x86; do
  defaults=$(OMARCHY_PATH="$ROOT" omarchy-pkg-defaults "$platform")
  while read -r name; do
    [[ -n $name && $name != \#* ]] || continue
    if [[ $platform == "x86" ]]; then
      grep -Fxq "$name" <<<"$defaults" || fail "x86_64 keeps $name"
    else
      ! grep -Fxq "$name" <<<"$defaults" || fail "$platform leaves out the x86_64-only $name"
    fi
  done <"$ROOT/install/omarchy-x86_64-only.packages"
done
grep -Fxq superwhisper-bin "$ROOT/install/omarchy-x86_64-only.packages" || fail "superwhisper-bin is listed as x86_64-only"
pass "base packages only x86_64 builds stay out of every aarch64 set"

! omarchy-pkg-defaults riscv 2>/dev/null || fail "an unknown platform is refused"
failing_bin="$work/failing-bin"
mkdir -p "$failing_bin"
printf '#!/bin/bash\nexit 1\n' >"$failing_bin/omarchy-hw-platform"
chmod +x "$failing_bin/omarchy-hw-platform"
! PATH="$failing_bin:$ROOT/bin:$PATH" omarchy-pkg-defaults >/dev/null 2>&1 || fail "a platform the detector cannot tell is refused"
pass "an unknown or undetectable platform is refused"

# omarchy-reinstall-pkgs installs the detected platform's set.
mkdir -p "$work/stubs"
cat >"$work/stubs/omarchy-update-pacman" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$STUB_LOG"
SH
cat >"$work/stubs/omarchy-refresh-pacman" <<'SH'
#!/bin/bash
printf 'refresh %s\n' "$*" >>"$STUB_LOG"
[[ -z ${REFRESH_FAILS:-} ]]
SH
chmod +x "$work/stubs/"*

for platform in aarch64 x86; do
  export STUB_LOG="$work/$platform.log"
  : >"$STUB_LOG"
  OMARCHY_PROC_ROOT="$work/$platform/proc" PATH="$work/stubs:$work/$platform/bin:$ROOT/bin:$PATH" \
    omarchy-reinstall-pkgs
  expected="-Syu --noconfirm --needed $(tr '\n' ' ' <"$work/$platform.packages")"
  [[ $(tail -n 1 "$STUB_LOG") == "${expected% }" ]] ||
    fail "$platform: reinstall installs the platform's default set" "$(tail -n 1 "$STUB_LOG")"
done
pass "omarchy-reinstall-pkgs installs the platform's default set"

# Every platform resets to its stable templates, as x86_64 always has; a failed
# refresh stops the reinstall.
reinstall_on() {
  local platform=$1
  export STUB_LOG="$work/channel.log"
  : >"$STUB_LOG"
  OMARCHY_PROC_ROOT="$work/$platform/proc" PATH="$work/stubs:$work/$platform/bin:$ROOT/bin:$PATH" \
    omarchy-reinstall-pkgs >"$work/channel.out" 2>&1
}
for platform in x86 aarch64 aarch64-apple; do
  reinstall_on "$platform" || fail "$platform: reinstall completes" "$(cat "$work/channel.out")"
  [[ $(head -n 1 "$STUB_LOG") == "refresh " ]] || fail "$platform: reinstall refreshes on stable" "$(cat "$STUB_LOG")"
  expected="-Syu --noconfirm --needed $(tr '\n' ' ' <"$work/$platform.packages")"
  [[ $(tail -n 1 "$STUB_LOG") == "${expected% }" ]] || fail "$platform: reinstall installs the platform's set"
done
pass "omarchy-reinstall-pkgs refreshes on stable on every platform"

if REFRESH_FAILS=1 reinstall_on aarch64; then
  fail "reinstall stops when the refresh fails"
fi
[[ $(cat "$STUB_LOG") == "refresh " ]] || fail "reinstall runs nothing after a failed refresh" "$(cat "$STUB_LOG")"
pass "omarchy-reinstall-pkgs stops when the refresh fails"

export STUB_LOG="$work/undetected.log"
: >"$STUB_LOG"
if PATH="$failing_bin:$work/stubs:$ROOT/bin:$PATH" omarchy-reinstall-pkgs >/dev/null 2>&1; then
  fail "reinstall stops when the platform cannot be told"
fi
! grep -q -- '--needed' "$STUB_LOG" || fail "reinstall installs nothing when the platform cannot be told" "$(cat "$STUB_LOG")"
pass "omarchy-reinstall-pkgs stops when the platform cannot be told"
