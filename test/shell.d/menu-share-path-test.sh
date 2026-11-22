#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin" "$tmp/home" "$tmp/work"
printf '#!/bin/bash\nprintf "%%s\\n" "$*" >>"$LOG"\n' >"$tmp/bin/systemd-run"
cp "$tmp/bin/systemd-run" "$tmp/bin/omarchy-notification-send"
chmod +x "$tmp/bin/"*

share() {
  : >"$tmp/log"
  (cd "$tmp/work" && PATH="$tmp/bin:$ROOT/bin:$PATH" HOME="$tmp/home" LOG="$tmp/log" \
    "$ROOT/bin/omarchy-menu-share" file "$@")
}

missing="$tmp/does-not-exist"
! share "$missing" 2>/dev/null || fail "a missing path exits non-zero"
grep -Fq "Path does not exist: $missing" "$tmp/log" || fail "a missing path is named in a notification" "$(cat "$tmp/log")"
! grep -Fq localsend "$tmp/log" || fail "a missing path does not launch LocalSend" "$(cat "$tmp/log")"
pass "a missing path is refused before LocalSend launches"

touch "$tmp/work/note.txt"
share note.txt || fail "a relative path is shared"
grep -Fqx -- "--user --quiet --collect localsend --headless send $tmp/work/note.txt" "$tmp/log" ||
  fail "a relative path reaches LocalSend as an absolute path" "$(cat "$tmp/log")"
pass "a relative path reaches LocalSend as an absolute path"

ln -s note.txt "$tmp/work/shared-note.txt"
share "$tmp/work/shared-note.txt" || fail "a symlink is shared"
grep -Fqx -- "--user --quiet --collect localsend --headless send $tmp/work/shared-note.txt" "$tmp/log" ||
  fail "a symlink keeps its shared name" "$(cat "$tmp/log")"
pass "a symlink keeps its shared name"
