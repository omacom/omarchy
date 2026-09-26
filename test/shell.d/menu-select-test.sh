#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

require_command perl

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

stub_bin="$tmp_dir/bin"
mkdir -p "$stub_bin"

# Stand in for the menu, answering the way Menu.qml does: a leading glyph is
# dropped, the label comes back with any subtext joined to it by a tab, and an
# empty subtext is no subtext at all. That transformation is what a caller
# asking for an index needs inverted.
cat >"$stub_bin/omarchy-shell" <<'SH'
#!/bin/bash

printf '%s\n' "$3" >>"$OMARCHY_TEST_SUMMONS"

perl -MJSON::PP=decode_json -e '
  my $payload = decode_json($ARGV[0]);
  my $answer = $ENV{OMARCHY_TEST_SELECTION};

  unless (defined $answer) {
    my @parts = split /\t/, $payload->{options}[$ENV{OMARCHY_TEST_PICK}], -1;
    shift @parts if @parts > 1;
    my $label = shift @parts;
    my $detail = join "\t", @parts;
    $answer = length($detail) ? "$label\t$detail" : $label;
  }

  open my $selection, ">", $payload->{selectionFile} or die $!;
  print $selection $answer;
  close $selection;

  open my $done, ">", $payload->{doneFile} or die $!;
  close $done;
' "$4"
SH

chmod +x "$stub_bin"/*

export PATH="$stub_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_SUMMONS="$tmp_dir/summons"
: >"$OMARCHY_TEST_SUMMONS"

errors="$tmp_dir/errors"

# Pick the option at $1, then hand everything else to the menu.
picking() {
  local pick="$1"
  shift

  OMARCHY_TEST_PICK="$pick" omarchy-menu-select "$@" 2>"$errors"
}

[[ $(picking 2 --print-index "Format" jpg png webp) == "2" ]] ||
  fail "an index names the option that was picked" "$(<"$errors")"
pass "an index names the option that was picked"

[[ $(printf '%s\n' one two three | picking 1 --print-index "Pick") == "1" ]] ||
  fail "options read from stdin are indexed too" "$(<"$errors")"
pass "options read from stdin are indexed too"

# The glyph is the reason parsing the answer is fragile: what comes back is
# never what was passed in.
[[ $(picking 1 --print-index "Network" $'󰤨\tWi-Fi' $'󰈀\tEthernet') == "1" ]] ||
  fail "an option with a glyph is still found by index" "$(<"$errors")"
pass "an option with a glyph is still found by index"

# Two rows that read alike are what the subtext is for, and an index tells them
# apart without the caller knowing the subtext is the key.
same_label=($'󰚩\tAgent\tomp' $'󰚩\tAgent\tclaude')
[[ $(picking 1 --print-index "Agent" "${same_label[@]}") == "1" ]] ||
  fail "same-labelled options are told apart by index" "$(<"$errors")"
pass "same-labelled options are told apart by index"

[[ $(picking 1 "Format" jpg png webp) == "png" ]] ||
  fail "without the flag the selection still comes back as text" "$(<"$errors")"
[[ $(picking 1 "Agent" "${same_label[@]}") == $'Agent\tclaude' ]] ||
  fail "without the flag a subtext still comes back joined to its label" "$(<"$errors")"
pass "without the flag the selection still comes back as text"

# An answer that two options could have produced is not invertible. Saying so
# before the menu opens beats acting on whichever row was reached first.
: >"$OMARCHY_TEST_SUMMONS"
if picking 0 --print-index "Agent" $'󰚩\tAgent' $'󰊤\tAgent'; then
  fail "options that come back as the same text are refused"
fi
grep -q 'come back as different text' "$errors" ||
  fail "options that come back as the same text are refused" "$(<"$errors")"
[[ ! -s $OMARCHY_TEST_SUMMONS ]] ||
  fail "an unanswerable list is refused before the menu opens" "$(<"$OMARCHY_TEST_SUMMONS")"
pass "options that come back as the same text are refused"

if OMARCHY_TEST_SELECTION="Betamax" omarchy-menu-select --print-index "Format" jpg png 2>"$errors"; then
  fail "a selection matching no option fails instead of guessing"
fi
grep -q 'matches no option' "$errors" ||
  fail "a selection matching no option fails instead of guessing" "$(<"$errors")"
pass "a selection matching no option fails instead of guessing"

if OMARCHY_TEST_SELECTION="" omarchy-menu-select --print-index "Format" jpg png 2>"$errors"; then
  fail "a dismissed menu still exits non-zero" "$(<"$errors")"
fi
pass "a dismissed menu still exits non-zero"

if omarchy-menu-select --print-name "Format" jpg png 2>"$errors"; then
  fail "an unknown option is refused"
fi
grep -q 'unknown option --print-name' "$errors" ||
  fail "an unknown option is refused" "$(<"$errors")"
pass "an unknown option is refused"

# A prompt is still required, and the flag is not one.
if omarchy-menu-select --print-index 2>"$errors"; then
  fail "the flag alone is not a prompt"
fi
grep -q 'Usage: omarchy-menu-select \[--print-index\]' "$errors" ||
  fail "the flag alone is not a prompt" "$(<"$errors")"
pass "the flag alone is not a prompt"

# Callers that used to recover an id by cutting up the row they displayed.
grep -q -- '--print-index' "$ROOT/bin/omarchy-capture-screenrecording-with-webcam" ||
  fail "the webcam picker keys on its own list"
grep -q -- '--print-index' "$ROOT/bin/omarchy-games-retro-install" ||
  fail "the RetroArch core picker keys on its own list"
pass "the pickers that carry an id key on their own list"
