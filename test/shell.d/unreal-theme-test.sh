#!/bin/bash

set -euo pipefail

# omarchy-theme-set-unreal turns the generated unreal.json (sRGB hex) into an Unreal editor
# theme (linear FLinearColor strings). Unreal ignores slots it does not recognise and parses
# colors without complaint, so a misnamed slot or a wrong conversion only shows as a
# miscoloured editor. Every stock theme is rendered here and checked against the slot names
# Unreal's EStyleColor defines, and the conversion is pinned against known values.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

fake_bin="$test_tmp/bin"
home="$test_tmp/home"
current="$home/.local/state/omarchy/current"
unreal_theme="$home/.config/Epic/UnrealEngine/Slate/Themes/Omarchy.json"
mkdir -p "$fake_bin" "$current"

cat >"$fake_bin/omarchy-toggle-enabled" <<'SH'
#!/bin/bash
[[ $1 == "skip-unreal-theme-changes" && ${OMARCHY_TEST_SKIP_UNREAL:-0} == "1" ]]
SH
chmod +x "$fake_bin/omarchy-toggle-enabled"

# EStyleColor in Engine/Source/Runtime/SlateCore/Public/Styling/StyleColors.h, up to User1. Unreal
# reads theme keys by the enum's registered names, which carry the EStyleColor:: prefix.
unreal_slots=(
  Black Background Title WindowBorder Foldout Input InputOutline Recessed Panel Header Dropdown
  DropdownOutline Hover Hover2 White White25 Highlight Primary PrimaryHover PrimaryPress Secondary
  Foreground ForegroundHover ForegroundInverted ForegroundHeader Select SelectInactive SelectParent
  SelectHover Notifications AccentBlue AccentPurple AccentPink AccentRed AccentOrange AccentYellow
  AccentGreen AccentBrown AccentBlack AccentGray AccentWhite AccentFolder Warning Error Success
)

sync_unreal() {
  PATH="$fake_bin:$ROOT/bin:$PATH" HOME="$home" "$ROOT/bin/omarchy-theme-set-unreal"
}

render_theme() {
  local next_theme="$current/next-theme"

  rm -rf "$next_theme" "$current/theme"
  mkdir -p "$next_theme"
  cp "$1" "$next_theme/colors.toml"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-theme-set-templates"
  mv "$next_theme" "$current/theme"
}

render_theme "$ROOT/themes/tokyo-night/colors.toml"
sync_unreal
[[ ! -e $unreal_theme ]] || fail "nothing is written for a machine that never ran Unreal"
pass "nothing is written for a machine that never ran Unreal"

mkdir -p "$home/.config/Epic/UnrealEngine"
expected_slots=$(printf 'EStyleColor::%s\n' "${unreal_slots[@]}" | sort)

for colors in "$ROOT"/themes/*/colors.toml; do
  theme=$(basename "$(dirname "$colors")")
  render_theme "$colors"
  sync_unreal || fail "$theme converts to an Unreal theme"

  written_slots=$(jq -r '.Colors | keys[]' "$unreal_theme" | sort)
  [[ $written_slots == "$expected_slots" ]] ||
    fail "$theme fills exactly Unreal's color slots" "$(diff <(echo "$expected_slots") <(echo "$written_slots"))"

  jq -e '.Colors | all(test("^\\(R=[0-9.e-]+,G=[0-9.e-]+,B=[0-9.e-]+,A=[0-9.e-]+\\)$"))' "$unreal_theme" >/dev/null ||
    fail "$theme writes every color as an FLinearColor string"
done
pass "every stock theme fills exactly Unreal's color slots as FLinearColor strings"

jq -e '.Version == 1 and .Id == "886DB8111A8D42E9B681840D0BA1C0EC" and .DisplayName == "Omarchy"' "$unreal_theme" >/dev/null ||
  fail "the theme keeps the id Unreal remembers the selection by"
pass "the theme keeps the id Unreal remembers the selection by"

# sRGB #ffffff and #000000 are 1 and 0 in linear light; #808080 is 0.2158605 (the standard sRGB
# transfer function), and a trailing alpha byte passes through unconverted.
printf '{"Colors":{"White":"#ffffff","Black":"#000000","Hover2":"#80808040"}}\n' >"$current/theme/unreal.json"
sync_unreal
jq -e '
  .Colors["EStyleColor::White"] == "(R=1,G=1,B=1,A=1)"
  and .Colors["EStyleColor::Black"] == "(R=0,G=0,B=0,A=1)"
  and (.Colors["EStyleColor::Hover2"] | test("^\\(R=0\\.21586[0-9]*,G=0\\.21586[0-9]*,B=0\\.21586[0-9]*,A=0\\.25098[0-9]*\\)$"))
' "$unreal_theme" >/dev/null || fail "hex converts to linear color" "$(cat "$unreal_theme")"
pass "hex converts to linear color, alpha unconverted"

cp "$unreal_theme" "$test_tmp/previous.json"
printf '{"Colors":{"White":"#ffffff","Black":"not-a-color"}}\n' >"$current/theme/unreal.json"
if sync_unreal 2>/dev/null; then
  fail "an invalid color is reported"
fi
cmp -s "$unreal_theme" "$test_tmp/previous.json" || fail "an invalid color leaves the previous theme in place"
pass "an invalid color is reported and leaves the previous theme in place"

: >"$current/theme/unreal.json"
if sync_unreal 2>/dev/null; then
  fail "an empty unreal.json is reported"
fi
cmp -s "$unreal_theme" "$test_tmp/previous.json" || fail "an empty unreal.json leaves the previous theme in place"
pass "an empty unreal.json is reported and leaves the previous theme in place"

OMARCHY_TEST_SKIP_UNREAL=1 sync_unreal
[[ ! -e $unreal_theme ]] || fail "opting out removes the theme"
pass "opting out removes the theme"
