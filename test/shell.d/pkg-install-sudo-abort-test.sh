#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PKG_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$PKG_TEST_DIR"' EXIT

PKG_STUB_DIR="$PKG_TEST_DIR/bin"
mkdir -p "$PKG_STUB_DIR"

cat >"$PKG_STUB_DIR/fzf" <<'SH'
#!/bin/bash
sed -n '1p'
SH
chmod +x "$PKG_STUB_DIR/fzf"

cat >"$PKG_STUB_DIR/pacman" <<'SH'
#!/bin/bash

case "${1:-}" in
  -Slq)
    printf 'example\n'
    ;;
  -S)
    printf '%s\n' "$*" >>"$PKG_TEST_DIR/pacman-install.log"
    exit "${PACMAN_INSTALL_STATUS:-0}"
    ;;
  *)
    exit 0
    ;;
esac
SH
chmod +x "$PKG_STUB_DIR/pacman"

cat >"$PKG_STUB_DIR/yay" <<'SH'
#!/bin/bash

case "${1:-}" in
  -Slqa)
    printf 'example\n'
    ;;
  -S)
    printf '%s\n' "$*" >>"$PKG_TEST_DIR/yay-install.log"
    exit "${YAY_INSTALL_STATUS:-0}"
    ;;
  *)
    exit 0
    ;;
esac
SH
chmod +x "$PKG_STUB_DIR/yay"

cat >"$PKG_STUB_DIR/sudo" <<'SH'
#!/bin/bash

case "${1:-}" in
  -v)
    printf 'validate\n' >>"$PKG_TEST_DIR/sudo-validate.log"
    exit "${SUDO_VALIDATE_STATUS:-0}"
    ;;
  -n)
    exit 0
    ;;
  updatedb)
    printf 'updatedb\n' >>"$PKG_TEST_DIR/updatedb.log"
    exit "${UPDATEDB_STATUS:-0}"
    ;;
esac

exec "$@"
SH
chmod +x "$PKG_STUB_DIR/sudo"

cat >"$PKG_STUB_DIR/omarchy-show-done" <<'SH'
#!/bin/bash
printf 'done\n' >>"$PKG_TEST_DIR/show-done.log"
SH
chmod +x "$PKG_STUB_DIR/omarchy-show-done"

if PKG_TEST_DIR="$PKG_TEST_DIR" SUDO_VALIDATE_STATUS=1 PATH="$PKG_STUB_DIR:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-pkg-install"; then
  fail "pkg install should exit non-zero when sudo validation fails"
fi
[[ -f $PKG_TEST_DIR/sudo-validate.log ]] || fail "pkg install should reach sudo validation"
[[ ! -f $PKG_TEST_DIR/pacman-install.log ]] || fail "pkg install should not run pacman after sudo validation failure"
[[ ! -f $PKG_TEST_DIR/show-done.log ]] || fail "pkg install should not show done after sudo validation failure"
pass "pkg install aborts cleanly when sudo validation fails"

rm -f "$PKG_TEST_DIR"/*.log
if PKG_TEST_DIR="$PKG_TEST_DIR" SUDO_VALIDATE_STATUS=1 PATH="$PKG_STUB_DIR:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-pkg-aur-install"; then
  fail "aur install should exit non-zero when sudo validation fails"
fi
[[ -f $PKG_TEST_DIR/sudo-validate.log ]] || fail "aur install should reach sudo validation"
[[ ! -f $PKG_TEST_DIR/yay-install.log ]] || fail "aur install should not run yay after sudo validation failure"
[[ ! -f $PKG_TEST_DIR/updatedb.log ]] || fail "aur install should not run updatedb after sudo validation failure"
[[ ! -f $PKG_TEST_DIR/show-done.log ]] || fail "aur install should not show done after sudo validation failure"
pass "aur install aborts cleanly when sudo validation fails"
