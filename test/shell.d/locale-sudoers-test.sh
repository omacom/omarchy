#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/locale-test.sh"

generator="$ROOT/bin/omarchy-locale-generate"
registry="$ROOT/default/i18n/locales.json"

# The sudoers rule and the root half are covered in sudoers-test.sh. These
# unprivileged runs use fixtures: locale-gen is stubbed, the registry and
# locale.gen are overridden.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
cat >"$work/bin/locale-gen" <<'STUB'
#!/bin/bash
echo "$@" >>"$LOCALE_GEN_LOG"
STUB
chmod +x "$work/bin/locale-gen"
export LOCALE_GEN_LOG=$work/locale-gen.log OMARCHY_LOCALE_GEN=$work/locale.gen OMARCHY_LOCALE_REGISTRY=$registry
printf '#sv_SE.UTF-8 UTF-8\n#hi_IN UTF-8\n' >"$OMARCHY_LOCALE_GEN"
run() { PATH="$work/bin:$PATH" bash "$generator" "$@"; }

: >"$LOCALE_GEN_LOG"
run sv || fail "omarchy-locale-generate generates a registry language"
grep -qx 'sv_SE.UTF-8 UTF-8' "$OMARCHY_LOCALE_GEN" || fail "the language's locale is enabled in locale.gen" "$(cat "$OMARCHY_LOCALE_GEN")"
[[ $(cat "$LOCALE_GEN_LOG") == "sv_SE.UTF-8" ]] || fail "locale-gen generates the language's locale" "$(cat "$LOCALE_GEN_LOG")"
run fil || fail "omarchy-locale-generate adds a locale locale.gen doesn't list"
grep -qx 'fil_PH.UTF-8 UTF-8' "$OMARCHY_LOCALE_GEN" || fail "a missing locale is appended to locale.gen" "$(cat "$OMARCHY_LOCALE_GEN")"
pass "omarchy-locale-generate enables and generates a registry language's locale"

# The code check is a bracket range, which follows the locale's collation, so it
# is pinned to C: under tr_TR.UTF-8 an unpinned `[a-z]` misses `i` and `I`
# and every registry code reads as malformed.
if turkish_locale "$work/locales"; then
  : >"$LOCALE_GEN_LOG"
  in_turkish run it || fail "omarchy-locale-generate accepts a registry code under tr_TR.UTF-8"
  grep -qx 'it_IT.UTF-8 UTF-8' "$OMARCHY_LOCALE_GEN" || fail "the code's locale is enabled under tr_TR.UTF-8" "$(cat "$OMARCHY_LOCALE_GEN")"
  pass "omarchy-locale-generate reads a code the same under tr_TR.UTF-8"
else
  skip "no tr_TR.UTF-8 locale that misses i in [a-z] can be built here; skipping the locale-pinning check"
fi

for bad in "" "xx" "../da" "da;id" "da sv" "DA"; do
  : >"$LOCALE_GEN_LOG"
  if run "$bad" 2>/dev/null; then
    fail "omarchy-locale-generate rejects '$bad'"
  fi
  [[ ! -s $LOCALE_GEN_LOG ]] || fail "a rejected code generates nothing" "'$bad'"
done
if run da sv 2>/dev/null; then
  fail "omarchy-locale-generate takes exactly one code"
fi
pass "omarchy-locale-generate rejects anything but one registry code"

# The registry decides the locale; a malformed one never reaches locale.gen.
printf '{"da": {"locale": "da_DK.UTF-8 UTF-8\\nfr_FR.UTF-8"}}\n' >"$work/registry.json"
: >"$LOCALE_GEN_LOG"
if OMARCHY_LOCALE_REGISTRY=$work/registry.json run da 2>/dev/null; then
  fail "omarchy-locale-generate rejects a malformed registry locale"
fi
[[ ! -s $LOCALE_GEN_LOG ]] || fail "a malformed registry locale generates nothing"
pass "omarchy-locale-generate only generates well-formed locales"
