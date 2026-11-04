#!/bin/bash

# The emoji picker opens in a real shell: summoning it maps its surface,
# favorites and the skin tone saved from an earlier session load into the
# picker, a favorite added in the picker survives a restart, and the picker
# logs no QML errors while building its grid.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "emoji picker opens"

setup_scratch_shell
mkdir -p "$SCRATCH_HOME/.local/state/omarchy"
printf '{"recent":["\\ud83e\\udee0"],"favorites":["\\ud83d\\udc4d"],"tone":3}\n' \
  >"$SCRATCH_HOME/.local/state/omarchy/emojis.json"
start_scratch_shell
wait_scratch_shell

summoned=""
for _ in {1..80}; do
  [[ $(scratch_ipc shell summon omarchy.emojis '{}' 2>/dev/null || true) == "ok" ]] && { summoned=1; break; }
  kill -0 "$SCRATCH_PID" 2>/dev/null || break
  sleep 0.1
done
[[ -n $summoned ]] || { sed -n '1,120p' "$SCRATCH_LOG" >&2; fail "emoji picker summons in a scratch shell"; }
wait_scratch_layer omarchy-emojis mapped || fail "emoji picker maps when summoned"
pass "emoji picker maps when summoned"

sleep 0.5
if grep -E "plugins/emojis/.*(Error|TypeError|ReferenceError|is not a function|Cannot read)" "$SCRATCH_LOG" >&2; then
  fail "emoji picker builds its grid without QML errors"
fi
pass "emoji picker builds its grid without QML errors"

scratch_ipc_quiet shell hide omarchy.emojis >/dev/null 2>&1 || true
wait_scratch_layer omarchy-emojis absent || fail "emoji picker hides"
pass "emoji picker hides"

# The prefs the picker holds, once its file has loaded ("" until then).
picker_prefs() {
  local prefs
  for _ in {1..50}; do
    prefs=$(scratch_ipc shell call omarchy.emojis prefsJson 2>/dev/null || true)
    [[ $prefs == "{"* && $(jq -r '.recent | length' <<<"$prefs" 2>/dev/null) != 0 ]] && { printf '%s' "$prefs"; return; }
    sleep 0.1
  done
}

summon_picker() {
  for _ in {1..80}; do
    [[ $(scratch_ipc shell summon omarchy.emojis '{}' 2>/dev/null || true) == "ok" ]] && return 0
    kill -0 "$SCRATCH_PID" 2>/dev/null || break
    sleep 0.1
  done
  return 1
}

thumbs=$'\U1F44D'
melting=$'\U1FAE0'
grinning=$'\U1F600'

summon_picker || fail "emoji picker summons again"
prefs=$(picker_prefs)
[[ $(jq -r '.tone' <<<"$prefs") == 3 ]] || fail "emoji picker loads the saved skin tone" "$prefs"
[[ $(jq -r '.favorites[0]' <<<"$prefs") == "$thumbs" ]] || fail "emoji picker loads saved favorites" "$prefs"
[[ $(jq -r '.recent[0]' <<<"$prefs") == "$melting" ]] || fail "emoji picker loads recent emoji" "$prefs"
pass "emoji picker loads saved preferences"

[[ $(scratch_ipc shell call omarchy.emojis toggleFavorite "$grinning") == "ok" ]] || fail "emoji picker favorites an emoji"
saved="$SCRATCH_HOME/.local/state/omarchy/emojis.json"
for _ in {1..30}; do
  [[ $(jq -r '.favorites | join(" ")' "$saved" 2>/dev/null) == "$thumbs $grinning" ]] && break
  sleep 0.1
done
[[ $(jq -r '.favorites | join(" ")' "$saved") == "$thumbs $grinning" ]] || fail "emoji picker saves a new favorite" "$(cat "$saved")"
[[ $(jq -r '.tone' "$saved") == 3 ]] || fail "emoji picker keeps the tone when saving a favorite" "$(cat "$saved")"
pass "emoji picker saves a new favorite"

stop_scratch_shell
start_scratch_shell
wait_scratch_shell
summon_picker || fail "emoji picker summons after a restart"
prefs=$(picker_prefs)
[[ $(jq -r '.favorites | join(" ")' <<<"$prefs") == "$thumbs $grinning" ]] || fail "a new favorite survives a restart" "$prefs"
[[ $(jq -r '.tone' <<<"$prefs") == 3 ]] || fail "the skin tone survives a restart" "$prefs"
pass "a new favorite survives a restart"
