#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

unset XDG_CACHE_HOME
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# A scratch Omarchy root whose other intros are hosted locally in the same layout.
omarchy_root="$test_tmp/omarchy"
host="$test_tmp/host"
fetch_home="$test_tmp/home"
cache_root="$fetch_home/.cache/omarchy/background-intros"
host_url="file://$host"
cache="$cache_root/${host_url//[^A-Za-z0-9._-]/_}"
current="$fetch_home/.local/state/omarchy/current"
backgrounds="$omarchy_root/themes/retro/backgrounds"
hosted="$host/themes/retro/backgrounds/intros"
mkdir -p "$omarchy_root/bin" "$backgrounds/intros" "$hosted" "$current/theme"
cp "$ROOT/bin/omarchy-theme-bg-boot-intro" "$omarchy_root/bin/"
printf 'default still\n' >"$backgrounds/1-groove.webp"
printf 'default intro\n' >"$backgrounds/intros/1-groove.mp4"
printf 'groove remote\n' >"$hosted/1-groove.mp4"
printf 'dusk still\n' >"$backgrounds/2-dusk.webp"
printf 'dusk intro\n' >"$hosted/2-dusk.mp4"
cp -r "$backgrounds" "$current/theme/"
dusk="$current/theme/backgrounds/2-dusk.webp"
cached="$cache/themes/retro/backgrounds/intros/2-dusk.mp4"
ln -s "$dusk" "$current/background"

intro() {
  HOME="$fetch_home" OMARCHY_PATH="$omarchy_root" OMARCHY_BACKGROUND_INTROS_URL="file://$host" \
    "$omarchy_root/bin/omarchy-theme-bg-boot-intro" "$@"
}

[[ -z $(intro --resolve-only) ]] || fail "a wallpaper whose intro is not downloaded yet shows its still"
intro --fetch "$dusk"
[[ $(intro --resolve-only) == "$cached" ]] || fail "a downloaded intro plays for its wallpaper" "$(intro --resolve-only)"
[[ $(<"$cached") == "dusk intro" ]] || fail "the downloaded file is the hosted intro"
pass "a chosen wallpaper's intro downloads and then resolves from the cache"

staged="$test_tmp/next-theme"
mkdir -p "$staged"
cp -r "$current/theme/backgrounds" "$staged/"
[[ $(intro --resolve-only "$staged/backgrounds/2-dusk.webp") == "$cached" ]] || fail "a staged theme copy finds the downloaded intro"
pass "theme switches resolve downloaded intros through the staged copy"

groove="$current/theme/backgrounds/1-groove.webp"
intro --fetch "$groove"
[[ ! -e $cache/themes/retro/backgrounds/intros/1-groove.mp4 ]] || fail "a wallpaper with a shipped intro downloads nothing"
[[ $(intro --resolve-only "$groove") == "$current/theme/backgrounds/intros/1-groove.mp4" ]] || fail "the shipped intro wins"
pass "the theme's shipped default intro is used as before"

rm -rf "$cache_root"
for own in "$fetch_home/.config/omarchy/backgrounds/retro/2-dusk.webp" "$fetch_home/.config/omarchy/themes/retro/backgrounds/2-dusk.webp" \
  "$fetch_home/.config/omarchy/themes/community/backgrounds/3-sea.webp"; do
  mkdir -p "${own%/*}"
  printf 'my own picture\n' >"$own"
  intro --fetch "$own"
  [[ ! -e $cache_root ]] || fail "$own asks the host for nothing"
done
pass "only the very wallpapers Omarchy ships ask the host for an intro"

mkdir -p "$fetch_home/.local/state/omarchy/toggles"
touch "$fetch_home/.local/state/omarchy/toggles/background-intros-off"
intro --fetch "$dusk"
[[ ! -e $cached ]] || fail "disabled intros download nothing"
rm "$fetch_home/.local/state/omarchy/toggles/background-intros-off"
animations_bin="$test_tmp/animations-off"
mkdir -p "$animations_bin"
cat >"$animations_bin/hyprctl" <<'SH'
#!/bin/bash
printf '{"option":"animations:enabled","int":0,"bool":false}\n'
SH
chmod +x "$animations_bin/hyprctl"
PATH="$animations_bin:$PATH" intro --fetch "$dusk"
[[ ! -e $cached ]] || fail "disabled animations download nothing"
pass "the intro toggle and disabled animations stop downloads"

rm -rf "$cache_root"
mv "$hosted/2-dusk.mp4" "$test_tmp/2-dusk.mp4"
intro --fetch "$dusk" 2>/dev/null
[[ ! -e $cached && -z $(intro --resolve-only) ]] || fail "a wallpaper the host has no intro for keeps its still"
[[ -z $(find "$cache" -name '.intro.*') ]] || fail "a failed download leaves no partial file"
mv "$test_tmp/2-dusk.mp4" "$hosted/2-dusk.mp4"
intro --fetch "$dusk"
[[ ! -e $cached ]] || fail "the host is asked once for a wallpaper it has no intro for"
pass "a wallpaper without a hosted intro keeps its still and is asked for once"

mirror="$test_tmp/mirror"
mkdir -p "$mirror/themes/retro/backgrounds/intros"
printf 'dusk intro v2\n' >"$mirror/themes/retro/backgrounds/intros/2-dusk.mp4"
HOME="$fetch_home" OMARCHY_PATH="$omarchy_root" OMARCHY_BACKGROUND_INTROS_URL="file://$mirror" "$omarchy_root/bin/omarchy-theme-bg-boot-intro" --fetch "$dusk"
mirror_url="file://$mirror"
mirror_cached="$cache_root/${mirror_url//[^A-Za-z0-9._-]/_}/themes/retro/backgrounds/intros/2-dusk.mp4"
[[ $(<"$mirror_cached") == "dusk intro v2" ]] || fail "the download location can be overridden"
[[ ! -e $cache ]] || fail "intros cached from another host or commit are removed"
pass "the download location is configurable and a new commit replaces the old intros"

rm -rf "$cache_root"
gate_bin="$test_tmp/gate-bin"
mkdir -p "$gate_bin"
cat >"$gate_bin/curl" <<'SH'
#!/bin/bash
printf 'curl\n' >>"$CURL_LOG"
touch "$CURL_GATE.entered"
while [[ ! -f $CURL_GATE ]]; do sleep 0.01; done
exec /usr/bin/curl "$@"
SH
chmod +x "$gate_bin/curl"
export CURL_LOG="$test_tmp/curl.log" CURL_GATE="$test_tmp/curl-gate"
PATH="$gate_bin:$PATH" intro --fetch "$dusk" &
first=$!
for _ in {1..300}; do
  [[ -f $CURL_GATE.entered ]] && break
  sleep 0.01
done
PATH="$gate_bin:$PATH" intro --fetch "$dusk" &
second=$!
for _ in {1..100}; do
  kill -0 "$second" 2>/dev/null || break
  sleep 0.01
done
touch "$CURL_GATE"
wait "$first" "$second"
[[ $(wc -l <"$CURL_LOG") == 1 && -f $cached ]] || fail "choosing a wallpaper again during its download starts no second download"
pass "overlapping choices of one wallpaper share its download"

rm -rf "$cache_root"
XDG_CACHE_HOME="$test_tmp/xdg" intro --fetch "$dusk"
[[ -f $test_tmp/xdg/${cached#"$fetch_home/.cache/"} && ! -e $cache_root ]] || fail "intros download into XDG_CACHE_HOME when it is set"
[[ $(XDG_CACHE_HOME="$test_tmp/xdg" intro --resolve-only) == "$test_tmp/xdg/${cached#"$fetch_home/.cache/"}" ]] || fail "intros resolve from XDG_CACHE_HOME"
pass "downloaded intros follow XDG_CACHE_HOME"

command_bin="$test_tmp/bin"
mkdir -p "$command_bin"
printf '#!/bin/bash\n' >"$command_bin/omarchy-shell"
ln -s "$omarchy_root/bin/omarchy-theme-bg-boot-intro" "$command_bin/omarchy-theme-bg-boot-intro"
chmod +x "$command_bin/omarchy-shell"
rm "$current/background"
PATH="$command_bin:$PATH" HOME="$fetch_home" OMARCHY_PATH="$omarchy_root" OMARCHY_BACKGROUND_INTROS_URL="file://$host" "$ROOT/bin/omarchy-theme-bg-set" "$dusk"
for _ in {1..50}; do
  [[ -f $cached ]] && break
  sleep 0.1
done
[[ -f $cached ]] || fail "choosing a wallpaper downloads its intro"
pass "choosing a wallpaper downloads its intro in the background"
