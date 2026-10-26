#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_compositor "background intro poll test"
require_command quickshell

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/services" "$stage/bin" "$stage/home"
cp "$ROOT/shell/services/BackgroundIntro.qml" "$stage/services/"
ln -s "$ROOT/shell/Commons" "$stage/Commons"
cp "$SHELL_TEST_DIR/fixtures/background-intro-poll/shell.qml" "$stage/shell.qml"
cat >"$stage/bin/omarchy-theme-bg-boot-intro" <<'SH'
#!/bin/bash
sleep 1
SH
chmod +x "$stage/bin/omarchy-theme-bg-boot-intro"
cat >"$stage/bin/owe" <<'SH'
#!/bin/bash
if [[ -f $INTRO_TEST_MARK ]]; then
  printf 'released\n' >>"$INTRO_TEST_LOG"
else
  printf 'covered\n' >>"$INTRO_TEST_LOG"
fi
printf '{"kind":"still","ready":true,"has_transition":false,"time_pos":-1}\n'
SH
chmod +x "$stage/bin/owe"
touch "$stage/polls"
output=$(HOME="$stage/home" PATH="$stage/bin:$PATH" INTRO_TEST_LOG="$stage/polls" INTRO_TEST_MARK="$stage/mark" timeout 10 quickshell -p "$stage" --no-color 2>&1) || fail "background intro poll fixture exits cleanly" "$output"
[[ $output == *"RESULT pass"* ]] || fail "background intro poll assertions pass" "$output"
if rg -q 'RESULT fail|ReferenceError|TypeError|Error:|Unable to assign|Binding loop' <<<"$output"; then
  fail "background intro poll fixture has no QML errors" "$output"
fi
[[ -f $stage/mark ]] || fail "the fixture marks the cover release"
covered=$(grep -c '^covered$' "$stage/polls" || true)
released=$(grep -c '^released$' "$stage/polls" || true)
(( covered >= 10 )) || fail "the frame poll runs while the intro covers the background ($covered owe render-status runs)"
(( released <= 1 )) || fail "the frame poll stops once nothing waits for the intro ($released owe render-status runs in the second after the cover was released)"
pass "the frame poll stops once the cover is released"
