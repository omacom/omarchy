#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub_bin="$tmp/bin"
stock="$tmp/omarchy/themes"
user="$tmp/home/.config/omarchy/themes"
cache="$tmp/cache/omarchy/theme-selector"
mkdir -p "$stub_bin" "$stock/white" "$stock/nord" "$user/white/backgrounds" "$user/nord.custom"

# The switcher hands its preview directory to the picker; list it instead.
cat >"$stub_bin/omarchy-menu-images" <<'EOF'
#!/bin/bash
for entry in "${@: -1}"/*; do
  printf '%s\n' "${entry##*/}"
done
EOF
chmod +x "$stub_bin/omarchy-menu-images"

printf 'png' >"$stock/white/preview.png"
printf 'png' >"$stock/nord/preview.png"
printf 'jpg' >"$user/white/backgrounds/1-white.jpg"
printf 'png' >"$user/nord.custom/preview.png"

run_switcher() {
  HOME="$tmp/home" XDG_CACHE_HOME="$tmp/cache" OMARCHY_PATH="$tmp/omarchy" PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-theme-switcher"
}

entries=$(run_switcher)

white=$(grep -c '^white\.' <<<"$entries" || true)
(( white == 1 )) || fail "a user override whose preview has another extension lists its theme once" "$entries"
grep -Fxq 'white.jpg' <<<"$entries" || fail "the user override's preview wins over the stock one" "$entries"
pass "a user override whose preview has another extension lists its theme once"

grep -Fxq 'nord.png' <<<"$entries" || fail "a user theme named after a stock one with a suffix does not hide it" "$entries"
grep -Fxq 'nord.custom.png' <<<"$entries" || fail "a user theme named after a stock one with a suffix is listed" "$entries"
pass "a user theme named after a stock one with a suffix does not hide it"

# A cache built before the fix holds both entries under an unchanged theme tree.
ln -s "$stock/white/preview.png" "$cache/previews/white.png"
sed -i '1s/.*/v2/' "$cache/fast-signature"
entries=$(run_switcher)

white=$(grep -c '^white\.' <<<"$entries" || true)
(( white == 1 )) || fail "a preview cache from before the fix is rebuilt" "$entries"
pass "a preview cache from before the fix is rebuilt"
