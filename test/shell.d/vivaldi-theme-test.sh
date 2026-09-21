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

# The channel carries an alpha only when Hyprland has a window opacity set.
write_channel() {
  jq -n --argjson alpha "${1:-null}" '{
    schemaVersion: 1,
    colors: {bg: "#1e1e2e", fg: "#cdd6f4", accent: "#89b4fa", lighterBg: "#313244"},
    radius: -1,
    dimBlurred: true,
    blur: 8,
    contrast: -1,
    alpha: $alpha
  }' >"$CHANNEL"
}

prefs="$PREFS_DIR/Preferences"
jq -n '{
  vivaldi: {
    themes: {
      current: "Vivaldi5",
      user: [
        {id: "v5", name: "Vivaldi5", colorBg: "#ffffff"},
        {
          id: "omarchy-theme",
          name: "Omarchy",
          colorBg: "#000000",
          colorPosition: "tabbar",
          accentSaturationLimit: 0.6,
          accentOnWindow: false,
          transparencyTabBar: true,
          transparencyTabs: false,
          simpleScrollbar: false,
          backgroundImage: "/custom.png",
          backgroundPosition: "center",
          alpha: 0.75
        }
      ]
    }
  }
}' >"$prefs"
chmod 600 "$prefs"

run_theme_set() {
  HOME="$TEST_HOME" PATH="$FAKE_BIN:$PATH" VIVALDI_OMARCHY_JSON="$CHANNEL" \
    bash "$ROOT/bin/omarchy-theme-set-vivaldi"
}

write_channel
run_theme_set

[[ $(stat -c '%a' "$prefs") == "600" ]] || fail "native theme keeps the profile file mode"

jq -e '.vivaldi.theme.schedule.o_s == {light: "omarchy-theme", dark: "omarchy-theme"}' \
  "$prefs" >/dev/null ||
  fail "native theme points both schedule slots at the Omarchy theme"

jq -e '[.vivaldi.themes.user[] | select((.name // "") | startswith("Omarchy"))] | length == 1' \
  "$prefs" >/dev/null ||
  fail "native theme reuses the existing Omarchy theme"

jq -e '.vivaldi.themes.user[] | select(.id == "omarchy-theme")
  | .name == "Omarchy" and .colorBg == "#1e1e2e" and .colorFg == "#cdd6f4"
    and .colorAccentBg == "#313244" and .colorHighlightBg == "#89b4fa"
    and .radius == -1 and .blur == 8 and .contrast == -1
    and .dimBlurred == true and .accentFromPage == false
    and .preferSystemAccent == false' "$prefs" >/dev/null ||
  fail "native theme applies the managed fields"

jq -e '.vivaldi.themes.user[] | select(.id == "omarchy-theme")
  | .colorPosition == "tabbar" and .accentSaturationLimit == 0.6
    and .accentOnWindow == false and .transparencyTabBar == true
    and .transparencyTabs == false and .simpleScrollbar == false
    and .backgroundImage == "/custom.png" and .backgroundPosition == "center"' \
  "$prefs" >/dev/null ||
  fail "native theme preserves the user's Vivaldi theme settings"

jq -e '.vivaldi.themes.user[] | select(.id == "omarchy-theme") | .alpha == 0.75' \
  "$prefs" >/dev/null ||
  fail "native theme keeps the user's transparency when Hyprland sets none"

write_channel 0.4
run_theme_set
jq -e '.vivaldi.themes.user[] | select(.id == "omarchy-theme") | .alpha == 0.4' \
  "$prefs" >/dev/null ||
  fail "native theme mirrors a Hyprland window opacity"

# A brand new theme gets the export defaults, including a coloring mode
# Vivaldi actually recognizes.
jq '.vivaldi.themes.user |= map(select(.id != "omarchy-theme"))' "$prefs" >"$prefs.next" &&
  mv "$prefs.next" "$prefs"
write_channel
run_theme_set
jq -e '.vivaldi.themes.user[] | select(.name == "Omarchy")
  | .colorPosition == "tabbar" and .transparencyTabBar == true
    and .alpha == 0.92 and .colorBg == "#1e1e2e" and .radius == -1' "$prefs" >/dev/null ||
  fail "native theme creates a new theme with valid defaults"

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
