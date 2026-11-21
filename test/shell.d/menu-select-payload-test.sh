#!/bin/bash

set -euo pipefail

# omarchy-menu-select hands the shell one JSON payload. Option text arrives
# from arbitrary callers (keybinding descriptions, file names, icon glyphs), so
# it has to survive encoding exactly, including text that looks like a flag.
# The payload is built with a single jq run: a perl stub that fails guards
# against slipping back to JSON::PP, which cost ~120ms on the keybindings menu.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s' "$4" >"$OMARCHY_TEST_PAYLOAD"
touch "$(jq -r .doneFile <<<"$4")"
SH

cat >"$mock_bin/perl" <<'SH'
#!/bin/bash
echo "perl was run" >>"$OMARCHY_TEST_PAYLOAD.perl"
exit 1
SH

chmod +x "$mock_bin"/*

payload="$test_tmp/payload"

select_payload() {
  rm -f "$payload" "$payload.perl"
  PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PAYLOAD="$payload" \
    bash "$ROOT/bin/omarchy-menu-select" "$@" >/dev/null </dev/null || true

  [[ ! -e $payload.perl ]] || fail "omarchy-menu-select builds its payload without perl"
  [[ -s $payload ]] || fail "omarchy-menu-select summons the menu" "args: $*"
}

assert_payload() {
  local description="$1"
  local filter="$2"

  jq -e "$filter" "$payload" >/dev/null || fail "$description" "$(jq . "$payload")"
}

icon_row=$'\xef\x80\x8c\tLabel\tSubtext'
newline_row=$'multi\nline'

select_payload 'Pick "one"' "plain" "-x" "--y" 'quo"te\back' "ü日本" "$icon_row" "$newline_row" "" -- --width 800 --maxheight 500

assert_payload "options keep their text and order" \
  '.options == ["plain", "-x", "--y", "quo\"te\\back", "ü日本", "\uf00c\tLabel\tSubtext", "multi\nline", ""]'
pass "options keep their text, including flag-like, quoted, tabbed and multi-line rows"

assert_payload "prompt and sizes are set" \
  '.mode == "select" and .prompt == "Pick \"one\"" and .width == 800 and .maxHeight == 500'
assert_payload "single-select defaults are set" \
  '.multiple == false and .selected == [] and .onChange == [] and .changeKey == ""'
pass "prompt, sizes and single-select defaults are encoded"

select_payload "Pick" "a" "b" "-c" -- --multiple --selected b --selected -c --on-change '["omarchy-x", "--y"]' --change-key key --height 300

assert_payload "multi-select fields are set" \
  '.options == ["a", "b", "-c"] and .multiple == true and .selected == ["b", "-c"] and .onChange == ["omarchy-x", "--y"] and .changeKey == "key" and .maxHeight == 300 and (has("width") | not)'
pass "multi-select selections and change command are encoded apart from the options"

printf '%s\n' "one" "two" >"$test_tmp/stdin"
rm -f "$payload"
PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_PAYLOAD="$payload" \
  bash "$ROOT/bin/omarchy-menu-select" "Pick" <"$test_tmp/stdin" >/dev/null || true

assert_payload "options read from stdin" '.options == ["one", "two"]'
pass "options piped on stdin are encoded"
