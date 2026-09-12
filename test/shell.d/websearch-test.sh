#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/xdg-open" <<'SH'
#!/bin/bash
printf 'open:%s\n' "$*" >>"$OMARCHY_TEST_OPEN_LOG"
SH
chmod +x "$mock_bin/xdg-open"

export PATH="$mock_bin:$PATH"
export HOME="$test_tmp/home"
export OMARCHY_TEST_OPEN_LOG="$test_tmp/open-log"
mkdir -p "$HOME"

websearch="$ROOT/bin/omarchy-websearch"
default_search="$ROOT/bin/omarchy-default-search"

# No override, no browser profile: DuckDuckGo.
out=$("$websearch" "hyprland window rules")
grep -Fxq 'open:https://duckduckgo.com/?q=hyprland%20window%20rules' "$OMARCHY_TEST_OPEN_LOG" ||
  fail "websearch falls back to DuckDuckGo" "$(cat "$OMARCHY_TEST_OPEN_LOG")"
pass "websearch falls back to DuckDuckGo"

# Setter roundtrip; invalid ids rejected.
"$default_search" google || fail "default search setter succeeds"
[[ $("$default_search") == "google" ]] || fail "default search getter reads back"
pass "default search setter roundtrips"
"$default_search" altavista >/dev/null 2>&1 &&
  fail "default search rejects unknown engines"
pass "default search rejects unknown engines"

# The override wins and encodes the query.
: >"$OMARCHY_TEST_OPEN_LOG"
out=$("$websearch" "a & b")
grep -Fxq 'open:https://www.google.com/search?q=a%20%26%20b' "$OMARCHY_TEST_OPEN_LOG" ||
  fail "websearch honors the override with encoding" "$(cat "$OMARCHY_TEST_OPEN_LOG")"
pass "websearch honors the override with encoding"

# A Chrome-family browser default is honored without an override.
rm -f "$HOME/.config/omarchy/defaults/search-engine"
mkdir -p "$HOME/.config/brave-browser/Default"
cat >"$HOME/.config/brave-browser/Default/Preferences" <<'JSON'
{"profile": {"default_search_provider_data": {"template_url_data": {"url": "https://search.brave.com/search?q={searchTerms}"}}}}
JSON
: >"$OMARCHY_TEST_OPEN_LOG"
"$websearch" "hello world" >/dev/null
grep -Fxq 'open:https://search.brave.com/search?q=hello%20world' "$OMARCHY_TEST_OPEN_LOG" ||
  fail "websearch reads the browser default" "$(cat "$OMARCHY_TEST_OPEN_LOG")"
pass "websearch reads the browser default"

# Corrupt override degrades to the next source instead of breaking search.
printf 'not-an-engine' >"$HOME/.config/omarchy/defaults/search-engine"
: >"$OMARCHY_TEST_OPEN_LOG"
"$websearch" "still works" >/dev/null
grep -Fq 'open:https://search.brave.com/search?q=still%20works' "$OMARCHY_TEST_OPEN_LOG" ||
  fail "websearch survives a corrupt override" "$(cat "$OMARCHY_TEST_OPEN_LOG")"
pass "websearch survives a corrupt override"

# Menu wiring: engine submenu, checked guards, quicklink through the helper.
for engine in google brave duckduckgo startpage ecosia bing; do
  grep -Fq "\"setup.default.search-engine.${engine}\":" "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
    fail "menu has a ${engine} row"
done
pass "menu has all engine rows"
grep -Fq '"action":"omarchy-websearch {}"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "search quicklink uses the engine helper"
pass "search quicklink uses the engine helper"
