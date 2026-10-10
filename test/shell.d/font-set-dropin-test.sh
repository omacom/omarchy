#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
test_bin="$test_dir/bin"
migration="$ROOT/migrations/1791479460.sh"

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
grep -q "<family>Test Font</family>" "$dropin_conf" || fail "drop-in contains selected font"
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
grep -q "<family>Other Font</family>" "$dropin_conf" || fail "drop-in updated with new font"
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
grep -q "<family>Test Font</family>" "$dropin_conf" || fail "drop-in updated with new font"
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
grep -q "<family>Test Font</family>" "$dropin_conf" || fail "drop-in updated with new font"
[[ -f $user_fonts_conf ]] || fail "mixed user fonts.conf preserved"
grep -q "Alternate Serif" "$user_fonts_conf" || fail "custom serif rule was lost"
! grep -q "Old Legacy Font" "$user_fonts_conf" || fail "legacy rule still overrides selected font"
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

# Case 10: A one-line custom rule between two comments is not stripped with them
commented_rule='<?xml version="1.0"?>
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
  <!-- serif --><match target="pattern"><test name="family" qual="any"><string>serif</string></test><edit name="family" mode="prepend_first" binding="strong"><string>Alternate Serif</string></edit></match><!-- end -->
</fontconfig>'
printf '%s\n' "$commented_rule" >"$user_fonts_conf"
run_font_set "Test Font"
grep -Fq '<!-- serif --><match target="pattern"><test name="family" qual="any"><string>serif</string></test><edit name="family" mode="prepend_first" binding="strong"><string>Alternate Serif</string></edit></match><!-- end -->' "$user_fonts_conf" || fail "custom rule between comments was changed"
cp "$user_fonts_conf" "$test_dir/commented-after"
run_migration >/dev/null
cmp -s "$user_fonts_conf" "$test_dir/commented-after" || fail "migration changed custom rules"
pass "one-line custom rule between comments is preserved"

# Case 11: A family whose name only matches monospace once its spaces are gone is not the legacy rule
for family in "mono space" " monospace "; do
  printf '<fontconfig><match target="pattern"><test name="family" qual="any"><string>%s</string></test><edit name="family" mode="prepend_first" binding="strong"><string>User Font</string></edit></match></fontconfig>\n' "$family" >"$user_fonts_conf"
  run_migration >/dev/null
  [[ -f $user_fonts_conf ]] || fail "migration deleted a rule for the family '$family'"
done
pass "migration keeps a rule whose family only differs from monospace by spaces"

# Real fontconfig substitution: user conf.d is read before fonts.conf.
require_command fc-pattern
printf '%s\n' "$mixed_rule" >"$user_fonts_conf"
cat >"$test_dir/fontconfig.conf" <<XML
<fontconfig>
  <include>$dropin_conf</include>
  <include>$user_fonts_conf</include>
</fontconfig>
XML
run_font_set "Other Font"
family=$(FONTCONFIG_FILE="$test_dir/fontconfig.conf" fc-pattern -c -f '%{family[0]}' monospace)
[[ $family == "Other Font" ]] || fail "mixed legacy file shadows chosen font" "$family"
family=$(FONTCONFIG_FILE="$test_dir/fontconfig.conf" fc-pattern -c -f '%{family[0]}' serif)
[[ $family == "Alternate Serif" ]] || fail "custom serif substitution was lost" "$family"
pass "native fontconfig selects the new font and retains custom substitutions"

# A failed publication must not retire the legacy rule or touch terminals.
printf '%s\n' "$legacy_rule" >"$user_fonts_conf"
cp "$user_fonts_conf" "$test_dir/legacy-before"
mv "$dropin_conf" "$test_dir/dropin-before"
mkdir "$dropin_conf"
mkdir -p "$test_home/.config/foot"
printf 'font=Original Font:size=12\n' >"$test_home/.config/foot/foot.ini"
if run_font_set "Test Font" >"$test_dir/failure.log" 2>&1; then
  fail "font set reports a failed drop-in publication"
fi
cmp -s "$user_fonts_conf" "$test_dir/legacy-before" || fail "failed write removed legacy selection"
grep -qx 'font=Original Font:size=12' "$test_home/.config/foot/foot.ini" || fail "failed fontconfig write changed terminal config"
rmdir "$dropin_conf"
mv "$test_dir/dropin-before" "$dropin_conf"
pass "failed drop-in publication preserves the previous override and terminal config"

# Migration must also reject a directory in place of its destination.
mv "$dropin_conf" "$test_dir/dropin-before"
mkdir "$dropin_conf"
if run_migration >"$test_dir/failure.log" 2>&1; then
  fail "migration reports a failed drop-in publication"
fi
cmp -s "$user_fonts_conf" "$test_dir/legacy-before" || fail "failed migration removed legacy selection"
rmdir "$dropin_conf"
mv "$test_dir/dropin-before" "$dropin_conf"
pass "failed migration preserves the legacy override"

# Commented-out rules and near-matches are user content, not legacy overrides.
python3 - "$user_fonts_conf" <<'PY'
from pathlib import Path
import sys
p = Path(sys.argv[1])
legacy = p.read_text()
block = legacy[legacy.index('<match'):legacy.index('</match>') + len('</match>')]
p.write_text('<fontconfig>\n<!-- ' + block + ' -->\n' + block.replace('qual="any"', 'qual="first"') + '\n<match/>\n</fontconfig>\n')
PY
cp "$user_fonts_conf" "$test_dir/custom-before"
run_font_set "Test Font"
cmp -s "$user_fonts_conf" "$test_dir/custom-before" || fail "commented or customized rule changed"
pass "commented rules, custom attributes, and empty matches remain byte-identical"

# Malformed XML cannot safely be classified; report failure without changing files.
printf '<fontconfig><match' >"$user_fonts_conf"
cp "$dropin_conf" "$test_dir/dropin-before"
if run_font_set "Other Font" >"$test_dir/failure.log" 2>&1; then
  fail "malformed user configuration should report a migration error"
fi
cmp -s "$dropin_conf" "$test_dir/dropin-before" || fail "parse failure changed the existing drop-in"
[[ $(cat "$user_fonts_conf") == '<fontconfig><match' ]] || fail "malformed config was modified"
pass "parse errors leave both configurations intact"

# Dotfile symlinks survive cleanup, and unrelated bytes stay untouched.
printf '%s\n' "$mixed_rule" >"$test_dir/linked-fonts.conf"
rm "$user_fonts_conf"
ln -s "$test_dir/linked-fonts.conf" "$user_fonts_conf"
run_font_set "Other Font"
[[ -L $user_fonts_conf ]] || fail "font set replaced a dotfile symlink"
grep -q 'Alternate Serif' "$test_dir/linked-fonts.conf" || fail "linked custom rule was removed"
! grep -q 'Old Legacy Font' "$test_dir/linked-fonts.conf" || fail "linked legacy rule still shadows the drop-in"
pass "font set preserves dotfile symlinks while retiring the legacy rule"
rm "$user_fonts_conf"
printf '%s\n' "$legacy_rule" >"$user_fonts_conf"

if (( EUID != 0 )); then
  cp "$dropin_conf" "$test_dir/dropin-before"
  chmod 500 "$(dirname "$dropin_conf")"
  if run_font_set "Test Font" >"$test_dir/failure.log" 2>&1; then
    chmod 700 "$(dirname "$dropin_conf")"
    fail "unwritable drop-in directory must fail"
  fi
  chmod 700 "$(dirname "$dropin_conf")"
  cmp -s "$dropin_conf" "$test_dir/dropin-before" || fail "failed staging truncated the previous drop-in"
  cmp -s "$user_fonts_conf" "$test_dir/legacy-before" || fail "failed staging retired legacy selection"
  pass "failed staging preserves both existing overrides byte-for-byte"

  chmod 500 "$(dirname "$user_fonts_conf")"
  if run_font_set "Test Font" >"$test_dir/failure.log" 2>&1; then
    chmod 700 "$(dirname "$user_fonts_conf")"
    fail "failed legacy cleanup must be reported"
  fi
  chmod 700 "$(dirname "$user_fonts_conf")"
  cmp -s "$user_fonts_conf" "$test_dir/legacy-before" || fail "failed cleanup damaged the legacy config"
  grep -q 'Could not update fontconfig' "$test_dir/failure.log" || fail "cleanup error did not name the configuration"
  pass "failed legacy cleanup is reported without discarding the old override"
else
  skip "permission failures require an unprivileged test user"
fi

# Valid custom XML outside the legacy writer's format remains usable.
for format in latin1 utf16 entities; do
  python3 - "$user_fonts_conf" "$format" <<'PYXML'
from pathlib import Path
import sys
if sys.argv[2] == 'latin1':
  data = '<?xml version="1.0" encoding="ISO-8859-1"?><fontconfig><!-- café --><match target="font"><edit name="rgba" mode="assign"><const>rgb</const></edit></match></fontconfig>'.encode('latin1')
elif sys.argv[2] == 'utf16':
  data = '<?xml version="1.0" encoding="UTF-16"?><fontconfig><!-- custom rendering --><match target="font"><edit name="rgba" mode="assign"><const>rgb</const></edit></match></fontconfig>'.encode('utf-16')
else:
  data = b'<?xml version="1.0"?><!DOCTYPE fontconfig [<!ENTITY label "custom">]><fontconfig><!-- &label; --><match target="font"><edit name="rgba" mode="assign"><const>rgb</const></edit></match></fontconfig>'
Path(sys.argv[1]).write_bytes(data)
PYXML
  cp "$user_fonts_conf" "$test_dir/custom-before"
  run_font_set "Other Font" >"$test_dir/custom-result" 2>&1
  cmp -s "$user_fonts_conf" "$test_dir/custom-before" || fail "$format custom XML was modified"
  family=$(FONTCONFIG_FILE="$dropin_conf" fc-pattern -c -f '%{family[0]}' monospace)
  [[ $family == "Other Font" ]] || fail "$format custom XML prevented writing the selected font" "$family"
  grep -q 'unchanged' "$test_dir/custom-result" || fail "unsupported legacy recognition has no notice"
  pass "$format custom XML remains byte-identical and permits font selection"
done
