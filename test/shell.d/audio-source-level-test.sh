#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/bin"

# A recorder that yields 40 ms of silence, 40 ms at peak 0.125 and 40 ms of a
# full-scale sample, then keeps running like a live microphone.
cat >"$work/bin/parec" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$ARGS"
echo $$ >"$PIDFILE"
python3 -c "
import struct, sys
n = 48000 // 25
out = sys.stdout.buffer
out.write(struct.pack('<%df' % n, *([0.0] * n)))
out.write(struct.pack('<%df' % n, *([0.0] * (n - 1) + [-0.125])))
out.write(struct.pack('<%df' % n, *([0.0] * (n - 1) + [1.5])))
out.flush()"
exec sleep 30
SH
chmod +x "$work/bin/parec"
export ARGS="$work/args" PIDFILE="$work/pid"

PATH="$work/bin:$PATH" python3 "$ROOT/bin/omarchy-audio-source-level" virtual_mic >"$work/out" &
helper=$!
for _ in $(seq 50); do [[ $(wc -l <"$work/out") -ge 3 ]] && break; sleep 0.1; done
[[ $(head -3 "$work/out" | tr '\n' ' ') == "0.000 0.500 1.000 " ]] ||
  fail 'source level is the cube root of each 40 ms peak, capped at full scale' "$(cat "$work/out")"
pass 'source level is the cube root of each 40 ms peak, capped at full scale'

grep -qx -- '--device=virtual_mic' "$ARGS" && grep -qx -- '--property=node.name=omarchy-audio-level' "$ARGS" &&
  grep -qx -- '--property=media.category=Monitor' "$ARGS" ||
  fail 'source level records the named source as a named monitor stream' "$(cat "$ARGS")"
pass 'source level records the named source as a named monitor stream'

kill "$helper"
wait "$helper" 2>/dev/null || true
recorder=$(cat "$PIDFILE")
for _ in $(seq 30); do kill -0 "$recorder" 2>/dev/null || break; sleep 0.1; done
! kill -0 "$recorder" 2>/dev/null || fail 'stopping source level stops its recorder'
pass 'stopping source level stops its recorder'

for args in "" "--device=x" "a b"; do
  status=0
  # shellcheck disable=SC2086
  PATH="$work/bin:$PATH" python3 "$ROOT/bin/omarchy-audio-source-level" $args >/dev/null 2>&1 || status=$?
  [[ $status == 2 ]] || fail "source level refuses arguments '$args'" "status $status"
done
pass 'source level takes exactly one source name'
