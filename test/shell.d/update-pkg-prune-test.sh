#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

run_pkg_prune() {
  PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-pkg-prune"
}

# Pin the keep count above one.
write_stub sudo 'printf "%s\n" "$*" >"$PACCACHE_LOG"; exit 0'

PACCACHE_LOG="$test_tmp/args" run_pkg_prune >"$test_tmp/prune.out" 2>&1
grep -q 'paccache' "$test_tmp/args" || fail "cache prune runs paccache"
grep -qE 'paccache .*-rk2' "$test_tmp/args" ||
  fail "cache prune keeps more than one version" "$(cat "$test_tmp/args")"
pass "cache prune leaves a rollback version to spare"

# Housekeeping failure must not abort the update.
write_stub sudo 'exit 1'
run_pkg_prune >"$test_tmp/fail.out" 2>&1 ||
  fail "cache prune survives paccache failure"
grep -q 'Could not prune the package cache' "$test_tmp/fail.out" ||
  fail "cache prune warns when it fails" "$(cat "$test_tmp/fail.out")"
pass "cache prune warns but does not abort the update"

# yay keeps every package it builds, one clone per package. The real paccache
# must trim each clone to two versions, find the directory through yay's own
# config, and leave yay's files and anything a symlink points at alone.
build_dir="$test_tmp/aur-builds"
outside="$test_tmp/outside"
mkdir -p "$build_dir/foo-bin" "$build_dir/bar" "$outside"
for version in 1.0 1.1 2.0; do
  : >"$build_dir/foo-bin/foo-bin-$version-1-x86_64.pkg.tar.zst"
  : >"$outside/baz-$version-1-any.pkg.tar.zst"
done
: >"$build_dir/foo-bin/PKGBUILD"
: >"$build_dir/bar/PKGBUILD"
: >"$build_dir/bar/bar-1.0-1-any.pkg.tar.zst"
: >"$build_dir/vcs.json"
: >"$outside/PKGBUILD"
ln -s "$outside" "$build_dir/baz"
write_stub yay "printf '{\"buildDir\": \"%s\"}\n' '$build_dir'"

PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-aur-prune" >"$test_tmp/aur.out" 2>&1 ||
  fail "AUR prune does not fail the update" "$(cat "$test_tmp/aur.out")"
[[ ! -e $build_dir/foo-bin/foo-bin-1.0-1-x86_64.pkg.tar.zst ]] ||
  fail "AUR prune drops builds beyond two versions" "$(cat "$test_tmp/aur.out")"
[[ -e $build_dir/foo-bin/foo-bin-1.1-1-x86_64.pkg.tar.zst && -e $build_dir/foo-bin/foo-bin-2.0-1-x86_64.pkg.tar.zst ]] ||
  fail "AUR prune keeps the two newest builds"
[[ -e $build_dir/bar/bar-1.0-1-any.pkg.tar.zst && -e $build_dir/vcs.json ]] ||
  fail "AUR prune leaves single builds and yay's own files"
[[ -e $outside/baz-1.0-1-any.pkg.tar.zst ]] ||
  fail "AUR prune does not follow a symlink out of the build directory"
pass "AUR build directory keeps two versions per package"
