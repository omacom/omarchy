#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command gio

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
stub_dir="$test_tmp/bin"
mkdir -p "$home/.local/share/applications" "$stub_dir"

cat >"$stub_dir/retroarch" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$RETRO_ARGV"
SH

cat >"$stub_dir/update-desktop-database" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_dir/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_dir/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s\n' "$*"
SH

chmod +x "$stub_dir/"*

core_path="$test_tmp/core\\\\with-backslashes\"and-percent%_libretro.so"
game_path=$(printf '%s/Rom\nExec=retro-injection-marker.sfc' "$test_tmp")
touch "$core_path" "$game_path"

HOME="$home" PATH="$stub_dir:$ROOT/bin:/usr/bin:/bin" RETRO_ARGV="$test_tmp/argv" \
  "$ROOT/bin/omarchy-games-retro-install" "$core_path" "$game_path" \
  >"$test_tmp/out" 2>"$test_tmp/err"

mapfile -t desktop_files < <(find "$home/.local/share/applications" -maxdepth 1 -name '*.desktop' -print)
(( ${#desktop_files[@]} == 1 )) || fail "retro install writes one desktop entry" "${desktop_files[*]}"
desktop_file=${desktop_files[0]}

(( $(grep -c '^Exec=' "$desktop_file") == 1 )) ||
  fail "retro desktop values cannot inject another Exec key" "$(cat "$desktop_file")"
pass "retro install escapes newlines in desktop string values"

: >"$test_tmp/argv"
RETRO_ARGV="$test_tmp/argv" PATH="$stub_dir:/usr/bin:/bin" gio launch "$desktop_file" >/dev/null 2>&1 ||
  fail "the escaped retro desktop entry remains launchable" "$(cat "$desktop_file")"

for ((attempt = 0; attempt < 200; attempt++)); do
  [[ -s $test_tmp/argv ]] && break
  sleep 0.01
done

mapfile -d '' -t argv <"$test_tmp/argv"
[[ ${argv[0]:-} == -L && ${argv[1]:-} == "$core_path" && ${argv[2]:-} == "$game_path" ]] ||
  fail "retro launcher preserves core and game paths as separate arguments" "$(printf '%q\n' "${argv[@]}")"
pass "retro install preserves quoted and backslash paths through the desktop launcher"
