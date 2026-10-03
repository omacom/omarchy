#!/bin/bash

source "$(dirname "$0")/base-test.sh"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

FAKE_BIN="$TEST_HOME/bin"
CURRENT_THEME="$TEST_HOME/.local/state/omarchy/current/theme"
USER_DIR="$TEST_HOME/.config/sublime-text/Packages/User"
mkdir -p "$FAKE_BIN" "$CURRENT_THEME"
printf '{ "name": "Omarchy" }\n' >"$CURRENT_THEME/Omarchy.sublime-color-scheme"

cat >"$FAKE_BIN/omarchy-toggle-enabled" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$FAKE_BIN/omarchy-font-current" <<'EOF'
#!/bin/bash
printf 'JetBrains Mono\n'
EOF

chmod +x "$FAKE_BIN"/*

run_setter() {
  PATH="$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" "$ROOT/bin/omarchy-theme-set-sublime"
}

cat >"$FAKE_BIN/omarchy-cmd-present" <<'EOF'
#!/bin/bash
exit 1
EOF
chmod +x "$FAKE_BIN/omarchy-cmd-present"
run_setter
[[ ! -e $USER_DIR/Omarchy.sublime-color-scheme ]] || fail "Sublime theme sync skips when Sublime is not installed"
pass "Sublime theme sync no-ops without Sublime"

cat >"$FAKE_BIN/omarchy-cmd-present" <<'EOF'
#!/bin/bash
[[ $1 == "sublime_text" ]]
EOF
chmod +x "$FAKE_BIN/omarchy-cmd-present"
run_setter

[[ -f $USER_DIR/Omarchy.sublime-color-scheme ]] || fail "Sublime theme sync copies the rendered color scheme"
grep -Fq '"color_scheme": "Omarchy.sublime-color-scheme"' "$USER_DIR/Preferences.sublime-settings" ||
  fail "Sublime theme sync seeds the Omarchy color scheme"
grep -Fq '"font_face": "JetBrains Mono"' "$USER_DIR/Preferences.sublime-settings" ||
  fail "Sublime theme sync seeds the current Omarchy font"
pass "Sublime theme sync seeds scheme and font for a new User package"

printf '{\n\t"ignored_packages": ["Vintage"],\n\t"color_scheme": "old"\n}\n' >"$USER_DIR/Preferences.sublime-settings"
run_setter
grep -Fq '"ignored_packages": ["Vintage"]' "$USER_DIR/Preferences.sublime-settings" ||
  fail "Sublime theme sync preserves unrelated preferences"
grep -Fq '"color_scheme": "Omarchy.sublime-color-scheme"' "$USER_DIR/Preferences.sublime-settings" ||
  fail "Sublime theme sync replaces an existing color scheme"
pass "Sublime theme sync patches prefs without replacing the file"

cat >"$FAKE_BIN/omarchy-toggle-enabled" <<'EOF'
#!/bin/bash
[[ $1 == "skip-sublime-theme-changes" ]]
EOF
chmod +x "$FAKE_BIN/omarchy-toggle-enabled"
rm -f "$USER_DIR/Omarchy.sublime-color-scheme"
printf '{\n\t"color_scheme": "keep"\n}\n' >"$USER_DIR/Preferences.sublime-settings"
run_setter
[[ ! -e $USER_DIR/Omarchy.sublime-color-scheme ]] || fail "Sublime theme sync honors skip-sublime-theme-changes"
grep -Fq '"color_scheme": "keep"' "$USER_DIR/Preferences.sublime-settings" ||
  fail "Sublime theme sync leaves prefs alone when skipped"
pass "Sublime theme sync honors skip-sublime-theme-changes"
