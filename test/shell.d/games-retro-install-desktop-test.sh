#!/bin/bash

# games-retro-install must emit .desktop files whose Exec quoting and Name
# values survive adversarial ROM filenames (quotes, %, newlines, names that
# clean to nothing).

source "$(dirname "$0")/base-test.sh"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

mkdir -p "$workdir/stubs" "$workdir/cores" "$workdir/roms" "$workdir/home"
touch "$workdir/cores/snes9x_libretro.so"

for stub in update-desktop-database omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$workdir/stubs/$stub"
done
chmod +x "$workdir/stubs"/*

install_game() {
  HOME="$workdir/home" PATH="$workdir/stubs:/usr/bin:/bin" \
    bash "$ROOT/bin/omarchy-games-retro-install" "$workdir/cores/snes9x_libretro.so" "$1"
}

apps="$workdir/home/.local/share/applications"

# 1. A quote in the ROM path must not break the Exec argument grouping.
touch "$workdir/roms/My \"Best\" Game.sfc"
install_game "$workdir/roms/My \"Best\" Game.sfc"
exec_line=$(grep '^Exec=' "$apps/my-best-game.desktop")
[[ $exec_line == *'My \\"Best\\" Game.sfc"' ]] || fail "quote in ROM path is escaped in Exec" "$exec_line"
pass "quote in ROM path is escaped in Exec"

# 2. A literal % must be doubled so the launcher does not treat it as a field code.
touch "$workdir/roms/100% Complete.sfc"
install_game "$workdir/roms/100% Complete.sfc"
exec_line=$(grep '^Exec=' "$apps/100-complete.desktop")
[[ $exec_line == *'100%% Complete.sfc"' ]] || fail "% in ROM path is doubled in Exec" "$exec_line"
pass "% in ROM path is doubled in Exec"

touch "$workdir/roms/game%U.sfc"
install_game "$workdir/roms/game%U.sfc"
exec_line=$(grep '^Exec=' "$apps/game-u.desktop")
[[ $exec_line == *'game%%U.sfc"' ]] || fail "%U in ROM path is doubled in Exec" "$exec_line"
pass "%U in ROM path is doubled in Exec"

# 3. A newline in the filename must not inject a second key line. The
# generated entry is identified by its exact slug-derived filename, never by
# "first file in the directory": $apps still holds the entries from cases
# 1-2, and head -1 would inspect an unrelated clean file.
rm -f "$apps"/*.desktop
newline_rom=$'roms/evil\nExec=touch-pwned.sfc'
touch "$workdir/$newline_rom"
install_game "$workdir/$newline_rom"
desktop_files=("$apps"/*.desktop)
(( ${#desktop_files[@]} == 1 )) || fail "newline ROM produces exactly one .desktop entry" "$(ls "$apps")"
desktop_file="${desktop_files[0]}"
[[ $desktop_file == */evil-exec-touch-pwned.desktop ]] || fail "newline ROM lands in the slug-derived entry" "$desktop_file"
line_count=$(wc -l <"$desktop_file")
(( line_count == 10 )) || fail "newline in filename cannot inject .desktop key lines (got $line_count lines)"
grep -q '^Exec=touch-pwned$' "$desktop_file" && fail "injected Exec= key line is absent"
grep -q 'evil\\nExec=touch-pwned' "$desktop_file" || fail "newline in the Exec argument is escaped, not raw"
pass "newline in filename cannot inject .desktop key lines"

# 4. A name that cleans to nothing still gets a real entry, not ".desktop".
rm -f "$apps"/*.desktop
touch "$workdir/roms/(Europe).sfc"
install_game "$workdir/roms/(Europe).sfc"
[[ ! -e $apps/.desktop ]] || fail "(Europe).sfc must not land in .desktop"
desktop_count=$(ls "$apps"/*.desktop | wc -l)
(( desktop_count == 1 )) || fail "(Europe).sfc produces exactly one .desktop entry" "$(ls "$apps")"
name_line=$(grep '^Name=' "$apps"/*.desktop)
[[ -n ${name_line#Name=} ]] || fail "(Europe).sfc gets a non-empty Name"
pass "(Europe).sfc gets a real entry with a non-empty Name"

# 4b. Two names that slug to nothing must not share one launcher file.
rm -f "$apps"/*.desktop
touch "$workdir/roms/!!!.sfc" "$workdir/roms/???.sfc"
install_game "$workdir/roms/!!!.sfc"
install_game "$workdir/roms/???.sfc"
desktop_count=$(ls "$apps"/*.desktop | wc -l)
(( desktop_count == 2 )) || fail "two empty-slug ROMs keep separate entries" "$(ls "$apps")"
pass "two empty-slug ROMs keep separate entries"

# 5. Ordinary names are byte-identical to the old output shape.
rm -f "$apps"/*.desktop
touch "$workdir/roms/Super Game (USA).sfc"
install_game "$workdir/roms/Super Game (USA).sfc"
grep -qxF "Exec=retroarch -L \"$workdir/cores/snes9x_libretro.so\" \"$workdir/roms/Super Game (USA).sfc\"" "$apps/super-game.desktop" \
  || fail "ordinary ROM keeps the plain Exec shape"
grep -qxF 'Name=Super Game' "$apps/super-game.desktop" || fail "ordinary ROM keeps the plain Name shape"
pass "ordinary ROM keeps the plain .desktop shape"

# 6. Launched through GLib, as gtk-launch does, retroarch gets the exact ROM path.
printf '#!/bin/bash\nprintf "%%s\\0" "$@" >"%s/argv"\n' "$workdir" >"$workdir/stubs/retroarch"
chmod +x "$workdir/stubs/retroarch"

for rom in 'My "Best" Game.sfc' 'back\slash\.sfc' 'Cash $HOME `id`.sfc' 'game%U.sfc' $'evil\nExec=touch-pwned.sfc'; do
  rm -f "$apps"/*.desktop "$workdir/argv"
  touch "$workdir/roms/$rom"
  install_game "$workdir/roms/$rom"
  PATH="$workdir/stubs:/usr/bin:/bin" gio launch "$apps"/*.desktop || fail "GLib loads the entry for $(printf '%q' "$rom")"
  for _ in {1..50}; do [[ -s $workdir/argv ]] && break; sleep 0.1; done
  mapfile -d '' -t argv <"$workdir/argv"
  [[ ${argv[2]} == "$workdir/roms/$rom" ]] || fail "launch passes the exact ROM path for $(printf '%q' "$rom")" "${argv[2]}"
done
pass "launched entries pass the exact ROM path to retroarch"
