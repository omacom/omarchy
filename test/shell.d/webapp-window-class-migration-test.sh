#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1791696584.sh"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
apps="$tmpdir/home/.local/share/applications"
mkdir -p "$apps" "$tmpdir/dotfiles"

entry() {
  printf '[Desktop Entry]\nName=%s\nExec=%s\nType=Application\n' "$1" "$2"
}

entry WhatsApp 'omarchy-launch-webapp https://web.whatsapp.com/' >"$apps/WhatsApp.desktop"
entry Outlook 'omarchy-launch-webapp "https://outlook.office.com/mail/"' >"$apps/Outlook.desktop"
entry Local 'omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors' >"$apps/Local.desktop"
{ entry Named 'omarchy-launch-webapp https://named.example/'; echo 'StartupWMClass=mine'; } >"$apps/Named.desktop"
entry Linked 'omarchy-launch-webapp https://linked.example/' >"$tmpdir/dotfiles/Linked.desktop"
ln -s "$tmpdir/dotfiles/Linked.desktop" "$apps/Linked.desktop"

# Twice, as a retried update would.
for run in 1 2; do
  env -u XDG_DATA_HOME HOME="$tmpdir/home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
done

[[ $(sed -n 3,4p "$apps/WhatsApp.desktop") == $'Exec=omarchy-launch-webapp https://web.whatsapp.com/\nStartupWMClass=chrome-web.whatsapp.com__-Default' ]] ||
  fail "a web app launcher names its window right after Exec" "$(cat "$apps/WhatsApp.desktop")"
grep -Fxq 'StartupWMClass=chrome-outlook.office.com__mail_-Default' "$apps/Outlook.desktop" ||
  fail "a quoted web app URL names its window" "$(cat "$apps/Outlook.desktop")"
[[ $(grep -c '^StartupWMClass=' "$apps/WhatsApp.desktop") == 1 ]] || fail "a second run adds nothing"
pass "web app launchers name their windows once"

! grep -q '^StartupWMClass=' "$apps/Local.desktop" || fail "a custom command is left alone" "$(cat "$apps/Local.desktop")"
[[ $(grep '^StartupWMClass=' "$apps/Named.desktop") == "StartupWMClass=mine" ]] || fail "a class the launcher already names is kept"
pass "custom commands and existing classes are left alone"

[[ -L $apps/Linked.desktop ]] && grep -Fxq 'StartupWMClass=chrome-linked.example__-Default' "$tmpdir/dotfiles/Linked.desktop" ||
  fail "a symlinked launcher stays linked and its target is updated" "$(ls -l "$apps/Linked.desktop")"
pass "a symlinked launcher stays linked and its target is updated"
