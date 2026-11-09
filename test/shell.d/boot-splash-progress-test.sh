#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_node_test <<'JS'
const fs = require('fs')
const splash = requireFromRoot('shell/services/BootSplash.js')
const script = fs.readFileSync(path.join(root, 'default/plymouth/omarchy.script'), 'utf8')
const constant = name => Number(script.match(new RegExp(`global\\.${name} = ([\\d.]+);`))[1])

assertEqual(splash.progressLimit, constant('fake_progress_limit'), 'the cover eases to the limit the Plymouth theme fakes')
assertEqual(splash.progressDuration, constant('fake_progress_duration'), 'the cover eases over the duration the Plymouth theme fakes')
assertEqual(splash.progressAt(0), 0, 'the bar starts empty at the password')
assertEqual(splash.progressAt(7.5).toFixed(4), (0.7 * 0.75).toFixed(4), 'the bar eases out like Plymouth: 0.7 * (1 - (1 - t/15)^2)')
assertEqual(splash.progressAt(60), 0.7, 'the bar holds at the limit after its duration')

// Plymouth's own threshold: 1.625 times 135 dpi below 20", 110 dpi above.
assertEqual(splash.deviceScale(1280, 800, 320, 200), 1, 'a 100 dpi panel draws the splash at scale 1')
assertEqual(splash.deviceScale(2256, 1504, 285, 190), 1, 'a 201 dpi 13.5" panel is below Plymouth\'s threshold')
assertEqual(splash.deviceScale(2880, 1920, 285, 190), 2, 'a 257 dpi 13.5" panel draws the splash doubled')
assertEqual(splash.deviceScale(3840, 2160, 597, 336), 1, 'a 27" 4K monitor is below the desktop threshold')
assertEqual(splash.deviceScale(3840, 2160, 160, 90), 1, 'a size that is really an aspect ratio counts as unknown')
assertEqual(splash.deviceScale(3840, 2160, 0, 0), 1, 'an unknown size draws the splash at scale 1')
assertEqual(splash.pixelUnit({ width: 2880, height: 1920, physicalWidth: 285, physicalHeight: 190, scale: 2 }), 1, 'a doubled splash on a doubled monitor is one logical pixel per image pixel')
assertEqual(splash.pixelUnit({ width: 2256, height: 1504, physicalWidth: 285, physicalHeight: 190, scale: 1.25 }), 0.8, 'an undoubled splash shrinks by the monitor scale')
assertEqual(splash.pixelUnit(null), 0, 'an unknown monitor places nothing')
JS

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/bin" "$stage/proc" "$stage/sys/power/suspend_stats"
cat >"$stage/bin/systemctl" <<'SH'
#!/bin/bash
echo 1500000
SH
chmod +x "$stage/bin/systemctl"
printf '4.250 3.100\n' >"$stage/proc/uptime"
printf '0\n' >"$stage/sys/power/suspend_stats/success"

progress() {
  printf '%s\n' "$1" >"$stage/proc/cmdline"
  PATH="$stage/bin:$PATH" OMARCHY_SYSTEM_ROOT="$stage" "$ROOT/bin/omarchy-boot-splash-progress"
}

output=$(progress 'root=PARTUUID=a rw quiet splash')
[[ -z $output ]] || fail "an unencrypted boot has no splash progress" "$output"
output=$(progress 'cryptdevice=PARTUUID=a:root cryptkey=rootfs:/key root=/dev/mapper/root quiet splash')
[[ -z $output ]] || fail "a disk opened by a key file asked no password and has no splash progress" "$output"
before=$(date +%s%3N)
output=$(progress 'cryptdevice=PARTUUID=a:root root=/dev/mapper/root quiet splash')
after=$(date +%s%3N)
# systemd started 2.75 s before now, and the password went in 2 s before that.
(( output >= before - 4751 && output <= after - 4749 )) || fail "the bar started a 2 s key derivation before systemd" "$output, $before..$after"
touch "$stage/crypto_keyfile.bin"
output=$(progress 'cryptdevice=PARTUUID=a:root root=/dev/mapper/root quiet splash')
[[ -z $output ]] || fail "a disk opened by the encrypt hook's own key file has no splash progress" "$output"
rm "$stage/crypto_keyfile.bin"
printf '1\n' >"$stage/sys/power/suspend_stats/success"
output=$(progress 'cryptdevice=PARTUUID=a:root root=/dev/mapper/root quiet splash')
[[ -z $output ]] || fail "a machine suspended since boot cannot place the splash progress" "$output"
pass "the splash progress follows the password the encrypt hook asked for"

# The handoff read Plymouth's own bar as the compositor took the display: that
# wins over the estimate.
mkdir -p "$stage/run"
# The bar started 3.2 s before this moment, on both clocks.
read -r start expected < <(python3 -c 'import time; print(round(time.clock_gettime(time.CLOCK_MONOTONIC) * 1000) - 3200, round(time.time() * 1000) - 3200)')
printf '%s\n' "$start" >"$stage/run/omarchy-boot-splash-bar"
output=$(progress 'root=PARTUUID=a rw quiet splash')
(( output >= expected - 5 && output <= expected + 5 )) || fail "the recorded start of Plymouth's bar becomes the epoch" "$output, expected $expected"
pass "the splash progress comes from Plymouth's own bar when the handoff read it"
