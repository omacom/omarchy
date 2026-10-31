#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

PKG_TEST_DIR=$(mktemp -d)
trap 'rm -rf "$PKG_TEST_DIR"' EXIT

PKG_STUB_DIR="$PKG_TEST_DIR/bin"
mkdir -p "$PKG_STUB_DIR"

# A cancelled password prompt makes `sudo -v` fail; every other call is logged.
cat >"$PKG_STUB_DIR/sudo" <<'SH'
#!/bin/bash
if [[ $1 == "-v" ]]; then
  printf 'sudo -v\n' >>"$PKG_TEST_DIR/calls.log"
  exit 1
fi
printf 'sudo %s\n' "$*" >>"$PKG_TEST_DIR/calls.log"
SH

for cmd in pacman yay; do
  cat >"$PKG_STUB_DIR/$cmd" <<'SH'
#!/bin/bash
if [[ $1 == -Slq* ]]; then
  printf 'example\n'
else
  printf '%s %s\n' "${0##*/}" "$*" >>"$PKG_TEST_DIR/calls.log"
fi
SH
done

printf '#!/bin/bash\nhead -n1\n' >"$PKG_STUB_DIR/fzf"
printf '#!/bin/bash\nprintf "done\\n" >>"$PKG_TEST_DIR/calls.log"\n' >"$PKG_STUB_DIR/omarchy-show-done"
chmod +x "$PKG_STUB_DIR"/*

for installer in omarchy-pkg-install omarchy-pkg-aur-install; do
  rm -f "$PKG_TEST_DIR/calls.log"
  if PKG_TEST_DIR="$PKG_TEST_DIR" PATH="$PKG_STUB_DIR:$ROOT/bin:$PATH" "$ROOT/bin/$installer"; then
    fail "$installer should exit non-zero when the sudo prompt is cancelled"
  fi
  calls=$(<"$PKG_TEST_DIR/calls.log")
  [[ $calls == "sudo -v" ]] || fail "$installer should stop after the cancelled sudo prompt" "$calls"
  pass "$installer stops when the sudo prompt is cancelled"
done
