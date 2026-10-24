#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/locale-test.sh"

generator="$ROOT/bin/omarchy-locale-generate"
language="$ROOT/bin/omarchy-language"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-locale-generate"
registry="$ROOT/default/i18n/locales.json"

# Exactly one rule, naming each registry code as the whole argument. A code
# missing would prompt again for that language; the command with its argument
# dropped, which sudoers reads as "any arguments", would widen the grant.
expected="%wheel ALL=(root) NOPASSWD: $(jq -r 'keys | sort | map("/usr/bin/omarchy-locale-generate " + .) | join(", ")' "$registry")"
rules=$(grep -vE '^[[:space:]]*(#|$)' "$sudoers_file")
[[ $rules == "$expected" ]] ||
  fail "locale sudoers file carries exactly one rule naming each registry code" "got: $rules"

if command -v visudo >/dev/null; then
  visudo -cf "$sudoers_file" >/dev/null || fail "locale sudoers rule parses"
fi
pass "locale sudoers rule is scoped to the registry's languages"

grep -Fx 'generator=/usr/bin/omarchy-locale-generate' "$language" >/dev/null ||
  fail "omarchy-language elevates the path the sudoers rule names"
# `sudo -l` alone says whether a command is permitted, which Omarchy's blanket
# %wheel rule answers yes to; only the long listing prints the entry's tags.
grep -E 'sudo -n -l -l' "$language" >/dev/null ||
  fail "omarchy-language reads the grant from the long sudo listing"
pass "omarchy-language asks sudo for the grant before prompting"

# Root resolves bare helpers under sudo's secure_path, which a dev link
# prepends a user-writable checkout bin/ to, so the helper pins PATH to system
# directories once it holds root, and only then.
gated=$(grep -A1 -E '^if \(\( EUID == 0 \)\); then$' "$generator" || true)
[[ $gated == *"export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin"* ]] ||
  fail "omarchy-locale-generate gates the trusted-PATH pin on holding root"
# The test overrides must never reach root: root reads the packaged registry
# and the real locale.gen.
overrides=$(sed -n '/^if (( EUID != 0 )); then$/,/^fi$/p' "$generator")
[[ $overrides == *'OMARCHY_LOCALE_REGISTRY'* && $overrides == *'OMARCHY_LOCALE_GEN'* ]] ||
  fail "omarchy-locale-generate honors its test overrides only without root"
pass "omarchy-locale-generate pins PATH and its files when it holds root"

# Unprivileged runs against fixtures: locale-gen is stubbed, the registry and
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
