#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

# UVC webcams boot with auto-exposure priority on and quietly drop to 10-15 fps
# in ordinary room light. The package-owned rule turns it off on every uvcvideo
# capture node at boot and hot-plug, the way Chromium does each time it opens
# a camera, so mpv, OBS and Firefox see the same steady frame rate.
rule="$ROOT/etc/udev/rules.d/65-omarchy-webcam-framerate.rules"
[[ -f $rule ]] || fail "the webcam frame rate udev rule ships package-owned under etc/udev/rules.d"
pass "the webcam frame rate udev rule ships package-owned under etc/udev/rules.d"

# ID_USB_DRIVER and ID_V4L_CAPABILITIES are set by 60-persistent-v4l.rules, so
# the rule has to sort after it or its match keys are empty.
rule_number=$(basename "$rule" | cut -d- -f1)
((rule_number > 60)) || fail "the rule sorts after 60-persistent-v4l, which sets the properties it matches on" "$rule"
pass "the rule sorts after 60-persistent-v4l, which sets the properties it matches on"

# `udevadm verify` arrived in systemd 254.
if udevadm verify --help >/dev/null 2>&1; then
  udevadm verify "$rule" >/dev/null 2>&1 || fail "udevadm verify accepts the rule" "$(udevadm verify "$rule" 2>&1)"
  pass "udevadm verify accepts the rule"
else
  skip "udevadm verify accepts the rule (udevadm verify is unavailable on this host)"
fi

rule_body=$(grep -v '^#' "$rule" | grep -v '^[[:space:]]*$' || true)
[[ -n $rule_body ]] || fail "the rule file has an uncommented rule line" "$(cat "$rule")"
pass "the rule file has an uncommented rule line"

# udev drops a commented line without honouring its trailing backslash, so a
# rule split over two lines can be half commented out, leaving a RUN with no
# match keys that fires on every uevent. Keep the match and the RUN together.
[[ $(wc -l <<<"$rule_body") -eq 1 ]] || fail "the match keys and the RUN share one line" "$rule_body"
pass "the match keys and the RUN share one line"

# Boot coldplug and hot-plug are add events; a plain `udevadm trigger` sends
# change, and the rule should apply then too.
grep -qE 'ACTION=="add\|change"' <<<"$rule_body" || fail "the rule runs on add and change" "$rule_body"
pass "the rule runs on add and change"

grep -qE 'SUBSYSTEM=="video4linux"' <<<"$rule_body" && grep -qE 'ENV\{ID_USB_DRIVER\}=="uvcvideo"' <<<"$rule_body" ||
  fail "the rule is limited to uvcvideo video4linux nodes" "$rule_body"
pass "the rule is limited to uvcvideo video4linux nodes"

# The metadata node beside every UVC capture node has no controls and reports
# ":" for its capabilities; matching it would only log an error per camera at
# every boot. v4l_id can list more than one token (":capture:video_overlay:"),
# so the match is a glob on the capture token rather than the exact string.
grep -qE 'ENV\{ID_V4L_CAPABILITIES\}=="\*:capture:\*"' <<<"$rule_body" ||
  fail "the rule matches any node whose capabilities include capture, and no other" "$rule_body"
pass "the rule matches any node whose capabilities include capture, and no other"

# The RUN is checked for what it must do, not for its exact spelling: udev
# gives RUN programs no PATH, the node has to come from udev, the control is
# named so a reader can find it, and a camera without the control makes
# v4l2-ctl exit 1, which udev would log as a failed RUN at every boot.
run=$(grep -oE 'RUN\+="[^"]*"' <<<"$rule_body" || true)
[[ -n $run ]] || fail "the rule has a RUN key" "$rule_body"
pass "the rule has a RUN key"
grep -qF '/usr/bin/v4l2-ctl' <<<"$run" || fail "the RUN calls v4l2-ctl by absolute path" "$run"
pass "the RUN calls v4l2-ctl by absolute path"
grep -qF -- '-d $devnode' <<<"$run" || fail "the RUN targets the node udev matched" "$run"
pass "the RUN targets the node udev matched"
grep -qF -- '--set-ctrl exposure_dynamic_framerate=0' <<<"$run" || fail "the RUN sets exposure_dynamic_framerate to 0, by name" "$run"
pass "the RUN sets exposure_dynamic_framerate to 0, by name"
grep -qE "\|\| :'\"$" <<<"$run" || fail "a camera without the control leaves no failed-RUN line in the journal" "$run"
pass "a camera without the control leaves no failed-RUN line in the journal"
! grep -qE 'RUN\+="[^/]' <<<"$rule_body" || fail "every RUN program is given by absolute path" "$rule_body"
pass "every RUN program is given by absolute path"
