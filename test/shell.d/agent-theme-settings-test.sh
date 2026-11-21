#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command getfacl
require_command setfacl
require_command python3

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export CLAUDE_CONFIG_DIR="$HOME/.claude"
theme_dir="$HOME/.local/state/omarchy/current/theme"
mkdir -p "$theme_dir" "$HOME/.pi/agent" "$CLAUDE_CONFIG_DIR" "$test_tmp/dotfiles with spaces"
printf '{}\n' >"$theme_dir/pi.json"
printf '{}\n' >"$theme_dir/claude.json"

mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/cp" <<'SH'
#!/bin/bash
if [[ ${OMARCHY_TEST_FAIL_STAGE:-} == "attributes" && $1 == "--attributes-only" ]]; then
  exit 71
fi
command -p cp "$@"
SH
cat >"$test_tmp/bin/mv" <<'SH'
#!/bin/bash
if [[ ${OMARCHY_TEST_FAIL_STAGE:-} == "publish" && ${*: -1} == "$OMARCHY_TEST_SETTINGS_TARGET" ]]; then
  exit 72
fi
command -p mv "$@"
SH
chmod +x "$test_tmp/bin"/*

assert_no_settings_temps() {
  local candidate
  for candidate in "$target".*; do
    [[ ! -e $candidate ]] || fail "$agent activation leaves no settings temporary files" "$candidate"
  done
}

for agent in pi claude; do
  if [[ $agent == "pi" ]]; then
    settings="$HOME/.pi/agent/settings.json"
    expected_theme=omarchy-system
  else
    settings="$CLAUDE_CONFIG_DIR/settings.json"
    expected_theme=custom:omarchy
  fi

  for mode in 600 640 644 664; do
    printf '{"model":"keep-me","theme":"old"}\n' >"$settings"
    chmod "$mode" "$settings"
    "$ROOT/bin/omarchy-theme-set-$agent" --activate
    [[ $(stat -c '%a' "$settings") == "$mode" ]] ||
      fail "$agent theme activation preserves mode $mode" "actual mode: $(stat -c '%a' "$settings")"
    jq -e --arg theme "$expected_theme" '.theme == $theme and .model == "keep-me"' "$settings" >/dev/null ||
      fail "$agent theme activation updates the theme and keeps other settings"
  done
  pass "$agent theme activation preserves existing file modes and other settings"

  target="$test_tmp/dotfiles with spaces/$agent-settings.json"
  printf '{"model":"keep-me","theme":"old"}\n' >"$target"
  chmod 640 "$target"
  rm "$settings"
  relative_target=$(realpath --relative-to="$(dirname "$settings")" "$target")
  ln -s "$relative_target" "$settings"
  "$ROOT/bin/omarchy-theme-set-$agent" --activate
  [[ -L $settings && $(readlink "$settings") == "$relative_target" ]] ||
    fail "$agent theme activation keeps the dotfiles symlink"
  [[ $(stat -c '%a' "$target") == "640" ]] || fail "$agent theme activation preserves the target's mode"
  jq -e --arg theme "$expected_theme" '.theme == $theme and .model == "keep-me"' "$target" >/dev/null ||
    fail "$agent theme activation updates the symlink's target"
  pass "$agent theme activation updates the target without replacing the symlink"

  # A named ACL cannot be preserved by copying only the numeric mode bits.
  setfacl -m u:65534:r "$target"
  expected_acl=$(getfacl -cpn "$target")
  python3 - "$target" <<'PY'
import os, sys
os.setxattr(sys.argv[1], 'user.omarchy-test', b'keep-me')
PY
  "$ROOT/bin/omarchy-theme-set-$agent" --activate
  [[ $(getfacl -cpn "$target") == "$expected_acl" ]] || fail "$agent activation preserves named ACL entries"
  python3 - "$target" <<'PY'
import os, sys
assert os.getxattr(sys.argv[1], 'user.omarchy-test') == b'keep-me'
PY
  pass "$agent theme activation preserves ACLs and extended attributes"

  alternate_group=""
  for group in $(id -G); do
    if [[ $group != "$(id -g)" ]]; then
      alternate_group=$group
      break
    fi
  done
  if [[ -n $alternate_group ]]; then
    chgrp "$alternate_group" "$target"
    expected_owner=$(stat -c '%u:%g' "$target")
    "$ROOT/bin/omarchy-theme-set-$agent" --activate
    [[ $(stat -c '%u:%g' "$target") == "$expected_owner" ]] || fail "$agent activation preserves a non-default group"
    pass "$agent theme activation preserves file ownership"
  else
    skip "$agent ownership test needs membership in a second group"
  fi

  printf '{invalid JSON\n' >"$target"
  cp "$target" "$test_tmp/original"
  if "$ROOT/bin/omarchy-theme-set-$agent" --activate >"$test_tmp/output" 2>&1; then
    fail "$agent theme activation rejects malformed settings"
  fi
  cmp -s "$target" "$test_tmp/original" || fail "$agent failed activation changes no settings"
  [[ -L $settings && $(readlink "$settings") == "$relative_target" ]] ||
    fail "$agent failed activation preserves the symlink"
  assert_no_settings_temps
  pass "$agent failed activation preserves the original settings and symlink"

  printf '{"model":"keep-me","theme":"old"}\n' >"$target"
  cp "$target" "$test_tmp/original"
  export OMARCHY_TEST_SETTINGS_TARGET="$target"
  for stage in attributes publish; do
    if [[ $stage == "attributes" ]]; then expected_status=71; else expected_status=72; fi
    if PATH="$test_tmp/bin:$PATH" OMARCHY_TEST_FAIL_STAGE="$stage" \
      "$ROOT/bin/omarchy-theme-set-$agent" --activate >"$test_tmp/output" 2>&1; then
      fail "$agent activation propagates a failure during $stage"
    else
      actual_status=$?
    fi
    (( actual_status == expected_status )) || fail "$agent activation preserves the failure exit status"
    cmp -s "$target" "$test_tmp/original" || fail "$agent failure during $stage changes no settings"
    [[ -L $settings && $(readlink "$settings") == "$relative_target" ]] ||
      fail "$agent failure during $stage preserves the symlink"
    assert_no_settings_temps
  done
  pass "$agent metadata and publication failures preserve settings and clean up temporary files"
done
