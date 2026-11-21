#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "launch OSD order test"

# A slow `osd show` must not let the following `osd close` overtake it: the
# launch OSD has no duration, so a close that lands first leaves it open.
qml_fixture_scratch
osd_log="$QML_FIXTURE_TMP/osd.log"
cat >"$QML_FIXTURE_TMP/bin/omarchy-shell" <<'SH'
#!/bin/bash
[[ $2 == "show" ]] && sleep 0.5
echo "$2" >>"$OSD_LOG"
SH
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-shell"

OSD_LOG="$osd_log" run_qml_fixture launch-osd-order "launch OSD fixture runs" services Commons

[[ $(cat "$osd_log" 2>/dev/null | tr '\n' ' ') == "show close " ]] ||
  fail "launch OSD close waits for show" "omarchy-shell calls: $(cat "$osd_log" 2>/dev/null | tr '\n' ' ')"
pass "launch OSD close waits for show"
