#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
uri_prefix=$(python3 -I -c 'import pathlib, sys; print(pathlib.Path(sys.argv[1]).resolve().as_uri())' "$scratch")
mkdir -p "$scratch/bin" "$scratch/home"
export HOME="$scratch/home"
export PATH="$scratch/bin:$PATH"
export CLIPBOARD_FILE="$scratch/clipboard" NOTIFICATION_LOG="$scratch/notifications"

# Exercise the real command without encoding media or touching a live clipboard.
cat > "$scratch/bin/file" <<'STUB'
#!/bin/bash
printf '%s\n' "${TEST_MIME:-image/png}"
STUB

cat > "$scratch/bin/magick" <<'STUB'
#!/bin/bash
[[ ${ENCODE_FAIL:-0} == "0" ]] || exit 7
printf 'converted\n' > "${!#}"
STUB
cp "$scratch/bin/magick" "$scratch/bin/ffmpeg"

cat > "$scratch/bin/wl-copy" <<'STUB'
#!/bin/bash
(( $# == 2 )) && [[ $1 == "--type" && $2 == "text/uri-list" ]] || exit 8
[[ ${CLIPBOARD_FAIL:-0} == "0" ]] || exit 9
cat > "$CLIPBOARD_FILE"
STUB

cat > "$scratch/bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf '%s\n' "$@" >> "$NOTIFICATION_LOG"
STUB

# Answer only the optional video-quality prompt; never open a real menu.
cat > "$scratch/bin/omarchy-menu-select" <<'STUB'
#!/bin/bash
if [[ ${1:-} == "Select quality" ]]; then
  printf '%s\n' medium
else
  printf 'Unexpected menu selection: %s\n' "$*" >&2
  exit 99
fi
STUB

cat > "$scratch/bin/omarchy-menu-file" <<'STUB'
#!/bin/bash
printf 'Unexpected file picker: %s\n' "$*" >&2
exit 99
STUB

# The dummy media has no duration; keep quality estimates on their fallback.
cat > "$scratch/bin/ffprobe" <<'STUB'
#!/bin/bash
exit 1
STUB
chmod +x "$scratch/bin/"*

check_uri() {
  local input="$1" format="$2" resolution="$3" expected="$4" description="$5"
  mkdir -p "$(dirname -- "$input")"
  printf 'source\n' > "$input"
  rm -f "$CLIPBOARD_FILE" "$NOTIFICATION_LOG"
  bash "$ROOT/bin/omarchy-transcode" "$input" "$format" "$resolution" || fail "$description"
  printf '%s\n' "$expected" > "$scratch/expected"
  cmp -s "$scratch/expected" "$CLIPBOARD_FILE" || fail "$description"
  grep -q '^Saved and copied to clipboard' "$NOTIFICATION_LOG" || fail "successful copy reports completion"
  pass "$description"
}

check_uri "$scratch/plain.png" jpg low \
  "$uri_prefix/plain-low.jpg" "plain image paths keep their existing clipboard URI"
check_uri "$scratch/shot#1?take%20.png" png low \
  "$uri_prefix/shot%231%3Ftake%2520-low.png" "reserved characters are encoded rather than interpreted as URI syntax"
check_uri "$scratch/space name.png" jpg medium \
  "$uri_prefix/space%20name-medium.jpg" "spaces are encoded in clipboard paths"
check_uri "$scratch/Grüße.png" png high \
  "$uri_prefix/Gr%C3%BC%C3%9Fe-high.png" "UTF-8 filenames produce escaped ASCII URIs"
check_uri "$scratch/line"$'\n'"break"$'\t'".png" png low \
  "$uri_prefix/line%0Abreak%09-low.png" "newlines and tabs stay inside a single clipboard URI"
check_uri "$scratch/it's a photo.png" jpg low \
  "$uri_prefix/it%27s%20a%20photo-low.jpg" "quotes in filenames remain data"
check_uri "$scratch/folder #1/source.png" png low \
  "$uri_prefix/folder%20%231/source-low.png" "parent directory names are encoded as well"

mkdir -p "$scratch/real"
ln -s "$scratch/real" "$scratch/linked"
(
  cd "$scratch"
  check_uri "linked/relative.png" png low \
    "$uri_prefix/real/relative-low.png" "relative paths and symlinks still resolve to the output file"
)

mkdir -p "$scratch/shadow"
printf 'raise RuntimeError("must not import from the current directory")\n' > "$scratch/shadow/pathlib.py"
(
  cd "$scratch/shadow"
  check_uri "local.png" png low \
    "$uri_prefix/shadow/local-low.png" "URI conversion does not import Python modules from the current directory"
)

TEST_MIME=video/mp4 check_uri "$scratch/video#1.mp4" mp4 720p \
  "$uri_prefix/video%231-720p.mp4" "video outputs use the same URI encoding"
TEST_MIME=video/mp4 check_uri "$scratch/clip%20.mp4" gif 720p \
  "$uri_prefix/clip%2520-720p.gif" "GIF outputs preserve literal percent escapes in filenames"

for mime in image/png video/mp4; do
  rm -f "$CLIPBOARD_FILE" "$NOTIFICATION_LOG"
  format=png
  resolution=low
  if [[ $mime == "video/mp4" ]]; then
    format=mp4
    resolution=720p
  fi
  if TEST_MIME="$mime" ENCODE_FAIL=1 bash "$ROOT/bin/omarchy-transcode" "$scratch/plain.png" "$format" "$resolution"; then
    fail "encoder failure must fail transcoding"
  else
    status=$?
    (( status == 7 )) || fail "encoder failure is propagated" "exit status: $status"
  fi
  [[ ! -e $CLIPBOARD_FILE ]] || fail "encoder failure must not overwrite the clipboard"
  ! grep -q '^Saved and copied to clipboard' "$NOTIFICATION_LOG" 2>/dev/null || fail "encoder failure must not report success"
  pass "$mime encoder failures leave the clipboard untouched"
done

rm -f "$CLIPBOARD_FILE" "$NOTIFICATION_LOG"
if CLIPBOARD_FAIL=1 bash "$ROOT/bin/omarchy-transcode" "$scratch/plain.png" png low; then
  fail "clipboard failure must fail transcoding"
else
  status=$?
  (( status == 9 )) || fail "clipboard failure is propagated" "exit status: $status"
fi
! grep -q '^Saved and copied to clipboard' "$NOTIFICATION_LOG" 2>/dev/null || fail "clipboard failure must not report success"
pass "clipboard failure does not report successful completion"

cat > "$scratch/bin/python3" <<'STUB'
#!/bin/bash
exit 10
STUB
chmod +x "$scratch/bin/python3"
rm -f "$CLIPBOARD_FILE" "$NOTIFICATION_LOG"
if bash "$ROOT/bin/omarchy-transcode" "$scratch/plain.png" png low; then
  fail "URI conversion failure must fail transcoding"
else
  status=$?
  (( status == 10 )) || fail "URI conversion failure is propagated" "exit status: $status"
fi
[[ ! -e $CLIPBOARD_FILE ]] || fail "URI conversion failure must not overwrite the clipboard"
! grep -q '^Saved and copied to clipboard' "$NOTIFICATION_LOG" 2>/dev/null || fail "URI conversion failure must not report success"
pass "URI conversion failure leaves the clipboard untouched"
