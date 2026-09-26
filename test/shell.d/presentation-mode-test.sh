#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
stub="$tmpdir/bin"
mkdir -p "$home" "$stub"

cat >"$stub/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SHELL_LOG"
if [[ $1 == "-q" ]]; then
  shift
fi
if [[ $1 == "notifications" && $2 == "dndState" ]]; then
  printf '%s\n' "${DND_STATE:-off}"
  exit 0
fi
if [[ $1 == "notifications" && $2 == "setDnd" ]]; then
  printf '%s\n' "$3" >"$DND_SET_LOG"
  exit 0
fi
exit 0
SH
cat >"$stub/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH
chmod +x "$stub/omarchy-shell" "$stub/omarchy-notification-send"

run() {
  HOME="$home" PATH="$stub:$ROOT/bin:$PATH" \
    SHELL_LOG="$tmpdir/shell.log" DND_SET_LOG="$tmpdir/dnd" NOTIFY_LOG="$tmpdir/notify" \
    DND_STATE="${DND_STATE:-off}" \
    "$ROOT/bin/omarchy-toggle-presentation" "$@"
}

status=$(run on)
[[ $status == "on" ]] || fail "presentation on prints on" "$status"
[[ -f $home/.local/state/omarchy/toggles/presentation ]] ||
  fail "presentation on sets the presentation flag"
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation on hides the bar"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation on stays awake"
[[ $(<"$tmpdir/dnd") == "on" ]] ||
  fail "presentation on silences notifications" "$(cat "$tmpdir/dnd")"
grep -Fq 'Presentation mode on' "$tmpdir/notify" ||
  fail "presentation on notifies" "$(cat "$tmpdir/notify")"
pass "presentation on hides the bar, silences notifications, and stays awake"

: >"$tmpdir/dnd"
: >"$tmpdir/notify"
status=$(run off)
[[ $status == "off" ]] || fail "presentation off prints off" "$status"
[[ ! -f $home/.local/state/omarchy/toggles/presentation ]] ||
  fail "presentation off clears the presentation flag"
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation off shows the bar again when it was visible"
[[ ! -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation off allows idle when stay-awake was off"
[[ $(<"$tmpdir/dnd") == "off" ]] ||
  fail "presentation off restores notifications" "$(cat "$tmpdir/dnd")"
pass "presentation off restores the previous bar, dnd, and idle state"

# Already presenting: bar hidden, dnd on, stay-awake on — turning presentation
# off must leave those alone.
mkdir -p "$home/.local/state/omarchy/toggles" "$home/.local/state/omarchy/indicators"
touch "$home/.local/state/omarchy/toggles/bar-off"
touch "$home/.local/state/omarchy/indicators/stay-awake"
DND_STATE=on
: >"$tmpdir/dnd"
run on >/dev/null
: >"$tmpdir/dnd"
run off >/dev/null
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation off leaves a bar that was already hidden"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation off leaves stay-awake that was already on"
[[ ! -s $tmpdir/dnd ]] ||
  fail "presentation off does not clear dnd that was already on" "$(cat "$tmpdir/dnd")"
pass "presentation off does not undo state it did not change"

# Never enabled: off must not clobber unrelated settings (defaults "restore").
rm -f "$home/.local/state/omarchy/toggles/presentation" \
  "$home/.local/state/omarchy/presentation-restore"
mkdir -p "$home/.local/state/omarchy/toggles" "$home/.local/state/omarchy/indicators"
touch "$home/.local/state/omarchy/toggles/bar-off"
touch "$home/.local/state/omarchy/indicators/stay-awake"
DND_STATE=on
: >"$tmpdir/dnd"
: >"$tmpdir/notify"
status=$(run off)
[[ $status == "off" ]] || fail "presentation off when never on prints off" "$status"
[[ -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation off when never on leaves a hidden bar alone"
[[ -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation off when never on leaves stay-awake alone"
[[ ! -s $tmpdir/dnd ]] ||
  fail "presentation off when never on does not touch dnd" "$(cat "$tmpdir/dnd")"
[[ ! -s $tmpdir/notify ]] ||
  fail "presentation off when never on does not notify" "$(cat "$tmpdir/notify")"
pass "presentation off is a no-op when presentation was never enabled"

# Kill mid-enable: state file is touched before UI changes, so a second on must
# not rewrite the restore baseline from the already-mutated settings.
rm -rf "$home/.local/state/omarchy"
mkdir -p "$home/.local/state/omarchy/toggles" "$stub"
: >"$tmpdir/dnd"
: >"$tmpdir/notify"
# Simulate a crashed enable that already hid the bar / set stay-awake / DND,
# wrote restore from the pre-change baseline, and marked presentation on.
mkdir -p "$home/.local/state/omarchy"
printf 'bar_off=0\ndnd=off\nstay_awake=0\n' >"$home/.local/state/omarchy/presentation-restore"
touch "$home/.local/state/omarchy/toggles/presentation"
touch "$home/.local/state/omarchy/toggles/bar-off"
mkdir -p "$home/.local/state/omarchy/indicators"
touch "$home/.local/state/omarchy/indicators/stay-awake"
DND_STATE=on
run on >/dev/null
grep -Fq 'bar_off=0' "$home/.local/state/omarchy/presentation-restore" ||
  fail "presentation on does not overwrite an existing restore baseline" \
    "$(cat "$home/.local/state/omarchy/presentation-restore")"
: >"$tmpdir/dnd"
run off >/dev/null
[[ ! -f $home/.local/state/omarchy/toggles/bar-off ]] ||
  fail "presentation off after interrupted enable restores a previously visible bar"
[[ ! -f $home/.local/state/omarchy/indicators/stay-awake ]] ||
  fail "presentation off after interrupted enable clears stay-awake it had set"
[[ $(<"$tmpdir/dnd") == "off" ]] ||
  fail "presentation off after interrupted enable restores notifications" "$(cat "$tmpdir/dnd")"
pass "presentation restore baseline survives a kill mid-enable"

grep -Fq '"trigger.toggle.presentation"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "presentation mode is on the Toggle menu"
pass "presentation mode is on the Toggle menu"
