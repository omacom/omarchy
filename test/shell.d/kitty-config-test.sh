#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
kitty_config="$test_home/.config/kitty/kitty.conf"
mkdir -p "$(dirname "$kitty_config")" "$test_dir/bin"

# Exercise the real font commands without changing the running desktop.
for command in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/kitty"
cat >"$test_dir/bin/gsettings" <<'SH'
#!/bin/bash
if [[ $1 == "get" ]]; then
  if [[ $3 == "font-name" ]]; then
    echo "'Sans 11'"
  else
    echo 1.0
  fi
fi
SH
chmod +x "$test_dir/bin/"*

run_command() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/$@"
}

cp "$ROOT/config/kitty/kitty.conf" "$kitty_config"
output=$(run_command omarchy-display-text-size)
[[ $output == *"terminal font: 9 pt"* ]] || fail "size report accounts for inherited Kitty default"
run_command omarchy-font-set 'Test Font'
run_command omarchy-display-text-size 16
grep -qx 'font_family Test Font' "$kitty_config" || fail "font command creates family override"
run_command omarchy-font-set Font
grep -qx 'font_family Font' "$kitty_config" || fail "font command updates family override"
[[ $(grep -c '^font_family ' "$kitty_config") == "1" ]] || fail "font update avoids duplicate overrides"
grep -qx 'font_size 12.0' "$kitty_config" || fail "size command creates size override"
grep -qx '# font_size 12' "$kitty_config" || fail "font commands keep commented instructions"
run_command omarchy-display-text-size 18
[[ $(grep -c '^font_size ' "$kitty_config") == "1" ]] || fail "size update avoids duplicate overrides"
run_command omarchy-display-text-size reset
grep -qx 'font_size 9.0' "$kitty_config" || fail "size reset restores default"
pass "font controls add and update overrides in the minimal template"

rm "$kitty_config"
output=$(run_command omarchy-display-text-size)
[[ $output == *"terminal font: 9 pt"* ]] || fail "size report handles absent Kitty config"
run_command omarchy-font-set 'Test Font'
run_command omarchy-display-text-size 16
grep -qx 'font_family Test Font' "$kitty_config" || fail "font command handles absent config"
grep -qx 'font_size 12.0' "$kitty_config" || fail "size command handles absent setting"
! grep -q '^include ' "$kitty_config" || fail "font controls must not opt users back into theming"
rm "$kitty_config"
run_command omarchy-display-text-size 16
grep -qx 'font_size 12.0' "$kitty_config" || fail "size command handles absent config"
pass "font controls create missing Kitty overrides without restoring the theme include"

# try-omarchy VMs put a wrapper named kitty on PATH that exits 127 until Kitty
# is installed, so a command on PATH is not enough: ask Kitty itself.
if "$ROOT/bin/omarchy-cmd-present" kitty && kitty --version >/dev/null 2>&1; then
  kitty +runpy "$(cat "$ROOT/test/shell.d/fixtures/kitty/check-config.py")"
else
  skip "Kitty not installed; skipping native config parser checks"
fi

# The regional default must not reach the live session, even when terminals
# are visible from the install chroot. Keep the real setter and record IPC.
export OMARCHY_TEST_SESSION_LOG="$test_dir/session-log"
for command in pkill pgrep omarchy-restart-shell omarchy-notification-send; do
  cat >"$test_dir/bin/$command" <<'SH'
#!/bin/bash
printf '%s\n' "${0##*/} $*" >>"$OMARCHY_TEST_SESSION_LOG"
SH
done
cat >"$test_dir/bin/fc-list" <<'SH'
#!/bin/bash
printf '%s\n' "${OMARCHY_TEST_FONTS:-Test Font}"
SH

for terminal in alacritty foot ghostty; do
  mkdir -p "$test_home/.config/$terminal"
  cp "$ROOT/config/$terminal/"* "$test_home/.config/$terminal/"
done

before=$(tar -C "$test_home" -cf - .config | sha256sum)
OMARCHY_TEST_FONTS='Maple Mono NF CN Extra' run_command omarchy-region-font cn
OMARCHY_TEST_FONTS='Maple Mono NF CN' run_command omarchy-region-font us
[[ $(tar -C "$test_home" -cf - .config | sha256sum) == "$before" ]] || fail "missing exact font or profile leaves all font settings alone"
pass "a fallback or partial font match never replaces the user's font"

for context in iso-chroot provision-owner; do
  OMARCHY_TEST_FONTS='Maple Mono NF CN,Maple Mono' OMARCHY_SETUP_CONTEXT="$context" run_command omarchy-region-font cn
  grep -qx 'font_family Maple Mono NF CN' "$kitty_config" || fail "regional font reaches Kitty"
  grep -qx 'font=Maple Mono NF CN:size=9' "$test_home/.config/foot/foot.ini" || fail "regional font reaches foot"
  grep -qF 'family = "Maple Mono NF CN"' "$test_home/.config/alacritty/alacritty.toml" || fail "regional font reaches Alacritty"
  grep -qx 'font-family = "Maple Mono NF CN"' "$test_home/.config/ghostty/config" || fail "regional font reaches Ghostty"
  grep -q '<string>Maple Mono NF CN</string>' "$test_home/.config/fontconfig/fonts.conf" || fail "regional font becomes the system monospace default"
  [[ ! -s $OMARCHY_TEST_SESSION_LOG ]] || fail "headless setup sends no terminal signals or desktop IPC" "$(cat "$OMARCHY_TEST_SESSION_LOG")"
done
pass "install and first-boot owner setup write the regional font without reaching a session"

run_command omarchy-font-set 'Test Font'
grep -qx 'pkill -USR1 kitty' "$OMARCHY_TEST_SESSION_LOG" || fail "interactive font changes still reload Kitty"
grep -qx 'pkill -SIGUSR2 ghostty' "$OMARCHY_TEST_SESSION_LOG" || fail "interactive font changes still reload Ghostty"
grep -qx 'omarchy-restart-shell ' "$OMARCHY_TEST_SESSION_LOG" || fail "interactive font changes still refresh the shell"
pass "interactive font changes retain their session refreshes"
