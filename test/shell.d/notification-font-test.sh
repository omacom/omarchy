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

font set "DejaVu Sans" >/dev/null
[[ $(mode) == "DejaVu Sans" ]] || fail "notification font set persists a custom family"
pass "notification font set persists a custom family"

if font set "No Such Font XYZ-123" 2>/dev/null; then
  fail "notification font set rejects unknown families"
fi
[[ $(mode) == "DejaVu Sans" ]] || fail "notification font set leaves the stored mode alone on rejection"
pass "notification font set rejects unknown families"

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
