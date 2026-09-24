#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

STUB_DIR="$TMPDIR/stub"
mkdir -p "$STUB_DIR"

# Records the rows it was offered, then answers with the first one. The exit
# status can be forced so the caller's propagation can be checked.
cat >"$STUB_DIR/omarchy-menu-select" <<'STUB'
#!/bin/bash
cat >"$OMARCHY_TEST_ROWS"
if (( ${OMARCHY_TEST_MENU_EXIT:-0} != 0 )); then
  exit "$OMARCHY_TEST_MENU_EXIT"
fi
head -n 1 "$OMARCHY_TEST_ROWS"
STUB

chmod +x "$STUB_DIR"/*

export PATH="$STUB_DIR:$ROOT/bin:$PATH"
export OMARCHY_TEST_ROWS="$TMPDIR/rows"

# pick runs the command against a set of paths and formats, leaving the rows it
# offered in $TMPDIR/rows and its exit status in the variable named by $3.
pick() {
  local paths="$1" formats="$2"

  : >"$OMARCHY_TEST_ROWS"
  omarchy-menu-file "Select media" "$paths" "$formats" >/dev/null 2>&1 || true
  ROWS=$(cat "$OMARCHY_TEST_ROWS")
}

# ~/Pictures and ~/Videos are symlinks on plenty of machines (media moved to a
# bigger disk). find without -L never descends into them, so the picker used to
# come up empty and the caller never opened its next panel.
home="$TMPDIR/home"
mkdir -p "$home" "$TMPDIR/storage/pictures" "$TMPDIR/storage/videos"
: >"$TMPDIR/storage/pictures/photo.jpg"
: >"$TMPDIR/storage/pictures/shot.png"
: >"$TMPDIR/storage/videos/clip.mp4"
ln -s "$TMPDIR/storage/pictures" "$home/Pictures"
ln -s "$TMPDIR/storage/videos" "$home/Videos"

pick "$home/Pictures:$home/Videos" "jpg png mp4"

[[ $ROWS == *"$home/Pictures/photo.jpg"* ]] ||
  fail "symlinked starting point is descended" "$ROWS"
[[ $ROWS == *"$home/Pictures/shot.png"* ]] ||
  fail "every format is picked up under a symlinked directory" "$ROWS"
[[ $ROWS == *"$home/Videos/clip.mp4"* ]] ||
  fail "a second symlinked starting point is descended" "$ROWS"
pass "symlinked picture and video directories are searched"

# -H follows the starting point but not a symlink nested inside it, so media
# reachable only through a second hop is not swept into the menu.
mkdir -p "$TMPDIR/elsewhere"
: >"$TMPDIR/elsewhere/nested.jpg"
ln -s "$TMPDIR/elsewhere" "$TMPDIR/storage/pictures/nested"

pick "$home/Pictures" "jpg"

[[ $ROWS == *"photo.jpg"* ]] || fail "starting-point symlink is still searched" "$ROWS"
[[ $ROWS != *"nested.jpg"* ]] || fail "a nested symlink is not followed" "$ROWS"
pass "only starting-point symlinks are followed"

# Hidden directories and dotfiles still stay out of the menu.
: >"$TMPDIR/storage/pictures/.hidden.jpg"
mkdir -p "$TMPDIR/storage/pictures/.private"
: >"$TMPDIR/storage/pictures/.private/secret.jpg"

pick "$home/Pictures" "jpg"

[[ $ROWS == *"photo.jpg"* ]] || fail "visible file still offered" "$ROWS"
[[ $ROWS != *".hidden.jpg"* ]] || fail "hidden file stays out of the menu" "$ROWS"
[[ $ROWS != *"secret.jpg"* ]] || fail "hidden directory stays out of the menu" "$ROWS"
pass "hidden files and directories stay out of the menu"

# A large library is capped so the option list cannot blow past the argument
# size limit, keeping the newest files by modification time.
mkdir -p "$home/Big"
for i in $(seq 1 550); do
  : >"$home/Big/file$(printf '%04d' "$i").jpg"
done

pick "$home/Big" "jpg"

offered=$(grep -c . "$OMARCHY_TEST_ROWS" || true)
[[ $offered == 500 ]] || fail "large result sets are capped at 500 rows" "offered: $offered"
pass "large result sets are capped at 500 rows"

# The caller branches on the menu's status, so an empty pick has to propagate.
: >"$OMARCHY_TEST_ROWS"
if OMARCHY_TEST_MENU_EXIT=1 omarchy-menu-file "Select media" "$home/Pictures" "jpg" >/dev/null 2>&1; then
  fail "a dismissed menu propagates its non-zero status"
fi
pass "a dismissed menu propagates its non-zero status"
