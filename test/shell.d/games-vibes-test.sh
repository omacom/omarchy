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
printf '#!/bin/bash\n' >"$mock_bin/omarchy-notification-send"
chmod +x "$mock_bin/omarchy-notification-send"

# A home with a space and a percent sign, which the file URL has to survive.
export HOME="$test_tmp/my home 100%"
# An Omarchy that ships two games, one of which the user has a copy of.
export OMARCHY_PATH="$test_tmp/omarchy"
shipped="$OMARCHY_PATH/default/games/vibes"
mkdir -p "$shipped/chess" "$shipped/snake"
cp "$ROOT/default/games/vibes.html" "$OMARCHY_PATH/default/games/"
# Its launcher, as a fresh install and omarchy-refresh-applications put it.
mkdir -p "$OMARCHY_PATH/applications" "$HOME/.local/share/applications"
cp "$ROOT/applications/Game Vibes.desktop" "$OMARCHY_PATH/applications/"
cp "$ROOT/applications/Game Vibes.desktop" "$HOME/.local/share/applications/"
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
printf '<meta name="description" content="Eat & grow">\n' >>"$vibes/snake/index.html"
make_game tilt-maze 'Tilt </script><script>alert(1)</script>'
mkdir -p "$vibes/notes" "$vibes/Bad Name"
make_game "Bad Name" "Bad"

url=$(omarchy-games-vibes-launch --url) || fail "Game Vibes lists the games"
[[ $url == file://*"#palette="* && ! -s $OMARCHY_TEST_ARGV ]] || fail "--url prints the list's address and opens nothing" "$url"
games=$(sed -n 's:^const GAMES = \(.*\);$:\1:p' "$vibes/index.html" | sed 's/\\u003c/</g')
[[ $(jq -r '[.[].name] | join(" ")' <<<"$games") == "chess snake tilt-maze" ]] ||
  fail "the list has each game folder with an index.html, shipped or made here, and nothing else" "$games"
[[ $(jq -r '.[1].title' <<<"$games") == "Snake" ]] || fail "a game made here replaces the shipped game of its name" "$games"
[[ $(jq -r '.[1].blurb' <<<"$games") == "Eat & grow" && $(jq -r '.[0].blurb' <<<"$games") == "" ]] ||
  fail "a game's blurb is its description meta, and empty without one" "$games"
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
grep -q '^StartupWMClass=chrome-' "$HOME/.local/share/applications/Game Vibes.desktop" ||
  fail "opening Game Vibes gives its launcher this home's window class, for the dock"
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

# A shared game is a git repository with index.html at its root, and installs like a theme.
repo="$test_tmp/omarchy-Space_Rocks-game"
git init -q "$repo"
printf '<!doctype html><title>Space Rocks</title>\n' >"$repo/index.html"
ln -s /etc/passwd "$repo/secret"
git -C "$repo" add . && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm game
: >"$OMARCHY_TEST_ARGV"
omarchy-games-vibes-install "file://$repo" >/dev/null 2>&1 || fail "a game installs from a git repository"
[[ -f $vibes/space-rocks/index.html && ! -e $vibes/space-rocks/secret && ! -L $vibes/space-rocks/secret ]] ||
  fail "the game is named after its repository, without the repository's symlinks"
[[ $(head -1 "$OMARCHY_TEST_ARGV") == *"&open=space-rocks" ]] || fail "an installed game opens in Game Vibes"
omarchy-games-vibes-install "file://$repo" >/dev/null 2>&1 || fail "installing again replaces the copy from the same repository"
git -C "$repo" rm -q index.html && git -C "$repo" -c user.name=t -c user.email=t@t commit -qm broken
! omarchy-games-vibes-install "file://$repo" >/dev/null 2>&1 && [[ -f $vibes/space-rocks/index.html ]] ||
  fail "a reinstall that fails leaves the game that was there"
[[ -z $(find "$vibes" -maxdepth 1 -type d -name '.install.*') ]] || fail "a failed install leaves nothing behind"

git init -q "$test_tmp/snake" && printf '<!doctype html><title>Other Snake</title>\n' >"$test_tmp/snake/index.html" && git -C "$test_tmp/snake" add . &&
  git -C "$test_tmp/snake" -c user.name=t -c user.email=t@t commit -qm game
! omarchy-games-vibes-install "file://$test_tmp/snake" >/dev/null 2>&1 || fail "installing never replaces a game made here"
[[ $(<"$vibes/snake/index.html") == *"<title>Snake</title>"* ]] || fail "the game made here is untouched"

git init -q "$test_tmp/empty-game" && git -C "$test_tmp/empty-game" -c user.name=t -c user.email=t@t commit -qm none --allow-empty
! omarchy-games-vibes-install "file://$test_tmp/empty-game" >/dev/null 2>&1 && [[ ! -e $vibes/empty ]] ||
  fail "a repository without an index.html is not installed"
pass "a shared game installs from its git repository, like a theme"

omarchy-games-vibes-remove space-rocks >/dev/null || fail "an installed game is removed"
[[ ! -e $vibes/space-rocks ]] || fail "removing a game deletes its folder"
! omarchy-games-vibes-remove ../vibes >/dev/null 2>&1 || fail "remove refuses a path"
! omarchy-games-vibes-remove chess-shipped >/dev/null 2>&1 || fail "remove refuses a game that isn't there"
pass "a game is removed from ~/Games/vibes by name"
