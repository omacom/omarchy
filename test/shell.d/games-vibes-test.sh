#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command gio

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/omarchy-launch-webapp" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >>"$OMARCHY_TEST_ARGV"
SH
chmod +x "$mock_bin/omarchy-launch-webapp"

# A home with a space and a percent sign, which the file URL has to survive.
export HOME="$test_tmp/my home 100%"
# An Omarchy that ships two games, one of which the user has a copy of.
export OMARCHY_PATH="$test_tmp/omarchy"
shipped="$OMARCHY_PATH/default/games/vibes"
mkdir -p "$shipped/chess" "$shipped/snake"
cp "$ROOT/default/games/vibes.html" "$OMARCHY_PATH/default/games/"
printf '<!doctype html><title>Chess</title>\n' >"$shipped/chess/index.html"
printf '<!doctype html><title>Shipped Snake</title>\n' >"$shipped/snake/index.html"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_ARGV="$test_tmp/argv"
vibes="$HOME/Games/vibes"
mkdir -p "$HOME/.local/state/omarchy/current/theme"
printf 'background = "#1a1b26"\nforeground = "#a9b1d6"\naccent = "#7aa2f7"\n' >"$HOME/.local/state/omarchy/current/theme/colors.toml"

make_game() {
  mkdir -p "$vibes/$1"
  printf '<!doctype html><title>%s</title>\n' "$2" >"$vibes/$1/index.html"
}

make_game snake "Snake"
make_game tilt-maze 'Tilt </script><script>alert(1)</script>'
mkdir -p "$vibes/notes" "$vibes/Bad Name"
make_game "Bad Name" "Bad"

omarchy-games-vibes-install >/dev/null || fail "games vibes install lists the games"
games=$(sed -n 's:^const GAMES = \(.*\);$:\1:p' "$vibes/index.html" | sed 's/\\u003c/</g')
[[ $(jq -r '[.[].name] | join(" ")' <<<"$games") == "chess snake tilt-maze" ]] ||
  fail "the list has each game folder with an index.html, shipped or made here, and nothing else" "$games"
[[ $(jq -r '.[1].title' <<<"$games") == "Snake" ]] || fail "a game made here replaces the shipped game of its name" "$games"
[[ $(jq -r '.[2].title' <<<"$games") == 'Tilt </script><script>alert(1)</script>' ]] || fail "a game is listed by its <title>" "$games"
(( $(grep -c '</script>' "$vibes/index.html") == 1 )) || fail "a title can't end the list's script"
pass "Game Vibes lists the games in ~/Games/vibes by their titles"

: >"$OMARCHY_TEST_ARGV"
gio launch "$HOME/.local/share/applications/Game Vibes.desktop" >/dev/null 2>&1 || fail "the Game Vibes launcher starts"
for ((attempt = 0; attempt < 200; attempt++)); do
  [[ -s $OMARCHY_TEST_ARGV ]] && break
  sleep 0.01
done
url=$(head -1 "$OMARCHY_TEST_ARGV")
opened=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1].removeprefix("file://").split("#")[0]))' "$url")
[[ $opened == "$vibes/index.html" ]] || fail "Game Vibes opens the list of games" "$url"
accent=$(python3 -c 'import json, sys, urllib.parse; print(json.loads(urllib.parse.unquote(sys.argv[1].split("#palette=")[1]))["accent"])' "$url")
[[ $accent == "#7aa2f7" ]] || fail "Game Vibes opens in the current theme's palette" "$url"
pass "the one Game Vibes launcher opens the list in the current theme"

: >"$OMARCHY_TEST_ARGV"
omarchy-games-vibes-launch snake || fail "Game Vibes opens a game it lists"
[[ $(head -1 "$OMARCHY_TEST_ARGV") == *"#palette="*"&open=snake" ]] || fail "a game opens through the list, so Esc comes back to it" "$(head -1 "$OMARCHY_TEST_ARGV")"
! omarchy-games-vibes-launch notes 2>/dev/null || fail "Game Vibes refuses a folder that isn't a game"
! omarchy-games-vibes-launch ../vibes/snake 2>/dev/null || fail "Game Vibes refuses a path for a game"
pass "Game Vibes opens straight into a game when it's done"

omarchy-games-vibes-copy chess >/dev/null || fail "a shipped game copies into ~/Games/vibes"
[[ $(<"$vibes/chess/index.html") == *"<title>Chess</title>"* && -w $vibes/chess/index.html ]] || fail "the copy is the game, and can be changed"
! omarchy-games-vibes-copy chess 2>/dev/null || fail "a copy never replaces a game in ~/Games/vibes"
omarchy-games-vibes-copy snake snake-2 >/dev/null && [[ $(<"$vibes/snake-2/index.html") == *"<title>Snake</title>"* ]] ||
  fail "a game made here copies under a new name, from the user's own version"
pass "a game in Game Vibes copies into ~/Games/vibes to keep working on"
