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

cat >"$installed" <<'EOF'
[Desktop Entry]
Name=kitty
Icon=my-kitty
Exec=kitty --class=mine
Actions=New;

[Desktop Action New]
Name=New Terminal
Exec=kitty
EOF

HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
  "$ROOT/bin/omarchy-install-terminal" kitty >/dev/null

grep -qxF 'Icon=my-kitty' "$installed" || fail "install-terminal keeps a custom Kitty icon"
grep -qxF 'Exec=kitty --single-instance --class=mine' "$installed" ||
  fail "install-terminal adds --single-instance to a custom Kitty Exec"
grep -qxF 'Exec=kitty --single-instance' "$installed" ||
  fail "install-terminal adds --single-instance to a custom Kitty action"
! grep -q '^GenericName=' "$installed" || fail "install-terminal replaces a custom Kitty desktop file"
pass "install-terminal updates Exec on an existing Kitty desktop file"

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

custom="$home/.local/share/applications/kitty.desktop"
cat >"$custom" <<'EOF'
[Desktop Entry]
Name=kitty
Icon=my-kitty
Exec=kitty --single-instance --hold
Exec=/usr/bin/kitty

[Desktop Action New]
Name=New Terminal
Exec=kitty --title=mine
EOF

HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash -euo pipefail "$migration" >/dev/null

grep -qxF 'Icon=my-kitty' "$custom" || fail "migration keeps a custom Kitty icon"
grep -qxF 'Exec=kitty --single-instance --hold' "$custom" ||
  fail "migration keeps an Exec line that already passes --single-instance"
grep -qxF 'Exec=/usr/bin/kitty' "$custom" ||
  fail "migration leaves an Exec line whose command is not kitty"
grep -qxF 'Exec=kitty --single-instance --title=mine' "$custom" ||
  fail "migration adds --single-instance to a custom Kitty action"
! grep -q '^GenericName=' "$custom" || fail "migration replaces a custom Kitty desktop file"
pass "migration adds --single-instance without replacing a custom desktop file"

cp "$custom" "$custom.before"
HOME="$home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
  bash -euo pipefail "$migration" >/dev/null
cmp -s "$custom.before" "$custom" || fail "migration rewrites an updated Kitty desktop file"
pass "migration leaves an updated Kitty desktop file unchanged"

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
