#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sense_home=$(mktemp -d)
trap 'rm -rf "$sense_home"' EXIT
sense_bin="$sense_home/bin"
sense_state="$sense_home/state"
mkdir -p "$sense_bin" "$sense_home/run"

cat >"$sense_bin/hyprctl" << 'SH'
#!/bin/bash
echo "hyprctl $*" >>"$HOME/hypr.log"
if [[ $1 == clients ]]; then
  cat "$HOME/clients.json"
elif [[ $1 == activewindow ]]; then
  printf '{"class":"ghostty"}\n'
fi
exit 0
SH
cat >"$sense_bin/omarchy-shell" << 'SH'
#!/bin/bash
state="$HOME/.sense-dnd"
if [[ $1 == notifications && $2 == isDnd ]]; then
  [[ -f $state ]] && echo on || echo off
elif [[ $1 == notifications && $2 == setDnd ]]; then
  if [[ -f $HOME/.sense-dnd-fail ]]; then
    rm -f "$HOME/.sense-dnd-fail"
    exit 1
  fi
  if [[ $3 == on ]]; then touch "$state"; else rm -f "$state"; fi
fi
exit 0
SH
printf '#!/bin/bash\nexit 0\n' >"$sense_bin/omarchy-notification-send"
chmod +x "$sense_bin"/*

sense_clients() {
  cat >"$sense_home/clients.json" <<JSON
[{"address":"0x1","class":"ghostty","workspace":{"id":$1,"name":"$1"}},
 {"address":"0x2","class":"code","workspace":{"id":$2,"name":"$2"}},
 {"address":"0x3","class":"firefox","workspace":{"id":$3,"name":"$3"}}]
JSON
}
sense_run() {
  env HOME="$sense_home" OMARCHY_SENSE_STATE_DIR="$sense_state" OMARCHY_SENSE_NOW="$1" \
    XDG_RUNTIME_DIR="$sense_home/run" HYPRLAND_INSTANCE_SIGNATURE="" \
    PATH="$sense_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-sense" "${@:2}"
}

sense_clients 1 2 3
sense_run 1760259600 enable >/dev/null
for day in 0 1 2; do
  sense_run $(( 1760259600 + day * 86400 )) snapshot
  sense_run $(( 1760263200 + day * 86400 )) snapshot
done
sense_scenes=$(sense_run 1760515200 scenes)
[[ $sense_scenes == *"ghostty -> workspace 1"* ]] || fail "sense learns a recurring layout as a scene" "$sense_scenes"
[[ $sense_scenes == *"code -> workspace 2"* ]] || fail "sense remembers each window's workspace" "$sense_scenes"
sense_scenes_json=$(sense_run 1760515200 scenes --json)
[[ $sense_scenes_json == *'"seen":6'* ]] || fail "sense reports how often a scene recurred" "$sense_scenes_json"
pass "sense learns a recurring layout"

sense_clients 3 1 2
sense_run 1760515200 apply 1 >/dev/null
grep -q "movetoworkspacesilent 1,address:0x1" "$sense_home/hypr.log" || fail "sense moves a window back to its scene workspace"
grep -q "movetoworkspacesilent 2,address:0x2" "$sense_home/hypr.log" || fail "sense moves every window back to its scene workspace"
pass "sense puts a scene back"

: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5; do printf '%s\tghostty\n' $(( 1760508000 + i * 600 )) >>"$sense_state/events.tsv"; done
printf '1760515200\tghostty\n1760515260\tcode\n' >>"$sense_state/events.tsv"
sense_flow=$(sense_run 1760515860 flow)
[[ $sense_flow == "in flow"* ]] || fail "sense reads a settled stretch as flow" "$sense_flow"
sense_run 1760515860 guard >/dev/null
[[ -f $sense_home/.sense-dnd ]] || fail "sense silences notifications during flow"
: >"$sense_state/events.tsv"
for i in $(seq 0 15); do
  sense_class=ghostty
  (( i % 4 == 1 )) && sense_class=code
  (( i % 4 == 2 )) && sense_class=firefox
  (( i % 4 == 3 )) && sense_class=spotify
  printf '%s\t%s\n' $(( 1760516000 + i * 20 )) "$sense_class" >>"$sense_state/events.tsv"
done
sense_flow=$(sense_run 1760516320 flow)
[[ $sense_flow == "scattered"* ]] || fail "sense reads rapid switching as scattered" "$sense_flow"
sense_run 1760516320 guard >/dev/null
[[ -f $sense_home/.sense-dnd ]] && fail "sense restores notifications after flow"
pass "sense guards flow and restores after it"

printf '1760259600\t2025-10-12\t09\tcode@3,firefox@4,ghostty@1,ghostty@2\n1760346000\t2025-10-13\t09\tcode@3,firefox@4,ghostty@1,ghostty@2\n1760432400\t2025-10-14\t09\tcode@3,firefox@4,ghostty@1,ghostty@2\n' >"$sense_state/snapshots.tsv"
cat >"$sense_home/clients.json" <<'JSON'
[{"address":"0x1","class":"ghostty","workspace":{"id":4,"name":"4"}},
 {"address":"0x9","class":"ghostty","workspace":{"id":3,"name":"3"}},
 {"address":"0x2","class":"code","workspace":{"id":1,"name":"1"}},
 {"address":"0x3","class":"firefox","workspace":{"id":2,"name":"2"}}]
JSON
: >"$sense_home/hypr.log"
sense_run 1760515200 apply 1 >/dev/null
sense_moves=$(grep movetoworkspacesilent "$sense_home/hypr.log" || true)
[[ $(grep -c 'address:0x1' <<<"$sense_moves") -eq 1 ]] || fail "sense uses the first same-class window once" "$sense_moves"
[[ $(grep -c 'address:0x9' <<<"$sense_moves") -eq 1 ]] || fail "sense uses the second same-class window once" "$sense_moves"
[[ $sense_moves == *"movetoworkspacesilent 1,address:"* && $sense_moves == *"movetoworkspacesilent 2,address:"* ]] || fail "sense fills both scene workspaces" "$sense_moves"
pass "sense gives each same-class window its own slot"

sense_empty_json=$(env HOME="$sense_home" OMARCHY_SENSE_STATE_DIR="$sense_home/empty" OMARCHY_SENSE_NOW=1760515200 \
  XDG_RUNTIME_DIR="$sense_home/run" HYPRLAND_INSTANCE_SIGNATURE="" \
  PATH="$sense_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-sense" flow --json)
[[ $sense_empty_json == *'"state": "learning"'* ]] || fail "sense flow json works with no history" "$sense_empty_json"
pass "sense flow json works with no history"

: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5 6 7; do printf '%s\tghostty\n' $(( 1760510000 + i * 60 )) >>"$sense_state/events.tsv"; done
printf '1760511000\tcode\n1760512800\t__away__\n' >>"$sense_state/events.tsv"
sense_flow=$(sense_run 1760512860 flow)
[[ $sense_flow == "idle"* ]] || fail "sense reads the away marker as idle" "$sense_flow"
: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5 6 7; do printf '%s\tghostty\n' $(( 1760510000 + i * 60 )) >>"$sense_state/events.tsv"; done
printf '1760511000\tcode\n' >>"$sense_state/events.tsv"
sense_flow=$(sense_run 1760551000 flow)
[[ $sense_flow == "in flow"* ]] || fail "sense keeps a long unbroken stretch in flow" "$sense_flow"
pass "sense treats away as idle and a long stretch as flow"

: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5 6 7; do printf '%s\tghostty\n' $(( 1760510000 + i * 60 )) >>"$sense_state/events.tsv"; done
sense_run 1760510500 disable >/dev/null
[[ -f $sense_state/enabled ]] && fail "sense disable stops learning"
[[ $(tail -n 1 "$sense_state/events.tsv" | cut -f2) == "__away__" ]] || fail "sense closes the focus stretch when disabled"
sense_run 1760519000 enable >/dev/null
sense_flow=$(sense_run 1760519000 flow)
[[ $sense_flow == "in flow"* ]] && fail "sense does not count disabled time as flow" "$sense_flow"
pass "sense excludes disabled time from flow"

printf '1760259600\t2025-10-12\t09\tcode@2,ghostty@my%%20project\n1760346000\t2025-10-13\t09\tcode@2,ghostty@my%%20project\n1760432400\t2025-10-14\t09\tcode@2,ghostty@my%%20project\n' >"$sense_state/snapshots.tsv"
cat >"$sense_home/clients.json" <<'JSON'
[{"address":"0x1","class":"ghostty","workspace":{"id":1,"name":"1"}},
 {"address":"0x2","class":"code","workspace":{"id":2,"name":"2"}}]
JSON
: >"$sense_home/hypr.log"
sense_run 1760515200 apply 1 >/dev/null
grep -q "movetoworkspacesilent my project,address:0x1" "$sense_home/hypr.log" || fail "sense restores a workspace name that contains a space" "$(cat "$sense_home/hypr.log")"
pass "sense keeps workspace names intact"

: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5 6 7; do printf '%s\tghostty\n' $(( 1760510000 + i * 30 )) >>"$sense_state/events.tsv"; done
printf '1760512000\tghostty\n' >>"$sense_state/events.tsv"
rm -f "$sense_home/.sense-dnd" "$sense_state/guardian-dnd"
touch "$sense_home/.sense-dnd-fail"
sense_run 1760512300 guard >/dev/null
[[ -f $sense_home/.sense-dnd || -f $sense_state/guardian-dnd ]] && fail "a failed silence does not look owned"
sense_run 1760512300 guard >/dev/null
[[ -f $sense_home/.sense-dnd && -f $sense_state/guardian-dnd ]] || fail "sense retries a failed silence"
pass "sense retries a failed silence"

quiet="$sense_home/.local/state/omarchy/notifications/quiet.json"
mkdir -p "${quiet%/*}"
printf '%s\n' '{"dnd":false}' >"$quiet"
rm -f "$sense_home/.sense-dnd" "$sense_state/guardian-dnd"
sense_run 1760512300 guard >/dev/null
saved=$(cut -f3 "$sense_state/guardian-dnd")
[[ -n $saved ]] || fail "sense records the quiet file when it silences"
printf '%s\n' '{"dnd":true}' >"$quiet"
# A rewrite after the saved mtime is the user turning DND off and on again.
touch -d "@$(( saved + 30 ))" "$quiet" 2>/dev/null || touch -t 202610211200 "$quiet"
sense_run 1760512400 disable >/dev/null
[[ -f $sense_home/.sense-dnd ]] || fail "sense leaves dnd alone once the user has changed it"
pass "sense leaves a later manual dnd setting alone"

sense_run 1760512400 forget >/dev/null
[[ -f $sense_state/snapshots.tsv || -f $sense_state/events.tsv ]] && fail "sense forget deletes its history"
pass "sense forgets on request"
