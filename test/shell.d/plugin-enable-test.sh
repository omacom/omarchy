#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/home" "$TMPDIR/bin"
calls="$TMPDIR/calls"

cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
printf 'ok\n'
SH
chmod +x "$TMPDIR/bin/omarchy-shell"

run_enable() {
  HOME="$TMPDIR/home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_CALLS="$calls" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    omarchy-plugin-enable "$@"
}

run_enable omarchy.active-window --section right >/dev/null
grep -Fqx 'shell enablePlugin omarchy.active-window {"section":"right"}' "$calls" ||
  fail "plugin enable did not combine activation and placement"
pass "plugin enable combines activation and placement in one shell mutation"

run_enable omarchy.clock --before omarchy.weather >/dev/null
grep -Fqx 'shell enablePlugin omarchy.clock {"before":"omarchy.weather"}' "$calls" ||
  fail "plugin enable did not preserve relative placement"
pass "plugin enable forwards relative placement"

run_enable omarchy.dropbox >/dev/null
grep -Fqx 'shell enablePlugin omarchy.dropbox {}' "$calls" ||
  fail "plugin enable did not use manifest-default placement"
pass "plugin enable leaves default placement to the registry"

if run_enable omarchy.bar --section right >/dev/null 2>&1; then
  fail "plugin enable accepted placement for a full bar"
fi
pass "plugin enable rejects placement for full bars"

hint_dir="$TMPDIR/home/.config/omarchy/plugins/acme.hint"
mkdir -p "$hint_dir"
cat >"$hint_dir/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.hint",
  "name": "Hint",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "postEnable": "Jump on connect needs a Hyprland loader.\n  ~/.config/omarchy/plugins/seanpk.dock-workspaces/bin/install-loader"
}
JSON
printf 'import QtQuick\nItem {}\n' >"$hint_dir/Widget.qml"

hint_out=$(run_enable acme.hint)
[[ $hint_out == *"Enabled acme.hint"* ]] ||
  fail "plugin enable still reports Enabled" "$hint_out"
[[ $hint_out == *"install-loader"* ]] ||
  fail "plugin enable did not print postEnable" "$hint_out"
[[ $hint_out != *$'\033'* ]] ||
  fail "plugin enable left an escape in postEnable" "$hint_out"
pass "plugin enable prints a plugin's postEnable text"

utf8_dir="$TMPDIR/home/.config/omarchy/plugins/acme.utf8"
mkdir -p "$utf8_dir"
cat >"$utf8_dir/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.utf8",
  "name": "UTF-8 hint",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "postEnable": "Open Setup › Plugins, then run café-setup"
}
JSON
printf 'import QtQuick\nItem {}\n' >"$utf8_dir/Widget.qml"

utf8_out=$(LANG=C.UTF-8 run_enable acme.utf8)
[[ $utf8_out == *"Open Setup › Plugins, then run café-setup"* ]] ||
  fail "plugin enable keeps non-ASCII postEnable text" "$utf8_out"
pass "plugin enable keeps non-ASCII postEnable text"

esc_dir="$TMPDIR/home/.config/omarchy/plugins/acme.esc"
mkdir -p "$esc_dir"
cat >"$esc_dir/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.esc",
  "name": "Escape hint",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "postEnable": "\u001b]0;pwned\u0007\tRun install-loader\r"
}
JSON
printf 'import QtQuick\nItem {}\n' >"$esc_dir/Widget.qml"

esc_out=$(run_enable acme.esc)
[[ $esc_out == *"Run install-loader"* && $esc_out == *$'\t'* ]] ||
  fail "plugin enable prints the sanitized postEnable text" "$esc_out"
[[ $esc_out != *$'\033'* && $esc_out != *$'\a'* && $esc_out != *$'\r'* ]] ||
  fail "plugin enable strips control bytes from postEnable" "$(printf '%q' "$esc_out")"
pass "plugin enable strips control bytes from postEnable"

cap_dir="$TMPDIR/home/.config/omarchy/plugins/acme.cap"
mkdir -p "$cap_dir"
cap_note="$(printf 'A%.0s' {1..2000})TAIL"
jq -n --arg note "$cap_note" '{
  schemaVersion: 1,
  id: "acme.cap",
  name: "Cap hint",
  version: "1.0.0",
  kinds: ["bar-widget"],
  entryPoints: { barWidget: "Widget.qml" },
  postEnable: $note
}' >"$cap_dir/manifest.json"
printf 'import QtQuick\nItem {}\n' >"$cap_dir/Widget.qml"

cap_out=$(run_enable acme.cap)
[[ $cap_out == *"$(printf 'A%.0s' {1..2000})"* ]] ||
  fail "plugin enable keeps a 2000-character postEnable note" "$cap_out"
[[ $cap_out != *TAIL* ]] ||
  fail "plugin enable did not cap postEnable at 2000 characters" "$cap_out"
pass "plugin enable caps postEnable at 2000 characters"
