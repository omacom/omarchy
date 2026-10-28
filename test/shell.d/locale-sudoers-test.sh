#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

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
