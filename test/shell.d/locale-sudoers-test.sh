#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

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

# Unprivileged runs against fixtures: localedef is stubbed, the registry and
# locale.gen are overridden.
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
# localedef lists the archive from a file, and adds to it unless told the
# addition fails, exiting with the status it is given either way.
cat >"$work/bin/localedef" <<'STUB'
#!/bin/bash
if [[ $1 == "--list-archive" ]]; then
  cat "$LOCALEDEF_ARCHIVE"
  exit
fi
echo "$@" >>"$LOCALE_GEN_LOG"
locale=${*: -1}
[[ -n ${LOCALEDEF_FAILS:-} ]] || echo "${locale%.UTF-8}.utf8" >>"$LOCALEDEF_ARCHIVE"
exit "${LOCALEDEF_STATUS:-0}"
STUB
chmod +x "$work/bin/localedef"
export LOCALE_GEN_LOG=$work/locale-gen.log LOCALEDEF_ARCHIVE=$work/locale-archive OMARCHY_LOCALE_GEN=$work/locale.gen OMARCHY_LOCALE_REGISTRY=$registry
printf '#sv_SE.UTF-8 UTF-8\n#hi_IN UTF-8\n' >"$OMARCHY_LOCALE_GEN"
run() { PATH="$work/bin:$PATH" bash "$generator" "$@"; }

# The source lookup is the host's, so a /usr/local override here is a right answer.
: >"$LOCALE_GEN_LOG"
run sv || fail "omarchy-locale-generate generates a registry language"
grep -qx 'sv_SE.UTF-8 UTF-8' "$OMARCHY_LOCALE_GEN" || fail "the language's locale is enabled in locale.gen" "$(cat "$OMARCHY_LOCALE_GEN")"
[[ $(cat "$LOCALE_GEN_LOG") == "-i "?(/usr/local/share/i18n/locales/)sv_SE?(.UTF-8)" -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8" ]] ||
  fail "localedef adds only the language's locale" "$(cat "$LOCALE_GEN_LOG")"
: >"$LOCALE_GEN_LOG"
run hi || fail "omarchy-locale-generate generates a locale locale.gen spells without its codeset"
grep -qx 'hi_IN UTF-8' "$OMARCHY_LOCALE_GEN" || fail "a codeset-less entry is enabled in place" "$(cat "$OMARCHY_LOCALE_GEN")"
[[ $(cat "$LOCALE_GEN_LOG") == "-i "?(/usr/local/share/i18n/locales/)hi_IN?(.UTF-8)" -c -f UTF-8 -A /usr/share/locale/locale.alias hi_IN.UTF-8" ]] ||
  fail "localedef names a codeset-less entry with its codeset" "$(cat "$LOCALE_GEN_LOG")"
run fil || fail "omarchy-locale-generate adds a locale locale.gen doesn't list"
grep -qx 'fil_PH.UTF-8 UTF-8' "$OMARCHY_LOCALE_GEN" || fail "a missing locale is appended to locale.gen" "$(cat "$OMARCHY_LOCALE_GEN")"
pass "omarchy-locale-generate enables and generates a registry language's locale"

# localedef exits 1 for warnings and for a locale it could not add to a full
# archive alike, so only the archive says whether the language can switch.
: >"$LOCALEDEF_ARCHIVE"
LOCALEDEF_STATUS=1 run sv || fail "localedef warnings still generate the locale"
for status in 1 4 135; do
  : >"$LOCALE_GEN_LOG"
  if LOCALEDEF_FAILS=1 LOCALEDEF_STATUS=$status run da 2>/dev/null; then
    fail "omarchy-locale-generate fails when localedef adds nothing and exits $status"
  fi
  [[ $(cat "$LOCALE_GEN_LOG") == *" da_DK.UTF-8" ]] || fail "the failure is localedef's, not an earlier refusal" "$(cat "$LOCALE_GEN_LOG")"
done
pass "omarchy-locale-generate fails when the locale is not generated"

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
