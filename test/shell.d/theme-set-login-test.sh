#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-theme-set-login hands the theme's boot splash and login screen colors
# to omarchy-theme-set-login-colors, letting splash_* keys take precedence over
# the desktop palette and falling through to Tokyo Night's splash defaults.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin" "$test_tmp/home/.local/state/omarchy/current/theme"
colors_file="$test_tmp/home/.local/state/omarchy/current/theme/colors.toml"
system_copy="$test_tmp/system-colors"
call_log="$test_tmp/login-colors.log"

cat >"$test_tmp/bin/omarchy-theme-set-login-colors" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_CALL_LOG"
SH
chmod +x "$test_tmp/bin/omarchy-theme-set-login-colors"

cat >"$test_tmp/bin/id" <<'SH'
#!/bin/bash
if [[ ${1:-} == "-Gn" ]]; then
  echo "wheel"
else
  exec /usr/bin/id "$@"
fi
SH
chmod +x "$test_tmp/bin/id"

run_set_login() {
  : >"$call_log"
  rm -f "$system_copy"
  HOME="$test_tmp/home" \
    PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
    OMARCHY_LOGIN_COLORS_PATH="$system_copy" \
    TEST_CALL_LOG="$call_log" \
    "$ROOT/bin/omarchy-theme-set-login"
}

assert_args() {
  local description=$1 expected=$2 actual
  actual=$(cat "$call_log")
  [[ $actual == "$expected" ]] || fail "$description" "expected: '$expected', got: '$actual'"
  pass "$description"
}

# Tokyo Night's stock colors.toml matches the old Plymouth palette.
cp "$ROOT/themes/tokyo-night/colors.toml" "$colors_file"
run_set_login
assert_args "Tokyo Night resolves to its Plymouth splash colors" "1a1b26 c0caf5 a8cd76 f7768e"

# A theme with no splash_* keys falls through to its standard palette.
cp "$ROOT/themes/catppuccin/colors.toml" "$colors_file"
run_set_login
assert_args "themes without splash_* fall through to their standard palette" "1e1e2e cdd6f4 89b4fa f38ba8"

# Partial splash_* overrides only replace the keys they set.
cat >"$colors_file" <<'EOF'
background = "#101112"
foreground = "#d0d1d2"
accent = "#304050"
red = "#aa1122"
splash_background = "#010203"
splash_error = "#ff0055"
EOF
run_set_login
assert_args "partial splash_* overrides leave other roles falling through" "010203 d0d1d2 304050 ff0055"

# An invalid or overlong splash_* value falls through to the regular key.
cat >"$colors_file" <<'EOF'
background = "#101112"
foreground = "#d0d1d2"
accent = "#304050"
red = "#aa1122"
splash_accent = "not-a-color"
splash_foreground = "#11223344"
EOF
run_set_login
assert_args "invalid and overlong splash_* values fall through to the standard key" "101112 d0d1d2 304050 aa1122"

# Missing keys fall back to the same defaults the real SplashColors.qml loads.
printf 'mode = "dark"\n' >"$colors_file"
run_set_login
helper_defaults=$(cat "$call_log")
assert_args "omitted colors fall back to Tokyo Night splash defaults" "1a1b26 c0caf5 a8cd76 f7768e"

qml_test_runner=""
for candidate in /usr/lib/qt6/bin/qmltestrunner /usr/lib/qt6/qmltestrunner; do
  if [[ -x $candidate ]]; then
    qml_test_runner=$candidate
    break
  fi
done

if [[ -n $qml_test_runner ]]; then
  qml_fixture="$test_tmp/qml"
  mkdir -p "$qml_fixture/Quickshell/Io"
  cat >"$qml_fixture/Quickshell/qmldir" <<'EOF'
module Quickshell
Scope 1.0 Scope.qml
EOF
  cat >"$qml_fixture/Quickshell/Scope.qml" <<'EOF'
import QtQuick
QtObject {
  default property list<QtObject> data
}
EOF
  cat >"$qml_fixture/Quickshell/Io/qmldir" <<'EOF'
module Quickshell.Io
FileView 1.0 FileView.qml
EOF
  cat >"$qml_fixture/Quickshell/Io/FileView.qml" <<'EOF'
import QtQuick
QtObject {
  property string path: ""
  property bool blockLoading: false
  property bool printErrors: false
  function text() { return "" }
}
EOF
  cp "$ROOT/default/splash/ui/SplashColors.qml" "$qml_fixture/"
  cat >"$qml_fixture/tst_splash_defaults.qml" <<EOF
import QtQuick
import QtTest

TestCase {
  name: "SplashColorsDefaults"

  SplashColors {
    id: splash
    path: "/nonexistent/colors"
  }

  function test_defaults_match_login_helper() {
    const actual = [
      splash.colors.background,
      splash.colors.foreground,
      splash.colors.accent,
      splash.colors.error
    ].map(c => c.replace(/^#/, "").toLowerCase()).join(" ")
    compare(actual, "${helper_defaults}")
  }
}
EOF
  qml_out=$(QT_QPA_PLATFORM=offscreen QT_QPA_PLATFORMTHEME= QT_QUICK_BACKEND=software \
    "$qml_test_runner" -import "$qml_fixture" -input "$qml_fixture/tst_splash_defaults.qml" -o -,txt 2>&1) ||
    fail "SplashColors.qml defaults match omarchy-theme-set-login" "$qml_out"
  pass "SplashColors.qml defaults match omarchy-theme-set-login"
else
  skip "Qt6 qmltestrunner not found; skipping SplashColors.qml default check"
fi

# Already-matching system copy skips the privileged write.
cp "$ROOT/themes/tokyo-night/colors.toml" "$colors_file"
printf 'background=#1a1b26\nforeground=#c0caf5\naccent=#a8cd76\nerror=#f7768e\n' >"$system_copy"
: >"$call_log"
HOME="$test_tmp/home" \
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" \
  OMARCHY_LOGIN_COLORS_PATH="$system_copy" \
  TEST_CALL_LOG="$call_log" \
  "$ROOT/bin/omarchy-theme-set-login"
assert_args "matching system colors skip calling omarchy-theme-set-login-colors" ""
