#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
home_a="$test_tmp/user-a"
home_b="$test_tmp/user-b"
mkdir -p "$mock_bin"
export TEST_JQ
TEST_JQ=$(type -P jq)

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-theme-color" <<'SH'
#!/bin/bash
case $1 in
  background) echo "${CHANNEL_COLOR:-#1e1e2e}" ;;
  foreground) echo '#ffffff' ;;
  accent) echo '#00aaff' ;;
  lighter_background) echo '#555555' ;;
esac
SH
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
case $3 in
  decoration:rounding) printf '{"int":%s}\n' "${CHANNEL_RADIUS:-0}" ;;
  decoration:dim_inactive) echo '{"bool":false}' ;;
  decoration:blur:enabled) echo '{"bool":true}' ;;
  decoration:blur:size) echo '{"int":3}' ;;
  decoration:blur:contrast) echo '{"float":1.0}' ;;
  decoration:active_opacity) echo '{"float":0.75,"set":true}' ;;
esac
SH
cat >"$mock_bin/jq" <<'SH'
#!/bin/bash
if [[ $1 == "-n" && ${FAIL_CHANNEL:-0} == "1" ]]; then
  printf 'incomplete JSON\n'
  exit 1
fi
exec "$TEST_JQ" "$@"
SH
chmod +x "$mock_bin"/*

for home in "$home_a" "$home_b"; do
  mkdir -p "$home/.config/vivaldi/Default"
  printf '{}\n' >"$home/.config/vivaldi/Default/Preferences"
  chmod 600 "$home/.config/vivaldi/Default/Preferences"
done

run_refresh() {
  HOME="$1" CHANNEL_COLOR="$2" CHANNEL_RADIUS="$3" OMARCHY_PATH="$ROOT" \
    PATH="$mock_bin:$ROOT/bin:$PATH" env -u VIVALDI_OMARCHY_JSON \
    bash "$ROOT/default/vivaldi/vivaldi-theme-refresh"
}

channel_a="$home_a/.local/state/omarchy/vivaldi/theme.json"
channel_b="$home_b/.local/state/omarchy/vivaldi/theme.json"
prefs_a="$home_a/.config/vivaldi/Default/Preferences"
prefs_b="$home_b/.config/vivaldi/Default/Preferences"
run_refresh "$home_a" '#123456' 0
run_refresh "$home_b" '#abcdef' 7
for channel in "$channel_a" "$channel_b"; do
  [[ $(stat -c '%a' "$(dirname "$channel")") == "700" ]] ||
    fail "the Vivaldi channel directory is private"
  [[ $(stat -c '%a' "$channel") == "600" ]] || fail "the Vivaldi channel is private"
done
jq -e '.colors.bg == "#123456" and .radius == -1' "$channel_a" >/dev/null ||
  fail "the first user has its own palette and appearance"
jq -e '.colors.bg == "#abcdef" and .radius == 7' "$channel_b" >/dev/null ||
  fail "the second user has its own palette and appearance"
jq -e '.vivaldi.themes.user[] | .colorBg == "#123456" and .radius == -1' \
  "$prefs_a" >/dev/null || fail "the native writer reads the first user's private channel"
jq -e '.vivaldi.themes.user[] | .colorBg == "#abcdef" and .radius == 7' \
  "$prefs_b" >/dev/null || fail "the native writer reads the second user's private channel"
pass "live channels and native themes keep each user's colors and appearance separate"

before_b=$(cat "$channel_b" "$prefs_b")
chmod 755 "$(dirname "$channel_a")"
chmod 664 "$channel_a"
run_refresh "$home_a" '#654321' 9
[[ $(cat "$channel_b" "$prefs_b") == "$before_b" ]] ||
  fail "a refresh does not change another user's channel or preferences"
[[ $(stat -c '%a' "$(dirname "$channel_a")") == "700" ]] ||
  fail "refresh tightens an existing channel directory"
[[ $(stat -c '%a' "$channel_a") == "600" ]] ||
  fail "refresh replaces an existing channel with a private file"
pass "refresh updates only the caller's channel and preserves private permissions"

before_a=$(cat "$channel_a" "$prefs_a")
if FAIL_CHANNEL=1 run_refresh "$home_a" '#112233' 4; then
  fail "a failed channel write reports failure"
fi
[[ $(cat "$channel_a" "$prefs_a") == "$before_a" ]] ||
  fail "a failed channel write leaves the last channel and native preferences intact"
shopt -s nullglob
staged=("$(dirname "$channel_a")"/.theme.*)
(( ${#staged[@]} == 0 )) || fail "a failed channel write removes its temporary file"
pass "channel writes are atomic and clean up failed staging files"

mv "$channel_a" "$test_tmp/saved-channel"
mkdir "$channel_a"
if run_refresh "$home_a" '#112233' 4 2>/dev/null; then
  fail "a directory at the channel path does not masquerade as a successful write"
fi
rmdir "$channel_a"
mv "$test_tmp/saved-channel" "$channel_a"
[[ $(cat "$channel_a" "$prefs_a") == "$before_a" ]] ||
  fail "a failed publish leaves the previous channel and native preferences intact"
pass "a failed channel publish reports failure without changing native preferences"

# Run the real hook against a disposable resources directory, never /opt.
test_ui="$test_tmp/ui"
mkdir -p "$test_ui/style"
cat >"$test_ui/window.html" <<'HTML'
<!DOCTYPE html>
<html>
<head>
</head>
<body>
</body>
</html>
HTML
printf 'legacy\n' >"$test_ui/style/omarchy.csv"
printf '{}\n' >"$test_ui/style/omarchy.json"
sed 's|^VIVALDI_UI=.*|VIVALDI_UI=$TEST_VIVALDI_UI|' \
  "$ROOT/default/vivaldi/vivaldi-post-update" >"$test_tmp/post-update"
cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat >"$mock_bin/omarchy-theme-set-browser" <<'SH'
#!/bin/bash
"$OMARCHY_PATH/default/vivaldi/vivaldi-theme-refresh"
SH
chmod +x "$mock_bin"/*
for home in "$home_a" "$home_b"; do
  HOME="$home" PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
    TEST_VIVALDI_UI="$test_ui" env -u VIVALDI_OMARCHY_JSON \
    bash "$test_tmp/post-update"
  [[ ! -e $test_ui/style/omarchy.json && ! -e $test_ui/style/omarchy.csv ]] ||
    fail "the hook removes shared channels instead of assigning them to its caller"
done
cmp -s "$ROOT/default/vivaldi/omarchy-theme-loader.js" "$test_ui/style/omarchy.js" ||
  fail "the hook installs the same user-independent loader"
[[ $(grep -Fc '<script src="style/omarchy.js">' "$test_ui/window.html") == "1" ]] ||
  fail "repeated hooks install only one loader"
[[ $(grep -Fc 'id="omarchy-theme"' "$test_ui/window.html") == "1" ]] ||
  fail "repeated hooks install only one theme style"
pass "post-update installs only shared code and retires the shared theme data"
