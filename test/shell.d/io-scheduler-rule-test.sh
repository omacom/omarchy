#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# Since Linux 7.2 a scheduler write fails with EBUSY while another disk on the
# same tag set (a sibling NVMe namespace, another LUN of a card reader) is
# switching, and udev never retries an ATTR write. The rule writes from RUN
# so it can retry.
rule=$ROOT/etc/udev/rules.d/60-omarchy-io-scheduler.rules
write=$(sed -n "s|.*RUN+=\"/usr/bin/sh -c '\(.*\)'\"\$|\1|p" "$rule")
[[ -n $write ]] || fail "the kyber write runs from RUN, so a busy queue is not the last attempt"

# udev expands \$devpath under /sys; /sys/.. reaches the scratch disk. A
# directory in place of the attribute refuses the write, as a busy queue does,
# until the sibling's switch is done.
disk=$test_tmp/disk
mkdir -p "$disk/queue/scheduler"
(sleep 0.5; rmdir "$disk/queue/scheduler"; : >"$disk/queue/scheduler") &
sh -c "${write//\$devpath//..$disk}" 2>/dev/null || fail "the kyber write succeeds once the sibling disk has switched"
wait
[[ $(<"$disk/queue/scheduler") == kyber ]] || fail "the retried write sets kyber"
pass "the kyber write retries while a sibling disk switches scheduler"
