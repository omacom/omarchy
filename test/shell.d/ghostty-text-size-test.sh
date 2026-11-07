#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
ghostty_config="$test_home/.config/ghostty/config"
alacritty_config="$test_home/.config/alacritty/alacritty.toml"
shell_config="$test_home/.config/omarchy/shell.toml"
mkdir -p "$test_dir/bin"

# Ghostty applies GTK's text-scaling-factor to its own font-size, so the command
# must change the factor and leave Ghostty's config alone.
cat >"$test_dir/bin/gsettings" <<'SH'
#!/bin/bash
if [[ $1 == "get" && $3 == "font-name" ]]; then
  echo "'Cantarell 11'"
elif [[ $1 == "get" ]]; then
  cat "$FACTOR_FILE" 2>/dev/null || echo 1.0
elif [[ ${FAIL_GSETTINGS:-} == "1" ]]; then
  exit 55
elif [[ $1 == "set" ]]; then
  printf '%s\n' "$4" >"$FACTOR_FILE"
else
  rm -f "$FACTOR_FILE"
fi
SH
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$SIGNAL_LOG"\n' >"$test_dir/bin/pkill"
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/omarchy-cmd-present"
cat >"$test_dir/bin/pgrep" <<'SH'
#!/bin/bash
[[ ${FOOT_RUNNING:-0} == "1" && $1 == "-x" && $2 == "foot" ]]
SH
cat >"$test_dir/bin/omarchy-i18n" <<'SH'
#!/bin/bash
[[ $1 == "display.restartFootForFontSize" ]] || exit 64
printf '%s\n' "$1" >>"$I18N_LOG"
printf '%s\n' "Localized Foot restart notice"
SH
cat >"$test_dir/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
{
  printf '%s\n' "call"
  printf 'arg=%s\n' "$@"
} >>"$NOTIFICATION_LOG"
printf '%s\n' 417
SH
chmod +x "$test_dir/bin/"*

run_command() {
  env HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    FACTOR_FILE="$test_dir/factor" SIGNAL_LOG="$test_dir/signals" \
    I18N_LOG="$test_dir/i18n" NOTIFICATION_LOG="$test_dir/notifications" \
    XDG_RUNTIME_DIR="$test_dir/runtime" FOOT_RUNNING="${FOOT_RUNNING:-0}" \
    "$ROOT/bin/omarchy-display-text-size" "$@"
}

reset_fixture() {
  rm -rf "$test_home" "$test_dir/factor" "$test_dir/signals" "$test_dir/dotfiles-ghostty" \
    "$test_dir/runtime" "$test_dir/i18n" "$test_dir/notifications"
  mkdir -p "$test_dir/runtime" "$(dirname "$ghostty_config")" "$(dirname "$alacritty_config")"
  printf 'size = 9\n' >"$alacritty_config"
}

for base in 9 13 15; do
  reset_fixture
  printf 'font-family = "JetBrainsMono Nerd Font"\nfont-size = %s\n' "$base" >"$ghostty_config"
  cp "$ghostty_config" "$test_dir/ghostty-before"

  run_command 20 || fail "size 20 succeeds with Ghostty at ${base}pt"
  [[ $(<"$test_dir/factor") == "1.6364" ]] || fail "size 20 sets the GTK factor"
  grep -qx 'size = 15' "$alacritty_config" || fail "size 20 sizes the other terminals"
  grep -qx 'base-size = 20' "$shell_config" || fail "size 20 sets the shell base size"
  cmp -s "$test_dir/ghostty-before" "$ghostty_config" || fail "size 20 leaves Ghostty's ${base}pt base font alone"
  [[ $(run_command) == *"terminal font: 15 pt"* ]] || fail "size report names the size the command set"

  run_command reset || fail "reset succeeds with Ghostty at ${base}pt"
  [[ ! -e $test_dir/factor ]] || fail "reset restores the GTK factor"
  grep -qx 'size = 9' "$alacritty_config" || fail "reset restores the other terminals"
  ! grep -q 'base-size' "$shell_config" || fail "reset restores the shell base size"
  cmp -s "$test_dir/ghostty-before" "$ghostty_config" || fail "reset leaves Ghostty's ${base}pt base font alone"
  ! grep -q ghostty "$test_dir/signals" 2>/dev/null || fail "Ghostty is never signalled to reload"
done
pass "size and reset scale Ghostty through GTK and leave its base font alone"

reset_fixture
printf 'font-size = 12\n' >"$test_dir/dotfiles-ghostty"
ln -s "$test_dir/dotfiles-ghostty" "$ghostty_config"
run_command 20
run_command reset
[[ -L $ghostty_config ]] || fail "a dotfile symlink survives"
grep -qx 'font-size = 12' "$test_dir/dotfiles-ghostty" || fail "the symlink target is untouched"
pass "a symlinked Ghostty config is left alone"

reset_fixture
run_command 20 || fail "size succeeds without a Ghostty config"
run_command reset || fail "reset succeeds without a Ghostty config"
[[ ! -e $ghostty_config ]] || fail "an absent Ghostty config stays absent"
pass "an absent Ghostty config is not created"

reset_fixture
printf 'font-size = 13\n' >"$ghostty_config"
for args in 20 reset; do
  if FAIL_GSETTINGS=1 run_command "$args" 2>/dev/null; then
    fail "$args fails when GSettings refuses the write"
  fi
  grep -qx 'size = 9' "$alacritty_config" || fail "$args changes no terminal when GSettings fails"
  [[ ! -e $shell_config ]] || fail "$args changes no shell size when GSettings fails"
  grep -qx 'font-size = 13' "$ghostty_config" || fail "$args leaves Ghostty alone when GSettings fails"
done
pass "a refused GSettings write changes nothing else"

reset_fixture
mkdir -p "$test_home/.config/foot"
printf 'font=monospace:size=9\n' >"$test_home/.config/foot/foot.ini"
FOOT_RUNNING=1 run_command 20 || fail "size succeeds with Foot running"
grep -qx 'font=monospace:size=15' "$test_home/.config/foot/foot.ini" || fail "size updates Foot's config"
grep -qx 'display.restartFootForFontSize' "$test_dir/i18n" || fail "the Foot notice uses its localization key"
grep -qx 'arg=Localized Foot restart notice' "$test_dir/notifications" || fail "the translated Foot notice is sent"
[[ $(<"$test_dir/runtime/omarchy-display-text-size.foot-notif-id") == "417" ]] || fail "the Foot notification id is retained"

FOOT_RUNNING=1 run_command reset || fail "reset succeeds with Foot running"
grep -qx 'font=monospace:size=9' "$test_home/.config/foot/foot.ini" || fail "reset restores Foot's config"
[[ $(grep -c '^call$' "$test_dir/notifications") == "2" ]] || fail "size and reset each notify running Foot"
[[ $(grep -c '^display.restartFootForFontSize$' "$test_dir/i18n") == "2" ]] || fail "both Foot notices use localization"
grep -qx 'arg=-r' "$test_dir/notifications" || fail "the Foot notice replaces the previous notification"
grep -qx 'arg=417' "$test_dir/notifications" || fail "the previous Foot notification id is reused"
pass "Foot sizing and reset retain localized replacement notices"
