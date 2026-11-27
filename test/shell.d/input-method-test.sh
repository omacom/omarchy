#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

OMARCHY_PATH="$ROOT" python "$ROOT/test/shell.d/input-method-checks.py"

fcitx_tmp=$(mktemp -d)
trap 'rm -rf "$fcitx_tmp"' EXIT

# Stub /usr/bin/fcitx5 via a scratch copy of omarchy-fcitx5-start so we test
# its real profile parser and --disable selection without touching the live daemon.
mkdir -p "$fcitx_tmp/bin"
cat >"$fcitx_tmp/bin/fcitx5" <<'SH'
#!/bin/bash
printf '%s\n' "$*"
SH
chmod +x "$fcitx_tmp/bin/fcitx5"
sed "s|/usr/bin/fcitx5|$fcitx_tmp/bin/fcitx5|" "$ROOT/bin/omarchy-fcitx5-start" >"$fcitx_tmp/omarchy-fcitx5-start"
chmod +x "$fcitx_tmp/omarchy-fcitx5-start"

run_fcitx_start() {
  local profile_dir="$fcitx_tmp/cfg"
  rm -rf "$profile_dir"
  mkdir -p "$profile_dir"
  if [[ -n ${1:-} ]]; then
    printf '%s\n' "$1" >"$profile_dir/profile"
  fi
  FCITX_CONFIG_HOME="$profile_dir" "$fcitx_tmp/omarchy-fcitx5-start"
}

[[ $(run_fcitx_start $'[Groups/0]\nName=Default\n[Groups/0/Items/0]\nName=keyboard-us') == "--replace --disable notificationitem,xcb,xim" ]] ||
  fail "keyboard-only profile disables xcb and xim even when the group is named Default"
[[ $(run_fcitx_start $'[Groups/0]\nName=Default\n[Groups/0/Items/0]\nName=keyboard-us\n[Groups/0/Items/1]\nName=mozc') == "--replace --disable notificationitem" ]] ||
  fail "composition engine in group 0 keeps xcb and xim enabled"
[[ $(run_fcitx_start $'[Groups/0]\nName=Default\n[Groups/0/Items/0]\nName=keyboard-us\n[Groups/1]\nName=CJK\n[Groups/1/Items/0]\nName=pinyin') == "--replace --disable notificationitem" ]] ||
  fail "composition engine in another group keeps xcb and xim enabled"
[[ $(run_fcitx_start "") == "--replace --disable notificationitem" ]] ||
  fail "missing profile keeps xcb and xim enabled"
pass "omarchy-fcitx5-start disables xcb and xim only on keyboard-only profiles"
