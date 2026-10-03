#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/data/applications" "$tmp_dir/system/applications" "$tmp_dir/bin"

write_fake_command() {
  local name="$1"
  local prefix="$2"

  cat >"$tmp_dir/bin/$name" <<SCRIPT
#!/bin/bash
printf '%s:%s:%s\\n' '$prefix' "\${OMARCHY_REMOVE_NOTIFY:-}" "\$*" >>"\$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$name"
}

write_fake_command omarchy-webapp-remove web
write_fake_command omarchy-tui-remove tui
write_fake_command omarchy-launch-floating-terminal-with-presentation terminal

cat >"$tmp_dir/bin/omarchy-notification-send" <<'SCRIPT'
#!/bin/bash
printf 'notify::%s\n' "$*" >>"$TEST_LOG"
SCRIPT
chmod +x "$tmp_dir/bin/omarchy-notification-send"

cat >"$tmp_dir/bin/update-desktop-database" <<'SCRIPT'
#!/bin/bash
:
SCRIPT
chmod +x "$tmp_dir/bin/update-desktop-database"

cat >"$tmp_dir/bin/pacman" <<'SCRIPT'
#!/bin/bash
if [[ $1 == "-Qqo" && $2 == */native.desktop ]]; then
  printf 'native-pkg\n'
elif [[ $1 == "-Qqo" && $2 == */system/applications/firefox.desktop ]]; then
  printf 'firefox\n'
elif [[ $1 == "-Qq" && $2 == "spotify" ]]; then
  printf 'spotify\n'
else
  exit 1
fi
SCRIPT
chmod +x "$tmp_dir/bin/pacman"

cat >"$tmp_dir/data/applications/Basecamp.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Basecamp
Exec=omarchy-launch-webapp https://example.com
DESKTOP

cat >"$tmp_dir/data/applications/Docker.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Docker
Exec=xdg-terminal-exec --app-id=TUI.tile -e lazydocker
DESKTOP

cat >"$tmp_dir/system/applications/native.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Native
Exec=native
DESKTOP

cat >"$tmp_dir/data/applications/aliens.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Aliens
Exec=retroarch -L /usr/lib/libretro/fbneo_libretro.so /home/example/Games/roms/fbneo/aliens.zip
DESKTOP

# An Omarchy launcher wrapper names the package it fronts; a user's own launcher
# that happens to share a packaged app's desktop ID does not.
printf '[Desktop Entry]\nName=Spotify\nExec=omarchy-launch-spotify %%u\nX-Omarchy-Package=spotify\n' >"$tmp_dir/data/applications/spotify.desktop"
printf '[Desktop Entry]\nName=Firefox\nExec=firefox\n' >"$tmp_dir/system/applications/firefox.desktop"
printf '[Desktop Entry]\nName=Private Firefox\nExec=firefox --private-window\n' >"$tmp_dir/data/applications/firefox.desktop"

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_DATA_DIRS="$tmp_dir/system"

"$ROOT/bin/omarchy-remove-launcher-entry" Basecamp.desktop Basecamp
"$ROOT/bin/omarchy-remove-launcher-entry" Docker.desktop Docker
"$ROOT/bin/omarchy-remove-launcher-entry" native.desktop Native
"$ROOT/bin/omarchy-remove-launcher-entry" aliens.desktop Aliens
"$ROOT/bin/omarchy-remove-launcher-entry" spotify.desktop Spotify
"$ROOT/bin/omarchy-remove-launcher-entry" firefox.desktop "Private Firefox"

mapfile -t lines <"$TEST_LOG"

[[ ${lines[0]} == "web:false:Basecamp" ]] || fail "launcher remove routes web apps by desktop name" "${lines[0]}"
pass "launcher remove routes web apps by desktop name"

[[ ${lines[1]} == "tui:false:Docker" ]] || fail "launcher remove routes TUIs by desktop name" "${lines[1]}"
pass "launcher remove routes TUIs by desktop name"

[[ ${lines[2]} == "terminal::echo Uninstalling Native...; sudo pacman -Rns native-pkg" ]] || fail "launcher remove opens package uninstall flow" "${lines[2]}"
pass "launcher remove opens package uninstall flow"

[[ ! -e $tmp_dir/data/applications/aliens.desktop ]] || fail "launcher remove deletes user-owned desktop files"
pass "launcher remove deletes user-owned desktop files"

spotify_entry="$tmp_dir/data/applications/spotify.desktop"
uninstall="echo Uninstalling Spotify...; sudo pacman -Rns spotify && rm -f $spotify_entry && { update-desktop-database $tmp_dir/data/applications &>/dev/null || true; }"
[[ ${lines[3]:-} == "terminal::$uninstall" ]] || fail "launcher remove uninstalls the package an Omarchy wrapper names" "${lines[3]:-}"
pass "launcher remove uninstalls the package an Omarchy wrapper names"

[[ -e $spotify_entry ]] || fail "launcher remove keeps the wrapper until the uninstall succeeds"
pass "launcher remove keeps the wrapper until the uninstall succeeds"

# Run the uninstall the terminal would run, once failing and once succeeding.
printf '#!/bin/bash\nexit "${SUDO_STATUS:-0}"\n' >"$tmp_dir/bin/sudo"
chmod +x "$tmp_dir/bin/sudo"
SUDO_STATUS=1 bash -c "$uninstall" >/dev/null || true
[[ -e $spotify_entry ]] || fail "a cancelled uninstall leaves the wrapper in place"
pass "a cancelled uninstall leaves the wrapper in place"
SUDO_STATUS=0 bash -c "$uninstall" >/dev/null
[[ ! -e $spotify_entry ]] || fail "a finished uninstall removes the wrapper"
pass "a finished uninstall removes the wrapper"

[[ ! -e $tmp_dir/data/applications/firefox.desktop && -e $tmp_dir/system/applications/firefox.desktop ]] || fail "launcher remove only deletes a user launcher that shares a packaged app's ID"
pass "launcher remove only deletes a user launcher that shares a packaged app's ID"

(( ${#lines[@]} == 4 )) || fail "launcher remove does not notify for user-owned desktop files" "$(printf '%s\n' "${lines[@]}")"
pass "launcher remove does not notify for user-owned desktop files"
