#!/bin/bash

source "$(dirname "$0")/base-test.sh"

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

FAKE_BIN="$TEST_HOME/bin"
mkdir -p "$FAKE_BIN" "$TEST_HOME/.local/state/omarchy/current/theme"
printf ':root { --toolbar-color: red; }\n' >"$TEST_HOME/.local/state/omarchy/current/theme/firefox-userChrome.css"

# A browser left running by whoever runs the suite must not notify them.
printf '#!/bin/bash\n' >"$FAKE_BIN/omarchy-notification-send"
chmod +x "$FAKE_BIN/omarchy-notification-send"

# Zen's profiles.ini as Zen writes it: an install section without a path, a
# relative path with spaces, and an absolute profile elsewhere.
zen="$TEST_HOME/.config/zen"
relative="$zen/qr64izak.Default (release)"
absolute="$TEST_HOME/elsewhere/work profile"
mkdir -p "$relative/chrome" "$absolute"
cat >"$zen/profiles.ini" <<EOF
[Profile0]
Name=Default (release)
IsRelative=1
Path=qr64izak.Default (release)

[Install15B76BAA26BA15E7]
Default=qr64izak.Default (release)
Locked=1

[Profile1]
Name=Work
IsRelative=0
Path=$absolute
EOF
printf '#urlbar { display: none; }\n' >"$relative/chrome/userChrome.css"

sync_firefox() {
  PATH="$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" "$ROOT/bin/omarchy-theme-set-firefox" ||
    fail "Firefox theme sync succeeds"
}

sync_firefox
sync_firefox

for profile in "$relative" "$absolute"; do
  cmp -s "$TEST_HOME/.local/state/omarchy/current/theme/firefox-userChrome.css" "$profile/chrome/omarchy.css" ||
    fail "Firefox theme sync themes every profile in profiles.ini" "$profile"
  [[ $(grep -c 'legacyUserProfileCustomizations' "$profile/user.js") == "1" ]] ||
    fail "Firefox theme sync enables userChrome.css once" "$(cat "$profile/user.js")"
done
pass "Firefox theme sync themes relative and absolute profiles"

[[ $(<"$absolute/chrome/userChrome.css") == '@import "omarchy.css";' ]] ||
  fail "Firefox theme sync creates a userChrome.css that imports the theme"
[[ $(<"$relative/chrome/userChrome.css") == $'@import "omarchy.css";\n#urlbar { display: none; }' ]] ||
  fail "Firefox theme sync imports the theme above the user's own rules, once" "$(cat "$relative/chrome/userChrome.css")"
pass "Firefox theme sync keeps the user's userChrome.css"

# A failed temporary copy must leave the user's stylesheet as it was and be
# reported, so omarchy-theme-set names the failed retint.
FAILING_BIN="$TEST_HOME/failing-bin"
mkdir -p "$FAILING_BIN"
printf '#!/bin/bash\nexit 1\n' >"$FAILING_BIN/mktemp"
chmod +x "$FAILING_BIN/mktemp"
printf '#urlbar { display: none; }\n' >"$relative/chrome/userChrome.css"
if PATH="$FAILING_BIN:$FAKE_BIN:$ROOT/bin:$PATH" HOME="$TEST_HOME" "$ROOT/bin/omarchy-theme-set-firefox" 2>/dev/null; then
  fail "Firefox theme sync reports a profile it could not theme"
fi
[[ $(<"$relative/chrome/userChrome.css") == "#urlbar { display: none; }" ]] ||
  fail "Firefox theme sync keeps userChrome.css when its copy fails" "$(cat "$relative/chrome/userChrome.css")"
pass "Firefox theme sync keeps userChrome.css when its copy fails"

rm -rf "$absolute/chrome"
mkdir -p "$TEST_HOME/.local/state/omarchy/toggles"
touch "$TEST_HOME/.local/state/omarchy/toggles/skip-firefox-theme-changes"
sync_firefox
[[ ! -e $absolute/chrome ]] || fail "Firefox theme sync leaves profiles alone when skipped by its toggle"
pass "Firefox theme sync leaves profiles alone when skipped by its toggle"
