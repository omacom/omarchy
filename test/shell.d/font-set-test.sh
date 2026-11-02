#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command python3

migration="$ROOT/migrations/1787771328.sh"
default_fontconfig="$ROOT/default/fontconfig/conf.avail/50-omarchy.conf"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

cat >"$test_dir/bin/fc-list" <<'STUB'
#!/bin/bash

echo "${FONT_SET_TEST_FAMILY:-Test Mono S}"
STUB

for stub in omarchy-restart-shell omarchy-notification-send omarchy-hook; do
  printf '#!/bin/bash\n\nexit 0\n' >"$test_dir/bin/$stub"
done

# No terminal is running under a fake home, so the restart toasts stay quiet.
printf '#!/bin/bash\n\nexit 1\n' >"$test_dir/bin/pgrep"

chmod +x "$test_dir/bin/"*

home="$test_dir/home"
fontconfig_file="$home/.config/fontconfig/fonts.conf"

# The override "omarchy font set" wrote before the alias: it fires on any
# pattern carrying the monospace generic, and 48-guessfamily.conf appends that
# generic to every family whose name merely contains "mono".
legacy_override() {
  cat <<XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>$1</string>
    </edit>
  </match>
</fontconfig>
XML
}

expected_override() {
  cat <<XML
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias binding="strong">
    <family>Omarchy Fixed Pitch</family>
    <prefer>
      <family>$1</family>
    </prefer>
  </alias>
</fontconfig>
XML
}

run_migration() {
  HOME="$home" bash -euo pipefail "$migration" >/dev/null
}

set_font() {
  rm -rf "$home"
  mkdir -p "$home"
  HOME="$home" FONT_SET_TEST_FAMILY="$1" PATH="$test_dir/bin:$PATH" \
    bash "$ROOT/bin/omarchy-font-set" "$1" >/dev/null
}

# --- The generic leaves a placeholder for the user file ------------------------

# Read as XML rather than as text, so the check holds however the rule is
# spelled. The generic has to be consumed, or 60-latin.conf and 65-nonlatin.conf
# put their own monospace lists ahead of every CJK fallback 50-omarchy.conf adds.
packaged=$(python3 - "$default_fontconfig" <<'PYTHON'
import sys, xml.etree.ElementTree as ET

root = ET.parse(sys.argv[1]).getroot()

def matches_generic(match):
  if match.get("target") not in (None, "pattern"):
    return False
  return any((string.text or "").strip() == "monospace"
             for test in match.findall("test") if test.get("name") == "family"
             for string in test.findall("string"))

edits = ["%s %s %s" % (edit.get("mode", "assign"),
                              ", ".join((string.text or "").strip() for string in edit.findall("string")),
                              edit.get("binding") or "weak")
                for match in root.findall("match") if matches_generic(match)
                for edit in match.findall("edit") if edit.get("name") == "family"]

print("edits:", "; ".join(edits) if edits else "nothing")
PYTHON
)

# The strong binding is load-bearing: weak, and the untargeted strong Naskh
# fallback outranks it on a machine that has chosen no font.
[[ $packaged == *"assign Omarchy Fixed Pitch, JetBrainsMono Nerd Font strong"* ]] ||
  fail "the packaged default replaces the generic with the placeholder, then its own family, strongly bound" "$packaged"
pass "the packaged default replaces the generic with the placeholder, then its own family, strongly bound"

# --- omarchy-font-set writes the alias ---------------------------------------

set_font "Test Mono S"

[[ $(<"$fontconfig_file") == "$(expected_override "Test Mono S")" ]] ||
  fail "omarchy-font-set writes the chosen family as an alias" "$(cat "$fontconfig_file")"
pass "omarchy-font-set writes the chosen family as an alias"

# --- The migration repairs an override the old command left behind ------------

rm -rf "$home"
mkdir -p "$(dirname "$fontconfig_file")"
legacy_override "Test Mono S" >"$fontconfig_file"
run_migration

[[ $(<"$fontconfig_file") == "$(expected_override "Test Mono S")" ]] ||
  fail "migration rewrites the legacy override and keeps the chosen family" "$(cat "$fontconfig_file")"
pass "migration rewrites the legacy override and keeps the chosen family"

before=$(<"$fontconfig_file")
run_migration

[[ $(<"$fontconfig_file") == "$before" ]] ||
  fail "migration is idempotent" "$(cat "$fontconfig_file")"
pass "migration is idempotent"

# --- Anything else stays as the user left it ----------------------------------

rm -rf "$home"
mkdir -p "$(dirname "$fontconfig_file")"
cat >"$fontconfig_file" <<'XML'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>Test Mono S</string>
    </edit>
  </match>
  <match target="pattern">
    <edit name="rgba" mode="assign">
      <const>none</const>
    </edit>
  </match>
</fontconfig>
XML
customized=$(<"$fontconfig_file")
run_migration

[[ $(<"$fontconfig_file") == "$customized" ]] ||
  fail "migration leaves a hand-edited override alone" "$(cat "$fontconfig_file")"
pass "migration leaves a hand-edited override alone"

rm -rf "$home"
mkdir -p "$home"
run_migration

[[ ! -e $fontconfig_file ]] ||
  fail "migration writes nothing when no override exists" "$(cat "$fontconfig_file")"
pass "migration writes nothing when no override exists"

# --- What fontconfig resolves with those files --------------------------------

# The assertions above pin what the two files say; this one pins what fontconfig
# does with them, which is the only part a user ever sees. It needs the system
# fontconfig directory and enough monospace families installed to tell a capture
# apart from a correct match, so it skips where a machine cannot answer.

packaged_family="JetBrainsMono Nerd Font"
fixture="$test_dir/fontconfig"

installed_mono_families() {
  fc-list :spacing=100 family | tr ',' '\n' | sed 's/^ *//; s/ *$//' | sort -u
}

build_fixture() {
  rm -rf "$fixture"
  mkdir -p "$fixture/conf.d" "$fixture/cache"

  local file
  for file in /etc/fonts/conf.d/*.conf; do
    ln -s "$file" "$fixture/conf.d/${file##*/}"
  done

  # Only the packaged file is swapped for the one under test; the rest of the
  # system directory loads exactly as it would on the machine.
  rm -f "$fixture/conf.d/50-omarchy.conf"
  cp "$default_fontconfig" "$fixture/conf.d/50-omarchy.conf"

  sed "s#<include ignore_missing=\"yes\">conf.d</include>#<include ignore_missing=\"yes\">$fixture/conf.d</include>#" \
    /etc/fonts/fonts.conf >"$fixture/fonts.conf"
}

resolve() {
  FONTCONFIG_FILE="$fixture/fonts.conf" XDG_CONFIG_HOME="$home/.config" XDG_CACHE_HOME="$fixture/cache" \
    fc-match "$1" family
}

# fc-match answers with every name the matched font carries, and a family can be
# a font's alternate name: "JetBrainsMono NF" answers "JetBrainsMono Nerd
# Font,JetBrainsMono NF". Reading only the head calls that a capture.
resolved_to() {
  local answer=$1 family=$2

  [[ ,$answer, == *",$family,"* ]]
}

resolvable=1
command -v fc-match >/dev/null && command -v fc-list >/dev/null || resolvable=0
# Without the guessfamily rules the capture cannot happen in the first place,
# and without the packaged family there is no default left to compare against.
[[ -r /etc/fonts/fonts.conf && -r /etc/fonts/conf.d/48-guessfamily.conf ]] || resolvable=0

chosen=""
named=""
if ((resolvable)); then
  installed_mono_families | grep -Fxq "$packaged_family" || resolvable=0
fi
if ((resolvable)); then
  mapfile -t candidates < <(installed_mono_families | grep -i mono | grep -Fxv "$packaged_family")
  chosen=${candidates[0]:-}
  # A name sharing any file with the chosen font would resolve to it either way.
  # Given as a property, so a hyphen in the name is not read as a size, and a
  # name fc-list still misreads finds no files and is passed over.
  for candidate in "${candidates[@]:1}"; do
    [[ -n $(fc-list ":family=$candidate" file) ]] || continue
    if [[ -z $(comm -12 <(fc-list ":family=$candidate" file | sort) <(fc-list ":family=$chosen" file | sort)) ]]; then
      named=$candidate
      break
    fi
  done
  [[ -n $chosen && -n $named ]] || resolvable=0
fi

if ((resolvable)); then
  build_fixture

  rm -rf "$home"
  mkdir -p "$home/.config"

  answer=$(resolve monospace)
  resolved_to "$answer" "$packaged_family" ||
    fail "with no font chosen, monospace resolves to the packaged family" "monospace -> $answer"
  pass "with no font chosen, monospace resolves to the packaged family"

  set_font "$chosen"

  answer=$(resolve monospace)
  resolved_to "$answer" "$chosen" ||
    fail "the chosen family follows the monospace generic" "monospace -> $answer, wanted $chosen"
  pass "the chosen family follows the monospace generic"

  answer=$(resolve "$named")
  resolved_to "$answer" "$named" ||
    fail "a named mono family still resolves to itself" "$named -> $answer, chosen was $chosen"
  pass "a named mono family still resolves to itself"

  answer=$(resolve "$packaged_family")
  resolved_to "$answer" "$packaged_family" ||
    fail "the packaged family named outright still resolves to itself" "$packaged_family -> $answer, chosen was $chosen"
  pass "the packaged family named outright still resolves to itself"

  # Escaped, or fc-match reads the hyphen as the start of a size.
  answer=$(resolve 'ui\-monospace')
  resolved_to "$answer" "$chosen" ||
    fail "the chosen family follows ui-monospace" "ui-monospace -> $answer, wanted $chosen"
  pass "the chosen family follows ui-monospace"
else
  pass "no fontconfig fixture on this machine; skipping resolution checks"
fi
