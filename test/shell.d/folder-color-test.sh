#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
failing_jq_bin="$test_tmp/failing-jq-bin"
no_touch_bin="$test_tmp/no-touch-bin"
icon_base="$test_tmp/icons"
state_dir="$test_tmp/state"
folder="$test_tmp/folder"
registry="$state_dir/omarchy/folder-colors.json"
gio_log="$test_tmp/gio.log"
jq_log="$test_tmp/jq.log"
touch_log="$test_tmp/touch.log"

mkdir -p "$mock_bin" "$failing_jq_bin" "$no_touch_bin" "$folder" "$(dirname "$registry")" \
  "$icon_base/Yaru-red/256x256/places"
touch "$icon_base/Yaru-red/256x256/places/folder.png"

cat >"$mock_bin/gio" <<'EOF'
#!/bin/bash

printf '%s\n' "$*" >>"$TEST_GIO_LOG"

if [[ $1 == "info" ]]; then
  if [[ $* == *"standard::icon"* ]]; then
    echo "  standard::icon: folder"
  fi
  exit 0
fi

attribute="${*: -1}"
if [[ $attribute == "${GIO_FAIL_ATTRIBUTE:-}" ]]; then
  exit 1
fi
EOF
chmod +x "$mock_bin/gio"

cat >"$failing_jq_bin/jq" <<'EOF'
#!/bin/bash
echo called >>"$TEST_JQ_LOG"
exit 1
EOF
chmod +x "$failing_jq_bin/jq"

cat >"$no_touch_bin/touch" <<'EOF'
#!/bin/bash
echo called >>"$TEST_TOUCH_LOG"
exit 1
EOF
chmod +x "$no_touch_bin/touch"

save_color() {
  jq -n --arg path "$folder" '{($path): "blue"}' >"$registry"
}

assert_color_saved() {
  [[ $(jq -r --arg path "$folder" '.[$path]' "$registry") == "blue" ]] ||
    fail "$1"
}

assert_no_registry_temp() {
  shopt -s nullglob
  local temps=("$registry".?????? "$registry".reapply.??????)
  shopt -u nullglob
  (( ${#temps[@]} == 0 )) || fail "$1"
}

save_color
if PATH="$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  GIO_FAIL_ATTRIBUTE="metadata::custom-icon" \
  "$ROOT/bin/omarchy-folder-color" clear "$folder" >"$test_tmp/output" 2>&1; then
  fail "folder color clear propagates a custom-icon metadata failure"
fi
assert_color_saved "folder color clear preserves saved state after a custom-icon metadata failure"
pass "folder color clear preserves saved state when removing the custom icon fails"

save_color
if PATH="$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  GIO_FAIL_ATTRIBUTE="metadata::custom-icon-name" \
  "$ROOT/bin/omarchy-folder-color" clear "$folder" >"$test_tmp/output" 2>&1; then
  fail "folder color clear propagates a custom-icon-name metadata failure"
fi
assert_color_saved "folder color clear preserves saved state after a custom-icon-name metadata failure"
pass "folder color clear preserves saved state when removing the legacy icon name fails"

save_color
touch -a -m -d "2020-06-15 12:00:00.123456789" "$folder"
before=$(stat -c '%x|%y' "$folder")
PATH="$no_touch_bin:$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  TEST_TOUCH_LOG="$touch_log" \
  "$ROOT/bin/omarchy-folder-color" clear "$folder" >"$test_tmp/output"
after=$(stat -c '%x|%y' "$folder")

[[ $(jq -r --arg path "$folder" '.[$path] // "missing"' "$registry") == "missing" ]] ||
  fail "folder color clear removes saved state after both metadata writes succeed"
[[ $before == "$after" ]] || fail "folder color clear preserves folder timestamps"
[[ ! -e $touch_log ]] || fail "folder color refresh never rewrites folder timestamps"
if grep -Fq 'unix::mode' "$gio_log"; then
  fail "folder color refresh never reads or rewrites folder permissions"
fi
[[ $(grep -c 'xattr::omarchy-folder-color-refresh-' "$gio_log") == 2 ]] ||
  fail "folder color refresh adds and removes one temporary xattr"
[[ $(grep -c 'metadata::custom-icon$' "$gio_log") == 3 ]] ||
  fail "folder color clear attempts the custom icon removal on every run"
[[ $(grep -c 'metadata::custom-icon-name$' "$gio_log") == 2 ]] ||
  fail "folder color clear attempts the legacy icon-name removal when reached"
grep -Fxq "Cleared color from $folder" "$test_tmp/output" ||
  fail "folder color clear reports success after completing the metadata writes"
pass "folder color clear removes saved state only after metadata succeeds"

save_color
rm -f "$jq_log"
if PATH="$failing_jq_bin:$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  TEST_JQ_LOG="$jq_log" OMARCHY_FOLDER_COLOR_ICON_BASE="$icon_base" \
  "$ROOT/bin/omarchy-folder-color" set "$folder" red >"$test_tmp/output" 2>&1; then
  fail "folder color set propagates a registry jq failure"
fi
assert_color_saved "folder color set preserves the registry after jq fails"
[[ -s $jq_log ]] || fail "folder color set reaches the registry write before reporting its failure"
assert_no_registry_temp "folder color set removes its temporary registry after jq fails"
if grep -Fq "Colored $folder red" "$test_tmp/output"; then
  fail "folder color set reports success after jq fails"
fi
pass "folder color set cleans up and reports registry failures"

save_color
rm -f "$jq_log"
if PATH="$failing_jq_bin:$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  TEST_JQ_LOG="$jq_log" \
  "$ROOT/bin/omarchy-folder-color" clear "$folder" >"$test_tmp/output" 2>&1; then
  fail "folder color clear propagates a registry jq failure"
fi
assert_color_saved "folder color clear preserves the registry after jq fails"
[[ -s $jq_log ]] || fail "folder color clear reaches the registry write before reporting its failure"
assert_no_registry_temp "folder color clear removes its temporary registry after jq fails"
if grep -Fq "Cleared color from $folder" "$test_tmp/output"; then
  fail "folder color clear reports success after registry jq fails"
fi
pass "folder color clear cleans up and reports registry failures"

: >"$registry"
if PATH="$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  OMARCHY_FOLDER_COLOR_ICON_BASE="$icon_base" \
  "$ROOT/bin/omarchy-folder-color" set "$folder" red >"$test_tmp/output" 2>&1; then
  fail "folder color set accepts an empty registry with no jq output"
fi
[[ ! -s $registry ]] || fail "folder color set preserves an empty registry after jq produces no output"
assert_no_registry_temp "folder color set removes its temporary registry after jq produces no output"
if grep -Fq "Colored $folder red" "$test_tmp/output"; then
  fail "folder color set reports success after jq produces no output"
fi
pass "folder color set rejects an empty registry and cleans up"

save_color
rm -f "$jq_log"
if PATH="$failing_jq_bin:$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  TEST_JQ_LOG="$jq_log" \
  "$ROOT/bin/omarchy-folder-color" reapply >"$test_tmp/output" 2>&1; then
  fail "folder color reapply hides a registry jq failure"
fi
[[ -s $jq_log ]] || fail "folder color reapply attempts to read the registry"
assert_no_registry_temp "folder color reapply removes its temporary entries after jq fails"
pass "folder color reapply reports registry read failures"

plain_folder="$test_tmp/Projects"
newline_folder="$plain_folder"$'\n'
mkdir "$plain_folder" "$newline_folder"
jq -n '{}' >"$registry"
PATH="$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  OMARCHY_FOLDER_COLOR_ICON_BASE="$icon_base" \
  "$ROOT/bin/omarchy-folder-color" set "$newline_folder" red >"$test_tmp/output"
jq -e --arg path "$newline_folder" 'has($path) and .[$path] == "red"' "$registry" >/dev/null ||
  fail "folder color set preserves a trailing newline in the resolved path"
jq -e --arg path "$plain_folder" 'has($path) | not' "$registry" >/dev/null ||
  fail "folder color set does not color the sibling without a trailing newline"
pass "folder color set preserves trailing newlines in folder names"

jq -n --arg plain "$plain_folder" --arg newline "$newline_folder" \
  '{($plain): "blue", ($newline): "red"}' >"$registry"
PATH="$mock_bin:$PATH" XDG_STATE_HOME="$state_dir" TEST_GIO_LOG="$gio_log" \
  "$ROOT/bin/omarchy-folder-color" clear "$newline_folder" >"$test_tmp/output"
jq -e --arg path "$newline_folder" 'has($path) | not' "$registry" >/dev/null ||
  fail "folder color clear removes the trailing-newline folder entry"
jq -e --arg path "$plain_folder" '.[$path] == "blue"' "$registry" >/dev/null ||
  fail "folder color clear preserves the sibling without a trailing newline"
pass "folder color clear preserves trailing newlines in folder names"
