#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'MOCK'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  printf '%s\n' "$OMARCHY_TEST_CLIENTS_JSON"
elif [[ $1 == "dispatch" ]]; then
  printf '%s\n' "${*:2}" >>"$OMARCHY_TEST_FOCUS_DISPATCH"
  if [[ $2 != "focuswindow" && ${OMARCHY_TEST_FOCUS_FALLBACK:-0} == "1" ]]; then
    exit 1
  fi
fi
MOCK
for command in setsid omarchy-launch-floating-terminal-with-presentation; do
  cat >"$mock_bin/$command" <<'MOCK'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_LAUNCH"
MOCK
done
chmod +x "$mock_bin"/*

# Only redirect the installation check and native launch path; exercise the
# real Spotify branch logic and the checkout's shared helpers.
spotify_binary="$test_tmp/spotify"
sed "s|/usr/bin/spotify|$spotify_binary|g" "$ROOT/bin/omarchy-launch-spotify" >"$test_tmp/launch-spotify"

dispatch_log="$test_tmp/dispatch"
launch_log="$test_tmp/launch"
stderr_log="$test_tmp/stderr"

run_launcher() {
  local launcher="$ROOT/bin/$1"
  local clients_json="$2"
  shift 2
  if [[ $launcher == "$ROOT/bin/omarchy-launch-spotify" ]]; then
    launcher="$test_tmp/launch-spotify"
  fi
  rm -f "$dispatch_log" "$launch_log"
  PATH="$mock_bin:$ROOT/bin:$PATH" OMARCHY_TEST_CLIENTS_JSON="$clients_json" \
    OMARCHY_TEST_FOCUS_DISPATCH="$dispatch_log" OMARCHY_TEST_LAUNCH="$launch_log" \
    bash "$launcher" "$@" 2>"$stderr_log" || fail "launcher succeeds" "$(cat "$stderr_log")"
  [[ ! -s $stderr_log ]] || fail "launcher emits no errors" "$(cat "$stderr_log")"
}

assert_focus() {
  grep -F "address:$1" "$dispatch_log" >/dev/null || fail "focuses $1"
  [[ ! -e $launch_log ]] || fail "does not launch a duplicate"
  pass "$2"
}

assert_launch() {
  [[ ! -e $dispatch_log ]] || fail "does not focus a false match"
  [[ $(cat "$launch_log") == "$1" ]] || fail "launches the expected command" "$(cat "$launch_log")"
  pass "$2"
}

printf '#!/bin/bash\n' >"$spotify_binary"
chmod +x "$spotify_binary"
false_spotify='[
  {"address":"0xplugin","class":"org.quickshell","title":"Spotify"},
  {"address":"0xbrowser","class":"chromium","title":"Spotify"}
]'
clients_json=$(jq '. + [{"address":"0xspotify","class":"Spotify","title":"Liked Songs"}]' <<<"$false_spotify")
run_launcher omarchy-launch-spotify "$clients_json"
assert_focus 0xspotify "native Spotify skips plugin and browser titles"
run_launcher omarchy-launch-spotify "$false_spotify"
assert_launch "uwsm-app -- $spotify_binary" "native Spotify launches when only false matches exist"

rm "$spotify_binary"
clients_json='[
  {"address":"0xplugin","class":"ORG.QUICKSHELL","title":"Spotify"},
  {"address":"0xwebapp","class":"chromium","title":"Spotify"}
]'
run_launcher omarchy-launch-spotify "$clients_json"
assert_focus 0xwebapp "Spotify web app preserves title matching"
run_launcher omarchy-launch-spotify '[{"address":"0xplugin","class":"Org.Quickshell","title":"Spotify"}]'
assert_launch "omarchy-launch-webapp https://open.spotify.com/" "Spotify web app launches when only a plugin matches"

for signal_class in signal signal-desktop; do
  clients_json=$(jq -n --arg class "$signal_class" '[
    {"address":"0xplugin","class":"org.quickshell","title":"Signal"},
    {"address":"0xbrowser","class":"chromium","title":"Signal"},
    {"address":"0xsignal","class":$class,"title":"Alice"}
  ]')
  run_launcher omarchy-launch-signal "$clients_json"
  assert_focus 0xsignal "Signal recognizes $signal_class behind title-only false matches"
done

run_launcher omarchy-launch-signal '[
  {"address":"0xplugin","class":"ORG.QUICKSHELL","title":"Signal"},
  {"address":"0xbrowser","class":"chromium","title":"Signal"}
]'
if [[ -x /usr/bin/signal-desktop ]]; then
  assert_launch "uwsm-app -- /usr/bin/signal-desktop" "Signal launches when only false matches exist"
else
  assert_launch "omarchy-install-service-signal" "Signal offers installation when only false matches exist"
fi

# Invalid fields precede the match, so jq cannot emit the expected address
# before failing. Capture stderr too: the head pipeline can hide jq's status.
for fields in '[{},{"class":null,"title":null}]' '[{"class":"other"},{"class":"other","title":null}]'; do
  clients_json=$(jq '. + [{"address":"0xvalid","class":"chromium","title":"Calendar"}]' <<<"$fields")
  run_launcher omarchy-launch-or-focus "$clients_json" Calendar calendar-launch-command
  assert_focus 0xvalid "default matching handles incomplete fields: $fields"
done

clients_json='[
  {},
  {"class":null,"title":null},
  {"address":"0xvalid","class":"Calendar"}
]'
for mode in default class-only; do
  args=()
  if [[ $mode == "class-only" ]]; then
    args+=(--class-only)
  fi
  run_launcher omarchy-launch-or-focus "$clients_json" "${args[@]}" Calendar calendar-launch-command
  assert_focus 0xvalid "$mode matching handles missing classes and a titleless valid client"
done
run_launcher omarchy-launch-signal '[{},{"class":null},{"address":"0xsignal","class":"signal"}]'
assert_focus 0xsignal "Signal handles missing and null classes"

for mode in default class-only; do
  args=()
  if [[ $mode == "class-only" ]]; then
    args+=(--class-only)
  fi
  run_launcher omarchy-launch-or-focus '[{"address":"0xplugin","class":"Org.Quickshell","title":"Calendar"}]' "${args[@]}" 'org.quickshell|Calendar' calendar-launch-command
  assert_launch calendar-launch-command "$mode matching excludes Quickshell even when its class matches"
done

run_launcher omarchy-launch-or-focus '[
  {"address":"0xplugin","class":"org.quickshell","title":"Calendar"},
  {"address":"0xwebapp","class":"chromium","title":"Calendar"}
]' Calendar calendar-launch-command
assert_focus 0xwebapp "generic launcher preserves web app title matching"
run_launcher omarchy-launch-or-focus '[{"address":"0xapp","class":"CALENDAR","title":"Today"}]' calendar
assert_focus 0xapp "generic launcher preserves case-insensitive class matching"
run_launcher omarchy-launch-or-focus '[{"address":"0xtui","class":"terminal","title":"org.omarchy.btop"}]' org.omarchy.btop btop
assert_focus 0xtui "generic launcher preserves TUI title matching"
run_launcher omarchy-launch-or-focus '[{"address":"0xother","class":"mycalendar","title":"Today"}]' calendar
assert_launch "uwsm-app -- calendar" "generic launcher preserves word boundaries and default launch command"

OMARCHY_TEST_FOCUS_FALLBACK=1 run_launcher omarchy-launch-or-focus '[{"address":"0xapp","class":"Calendar","title":"Today"}]' Calendar
assert_focus 0xapp "generic launcher preserves fallback focus"
grep -Fx 'focuswindow address:0xapp' "$dispatch_log" >/dev/null || fail "uses fallback focuswindow"

for args in "" "--class-only"; do
  if bash "$ROOT/bin/omarchy-launch-or-focus" ${args:+"$args"} >"$test_tmp/usage" 2>"$stderr_log"; then
    fail "missing window pattern is rejected"
  fi
  grep -F 'Usage:' "$test_tmp/usage" >/dev/null || fail "prints usage for missing pattern"
  [[ ! -s $stderr_log ]] || fail "missing pattern does not cause shell errors"
  pass "missing window pattern is rejected: $args"
done
