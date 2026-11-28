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
if [[ $1 == "-Qqo" ]]; then
  shift
  [[ ${1:-} == "--" ]] && shift
  if [[ ${1:-} == */native.desktop ]]; then
    printf 'native-pkg\n'
  fi
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

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export XDG_DATA_HOME="$tmp_dir/data"
export XDG_DATA_DIRS="$tmp_dir/system"

"$ROOT/bin/omarchy-remove-launcher-entry" Basecamp.desktop Basecamp
"$ROOT/bin/omarchy-remove-launcher-entry" Docker.desktop Docker
native_output="$("$ROOT/bin/omarchy-remove-launcher-entry" native.desktop Native)"
aliens_output="$("$ROOT/bin/omarchy-remove-launcher-entry" aliens.desktop Aliens)"

# The uninstall terminal is left running on its own, so its log line lands
# after the command returns.
for _ in {1..50}; do
  grep -q '^terminal:' "$TEST_LOG" && break
  sleep 0.1
done

mapfile -t lines <"$TEST_LOG"

[[ ${lines[0]} == "web:false:Basecamp" ]] || fail "launcher remove routes web apps by desktop name" "${lines[0]}"
pass "launcher remove routes web apps by desktop name"

[[ ${lines[1]} == "tui:false:Docker" ]] || fail "launcher remove routes TUIs by desktop name" "${lines[1]}"
pass "launcher remove routes TUIs by desktop name"

[[ ${lines[2]} == "terminal::echo Uninstalling Native...; sudo pacman -Rns native-pkg" ]] || fail "launcher remove opens package uninstall flow" "${lines[2]}"
pass "launcher remove opens package uninstall flow"

[[ $native_output == "terminal" ]] || fail "launcher remove announces an uninstall that needs a terminal" "$native_output"
pass "launcher remove announces an uninstall that needs a terminal"

[[ -z $aliens_output ]] || fail "launcher remove deletes user-owned desktop files without a terminal" "$aliens_output"
pass "launcher remove deletes user-owned desktop files without a terminal"

[[ ! -e $tmp_dir/data/applications/aliens.desktop ]] || fail "launcher remove deletes user-owned desktop files"
pass "launcher remove deletes user-owned desktop files"

(( ${#lines[@]} == 3 )) || fail "launcher remove does not notify for user-owned desktop files" "$(printf '%s\n' "${lines[@]}")"
pass "launcher remove does not notify for user-owned desktop files"

# Traversal or option-shaped desktop IDs must be rejected before resolving paths.
cat >"$tmp_dir/data/escaped.desktop" <<'DESKTOP'
[Desktop Entry]
Name=Escaped
Exec=omarchy-launch-webapp https://example.com
DESKTOP

for bad_id in "../escaped.desktop" "/etc/passwd" "-rf.desktop" ".."; do
  if "$ROOT/bin/omarchy-remove-launcher-entry" "$bad_id" Bad >/dev/null 2>&1; then
    fail "launcher remove rejects unsafe desktop id: $bad_id"
  fi
done
[[ -f $tmp_dir/data/escaped.desktop ]] || fail "launcher remove leaves files outside applications/ untouched"
(( ${#lines[@]} == $(wc -l <"$TEST_LOG") )) || fail "rejected desktop IDs do not dispatch removal commands"
pass "launcher remove rejects traversal and option-shaped desktop IDs"
