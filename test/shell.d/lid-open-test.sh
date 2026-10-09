#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

lid_open="$ROOT/bin/omarchy-system-lid-open"

grep -F "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'" "$lid_open" >/dev/null
grep -F 'omarchy-system-wake' "$lid_open" >/dev/null
pass "lid open forces DPMS on after a missed switch event"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
runtime="$tmpdir/run"
mkdir -p "$runtime"
call_log="$tmpdir/calls"
: >"$call_log"
mock_bin="$tmpdir/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-hw-laptop-closed" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-hw-external-monitors" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$mock_bin/omarchy-system-wake" <<SH
#!/bin/bash
echo omarchy-system-wake >>"$call_log"
SH
cat >"$mock_bin/hyprctl" <<SH
#!/bin/bash
echo hyprctl "\$*" >>"$call_log"
SH
cat >"$mock_bin/omarchy-hw-display" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

XDG_RUNTIME_DIR="$runtime" PATH="$mock_bin:$PATH" "$lid_open"
mapfile -t calls <"$call_log"
[[ ${calls[0]} == "omarchy-system-wake" ]] ||
  fail "open lid wakes displays" "calls: ${calls[*]}"
[[ ${calls[1]} == *"dpms"* ]] ||
  fail "open lid forces DPMS enable" "calls: ${calls[*]}"
pass "open lid wakes displays and forces DPMS enable"
