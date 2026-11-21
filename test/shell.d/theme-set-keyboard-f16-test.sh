#!/bin/bash

source "$(dirname "$0")/base-test.sh"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

FAKE_BIN="$TEST_HOME/bin"
CURRENT_THEME="$TEST_HOME/.local/state/omarchy/current/theme"
QMK_LOG="$TEST_HOME/qmk.log"
mkdir -p "$FAKE_BIN" "$CURRENT_THEME"

cat >"$FAKE_BIN/omarchy-cmd-present" <<'EOF'
#!/bin/bash
[[ $1 == "qmk_hid" ]]
EOF

cat >"$FAKE_BIN/omarchy-hw-framework16" <<'EOF'
#!/bin/bash
[[ -z $NOT_FRAMEWORK16 ]]
EOF

cat >"$FAKE_BIN/qmk_hid" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$QMK_LOG"
EOF

cat >"$FAKE_BIN/python3" <<'EOF'
#!/bin/bash
echo "python3 started" >>"$QMK_LOG"
exit 1
EOF

chmod +x "$FAKE_BIN"/*

apply_keyboard_color() {
  rm -f "$QMK_LOG"
  QMK_LOG="$QMK_LOG" PATH="$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" "$ROOT/bin/omarchy-theme-set-keyboard-f16"
}

qmk_calls() {
  [[ -f $QMK_LOG ]] && cat "$QMK_LOG"
}

expected_calls() {
  printf -- '--vid 32ac --pid 0012 via %s\n' "--rgb-effect 1" "--rgb-hue $1" "--rgb-saturation $2" "--rgb-brightness 100" "--save"
}

# Hue and saturation are what Python's colorsys gave for each colour.
for case in "#7aa2f7 156 129" "FF9F0A 25 245" "#004b1e 101 255" "#808080 0 0" "#ff0001 254 255"; do
  read -r color hue saturation <<<"$case"
  echo "$color" >"$CURRENT_THEME/keyboard.rgb"
  apply_keyboard_color
  [[ $(qmk_calls) == "$(expected_calls "$hue" "$saturation")" ]] || \
    fail "Framework 16 keyboard gets $color as QMK hue and saturation" "$(qmk_calls)"
done
pass "Framework 16 keyboard gets the theme colour as QMK hue and saturation without Python"

echo "not-a-colour" >"$CURRENT_THEME/keyboard.rgb"
apply_keyboard_color
[[ -z $(qmk_calls) ]] || fail "Framework 16 keyboard ignores a malformed colour" "$(qmk_calls)"
pass "Framework 16 keyboard ignores a malformed colour"

echo "#7aa2f7" >"$CURRENT_THEME/keyboard.rgb"
NOT_FRAMEWORK16=1 apply_keyboard_color
[[ -z $(qmk_calls) ]] || fail "Only a Framework 16 gets the keyboard colour" "$(qmk_calls)"
pass "Only a Framework 16 gets the keyboard colour"
