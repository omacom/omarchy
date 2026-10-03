#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

# pw-metadata keeps clock.force-quantum in a file; reads print it the way
# PipeWire does.
cat >"$tmp/bin/pw-metadata" <<SH
#!/bin/bash
state="$tmp/quantum"
[[ \${PIPEWIRE_DOWN:-0} == 1 ]] && exit 1
if (( \$# == 5 )); then
  echo "\$5" >"\$state"
elif [[ -f \$state ]]; then
  echo "Found \"settings\" metadata 30"
  echo "update: id:0 key:'clock.force-quantum' value:'\$(cat "\$state")' type:''"
fi
SH
printf '#!/bin/bash\necho "$*" >>"%s/notifications"\n' "$tmp" >"$tmp/bin/omarchy-notification-send"
# PipeWire's data loop shows FF (FIFO) when it has realtime priority, TS
# otherwise. pgrep must ask for this user's PipeWire.
printf '#!/bin/bash\n[[ " $* " == *" -u %s "* ]] && echo 4242\n' "$UID" >"$tmp/bin/pgrep"
printf '#!/bin/bash\necho " TS pipewire"\necho " ${OTHER_CLASS:-TS} module-rt"\necho " ${PIPEWIRE_CLASS:-FF} data-loop.0"\n' >"$tmp/bin/ps"
chmod +x "$tmp/bin/"*

toggle() {
  PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-toggle-low-latency-audio" "$@"
}

rm -f "$tmp/quantum"
! toggle --status || fail "low-latency audio starts off when PipeWire has no forced quantum"
pass "low-latency audio starts off when PipeWire has no forced quantum"

toggle
[[ $(cat "$tmp/quantum") == 256 ]] || fail "toggling on forces a 256-sample quantum" "$(cat "$tmp/quantum")"
toggle --status || fail "status reports low-latency audio on"
pass "toggling on forces a 256-sample quantum and status reports it"

toggle
[[ $(cat "$tmp/quantum") == 0 ]] || fail "toggling off clears the forced quantum"
! toggle --status || fail "status reports low-latency audio off"
pass "toggling off clears the forced quantum"

toggle on && toggle on
[[ $(cat "$tmp/quantum") == 256 ]] || fail "on is idempotent"
toggle off
[[ $(cat "$tmp/quantum") == 0 ]] || fail "off clears the forced quantum"
pass "on and off set the state explicitly"

: >"$tmp/notifications"
PIPEWIRE_CLASS=TS toggle on
grep -q "realtime priority" "$tmp/notifications" || fail "turning on without realtime priority says so" "$(cat "$tmp/notifications")"
: >"$tmp/notifications"
PIPEWIRE_CLASS=FF toggle on
! grep -q "realtime" "$tmp/notifications" || fail "turning on with realtime priority shows no hint" "$(cat "$tmp/notifications")"
: >"$tmp/notifications"
PIPEWIRE_CLASS=TS OTHER_CLASS=FF toggle on
grep -q "realtime priority" "$tmp/notifications" || fail "only the data loop's scheduling counts" "$(cat "$tmp/notifications")"
pass "the realtime hint follows the data loop's actual scheduling"

toggle off
: >"$tmp/notifications"
if PIPEWIRE_DOWN=1 toggle on 2>/dev/null; then
  fail "a failed PipeWire write is reported as a failure"
fi
[[ ! -s $tmp/notifications ]] || fail "a failed PipeWire write sends no notification" "$(cat "$tmp/notifications")"
echo 256 >"$tmp/quantum"
: >"$tmp/notifications"
if PIPEWIRE_DOWN=1 toggle 2>/dev/null || PIPEWIRE_DOWN=1 toggle off 2>/dev/null; then
  fail "a failed PipeWire read is reported as a failure"
fi
[[ ! -s $tmp/notifications && $(cat "$tmp/quantum") == 256 ]] ||
  fail "a failed PipeWire read neither notifies nor changes the setting" "$(cat "$tmp/notifications")"
! PIPEWIRE_DOWN=1 toggle --status || fail "status is not on when PipeWire can't be read"
echo 0 >"$tmp/quantum"
pass "a failed PipeWire read or write fails without a notification"

echo 128 >"$tmp/quantum"
! toggle --status || fail "another forced quantum is not reported as low-latency audio"
if toggle 2>/dev/null || toggle off 2>/dev/null; then
  fail "toggle and off refuse to replace another forced quantum"
fi
[[ $(cat "$tmp/quantum") == 128 ]] || fail "another forced quantum is left alone" "$(cat "$tmp/quantum")"
toggle on
[[ $(cat "$tmp/quantum") == 256 ]] || fail "on still sets low-latency audio explicitly"
pass "a buffer forced to another size is left alone unless on is asked for"

if toggle sideways 2>/dev/null; then
  fail "an unknown argument is rejected"
fi
pass "an unknown argument is rejected"

grep -qF '"checked":"omarchy-toggle-low-latency-audio --status","action":"omarchy-toggle-low-latency-audio"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "the toggle menu offers low-latency audio with its state checked"
pass "the toggle menu offers low-latency audio with its state checked"
