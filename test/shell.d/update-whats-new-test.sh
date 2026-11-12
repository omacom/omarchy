#!/bin/bash
# omarchy-update-whats-new-notes decides when the update icon offers a
# release's what's-new tour and what the tour shows: only the installed
# release's notes are offered, once, and only on the package channels; items
# whose guard fails drop out, and the text follows the Omarchy language.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
tree="$test_tmp/omarchy"
mkdir -p "$stub_bin" "$tree/default/omarchy/whats-new" "$tree/default/i18n/da" "$test_tmp/home"

cat >"$stub_bin/pacman" <<'STUB'
#!/bin/bash
[[ $1 == "-Q" && $2 == "${TEST_PACKAGE:-omarchy}" ]] || exit 1
echo "$2 ${TEST_VERSION:-4.5.0-1}"
STUB
cat >"$stub_bin/omarchy-language" <<'STUB'
#!/bin/bash
echo "${TEST_LANGUAGE:-en}"
STUB
chmod +x "$stub_bin/pacman" "$stub_bin/omarchy-language"

cat >"$tree/default/omarchy/whats-new/4.4.jsonc" <<'JSONC'
{ "items": [{ "title": "Old news", "body": "From before." }] }
JSONC
cat >"$tree/default/omarchy/whats-new/4.5.jsonc" <<'JSONC'
// The notes shown for every 4.5 release.
{
  "post": "https://omarchy.org/news/2026/11/omarchy-4-5/",
  "items": [
    { "changed": true, "title": "Hotkeys moved", "body": "Some did.", "keys": "Super + K" },
    { "title": "Only with Hype", "body": "Hidden.", "when": "false" },
    { "title": "Elsewhen", "body": "A world clock.", "try": { "label": "Open", "action": "omarchy-shell shell summon omarchy.elsewhen" } }
  ]
}
JSONC
printf '{"Hotkeys moved": "Genveje er flyttet", "Open": "Åbn"}\n' >"$tree/default/i18n/da/whats-new.json"

expect() {
  [[ $1 == "$2" ]] || fail "$3" "expected $2, got $1"
  pass "$3"
}

notes() {
  HOME="$test_tmp/home" OMARCHY_PATH="$tree" PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-update-whats-new-notes" "$@"
}

[[ $(notes --pending) == "4.5" ]] || fail "a stable 4.5 install is offered the 4.5 notes"
pass "a stable 4.5 install is offered the 4.5 notes"

[[ $(TEST_VERSION=4.5.0rc3-1 notes --pending) == "4.5" && $(TEST_VERSION=4.5.2-1 notes --pending) == "4.5" ]] ||
  fail "release candidates and patch releases share their release's notes"
pass "release candidates and patch releases share their release's notes"

if TEST_PACKAGE=omarchy-dev notes --pending >/dev/null; then
  fail "edge and dev, on omarchy-dev, are not prompted"
fi
pass "edge and dev, on omarchy-dev, are not prompted"

if TEST_VERSION=4.6.0-1 notes --pending >/dev/null; then
  fail "a release without notes of its own offers nothing"
fi
[[ $(TEST_VERSION=4.6.0-1 notes | jq -r .release) == "4.5" ]] || fail "the menu falls back to the newest notes"
pass "a release without notes offers nothing, and the menu shows the newest"

shown=$(notes)
expect "$(jq -c '[.release, .pending, (.items | map(.title))]' <<<"$shown")" '["4.5",true,["Hotkeys moved","Elsewhen"]]' \
  "the installed notes are pending and drop items whose guard fails"
expect "$(jq -c '.items[0] | [.changed, .keys]' <<<"$shown")" '[true,"Super + K"]' "items keep their changed flag and hotkey"

translated=$(TEST_LANGUAGE=da notes 4.5)
expect "$(jq -c '[.items[0].title, .items[0].body, .items[1].try.label, .items[1].try.action]' <<<"$translated")" \
  '["Genveje er flyttet","Some did.","Åbn","omarchy-shell shell summon omarchy.elsewhen"]' \
  "text follows the language, falling back to English, and actions stay as written"

HOME="$test_tmp/home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-whats-new-seen" 4.5
if notes --pending >/dev/null; then
  fail "seen notes are not offered again"
fi
pass "seen notes are not offered again"
expect "$(notes | jq .pending)" "false" "seen notes still open from the menu"

if notes ../4.5 >/dev/null 2>&1 || notes 4.9 >/dev/null 2>&1; then
  fail "only a release with notes can be named"
fi
pass "only a release with notes can be named"

# Every shipped notes file parses, and every command a Try button starts with
# still exists.
for file in "$ROOT"/default/omarchy/whats-new/*.jsonc; do
  release=$(basename "$file" .jsonc)
  shipped=$(OMARCHY_PATH="$ROOT" PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$test_tmp/home" \
    "$ROOT/bin/omarchy-update-whats-new-notes" "$release") || fail "the shipped $release notes parse"
  (( $(jq '.items | length' <<<"$shipped") > 0 )) || fail "the shipped $release notes have items"
  while read -r command; do
    [[ -x $ROOT/bin/$command ]] || fail "the $release notes' Try button runs $command, which exists"
  done < <(sed '/^[[:space:]]*\/\//d' "$file" | jq -r '.items[].try.action // empty | split(" ")[0] | select(startswith("omarchy-"))')
  pass "the shipped $release notes parse and their Try commands exist"
done
