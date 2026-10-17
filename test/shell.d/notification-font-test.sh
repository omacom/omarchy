#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Stub the shell IPC: commit() refreshes the running shell, which does not
# exist under test. Record calls and succeed silently.
printf '%s\n' '#!/bin/bash' 'echo "$@" >>"$OMARCHY_TEST_SHELL_ARGS"' 'exit 0' >"$tmpdir/omarchy-shell"
chmod +x "$tmpdir/omarchy-shell"
touch "$tmpdir/shell-args"

export OMARCHY_TEST_SHELL_ARGS="$tmpdir/shell-args"

# Isolate shell.json writes: omarchy-shell-config resolves the user config
# from $HOME, so point HOME at the scratch dir.
export HOME="$tmpdir"
export PATH="$tmpdir:$ROOT/bin:$PATH"

font() {
  omarchy-notification-font "$@"
}

mode() {
  jq -r '.notifications.font // "default"' "$HOME/.config/omarchy/shell.json"
}

# ------------------------------------------------------------------ CLI

out=$(font show)
[[ $out == *"mode: default"* ]] || fail "notification font show defaults to default mode" "$out"
[[ $out == *"Liberation Sans"* ]] || fail "notification font show resolves the default family" "$out"
pass "notification font show defaults to default mode"

font default >/dev/null
[[ $(mode) == "default" ]] || fail "notification font default persists default mode"
pass "notification font default persists default mode"

font system >/dev/null
[[ $(mode) == "system" ]] || fail "notification font system persists system mode"
pass "notification font system persists system mode"

out=$(font show)
[[ $out == *"mode: system"* ]] || fail "notification font show reports system mode" "$out"
pass "notification font show reports system mode"

mapfile -t installed_families < <(fc-list -f '%{family[0]}\n' | sort -u)
custom_family=${installed_families[0]}
[[ -n $custom_family ]] || fail "custom font test needs an installed family"
font set "$custom_family" >/dev/null
[[ $(mode) == "$custom_family" ]] || fail "notification font set persists a custom family"
pass "notification font set persists a custom family"

if font set "No Such Font XYZ-123" >"$tmpdir/font-error" 2>&1; then
  fail "notification font set rejects unknown families"
fi
[[ $(mode) == "$custom_family" ]] || fail "notification font set leaves the stored mode alone on rejection"
pass "notification font set rejects unknown families"
grep -Fq "Font 'No Such Font XYZ-123' not found." "$tmpdir/font-error" || fail "unknown family has an explanatory error"
pass "unknown family has an explanatory error"

# Fixed font database catches partial-family, style and empty-string matches
# independently of whichever font packages the test machine has installed.
cat >"$tmpdir/fc-list" <<'FONTS'
#!/bin/bash
printf '%s\n' 'Fixture Sans,Fixture Sans Alias' 'Fixture Mono'
FONTS
chmod +x "$tmpdir/fc-list"
for invalid_family in "" "Fixture" "Regular"; do
  if font set "$invalid_family" >"$tmpdir/font-error" 2>&1; then
    fail "reject empty, partial and style names" "$invalid_family"
  fi
  [[ $(mode) == "$custom_family" ]] || fail "invalid family must preserve config"
done
pass "empty, partial and style names are rejected without changing config"
font set "fixture sans alias" >/dev/null
[[ $(mode) == "fixture sans alias" ]] || fail "full aliases are accepted case-insensitively"
pass "full aliases are accepted case-insensitively"
font list | grep -Fx 'Fixture Sans' >/dev/null || fail "proportional families appear in the list"
pass "proportional families appear in the list"
rm "$tmpdir/fc-list"

if font bogus 2>/dev/null; then
  fail "notification font rejects unknown subcommands"
fi
pass "notification font rejects unknown subcommands"

[[ -n $(font list) ]] || fail "notification font list prints families"
pass "notification font list prints families"

# ------------------------------------------------------------- QML wiring

service_qml=$(cat "$ROOT/shell/plugins/notifications/Service.qml")
card_qml=$(cat "$ROOT/shell/plugins/notifications/components/NotificationCard.qml")

grep -q 'shellConfig.notifications' <<<"$service_qml" \
  || fail "notifications service reads the font setting from shellConfig"
pass "notifications service reads the font setting from shellConfig"

grep -q '"default"' <<<"$service_qml" \
  || fail "notifications service falls back to default mode"
pass "notifications service falls back to default mode"

grep -q 'notificationTextFontFamily' <<<"$service_qml" \
  || fail "notifications service resolves a text font family"
pass "notifications service resolves a text font family"

grep -q 'textFontFamily: service.notificationTextFontFamily' <<<"$service_qml" \
  || fail "notifications service passes the resolved font to the card"
pass "notifications service passes the resolved font to the card"

grep -q 'property string textFontFamily: "Liberation Sans"' <<<"$card_qml" \
  || fail "notification card keeps Liberation Sans as the default text font"
pass "notification card keeps Liberation Sans as the default text font"

[[ $(grep -c 'font.family: root.textFontFamily' <<<"$card_qml") == 2 ]] \
  || fail "notification card binds summary and body to the configured font"
pass "notification card binds summary and body to the configured font"

! grep -q 'font.family: "Liberation Sans"' <<<"$card_qml" \
  || fail "notification card has no hardcoded text font literals left"
pass "notification card has no hardcoded text font literals left"

grep -q 'font.family: root.fontFamily' <<<"$card_qml" \
  || fail "notification card keeps glyphs on the system font"
pass "notification card keeps glyphs on the system font"

# Execute the production font-resolution expressions, not a parallel resolver.
node <<'JS'
const fs = require('fs')
const assert = require('assert')
const source = fs.readFileSync(process.env.ROOT + '/shell/plugins/notifications/Service.qml', 'utf8')
function expression(name) {
  const start = source.indexOf('readonly property string ' + name + ': {')
  assert(start >= 0, name)
  const body = source.slice(start).split(': {')[1].split('\n  }')[0]
  return new Function('shell', 'service', 'Style', 'Commons', body)
}
const setting = expression('notificationFontSetting')
const resolve = expression('notificationTextFontFamily')
const shell = { shellConfig: {}, bar: { fontFamily: 'System One' } }
const style = { font: { family: 'System Fallback' } }
const commons = { Color: { notifications: { fontFamily: 'Theme One' } } }
const service = {}
const current = () => {
  service.notificationFontSetting = setting(shell, service, style, commons)
  return resolve(shell, service, style, commons)
}
assert.equal(current(), 'Theme One')
shell.shellConfig.notifications = { font: 'Custom Override' }
assert.equal(current(), 'Custom Override')
commons.Color.notifications.fontFamily = 'Theme Two'
assert.equal(current(), 'Custom Override')
shell.shellConfig.notifications.font = 'default'
assert.equal(current(), 'Theme Two')
shell.shellConfig.notifications.font = 'system'
assert.equal(current(), 'System One')
shell.bar.fontFamily = 'System Two'
assert.equal(current(), 'System Two')
shell.bar = null
assert.equal(current(), 'System Fallback')
shell.shellConfig.notifications.font = ''
commons.Color.notifications.fontFamily = 'Liberation Sans'
assert.equal(current(), 'Liberation Sans')
JS
pass "theme default, custom override and live system font precedence"
