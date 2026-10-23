#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export CALL_LOG="$scratch/calls"

cat > "$scratch/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$ACTIVE_WINDOW"
SH

cat > "$scratch/bin/gdbus" <<'SH'
#!/bin/bash
printf 'gdbus %s\n' "$*" >> "$CALL_LOG"
exit "${DBUS_STATUS:-0}"
SH

cat > "$scratch/bin/setsid" <<'SH'
#!/bin/bash
printf 'launch %s\n' "$*" >> "$CALL_LOG"
SH
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH"

run_launcher() {
  : > "$CALL_LOG"
  bash "$ROOT/bin/omarchy-launch-nautilus"
}

export ACTIVE_WINDOW='{"class":"org.gnome.Nautilus"}'
run_launcher
[[ $(cat "$CALL_LOG") == 'gdbus call --session --dest org.gnome.Nautilus --object-path /org/gnome/Nautilus --method org.gtk.Actions.Activate --timeout 5 clone-window [] {}' ]] ||
  fail "focused Files clones the active window without launching Home"
pass "focused Files clones the active window without launching Home"

for ACTIVE_WINDOW in '{"class":"foot"}' '{}' '{"class":"org.gnome.NautilusPreviewer"}' ''; do
  run_launcher
  [[ $(cat "$CALL_LOG") == 'launch uwsm-app -- nautilus --new-window' ]] ||
    fail "a fresh Files window opens when Files is not focused" "$ACTIVE_WINDOW"
done
pass "a fresh Files window opens when Files is not focused or no window is available"

export ACTIVE_WINDOW='{"class":"org.gnome.Nautilus"}' DBUS_STATUS=1
run_launcher
[[ $(tail -n 1 "$CALL_LOG") == 'launch uwsm-app -- nautilus --new-window' ]] ||
  fail "a failed clone request falls back to opening Files"
pass "a failed clone request falls back to opening Files"
