#!/bin/bash

set -euo pipefail

# omarchy-theme-set-openclaw writes Omarchy's colors into OpenClaw's config
# through OpenClaw's own config command, and what it writes depends on what
# the installed OpenClaw's schema accepts. Both are exercised here against a
# throwaway HOME with the openclaw command stubbed, so a palette that stopped
# being validated, a write into an OpenClaw that was never set up, a key sent
# to an OpenClaw that does not know it, or an activation that trampled a
# chosen theme shows up in what was run.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

# The stub answers the three questions the hook asks: what the config's ui
# section holds (OMARCHY_TEST_UI, unset being an error as with the real
# command), what the schema holds (a customTheme key only when
# OMARCHY_TEST_PALETTE is 1), and whether a batch write is accepted. Every
# call is recorded, batches whole.
cat >"$mock_bin/openclaw" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_OPENCLAW_CALLS"
case "$1 $2" in
  "config schema")
    if [[ ${OMARCHY_TEST_PALETTE:-0} == 1 ]]; then
      echo '{"properties":{"ui":{"properties":{"seamColor":{},"prefs":{},"customTheme":{}}}}}'
    else
      echo '{"properties":{"ui":{"properties":{"seamColor":{},"prefs":{}}}}}'
    fi
    ;;
  "config set")
    # A write that takes its time, once: the first run past it has built its
    # batch from the theme it saw, and a later run could land before it.
    if [[ -f ${OMARCHY_TEST_SLOW_WRITE:-/nonexistent} ]]; then
      rm -f "$OMARCHY_TEST_SLOW_WRITE"
      sleep 2
    fi
    if [[ $3 == "--batch-json" ]]; then
      printf '%s\n' "$4" >"$OMARCHY_TEST_OPENCLAW_BATCH"
      printf '%s\n' "$4" >>"$OMARCHY_TEST_OPENCLAW_BATCH.log"
      cat "$HOME/.local/state/omarchy/openclaw-accent" >"$OMARCHY_TEST_OPENCLAW_BATCH.note" 2>/dev/null || true
      # A write that lands and then dies: what the read after it will show.
      if [[ -n ${OMARCHY_TEST_LANDED:-} && ${OMARCHY_TEST_WRITE_FAILS:-0} == 1 ]]; then
        jq -c '{prefs: {accent: (.[] | select(.path == "ui.prefs.accent") | .value)}}' <<<"$4" >"$OMARCHY_TEST_LANDED"
      fi
    fi
    [[ ${OMARCHY_TEST_WRITE_FAILS:-0} == 0 ]]
    ;;
  "config get")
    # A theme switch landing while the hook is at work replaces the palette
    # under it; the swap happens once, on the first read past it.
    if [[ -f ${OMARCHY_TEST_SWAP_SOURCE:-/nonexistent} ]]; then
      mv "$OMARCHY_TEST_SWAP_SOURCE" "$HOME/.local/state/omarchy/current/theme/openclaw.json"
    fi
    # A read that fails for some other reason than an unset section.
    [[ ${OMARCHY_TEST_READ_FAILS:-0} == 0 ]] || { echo '{"ok":false,"error":{"type":"cli_error","message":"Gateway config could not be loaded"}}'; exit 1; }
    # A write that landed before its process died: the read after it shows
    # the accent it carried.
    if [[ -f ${OMARCHY_TEST_LANDED:-/nonexistent} ]]; then
      printf '%s\n' "$(cat "$OMARCHY_TEST_LANDED")"
      exit 0
    fi
    [[ -n ${OMARCHY_TEST_UI:-} ]] || { echo '{"ok":false,"error":{"type":"cli_error","message":"Config path is valid but unset: ui. The runtime default applies."}}'; exit 1; }
    printf '%s\n' "$OMARCHY_TEST_UI"
    ;;
esac
SH

# The command is looked for through the helper, so a machine that removed
# the app but kept its config can be played without touching PATH.
cat >"$mock_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash
[[ $1 == "openclaw" && ${OMARCHY_TEST_OPENCLAW_INSTALLED:-1} == 0 ]]
SH

chmod +x "$mock_bin"/*

# A palette with every token the template names, as a rendered theme has.
good_palette=$(jq '.colors |= with_entries(.value = "#1a1b26")
  | .colors.accent = "#7aa2f7"
  | .colors."accent-subtle" = "rgba(122,162,247, 0.12)"
  | .colors."font-body" = "system-ui, sans-serif"' "$ROOT/default/themed/openclaw.json.tpl")

test_home="$test_tmp/home"
openclaw_config="$test_home/.openclaw/openclaw.json"
record="$test_home/.local/state/omarchy/openclaw-accent"
calls="$test_tmp/calls"
batch="$test_tmp/batch"

# Each case gets a fresh HOME so no file survives from the one before. Only
# --set-up adds the config that says OpenClaw's onboarding has run, and only
# --wrote adds Omarchy's note of the accent it last wrote.
reset_home() {
  local source="$good_palette"

  rm -rf "$test_home"
  mkdir -p "$test_home/.local/state/omarchy/current/theme"
  : >"$calls"
  rm -f "$batch" "$batch.log" "$batch.note"

  while (( $# > 0 )); do
    case "$1" in
      --set-up)
        mkdir -p "$test_home/.openclaw"
        echo '{}' >"$openclaw_config"
        ;;
      --wrote)
        printf '%s\n' "$2" >"$record"
        shift
        ;;
      *) source="$1" ;;
    esac
    shift
  done

  printf '%s\n' "$source" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
}

run_hook() {
  OMARCHY_TEST_OPENCLAW_CALLS="$calls" \
    OMARCHY_TEST_OPENCLAW_BATCH="$batch" \
    OMARCHY_TEST_PALETTE="${OMARCHY_TEST_PALETTE:-0}" \
    OMARCHY_TEST_UI="${OMARCHY_TEST_UI:-}" \
    OMARCHY_TEST_WRITE_FAILS="${OMARCHY_TEST_WRITE_FAILS:-0}" \
    OMARCHY_TEST_OPENCLAW_INSTALLED="${OMARCHY_TEST_OPENCLAW_INSTALLED:-1}" \
    OMARCHY_TEST_SLOW_WRITE="${OMARCHY_TEST_SLOW_WRITE:-}" \
    OMARCHY_TEST_SWAP_SOURCE="${OMARCHY_TEST_SWAP_SOURCE:-}" \
    OMARCHY_TEST_READ_FAILS="${OMARCHY_TEST_READ_FAILS:-0}" \
    OMARCHY_TEST_LANDED="${OMARCHY_TEST_LANDED:-}" \
    PATH="$mock_bin:$PATH" \
    HOME="$test_home" \
    OMARCHY_PATH="$ROOT" \
    XDG_RUNTIME_DIR="$test_tmp" \
    OPENCLAW_CONFIG_PATH='' \
    "$ROOT/bin/omarchy-theme-set-openclaw" "$@"
}

batch_paths() {
  jq -r '.[].path' "$batch" | paste -sd ' '
}

# -- publishing ---------------------------------------------------------------

reset_home
run_hook 2>"$test_tmp/stderr"
[[ ! -s $calls ]] || fail "nothing is run for an OpenClaw that never onboarded" "$(cat "$calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch says nothing about a missing OpenClaw" "$(cat "$test_tmp/stderr")"
pass "a theme switch leaves a machine that never set up OpenClaw alone"

reset_home --set-up
rm "$test_home/.local/state/omarchy/current/theme/openclaw.json"
run_hook
[[ ! -s $calls ]] || fail "nothing is run without a generated palette" "$(cat "$calls")"
pass "a theme switch without a generated palette runs nothing"

# Onboarding's repair pass reads a config written after it began as the
# wizard having applied setup, and would end the wizard on a deadline; while
# onboarding holds its lock a switch writes nothing and says nothing.
reset_home --set-up
exec 7>"$test_tmp/omarchy-openclaw-onboard.lock"
flock 7
run_hook 2>"$test_tmp/stderr"
[[ ! -s $calls ]] || fail "nothing is run while onboarding holds its lock" "$(cat "$calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch during onboarding is quiet" "$(cat "$test_tmp/stderr")"
run_hook --activate 2>"$test_tmp/stderr"
grep -q 'being set up' "$test_tmp/stderr" || fail "--activate during onboarding says so" "$(cat "$test_tmp/stderr")"
flock -u 7
run_hook
grep -q 'config set' "$calls" || fail "a switch after onboarding released its lock publishes" "$(cat "$calls")"
pass "a theme switch during onboarding leaves the config to onboarding's own hand-over"

# The other way round, a hook already writing holds onboarding off until its
# write has landed, so the config onboarding starts from is never moved under
# it: while the hook is mid-write the lock cannot be taken exclusively.
reset_home --set-up
: >"$test_tmp/slow-write"
OMARCHY_TEST_SLOW_WRITE="$test_tmp/slow-write" run_hook &
hook_pid=$!
until [[ ! -f $test_tmp/slow-write ]]; do sleep 0.1; done
if flock -x -n 7; then
  flock -u 7
  fail "a hook mid-write holds the onboarding lock"
fi
wait "$hook_pid"
flock -x -n 7 || fail "a hook that has finished lets onboarding go ahead"
flock -u 7
pass "a hook mid-write holds onboarding off until its write has landed"

reset_home --set-up
OMARCHY_TEST_OPENCLAW_INSTALLED=0 run_hook 2>"$test_tmp/stderr"
[[ ! -s $calls ]] || fail "a config left behind by a removed OpenClaw is not written to" "$(cat "$calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch says nothing about a removed OpenClaw" "$(cat "$test_tmp/stderr")"
pass "a theme switch leaves a config the removed app kept alone"

reset_home --set-up
run_hook 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "an OpenClaw without palette support gets the accent, as the seam color and the shown accent" "$(cat "$batch")"
[[ $(jq -r '[.[].value] | unique | .[]' "$batch") == "#7aa2f7" ]] || fail "the accent written is the theme's" "$(cat "$batch")"
[[ $(grep -c 'config set' "$calls") == 1 ]] || fail "publishing is one config write" "$(cat "$calls")"
[[ $(cat "$record") == "#7aa2f7" ]] || fail "the accent written is noted" "$(cat "$record" 2>&1)"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch publishes quietly" "$(cat "$test_tmp/stderr")"
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#000000","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(cat "$record") == "#7aa2f7" ]] || fail "once the write has landed the note names the accent written alone" "$(cat "$record")"
# A write that is refused puts the note back: the accent it was to carry
# never landed, and a note of it would read a later choice of that very
# accent as Omarchy's. The stub records the note as it stood when the write
# was attempted, which is what a run stopped mid-write leaves behind.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#000000","prefs":{"accent":"#ff66ff"}}' OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>/dev/null || true
[[ $(cat "$batch.note") == $'#7aa2f7\n#ff66ff' ]] || fail "until the write lands the note keeps the accent found and judged Omarchy's as well" "$(cat "$batch.note")"
[[ $(cat "$record") == "#ff66ff" ]] || fail "a refused write puts the note back" "$(cat "$record")"
reset_home --set-up
OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>/dev/null || true
[[ $(cat "$batch.note") == "#7aa2f7" ]] || fail "a first write notes the accent it carries" "$(cat "$batch.note")"
[[ ! -e $record ]] || fail "a refused first write leaves no note" "$(cat "$record")"
reset_home --set-up --wrote $'#ff66ff\n#000000'
OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>/dev/null || true
[[ $(cat "$batch.note") == $'#7aa2f7\n#ff66ff' ]] || fail "with no accent shown, the accent noted before stays behind the new one" "$(cat "$batch.note")"
[[ $(cat "$record") == $'#ff66ff\n#000000' ]] || fail "a refused write puts a two-line note back whole" "$(cat "$record")"

# A write that landed before its process died is a write that landed: the
# accent is noted alone, as after a clean write.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' OMARCHY_TEST_WRITE_FAILS=1 OMARCHY_TEST_LANDED="$test_tmp/landed" run_hook 2>/dev/null || true
[[ $(cat "$record") == "#7aa2f7" ]] || fail "a write that landed before its process died is noted as written" "$(cat "$record")"
rm -f "$test_tmp/landed"

# A read that fails for any reason other than an unset section says nothing
# about what the UI shows, and a chosen accent must not be taken for unset.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_READ_FAILS=1 run_hook 2>"$test_tmp/stderr" && fail "a failed config read is not a success"
! grep -q 'config set' "$calls" || fail "nothing is written when the config could not be read" "$(cat "$calls")"
[[ $(cat "$record") == "#ff66ff" ]] || fail "a failed read leaves the note alone" "$(cat "$record")"
grep -q 'Could not read' "$test_tmp/stderr" || fail "a failed read is reported" "$(cat "$test_tmp/stderr")"
pass "a config that cannot be read is left as it is"

# The accent a refused write was to carry is not Omarchy's claim afterwards.
reset_home --set-up --wrote '#111111'
OMARCHY_TEST_UI='{"seamColor":"#111111","prefs":{"accent":"#111111"}}' OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>/dev/null || true
OMARCHY_TEST_UI='{"seamColor":"#111111","prefs":{"accent":"#7aa2f7"}}' run_hook
[[ $(batch_paths) == "ui.seamColor" ]] ||
  fail "an accent chosen in OpenClaw that a refused write once carried is the user's" "$(cat "$batch") note: $(cat "$record")"

# The accent found is Omarchy's claim only until the write lands: choosing it
# again in OpenClaw afterwards is a choice.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' run_hook
OMARCHY_TEST_UI='{"seamColor":"#7aa2f7","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(batch_paths) == "ui.seamColor" ]] ||
  fail "an accent chosen in OpenClaw that Omarchy wrote before the last one is the user's" "$(cat "$batch") note: $(cat "$record")"
[[ $(ls "$(dirname "$record")" | grep -c openclaw-accent) == 1 ]] || fail "no temporary file is left beside the note"
pass "the accent is written as OpenClaw's seam color and shown accent, and noted"

reset_home --set-up --wrote '#FF66FF'
OMARCHY_TEST_UI='{"seamColor":"#000000","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "an accent still equal to the one Omarchy wrote is Omarchy's to replace, whatever the seam color says" "$(cat "$batch")"
pass "a theme switch replaces the accent it wrote before"

# An operator may have set the seam color by hand and a user chosen the same
# accent before this hook existed; with no note, neither is Omarchy's.
reset_home --set-up
OMARCHY_TEST_UI='{"seamColor":"#FF66FF","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(batch_paths) == "ui.seamColor" ]] ||
  fail "without a note, an accent equal to the seam color is still the user's" "$(cat "$batch")"
pass "a theme switch leaves an accent equal to the seam color where no note exists"

reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#00aa00"}}' run_hook 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor" ]] ||
  fail "an accent that differs from the one Omarchy wrote was chosen in OpenClaw and stays; the seam color still follows" "$(cat "$batch")"
[[ $(cat "$record") == "#ff66ff" ]] || fail "the note is not moved while the user owns the accent" "$(cat "$record")"
[[ ! -s $test_tmp/stderr ]] || fail "a chosen accent is left without comment on a theme switch" "$(cat "$test_tmp/stderr")"
pass "a theme switch leaves an accent the user chose in OpenClaw"

reset_home --set-up
OMARCHY_TEST_UI='{"prefs":{"accent":"#00aa00"}}' run_hook
[[ $(batch_paths) == "ui.seamColor" ]] ||
  fail "an accent set before Omarchy ever wrote one was chosen in OpenClaw" "$(cat "$batch")"
[[ ! -e $record ]] || fail "no note is made of an accent Omarchy did not write"
pass "a theme switch leaves an accent chosen before Omarchy wrote one"

# The note must not move while the user owns the accent: if it did, a theme
# whose accent happens to equal the chosen one would make the choice look
# like Omarchy's on the switch after.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#123456","prefs":{"accent":"#7aa2f7"}}' run_hook
[[ $(batch_paths) == "ui.seamColor" ]] ||
  fail "a theme whose accent matches the chosen one does not take the accent over" "$(cat "$batch")"
[[ $(cat "$record") == "#ff66ff" ]] || fail "the note stays at what Omarchy last wrote" "$(cat "$record")"
pass "a theme sharing the chosen accent leaves the note of what Omarchy wrote alone"

# Restoring the default in Appearance clears the shown accent, and the UI
# then falls back to the seam color, which has to be the current theme's.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#7aa2f7"}' run_hook
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] || fail "a restored default is followed again" "$(cat "$batch")"
pass "a theme switch takes the accent back once the default is restored"

# Two switches in quick succession: the first run has built its batch from
# the first theme and is held up writing it while the second runs through,
# and the config must end on the second theme.
reset_home --set-up
first_palette=$(jq '.colors.accent = "#111111"' <<<"$good_palette")
second_palette=$(jq '.colors.accent = "#222222"' <<<"$good_palette")
printf '%s\n' "$first_palette" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
: >"$test_tmp/slow-write"
OMARCHY_TEST_SLOW_WRITE="$test_tmp/slow-write" run_hook &
first_pid=$!
# The stub takes the sentinel as it enters the slow write, which is when the
# first run has its batch and the theme may change under it.
until [[ ! -f $test_tmp/slow-write ]]; do sleep 0.1; done
printf '%s\n' "$second_palette" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
run_hook
wait "$first_pid"
[[ $(grep -c . "$batch.log") == 2 ]] || fail "both switches publish" "$(cat "$batch.log")"
[[ $(tail -1 "$batch.log" | jq -r '.[0].value') == "#222222" ]] ||
  fail "the later switch is the last to write" "$(cat "$batch.log")"
pass "two switches in quick succession end on the later theme"

# The note has to be what was written, not what the theme became during the
# write: a note of the new theme against an accent of the old would read
# that accent as the user's from then on.
reset_home --set-up
printf '%s\n' "$first_palette" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
: >"$test_tmp/slow-write"
OMARCHY_TEST_SLOW_WRITE="$test_tmp/slow-write" run_hook &
first_pid=$!
until [[ ! -f $test_tmp/slow-write ]]; do sleep 0.1; done
printf '%s\n' "$second_palette" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
wait "$first_pid"
[[ $(jq -r '.[] | select(.path == "ui.prefs.accent") | .value' "$batch") == "#111111" ]] ||
  fail "the first run wrote the theme it started with" "$(cat "$batch")"
[[ $(cat "$record") == "#111111" ]] || fail "the note is the accent that was written, not the theme that came after" "$(cat "$record")"
pass "a theme changing under a write does not poison the note"

# A switch landing while the hook is between reading the config and writing
# it must not leak into what the hook publishes: everything a run sends comes
# from the one palette it validated.
reset_home --set-up
jq '.colors."accent-2" = "rgba({{ yellow_rgb }}, 0.7)" | .colors.accent = "#333333"' <<<"$good_palette" >"$test_tmp/swap"
OMARCHY_TEST_PALETTE=1 OMARCHY_TEST_SWAP_SOURCE="$test_tmp/swap" run_hook
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent ui.customTheme ui.prefs.theme" ]] ||
  fail "a run publishes the palette it validated" "$(cat "$batch")"
[[ $(jq -r '.[] | select(.path == "ui.customTheme") | .value.dark.accent' "$batch") == "#7aa2f7" ]] ||
  fail "a palette swapped under a run is not the one published" "$(cat "$batch")"
pass "a theme switch landing mid-run does not leak into what is published"

reset_home --set-up
OMARCHY_TEST_PALETTE=1 run_hook 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent ui.customTheme ui.prefs.theme" ]] ||
  fail "an OpenClaw that accepts a palette gets the accent, the palette and its selection in one write" "$(cat "$batch")"
palette_written() { jq -c '.[] | select(.path == "ui.customTheme") | .value' "$batch"; }
[[ $(palette_written | jq -r '.label') == "Omarchy" ]] || fail "the palette carries its label" "$(cat "$batch")"
[[ $(palette_written | jq -c '.dark') == $(jq -c '.colors' <<<"$good_palette") ]] ||
  fail "the palette's dark map is the generated colors" "$(cat "$batch")"
[[ $(palette_written | jq -c '.light') == $(palette_written | jq -c '.dark') ]] ||
  fail "an Omarchy theme is one mode, so both maps carry the same colors" "$(cat "$batch")"
[[ $(grep -c 'config set' "$calls") == 1 ]] || fail "publishing is one config write" "$(cat "$calls")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch publishes quietly" "$(cat "$test_tmp/stderr")"
pass "the palette is published once the schema declares it"

reset_home --set-up '{"label": "Omarchy", "colors": {"bg": "#1a1b26", "accent": "{{ accent }}"}}'
run_hook 2>"$test_tmp/stderr"
! grep -q 'config set' "$calls" || fail "an unresolved accent is not written" "$(cat "$calls")"
grep -q 'not a plain color palette' "$test_tmp/stderr" || fail "an unresolved accent is reported" "$(cat "$test_tmp/stderr")"
pass "a palette with an unresolved accent is not published"

# A theme without some other palette key renders it empty and leaves what
# was derived from it as a literal placeholder; OpenClaw would refuse either,
# but the accent is whole and still goes. Each fixture is the whole palette
# with one value spoiled, so it is the value and not a missing key that is
# refused.
for unresolved in \
  "$(jq '.colors."accent-2" = ""' <<<"$good_palette")" \
  "$(jq '.colors."accent-2-muted" = "rgba({{ yellow_rgb }}, 0.7)"' <<<"$good_palette")" \
  "$(jq '.colors.bg = {"url": "file:///etc/passwd"}' <<<"$good_palette")" \
  "$(jq '.colors.bg = 1' <<<"$good_palette")"; do
  reset_home --set-up "$unresolved"
  run_hook 2>"$test_tmp/stderr"
  [[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] || fail "an unresolved palette still yields the accent" "$(cat "$batch")"
  [[ ! -s $test_tmp/stderr ]] || fail "an unresolved palette is not reported where no palette could go anyway" "$(cat "$test_tmp/stderr")"

  reset_home --set-up "$unresolved"
  OMARCHY_TEST_PALETTE=1 run_hook 2>"$test_tmp/stderr"
  [[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] || fail "an unresolved palette is not published to an OpenClaw that would take one" "$(cat "$batch")"
  grep -q 'accent alone' "$test_tmp/stderr" || fail "an unresolved palette is reported where a palette could have gone" "$(cat "$test_tmp/stderr")"
done
pass "a palette with unresolved colors yields the accent alone"

# The Control UI renders a custom theme only whole, so a theme shipping an
# openclaw.json of its own that names fewer tokens than the template, or no
# label, is not a palette OpenClaw could show.
for partial in \
  "$(jq 'del(.colors.bg)' <<<"$good_palette")" \
  "$(jq 'del(.label)' <<<"$good_palette")" \
  "$(jq '.label = ""' <<<"$good_palette")"; do
  reset_home --set-up "$partial"
  OMARCHY_TEST_PALETTE=1 run_hook 2>"$test_tmp/stderr"
  [[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] || fail "a palette short of the template's tokens yields the accent alone" "$(cat "$batch")"
  grep -q 'accent alone' "$test_tmp/stderr" || fail "a palette short of the template's tokens is reported" "$(cat "$test_tmp/stderr")"
done
pass "a palette short of the template's tokens yields the accent alone"

for bad in \
  '{"label": "Omarchy", "colors": {"bg": "#1a1b26"}}' \
  '{"label": "Omarchy", "colors": {"accent": "7aa2f7"}}' \
  '{"label": "Omarchy", "colors": "#7aa2f7"}' \
  '{"label": "Omarchy"' \
  'name: omarchy'; do
  reset_home --set-up "$bad"
  run_hook 2>/dev/null
  ! grep -q 'config set' "$calls" || fail "a palette that is not an object of named strings with a hex accent is not published" "$bad"
done
pass "an accent is held to the shape the template promises"

reset_home --set-up
OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>"$test_tmp/stderr" && fail "a refused write is not a success"
grep -q 'did not accept' "$test_tmp/stderr" || fail "a refused write is reported" "$(cat "$test_tmp/stderr")"
pass "a write OpenClaw refuses fails the hook"

# The note is written before the config, so a run that stops between the two
# leaves the config on an accent the note still names, whichever of the two
# it is: the one found there, if the write never happened, or the new one.
# That holds where the accent found was known only from the seam color, and
# across more than one refused write.
reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>/dev/null || true
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "an accent left in place by a refused write is still Omarchy's on the switch after" "$(cat "$batch") note: $(cat "$record")"

# A run killed between the note and the write leaves the two-line note and
# the config on the accent found, the note's second line.
reset_home --set-up --wrote $'#7aa2f7\n#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "an accent named second in the note a killed run left is still Omarchy's" "$(cat "$batch") note: $(cat "$record")"

reset_home --set-up --wrote '#ff66ff'
for attempt in '#111111' '#222222'; do
  printf '%s\n' "$(jq --arg a "$attempt" '.colors.accent = $a' <<<"$good_palette")" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
  OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' OMARCHY_TEST_WRITE_FAILS=1 run_hook 2>/dev/null || true
done
printf '%s\n' "$good_palette" >"$test_home/.local/state/omarchy/current/theme/openclaw.json"
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' run_hook
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "an accent is still Omarchy's after two refused writes of other accents" "$(cat "$batch") note: $(cat "$record")"
pass "a run that stops between note and write leaves the accent Omarchy's"

reset_home
mkdir -p "$test_tmp/elsewhere"
echo '{}' >"$test_tmp/elsewhere/openclaw.json"
OPENCLAW_CONFIG_PATH="$test_tmp/elsewhere/openclaw.json" \
  OMARCHY_TEST_OPENCLAW_CALLS="$calls" OMARCHY_TEST_OPENCLAW_BATCH="$batch" OMARCHY_TEST_PALETTE=0 \
  PATH="$mock_bin:$PATH" HOME="$test_home" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_tmp" \
  "$ROOT/bin/omarchy-theme-set-openclaw"
[[ -s $batch ]] || fail "a config OpenClaw was pointed at elsewhere is followed" "$(cat "$calls")"
[[ ! -e $record ]] || fail "a config elsewhere does not write the default config's note" "$(cat "$record")"
[[ $(ls "$(dirname "$record")" | grep -c '^openclaw-accent-') == 1 ]] ||
  fail "a config elsewhere gets a note of its own" "$(ls "$(dirname "$record")")"
pass "the hook follows OPENCLAW_CONFIG_PATH like OpenClaw does, with a note per config"

# Another spelling of the default config names the same config, and its note.
reset_home --set-up --wrote '#ff66ff'
OPENCLAW_CONFIG_PATH="$test_home/.openclaw/./openclaw.json" \
  OMARCHY_TEST_OPENCLAW_CALLS="$calls" OMARCHY_TEST_OPENCLAW_BATCH="$batch" OMARCHY_TEST_PALETTE=0 \
  OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#ff66ff"}}' \
  PATH="$mock_bin:$PATH" HOME="$test_home" OMARCHY_PATH="$ROOT" XDG_RUNTIME_DIR="$test_tmp" \
  "$ROOT/bin/omarchy-theme-set-openclaw"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "the default config spelled another way still reads the default note" "$(cat "$batch")"
[[ $(ls "$(dirname "$record")" | grep -c '^openclaw-accent-') == 0 ]] ||
  fail "the default config spelled another way gets no note of its own" "$(ls "$(dirname "$record")")"
pass "an equivalent spelling of the config path is the same config"

# -- activation ---------------------------------------------------------------

reset_home
rm "$test_home/.local/state/omarchy/current/theme/openclaw.json"
run_hook --activate 2>"$test_tmp/stderr" && fail "--activate without a generated palette is not a success"
grep -q 'theme source missing' "$test_tmp/stderr" || fail "--activate without a palette says what is missing" "$(cat "$test_tmp/stderr")"
pass "--activate reports a missing palette"

reset_home
run_hook --activate 2>"$test_tmp/stderr"
[[ ! -s $calls ]] || fail "--activate runs nothing for an OpenClaw that never onboarded" "$(cat "$calls")"
grep -q 'not set up yet' "$test_tmp/stderr" || fail "--activate says OpenClaw is not set up" "$(cat "$test_tmp/stderr")"
pass "--activate reports an OpenClaw that never onboarded"

reset_home --set-up
OMARCHY_TEST_OPENCLAW_INSTALLED=0 run_hook --activate 2>"$test_tmp/stderr"
[[ ! -s $calls ]] || fail "--activate runs nothing where the app was removed" "$(cat "$calls")"
grep -q 'not installed' "$test_tmp/stderr" || fail "--activate says OpenClaw is not installed" "$(cat "$test_tmp/stderr")"
pass "--activate reports a removed OpenClaw"

reset_home --set-up
run_hook --activate 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent" ]] ||
  fail "--activate on an OpenClaw without palette support writes the accent" "$(cat "$batch")"
[[ ! -s $test_tmp/stderr ]] || fail "--activate is quiet where the accent is all there is" "$(cat "$test_tmp/stderr")"
pass "--activate without palette support is the accent alone"

reset_home --set-up
OMARCHY_TEST_PALETTE=1 run_hook --activate 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent ui.customTheme ui.prefs.theme" ]] ||
  fail "--activate selects the palette on an OpenClaw with no theme chosen, in the same write" "$(cat "$batch")"
[[ $(jq -r '.[] | select(.path == "ui.prefs.theme") | .value' "$batch") == "custom" ]] ||
  fail "the theme selected is the custom family the palette fills" "$(cat "$batch")"
[[ $(grep -c 'config set' "$calls") == 1 ]] || fail "activation is one config write" "$(cat "$calls")"
[[ ! -s $test_tmp/stderr ]] || fail "--activate selects quietly" "$(cat "$test_tmp/stderr")"
pass "--activate selects the palette where no theme was chosen"

reset_home --set-up
OMARCHY_TEST_PALETTE=1 OMARCHY_TEST_UI='{"prefs":{"theme":"custom"}}' run_hook --activate 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent ui.customTheme" ]] ||
  fail "a palette already selected is republished and not selected again" "$(cat "$batch")"
[[ ! -s $test_tmp/stderr ]] || fail "a palette already selected is left without comment" "$(cat "$test_tmp/stderr")"
pass "--activate leaves a palette already selected as it is"

reset_home --set-up
OMARCHY_TEST_PALETTE=1 OMARCHY_TEST_UI='{"prefs":{"theme":"rose"}}' run_hook --activate 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent ui.customTheme" ]] ||
  fail "the palette is still published beside a chosen theme, and the theme is never replaced" "$(cat "$batch")"
grep -q "'rose' theme; leaving it" "$test_tmp/stderr" || fail "a chosen theme is named when it is left" "$(cat "$test_tmp/stderr")"
pass "--activate leaves a theme the user chose in OpenClaw"

reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#00aa00"}}' run_hook --activate 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor" ]] || fail "--activate never replaces an accent chosen in OpenClaw" "$(cat "$batch")"
grep -q 'accent of its own; leaving it' "$test_tmp/stderr" || fail "a chosen accent is named when it is left" "$(cat "$test_tmp/stderr")"
pass "--activate leaves an accent the user chose in OpenClaw"

reset_home --set-up --wrote '#ff66ff'
OMARCHY_TEST_PALETTE=1 OMARCHY_TEST_UI='{"seamColor":"#ff66ff","prefs":{"accent":"#00aa00"}}' run_hook
[[ $(batch_paths) == "ui.seamColor ui.customTheme ui.prefs.theme" ]] ||
  fail "the palette is published and selected beside a chosen accent, which stays" "$(cat "$batch")"
pass "a chosen accent does not keep the palette from being published"

# An OpenClaw that starts accepting the palette after the one-shot migration
# ran is only ever reached by theme switches, so a switch selects it too.
reset_home --set-up
OMARCHY_TEST_PALETTE=1 run_hook 2>"$test_tmp/stderr"
[[ $(jq -r '.[] | select(.path == "ui.prefs.theme") | .value' "$batch") == "custom" ]] ||
  fail "a theme switch selects the palette where no theme was chosen" "$(cat "$batch")"
[[ ! -s $test_tmp/stderr ]] || fail "a theme switch selects quietly" "$(cat "$test_tmp/stderr")"
pass "a theme switch selects the palette where no theme was chosen"

reset_home --set-up
OMARCHY_TEST_PALETTE=1 OMARCHY_TEST_UI='{"prefs":{"theme":"rose"}}' run_hook 2>"$test_tmp/stderr"
[[ $(batch_paths) == "ui.seamColor ui.prefs.accent ui.customTheme" ]] ||
  fail "a theme switch publishes beside a chosen theme and never replaces it" "$(cat "$batch")"
[[ ! -s $test_tmp/stderr ]] || fail "a chosen theme is left without comment on a theme switch" "$(cat "$test_tmp/stderr")"
pass "a theme switch leaves a theme the user chose in OpenClaw"

run_hook --bogus 2>/dev/null && fail "an unknown flag is rejected"
pass "an unknown flag is rejected"
