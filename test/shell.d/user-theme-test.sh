#!/bin/bash

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
theme_dir="$test_tmp/home/.local/state/omarchy/current/theme"
mkdir -p "$mock_bin" "$test_tmp/home/.config/chromium" "$theme_dir"
printf '{}\n' >"$theme_dir/opencode.json"

cat >"$mock_bin/omarchy-theme-set" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_THEME_CALLS"
SH
chmod +x "$mock_bin/omarchy-theme-set"

for command in omarchy-theme-set-pi omarchy-theme-set-fcitx5 omarchy-theme-set-qt; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
  chmod +x "$mock_bin/$command"
done

calls="$test_tmp/theme-calls"
export OPENCODE_CONFIG_DIR="$test_tmp/home/.config/opencode"
export XDG_RUNTIME_DIR="$test_tmp/runtime"
mkdir -p "$XDG_RUNTIME_DIR"
test_path="$mock_bin:$ROOT/bin:$PATH"
touch "$test_tmp/home/.config/chromium/SingletonLock"
HOME="$test_tmp/home" PATH="$test_path" OMARCHY_TEST_THEME_CALLS="$calls" \
  bash -e "$ROOT/install/user/theme.sh"
grep -Fx 'Tokyo Night' "$calls" >/dev/null || fail "user theme setup seeds Tokyo Night when no theme exists"
[[ -f $test_tmp/home/.config/chromium/SingletonLock ]] || fail "runtime user theme setup preserves Chromium's singleton lock"

: >"$calls"
printf 'Solitude\n' >"$test_tmp/home/.local/state/omarchy/current/theme.name"
rm "$theme_dir/opencode.json"
if ! HOME="$test_tmp/home" PATH="$test_path" OMARCHY_TEST_THEME_CALLS="$calls" \
  bash -e "$ROOT/install/user/theme.sh" >"$test_tmp/theme.log" 2>&1; then
  fail "user theme setup must not fail when a saved theme lacks the OpenCode palette" "$(cat "$test_tmp/theme.log")"
fi
grep -F 'OpenCode theme activation skipped' "$test_tmp/theme.log" >/dev/null || fail "user theme setup must skip activation when the saved theme has no palette"
[[ ! -s $calls ]] || fail "user theme setup preserves an existing theme"

pass "user theme setup only seeds the default theme once and tolerates a missing OpenCode palette"
