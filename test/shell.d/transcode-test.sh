#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

tmp=$(mktemp -d)
cleanup() {
  local status=$? pid
  trap - EXIT
  if [[ -f $tmp/wl-copy.pids ]]; then
    while IFS= read -r pid; do
      [[ -n $pid ]] && kill "$pid" 2>/dev/null || true
    done <"$tmp/wl-copy.pids"
  fi
  rm -rf "$tmp"
  exit "$status"
}
trap cleanup EXIT

stub_bin="$tmp/bin"
home="$tmp/home"
mkdir -p "$stub_bin" "$home"

cat >"$stub_bin/file" <<'EOF'
#!/bin/bash
echo "video/mp4"
EOF

cat >"$stub_bin/ffmpeg" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$FFMPEG_LOG"
has_overwrite=false
for arg in "$@"; do
  [[ $arg == "-y" ]] && has_overwrite=true
done
output="${*: -1}"
if [[ -e $output && $has_overwrite != "true" ]]; then
  echo "File '$output' already exists without -y" >&2
  exit 1
fi
printf 'transcoded' >"$output"
EOF

cat >"$stub_bin/wl-copy" <<'EOF'
#!/bin/bash
cat >/dev/null
if [[ ${WL_COPY_FAIL:-0} == "1" ]]; then
  echo "Failed to connect to a compositor" >&2
  exit 1
fi
# Emulate wl-copy's background clipboard server inheriting stdout/stderr.
sleep 30 &
echo "$!" >>"$WL_COPY_PIDS"
EOF

cat >"$stub_bin/omarchy-notification-send" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$NOTIFY_LOG"
EOF

chmod +x "$stub_bin/file" "$stub_bin/ffmpeg" "$stub_bin/wl-copy" "$stub_bin/omarchy-notification-send"

input="$tmp/demo.mov"
printf 'video' >"$input"

# Overwriting existing outputs works across all three video paths without
# hanging a piped caller on wl-copy's background clipboard process.
for case_spec in "mp4 4k" "mp4 1080p" "gif 720p"; do
  read -r fmt res <<<"$case_spec"
  existing="$tmp/demo-$res.$fmt"
  printf 'old' >"$existing"
  : >"$tmp/ffmpeg.log"
  : >"$tmp/notify.log"

  timeout 5 bash -c '
    set -euo pipefail
    PATH="$1" HOME="$2" OMARCHY_PATH="$3" \
      FFMPEG_LOG="$4" NOTIFY_LOG="$5" WL_COPY_PIDS="$6" \
      "$3/bin/omarchy-transcode" "$7" "$8" "$9" 2>&1 | cat >/dev/null
  ' _ "$stub_bin:$ROOT/bin:$PATH" "$home" "$ROOT" \
    "$tmp/ffmpeg.log" "$tmp/notify.log" "$tmp/wl-copy.pids" \
    "$input" "$fmt" "$res" ||
    fail "transcoding $fmt $res overwrites existing output without hanging piped callers"

  [[ $(<"$existing") == "transcoded" ]] ||
    fail "transcoding $fmt $res replaced existing output"
  grep -Fq "Saved and copied to clipboard." "$tmp/notify.log" ||
    fail "transcoding $fmt $res sent completion notification"
done
pass "video transcoding overwrites existing output without hanging piped callers"

# When wl-copy fails, stderr stays visible and the completion toast is not sent.
: >"$tmp/notify.log"
status=0
err=$(PATH="$stub_bin:$ROOT/bin:$PATH" HOME="$home" OMARCHY_PATH="$ROOT" \
  FFMPEG_LOG="$tmp/ffmpeg.log" NOTIFY_LOG="$tmp/notify.log" \
  WL_COPY_PIDS="$tmp/wl-copy.pids" WL_COPY_FAIL=1 \
  "$ROOT/bin/omarchy-transcode" "$input" mp4 1080p 2>&1 >/dev/null) || status=$?

(( status != 0 )) || fail "wl-copy failure exits non-zero"
grep -Fq "Failed to connect to a compositor" <<<"$err" ||
  fail "wl-copy failure keeps stderr visible" "$err"
! grep -Fq "Saved and copied to clipboard." "$tmp/notify.log" ||
  fail "wl-copy failure does not send the copied-to-clipboard notification"
pass "clipboard failure surfaces wl-copy stderr instead of swallowing it"
