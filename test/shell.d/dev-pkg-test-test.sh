#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/home/Work/omarchy/omarchy-installer" "$scratch/recipes"
for package in omarchy-settings-dev omarchy-dev; do
  mkdir -p "$scratch/recipes/$package"
  printf 'pkgname=%s\npkgver=1\n' "$package" >"$scratch/recipes/$package/PKGBUILD"
done
cat >"$scratch/bin/makepkg" <<'STUB'
#!/bin/bash
set -euo pipefail
source PKGBUILD
printf 'build %s\n' "$pkgname" >>"$TEST_LOG"
[[ ${FAIL_BUILD:-} != "$pkgname" ]] || exit 1
: >"$pkgname-$pkgver-1-any.pkg.tar.zst"
STUB
cat >"$scratch/bin/sudo" <<'STUB'
#!/bin/bash
set -euo pipefail
[[ $1 == "pacman" && $2 == "-U" && $3 == "--noconfirm" && $4 == "--overwrite=*" ]]
shift 4
printf 'install' >>"$TEST_LOG"
for archive in "$@"; do
  [[ -f $archive ]]
  printf ' %s' "$(basename "$archive")" >>"$TEST_LOG"
done
printf '\n' >>"$TEST_LOG"
STUB
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH" HOME="$scratch/home" OMARCHY_PKGBUILDS_DIR="$scratch/recipes" TEST_LOG="$scratch/log"

"$ROOT/bin/omarchy-dev-pkg-test" >"$scratch/output" 2>&1 || fail 'default package pair builds and installs' "$(cat "$scratch/output")"
[[ $(wc -l <"$TEST_LOG") == 3 ]] || fail 'one install follows both builds' "$(cat "$TEST_LOG")"
sed -n '1p' "$TEST_LOG" | rg -q '^build omarchy-settings-dev$' || fail 'settings builds first'
sed -n '2p' "$TEST_LOG" | rg -q '^build omarchy-dev$' || fail 'runtime builds before installation'
sed -n '3p' "$TEST_LOG" | rg -q '^install omarchy-settings-dev-.* omarchy-dev-' || fail 'the pair installs in one pacman transaction'
pass 'pkg-test installs both packages together after building both'

: >"$TEST_LOG"
if FAIL_BUILD=omarchy-dev "$ROOT/bin/omarchy-dev-pkg-test" >"$scratch/output" 2>&1; then
  fail 'a failed second build stops pkg-test'
fi
! rg -q '^install' "$TEST_LOG" || fail 'a failed second build must not install settings alone'
pass 'a failed second build leaves the installed pair untouched'

: >"$TEST_LOG"
"$ROOT/bin/omarchy-dev-pkg-test" omarchy "$scratch/home/Work/omarchy/omarchy-installer" >"$scratch/output" 2>&1 || fail 'explicit single package builds' "$(cat "$scratch/output")"
[[ $(wc -l <"$TEST_LOG") == 2 ]] || fail 'explicit package has one build and one install'
sed -n '2p' "$TEST_LOG" | rg -q '^install omarchy-dev-[^ ]+$' || fail 'explicit package installs only its archive'
pass 'pkg-test retains single-package aliases and installation'
