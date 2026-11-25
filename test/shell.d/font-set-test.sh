#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

# A font choice must leave explicitly named mono families ahead of the generic.
unset FONTCONFIG_FILE FONTCONFIG_PATH
chosen="Adwaita Mono"
named="Liberation Mono"
packaged="JetBrainsMono Nerd Font"

if ! command -v fc-match >/dev/null || [[ ! -r /etc/fonts/conf.d/48-guessfamily.conf ]]; then
  skip "font set resolution needs fc-match and the system fontconfig"
  exit 0
fi

files_of() {
  fc-list ":family=$1" file | sort
}

if [[ -z $(files_of "$chosen") || -z $(files_of "$named") || -z $(files_of "$packaged") ]]; then
  skip "font set resolution needs $chosen, $named and $packaged"
  exit 0
fi
if [[ -n $(comm -12 <(files_of "$chosen") <(files_of "$named")) || -n $(comm -12 <(files_of "$chosen") <(files_of "$packaged")) ]]; then
  skip "font set resolution needs distinct chosen, named and packaged fonts"
  exit 0
fi

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
test_home="$test_dir/home"
mkdir -p "$test_home/.config" "$test_dir/bin" "$test_dir/conf.d" "$test_dir/cache"

# Run the real font command without touching the running desktop.
for command in pkill omarchy-restart-shell omarchy-hook omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$test_dir/bin/$command"
done
printf '#!/bin/bash\nprintf "%s\\n"\n' "$chosen" >"$test_dir/bin/fc-list"
chmod +x "$test_dir/bin/"*

# The system rules, with this checkout's 50-omarchy.conf in place of the installed one.
for file in /etc/fonts/conf.d/*.conf; do
  ln -s "$file" "$test_dir/conf.d/${file##*/}"
done
rm -f "$test_dir/conf.d/50-omarchy.conf"
cp "$ROOT/default/fontconfig/conf.avail/50-omarchy.conf" "$test_dir/conf.d/"
sed "s#<include ignore_missing=\"yes\">conf.d</include>#<include ignore_missing=\"yes\">$test_dir/conf.d</include>#" \
  /etc/fonts/fonts.conf >"$test_dir/fonts.conf"
grep -Fq "$test_dir/conf.d</include>" "$test_dir/fonts.conf" || fail "fontconfig fixture loads the rules under test"

# Match every family name the resolved font carries, including alternate names.
resolves_to() {
  local answer
  answer=$(FONTCONFIG_FILE="$test_dir/fonts.conf" XDG_CONFIG_HOME="$test_home/.config" \
    XDG_CACHE_HOME="$test_dir/cache" fc-match "$1" family)
  [[ ,$answer, == *",$2,"* ]] || fail "$3" "$1 -> $answer, wanted $2"
  pass "$3"
}

resolves_to monospace "$packaged" "with no font chosen, monospace resolves to the packaged family"

set_font() {
  env HOME="$test_home" PATH="$test_dir/bin:$ROOT/bin:$PATH" FONTCONFIG_FILE="$test_dir/fonts.conf" \
    XDG_CACHE_HOME="$test_dir/cache" "$ROOT/bin/omarchy-font-set" "$chosen" >/dev/null 2>&1
}

# Installed defaults without the placeholder: refuse before writing anything.
cp "$test_dir/conf.d/50-omarchy.conf" "$test_dir/50-omarchy.conf.new"
sed -i '/<string>Omarchy Fixed Pitch<\/string>/d' "$test_dir/conf.d/50-omarchy.conf"
! set_font && [[ ! -e $test_home/.config/fontconfig/fonts.conf ]] ||
  fail "font set refuses while the installed defaults lack the placeholder"
pass "font set refuses while the installed defaults lack the placeholder"
mv "$test_dir/50-omarchy.conf.new" "$test_dir/conf.d/50-omarchy.conf"

set_font || fail "font set succeeds with the defaults under test"

resolves_to monospace "$chosen" "monospace follows the chosen $chosen"
resolves_to "$named" "$named" "$named remains itself after choosing $chosen"
resolves_to "$packaged" "$packaged" "$packaged remains itself after choosing $chosen"
