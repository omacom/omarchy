#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"
export HOME="$work/home" XDG_DATA_HOME="$work/note data" OMARCHY_PATH="$ROOT"
export PATH="$work/bin:$ROOT/bin:$PATH" EDITOR_ARGS="$work/editor-args"
printf '#!/bin/bash\nexit 0\n' >"$work/bin/omarchy-notification-send"
cat >"$work/bin/omarchy-launch-editor" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$EDITOR_ARGS"
STUB
cat >"$work/bin/wl-paste" <<'STUB'
#!/bin/bash
requested=""
while (( $# )); do
  if [[ $1 == "--type" ]]; then requested=$2; shift; fi
  shift
done
if [[ ${CLIP_KIND:-text} == "image" ]]; then
  [[ $requested != "text" ]] || exit 1
  printf '\211PNG\r\n'
else
  printf 'a clipboard note'
fi
STUB
chmod +x "$work/bin"/*

if CLIP_KIND=image "$ROOT/bin/omarchy-scratch" paste >"$work/output" 2>&1; then
  fail "an image-only clipboard is refused"
fi
file="$XDG_DATA_HOME/omarchy/scratch.md"
[[ ! -e $file ]] || fail "image data is never appended to the note"
pass "image-only clipboard contents are refused"

"$ROOT/bin/omarchy-scratch" paste
grep -Fq 'a clipboard note' "$file" || fail "text clipboard contents are saved"
pass "text clipboard contents are saved"

EDITOR='omarchy-launch-editor --inline' "$ROOT/bin/omarchy-scratch" open
mapfile -d '' -t arguments <"$EDITOR_ARGS"
[[ ${#arguments[@]} == 2 && ${arguments[0]} == "--inline" && ${arguments[1]} == "$file" ]] ||
  fail "the editor receives its flag and the note path as separate arguments"
pass "the default editor command opens a note whose path contains spaces"
