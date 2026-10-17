#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'chmod -R u+w "$TMPDIR" 2>/dev/null || true; rm -rf "$TMPDIR"' EXIT

STUB_DIR="$TMPDIR/stub"
mkdir -p "$STUB_DIR" "$TMPDIR/cache/yay/hyprmoncfg/src/go-mod/github.com/pkg" "$TMPDIR/home"

# Simulate Go's read-only module cache left from a previous yay build.
touch "$TMPDIR/cache/yay/hyprmoncfg/src/go-mod/github.com/pkg/LICENSE"
chmod a-w "$TMPDIR/cache/yay/hyprmoncfg/src/go-mod/github.com/pkg/LICENSE"
chmod a-w "$TMPDIR/cache/yay/hyprmoncfg/src/go-mod/github.com/pkg"
chmod a-w "$TMPDIR/cache/yay/hyprmoncfg/src/go-mod"

cat >"$STUB_DIR/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Qem" ]] || exit 90
exit 0
STUB

cat >"$STUB_DIR/omarchy-pkg-aur-accessible" <<'STUB'
#!/bin/bash
exit 0
STUB

cat >"$STUB_DIR/yay" <<'STUB'
#!/bin/bash
printf 'yay %s\n' "$*" >>"$FAKE_CALLS"
exit 1
STUB

chmod +x "$STUB_DIR"/*

FAKE_CALLS="$TMPDIR/calls"
export FAKE_CALLS
: >"$FAKE_CALLS"

aur_pkgs=$(cat "$ROOT/bin/omarchy-update-aur-pkgs")
[[ $aur_pkgs == *'writable_yay_go_mod_caches'* ]] || fail "AUR update must soften read-only yay go-mod caches"
[[ $aur_pkgs == *'src/go-mod'* ]] || fail "AUR update must look for go-mod trees under yay's cache"
[[ $aur_pkgs != *'yay '* ]] || true
if grep -Eq 'yay .*\|\| exit 1' <<<"$aur_pkgs"; then
  fail "AUR update must not abort the whole update on yay failure"
fi
[[ $aur_pkgs == *'AUR package update failed'* ]] || fail "AUR update must warn when yay fails"
pass "AUR update softens go-mod caches and warns instead of aborting"

HOME="$TMPDIR/home" \
  XDG_CACHE_HOME="$TMPDIR/cache" \
  PATH="$STUB_DIR:$PATH" \
  OMARCHY_PATH="$ROOT" \
  bash "$ROOT/bin/omarchy-update-aur-pkgs" >"$TMPDIR/out" 2>"$TMPDIR/err" || fail "AUR helper exited non-zero" "$(cat "$TMPDIR/err")"

grep -q 'yay ' "$FAKE_CALLS" || fail "AUR helper did not invoke yay" "$(cat "$FAKE_CALLS")"
pass "AUR helper still runs yay when foreign packages are installed"

[[ -w $TMPDIR/cache/yay/hyprmoncfg/src/go-mod ]] || fail "go-mod cache stayed read-only"
[[ -w $TMPDIR/cache/yay/hyprmoncfg/src/go-mod/github.com/pkg/LICENSE ]] || fail "go-mod file stayed read-only"
pass "read-only yay go-mod caches become writable before yay"

grep -q 'AUR package update failed' "$TMPDIR/err" || fail "yay failure was not reported as a warning" "$(cat "$TMPDIR/err")"
pass "yay failure is reported without failing the update"
