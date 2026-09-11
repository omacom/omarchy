#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

export PATH="$ROOT/bin:$PATH"

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

export OMARCHY_EDITION_FILE="$workdir/omarchy-edition"

# An install that predates editions has no marker at all, and every one of those
# is a desktop.
[[ $(omarchy-edition) == "desktop" ]] ||
  fail "edition defaults to desktop when the marker is missing"
omarchy-edition-desktop ||
  fail "the desktop predicate holds when the marker is missing"
! omarchy-edition-server ||
  fail "the server predicate fails when the marker is missing"
pass "a missing marker reads as the desktop edition"

printf 'server\n' >"$OMARCHY_EDITION_FILE"
[[ $(omarchy-edition) == "server" ]] || fail "edition reads server from the marker"
omarchy-edition-server || fail "the server predicate holds for a server marker"
! omarchy-edition-desktop || fail "the desktop predicate fails for a server marker"
pass "a server marker flips both predicates"

printf 'desktop\n' >"$OMARCHY_EDITION_FILE"
[[ $(omarchy-edition) == "desktop" ]] || fail "edition reads desktop from the marker"
omarchy-edition-desktop || fail "the desktop predicate holds for a desktop marker"
! omarchy-edition-server || fail "the server predicate fails for a desktop marker"
pass "a desktop marker flips both predicates back"

# Trailing whitespace is what a hand-edited marker or a heredoc leaves behind.
printf '  server  \n\n' >"$OMARCHY_EDITION_FILE"
[[ $(omarchy-edition) == "server" ]] || fail "edition ignores surrounding whitespace"
pass "surrounding whitespace in the marker is ignored"

# Guessing here would silently hand a half-configured machine the wrong edition,
# so an unreadable marker is an error, and both predicates stay false.
for bogus in "" "Server" "workstation"; do
  printf '%s\n' "$bogus" >"$OMARCHY_EDITION_FILE"
  ! omarchy-edition >/dev/null 2>&1 ||
    fail "edition rejects an unrecognized marker" "accepted: ${bogus:-<empty>}"
  ! omarchy-edition-server ||
    fail "the server predicate fails for an unrecognized marker" "accepted: ${bogus:-<empty>}"
  ! omarchy-edition-desktop ||
    fail "the desktop predicate fails for an unrecognized marker" "accepted: ${bogus:-<empty>}"
done
pass "an unrecognized marker fails loudly and leaves both predicates false"

omarchy-edition-set server >/dev/null || fail "edition-set writes the server marker"
[[ $(omarchy-edition) == "server" ]] || fail "edition-set is readable by omarchy-edition"
omarchy-edition-set desktop >/dev/null || fail "edition-set writes the desktop marker"
[[ $(omarchy-edition) == "desktop" ]] || fail "edition-set overwrites a previous marker"
pass "edition-set round-trips through omarchy-edition"

! omarchy-edition-set workstation >/dev/null 2>&1 ||
  fail "edition-set rejects an unknown edition"
[[ $(omarchy-edition) == "desktop" ]] ||
  fail "a rejected edition-set leaves the marker untouched"
! omarchy-edition-set >/dev/null 2>&1 || fail "edition-set requires an argument"
! omarchy-edition-set desktop server >/dev/null 2>&1 ||
  fail "edition-set refuses more than one argument"
pass "edition-set validates its argument before writing"
