#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
# Source only the user-side launcher helper: no Docker or elevation runs.
source <(sed -n '/^create_launcher_entry() (/ , /^)/p' "$ROOT/bin/omarchy-windows-vm")
create_launcher_entry
entry="$HOME/.local/share/applications/windows-vm.desktop"
grep -Fx 'Exec=uwsm app -- omarchy-windows-vm launch' "$entry" >/dev/null || fail "launcher must be complete"
cp "$entry" "$test_tmp/original"
# A failed publication must retain an existing complete launcher.
mv() { return 1; }
if create_launcher_entry; then fail "launcher publication failure must propagate"; fi
cmp "$entry" "$test_tmp/original" || fail "publication failure must preserve the old marker"
[[ -z $(find "$HOME" -name '.windows-vm.*' -print) ]] || fail "failed publication must remove staging files"
unset -f mv
# A fresh failure must not leave a partial installed-state marker.
export HOME="$test_tmp/new-home"
cat() { return 1; }
if create_launcher_entry; then fail "launcher write failure must propagate"; fi
[[ ! -e $HOME/.local/share/applications/windows-vm.desktop ]] || fail "failed writes must not leave an installed marker"
unset -f cat
pass "Windows VM launcher publishes atomically and propagates write/publication errors"
