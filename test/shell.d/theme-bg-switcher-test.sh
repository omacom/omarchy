#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

export HOME="$tmp/home"
export XDG_CACHE_HOME="$tmp/cache"
export OMARCHY_PATH="$tmp/omarchy"
mkdir -p "$OMARCHY_PATH/themes/nord/backgrounds" "$HOME/.config/omarchy/themes/fjord/backgrounds" "$HOME/.local/state/omarchy/current" "$tmp/bin"

printf 'aurora' >"$OMARCHY_PATH/themes/nord/backgrounds/1-aurora.png"
printf 'shared' >"$OMARCHY_PATH/themes/nord/backgrounds/2-shared.jpg"
# Sorts first with the same bytes as 1-aurora.png, but the picker cannot show it.
printf 'aurora' >"$OMARCHY_PATH/themes/nord/backgrounds/0-aurora.bak"
printf 'shared' >"$HOME/.config/omarchy/themes/fjord/backgrounds/copy.jpg"
# Same content as 2-shared.jpg, so its quoted name goes through the hashing.
printf 'shared' >"$HOME/.config/omarchy/themes/fjord/backgrounds/a'\$(touch pwned)'.jpg"
printf 'forged' >"$HOME/.config/omarchy/themes/fjord/backgrounds/x"$'\n''1	..	y.jpg	hostname'
# omarchy-theme-set copies the theme's backgrounds, so the current one is a copy.
mkdir -p "$HOME/.local/state/omarchy/current/theme/backgrounds"
cp "$OMARCHY_PATH/themes/nord/backgrounds/1-aurora.png" "$HOME/.local/state/omarchy/current/theme/backgrounds/"
ln -s "$HOME/.local/state/omarchy/current/theme/backgrounds/1-aurora.png" "$HOME/.local/state/omarchy/current/background"

# The rows themselves come from omarchy-menu-images, covered by its own test.
printf '#!/bin/bash\nprintf "arg %%s\\n" "$@"\n' >"$tmp/bin/omarchy-menu-images"
chmod +x "$tmp/bin/omarchy-menu-images"

output=$(cd "$tmp" && PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-theme-bg-switcher" --rows all)
[[ ! -e $tmp/pwned ]] || fail "a file name is never run as a command"
all="$XDG_CACHE_HOME/omarchy/backgrounds-all"

[[ $(ls "$all" | sort | tr '\n' '|') == "nord · 1.png|nord · 2.jpg|" ]] ||
  fail "all themes lists each background once, named by its theme, and skips names with a newline: $(ls "$all" | tr '\n' '|')"
[[ $(readlink "$all/nord · 1.png") == "$OMARCHY_PATH/themes/nord/backgrounds/1-aurora.png" ]] ||
  fail "all themes links to the theme's file"
[[ $(sed -n 1p <<<"$output") == "all" && $(sed -n 2p <<<"$output") == "$all/nord · 1.png" ]] ||
  fail "a view selects the current background, matched by content: $output"
[[ $(<"$HOME/.local/state/omarchy/background-switcher-view") == "all" ]] ||
  fail "a fetched view is remembered for the next open"

PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-theme-bg-switcher" --rows ../../etc >/dev/null
[[ $(<"$HOME/.local/state/omarchy/background-switcher-view") == "theme" ]] ||
  fail "an unknown view falls back to the theme's backgrounds"

switcher() { PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-theme-bg-switcher" "$@"; }
offered_views() { switcher | grep -A1 -x 'arg --views' | tail -n 1; }
mkdir -p "$HOME/.config/omarchy/backgrounds"
[[ $(offered_views) != *'"mine"'* ]] || fail "my backgrounds is offered only when it holds media"
printf 'mine' >"$HOME/.config/omarchy/backgrounds/sunset.JPG"
[[ $(offered_views) == *'"id":"mine"'* ]] || fail "my backgrounds is offered once it holds media: $(offered_views)"
[[ $(switcher --rows mine | sed -n 1p) == "mine" && $(<"$HOME/.local/state/omarchy/background-switcher-view") == "mine" ]] ||
  fail "my backgrounds is fetched and remembered"
rm "$HOME/.config/omarchy/backgrounds/sunset.JPG"
[[ $(offered_views) == *'"current":"theme"'* ]] || fail "a remembered my backgrounds that has emptied opens the theme's backgrounds"

echo "ok - theme background switcher views"
