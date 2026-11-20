#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# 48-guessfamily.conf appends the monospace generic to every family whose name
# merely contains "mono", so a chosen font must not capture a request that names
# another mono family. Checked through fc-match against the system fontconfig,
# with only the packaged file swapped for the one under test.

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

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/conf.d" "$test_dir/cache" "$test_dir/home/.config"
printf '#!/bin/bash\n\necho "%s"\n' "$chosen" >"$test_dir/bin/fc-list"
for stub in omarchy-restart-shell omarchy-notification-send omarchy-hook pkill; do
  printf '#!/bin/bash\n\nexit 0\n' >"$test_dir/bin/$stub"
done
# No terminal runs under the fake home, so the restart toasts stay quiet.
printf '#!/bin/bash\n\nexit 1\n' >"$test_dir/bin/pgrep"
chmod +x "$test_dir/bin/"*

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

HOME="$test_dir/home" PATH="$test_dir/bin:$PATH" bash "$ROOT/bin/omarchy-font-set" "$chosen" >/dev/null
cmp -s "$test_dir/custom.conf" "$test_dir/home/.config/fontconfig/fonts.conf" || fail "choosing a font preserves custom fontconfig bytes"
pass "choosing a font preserves custom fontconfig bytes"

# The prerequisite migration may already have converted the legacy edit.
sed 's#</fontconfig>#<alias binding="strong"><family>Omarchy Fixed Pitch</family><prefer><family>Old Mono</family></prefer></alias></fontconfig>#' \
  "$test_dir/custom.conf" >"$test_dir/home/.config/fontconfig/fonts.conf"
HOME="$test_dir/home" PATH="$test_dir/bin:$PATH" bash "$ROOT/bin/omarchy-font-set" "$chosen" >/dev/null
cmp -s "$test_dir/custom.conf" "$test_dir/home/.config/fontconfig/fonts.conf" || fail "choosing a font retires the prerequisite alias without changing custom rules"
pass "choosing a font retires the prerequisite alias without changing custom rules"

resolves_to monospace "$chosen" "the chosen family follows the monospace generic"
resolves_to "$named" "$named" "a named mono family still resolves to itself after a font is chosen"
resolves_to "$packaged_family" "$packaged_family" "the packaged family named outright still resolves to itself"
