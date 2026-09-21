#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
(
  calls=$(mktemp)
  trap 'rm -f "$calls"' EXIT
  omarchy-pkg-present() { [[ " $installed " == *" $1 "* ]]; }
  nvidia-ctk() { echo "nvidia-ctk $*" >> "$calls"; }
  systemctl() { echo "systemctl $*" >> "$calls"; }
  installed=""
  source "$ROOT/install/hardware/nvidia-apps.sh"
  [[ ! -s $calls ]]
  installed="dgx-dashboard"
  source "$ROOT/install/hardware/nvidia-apps.sh"
  [[ $(cat "$calls") == 'systemctl enable dgx-dashboard.service' ]]
  : > "$calls"
  installed="nvidia-ai-workbench"
  source "$ROOT/install/hardware/nvidia-apps.sh"
  [[ $(cat "$calls") == 'nvidia-ctk runtime configure --runtime=docker' ]]
  echo 'ok - optional apps configure only their installed services, without starting them'
)
