#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
stub_bin="$test_dir/bin"
source_skin="$home/.local/state/omarchy/current/theme/mc.ini"
skin="$home/.local/share/mc/skins/omarchy.ini"
mc_ini="$home/.config/mc/ini"
mkdir -p "${source_skin%/*}" "$stub_bin"

cat >"$stub_bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stub_bin/omarchy-cmd-present"

sync_skin() {
  HOME="$home" PATH="$stub_bin:$PATH" bash "$ROOT/bin/omarchy-theme-set-mc"
}

skin_setting() {
  awk '/^\[/ { in_mc = ($0 == "[Midnight-Commander]") } in_mc && /^skin=/' "$mc_ini"
}

printf '[skin]\ndescription=first\n' >"$source_skin"
sync_skin
[[ ! -L $skin ]] && grep -qx 'description=first' "$skin" || fail "the skin is installed as a file"
[[ $(<"$mc_ini") == $'[Midnight-Commander]\nskin=omarchy' ]] || fail "a fresh mc config selects the skin" "$(<"$mc_ini")"
pass "a fresh install selects the theme's skin"

rm "$source_skin"
sync_skin
grep -qx 'description=first' "$skin" || fail "the last skin survives a theme without one"
pass "the last skin survives a theme without one"

printf '[skin]\ndescription=second\n' >"$source_skin"
printf '[Midnight-Commander]\nskin = julia256\nuse_internal_edit=true\n\n[Layout]\nmessage_visible=true\n' >"$mc_ini"
sync_skin
grep -qx 'description=second' "$skin" || fail "a new theme replaces the skin"
[[ $(skin_setting) == 'skin=omarchy' ]] || fail "a spaced skin entry is replaced" "$(<"$mc_ini")"
grep -qx 'use_internal_edit=true' "$mc_ini" && grep -qx 'message_visible=true' "$mc_ini" ||
  fail "other mc settings are kept" "$(<"$mc_ini")"
pass "an existing skin entry is replaced in place"

printf '[Midnight-Commander]\nuse_internal_edit=true\n\n[Layout]\nmessage_visible=true\n' >"$mc_ini"
sync_skin
[[ $(skin_setting) == 'skin=omarchy' ]] || fail "the skin lands in the Midnight-Commander section" "$(<"$mc_ini")"
[[ $(grep -c '^skin=' "$mc_ini") == 1 ]] || fail "the skin is set once" "$(<"$mc_ini")"
pass "a missing skin entry is added to the Midnight-Commander section"

printf '[Layout]\nmessage_visible=true\n' >"$mc_ini"
sync_skin
[[ $(skin_setting) == 'skin=omarchy' ]] || fail "a config without the section gains it" "$(<"$mc_ini")"
pass "a config without the Midnight-Commander section gains it"

