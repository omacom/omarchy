#!/bin/bash

source "$(dirname "$0")/base-test.sh"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

FAKE_BIN="$TEST_HOME/bin"
PREFS_DIR="$TEST_HOME/.config/vivaldi/Default"
CHANNEL="$TEST_HOME/channel.json"
mkdir -p "$FAKE_BIN" "$PREFS_DIR"

cat >"$FAKE_BIN/pgrep" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$FAKE_BIN/omarchy-theme-current" <<'EOF'
#!/bin/bash
echo "Catppuccin"
EOF

cat >"$FAKE_BIN/omarchy-theme-color" <<'EOF'
#!/bin/bash
case $1 in
  background) echo "#1e1e2e" ;;
  foreground) echo "#cdd6f4" ;;
  accent) echo "#89b4fa" ;;
  lighter_background) echo "#313244" ;;
esac
EOF

chmod +x "$FAKE_BIN"/*

jq -n '{
  schemaVersion: 1,
  colors: {bg: "#1e1e2e", fg: "#cdd6f4", accent: "#89b4fa", lighterBg: "#313244"},
  radius: -1,
  dimBlurred: true,
  blur: 8,
  contrast: -1,
  alpha: 0.4
}' >"$CHANNEL"

prefs="$PREFS_DIR/Preferences"
jq -n '{
  vivaldi: {
    themes: {
      current: "Vivaldi5",
      user: [{id: "v5", name: "Vivaldi5", colorBg: "#ffffff"}]
    }
  }
}' >"$prefs"
chmod 600 "$prefs"

run_theme_set() {
  HOME="$TEST_HOME" PATH="$FAKE_BIN:$PATH" VIVALDI_OMARCHY_JSON="$CHANNEL" \
    bash "$ROOT/bin/omarchy-theme-set-vivaldi"
}

count_omarchy_themes() {
  jq '[.vivaldi.themes.user[]
       | select((.name // "") | startswith("Omarchy"))] | length' "$prefs"
}

run_theme_set

[[ $(stat -c '%a' "$prefs") == "600" ]] || fail "native theme keeps the profile file mode"

theme_id=$(jq -r '.vivaldi.theme.schedule.o_s.light' "$prefs")
[[ -n $theme_id && $theme_id != "null" ]] || fail "native theme activates the Omarchy theme"

jq -e --arg id "$theme_id" \
  '.vivaldi.theme.schedule.o_s == {light: $id, dark: $id}' "$prefs" >/dev/null ||
  fail "native theme points both schedule slots at the Omarchy theme"

jq -e --arg id "$theme_id" \
  '.vivaldi.themes.user[] | select(.id == $id)
   | .colorBg == "#1e1e2e" and .colorFg == "#cdd6f4"
     and .colorAccentBg == "#313244" and .colorHighlightBg == "#89b4fa"' \
  "$prefs" >/dev/null ||
  fail "native theme applies the current colors"

jq -e --arg id "$theme_id" \
  '.vivaldi.themes.user[] | select(.id == $id)
   | .radius == -1 and .blur == 8 and .contrast == -1
     and .dimBlurred == true and .alpha == 0.4' \
  "$prefs" >/dev/null ||
  fail "native theme applies the Hyprland appearance"

grep -q 'Omarchy Catppuccin' "$prefs" || fail "native theme names the theme after the current one"

run_theme_set
[[ $(count_omarchy_themes) == "1" ]] || fail "native theme reuses the existing Omarchy theme"

# A channel written before it carried transparency keeps Vivaldi's own default.
jq 'del(.alpha)' "$CHANNEL" >"$CHANNEL.next" && mv "$CHANNEL.next" "$CHANNEL"
run_theme_set
jq -e --arg id "$theme_id" \
  '.vivaldi.themes.user[] | select(.id == $id) | .alpha == 0.92' \
  "$prefs" >/dev/null ||
  fail "native theme falls back to Vivaldi's default transparency"

# A theme set while Vivaldi runs would be discarded on exit, so it must not be
# written then.
cat >"$FAKE_BIN/pgrep" <<'EOF'
#!/bin/bash
exit 0
EOF
chmod +x "$FAKE_BIN/pgrep"
before=$(cat "$prefs")
run_theme_set
[[ $(cat "$prefs") == "$before" ]] || fail "native theme skips writing while Vivaldi runs"

pass "Vivaldi native theme follows the Omarchy theme"
