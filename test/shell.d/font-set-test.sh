#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home with spaces"
mkdir -p "$test_home/.config" "$test_dir/bin"

for command in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send omarchy-cmd-present; do
  printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Sarasa Mono SC\\nTest Font\\n"\n' >"$test_dir/bin/fc-list"
chmod +x "$test_dir/bin/"*

run_font_set() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-font-set" "$@"
}

run_font_set "Sarasa Mono SC"
fonts_conf="$test_home/.config/fontconfig/fonts.conf"
[[ -f $fonts_conf ]] || fail "font set writes fonts.conf"

grep -Fq 'qual="first" compare="eq"' "$fonts_conf" || fail "fontconfig test uses qual=first compare=eq"
grep -Fq '<string>JetBrainsMono Nerd Font</string>' "$fonts_conf" || fail "fontconfig test matches packaged default monospace family"
grep -Fq '<string>Sarasa Mono SC</string>' "$fonts_conf" || fail "fontconfig edit prepends the chosen family"
grep -Fq '<string>ui-monospace</string>' "$fonts_conf" || fail "fontconfig keeps ui-monospace on the chosen family"
! grep -Fq 'qual="any"' "$fonts_conf" || fail "fontconfig test must not use qual=any"
! grep -Fq '<string>monospace</string>' "$fonts_conf" || fail "fontconfig test must not match the monospace generic directly"
pass "font set writes a first-family test against the packaged monospace default"

# Exercise Fontconfig's actual pattern substitution as well as the emitted XML.
# fc-pattern does not require the chosen test font to be installed. Escape the
# hyphen in ui-monospace or Fontconfig parses it as family "ui" + size suffix.
if command -v fc-pattern >/dev/null 2>&1; then
  config_fixture="$test_dir/fontconfig-test.conf"
  cat >"$config_fixture" <<XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <include>$ROOT/default/fontconfig/conf.avail/50-omarchy.conf</include>
  <include>$fonts_conf</include>
</fontconfig>
XML

  first_family() {
    FONTCONFIG_FILE="$config_fixture" fc-pattern -c -f '%{family}\n' "$1" |
      cut -d, -f1
  }

  [[ $(first_family monospace) == "Sarasa Mono SC" ]] ||
    fail "generic monospace must select the chosen font"
  [[ $(first_family 'ui\-monospace') == "Sarasa Mono SC" ]] ||
    fail "ui-monospace must select the chosen font"
  [[ $(first_family 'Noto Sans Mono') == "Noto Sans Mono" ]] ||
    fail "explicit named mono font must not be remapped"
  pass "Fontconfig substitutions preserve named fonts and override generic/ UI monospace"
else
  skip "Fontconfig pattern checks require fc-pattern"
fi

# A custom packaged default should be read at write time rather than hard-coded.
custom_root="$test_dir/custom-omarchy"
mkdir -p "$custom_root/default/fontconfig/conf.avail"
cat >"$custom_root/default/fontconfig/conf.avail/50-omarchy.conf" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <!-- A preceding CJK-style append must not become the default family. -->
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="append" binding="strong">
      <string>Supplemental Mono</string>
    </edit>
  </match>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="assign" binding="strong">
      <string>Custom Default Mono</string>
    </edit>
  </match>
</fontconfig>
XML

env HOME="$test_home" OMARCHY_PATH="$custom_root" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-font-set" "Test Font"
grep -Fq '<string>Custom Default Mono</string>' "$fonts_conf" || fail "fontconfig test reads the packaged default at write time"
! grep -Fq '<string>Supplemental Mono</string>' "$fonts_conf" || fail "fontconfig must ignore the preceding append rule"
grep -Fq '<string>Test Font</string>' "$fonts_conf" || fail "fontconfig edit uses the newly chosen family"
pass "font set reads the packaged monospace assign from 50-omarchy.conf"
