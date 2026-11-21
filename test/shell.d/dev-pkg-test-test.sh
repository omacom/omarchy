#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/dev-pkg-test.log"
linked_checkout="$test_tmp/dev-link/omarchy"
fallback_checkout="$test_tmp/home/Work/omarchy/omarchy-installer"
explicit_checkout="$test_tmp/explicit/omarchy"
override_pkgbuilds="$test_tmp/override-pkgbuilds"
mkdir -p "$stub_bin" "$linked_checkout" "$fallback_checkout" "$explicit_checkout"
unset OMARCHY_PKGBUILDS_DIR

make_pkgbuild() {
  local root="$1"
  local package="$2"

  mkdir -p "$root/$package"
  printf 'pkgname=%s\npkgver=1\npkgrel=1\n' "$package" >"$root/$package/PKGBUILD"
}

linked_pkgbuilds="$test_tmp/dev-link/omarchy-pkgs/pkgbuilds"
make_pkgbuild "$linked_pkgbuilds" omarchy-settings-dev
make_pkgbuild "$linked_pkgbuilds" omarchy-dev

fallback_pkgbuilds="$test_tmp/home/Work/omarchy/omarchy-pkgs/pkgbuilds"
make_pkgbuild "$fallback_pkgbuilds" omarchy-dev

explicit_pkgbuilds="$test_tmp/explicit/omarchy-pkgs/pkgbuilds"
make_pkgbuild "$explicit_pkgbuilds" omarchy-dev

make_pkgbuild "$override_pkgbuilds" custom-package

cat >"$stub_bin/git" <<'SH'
#!/bin/bash

if [[ $3 == "rev-parse" ]]; then
  echo abc1234
fi
SH
chmod +x "$stub_bin/git"

cat >"$stub_bin/makepkg" <<'SH'
#!/bin/bash

package=${PWD##*/}
printf 'makepkg\t%s\t%s\n' "$package" "$OMARCHY_SRC" >>"$OMARCHY_DEV_PKG_TEST_LOG"
: >"$package-test.pkg.tar.zst"
SH
chmod +x "$stub_bin/makepkg"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$OMARCHY_DEV_PKG_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_PKG_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_PKG_TEST_LOG"
SH
chmod +x "$stub_bin/sudo"

run_pkg_test() {
  HOME="$test_tmp/home" \
    OMARCHY_DEV_PKG_TEST_LOG="$log_file" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-dev-pkg-test" "$@"
}

assert_makepkg() {
  local package="$1"
  local checkout="$2"
  local description="$3"

  grep -Fx $'makepkg\t'"$package"$'\t'"$checkout" "$log_file" >/dev/null ||
    fail "$description" "$(cat "$log_file")"
  pass "$description"
}

: >"$log_file"
OMARCHY_PATH="$linked_checkout" run_pkg_test >/dev/null
assert_makepkg omarchy-settings-dev "$linked_checkout" "settings package uses the active Omarchy checkout"
assert_makepkg omarchy-dev "$linked_checkout" "runtime package uses the active Omarchy checkout"
(( $(grep -c '^makepkg' "$log_file") == 2 )) || fail "dev pkg-test builds both default packages once" "$(cat "$log_file")"
pass "dev pkg-test finds both PKGBUILDs beside the active checkout"

: >"$log_file"
OMARCHY_PATH=/usr/share/omarchy run_pkg_test omarchy-dev >/dev/null
assert_makepkg omarchy-dev "$fallback_checkout" "package mode keeps the legacy checkout and sibling PKGBUILD defaults"

: >"$log_file"
OMARCHY_PATH="$linked_checkout" run_pkg_test omarchy-dev "$explicit_checkout" >/dev/null
assert_makepkg omarchy-dev "$explicit_checkout" "an explicit checkout also selects its sibling PKGBUILD tree"

: >"$log_file"
OMARCHY_PATH="$linked_checkout" OMARCHY_PKGBUILDS_DIR="$override_pkgbuilds" run_pkg_test custom-package >/dev/null
assert_makepkg custom-package "$linked_checkout" "OMARCHY_PKGBUILDS_DIR overrides the derived PKGBUILD tree"

missing_checkout="$test_tmp/missing/omarchy"
mkdir -p "$missing_checkout"
: >"$log_file"
if OMARCHY_PATH="$missing_checkout" run_pkg_test omarchy-dev >"$test_tmp/missing.out" 2>"$test_tmp/missing.err"; then
  fail "dev pkg-test rejects a missing sibling PKGBUILD"
fi
missing_pkgbuild="$test_tmp/missing/omarchy-pkgs/pkgbuilds/omarchy-dev/PKGBUILD"
grep -Fx "Error: PKGBUILD not found at $missing_pkgbuild" "$test_tmp/missing.err" >/dev/null ||
  fail "dev pkg-test reports the derived PKGBUILD path" "$(cat "$test_tmp/missing.err")"
[[ ! -s $log_file ]] || fail "dev pkg-test does not build or install without a PKGBUILD" "$(cat "$log_file")"
pass "dev pkg-test rejects a missing sibling PKGBUILD before building"

help_output=$(run_pkg_test --help)
[[ $help_output == *'PKGBUILDs default to <parent-of-path-to-checkout>/omarchy-pkgs/pkgbuilds/.'* ]] ||
  fail "dev pkg-test help documents the sibling PKGBUILD default" "$help_output"
[[ $help_output == *'Set OMARCHY_PKGBUILDS_DIR to override that location.'* ]] ||
  fail "dev pkg-test help documents the PKGBUILD override" "$help_output"
pass "dev pkg-test help documents PKGBUILD resolution"
