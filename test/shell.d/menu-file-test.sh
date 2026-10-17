#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

STUB_DIR="$TMPDIR/stub"
mkdir -p "$STUB_DIR" "$TMPDIR/home/Pictures" "$TMPDIR/home/Videos"

cat >"$STUB_DIR/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notification: %s\n' "$*" >>"$FAKE_CALLS"
STUB

chmod +x "$STUB_DIR"/*

: >"$TMPDIR/calls"

# Empty ~/Pictures and ~/Videos are what a fresh install has. The real menu
# helpers run here: an empty list must never reach the picker's usage check.
status=0
HOME="$TMPDIR/home" PATH="$STUB_DIR:$ROOT/bin:$PATH" FAKE_CALLS="$TMPDIR/calls" \
  "$ROOT/bin/omarchy-transcode" >"$TMPDIR/out" 2>"$TMPDIR/err" || status=$?

(( status != 0 )) || fail "transcode with nothing to pick exits non-zero"
[[ $(cat "$TMPDIR/err") != *"Usage: omarchy-menu-select"* ]] \
  || fail "transcode with nothing to pick does not print the picker's usage" "$(cat "$TMPDIR/err")"
[[ $(cat "$TMPDIR/calls") == *"notification: No files found $TMPDIR/home/Pictures, $TMPDIR/home/Videos"* ]] \
  || fail "transcode with nothing to pick says so in a notification" "$(cat "$TMPDIR/calls")"
pass "transcode with nothing to pick says so instead of failing silently"

# With a file to pick, the list still reaches the picker, newest first.
cat >"$STUB_DIR/omarchy-menu-select" <<'STUB'
#!/bin/bash
cat >"$FAKE_ROWS"
head -n 1 "$FAKE_ROWS"
STUB
chmod +x "$STUB_DIR/omarchy-menu-select"

touch -d '2026-01-01' "$TMPDIR/home/Pictures/old.png"
touch -d '2026-02-01' "$TMPDIR/home/Videos/new.mp4"
touch "$TMPDIR/home/Pictures/notes.txt"

pick=$(HOME="$TMPDIR/home" PATH="$STUB_DIR:$PATH" FAKE_ROWS="$TMPDIR/rows" \
  "$ROOT/bin/omarchy-menu-file" "Pick" "$TMPDIR/home/Pictures:$TMPDIR/home/Videos" "png mp4")

[[ $(cat "$TMPDIR/rows") == "$TMPDIR/home/Videos/new.mp4"$'\n'"$TMPDIR/home/Pictures/old.png" ]] \
  || fail "menu-file offers matching files newest first" "$(cat "$TMPDIR/rows")"
[[ $pick == "$TMPDIR/home/Videos/new.mp4" ]] || fail "menu-file returns the pick" "$pick"
pass "menu-file offers matching files newest first and returns the pick"

# find fails on an unreadable subdirectory, but what it did find is still
# offered and the pick still comes back as a success.
mkdir "$TMPDIR/home/Pictures/locked"
chmod 000 "$TMPDIR/home/Pictures/locked"

if [[ -r $TMPDIR/home/Pictures/locked ]]; then
  skip "menu-file survives an unreadable subdirectory (running as root)"
else
  status=0
  pick=$(HOME="$TMPDIR/home" PATH="$STUB_DIR:$PATH" FAKE_ROWS="$TMPDIR/rows" \
    "$ROOT/bin/omarchy-menu-file" "Pick" "$TMPDIR/home/Pictures" "png") || status=$?

  (( status == 0 )) && [[ $pick == "$TMPDIR/home/Pictures/old.png" ]] \
    || fail "menu-file survives an unreadable subdirectory" "status=$status pick=$pick"
  pass "menu-file survives an unreadable subdirectory"
fi

chmod 755 "$TMPDIR/home/Pictures/locked"
