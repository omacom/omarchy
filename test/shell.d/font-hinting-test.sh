#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
config_home="$test_home/.config"
drop_in="$test_home/.config/fontconfig/conf.d/20-omarchy-hinting.conf"
fonts_conf="$test_home/.config/fontconfig/fonts.conf"
calls="$test_dir/calls"
mkdir -p "$test_home/.config/omarchy/hooks/font-hinting.d" "$test_dir/bin"

for command in omarchy-restart-shell gsettings; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s $*" >>"%s"\n' "$command" "$calls" >"$test_dir/bin/$command"
done
# Run the real notification helper; only the D-Bus transport is a stub.
printf '#!/bin/bash\nprintf "%%s\\n" "$@" >>"%s"\n' "$calls" >"$test_dir/bin/busctl"
printf '#!/bin/bash\nexit 1\n' >"$test_dir/bin/pgrep"
printf '#!/bin/bash\nprintf "Test Font\\n"\n' >"$test_dir/bin/fc-list"
chmod +x "$test_dir/bin/"*
printf '#!/bin/bash\nprintf "%%s\\n" "hook $1" >>"%s"\n' "$calls" >"$test_home/.config/omarchy/hooks/font-hinting.d/record"

run_command() {
  env HOME="$test_home" XDG_CONFIG_HOME="$config_home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$ROOT/bin/$@"
}

[[ ! -e $drop_in ]] || fail "test starts without a hinting override"
default_hinting=$(run_command omarchy-font-hinting)
[[ $default_hinting =~ ^(none|slight|medium|full)$ ]] || fail "current hinting is one of the four styles" "$default_hinting"
[[ ! -e $calls ]] || fail "reading the hinting changes nothing"
pass "font hinting reports the style fontconfig resolves"

for style in full medium slight none; do
  : >"$calls"
  run_command omarchy-font-hinting "$style"
  grep -q "<const>hint$style</const>" "$drop_in" || fail "$style writes its hintstyle"
  [[ $(run_command omarchy-font-hinting) == "$style" ]] || fail "fontconfig resolves $style after setting it"
  grep -qx "gsettings set org.gnome.desktop.interface font-hinting $style" "$calls" || fail "$style reaches GTK"
  grep -q '^omarchy-restart-shell' "$calls" || fail "$style restarts the shell"
  grep -qx 'Restart open apps to see the change' "$calls" || fail "$style sends its restart reminder through the real notification parser"
  grep -qx "hook $style" "$calls" || fail "$style runs the font-hinting hook"
done
grep -q '<bool>false</bool>' "$drop_in" || fail "none turns hinting off"
pass "font hinting sets fontconfig and GTK together"

run_command omarchy-font-hinting full
run_command omarchy-font-set 'Test Font' >/dev/null
grep -q 'Test Font' "$fonts_conf" || fail "font set writes fonts.conf"
[[ $(run_command omarchy-font-hinting) == "full" ]] || fail "hinting survives a font change"
pass "font hinting survives omarchy-font-set rewriting fonts.conf"

: >"$calls"
run_command omarchy-font-hinting reset
[[ ! -e $drop_in ]] || fail "reset removes the override"
[[ $(run_command omarchy-font-hinting) == "$default_hinting" ]] || fail "reset returns to the default style"
grep -qx "gsettings reset org.gnome.desktop.interface font-hinting" "$calls" || fail "reset reaches GTK"
grep -qx "hook $default_hinting" "$calls" || fail "reset runs the hook with the default style"
pass "font hinting reset restores the defaults"

: >"$calls"
if run_command omarchy-font-hinting bold 2>/dev/null; then
  fail "an unknown style is rejected"
fi
[[ ! -e $drop_in && ! -s $calls ]] || fail "an unknown style changes nothing"
pass "font hinting rejects unknown styles"

config_home="$test_dir/custom-config"
run_command omarchy-font-hinting full
[[ -f $config_home/fontconfig/conf.d/20-omarchy-hinting.conf && ! -e $drop_in ]] || fail "hinting uses the custom config directory"
[[ $(run_command omarchy-font-hinting) == "full" ]] || fail "fontconfig resolves hinting from the custom config directory"
run_command omarchy-font-hinting reset
[[ ! -e $config_home/fontconfig/conf.d/20-omarchy-hinting.conf ]] || fail "reset removes the custom-directory override"
pass "font hinting follows XDG_CONFIG_HOME for setting, reading and reset"
