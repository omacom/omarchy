#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Theme collections: each person's picker (omarchy-theme-switcher's rows)
# offers the collections a grown-up picked for them, Kids for a child and
# everything for anyone else until then, and a child's first login opens on a
# Kids theme.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/omarchy/default/omarchy/theme-collections" "$tmp/home" "$tmp/settings"
cp "$ROOT/default/omarchy/theme-collections/kids" "$tmp/omarchy/default/omarchy/theme-collections/"

cat >"$tmp/bin/id" <<'SH'
#!/bin/bash
echo "${TEST_GROUPS:-kid wheel}"
SH
# The rows are the previews in the directory it is handed, by name.
cat >"$tmp/bin/omarchy-menu-images" <<'SH'
#!/bin/bash
for f in "${!#}"/*; do basename "${f%.*}"; done | sort
SH
cat >"$tmp/bin/omarchy-theme-set" <<'SH'
#!/bin/bash
echo "$1" >>"$TEST_TMP/theme-set"
SH
chmod +x "$tmp/bin/"*
cp "$ROOT/bin/omarchy-theme-collections" "$tmp/bin/"
export PATH="$tmp/bin:$PATH" TEST_TMP=$tmp HOME=$tmp/home OMARCHY_PATH=$tmp/omarchy USER=emma THEME_COLLECTIONS_SETTINGS=$tmp/settings

install_theme() {
  mkdir -p "$tmp/omarchy/themes/$1"
  printf 'png' >"$tmp/omarchy/themes/$1/preview.png"
}

rows() {
  [[ -n ${KEEP_CACHE:-} ]] || rm -rf "$tmp/home/.cache"
  "$ROOT/bin/omarchy-theme-switcher" --print-rows | paste -sd' ' -
}

install_theme tokyo-night
install_theme gruvbox

export TEST_GROUPS="kid omarchy-child"
[[ $(rows) == "gruvbox tokyo-night" ]] || fail "with no kids theme installed a child is offered every theme" "$(rows)"
pass "a child is offered every theme while no Kids theme is installed"

install_theme dino-dawn
install_theme cozy-night
[[ $(rows) == "cozy-night dino-dawn" ]] || fail "a child is offered only the Kids themes" "$(rows)"
export TEST_GROUPS="dhh wheel"
[[ $(rows) == "cozy-night dino-dawn gruvbox tokyo-night" ]] || fail "an adult is offered every theme" "$(rows)"
pass "until a grown-up picks, a child's picker holds Kids and anyone else's holds everything"

export TEST_GROUPS="kid omarchy-child"
printf 'general\n' >"$tmp/settings/emma"
[[ $(rows) == "gruvbox tokyo-night" ]] || fail "General is every theme in no collection" "$(rows)"
printf 'general\nkids\n' >"$tmp/settings/emma"
[[ $(rows) == "cozy-night dino-dawn gruvbox tokyo-night" ]] || fail "General and Kids together are every theme" "$(rows)"
printf 'kids\n' >"$tmp/settings/emma"
[[ $(rows) == "cozy-night dino-dawn" ]] || fail "Kids alone is the Kids themes" "$(rows)"
pass "the collections a grown-up picks are exactly what the picker offers: General, Kids, or both"

# Two refreshes at once, as the shell's and a CLI's can overlap: every run
# still hands over only the person's collections.
export KEEP_CACHE=1
rows >/dev/null
for i in 1 2 3 4 5 6 7 8; do
  rows >"$tmp/rows.$i" &
done
wait
for i in 1 2 3 4 5 6 7 8; do
  [[ $(cat "$tmp/rows.$i") == "cozy-night dino-dawn" ]] || fail "overlapping refreshes each offer only the person's collections" "$(cat "$tmp/rows.$i")"
done
unset KEEP_CACHE
pass "overlapping theme refreshes never offer more than the person's collections"

rm -f "$tmp/settings/emma"
bash "$ROOT/install/user/first-run/child.sh"
[[ $(cat "$tmp/theme-set") == "cozy-night" ]] || fail "a child's first login sets the first Kids theme installed"
rm -f "$tmp/theme-set"
printf 'general\n' >"$tmp/settings/emma"
bash "$ROOT/install/user/first-run/child.sh"
[[ ! -e $tmp/theme-set ]] || fail "a child whose picker has no Kids keeps the theme they have"
rm -f "$tmp/settings/emma"
TEST_GROUPS="dhh wheel" bash "$ROOT/install/user/first-run/child.sh"
[[ ! -e $tmp/theme-set ]] || fail "an adult's first login leaves the theme alone"
pass "a child's first login opens on the first Kids theme when Kids is theirs, and an adult's is untouched"

mkdir -p "$tmp/home/.config/omarchy/themes/paper-harbor"
mv "$tmp/omarchy/themes/cozy-night" "$tmp/cozy-night.away"
bash "$ROOT/install/user/first-run/child.sh"
[[ $(cat "$tmp/theme-set") == "paper-harbor" ]] || fail "a child's first login finds a Kids theme in their own themes" "$(cat "$tmp/theme-set" 2>/dev/null)"
pass "a child's first login finds Kids themes installed in their own themes directory"
