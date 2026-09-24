#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

packages="$ROOT/install/omarchy-base.packages"
migration="$ROOT/migrations/1788129995.sh"

grep -qxF omasnap "$packages" || fail "fresh installs include Omasnap"
! grep -qxF tensaku "$packages" || fail "fresh installs no longer include Tensaku"
! grep -qxF satty "$packages" || fail "fresh installs no longer include Satty"
pass "fresh installs use Omasnap as the screenshot tool"

grep -Fq 'namespace = "^omasnap$"' "$ROOT/default/hypr/apps/screenshot-selection.lua" ||
  fail "Omasnap has a layer rule"
grep -Fq 'no_screen_share = true' "$ROOT/default/hypr/apps/screenshot-selection.lua" ||
  fail "the Omasnap overlay is excluded from screen sharing"
! grep -Fq 'dev.tensaku.Tensaku' "$ROOT/default/hypr/apps/system.lua" ||
  fail "the removed Tensaku window rules are gone"
pass "Hyprland applies Omasnap's overlay policy without stale Tensaku rules"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omasnap" <<'SH'
#!/bin/bash
printf '%s\t%s\n' "${OMASNAP_SCREENSHOT_DIR:-}" "$*" >>"$OMASNAP_TEST_LOG"
SH
chmod +x "$stub_bin/omasnap"

capture_log="$test_tmp/capture.log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot"
[[ $(<"$capture_log") == $'\t' ]] || fail "the default screenshot opens Omasnap without extra arguments"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" OMARCHY_SCREENSHOT_DIR="$test_tmp/legacy-output" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" windows copy
[[ $(<"$capture_log") == "$test_tmp/legacy-output"$'\twindows --copy' ]] ||
  fail "the screenshot command maps the legacy directory and copy argument to Omasnap"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" OMARCHY_SCREENSHOT_DIR="$test_tmp/legacy-output" OMASNAP_SCREENSHOT_DIR="$test_tmp/native-output" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" fullscreen save
[[ $(<"$capture_log") == "$test_tmp/native-output"$'\tfullscreen --save' ]] ||
  fail "the native Omasnap directory wins while legacy save syntax still works"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" region slurp
[[ $(<"$capture_log") == $'\tregion' ]] || fail "the former default slurp argument remains a harmless compatibility no-op"

: >"$capture_log"
OMASNAP_TEST_LOG="$capture_log" PATH="$stub_bin:$PATH" \
  "$ROOT/bin/omarchy-capture-screenshot" scroll --save
[[ $(<"$capture_log") == $'\tscroll --save' ]] || fail "native Omasnap modes and flags pass through unchanged"

pass "the Omarchy screenshot route delegates compatible arguments to Omasnap"

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'add\t%s\n' "$*" >>"$OMASNAP_MIGRATION_LOG"
exit "${OMASNAP_PACKAGE_STATUS:-0}"
SH
cat >"$stub_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'drop\t%s\n' "$*" >>"$OMASNAP_MIGRATION_LOG"
SH
chmod +x "$stub_bin/omarchy-pkg-add" "$stub_bin/omarchy-pkg-drop"

migration_home="$test_tmp/home"
mkdir -p "$migration_home/.config/imv" "$migration_home/dotfiles"
cat >"$migration_home/dotfiles/imv.config" <<'EOF'
[binds]

# Edit the current image in Tensaku and quit the viewer
<Ctrl+e> = exec tensaku-edit "$imv_current_file" & ; quit
<Ctrl+x> = exec custom-editor "$imv_current_file" & ; quit
EOF
ln -s "$migration_home/dotfiles/imv.config" "$migration_home/.config/imv/config"

migration_log="$test_tmp/migration.log"
run_migration() {
  : >"$migration_log"
  OMASNAP_MIGRATION_LOG="$migration_log" HOME="$migration_home" PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

run_migration

[[ $(sed -n '1p' "$migration_log") == $'add\tomasnap' ]] || fail "the migration installs Omasnap first"
[[ $(sed -n '2p' "$migration_log") == $'drop\tsatty tensaku' ]] || fail "the migration removes Satty and Tensaku after Omasnap is ready"
grep -Fq '# Edit the current image in Omasnap and quit the viewer' "$migration_home/.config/imv/config" ||
  fail "the migration updates the stock imv editor comment"
grep -Fq '<Ctrl+e> = exec omasnap "$imv_current_file" & ; quit' "$migration_home/.config/imv/config" ||
  fail "the migration sends the stock imv edit binding to Omasnap"
grep -Fq '<Ctrl+x> = exec custom-editor "$imv_current_file" & ; quit' "$migration_home/.config/imv/config" ||
  fail "the migration preserves custom imv bindings"
[[ -L $migration_home/.config/imv/config ]] || fail "the migration preserves a dotfile-managed imv symlink"
[[ $(stat -c '%a' "$migration") == 644 ]] || fail "the Omasnap migration has mode 0644"

pass "the migration swaps packages and safely updates only the stock imv binding"

cat >"$migration_home/dotfiles/imv.config" <<'EOF'
[binds]

# Edit the current image in Satty and quit the viewer
<Ctrl+e> = exec satty --filename "$imv_current_file" & ; quit
<Ctrl+x> = exec custom-editor "$imv_current_file" & ; quit
EOF
cp "$migration_home/dotfiles/imv.config" "$test_tmp/imv-before"
legacy_desktop="$migration_home/.local/share/applications/omasnap.desktop"
mkdir -p "$(dirname "$legacy_desktop")"
cat >"$legacy_desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Omasnap
Exec=omasnap
NoDisplay=true
EOF
if OMASNAP_PACKAGE_STATUS=1 run_migration; then
  fail "Omasnap install failure stops the migration"
fi
[[ $(<"$migration_log") == $'add\tomasnap' ]] || fail "install failure leaves old screenshot packages installed"
cmp -s "$test_tmp/imv-before" "$migration_home/dotfiles/imv.config" || fail "install failure leaves the imv binding untouched"
[[ -f $legacy_desktop ]] || fail "install failure preserves the existing launcher entry"
pass "Omasnap install failure preserves the previous screenshot setup"

run_migration
[[ ! -e $legacy_desktop && ! -L $legacy_desktop ]] || fail "the migration removes the old user-local Omasnap desktop entry"
pass "the migration removes the desktop entry that hides the packaged launcher"
grep -Fq '# Edit the current image in Omasnap and quit the viewer' "$migration_home/.config/imv/config" ||
  fail "the migration updates the stock Satty comment"
grep -Fq '<Ctrl+e> = exec omasnap "$imv_current_file" & ; quit' "$migration_home/.config/imv/config" ||
  fail "the migration replaces the stock Satty binding before removing Satty"
grep -Fq '<Ctrl+x> = exec custom-editor "$imv_current_file" & ; quit' "$migration_home/.config/imv/config" ||
  fail "the Satty migration preserves custom bindings"
[[ -L $migration_home/.config/imv/config ]] || fail "the Satty migration preserves the imv symlink"
pass "the migration upgrades the stock Satty binding to Omasnap"

cp "$migration_home/dotfiles/imv.config" "$test_tmp/imv-migrated"
run_migration
cmp -s "$test_tmp/imv-migrated" "$migration_home/dotfiles/imv.config" || fail "rerunning the migration preserves the updated imv config"
pass "the migration can be rerun"

printf '<Ctrl+e> = exec custom-editor "$imv_current_file" & ; quit\n' >"$migration_home/dotfiles/imv.config"
cp "$migration_home/dotfiles/imv.config" "$test_tmp/imv-custom"
run_migration
cmp -s "$test_tmp/imv-custom" "$migration_home/dotfiles/imv.config" || fail "the migration preserves a custom edit shortcut"
pass "custom imv edit shortcuts remain unchanged"
