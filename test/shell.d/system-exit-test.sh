#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls"
clients="$test_tmp/clients"
mkdir -p "$mock_bin"

# Windows close on request unless listed in $clients.stubborn, like an editor
# that answers the close with a "Save changes?" dialog.
cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "clients" ]]; then
  cat "$CLIENTS"
elif [[ $2 =~ address:(0x[0-9a-f]+) ]] && ! grep -qx "${BASH_REMATCH[1]}" "$CLIENTS.stubborn" 2>/dev/null; then
  jq --arg a "${BASH_REMATCH[1]}" 'map(select(.address != $a))' "$CLIENTS" >"$CLIENTS.new"
  mv "$CLIENTS.new" "$CLIENTS"
fi
SH

# Run the unit inline, as the user manager would
cat >"$mock_bin/systemd-run" <<'SH'
#!/bin/bash
printf 'systemd-run %s\n' "$*" >>"$CALL_LOG"
while [[ $1 == -* ]]; do shift; done
"$@"
SH

for command in systemctl uwsm omarchy-notification-send omarchy-state; do
  printf '#!/bin/bash\nprintf "%s %%s\\n" "$*" >>"$CALL_LOG"\n' "$command" >"$mock_bin/$command"
done
printf '#!/bin/bash\n' >"$mock_bin/omarchy-osd"
printf '#!/bin/bash\n' >"$mock_bin/sleep"
chmod +x "$mock_bin"/*

open_windows() {
  : >"$call_log"
  cat >"$clients" <<'JSON'
[
  {"address": "0x1", "class": "jetbrains-webstorm", "mapped": true},
  {"address": "0x2", "class": "Alacritty", "mapped": true},
  {"address": "0x3", "class": "jetbrains-webstorm", "mapped": false}
]
JSON
}

run_exit() {
  CALL_LOG="$call_log" CLIENTS="$clients" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-system-$1" || true
}

for action in "reboot:systemctl reboot" "shutdown:systemctl poweroff" "logout:uwsm stop"; do
  name=${action%%:*}
  final=${action#*:}

  open_windows
  echo 0x1 >"$clients.stubborn"
  run_exit "$name"
  grep -q "^systemd-run --user .*omarchy-system-exit $name$" "$call_log" || fail "$name runs in the user manager" "$(cat "$call_log")"
  pass "$name runs in the user manager"
  ! grep -q "^$final" "$call_log" || fail "$name waits while an app is still open" "$(cat "$call_log")"
  grep -q "^omarchy-notification-send .*Still open: jetbrains-webstorm$" "$call_log" || fail "$name names the app that stopped it" "$(cat "$call_log")"
  ! grep -q "^omarchy-state clear" "$call_log" || fail "$name keeps reboot-required flags when cancelled"
  pass "$name is cancelled while an app is still open"

  open_windows
  rm -f "$clients.stubborn"
  run_exit "$name"
  grep -q "^$final" "$call_log" || fail "$name proceeds once all apps closed" "$(cat "$call_log")"
  pass "$name proceeds once all apps closed"
done
