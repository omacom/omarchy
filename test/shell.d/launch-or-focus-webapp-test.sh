#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
HYPRCTL_LOG="$TMPDIR/hyprctl-log"
WEBAPP_LAUNCH_LOG="$TMPDIR/webapp-launch-log"

# hyprctl answers the client list from a fixture and records the focus dispatch,
# so the assertion is about which window the binding settled on.
cat >"$TMPDIR/bin/hyprctl" <<'SH'
#!/bin/bash
case "$1" in
  clients)
    cat "$HYPRCTL_CLIENTS"
    ;;
  dispatch)
    printf '%s\n' "$*" >>"$HYPRCTL_LOG"
    ;;
esac
SH

cat >"$TMPDIR/bin/omarchy-launch-webapp" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$WEBAPP_LAUNCH_LOG"
SH

chmod +x "$TMPDIR/bin/hyprctl" "$TMPDIR/bin/omarchy-launch-webapp"

# Window classes use the format Chromium gives --app windows: the browser name,
# the URL host, the path, then the profile. The first fixture is the collision
# from the report: an ordinary browser window whose active tab title contains
# "WhatsApp" sits beside the real web app window.
cat >"$TMPDIR/clients-whatsapp.json" <<'JSON'
[
  {"address": "0xbrowser", "class": "brave-browser", "title": "WhatsApp | Secure and Reliable Free Private Messaging and Calling"},
  {"address": "0xwhatsapp", "class": "brave-web.whatsapp.com__-Default", "title": "WhatsApp"}
]
JSON

cat >"$TMPDIR/clients-google.json" <<'JSON'
[
  {"address": "0xbrowser", "class": "brave-browser", "title": "Google Maps - Brave"},
  {"address": "0xmaps", "class": "brave-maps.google.com__-Default", "title": "Google Maps"},
  {"address": "0xphotos", "class": "brave-photos.google.com__-Default", "title": "Google Photos"}
]
JSON

cat >"$TMPDIR/clients-browser-only.json" <<'JSON'
[
  {"address": "0xbrowser", "class": "brave-browser", "title": "WhatsApp | Secure and Reliable Free Private Messaging and Calling"}
]
JSON

# A host must match completely: example.com is not example.com.au. The longer
# host comes first so a prefix match would pick it.
cat >"$TMPDIR/clients-subdomain.json" <<'JSON'
[
  {"address": "0xau", "class": "brave-example.com.au__-Default", "title": "Example AU"},
  {"address": "0xexample", "class": "brave-example.com__-Default", "title": "Example"}
]
JSON

# Two web apps on one host differ by path, and the path is part of the class.
# The calendar window comes first so a host-only match would pick it for the
# root-path binding.
cat >"$TMPDIR/clients-samehost.json" <<'JSON'
[
  {"address": "0xcalendar", "class": "brave-app.hey.com__calendar_weeks_-Default", "title": "Calendar"},
  {"address": "0xmail", "class": "brave-app.hey.com__-Default", "title": "Email"}
]
JSON

# A bracketed IPv6 host is a valid --app target and must not become a broken
# regex.
cat >"$TMPDIR/clients-ipv6.json" <<'JSON'
[
  {"address": "0xipv6", "class": "brave-[::1]__-Default", "title": "Local"}
]
JSON

run_webapp() {
  : >"$HYPRCTL_LOG"
  : >"$WEBAPP_LAUNCH_LOG"

  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  OMARCHY_PATH="$ROOT" \
  HYPRCTL_LOG="$HYPRCTL_LOG" \
  HYPRCTL_CLIENTS="$1" \
  WEBAPP_LAUNCH_LOG="$WEBAPP_LAUNCH_LOG" \
    "$ROOT/bin/omarchy-launch-or-focus-webapp" "${@:2}"
}

run_or_focus() {
  : >"$HYPRCTL_LOG"
  : >"$WEBAPP_LAUNCH_LOG"

  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  OMARCHY_PATH="$ROOT" \
  HYPRCTL_LOG="$HYPRCTL_LOG" \
  HYPRCTL_CLIENTS="$HYPRCTL_CLIENTS" \
  WEBAPP_LAUNCH_LOG="$WEBAPP_LAUNCH_LOG" \
    "$ROOT/bin/omarchy-launch-or-focus" "$@"
}

# The web app window is open, and a browser tab title also says "WhatsApp". The
# web app window is the one to focus: the browser tab must not win a title tie.
run_webapp "$TMPDIR/clients-whatsapp.json" WhatsApp https://web.whatsapp.com/
grep -Fq 'address:0xwhatsapp' "$HYPRCTL_LOG" ||
  fail "the web app window is not the one focused"
! grep -Fq 'address:0xbrowser' "$HYPRCTL_LOG" ||
  fail "a browser tab whose title contains the description is focused instead of the web app"
[[ ! -s $WEBAPP_LAUNCH_LOG ]] ||
  fail "the web app is launched although its window already exists"
pass "a browser tab title cannot win against the web app's own window"

# With the web app window closed, the browser tab title must not stop a launch.
run_webapp "$TMPDIR/clients-browser-only.json" WhatsApp https://web.whatsapp.com/
grep -Fq 'https://web.whatsapp.com/' "$WEBAPP_LAUNCH_LOG" ||
  fail "the web app is not launched when only a lookalike browser tab exists"
! grep -Fq 'address:0xbrowser' "$HYPRCTL_LOG" ||
  fail "the lookalike browser tab is focused instead of launching the web app"
pass "a lookalike browser tab does not stop the web app from launching"

# The class pattern is the URL's host and path, so a second web app on a
# different Google host is neither matched nor shadowed. The URL here has no
# trailing slash, which the browser adds, and the derived path defaults to one.
run_webapp "$TMPDIR/clients-google.json" "Google Maps" https://maps.google.com
grep -Fq 'address:0xmaps' "$HYPRCTL_LOG" ||
  fail "the Google Maps web app is not focused"
! grep -Fq 'address:0xphotos' "$HYPRCTL_LOG" ||
  fail "a web app on a different host with the same browser wins the match"
pass "the host in the URL picks the right web app window"

# Extra arguments after the URL still reach the launcher.
run_webapp "$TMPDIR/clients-browser-only.json" WhatsApp https://web.whatsapp.com/ --new-window
grep -Fq 'https://web.whatsapp.com/ --new-window' "$WEBAPP_LAUNCH_LOG" ||
  fail "arguments after the URL are dropped from the launch"
pass "flags after the URL are passed through to the web app launcher"

# omarchy-launch-or-focus itself keeps its historical class-or-title matching
# for callers that are not web apps.
HYPRCTL_CLIENTS="$TMPDIR/clients-browser-only.json" run_or_focus WhatsApp
grep -Fq 'address:0xbrowser' "$HYPRCTL_LOG" ||
  fail "a plain pattern no longer matches a window title"
pass "plain patterns still match window titles"

# --class is the mode the web app command relies on: class only, never titles.
HYPRCTL_CLIENTS="$TMPDIR/clients-whatsapp.json" run_or_focus --class '-web\.whatsapp\.com'
grep -Fq 'address:0xwhatsapp' "$HYPRCTL_LOG" ||
  fail "--class does not match the window class"
! grep -Fq 'address:0xbrowser' "$HYPRCTL_LOG" ||
  fail "--class falls back to matching titles"
pass "--class matches the window class alone"

# A binding for example.com must not focus example.com.au's window.
run_webapp "$TMPDIR/clients-subdomain.json" Example https://example.com/
grep -Fq 'address:0xexample' "$HYPRCTL_LOG" ||
  fail "the host match does not require the complete host"
! grep -Fq 'address:0xau' "$HYPRCTL_LOG" ||
  fail "a longer host that starts with the requested one is focused"
pass "a host matches completely rather than as a prefix"

# Same host, different paths: each binding finds its own web app.
run_webapp "$TMPDIR/clients-samehost.json" Calendar https://app.hey.com/calendar/weeks/
grep -Fq 'address:0xcalendar' "$HYPRCTL_LOG" ||
  fail "the calendar web app is not focused"
! grep -Fq 'address:0xmail' "$HYPRCTL_LOG" ||
  fail "the other web app on the same host wins the match"
pass "the path in the URL keeps same-host web apps apart"

run_webapp "$TMPDIR/clients-samehost.json" Email https://app.hey.com/
grep -Fq 'address:0xmail' "$HYPRCTL_LOG" ||
  fail "the root-path web app is not focused"
! grep -Fq 'address:0xcalendar' "$HYPRCTL_LOG" ||
  fail "a deeper path on the same host is matched for the root-path web app"
pass "a root-path web app does not match a deeper path on the same host"

# An IPv6 literal host parses into a usable class pattern instead of a broken
# regex that leaves the open web app unfocused.
run_webapp "$TMPDIR/clients-ipv6.json" Local http://[::1]:8080/
grep -Fq 'address:0xipv6' "$HYPRCTL_LOG" ||
  fail "an IPv6 web app window is not focused"
[[ ! -s $WEBAPP_LAUNCH_LOG ]] ||
  fail "an IPv6 web app is launched although its window already exists"
pass "a bracketed IPv6 host is matched"
