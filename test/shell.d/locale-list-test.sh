#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-locale-list"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

i18n="$tmp/i18n"
mkdir -p "$i18n/locales"

# One file per SUPPORTED entry, carrying the two LC_IDENTIFICATION lines the
# list reads. glibc's own are a few hundred lines of collation and character
# classes around them, and a fixture pins the cases rather than whatever the
# box running the test happens to ship -- the point here is the labelling, and
# glibc is free to add or drop a locale without that being a regression.
locale_file() {
  local name=$1 language=$2 territory=$3

  {
    printf 'LC_IDENTIFICATION\n'
    printf 'title      "a test locale"\n'
    if [[ -n $language ]]; then
      printf 'language   "%s"\n' "$language"
    fi
    if [[ -n $territory ]]; then
      printf 'territory  "%s"\n' "$territory"
    fi
    printf 'END LC_IDENTIFICATION\n'
  } >"$i18n/locales/$name"
}

# entry <name> <codeset> <language> <territory>
entry() {
  printf '%s %s\n' "$1" "$2" >>"$i18n/SUPPORTED"
  locale_file "${1%.UTF-8}" "$3" "$4"
}

entry en_US.UTF-8 UTF-8 "American English" "United States"
entry sl_SI.UTF-8 UTF-8 "Slovenian" "Slovenia"
entry eo UTF-8 "Esperanto" ""
entry sr_RS UTF-8 "Serbian" "Serbia"
entry sr_RS@latin UTF-8 "Serbian" "Serbia"
entry ca_ES.UTF-8 UTF-8 "Catalan" "Spain"
entry ca_ES@valencia UTF-8 "Catalan" "Spain"
entry zh_CN.UTF-8 UTF-8 "Chinese" "China"
entry zh_TW.UTF-8 UTF-8 "Chinese" "Taiwan"

# A modifier with no plain sibling: nothing is ambiguous, so nothing is appended.
entry tt_RU@iqtelif UTF-8 "Tatar" "Russia"

# A shape glibc does not ship today -- a shared label with no territory to hang
# the qualifier off. Here so that the second half of the label cannot regress
# into "Testish (, Variant)" the first time such a locale appears.
entry xx UTF-8 "Testish" ""
entry xx@variant UTF-8 "Testish" ""

# Left out of the list: one names no language, one is not UTF-8.
entry C.UTF-8 UTF-8 "" ""
entry en_GB.ISO-8859-1 ISO-8859-1 "British English" "United Kingdom"

list=$(OMARCHY_I18N_PATH="$i18n" "$command")

field() {
  printf '%s\n' "$list" | awk -F'\t' -v name="$1" -v column="$2" '$1 == name { print $column }'
}

assert_label() {
  local name=$1 expected=$2 description=$3
  local actual
  actual=$(field "$name" 4)

  [[ $actual == "$expected" ]] || fail "$description" "locale:         $name
expected label: $expected
actual label:   $actual"
  pass "$description"
}

assert_label sl_SI.UTF-8 "Slovenian (Slovenia)" "label is the language and its territory"
assert_label eo "Esperanto" "label is the language alone when the locale names no territory"

# The ten groups this exists for: language and territory are identical and the
# modifier is the whole difference, so picking one of them was a coin flip.
assert_label sr_RS@latin "Serbian (Serbia, Latin)" "label carries the modifier when it is the only difference"
assert_label sr_RS "Serbian (Serbia)" "the unmodified locale of a pair keeps the plain label"
assert_label ca_ES@valencia "Catalan (Spain, Valencia)" "label carries a modifier that names a variant rather than a script"
assert_label tt_RU@iqtelif "Tatar (Russia)" "label leaves the modifier off when nothing shares the label"
assert_label xx@variant "Testish (Variant)" "label carries the modifier with no territory to sit beside"

# The one distinction glibc will not supply: LC_IDENTIFICATION has no script
# field and all four Chinese locales name their language "Chinese".
assert_label zh_CN.UTF-8 "Chinese (China, Simplified)" "label names the written form for Simplified Chinese"
assert_label zh_TW.UTF-8 "Chinese (Taiwan, Traditional)" "label names the written form for Traditional Chinese"

# What the labels are for: a label read back off a picker names one locale.
duplicates=$(printf '%s\n' "$list" | cut -d$'\t' -f4 | sort | uniq -d)
[[ -z $duplicates ]] || fail "every label names exactly one locale" "labels shared by more than one locale:
$duplicates"
pass "every label names exactly one locale"

# The three fields that were already the contract, unchanged by the fourth.
[[ $(field sr_RS@latin 2) == "Serbian" && $(field sr_RS@latin 3) == "Serbia" ]] ||
  fail "the language and territory fields still report what the locale says" "$(field sr_RS@latin 0)"
pass "the language and territory fields still report what the locale says"

[[ $(printf '%s\n' "$list" | cut -d$'\t' -f1 | tr '\n' ' ') == "en_US.UTF-8 sl_SI.UTF-8 eo sr_RS sr_RS@latin ca_ES.UTF-8 ca_ES@valencia zh_CN.UTF-8 zh_TW.UTF-8 tt_RU@iqtelif xx xx@variant " ]] ||
  fail "the list keeps SUPPORTED's order and drops what names no language" "$(printf '%s\n' "$list" | cut -d$'\t' -f1 | tr '\n' ' ')"
pass "the list keeps SUPPORTED's order and drops what names no language"

# Off Arch there is no /usr/share/i18n at all, and the callers treat an empty
# list as "no languages to offer" rather than as a failure.
missing=$(OMARCHY_I18N_PATH="$tmp/absent" "$command") || fail "a missing locale tree is empty rather than fatal"
[[ -z $missing ]] || fail "a missing locale tree is empty rather than fatal" "actual: $missing"
pass "a missing locale tree is empty rather than fatal"
