#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sense_home=$(mktemp -d)
TMPDIRS+=("$sense_home")
sense_bin=$(mktemp -d)
TMPDIRS+=("$sense_bin")
sense_state="$sense_home/state"
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
sense_runtime="$sense_home/runtime"
mkdir -p "$sense_runtime"
# A private runtime dir and no session signature, so enable cannot attach
# to the compositor this suite happens to be running under.
sense_run() {
  env -u HYPRLAND_INSTANCE_SIGNATURE HOME="$sense_home" XDG_RUNTIME_DIR="$sense_runtime" \
    OMARCHY_SENSE_STATE_DIR="$sense_state" OMARCHY_SENSE_NOW="$1" \
    PATH="$sense_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-sense" "${@:2}"
}

# The same layout at the same time on three days becomes a scene.
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

# Scrambling the windows and applying the scene puts them back.
sense_clients 3 1 2
sense_run 1760515200 apply 1 >/dev/null
grep -q "movetoworkspacesilent 1,address:0x1" "$sense_home/hypr.log" || fail "sense moves a window back to its scene workspace"
grep -q "movetoworkspacesilent 2,address:0x2" "$sense_home/hypr.log" || fail "sense moves every window back to its scene workspace"

# A long stretch on one app with few switches is flow; guard silences for it,
# and restores what it silenced once focus scatters again.
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

# Two windows of the same class in one scene each get their own slot.
printf '1760259600\t2025-10-12\t09\tcode@3,firefox@4,ghostty@1,ghostty@2\n1760346000\t2025-10-13\t09\tcode@3,firefox@4,ghostty@1,ghostty@2\n1760432400\t2025-10-14\t09\tcode@3,firefox@4,ghostty@1,ghostty@2\n' >"$sense_state/snapshots.tsv"
cat >"$sense_home/clients.json" <<'JSON'
[{"address":"0x1","class":"ghostty","workspace":{"id":4,"name":"4"}},
 {"address":"0x9","class":"ghostty","workspace":{"id":3,"name":"3"}},
 {"address":"0x2","class":"code","workspace":{"id":1,"name":"1"}},
 {"address":"0x3","class":"firefox","workspace":{"id":2,"name":"2"}}]
JSON
: >"$sense_home/hypr.log"
sense_run 1760515200 apply 1 >/dev/null
grep -q "movetoworkspacesilent 1,address:0x1" "$sense_home/hypr.log" || fail "sense gives the first same-class window its own scene slot"
grep -q "movetoworkspacesilent 2,address:0x9" "$sense_home/hypr.log" || fail "sense gives the second same-class window its own scene slot"

# The same two terminals, already on the scene's workspaces but listed
# workspace 2 first, stay put.
cat >"$sense_home/clients.json" <<'JSON'
[{"address":"0x1","class":"ghostty","workspace":{"id":2,"name":"2"}},
 {"address":"0x9","class":"ghostty","workspace":{"id":1,"name":"1"}},
 {"address":"0x2","class":"code","workspace":{"id":3,"name":"3"}},
 {"address":"0x3","class":"firefox","workspace":{"id":4,"name":"4"}}]
JSON
: >"$sense_home/hypr.log"
sense_run 1760515200 apply 1 >/dev/null
grep -q "movetoworkspacesilent" "$sense_home/hypr.log" && fail "sense leaves windows that already match their scene slots"

# Flow JSON works before any history exists.
sense_empty_json=$(env -u HYPRLAND_INSTANCE_SIGNATURE HOME="$sense_home" XDG_RUNTIME_DIR="$sense_runtime" OMARCHY_SENSE_STATE_DIR="$sense_home/empty" OMARCHY_SENSE_NOW=1760515200 PATH="$sense_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-sense" flow --json)
[[ $sense_empty_json == *'"state": "learning"'* ]] || fail "sense flow json works with no history" "$sense_empty_json"

# A break marked __away__ is idle, not a long stretch in the previous app,
# while 30 unbroken minutes in one app is still flow.
: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5 6 7; do printf '%s\tghostty\n' $(( 1760510000 + i * 60 )) >>"$sense_state/events.tsv"; done
printf '1760511000\tcode\n1760512800\t__away__\n' >>"$sense_state/events.tsv"
sense_flow=$(sense_run 1760512860 flow)
[[ $sense_flow == "idle"* ]] || fail "sense reads the away marker as idle" "$sense_flow"
: >"$sense_state/events.tsv"
for i in 0 1 2 3 4 5 6 7; do printf '%s\tghostty\n' $(( 1760510000 + i * 60 )) >>"$sense_state/events.tsv"; done
printf '1760511000\tcode\n' >>"$sense_state/events.tsv"
sense_flow=$(sense_run 1760512860 flow)
[[ $sense_flow == "in flow"* ]] || fail "sense keeps a long unbroken stretch in flow" "$sense_flow"

# The same focus sequence on different days becomes a routine, and replaying
# it walks the apps in order, each to its most common workspace.
: >"$sense_state/events.tsv"
for day in 0 1 2; do
  sense_base=$(( 1760259600 + day * 86400 ))
  printf '%s\tghostty\n%s\tcode\n%s\tfirefox\n%s\tcode\n' \
    $sense_base $(( sense_base + 60 )) $(( sense_base + 120 )) $(( sense_base + 180 )) >>"$sense_state/events.tsv"
done
printf '1760509200\tghostty\n1760509260\tcode\n1760509320\tfirefox\n1760509380\tcode\n' >>"$sense_state/events.tsv"
sense_routines=$(sense_run 1760515200 routines)
[[ $sense_routines == *"ghostty -> code -> firefox -> code"* ]] || fail "sense learns a repeated focus sequence as a routine" "$sense_routines"
sense_routines_json=$(sense_run 1760515200 routines --json)
[[ $sense_routines_json == *'"steps":["ghostty","code","firefox","code"]'* ]] || fail "sense reports routine steps" "$sense_routines_json"
: >"$sense_home/hypr.log"
sense_name=$(printf '%s\n' "$sense_routines" | awk 'NR==1 { print $1 }')
[[ $sense_name == ghostty-to-code-* ]] || fail "sense names a routine from its sequence" "$sense_name"
# Replay uses the clients left by the scene check above: ghostty 0x1, code 0x2, firefox 0x3.
cat >"$sense_home/clients.json" <<'JSON'
[{"address":"0x1","class":"ghostty","workspace":{"id":1,"name":"1"}},
 {"address":"0x2","class":"code","workspace":{"id":2,"name":"2"}},
 {"address":"0x3","class":"firefox","workspace":{"id":3,"name":"3"}}]
JSON
: >"$sense_home/hypr.log"
sense_run 1760515200 routine "$sense_name" >/dev/null
grep -q "movetoworkspacesilent 3,address:0x2" "$sense_home/hypr.log" || fail "routine replay puts an app on its usual workspace"
sense_focus=$(grep 'hl.dsp.focus' "$sense_home/hypr.log" | awk '
  /address:0x/ {
    line = $0
    sub(/.*address:/, "", line)
    sub(/[^0-9a-fx].*/, "", line)
    out = out (out == "" ? "" : " ") line
  }
  END { print out }
')
[[ $sense_focus == "0x1 0x2 0x3 0x2" ]] || fail "routine replay focuses each step in order" "$sense_focus"
sense_run 1760515200 routine dismiss "$sense_name" >/dev/null
sense_routines=$(sense_run 1760515200 routines)
[[ $sense_routines == "no routines yet"* ]] || fail "sense stops suggesting a dismissed routine" "$sense_routines"

# Learning nothing while disabled, and forgetting on request.
sense_run 1760516320 disable >/dev/null
[[ -f $sense_state/enabled ]] && fail "sense disable stops learning"
sense_run 1760516320 forget >/dev/null
[[ -f $sense_state/snapshots.tsv || -f $sense_state/events.tsv || -f $sense_state/known-routines || -f $sense_state/dismissed-routines ]] && fail "sense forget deletes its history"
pass "sense learns scenes, restores layouts, and guards flow"
