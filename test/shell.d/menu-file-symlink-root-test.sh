#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-menu-file uses GNU find -printf (Arch packaging). Skip on BSD find.
if ! find --version >/dev/null 2>&1; then
  pass "no GNU find; skipping menu-file symlink-root coverage"
  exit 0
fi
if ! find -H / -maxdepth 0 -printf '' >/dev/null 2>&1; then
  pass "find lacks -printf; skipping menu-file symlink-root coverage"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub_bin="$tmp/bin"
mkdir -p "$stub_bin" "$tmp/real_media" "$tmp/home"

# Real directory with a matching file; expose it only via a symlink root
# (the regression: GNU find without -H skips symlink command-line roots).
printf 'x' >"$tmp/real_media/clip.webm"
printf 'y' >"$tmp/real_media/note.txt"
ln -s "$tmp/real_media" "$tmp/home/Videos"

# Interior loop must not turn a successful pick into failure under pipefail.
mkdir -p "$tmp/real_media/sub"
ln -s "$tmp/real_media" "$tmp/real_media/sub/loop"

# Record stdin rows offered to the selector, then return first path (or forced pick).
cat >"$stub_bin/omarchy-menu-select" <<'STUB'
#!/bin/bash
cat >"${OMARCHY_TEST_ROWS:?}"
if [[ -n ${OMARCHY_TEST_PICK:-} ]]; then
  printf '%s\n' "$OMARCHY_TEST_PICK"
  exit 0
fi
head -n1 "${OMARCHY_TEST_ROWS}"
STUB
chmod +x "$stub_bin/omarchy-menu-select"

export PATH="$stub_bin:$ROOT/bin:$PATH"
export OMARCHY_TEST_ROWS="$tmp/rows"
unset OMARCHY_TEST_PICK || true

: >"$OMARCHY_TEST_ROWS"
out=$(
  omarchy-menu-file "Select video" "$tmp/home/Videos" "webm mp4" 2>/dev/null
) || fail "omarchy-menu-file exits 0 for a symlink directory root" "exit=$?"

rows=$(cat "$OMARCHY_TEST_ROWS")
# find -H prints paths via the command-line root (…/Videos/clip.webm)
[[ $rows == *"/Videos/clip.webm"* || $rows == *"/real_media/clip.webm"* ]] \
  || fail "omarchy-menu-file offers a file under a symlink root to the selector" "rows=$rows"
pass "omarchy-menu-file offers a file under a symlink root to the selector"

[[ $out == *clip.webm* ]] \
  || fail "omarchy-menu-file returns the selected path under a symlink root" "out=$out"
pass "omarchy-menu-file returns the selected path under a symlink root"

[[ $rows != *note.txt* ]] \
  || fail "omarchy-menu-file filters by format under a symlink root" "rows=$rows"
pass "omarchy-menu-file filters by format under a symlink root"

mkdir -p "$tmp/real_pics"
printf 'z' >"$tmp/real_pics/shot.jpg"
ln -sfn "$tmp/real_media" "$tmp/home/Pictures"

: >"$OMARCHY_TEST_ROWS"
out=$(
  omarchy-menu-file "Select media" "$tmp/home/Pictures:$tmp/real_pics" "jpg webm" 2>/dev/null
) || fail "omarchy-menu-file exits 0 for mixed symlink and real roots"

rows=$(cat "$OMARCHY_TEST_ROWS")
[[ $rows == *clip.webm* && $rows == *shot.jpg* ]] \
  || fail "omarchy-menu-file merges symlink and real roots" "rows=$rows"
pass "omarchy-menu-file merges symlink and real roots"

export OMARCHY_TEST_PICK="$tmp/home/Videos/clip.webm"
: >"$OMARCHY_TEST_ROWS"
out=$(
  omarchy-menu-file "Select video" "$tmp/home/Videos" "webm" 2>/dev/null
) || fail "omarchy-menu-file stays exit 0 when an interior symlink loop exists under a followed root" "exit=$?"
[[ $out == "$tmp/home/Videos/clip.webm" || $out == *clip.webm* ]] \
  || fail "omarchy-menu-file still returns the pick when an interior loop exists" "out=$out"
pass "omarchy-menu-file stays healthy with an interior symlink loop under a followed root"
