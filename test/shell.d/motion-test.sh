#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Every shell animation runs for Style.duration(ms), which is 0 once
# `omarchy toggle animations` has turned Hyprland's animations off, so a bare
# number keeps moving on the machines that asked for stillness
# (agents/skills/motion.md). A `duration:` opening a line or following `{` or
# `;` is an animation's; the OSD's `property int duration` and JS objects such
# as `{ icon: …, duration: 0 }` are not.
bare=$(grep -rnE --include='*.qml' '(^|[{;])\s*duration:\s*[0-9]' "$ROOT/shell" || true)
[[ -z $bare ]] ||
  fail "every shell animation duration goes through Style.duration()" "$bare"
pass "every shell animation duration goes through Style.duration()"
