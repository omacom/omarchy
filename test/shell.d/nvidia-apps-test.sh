#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
calls="$scratch/calls"

run_setup() (
  failure=$1
  export OMARCHY_IMAGE_DEFERRED_HARDWARE=$2
  omarchy-pkg-present() { [[ -z ${NONE_INSTALLED:-} ]]; }
  nvidia-ctk() { echo "nvidia-ctk $*" >> "$calls"; }
  systemctl() {
    echo "systemctl $*" >> "$calls"
    [[ $failure != "$1" ]]
  }
  source "$ROOT/install/hardware/nvidia-apps.sh"
)

: > "$calls"
NONE_INSTALLED=1 run_setup "" ""
[[ ! -s $calls ]] || fail "a machine without the optional applications configures nothing" "$(<"$calls")"
pass "a machine without the optional applications configures nothing"

: > "$calls"
run_setup "" ""
[[ $(<"$calls") == $'nvidia-ctk runtime configure --runtime=docker\nsystemctl enable dgx-dashboard.service' ]] ||
  fail "installed applications are configured without starting Dashboard outside first boot" "$(<"$calls")"
pass "Dashboard is only enabled outside deferred first-boot setup"

: > "$calls"
# Outside a conditional, and with errexit set again inside, so a failing step
# stops the setup even when it is not the last one.
set +e
(set -e; run_setup start 1)
status=$?
set -e
(( status == 0 )) || fail "a refused Dashboard start does not fail deferred setup"
[[ $(<"$calls") == $'nvidia-ctk runtime configure --runtime=docker\nsystemctl enable dgx-dashboard.service\nsystemctl start --no-block dgx-dashboard.service' ]] ||
  fail "deferred setup starts Dashboard" "$(<"$calls")"
pass "a refused Dashboard start does not fail deferred setup"
