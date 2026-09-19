#!/bin/bash

set -euo pipefail

# Installing a listed theme pins it to the commit the marketplace validated, and
# everything downstream -- updating it, listing it, browsing past it -- depends
# on that pin and on the marker left beside it. Exercised against a catalog
# served over file:// and repositories created here, with theme staging and the
# shell stubbed, so the clone, the checkout and the marker are the real ones.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/theme-catalog-helpers.sh"

marketplace_setup

# --- installing a listed theme ---------------------------------------------

omarchy-theme-install alpha >/dev/null
assert_contains "installing a listed theme applies it" "$(marketplace_calls)" "theme-set alpha"
assert_equal "the working tree is the validated commit" \
  "$(git -C "$MARKETPLACE_THEMES/alpha" rev-parse HEAD)" "${MARKETPLACE_COMMITS[alpha]}"
assert_equal "the marker records the commit" \
  "$(jq -r .commit "$MARKETPLACE_THEMES/alpha/.marketplace")" "${MARKETPLACE_COMMITS[alpha]}"
assert_equal "the marker records the listed name" \
  "$(jq -r .name "$MARKETPLACE_THEMES/alpha/.marketplace")" "alpha"

# The marker lives inside someone else's repository, so git is told to ignore it
# rather than leaving every clone reading as dirty.
assert_equal "the marker does not dirty the clone" \
  "$(git -C "$MARKETPLACE_THEMES/alpha" status --porcelain)" ""

# omarchy-theme-set copies "$source"/* into the staged theme, which never
# matches a dotfile. If that ever changed, the marker would land in the live
# theme directory and from there into every theme's staged contents.
assert_equal "the marker is not something theme staging would copy" \
  "$(compgen -G "$MARKETPLACE_THEMES/alpha/*" | grep -c 'marketplace' || true)" "0"

# --- only the files Omarchy reads are cloned --------------------------------

# A theme repo may carry a gallery, notes beside its wallpapers, or a file that
# runs code. None of it has to be downloaded to apply the theme's colours.
assert_equal "the files Omarchy reads are checked out" \
  "$(cd "$MARKETPLACE_THEMES/alpha" && printf '%s ' colors.toml preview.png shell.lock.toml backgrounds/one.jpg | xargs -n1 test -f && echo present)" "present"

for unread in docs/screenshot.png backgrounds/notes.txt neovim.lua; do
  [[ ! -e $MARKETPLACE_THEMES/alpha/$unread ]] ||
    fail "a theme repo's $unread is not checked out"
done
pass "what Omarchy never reads is left in the repo"

# The patterns are the clone's, so they survive into updates rather than being
# a one-off filter applied at install time.
assert_equal "the checkout stays restricted afterwards" \
  "$(git -C "$MARKETPLACE_THEMES/alpha" config core.sparseCheckout)" "true"

# A colour file Omarchy generates may also be shipped by a theme, so every one
# of them needs a pattern; a new template upstream otherwise stops arriving
# without anything failing. Derived from the templates and from theme-set's own
# deny list so the three cannot drift apart.
patterns=$(omarchy-theme-files | sed 's|^/||')
denied=$(sed -n 's/^INSTALLED_THEME_DENIED=(\(.*\))$/\1/p' "$ROOT/bin/omarchy-theme-set")

uncovered=()
for tpl in "$ROOT"/default/themed/*.tpl; do
  generated=$(basename "$tpl" .tpl)

  # A theme may ship neither Lua nor anything on the deny list, so neither
  # needs a pattern.
  [[ $generated == *.lua ]] && continue
  [[ " $denied " == *" $generated "* ]] && continue

  covered=0
  while IFS= read -r pattern; do
    # shellcheck disable=SC2053
    if [[ $generated == $pattern ]]; then
      covered=1
      break
    fi
  done <<<"$patterns"

  (( covered )) || uncovered+=("$generated")
done

(( ${#uncovered[@]} == 0 )) ||
  fail "every colour file Omarchy generates can be shipped by a theme" \
    "no pattern in THEME_FILES matches: ${uncovered[*]}"
pass "every colour file Omarchy generates can be shipped by a theme"

# --- a listed name that is not the derived directory name -------------------

# The catalog lists this one as "delta"; its repo is omarchy-dlt-theme, and the
# directory has to be what this machine derives, because omarchy-theme-set and
# every picker after it address a theme by directory name.
output=$(omarchy-theme-install delta 2>&1)
assert_contains "a disagreeing name is reported" "$output" "installing it as 'dlt'"
[[ -d $MARKETPLACE_THEMES/dlt ]] || fail "the directory is the derived name"
pass "the directory is the derived name"
assert_equal "the marker keeps the listed name" \
  "$(jq -r .name "$MARKETPLACE_THEMES/dlt/.marketplace")" "delta"

# --- refusals ---------------------------------------------------------------

if omarchy-theme-install not-a-theme >/dev/null 2>&1; then
  fail "an unlisted name is refused"
fi
assert_contains "an unlisted name says where to look" \
  "$(omarchy-theme-install not-a-theme 2>&1 || true)" "omarchy theme browse"

# A symlink in the themes directory is someone's own working copy. Installing
# over it would unlink their work without asking.
ln -s "$MARKETPLACE_TMP" "$MARKETPLACE_THEMES/gamma"
if omarchy-theme-install gamma >/dev/null 2>&1; then
  fail "installing over a symlinked theme is refused"
fi
[[ -L $MARKETPLACE_THEMES/gamma ]] || fail "the symlinked theme is left alone"
pass "installing over a symlinked theme is refused"
rm -f "$MARKETPLACE_THEMES/gamma"

# A repo that no longer carries the validated commit cannot be installed as if
# it did: following its branch instead would install code nobody checked.
missing=$(jq --arg c "0000000000000000000000000000000000000000" \
  '.themes |= map(if .slug == "gamma" then .commit = $c else . end)' \
  "$MARKETPLACE_CDN/v1/catalog.json")
printf '%s' "$missing" >"$MARKETPLACE_CDN/v1/catalog.json"
marketplace_forget_catalog
output=$(omarchy-theme-install gamma 2>&1 || true)
assert_contains "a missing validated commit refuses the install" "$output" "no longer has the commit"
[[ ! -e $MARKETPLACE_THEMES/gamma ]] || fail "a refused install leaves nothing behind"
pass "a refused install leaves nothing behind"
marketplace_write_catalog
marketplace_forget_catalog

# --- a git URL still installs the way it always did -------------------------

marketplace_reset_calls
omarchy-theme-install "file://${MARKETPLACE_REPOS[gamma]}" >/dev/null
assert_contains "a git URL still installs" "$(marketplace_calls)" "theme-set gamma"
[[ ! -f $MARKETPLACE_THEMES/gamma/.marketplace ]] || fail "a URL install is not marked as listed"
pass "a URL install is not marked as listed"
assert_equal "a URL install follows the branch, not a pin" \
  "$(git -C "$MARKETPLACE_THEMES/gamma" rev-parse --abbrev-ref HEAD)" "master"

# --- listing what came from the marketplace ---------------------------------

assert_equal "pinned themes are listed by their listed name" \
  "$(omarchy-theme-pinned --names | sort | tr '\n' ' ')" "alpha delta "
assert_equal "the theme cloned from a URL is not among them" \
  "$(omarchy-theme-pinned --names | grep -c gamma || true)" "0"

# --- updating ---------------------------------------------------------------

# Move alpha back a commit and let the update walk it forward, which is the
# whole point of the pin: it tracks validated commits, not a branch.
older=$(git -C "${MARKETPLACE_REPOS[alpha]}" rev-parse HEAD~1)
git -C "$MARKETPLACE_THEMES/alpha" checkout --quiet --detach "$older"
jq --arg c "$older" '.commit = $c' "$MARKETPLACE_THEMES/alpha/.marketplace" >"$MARKETPLACE_TMP/m"
mv "$MARKETPLACE_TMP/m" "$MARKETPLACE_THEMES/alpha/.marketplace"
printf 'alpha' >"$HOME/.local/state/omarchy/current/theme.name"

marketplace_reset_calls
output=$(omarchy-theme-update 2>&1)
assert_contains "an outdated pin moves forward" "$output" "${older:0:12} -> ${MARKETPLACE_COMMITS[alpha]:0:12}"
assert_equal "the working tree moved with it" \
  "$(git -C "$MARKETPLACE_THEMES/alpha" rev-parse HEAD)" "${MARKETPLACE_COMMITS[alpha]}"
assert_equal "the marker moved with it" \
  "$(jq -r .commit "$MARKETPLACE_THEMES/alpha/.marketplace")" "${MARKETPLACE_COMMITS[alpha]}"
assert_contains "the applied theme is staged again" "$(marketplace_calls)" "theme-set alpha"

# A pin that is already current is left alone, and saying so beats silence.
marketplace_reset_calls
output=$(omarchy-theme-update 2>&1)
assert_contains "a current pin reports itself" "$output" "already at the validated commit"
assert_equal "and nothing is staged again" "$(marketplace_calls)" ""

# A catalog that cannot be read is not a theme that was delisted; saying the one
# when it is the other would send someone looking for a theme that is still
# there.
marketplace_forget_catalog
output=$(OMARCHY_THEME_CATALOG_URL="file://$MARKETPLACE_TMP/gone" omarchy-theme-update 2>&1 || true)
assert_contains "an unreadable catalog is not a delisting" "$output" "could not read the marketplace"
marketplace_forget_catalog

# A theme that is genuinely no longer listed is left where it is, and said so.
delisted=$(jq '.themes |= map(select(.slug != "alpha"))' "$MARKETPLACE_CDN/v1/catalog.json")
printf '%s' "$delisted" >"$MARKETPLACE_CDN/v1/catalog.json"
assert_contains "a delisted theme is left alone" "$(omarchy-theme-update 2>&1)" "no longer listed"
marketplace_write_catalog
marketplace_forget_catalog

# A theme the user cloned themselves is still pulled, not pinned.
assert_contains "an unpinned theme still pulls" "$(omarchy-theme-update 2>&1)" "Updating: gamma"

# --- a listed repo built to get past the allowlist --------------------------

# The allowlist is for themes the marketplace listed: a stranger's repository
# the user picked off a wall of previews. Sparse-checkout patterns are gitignore
# patterns, so one naming a file also matches a directory of that name, and a
# symlink wearing an allowed name is checked out like any other entry.
hostile=$(marketplace_make_hostile_repo)

list_hostile() {
  local commit
  local name

  commit=$(git -C "$hostile" rev-parse HEAD)
  for name in catalog.json catalog.min.json; do
    jq --arg repo "file://$hostile" --arg commit "$commit" \
      '.themes |= map(select(.slug != "hostile"))
      | .themes += [{slug: "hostile", name: "Hostile", repo: $repo, commit: $commit,
        mode: "dark", hue: "gray", author: "nobody", featured: false,
        thumb: "unused/480.webp", colors: {}, warnings: [], ignored_on_install: []}]' \
      "$MARKETPLACE_CDN/v1/$name" >"$MARKETPLACE_TMP/listed" &&
      mv "$MARKETPLACE_TMP/listed" "$MARKETPLACE_CDN/v1/$name"
  done
  marketplace_forget_catalog
}

list_hostile
omarchy-theme-install hostile >/dev/null 2>&1

for smuggled in colors.toml/evil.sh colors.toml/run.lua README.md/evil.sh \
  backgrounds/nested/evil.sh install.sh; do
  [[ ! -e $MARKETPLACE_THEMES/hostile/$smuggled ]] ||
    fail "a listed repo cannot smuggle $smuggled past the allowlist"
done
pass "nothing a listed repo smuggles is written to disk"

# .marketplace is Omarchy's own marker, not something the repo shipped.
assert_equal "what the theme legitimately ships is kept" \
  "$(find "$MARKETPLACE_THEMES/hostile" -path '*/.git' -prune -o \
    -type f ! -name .marketplace -print |
    sed "s|$MARKETPLACE_THEMES/hostile/||" | sort | tr '\n' ' ')" "backgrounds/real.jpg "

# Nothing was deleted out of the working tree to achieve that -- git was told
# not to write it. A clone left dirty could never be updated again.
assert_equal "the clone is left clean enough to update" \
  "$(git -C "$MARKETPLACE_THEMES/hostile" status --porcelain)" ""

# A symlink cannot be excluded by a gitignore pattern, so one wearing an allowed
# name is checked out. It stops at omarchy-theme-set, which stages no symlink
# from a repo -- see theme-staging-test.sh.
[[ -L $MARKETPLACE_THEMES/hostile/preview.png ]] ||
  fail "the symlink case is still the one theme staging has to catch"
pass "the symlink case is left to theme staging, which refuses it"

# A later commit can carry what the first did not, so the allowlist has to hold
# as a listed theme moves rather than only at install time.
printf 'payload\n' >"$hostile/postinstall.sh"
printf 'payload\n' >"$hostile/colors.toml/later.lua"
git -C "$hostile" -c user.email=t@e -c user.name=t add -A
git -C "$hostile" -c user.email=t@e -c user.name=t commit --quiet -m "smuggle later"
list_hostile

output=$(omarchy-theme-update 2>&1)
assert_contains "a theme with smuggled files can still be updated" "$output" "Updating: hostile"
assert_equal "and it moved to the new commit" \
  "$(git -C "$MARKETPLACE_THEMES/hostile" rev-parse HEAD)" \
  "$(git -C "$hostile" rev-parse HEAD)"

for smuggled in postinstall.sh colors.toml/later.lua; do
  [[ ! -e $MARKETPLACE_THEMES/hostile/$smuggled ]] ||
    fail "an update cannot bring in $smuggled"
done
pass "what a later commit adds is held to the same list"

# The same repo installed from a URL is the user naming it themselves, and
# clones whole. omarchy-theme-set is what decides what may be staged out of it.
omarchy-theme-install "file://$hostile" >/dev/null 2>&1
[[ -f $MARKETPLACE_THEMES/hostile/install.sh ]] ||
  fail "a URL install clones the repository whole"
assert_equal "a URL install is not put under the allowlist" \
  "$(git -C "$MARKETPLACE_THEMES/hostile" config core.sparseCheckout)" ""

rm -rf "$MARKETPLACE_THEMES/hostile"
marketplace_write_catalog
marketplace_forget_catalog

# A theme the user cloned into the themes directory by hand is theirs, and an
# update must not start deleting out of it. sparse-checkout is what tells a
# clone omarchy-theme-install made from one the user made.
mkdir -p "$MARKETPLACE_THEMES/mine"
git -C "$MARKETPLACE_THEMES/mine" init --quiet -b master
printf 'accent = "#111111"\n' >"$MARKETPLACE_THEMES/mine/colors.toml"
printf 'notes\n' >"$MARKETPLACE_THEMES/mine/my-notes.txt"
git -C "$MARKETPLACE_THEMES/mine" -c user.email=t@e -c user.name=t add -A
git -C "$MARKETPLACE_THEMES/mine" -c user.email=t@e -c user.name=t commit --quiet -m mine

omarchy-theme-update >/dev/null 2>&1
[[ -f $MARKETPLACE_THEMES/mine/my-notes.txt ]] ||
  fail "a theme the user cloned themselves is left alone by the allowlist"
[[ $(git -C "$MARKETPLACE_THEMES/mine" config core.sparseCheckout) != "true" ]] ||
  fail "a theme the user cloned themselves is not put under the allowlist"
pass "a theme the user cloned themselves is left alone by the allowlist"

# --- browsing ---------------------------------------------------------------

# With a desktop up, browsing is the overlay's job: the command's work is to
# hand it the filters it was given and get out of the way.
export OMARCHY_TEST_SHELL_UP=1
marketplace_reset_calls
omarchy-theme-browse --light --search dune >/dev/null 2>&1
summon=$(marketplace_calls)
assert_contains "browsing summons the overlay" "$summon" "summon omarchy.theme-browser"
assert_contains "and hands it the search" "$summon" '"search":"dune"'
assert_contains "and hands it the mode" "$summon" '"light":true'
assert_contains "and does not invent one" "$summon" '"dark":false'

marketplace_reset_calls
omarchy-theme-browse --featured --new --installed --hue blue --refresh >/dev/null 2>&1
summon=$(marketplace_calls)
assert_contains "every filter reaches the overlay" "$summon" '"featured":true'
assert_contains "including the ones with no chip" "$summon" '"hue":"blue"'
assert_contains "and the refresh" "$summon" '"refresh":true'

# Without a shell the same catalog is offered as a list, and --print-name takes
# that path too, which is what lets the filtering be checked here. The list
# shows titles, so that is what these assert on.
list_titles() {
  : >"$OMARCHY_TEST_MENU"
  omarchy-theme-browse "$@" --print-name >/dev/null 2>&1
  sed 's/  (.*//' "$OMARCHY_TEST_MENU" 2>/dev/null | sort | tr '\n' ' '
}

assert_equal "the list offers every theme"  "$(list_titles)" "Alpha Beta Light Delta Gamma "
assert_equal "--dark"                       "$(list_titles --dark)" "Alpha Delta Gamma "
assert_equal "--light"                      "$(list_titles --light)" "Beta Light "
assert_equal "--hue"                        "$(list_titles --hue orange)" "Beta Light Gamma "
assert_equal "--featured"                   "$(list_titles --featured)" "Alpha "
assert_equal "--search matches the artist"  "$(list_titles --search ada)" "Alpha Delta Gamma "
assert_equal "--search ignores case"        "$(list_titles --search ADA)" "Alpha Delta Gamma "
assert_equal "--new reads the listing dates" "$(list_titles --new)" "Alpha "

# dlt on disk, delta in the catalog: the filter has to match on the catalog's
# name, which is what the marker remembers.
assert_equal "--installed matches the markers" "$(list_titles --installed)" "Alpha Delta "

output=$(omarchy-theme-browse --dark --light --hue purple --print-name 2>&1 || true)
assert_contains "an empty result says so" "$output" "no themes match"

# Opened from the menu there is no terminal to print into, and a failure that
# only reaches stderr reads to the user as the menu doing nothing at all.
marketplace_reset_calls
marketplace_forget_catalog
OMARCHY_THEME_CATALOG_URL="file://$MARKETPLACE_TMP/gone" OMARCHY_TEST_SHELL_UP=0 \
  omarchy-theme-browse --print-name >/dev/null 2>&1 || true
assert_contains "a failure with no terminal is notified" "$(marketplace_calls)" "notify Could not browse themes"
marketplace_forget_catalog

assert_equal "the list resolves a name back to its theme" \
  "$(OMARCHY_TEST_SHELL_UP=0 OMARCHY_TEST_FILTER="Beta Light" omarchy-theme-browse --light --print-name)" "beta"

marketplace_reset_calls
OMARCHY_TEST_SHELL_UP=0 OMARCHY_TEST_FILTER="Gamma" omarchy-theme-browse --dark >/dev/null 2>&1
assert_contains "choosing from the list with no terminal hands the install a floating one" \
  "$(marketplace_calls)" "floating omarchy-theme-install gamma"

# --- info -------------------------------------------------------------------

output=$(omarchy-theme-info beta 2>&1)
assert_contains "info names the artist" "$output" "Bo"
assert_contains "info shows the palette" "$output" "#cc6622"
assert_contains "info spells out a validator code" "$output" "ships files Omarchy will not install"
assert_contains "info warns what will not be installed" "$output" "kitty.conf"

# delta is installed as dlt; the marker, not the directory, says it is here.
assert_contains "info finds an installed theme by its listed name" \
  "$(omarchy-theme-info delta 2>&1)" "Installed"

if omarchy-theme-info not-a-theme >/dev/null 2>&1; then
  fail "info refuses an unlisted name"
fi
pass "info refuses an unlisted name"
