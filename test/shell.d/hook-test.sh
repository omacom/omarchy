#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
hooks="$home/.config/omarchy/hooks"
mkdir -p "$hooks"

run_hook() {
  HOME="$home" "$ROOT/bin/omarchy-hook" "$@" >"$tmpdir/out" 2>"$tmpdir/err"
}

# Drive the shipped event names rather than a copy of them, so an event added
# with a name the guard rejects fails here instead of silently never firing.
for shipped in "$ROOT"/config/omarchy/hooks/*.d; do
  event=$(basename "$shipped" .d)
  printf 'echo ran-%s "$@"\n' "$event" >"$hooks/$event"

  run_hook "$event" one two || fail "hook runs the shipped event $event" "$(cat "$tmpdir/err")"

  [[ $(cat "$tmpdir/out") == "ran-$event one two" ]] ||
    fail "hook forwards arguments to $event" "$(cat "$tmpdir/out")"
done

pass "hook runs every shipped event and forwards its arguments"

# Both halves matter: the name has to be rejected, and the script it would have
# resolved to outside the hooks directory has to stay unexecuted.
mkdir -p "$hooks/nested"
printf 'echo escaped\n' >"$home/.config/omarchy/escape"
printf 'echo escaped\n' >"$home/.config/escape"

refuses() {
  local name="$1"

  if run_hook "$name"; then
    fail "hook rejects $name"
  fi

  grep -Fq "Invalid hook name: $name" "$tmpdir/err" ||
    fail "hook reports $name as an invalid hook name" "$(cat "$tmpdir/err")"

  if grep -Fq escaped "$tmpdir/out"; then
    fail "hook leaves scripts outside the hooks directory unexecuted: $name"
  fi
}

refuses ../escape
refuses ../../escape
refuses nested/../../escape
refuses ..
refuses .
refuses /etc/passwd
refuses ""

pass "hook rejects names that escape the hooks directory"
