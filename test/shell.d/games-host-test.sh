#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command magick

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"
cat >"$mock_bin/tailscale" <<'SH'
#!/bin/bash
case "$*" in
  "status --self --json") echo '{"BackendState":"Running","Self":{"DNSName":"box.example.ts.net."}}' ;;
  "serve status --json") echo '{"TCP":{"443":{"HTTPS":true},"8443":{"HTTPS":true}}}' ;;
esac
SH
cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_UNIT"
SH
cat >"$mock_bin/systemctl" <<'SH'
#!/bin/bash
exit 3
SH
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/curl"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/ss"
chmod +x "$mock_bin"/*

export HOME="$test_tmp/home"
export OMARCHY_PATH="$ROOT"
export PATH="$mock_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_UNIT="$test_tmp/unit"
site="$HOME/.cache/omarchy/games-host"

mkdir -p "$HOME/Games/mine" "$HOME/.local/state/omarchy/current/theme"
printf 'accent = "#7aa2f7"\nbackground = "#1a1b26"\nforeground = "#a9b1d6"\n' >"$HOME/.local/state/omarchy/current/theme/colors.toml"
printf '<!doctype html><title>Mine &amp; Yours</title>\n' >"$HOME/Games/mine/index.html"
printf '<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64"><rect width="64" height="64" fill="#7aa2f7"/></svg>\n' >"$HOME/Games/mine/icon.svg"
printf 'private\n' >"$HOME/Games/mine/notes.txt"

! omarchy-games-host --port 8443 >/dev/null 2>&1 || fail "games host refuses a port the tailnet already serves"
[[ ! -e $OMARCHY_TEST_UNIT ]] || fail "nothing is started on a port that is taken"
pass "games host leaves a port that already serves something alone"

omarchy-games-host >"$test_tmp/out" || fail "games host starts" "$(cat "$test_tmp/out")"
grep -qF "https://box.example.ts.net:7443/" "$test_tmp/out" || fail "games host says where the games are" "$(cat "$test_tmp/out")"
[[ -f $site/mine/index.html && -f $site/mine/icon.svg && -f $site/chess/index.html ]] ||
  fail "the site has the user's games and the ones Omarchy ships"
[[ -z $(find "$site" -type f ! -name index.html ! -name 'icon.*' ! -name favicon.ico) ]] ||
  fail "the site holds only playable pages and icons" "$(find "$site" -type f)"
grep -q 'href="mine/#palette=' "$site/index.html" && grep -qF 'Mine &amp; Yours' "$site/index.html" ||
  fail "the lobby links each game by its title, opened in the host's theme"
pass "games host builds a lobby of playable copies and icons, and nothing else from a game's folder"

grep -qF 'tailscale serve --https="$3" "http://127.0.0.1:$1" &' "$OMARCHY_TEST_UNIT" && grep -qF 'wait -n' "$OMARCHY_TEST_UNIT" &&
  grep -qx -- '--property=PartOf=graphical-session.target' "$OMARCHY_TEST_UNIT" &&
  grep -qx '7444' "$OMARCHY_TEST_UNIT" && grep -qx '7443' "$OMARCHY_TEST_UNIT" && grep -qxF "$site" "$OMARCHY_TEST_UNIT" ||
  fail "games host serves the site from 127.0.0.1 through tailscale serve in one unit" "$(cat "$OMARCHY_TEST_UNIT")"
pass "games host runs its server and tailscale serve together for the session, so either ending withdraws both"

printf '#!/bin/bash\nexit 7\n' >"$mock_bin/curl"
printf '#!/bin/bash\necho "To enable HTTPS, visit the admin console"\n' >"$mock_bin/journalctl"
chmod +x "$mock_bin/curl" "$mock_bin/journalctl"
! omarchy-games-host >"$test_tmp/out" 2>&1 || fail "games host fails when the games never come up"
grep -qF "To enable HTTPS" "$test_tmp/out" || fail "a failed start shows what the host said" "$(cat "$test_tmp/out")"
pass "games host fails, and says why, when the games never come up"
