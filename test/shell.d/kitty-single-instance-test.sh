#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

desktop="$ROOT/default/kitty/kitty.desktop"
exec_count=$(grep -c '^Exec=kitty --single-instance$' "$desktop")
[[ $exec_count == 2 ]] || fail "shipped Kitty desktop launches with --single-instance" "count: $exec_count"
pass "shipped Kitty desktop uses --single-instance"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
mock_bin="$test_tmp/bin"
mkdir -p "$home/.config" "$mock_bin"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$mock_bin/omarchy-pkg-add"

HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-install-terminal" kitty >/dev/null

installed="$home/.local/share/applications/kitty.desktop"
[[ -f $installed ]] || fail "install-terminal copies the Kitty desktop entry"
grep -qxF 'Exec=kitty --single-instance' "$installed" ||
  fail "install-terminal copies the single-instance Kitty desktop"
pass "install-terminal installs the single-instance Kitty desktop"

migration="$ROOT/migrations/1788799150.sh"
rm -rf "$home/.local/share/applications"
mkdir -p "$home/.local/share/applications"

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
[[ $1 == kitty ]]
SH
chmod +x "$mock_bin/omarchy-cmd-present"

HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash -euo pipefail "$migration" >/dev/null

[[ -f $home/.local/share/applications/kitty.desktop ]] ||
  fail "migration copies the Kitty desktop when kitty is present"
grep -qxF 'Exec=kitty --single-instance' "$home/.local/share/applications/kitty.desktop" ||
  fail "migration installs --single-instance"
pass "migration copies the single-instance desktop when kitty is present"

rm -f "$home/.local/share/applications/kitty.desktop"
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin/omarchy-cmd-present"

HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash -euo pipefail "$migration" >/dev/null

[[ ! -e $home/.local/share/applications/kitty.desktop ]] ||
  fail "migration skips the desktop copy when kitty is absent"
pass "migration is a no-op when kitty is not installed"
