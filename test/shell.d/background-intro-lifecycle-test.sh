#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "background intro lifecycle test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/services" "$stage/bin" "$stage/home"
printf 'P6\n1 1\n255\n\377\377\377' >"$stage/cover.ppm"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$stage/services/"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/background-intro-lifecycle/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
printf 'intro\n' >>"$INTRO_TEST_LOG"
sleep 2
SH
chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"
cat >"$stage/bin/owe" <<'SH'
#!/bin/bash
if [[ -n ${INTRO_TEST_POLLS:-} ]]; then
  if [[ -f $INTRO_TEST_MARK ]]; then
    printf 'released\n' >>"$INTRO_TEST_POLLS"
  else
    printf 'covered\n' >>"$INTRO_TEST_POLLS"
  fi
  printf '{"kind":"still","ready":true,"has_transition":false,"time_pos":-1}\n'
elif [[ -f $INTRO_TEST_FRAME_READY ]]; then
  sleep 0.25
  printf '{"kind":"video","ready":true,"has_transition":false,"time_pos":0.05}\n'
else
  printf '{"kind":"video","ready":true,"has_transition":true,"time_pos":0}\n'
fi
SH
chmod +x "$stage/bin/owe"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" INTRO_TEST_LOG="$stage/starts" INTRO_TEST_COVER="$stage/cover.ppm" INTRO_TEST_FRAME_READY="$stage/video-ready" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "background intro fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "background intro lifecycle assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "background intro fixture has no QML errors" "$output"
fi
[[ $(wc -l <"$stage/starts") == 1 ]] || fail "recreating the background service does not run another launcher"

# A login whose intro ends on a still never reports a video frame, so the
# frame poll has to stop once the cover is released.
cp "$SHELL_TEST_DIR/fixtures/background-intro-lifecycle/still-handoff.qml" "$stage/shell.qml"
touch "$stage/polls"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" INTRO_TEST_LOG="$stage/starts" INTRO_TEST_POLLS="$stage/polls" INTRO_TEST_MARK="$stage/mark" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "still intro fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "still intro assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "still intro fixture has no QML errors" "$output"
fi
[[ -f $stage/mark ]] || fail "the still intro fixture marks the cover release"
covered=$(grep -c '^covered$' "$stage/polls" || true)
released=$(grep -c '^released$' "$stage/polls" || true)
(( covered >= 10 )) || fail "the frame poll runs while the intro covers the background ($covered owe render-status runs)"
(( released <= 1 )) || fail "the frame poll stops once nothing waits for the intro ($released owe render-status runs in the second after the cover was released)"
pass "the cover stays while waiting, remains off when OWE recreates the background service, and stops polling after a still intro"
