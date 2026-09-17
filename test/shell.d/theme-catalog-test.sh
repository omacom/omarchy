#!/bin/bash

set -euo pipefail

# omarchy-theme-catalog is the only place that knows where the marketplace
# publishes and how it is cached, so what it caches, refuses and refreshes is
# checked here rather than through the commands that read it.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/theme-catalog-helpers.sh"

marketplace_setup

cache="$XDG_CACHE_HOME/omarchy/theme-catalog"

assert_equal "the minimal catalog lists every theme" \
  "$(omarchy-theme-catalog | jq -r '[.themes[].slug] | join(" ")')" "alpha beta gamma delta"

[[ -s $cache/catalog.min.json ]] || fail "the catalog is cached after the first read"
pass "the catalog is cached after the first read"

assert_equal "--entry reads the full entry" \
  "$(omarchy-theme-catalog --entry beta | jq -r '.warnings[0]')" "IGNORED_ON_INSTALL"

assert_equal "an unlisted name yields nothing" "$(omarchy-theme-catalog --entry nope)" ""

# A cached catalog is what makes browsing work on a train. An unreachable
# publisher must leave it in place rather than replace it with nothing.
output=$(OMARCHY_THEME_CATALOG_URL="file://$MARKETPLACE_TMP/gone" omarchy-theme-catalog --refresh 2>&1 >/dev/null)
assert_contains "an unreachable catalog says so" "$output" "using the cached copy"
assert_equal "and the cached catalog still answers" \
  "$(OMARCHY_THEME_CATALOG_URL="file://$MARKETPLACE_TMP/gone" omarchy-theme-catalog | jq -r '.themes[0].slug')" "alpha"

# With no cache to fall back on there is nothing to serve, and saying so beats
# handing a caller an empty catalog it would read as "no themes exist".
marketplace_forget_catalog
if OMARCHY_THEME_CATALOG_URL="file://$MARKETPLACE_TMP/gone" omarchy-theme-catalog >/dev/null 2>&1; then
  fail "an unreachable catalog with no cache fails"
fi
pass "an unreachable catalog with no cache fails"

# What lands has to parse as a catalog: a login page from a captive portal must
# not replace a working copy.
omarchy-theme-catalog >/dev/null
printf '<html>sign in</html>' >"$MARKETPLACE_CDN/v1/catalog.min.json"
output=$(omarchy-theme-catalog --refresh 2>&1 >/dev/null)
assert_contains "a download that is not a catalog is not taken" "$output" "using the cached copy"
assert_equal "and the cached catalog still answers" \
  "$(omarchy-theme-catalog | jq -r '.themes[0].slug')" "alpha"
marketplace_write_catalog
marketplace_forget_catalog

# A wall of grid tiles wants the small rendition and the single preview beside
# them wants the large one, so which is cached is the caller's choice and both
# live under the same commit.
previews=$(printf 'alpha\ngamma\n' | omarchy-theme-catalog --previews)
assert_equal "a preview is reported for each name asked for" "$(wc -l <<<"$previews")" "2"
assert_contains "previews are cached per commit" "$previews" "/previews/alpha/${MARKETPLACE_COMMITS[alpha]}-1200.webp"
assert_contains "the default rendition is the large one" \
  "$(cat "$(awk -F'\t' '$1 == "alpha" { print $2 }' <<<"$previews")")" "fake alpha 1200"

tiles=$(omarchy-theme-catalog --previews --size 480 alpha gamma)
assert_contains "--size picks the small rendition" "$tiles" "-480.webp"
assert_contains "which is a different file, not the same one renamed" \
  "$(cat "$(awk -F'\t' '$1 == "alpha" { print $2 }' <<<"$tiles")")" "fake alpha 480"

# Names come from the arguments as well as from stdin: the overlay asks for a
# hundred and fifty of them at once and has no stdin to write to.
assert_equal "names may be given as arguments" \
  "$(omarchy-theme-catalog --previews --size 480 beta | cut -f1)" "beta"

assert_equal "a name that is not listed asks for no preview" \
  "$(printf 'nope\n' | omarchy-theme-catalog --previews)" ""

if omarchy-theme-catalog --previews --size 900 alpha >/dev/null 2>&1; then
  fail "a rendition the registry does not publish is refused"
fi
pass "a rendition the registry does not publish is refused"
