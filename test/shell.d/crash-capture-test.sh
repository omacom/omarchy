#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMPDIR/bin"
SYSTEMCTL_LOG="$TMPDIR/systemctl-log"

cat >"$TMPDIR/bin/systemctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SYSTEMCTL_LOG"
SH

cat >"$TMPDIR/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
exit 0
SH

chmod +x "$TMPDIR/bin/systemctl" "$TMPDIR/bin/omarchy-notification-send"

test_home="$TMPDIR/home"
flag="$test_home/.local/state/omarchy/toggles/crash-capture-off"

toggle_crash_capture() {
  PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  SYSTEMCTL_LOG="$SYSTEMCTL_LOG" \
  HOME="$test_home" \
    "$ROOT/bin/omarchy-toggle-crash-capture"
}

toggle_crash_capture
[[ -f $flag ]] || fail "crash capture toggle disables the watcher"
grep -Fqx -- "--user stop omarchy-crash-watch.service" "$SYSTEMCTL_LOG" ||
  fail "crash capture toggle stops the running watcher, so disabling takes effect before the next login"
pass "crash capture toggle disables the watcher"

: >"$SYSTEMCTL_LOG"
toggle_crash_capture
[[ ! -f $flag ]] || fail "crash capture toggle re-enables the watcher"
grep -Fqx -- "--user start omarchy-crash-watch.service" "$SYSTEMCTL_LOG" ||
  fail "crash capture toggle starts the watcher, so enabling takes effect before the next login"
pass "crash capture toggle re-enables the watcher"

require_command jq

# The per-program mute, driven through the real watcher with a stubbed journal:
# these prove what a person sees -- a toast arriving or not -- where asserting
# that a flag file was read would prove only that a flag file was read.
watch_bin="$TMPDIR/watch-bin"
watch_home="$TMPDIR/watch-home"
NOTIFY_LOG="$TMPDIR/notify-log"
JOURNAL_ENTRIES="$TMPDIR/journal-entries"

mkdir -p "$watch_bin" "$watch_home"

# The real journal applies --output-fields as an allowlist, silently, and -o json
# without --all turns any field over 4 KiB into null. The stub does both, so a
# field the watcher reads without asking for it, or a crashed process's
# environment read without --all, arrives as it would on a real machine.
cat >"$watch_bin/journalctl" <<'SH'
#!/bin/bash
fields=
all=false
for arg; do
  [[ $arg == --output-fields=* ]] && fields=${arg#--output-fields=}
  [[ $arg == "--all" ]] && all=true
done
jq -c --arg fields "$fields" --argjson all "$all" '
  (if $fields == "" then . else ($fields | split(",")) as $f | with_entries(select(.key | IN($f[]))) end)
  | if $all then . else
      with_entries(if (.value | type | IN("string", "array")) and (.value | length) > 4096 then .value = null else . end)
    end' "$JOURNAL_ENTRIES"
SH

cat >"$watch_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
echo claude
SH

cat >"$watch_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$watch_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH

chmod +x "$watch_bin/journalctl" "$watch_bin/omarchy-default-agent" \
  "$watch_bin/omarchy-notification-wait" "$watch_bin/omarchy-notification-send"

reset_entries() {
  : >"$JOURNAL_ENTRIES"
}

# One core dump as systemd-coredump journals it. The UID must be this user's, or
# the watcher discards it as somebody else's crash before anything under test.
# The crashed process's environment, when given, is one newline-separated string.
crash_entry() {
  local comm="$1" exe="$2" environ="${3:-}"

  jq -cn --arg uid "$UID" --arg comm "$comm" --arg exe "$exe" --arg environ "$environ" \
    '{_UID: $uid, COREDUMP_COMM: $comm, COREDUMP_PID: "4242",
      COREDUMP_EXE: $exe, COREDUMP_SIGNAL_NAME: "SIGSEGV"}
     + if $environ == "" then {} else {COREDUMP_ENVIRON: $environ} end' >>"$JOURNAL_ENTRIES"
}

# The stubbed journalctl ends after the entries, so the watcher's loop ends too.
# Its exit status is asserted rather than discarded: a watcher that dies on a
# muted crash notifies about nothing afterwards, which every assertion below
# that expects silence would otherwise read as success.
run_watch() {
  local status=0

  : >"$NOTIFY_LOG"

  # None of the runner's tunables, so a desktop that exports one cannot change
  # what the watcher holds back or announces.
  PATH="$watch_bin:$ROOT/bin:$PATH" \
  JOURNAL_ENTRIES="$JOURNAL_ENTRIES" \
  NOTIFY_LOG="$NOTIFY_LOG" \
  HOME="$watch_home" \
    env -u OMARCHY_CRASH_DIAGNOSIS_COOLDOWN_SECONDS -u OMARCHY_CRASH_DIAGNOSIS_MAX_SECONDS \
      -u OMARCHY_CRASH_DEDUPE_SECONDS -u OMARCHY_CRASH_IGNORE \
      "$ROOT/bin/omarchy-crash-watch" || status=$?

  (( status == 0 )) ||
    fail "the watcher exited $status rather than carrying on, so a mute takes the service down with it"
}

# Through the real command rather than writing the flag by hand: these assertions
# are then the guard that the thing the diagnosis runs and the thing the watcher
# reads have not drifted apart.
mute() {
  HOME="$watch_home" PATH="$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-crash-mute" "$1" "$2" >/dev/null
}

announced() {
  grep -Fq "Process crashed: $1" "$NOTIFY_LOG"
}

reset_entries
crash_entry hyprland /usr/bin/hyprland
run_watch
announced hyprland ||
  fail "a crash nobody muted still announces itself"
pass "a crash nobody muted still announces itself"

mute hyprland on
run_watch
! announced hyprland ||
  fail "muting a program stops the crash notifications the diagnosis offered to stop"
pass "muting a program stops its crash notifications"

reset_entries
crash_entry nautilus /usr/bin/nautilus
run_watch
announced nautilus ||
  fail "muting one program silences every other program, which is the global toggle's job and not this one's"
pass "muting one program leaves every other program announcing"

mute hyprland off
reset_entries
crash_entry hyprland /usr/bin/hyprland
run_watch
announced hyprland ||
  fail "un-muting a program brings its crash notifications back"
pass "un-muting a program brings its crash notifications back"

# The diagnosis tells the user to mute the name the toast showed them, so the
# toast has to show the name the watcher checks. COMM is truncated to 15
# characters and the executable's basename is not, and announcing the truncated
# one would leave a dutifully-followed mute matching nothing forever.
reset_entries
crash_entry chromium-browse /usr/lib/chromium/chromium-browser
run_watch
announced chromium-browser ||
  fail "the toast announces a name the mute cannot be keyed on, so following the diagnosis mutes nothing"
pass "the toast announces the name the mute is keyed on"

mute chromium-browser on
run_watch
! announced chromium-browser ||
  fail "the mute is keyed on the name the notification announced, not on the truncated COMM"
pass "muting the announced name silences a program whose COMM was truncated"

# A muted crash must not end the watcher. Restart=always would paper over it
# with a five-second gap, and the watcher restarts on `journalctl -n 0`, which
# never replays the crashes it missed while it was away.
reset_entries
crash_entry chromium-browse /usr/lib/chromium/chromium-browser
crash_entry nautilus /usr/bin/nautilus
run_watch
announced nautilus ||
  fail "a muted crash stops the watcher reading the journal, losing every crash after it"
pass "a muted crash does not stop the watcher reading the next one"

# A process can set its own comm to anything prctl takes, slashes included, and
# a crash with no recorded executable falls back to it. A name that climbed out
# of crash-ignore/ would let a crashing program silence itself against an
# unrelated flag -- and have the diagnosis write one there on the user's behalf.
# The fixture carries two slashes so that dropping only the first is not mistaken
# for dropping all of them.
reset_entries
crash_entry a/../bar-off -
sibling_flag="$watch_home/.local/state/omarchy/toggles/bar-off"
touch "$sibling_flag"
run_watch
announced bar-off ||
  fail "a comm that climbs out of crash-ignore/ reads an unrelated toggle, letting a crash suppress its own notification"
pass "a comm that climbs out of crash-ignore/ cannot reach an unrelated toggle"
rm -f "$sibling_flag"

# Stripping to the last component does not always leave a component. An empty
# name is no kind of array subscript and no kind of toast, and a dot component
# names a directory the mute would touch and then never match.
for empty_comm in / a/ . ..; do
  reset_entries
  crash_entry "$empty_comm" -
  run_watch
  announced unknown ||
    fail "a comm of '$empty_comm' leaves no usable name, so the toast cannot say what crashed and the mute has nothing to key on"
done
pass "a comm that strips down to nothing or a dot still announces under a name a mute can use"

# An empty comm is not a missing entry. Tab is IFS whitespace, so an empty field
# collapses and every field after it shifts along one -- the pid becomes a path,
# the crash reads as somebody else's, and it is dropped without a word.
reset_entries
crash_entry "" -
crash_entry nautilus /usr/bin/nautilus
run_watch
announced unknown ||
  fail "a crash whose comm is empty is dropped instead of announced, because the empty field shifted every field after it"
announced nautilus ||
  fail "an empty comm derails the rest of the journal entry"
pass "an empty comm is announced rather than parsed into the next field"

# Only "." and ".." are special. A leading dot is an ordinary filename, and
# folding those into the fallback would have one program's mute silence another.
for dotted_comm in .hidden ...; do
  reset_entries
  crash_entry "$dotted_comm" -
  run_watch
  announced "$dotted_comm" ||
    fail "'$dotted_comm' is an ordinary name, but it lands in the fallback, so muting it would silence unrelated crashes"
done
pass "a leading dot is an ordinary name rather than a special component"

# And the name it settles on is mutable like any other.
mute unknown on
reset_entries
crash_entry / -
run_watch
! announced unknown ||
  fail "the fallback name cannot be muted, so the one crash most likely to repeat is the one that cannot be silenced"
pass "the fallback name can be muted like any other"
mute unknown off

# What omarchy-crash-mute does on its own. That it agrees with the watcher is
# already covered above, which drives it for every mute it makes.
mute_home="$TMPDIR/mute-home"
mkdir -p "$mute_home"

crash_mute() {
  HOME="$mute_home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-crash-mute" "$@"
}

mute_flag() {
  [[ $1 == "--" ]] && shift
  printf '%s' "$mute_home/.local/state/omarchy/toggles/crash-ignore/$1"
}

crash_mute | grep -Fq "No programs muted" ||
  fail "an empty mute list prints nothing, so a user cannot tell it from a broken command"
pass "the command says so when nothing is muted"

crash_mute hyprland >/dev/null
crash_mute | grep -Fqx hyprland ||
  fail "a muted program is missing from the list, so a mute cannot be found again to lift it"
pass "the command lists what it muted"

# The watcher keys on the basename, so the command has to take the path a crash
# recorded and land on the same flag the watcher will look for.
crash_mute /usr/lib/chromium/chromium-browser >/dev/null
[[ -f $(mute_flag chromium-browser) ]] ||
  fail "a binary's path is muted verbatim rather than by name, so the watcher never sees that flag"
pass "the command reduces a path to the name the watcher checks"

crash_mute hyprland off >/dev/null
[[ ! -f $(mute_flag hyprland) ]] ||
  fail "off leaves the program muted, making the mute a one-way door"
pass "the command un-mutes"

# Muting is not flipping. The diagnosis offers this on a program the user may
# already have muted, and asking for a mute twice has to leave it muted.
crash_mute hyprland >/dev/null
crash_mute hyprland >/dev/null
[[ -f $(mute_flag hyprland) ]] ||
  fail "muting an already-muted program un-mutes it, so offering the mute a second time turns it back on"
pass "asking to mute twice leaves it muted"

# A program may legitimately be called .hidden, and a mute nobody can see is a
# mute nobody can lift.
crash_mute .hidden >/dev/null
crash_mute | grep -Fqx .hidden ||
  fail "a mute on a dotted name is missing from the list, so it can never be found and lifted"
pass "the list shows a name that begins with a dot"

# It turns what it is given into a path, so it has to refuse whatever is not one
# component of one.
for bad_name in . .. /; do
  ! crash_mute "$bad_name" >/dev/null 2>&1 ||
    fail "'$bad_name' is taken as a program name, and the flag that writes is not one the watcher will ever read"
done
pass "the command refuses a name that is not a name"

! crash_mute hyprland sideways >/dev/null 2>&1 ||
  fail "an action it does not know is treated as a mute, so a typo silences a program"
pass "the command refuses an action it does not know"

# And says what it refused, or the user retypes the same thing. Captured rather
# than piped: the command exits non-zero here, which pipefail would surface as
# the pipeline's status and read as a failed assertion.
refusal=$(crash_mute hyprland sideways 2>&1) || true
grep -Fq "Not an action" <<<"$refusal" ||
  fail "an unknown action is refused without naming it, leaving the user nothing to correct"
pass "the command names the action it refused"

crash_mute ../bar-off >/dev/null
[[ ! -e "$mute_home/.local/state/omarchy/toggles/bar-off" ]] ||
  fail "a name that climbs out writes a sibling toggle, so muting a crash could turn off the bar instead"
pass "the command cannot be talked into writing outside crash-ignore/"

# A program may be called -h, and the router answers that with its own help
# before the command runs. A leading -- is the way through, so it has to be
# consumed rather than taken for the program name.
crash_mute -- -h >/dev/null 2>&1 ||
  fail "a leading -- is refused rather than consumed, so a program named like a flag cannot be muted at all"
[[ -f $(mute_flag -- -h) ]] ||
  fail "a leading -- is taken for the program name, so muting -h mutes something else"
pass "a leading -- lets a program named like a flag be muted"

# toggle is advertised, so it has to flip both ways rather than quietly mute.
crash_mute toggler off >/dev/null
crash_mute toggler toggle >/dev/null
[[ -f $(mute_flag toggler) ]] ||
  fail "toggle does not mute an un-muted program"
crash_mute toggler toggle >/dev/null
[[ ! -f $(mute_flag toggler) ]] ||
  fail "toggle mutes but never un-mutes, so the advertised action only goes one way"
pass "toggle flips a mute both ways"

# The listing means what the watcher means, and the watcher honours a regular
# file. Anything else in there is not a mute, however much it looks like one.
mkdir -p "$(mute_flag notactuallymuted)"
! crash_mute | grep -Fqx notactuallymuted ||
  fail "a directory is reported as muted while that program's crashes keep arriving"
pass "the listing counts only the flags the watcher honours"
rmdir "$(mute_flag notactuallymuted)"

# A mute that could not be written must not be reported as one. Without this the
# command can print success for a flag that was never created.
failing_bin="$TMPDIR/failing-bin"
mkdir -p "$failing_bin"
cat >"$failing_bin/omarchy-toggle" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$failing_bin/omarchy-toggle"

status=0
refusal=$(HOME="$mute_home" PATH="$failing_bin:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-crash-mute" hyprland 2>&1) || status=$?
(( status != 0 )) ||
  fail "a mute that could not be written exits zero, so nothing downstream learns it failed"
! grep -Fq "Muted crash notifications" <<<"$refusal" ||
  fail "a mute that could not be written still reports success, so the user believes a program is silenced when it is not"
pass "a mute that could not be written is not reported as one"

# A diagnosis must not chain another (#11992): a crash the diagnosis causes, the
# agent's own included, is announced without the offer, and so is a program
# whose diagnosis is under way. Driven through the real watcher and
# omarchy-agent-crash, with the journal, the agent launcher and the notification
# sender stubbed. default-agent-test.sh covers omarchy-agent carrying the marker.
require_command flock

# A runner inside a diagnosis would mark every command below as part of it.
unset OMARCHY_CRASH_DIAGNOSIS

holders=()
cleanup() {
  ((${#holders[@]} == 0)) || kill "${holders[@]}" 2>/dev/null || true
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

diag_bin="$TMPDIR/diag-bin"
agent_bin="$TMPDIR/agent-bin"
stamps="$watch_home/.local/state/omarchy/crash-diagnosis"
AGENT_LOG="$TMPDIR/agent-log"
DEFAULT_AGENT="$TMPDIR/default-agent"
MISSING_COMMANDS="$TMPDIR/missing-commands"

mkdir -p "$diag_bin" "$agent_bin"
echo opencode >"$DEFAULT_AGENT"
: >"$MISSING_COMMANDS"

cat >"$diag_bin/coredumpctl" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$diag_bin/omarchy-default-agent" <<'SH'
#!/bin/bash
cat "$DEFAULT_AGENT"
SH

cat >"$diag_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
grep -Fqx -- "$1" "$MISSING_COMMANDS"
SH

# Stands in for the agent launcher when omarchy-agent-crash is driven, so the
# test sees whether a diagnosis was started, with what marker, and whether the
# dispatch lock came along with it.
cat >"$agent_bin/omarchy-agent" <<'SH'
#!/bin/bash
printf 'marker=%s\n' "${OMARCHY_CRASH_DIAGNOSIS:-}" >>"$AGENT_LOG"
if flock -n "$HOME/.local/state/omarchy/crash-diagnosis.lock" true; then
  echo "lock=free" >>"$AGENT_LOG"
else
  echo "lock=held" >>"$AGENT_LOG"
fi
SH

chmod +x "$diag_bin"/* "$agent_bin"/*

# The watcher's scratch HOME, so the stamps a click writes are the ones the
# watcher reads, and none of the runner's tunables. path_head puts stubs ahead
# of this tree's commands.
in_scratch() {
  PATH="${path_head:-}$diag_bin:$watch_bin:$ROOT/bin:$PATH" \
  NOTIFY_LOG="$NOTIFY_LOG" \
  AGENT_LOG="$AGENT_LOG" \
  DEFAULT_AGENT="$DEFAULT_AGENT" \
  MISSING_COMMANDS="$MISSING_COMMANDS" \
  HOME="$watch_home" \
    env -u OMARCHY_CRASH_DIAGNOSIS_COOLDOWN_SECONDS -u OMARCHY_CRASH_DIAGNOSIS_MAX_SECONDS "$@"
}

# What a click on an offering toast runs, with the agent launcher stubbed.
click_diagnose() {
  path_head="$agent_bin:" in_scratch "$ROOT/bin/omarchy-agent-crash" "$@"
}

click_crash() {
  click_diagnose 4242 "$1" "/usr/bin/$1" SIGSEGV
}

# The same core dump, as the journal hands it over when the environment holds a
# byte that is not printable UTF-8: an array of byte values. This one ends in a
# lone 0xff.
crash_entry_bytes() {
  local comm=$1 exe=$2 environ=$3

  jq -cn --arg uid "$UID" --arg comm "$comm" --arg exe "$exe" --arg environ "$environ" \
    '{_UID: $uid, COREDUMP_COMM: $comm, COREDUMP_PID: "4242",
      COREDUMP_EXE: $exe, COREDUMP_SIGNAL_NAME: "SIGSEGV",
      COREDUMP_ENVIRON: (($environ | explode) + [10, 88, 61, 255])}' >>"$JOURNAL_ENTRIES"
}

offered() {
  grep -Eq "Process crashed: $1 .*--exec omarchy-agent-crash 4242 $1 " "$NOTIFY_LOG"
}

held() {
  announced "$1" && ! offered "$1"
}

diagnoses_started() {
  if [[ -f $AGENT_LOG ]]; then
    grep -c '^marker=' "$AGENT_LOG"
  else
    echo 0
  fi
}

# Starts a process carrying a diagnosis's marker, as the agent or something it
# ran would, and waits until it has exec'd so its environment shows the marker.
hold_marker() {
  local marker=$1 tries

  env "OMARCHY_CRASH_DIAGNOSIS=$marker" sleep 300 >/dev/null 2>&1 &
  holder=$!
  holders+=("$holder")
  for ((tries = 0; tries < 100; tries++)); do
    grep -qszxF -- "OMARCHY_CRASH_DIAGNOSIS=$marker" "/proc/$holder/environ" && return
    sleep 0.05
  done
  fail "the stand-in diagnosis process never showed its marker"
}

release_marker() {
  kill "$holder" 2>/dev/null || true
  wait "$holder" 2>/dev/null || true
}

# Moves a program's diagnoses back in time by their own start, which is what
# ages them, rather than the stamp's mtime: every line, or only the one given.
backdate() {
  local stamp="$stamps/$1" by=$2 only=${3:-} lines line

  mapfile -t lines <"$stamp"
  : >"$stamp"
  for line in "${lines[@]}"; do
    if [[ -z $only || $line == "$only" ]]; then
      line="${line%%:*}:$((${line#*:} - by))"
    fi
    printf '%s\n' "$line" >>"$stamp"
  done
}

# An ordinary crash is offered a diagnosis, and a click starts exactly one.
reset_entries
crash_entry brave /opt/brave/brave
run_watch
offered brave ||
  fail "an ordinary crash no longer offers a diagnosis" "$(cat "$NOTIFY_LOG")"
click_crash brave
(($(diagnoses_started) == 1)) ||
  fail "clicking an ordinary crash's toast did not start one diagnosis"
grep -Eqx "marker=4242:[0-9]+" "$AGENT_LOG" ||
  fail "the diagnosis is not marked with the crash it is diagnosing and when, so the crashes it causes look new" "$(cat "$AGENT_LOG")"
[[ $(cat "$stamps/brave") == "$(sed -n 's/^marker=//p' "$AGENT_LOG")" ]] ||
  fail "the stamp does not record the marker the diagnosis carries, so the watcher cannot tell whether it is still at work"
grep -Fqx "lock=free" "$AGENT_LOG" ||
  fail "the dispatch lock rides into the agent, so it is held for the whole diagnosis"
pass "an ordinary crash offers a diagnosis and a click starts one, marked"

# A second click, on an older toast for the same program, does not start a
# second diagnosis alongside the first, and the refusal offers the way past it.
: >"$NOTIFY_LOG"
click_crash brave
(($(diagnoses_started) == 1)) ||
  fail "a second click on the same program started a second diagnosis while the first is under way"
grep -Fq "Already diagnosing brave" "$NOTIFY_LOG" ||
  fail "a refused click says nothing, so the user cannot tell it from a broken toast"
grep -Fq -- "--exec omarchy-agent-crash --again 4242 brave /usr/bin/brave SIGSEGV" "$NOTIFY_LOG" ||
  fail "the refusal offers no way to start a diagnosis anyway, so a stale guard is a dead end" "$(cat "$NOTIFY_LOG")"
pass "a program already being diagnosed is not dispatched twice"

click_diagnose --again 4242 brave /usr/bin/brave SIGSEGV
(($(diagnoses_started) == 2)) ||
  fail "the refusal's action does not start a diagnosis anyway"
pass "the refusal's action starts a diagnosis anyway"

# The same program crashing again within the cooldown, as the diagnosis
# reproduces it, is announced without the offer.
reset_entries
crash_entry brave /opt/brave/brave
run_watch
announced brave ||
  fail "a crash within the cooldown is not announced at all"
! offered brave ||
  fail "a crash of a program sent for diagnosis minutes ago offers another, chaining an agent per reproduction"
grep -Fq "Already sent for AI diagnosis" "$NOTIFY_LOG" ||
  fail "the toast without the offer does not say why"
pass "a repeat crash within the cooldown is announced without the offer"

# Another program in the same window is still offered.
reset_entries
crash_entry nautilus /usr/bin/nautilus
run_watch
offered nautilus ||
  fail "a diagnosis of one program held back the offer for another"
pass "the cooldown is per program"

# After the cooldown, with nothing left carrying the marker, the same program is
# offered again, and a click starts a diagnosis again.
backdate brave 660
reset_entries
crash_entry brave /opt/brave/brave
run_watch
offered brave ||
  fail "a program is never offered a diagnosis again once its cooldown has passed"
click_crash brave
(($(diagnoses_started) == 3)) ||
  fail "a click after the cooldown did not start a diagnosis"
pass "after the cooldown a program is offered and dispatched again"

# A stamp from the future, after the clock stepped back, does not hold the
# program for hours.
mkdir -p "$stamps"
echo "4242:$((EPOCHSECONDS + 7200))" >"$stamps/mpv"
reset_entries
crash_entry mpv /usr/bin/mpv
run_watch
offered mpv ||
  fail "a stamp dated in the future holds its program back until the clock catches up"
click_crash mpv
(($(diagnoses_started) == 4)) ||
  fail "a click is refused against a stamp dated in the future"
pass "a stamp dated in the future holds nothing back"

# With no default agent a click hands the crash to the agents panel
# (omarchy-agent --pick), where the agent is started, and stamps and marks
# nothing: no diagnosis has started here, and a stamp would refuse every click
# for the cooldown.
: >"$DEFAULT_AGENT"
click_crash krita
[[ ! -e $stamps/krita ]] ||
  fail "a click with no default agent stamped the program, refusing every click after it for nothing"
[[ $(tail -n 2 "$AGENT_LOG" | head -n 1) == "marker=" ]] ||
  fail "a click with no default agent marked a diagnosis that has not started" "$(cat "$AGENT_LOG")"
echo opencode >"$DEFAULT_AGENT"
pass "a click with no default agent goes to the agents panel and holds nothing back"

# An agent omarchy-agent would refuse, its command missing and no package to
# install it from, is refused here and stamps nothing: a diagnosis that never
# started would hold its program for the cooldown. It says why, on the toast and
# on stderr for a hand-run.
echo hermes >"$DEFAULT_AGENT"
echo hermes >"$MISSING_COMMANDS"
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
if click_crash darktable 2>"$TMPDIR/refused-stderr"; then
  fail "a click whose agent cannot start reports success"
fi
(($(diagnoses_started) == starts)) && [[ ! -e $stamps/darktable ]] ||
  fail "a click whose agent cannot start stamped the program, holding it for the cooldown"
grep -Fq "hermes is not installed" "$NOTIFY_LOG" && grep -Fq "hermes is not installed" "$TMPDIR/refused-stderr" ||
  fail "a click whose agent cannot start does not say why" "$(cat "$NOTIFY_LOG" "$TMPDIR/refused-stderr")"
pass "a click whose agent cannot start is refused and holds nothing back"

# The local model has no command of its name, and is checked as pi, the agent
# omarchy-agent opens it in: diagnosed while pi is there, refused once it's gone.
echo local >"$DEFAULT_AGENT"
echo local >"$MISSING_COMMANDS"
starts=$(diagnoses_started)
click_crash inkscape
(($(diagnoses_started) == starts + 1)) && [[ -s $stamps/inkscape ]] ||
  fail "a default of the local model is refused as not installed"
pass "a default of the local model is diagnosed"

for default in local pi; do
  echo "$default" >"$DEFAULT_AGENT"
  echo pi >"$MISSING_COMMANDS"
  starts=$(diagnoses_started)
  : >"$NOTIFY_LOG"
  if click_crash kdenlive 2>"$TMPDIR/refused-stderr"; then
    fail "a click with a default of $default and pi removed reports success"
  fi
  (($(diagnoses_started) == starts)) && [[ ! -e $stamps/kdenlive ]] ||
    fail "a click with a default of $default and pi removed stamped the program, holding it for the cooldown"
  grep -Fq "pi is not installed" "$NOTIFY_LOG" && grep -Fq "pi is not installed" "$TMPDIR/refused-stderr" ||
    fail "a click with a default of $default and pi removed does not name pi" "$(cat "$NOTIFY_LOG" "$TMPDIR/refused-stderr")"
done
echo opencode >"$DEFAULT_AGENT"
: >"$MISSING_COMMANDS"
pass "a default of pi or the local model is refused once pi is removed"

# A hand-run given a truncated comm stamps the executable's name, the one the
# watcher looks up, so the program's next crash is held.
click_diagnose 4242 WebKitWebProces /usr/lib/webkit2gtk-4.1/WebKitWebProcess SIGSEGV
[[ -s $stamps/WebKitWebProcess && ! -e $stamps/WebKitWebProces ]] ||
  fail "a hand-run stamps the comm it was given, not the name the watcher checks" "$(ls "$stamps")"
pass "a hand-run stamps the name the watcher checks"

# A crash carrying the marker came from inside a diagnosis: the agent itself, or
# something it ran. It is announced without the offer, whatever its name. A real
# environment is usually over 4 KiB, which the journal only hands over whole
# with --all.
reset_entries
padding=$(printf 'x%.0s' {1..5000})
crash_entry opencode /home/someone/.local/bin/opencode $'HOME=/home/someone\nOMARCHY_CRASH_DIAGNOSIS=4242:'"$EPOCHSECONDS"$'\nTERM=xterm\nPADDING='"$padding"
run_watch
announced opencode ||
  fail "a crash inside a diagnosis is not announced at all"
! offered opencode ||
  fail "the diagnosis agent's own crash offers a diagnosis of its own, chaining an agent per hop"
grep -Fq "Crashed during an AI crash diagnosis" "$NOTIFY_LOG" ||
  fail "the toast for a crash inside a diagnosis does not say why there is no offer"
pass "a crash inside a diagnosis is announced without the offer"

# The marker can be the first variable in the block, with no newline before it.
reset_entries
crash_entry opencode /home/someone/.local/bin/opencode "OMARCHY_CRASH_DIAGNOSIS=4242:$EPOCHSECONDS"$'\nHOME=/home/someone'
run_watch
held opencode && grep -Fq "Crashed during an AI crash diagnosis" "$NOTIFY_LOG" ||
  fail "a marker that is the first variable in the environment is missed"
pass "the marker is found as the first variable"

# An environment with an escape in it (an exported PS1) and a byte that is not
# UTF-8 arrives as an array of bytes, and the marker in it still counts.
reset_entries
crash_entry_bytes opencode /home/someone/.local/bin/opencode $'PS1=\e[1;32m\\u\e[0m$ \nOMARCHY_CRASH_DIAGNOSIS=4242:'"$EPOCHSECONDS"$'\nHOME=/home/someone'
run_watch
held opencode && grep -Fq "Crashed during an AI crash diagnosis" "$NOTIFY_LOG" ||
  fail "an environment journalled as bytes loses the marker, and the chain comes back" "$(cat "$NOTIFY_LOG")"
pass "the marker is found in an environment journalled as bytes"

# A marker older than the maximum is a program the agent left running, crashing
# long after the diagnosis ended, and is offered like any other.
reset_entries
crash_entry opencode /home/someone/.local/bin/opencode $'HOME=/home/someone\nOMARCHY_CRASH_DIAGNOSIS=4242:'"$((EPOCHSECONDS - 7200))"
run_watch
offered opencode ||
  fail "a marker from a diagnosis hours ago still holds the offer back, so a program the agent left running is never offered again"
pass "an expired marker holds nothing back"

# Only the variable itself counts, not a value that mentions it.
reset_entries
crash_entry gimp /usr/bin/gimp "NOTE=OMARCHY_CRASH_DIAGNOSIS=1:$EPOCHSECONDS"
run_watch
offered gimp ||
  fail "a variable whose value mentions the marker is read as the marker"
pass "the marker is matched as a variable, not as text anywhere in the environment"

# Past the cooldown, a program is still held while something carries the marker
# its stamp records: the diagnosis is still at work. Once nothing does, or past
# the maximum whatever is still running, it is offered again.
click_crash vlc
backdate vlc 660
read -r vlc_marker <"$stamps/vlc"
hold_marker "$vlc_marker"
reset_entries
crash_entry vlc /usr/bin/vlc
run_watch
held vlc ||
  fail "a diagnosis still at work past the cooldown is chained by its program's next crash"
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
click_crash vlc
(($(diagnoses_started) == starts)) && grep -Fq "Already diagnosing vlc" "$NOTIFY_LOG" ||
  fail "a click past the cooldown starts a second diagnosis while the first is still at work"
pass "a diagnosis still at work holds its program past the cooldown"

release_marker
backdate vlc 6540
read -r vlc_marker <"$stamps/vlc"
hold_marker "$vlc_marker"
run_watch
offered vlc ||
  fail "a process left carrying the marker holds its program back past the maximum"
pass "the maximum bounds a diagnosis still apparently at work"

release_marker
backdate vlc -6540
run_watch
offered vlc ||
  fail "a finished diagnosis still holds its program back after the cooldown"
pass "a finished diagnosis holds nothing back after the cooldown"

# A diagnosis started anyway goes beside the one under way, not in its place:
# with the second's cooldown over and the second finished, the first, still at
# work, holds its program. Only once it finishes too is the program offered.
click_crash totem
backdate totem 1200
read -r first_marker <"$stamps/totem"
hold_marker "$first_marker"
starts=$(diagnoses_started)
click_diagnose --again 4242 totem /usr/bin/totem SIGSEGV
(($(diagnoses_started) == starts + 1)) ||
  fail "a diagnosis started anyway beside one still at work did not start"
second_marker=$(sed -n 's/^marker=//p' "$AGENT_LOG" | tail -n 1)
backdate totem 660 "$second_marker"
reset_entries
crash_entry totem /usr/bin/totem
run_watch
held totem ||
  fail "starting a diagnosis anyway dropped the first one's guard, so its reproductions chain an agent once the second's cooldown ends" "$(cat "$stamps/totem")"
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
click_crash totem
(($(diagnoses_started) == starts)) && grep -Fq "Already diagnosing totem" "$NOTIFY_LOG" ||
  fail "a click starts another diagnosis while the first of two is still at work"
(($(grep -c . "$stamps/totem") == 2)) ||
  fail "the stamp does not keep a line for each diagnosis" "$(cat "$stamps/totem")"
pass "a diagnosis started anyway keeps the first one's guard"

release_marker
run_watch
offered totem ||
  fail "a program is held back after every diagnosis of it has finished"
pass "a program is offered again once every diagnosis of it has finished"

# Two clicks at once must not both start one. A click that finds another
# dispatch holding the lock is refused, and stamps nothing.
# The holder execs into sleep with the lock still open, so killing it is what
# releases the lock, and nothing outlives the test holding it.
bash -c 'exec 9>>"$1" && flock 9 && exec sleep 300' _ "$stamps.lock" >/dev/null 2>&1 &
holders+=("$!")
for ((tries = 0; tries < 100; tries++)); do
  flock -n "$stamps.lock" true || break
  sleep 0.05
done
starts=$(diagnoses_started)
: >"$NOTIFY_LOG"
click_crash gedit
(($(diagnoses_started) == starts)) ||
  fail "a click started a diagnosis while another dispatch held the lock"
[[ ! -e $stamps/gedit ]] ||
  fail "a click refused for the lock still stamped the program"
grep -Fq "Already diagnosing gedit" "$NOTIFY_LOG" ||
  fail "a click refused for the lock says nothing"
kill "${holders[-1]}"
wait "${holders[-1]}" 2>/dev/null || true
pass "a click racing another dispatch is refused"
