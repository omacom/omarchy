#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

drop_in="$ROOT/default/systemd/system/speakersafetyd.service.d/10-omarchy.conf"
grep -Fx 'StartLimitIntervalSec=0' "$drop_in" >/dev/null ||
  fail "speakersafetyd drop-in still lets systemd give up after a 96 kHz panic burst"
grep -Fx 'RestartSec=5' "$drop_in" >/dev/null ||
  fail "speakersafetyd drop-in does not slow the crash loop"
pass "speakersafetyd drop-in keeps retrying after start-limit would have fired"

service="$ROOT/default/systemd/user/omarchy-speakersafetyd-watch.service"
grep -Fx 'ConditionPathExists=/usr/bin/speakersafetyd' "$service" >/dev/null ||
  fail "speakersafetyd watcher runs on machines that never install the daemon"
grep -Fx 'ConditionEnvironment=WAYLAND_DISPLAY' "$service" >/dev/null ||
  fail "speakersafetyd watcher can start over SSH with no notification server"
grep -Fx 'ExecStart=/usr/bin/omarchy-audio-speakersafetyd-watch' "$service" >/dev/null ||
  fail "speakersafetyd watcher does not use the packaged watch command"
pass "speakersafetyd watcher stays inert without the daemon and a display"

first_run_units="$ROOT/install/user/first-run/enable-user-units.sh"
grep -F 'omarchy-speakersafetyd-watch.service' "$first_run_units" >/dev/null ||
  fail "new installs never enable the speakersafetyd watcher"
pass "first-run enables the speakersafetyd watcher"

grep -F 'fix-speakersafetyd-restarts.sh' "$ROOT/install/hardware/all.sh" >/dev/null ||
  fail "new installs never copy the speakersafetyd restart drop-in"
pass "hardware setup installs the speakersafetyd restart drop-in"

watch="$ROOT/bin/omarchy-audio-speakersafetyd-watch"
# shellcheck disable=SC1090
source "$watch"

alsa_cards() {
  echo "AppleJ313"
}

amixer() {
  printf '%s\n' ': values=0'
}

speaker_volume_locked || fail "watcher misses a locked Speaker Volume Unlock control"
pass "watcher treats Speaker Volume Unlock=0 as locked"

amixer() {
  printf '%s\n' ': values=1'
}

speaker_volume_locked && fail "watcher treats an unlocked control as locked"
pass "watcher treats Speaker Volume Unlock=1 as unlocked"

migration="$ROOT/migrations/1790123774.sh"
grep -F 'speakersafetyd.service.d/10-omarchy.conf' "$migration" >/dev/null ||
  fail "existing installs never receive the speakersafetyd restart drop-in"
grep -F 'omarchy-speakersafetyd-watch.service' "$migration" >/dev/null ||
  fail "existing installs never enable the speakersafetyd watcher"
pass "migration repairs existing installs"
