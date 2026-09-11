#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/calls"
runtime="$tmpdir/runtime"
mkdir -p "$mock_bin" "$runtime"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s %s\n' "hyprctl" "$*" >>"$CALL_LOG"

if [[ $1 == "clients" && $2 == "-j" ]]; then
  cat "$CLIENTS_JSON"
  exit 0
fi

exit 0
SH
chmod +x "$mock_bin/hyprctl"

clients_before='[
  {"address":"0xaaa","class":"kitty","initialClass":"kitty","fullscreen":1,"fullscreenClient":1},
  {"address":"0xbbb","class":"org.omarchy.screensaver","initialClass":"org.omarchy.screensaver","fullscreen":2,"fullscreenClient":2},
  {"address":"0xccc","class":"firefox","initialClass":"firefox","fullscreen":0,"fullscreenClient":0}
]'

clients_after='[
  {"address":"0xaaa","class":"kitty","initialClass":"kitty","fullscreen":0,"fullscreenClient":0},
  {"address":"0xccc","class":"firefox","initialClass":"firefox","fullscreen":0,"fullscreenClient":0}
]'

export CALL_LOG="$call_log"
export XDG_RUNTIME_DIR="$runtime"
export PATH="$mock_bin:$PATH"

printf '%s\n' "$clients_before" >"$tmpdir/clients.json"
CLIENTS_JSON="$tmpdir/clients.json" "$ROOT/bin/omarchy-hyprland-fullscreen-snapshot" save

state_file="$runtime/omarchy-fullscreen-snapshot.json"
[[ -f $state_file ]] || fail "save writes a runtime snapshot"
jq -e 'length == 2' "$state_file" >/dev/null || fail "save ignores screensaver clients"
jq -e 'map(select(.address == "0xaaa" and .fullscreen == 1 and .fullscreenClient == 1)) | length == 1' "$state_file" >/dev/null ||
  fail "save keeps full-width state for ordinary clients"
pass "save snapshots non-screensaver fullscreen state"

>"$call_log"
printf '%s\n' "$clients_after" >"$tmpdir/clients.json"
CLIENTS_JSON="$tmpdir/clients.json" "$ROOT/bin/omarchy-hyprland-fullscreen-snapshot" restore

[[ ! -f $state_file ]] || fail "restore consumes the snapshot"
rg -F 'hl.dsp.window.fullscreen_state({ window = "address:0xaaa", internal = 1, client = 1 })' "$call_log" >/dev/null ||
  fail "restore re-applies full-width on the demoted window" "calls: $(tr '\n' '|' <"$call_log")"
! rg -F 'address:0xccc' "$call_log" >/dev/null || fail "restore skips windows that were already tiled"
! rg -F 'address:0xbbb' "$call_log" >/dev/null || fail "restore never targets the screensaver"
pass "restore re-applies demoted fullscreen modes"

>"$call_log"
CLIENTS_JSON="$tmpdir/clients.json" "$ROOT/bin/omarchy-hyprland-fullscreen-snapshot" restore
! rg -F 'fullscreen_state' "$call_log" >/dev/null || fail "a second restore is a no-op without a snapshot"
pass "restore is idempotent without a snapshot"

# Lifecycle wiring: launch saves, dismiss/lock restore.
rg -n 'omarchy-hyprland-fullscreen-snapshot save' "$ROOT/bin/omarchy-launch-screensaver" >/dev/null ||
  fail "screensaver launch saves fullscreen state before mapping"
rg -n 'omarchy-hyprland-fullscreen-snapshot restore' "$ROOT/bin/omarchy-screensaver" >/dev/null ||
  fail "screensaver dismiss restores fullscreen state"
rg -n 'omarchy-hyprland-fullscreen-snapshot restore' "$ROOT/bin/omarchy-system-lock" >/dev/null ||
  fail "system lock restores fullscreen state after killing the screensaver"
pass "screensaver lifecycle saves and restores fullscreen state"
