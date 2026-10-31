#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# Physical, since the install writes the canonical game path.
test_tmp=$(cd "$(mktemp -d)" && pwd -P)
trap 'rm -rf "$test_tmp"' EXIT

test_home="$test_tmp/home"
stub_bin="$test_tmp/bin"
mkdir -p "$test_home" "$stub_bin"

for stub in omarchy-notification-send update-desktop-database; do
  printf '#!/bin/bash\n:\n' >"$stub_bin/$stub"
  chmod +x "$stub_bin/$stub"
done

core="$test_tmp/mgba_libretro.so"
printf 'core\n' >"$core"

run_install() {
  HOME="$test_home" PATH="$stub_bin:/usr/bin" \
    "$ROOT/bin/omarchy-games-retro-install" "$core" "$1"
}

# A newline in a game file name used to become a new key line in the launcher
# entry. A name like this one would add a key of its own to the file.
game="$test_tmp/"$'pwn\nX-Omarchy-Hole=injected.sfc'
printf 'rom\n' >"$game"

run_install "$game" >/dev/null 2>&1 || true

desktop_file="$test_home/.local/share/applications/pwn-x-omarchy-hole-injected.desktop"
[[ -f $desktop_file ]] || fail "retro-install writes a desktop entry for the game"

if grep -q '^X-Omarchy-Hole=' "$desktop_file"; then
  fail "retro-install keeps a newline in a name from adding a key line"
fi
grep -qF 'Name=Pwn\nX-Omarchy-Hole=injected' "$desktop_file" ||
  fail "retro-install keeps a name with a newline on one escaped line"
grep -q "^Exec=retroarch -L " "$desktop_file" ||
  fail "retro-install keeps the Exec line whole when the path holds a newline"
pass "retro-install escapes a newline in a game name instead of adding a key line"

# A double quote in a file name used to step outside its quoted Exec argument.
game="$test_tmp/"$'qu"ote.sfc'
printf 'rom\n' >"$game"

run_install "$game" >/dev/null 2>&1 || true

desktop_file="$test_home/.local/share/applications/qu-ote.desktop"
[[ -f $desktop_file ]] || fail "retro-install writes a desktop entry for the game"
grep '^Exec=' "$desktop_file" | grep -qF 'qu\\"ote.sfc"' ||
  fail "retro-install escapes a double quote in a game path on the Exec line"
pass "retro-install keeps a double quote inside its Exec argument"

# A plain game keeps the same entry this command always wrote.
game="$test_tmp/Zelda.sfc"
printf 'rom\n' >"$game"

run_install "$game" >/dev/null 2>&1 || true

desktop_file="$test_home/.local/share/applications/zelda.desktop"
[[ -f $desktop_file ]] || fail "retro-install writes a desktop entry for a plain game"
grep -qF 'Name=Zelda' "$desktop_file" ||
  fail "retro-install writes the plain name"
grep -qF "Exec=retroarch -L \"$core\" \"$game\"" "$desktop_file" ||
  fail "retro-install writes the same Exec line as before for plain paths"
pass "retro-install writes the same entry as before for a plain game"

apps="$test_home/.local/share/applications"

# A name that cleans to nothing used to write a launcher called ".desktop".
rm -f "$apps"/*.desktop
game="$test_tmp/(Europe).sfc"
printf 'rom\n' >"$game"
run_install "$game" >/dev/null 2>&1 || fail "retro-install installs a game whose name cleans to nothing"
[[ ! -e $apps/.desktop ]] || fail "retro-install never writes a launcher called .desktop"
grep -qxF 'Name=(Europe).sfc' "$apps/europe-sfc.desktop" ||
  fail "retro-install names a game that cleans to nothing after its file"
pass "retro-install keeps the file name for a game whose name cleans to nothing"

# Names with no ASCII letters or digits used to share one launcher file. Punctuation
# slugs to nothing in any locale, as a Japanese title does under a UTF-8 one.
rm -f "$apps"/*.desktop
for game in "$test_tmp/!!!.sfc" "$test_tmp/???.sfc"; do
  printf 'rom\n' >"$game"
  run_install "$game" >/dev/null 2>&1 || fail "retro-install installs $game"
done
launchers=("$apps"/retro-game-*.desktop)
(( ${#launchers[@]} == 2 )) || fail "retro-install gives each unsluggable game its own launcher" "$(ls "$apps")"
pass "retro-install gives each unsluggable game its own launcher"

# A relative path used to land in Exec as written, so the launcher only worked
# from the directory the install ran in.
rm -f "$apps"/*.desktop
mkdir -p "$test_tmp/roms"
printf 'rom\n' >"$test_tmp/roms/Metroid.sfc"
(cd "$test_tmp" && run_install "roms/Metroid.sfc" >/dev/null 2>&1) || fail "retro-install installs a game given by a relative path"
grep -qxF "Exec=retroarch -L \"$core\" \"$test_tmp/roms/Metroid.sfc\"" "$apps/metroid.desktop" ||
  fail "retro-install writes the absolute game path for a relative one" "$(grep '^Exec=' "$apps/metroid.desktop" 2>&1)"
pass "retro-install writes the absolute game path for a relative one"

# What counts is what the launcher hands retroarch, so start each entry through
# GLib, as the app launcher does, and compare the argv a stub records.
require_command gio

printf '#!/bin/bash\nprintf "%%s\\0" "$@" >"%s/argv"\n' "$test_tmp" >"$stub_bin/retroarch"
chmod +x "$stub_bin/retroarch"

for name in 'My "Best" Game.sfc' 'back\slash\.sfc' 'Cash $HOME `id`.sfc' '100% game%U.sfc' $'evil\nExec=touch pwned.sfc' $'trailing-newline.sfc\n'; do
  rm -f "$apps"/*.desktop "$test_tmp/argv"
  game="$test_tmp/roms/$name"
  printf 'rom\n' >"$game"
  run_install "$game" >/dev/null 2>&1 || fail "retro-install installs $(printf '%q' "$name")"
  launchers=("$apps"/*.desktop)
  PATH="$stub_bin:/usr/bin" gio launch "${launchers[0]}" >/dev/null 2>&1 ||
    fail "GLib loads the launcher for $(printf '%q' "$name")"
  for _ in {1..100}; do
    [[ -s $test_tmp/argv ]] && break
    sleep 0.05
  done
  [[ -s $test_tmp/argv ]] || fail "the launcher for $(printf '%q' "$name") starts retroarch"
  mapfile -d '' -t argv <"$test_tmp/argv"
  (( ${#argv[@]} == 3 )) && [[ ${argv[0]} == "-L" && ${argv[1]} == "$core" && ${argv[2]} == "$game" ]] ||
    fail "the launcher hands retroarch the exact game path for $(printf '%q' "$name")" "$(printf '%q ' "${argv[@]}")"
done
[[ ! -e $test_tmp/pwned.sfc && ! -e pwned.sfc ]] || fail "a launcher runs nothing but retroarch"
pass "every launcher hands retroarch the exact game path"
