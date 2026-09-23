#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
test_bin="$test_dir/bin"
migration="$ROOT/migrations/1790098827.sh"

mkdir -p "$test_home/.config/fontconfig" "$test_bin"

for cmd in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$test_bin/$cmd"
done
printf '#!/bin/bash\nexit 1\n' >"$test_bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\nOther Font\\n"\n' >"$test_bin/fc-list"
chmod +x "$test_bin/"*

run_font_set() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-font-set" "$@"
}

run_migration() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_bin:$ROOT/bin:$PATH" bash -euo pipefail "$migration"
}

dropin_conf="$test_home/.config/fontconfig/conf.d/50-omarchy-monospace.conf"
user_fonts_conf="$test_home/.config/fontconfig/fonts.conf"

# Case 1: Fresh install - omarchy-font-set writes to drop-in conf.d
run_font_set "Test Font"
[[ -f $dropin_conf ]] || fail "omarchy-font-set creates conf.d drop-in file"
grep -q "<string>Test Font</string>" "$dropin_conf" || fail "drop-in contains selected font"
[[ ! -e $user_fonts_conf ]] || fail "user fonts.conf is not created by omarchy-font-set"
pass "omarchy-font-set creates conf.d drop-in file and leaves fonts.conf absent"

# Case 2: User fonts.conf with custom rules must NEVER be truncated or deleted
custom_rule='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit mode="assign" name="rgba"><const>rgb</const></edit>
  </match>
</fontconfig>'
printf '%s\n' "$custom_rule" >"$user_fonts_conf"

run_font_set "Other Font"
grep -q "<string>Other Font</string>" "$dropin_conf" || fail "drop-in updated with new font"
[[ -f $user_fonts_conf ]] || fail "user fonts.conf preserved"
[[ $(cat "$user_fonts_conf") == "$custom_rule" ]] || fail "custom user fonts.conf content was not truncated or modified"
pass "custom user fonts.conf is preserved and not truncated by omarchy-font-set"

# Case 3: Legacy pure Omarchy fonts.conf is retired by omarchy-font-set
legacy_rule='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>Old Legacy Font</string>
    </edit>
  </match>
</fontconfig>'
printf '%s\n' "$legacy_rule" >"$user_fonts_conf"

run_font_set "Test Font"
grep -q "<string>Test Font</string>" "$dropin_conf" || fail "drop-in updated with new font"
[[ ! -f $user_fonts_conf ]] || fail "legacy pure Omarchy fonts.conf should be retired by font-set"
pass "legacy pure Omarchy fonts.conf is retired by omarchy-font-set"

# Case 4: Mixed user fonts.conf with one-line custom rule must be preserved by omarchy-font-set
mixed_rule='<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>Old Legacy Font</string>
    </edit>
  </match>
  <match target="pattern"><test name="family" qual="any"><string>serif</string></test><edit name="family" mode="prepend_first" binding="strong"><string>Alternate Serif</string></edit></match>
</fontconfig>'
printf '%s\n' "$mixed_rule" >"$user_fonts_conf"

run_font_set "Test Font"
grep -q "<string>Test Font</string>" "$dropin_conf" || fail "drop-in updated with new font"
[[ -f $user_fonts_conf ]] || fail "mixed user fonts.conf preserved"
[[ $(cat "$user_fonts_conf") == "$mixed_rule" ]] || fail "mixed user fonts.conf content was not modified"
pass "mixed user fonts.conf with one-line custom rule is preserved by omarchy-font-set"

# Case 5: Migration moves legacy pure Omarchy fonts.conf to dropin if dropin does not exist
rm -rf "$test_home/.config/fontconfig"
mkdir -p "$test_home/.config/fontconfig"
printf '%s\n' "$legacy_rule" >"$user_fonts_conf"

run_migration >/dev/null
[[ -f $dropin_conf ]] || fail "migration created drop-in from legacy fonts.conf"
grep -q "<string>Old Legacy Font</string>" "$dropin_conf" || fail "migration preserved font name in drop-in"
[[ ! -f $user_fonts_conf ]] || fail "migration retired legacy fonts.conf"
pass "migration moves legacy pure fonts.conf to conf.d drop-in"

# Case 6: Migration leaves custom user fonts.conf untouched
printf '%s\n' "$custom_rule" >"$user_fonts_conf"
run_migration >/dev/null
[[ -f $user_fonts_conf ]] || fail "migration preserved custom fonts.conf"
[[ $(cat "$user_fonts_conf") == "$custom_rule" ]] || fail "migration modified custom fonts.conf"
pass "migration leaves custom user fonts.conf untouched"

# Case 7: Migration leaves mixed user fonts.conf untouched when drop-in already exists
printf '%s\n' "$mixed_rule" >"$user_fonts_conf"
run_migration >/dev/null
[[ -f $user_fonts_conf ]] || fail "migration preserved mixed fonts.conf when drop-in exists"
[[ $(cat "$user_fonts_conf") == "$mixed_rule" ]] || fail "migration modified mixed fonts.conf"
pass "migration leaves mixed user fonts.conf untouched when drop-in exists"

# Case 8: Migration leaves mixed user fonts.conf untouched when drop-in does not exist
rm -rf "$test_home/.config/fontconfig"
mkdir -p "$test_home/.config/fontconfig"
printf '%s\n' "$mixed_rule" >"$user_fonts_conf"
run_migration >/dev/null
[[ -f $user_fonts_conf ]] || fail "migration preserved mixed fonts.conf when drop-in absent"
[[ $(cat "$user_fonts_conf") == "$mixed_rule" ]] || fail "migration modified mixed fonts.conf when drop-in absent"
[[ ! -f $dropin_conf ]] || fail "migration did not treat mixed fonts.conf as pure drop-in source"
pass "migration does not mistake mixed fonts.conf for pure Omarchy template"

# Case 9: Migration idempotency
run_migration >/dev/null
[[ $(cat "$user_fonts_conf") == "$mixed_rule" ]] || fail "migration rerun modified custom fonts.conf"
pass "migration is idempotent"
