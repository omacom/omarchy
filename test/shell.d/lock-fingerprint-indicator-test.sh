#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "lock fingerprint indicator test"

run_qml_fixture lock-fingerprint-indicator "fingerprint indicator tracks the configured sensor and password dots fit beside it" Ui Commons
# Stands in for hyprctl: the first read is slow and finds Caps Lock off, so a
# refresh asked for meanwhile has to run a second read to see it on.
qml_fixture_scratch
cat >"$QML_FIXTURE_TMP/bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 != "devices" ]]; then
  printf '{}'
  exit 0
fi
reads=$(( $(cat "$HOME/hyprctl-device-reads" 2>/dev/null || echo 0) + 1 ))
echo "$reads" >"$HOME/hyprctl-device-reads"
if (( reads == 1 )); then
  sleep 0.3
  printf '{"keyboards":[{"name":"keychron-k2","main":true,"capsLock":false}]}'
else
  printf '{"keyboards":[{"name":"keychron-k2","main":true,"capsLock":true}]}'
fi
SH
chmod +x "$QML_FIXTURE_TMP/bin/hyprctl"

run_qml_fixture lock-caps-lock "caps lock icon tracks every typed keyboard and a refresh queued during a read still runs" Ui Commons
