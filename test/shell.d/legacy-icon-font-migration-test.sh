#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1788848726.sh"
fixture="$ROOT/test/shell.d/fixtures/legacy-icon-font/omarchy.ttf"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

export FONT_TEST_HOME="$test_dir/home with spaces"
export FONT_TEST_PACKAGE="$test_dir/packaged-font.ttf"
export FONT_TEST_CACHE_LOG="$test_dir/cache.log"
legacy_font="$FONT_TEST_HOME/.local/share/fonts/omarchy.ttf"

# Redirect only the filesystem roots; run the real hash check and removal.
# Never change the developer's HOME or refresh their real font cache.
python3 - "$migration" "$test_dir/migration.sh" <<'PY'
import pathlib
import sys

source = pathlib.Path(sys.argv[1]).read_text()
source = source.replace('$HOME', '$FONT_TEST_HOME')
source = source.replace('/usr/share/fonts/omarchy/omarchy.ttf', '$FONT_TEST_PACKAGE')
pathlib.Path(sys.argv[2]).write_text(source)
PY

mkdir -p "$test_dir/bin"
cat > "$test_dir/bin/fc-cache" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >> "$FONT_TEST_CACHE_LOG"
exit "${FONT_TEST_CACHE_STATUS:-0}"
SH
chmod +x "$test_dir/bin/fc-cache"

reset_fonts() {
  rm -rf "$FONT_TEST_HOME"
  mkdir -p "$FONT_TEST_HOME/.local/share/fonts" "$FONT_TEST_HOME/.config"
  cp "$ROOT/default/fonts/omarchy/omarchy.ttf" "$FONT_TEST_PACKAGE"
  : > "$FONT_TEST_CACHE_LOG"
}

run_migration() {
  PATH="$test_dir/bin:$PATH" bash -euo pipefail "$test_dir/migration.sh" > "$test_dir/output" 2>&1
}

reset_fonts
cp "$fixture" "$legacy_font"
cp "$fixture" "$FONT_TEST_HOME/.config/omarchy.ttf"
run_migration
[[ ! -e $legacy_font ]] || fail "stock font is removed from the actual user font directory"
cmp "$fixture" "$FONT_TEST_HOME/.config/omarchy.ttf" || fail "unrelated config path is untouched"
cmp "$ROOT/default/fonts/omarchy/omarchy.ttf" "$FONT_TEST_PACKAGE" || fail "packaged font is untouched"
[[ $(cat "$FONT_TEST_CACHE_LOG") == "-f" ]] || fail "font cache is refreshed after retirement"
pass "retire the known stock font at its real path and refresh the cache"

run_migration
[[ ! -e $legacy_font ]] || fail "a second run leaves the stock font retired"
pass "font retirement is idempotent"

reset_fonts
cp "$fixture" "$legacy_font"
printf 'custom modification\n' >> "$legacy_font"
cp "$legacy_font" "$test_dir/custom-font.ttf"
run_migration
cmp "$test_dir/custom-font.ttf" "$legacy_font" || fail "custom font is preserved"
pass "preserve a modified font with the legacy filename"

reset_fonts
cp "$fixture" "$test_dir/symlink-target.ttf"
ln -s "$test_dir/symlink-target.ttf" "$legacy_font"
run_migration
[[ -L $legacy_font ]] || fail "user font symlink is preserved"
cmp "$fixture" "$test_dir/symlink-target.ttf" || fail "symlink target is untouched"
pass "preserve user font symlinks even when they point to the stock font"

reset_fonts
run_migration
[[ ! -e $legacy_font ]] || fail "an absent user font is left absent"
pass "handle installs without a legacy user font"

reset_fonts
cp "$fixture" "$legacy_font"
rm "$FONT_TEST_PACKAGE"
if run_migration; then
  fail "missing packaged font keeps the repair pending"
fi
cmp "$fixture" "$legacy_font" || fail "keep the stock font until its replacement is present"
[[ ! -s $FONT_TEST_CACHE_LOG ]] || fail "missing replacement stops before cache refresh"
pass "preserve the stock font and fail when the packaged replacement is missing"

reset_fonts
cp "$fixture" "$legacy_font"
if FONT_TEST_CACHE_STATUS=17 run_migration; then
  fail "font cache failure keeps the repair pending"
fi
[[ ! -e $legacy_font ]] || fail "cache failure follows successful retirement"
run_migration
(( $(wc -l < "$FONT_TEST_CACHE_LOG") == 2 )) || fail "retry refreshes the cache after the file was removed"
pass "retry a failed cache refresh after successful font retirement"

if grep -q $'^retire\tomarchy.ttf\t' "$ROOT/bin/omarchy-upgrade-to-quattro"; then
  fail "upgrader no longer treats the user font as a config file"
fi
pass "upgrader leaves font retirement to its post-upgrade migrations"
