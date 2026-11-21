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

# Font selection also preserves custom fontconfig and explicitly named families.
packaged_family="JetBrainsMono Nerd Font"

if ! command -v fc-match >/dev/null || [[ ! -r /etc/fonts/conf.d/48-guessfamily.conf ]]; then
  skip "font set resolution needs fc-match and the system fontconfig"
  exit 0
fi

installed_mono_families() {
  fc-list :spacing=100 family | tr ',' '\n' | sed 's/^ *//; s/ *$//' | sort -u
}

files_of() {
  fc-list ":family=$1" file | sort
}

# Two mono families that share no font file, so a capture can be told apart
# from a correct match.
mapfile -t candidates < <(installed_mono_families | grep -i mono | grep -Fxv "$packaged_family")
chosen=${candidates[0]:-}
named=""
for candidate in "${candidates[@]:1}"; do
  [[ -n $(files_of "$candidate") && -z $(comm -12 <(files_of "$candidate") <(files_of "$chosen")) ]] || continue
  named=$candidate
  break
done

if [[ -z $named ]] || ! installed_mono_families | grep -Fxq "$packaged_family"; then
  skip "font set resolution needs $packaged_family and two other mono families"
  exit 0
fi

mkdir -p "$test_dir/bin" "$test_dir/conf.d" "$test_dir/cache" "$test_dir/home/.config"
printf '#!/bin/bash\n\necho "%s"\n' "$chosen" >"$test_dir/bin/fc-list"
for file in /etc/fonts/conf.d/*.conf; do
  ln -s "$file" "$test_dir/conf.d/${file##*/}"
done
rm -f "$test_dir/conf.d/50-omarchy.conf"
cp "$ROOT/default/fontconfig/conf.avail/50-omarchy.conf" "$test_dir/conf.d/"
sed "s#<include ignore_missing=\"yes\">conf.d</include>#<include ignore_missing=\"yes\">$test_dir/conf.d</include>#" \
  /etc/fonts/fonts.conf >"$test_dir/fonts.conf"

# fc-match answers with every name the matched font carries ("JetBrainsMono
# Nerd Font,JetBrainsMono NF"), so look for the family anywhere in the answer.
resolves_to() {
  local answer
  answer=$(FONTCONFIG_FILE="$test_dir/fonts.conf" XDG_CONFIG_HOME="$test_dir/home/.config" \
    XDG_CACHE_HOME="$test_dir/cache" fc-match "$1" family)
  [[ ,$answer, == *",$2,"* ]] || fail "$3" "$1 -> $answer, wanted $2"
  pass "$3"
}

rm -rf "$test_home/.config/fontconfig"
resolves_to monospace "$packaged_family" "with no font chosen, monospace resolves to the packaged family"

# User rules survive byte for byte; only the exact legacy generated block goes.
mkdir -p "$test_dir/home/.config/fontconfig"
cat >"$test_dir/custom.conf" <<'XML'
<?xml version="1.0"?>
<fontconfig>
  <!-- Keep my rendering rule. -->
  <match target="font"><edit name="rgba" mode="assign"><const>rgb</const></edit></match>
</fontconfig>
XML
sed 's#</fontconfig>#<match target="pattern"><test name="family" qual="any"><string>monospace</string></test><edit name="family" mode="prepend_first" binding="strong"><string>Old Mono</string></edit></match></fontconfig>#' \
  "$test_dir/custom.conf" >"$test_dir/home/.config/fontconfig/fonts.conf"

run_command omarchy-font-set "$chosen" >/dev/null
cmp -s "$test_dir/custom.conf" "$test_dir/home/.config/fontconfig/fonts.conf" || fail "choosing a font preserves custom fontconfig bytes"
pass "choosing a font preserves custom fontconfig bytes"

# The prerequisite migration may already have converted the legacy edit.
sed 's#</fontconfig>#<alias binding="strong"><family>Omarchy Fixed Pitch</family><prefer><family>Old Mono</family></prefer></alias></fontconfig>#' \
  "$test_dir/custom.conf" >"$test_dir/home/.config/fontconfig/fonts.conf"
run_command omarchy-font-set "$chosen" >/dev/null
cmp -s "$test_dir/custom.conf" "$test_dir/home/.config/fontconfig/fonts.conf" || fail "choosing a font retires the prerequisite alias without changing custom rules"
pass "choosing a font retires the prerequisite alias without changing custom rules"

resolves_to monospace "$chosen" "the chosen family follows the monospace generic"
resolves_to "$named" "$named" "a named mono family still resolves to itself after a font is chosen"
resolves_to "$packaged_family" "$packaged_family" "the packaged family named outright still resolves to itself"
