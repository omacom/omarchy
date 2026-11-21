#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command locale

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

turkish_locale=$(locale -a | awk 'tolower($0) ~ /^tr_tr([.]|$)/ { print; exit }')
if [[ -z $turkish_locale ]]; then
  mkdir -p "$work/locales"
  if ! localedef -i tr_TR -f UTF-8 "$work/locales/tr_TR.UTF-8" >/dev/null 2>&1; then
    skip "locale-sensitive command parsing: localedef cannot build tr_TR"
    exit 0
  fi
  export LOCPATH="$work/locales"
  turkish_locale=tr_TR.UTF-8
fi

command_bin=${OMARCHY_LOCALE_TEST_BIN:-$ROOT/bin}
home_dir="$work/home"
config_home="$work/config"
state_home="$work/state"
omarchy_path="$work/omarchy"
stub_dir="$work/bin"
mkdir -p "$home_dir" "$config_home" "$state_home/omarchy/workspace-layouts" \
  "$omarchy_path/themes/indigo-ice" "$home_dir/.config/omarchy/themes/iceberg-indigo" \
  "$stub_dir"

cat >"$stub_dir/hyprctl" <<'EOF'
#!/bin/bash
if [[ $1 == "workspaces" && ${2:-} == "-j" ]]; then
  printf '[{"id":3,"tiledLayout":"dwindle"}]\n'
elif [[ $1 == "getoption" && ${2:-} == "general.layout" ]]; then
  printf '{"str":"dwindle"}\n'
else
  exit 1
fi
EOF
chmod +x "$stub_dir/hyprctl"

run_command() {
  local locale_name="$1" command_name="$2"
  shift 2
  env LC_ALL="$locale_name" HOME="$home_dir" XDG_CONFIG_HOME="$config_home" \
    XDG_STATE_HOME="$state_home" OMARCHY_PATH="$omarchy_path" \
    PATH="$stub_dir:$command_bin:$ROOT/bin:$PATH" \
    "$command_bin/$command_name" "$@"
}

assert_same_output() {
  local description="$1" expected="$2" command_name="$3"
  shift 3
  local c_output turkish_output detail

  c_output=$(run_command C "$command_name" "$@") || fail "$description runs under C"
  turkish_output=$(run_command "$turkish_locale" "$command_name" "$@") || fail "$description runs under Turkish"

  if [[ $c_output != "$expected" ]]; then
    printf -v detail 'expected: %s\nactual: %s' "$expected" "$c_output"
    fail "$description has the expected C output" "$detail"
  fi
  if [[ $turkish_output != "$expected" ]]; then
    printf -v detail 'expected: %s\nactual: %s' "$expected" "$turkish_output"
    fail "$description has the expected Turkish output" "$detail"
  fi
  if [[ $turkish_output != "$c_output" ]]; then
    printf -v detail 'C: %s\nTurkish: %s' "$c_output" "$turkish_output"
    fail "$description is stable across locales" "$detail"
  fi
  pass "$description is stable across C and Turkish locales"
}

layout_dir="$state_home/omarchy/workspace-layouts"
printf 'o.workspace_mode({ workspace = "3", mode = "floating" })\n' >"$layout_dir/3.lua"
printf 'o.workspace_mode({ default = "scrolling" })\n' >"$layout_dir/default.lua"
assert_same_output "saved workspace mode parsing" floating omarchy-hyprland-workspace-layout-current 3
assert_same_output "saved default mode parsing" scrolling omarchy-hyprland-workspace-layout-default

rm "$layout_dir/3.lua"
assert_same_output "workspace fallback to the saved default" scrolling omarchy-hyprland-workspace-layout-current 3

mkdir -p "$home_dir/.local/state/omarchy/current"
printf 'iceberg-indigo\n' >"$home_dir/.local/state/omarchy/current/theme.name"
assert_same_output "current theme capitalization across a hyphen" "Iceberg Indigo" omarchy-theme-current

list_c=$(run_command C omarchy-theme-list)
list_turkish=$(run_command "$turkish_locale" omarchy-theme-list)
for theme_name in "Iceberg Indigo" "Indigo Ice"; do
  grep -Fxq -- "$theme_name" <<<"$list_c" || fail "theme list capitalizes $theme_name under C" "$list_c"
  grep -Fxq -- "$theme_name" <<<"$list_turkish" || fail "theme list capitalizes $theme_name under Turkish" "$list_turkish"
done
sorted_c=$(printf '%s\n' "$list_c" | LC_ALL=C sort)
sorted_turkish=$(printf '%s\n' "$list_turkish" | LC_ALL=C sort)
if [[ $sorted_c != "$sorted_turkish" ]]; then
  printf -v detail 'C:\n%s\nTurkish:\n%s' "$list_c" "$list_turkish"
  fail "theme list is stable across locales" "$detail"
fi
pass "theme list capitalizes i-prefixed names across hyphens in both locales"

preference="$config_home/fontconfig/conf.d/50-omarchy-input-method.conf"
mkdir -p "${preference%/*}"
printf '<family>Noto Sans CJK JP</family>\n' >"$preference"
assert_same_output "CJK font preference parsing" jp omarchy-font-cjk
