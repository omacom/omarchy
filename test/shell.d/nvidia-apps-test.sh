#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
calls="$scratch/calls"

run_setup() (
  installed=$1
  failure=${2:-}
  export OMARCHY_IMAGE_DEFERRED_HARDWARE=${3:-}
  export OMARCHY_INSTALL="$ROOT/install"
  omarchy-pkg-present() { [[ " $installed " == *" $1 "* ]]; }
  nvidia-ctk() {
    echo "nvidia-ctk $*" >> "$calls"
    [[ $failure != "nvidia-ctk" ]]
  }
  systemctl() {
    echo "systemctl $*" >> "$calls"
    [[ $failure != "$1" ]]
  }
  # Exercise installer wiring without running unrelated hardware setup.
  run_logged() {
    if [[ $1 == "$OMARCHY_INSTALL/hardware/nvidia-apps.sh" ]]; then
      source "$1"
    fi
  }
  source "$OMARCHY_INSTALL/hardware/all.sh"
)

for deferred in "" 0 1; do
  for mask in {0..7}; do
    packages=()
    expected=()
    if (( mask & 1 )); then
      packages+=(nvidia-ai-workbench)
      expected+=('nvidia-ctk runtime configure --runtime=docker')
    fi
    if (( mask & 2 )); then
      packages+=(dgx-dashboard)
      expected+=('systemctl enable dgx-dashboard.service')
      if [[ $deferred == "1" ]]; then
        expected+=('systemctl start --no-block dgx-dashboard.service')
      fi
    fi
    if (( mask & 4 )); then
      packages+=(ollama)
    fi
    : > "$calls"
    run_setup "${packages[*]}" "" "$deferred"
    actual=$(cat "$calls")
    wanted=$(printf '%s\n' "${expected[@]}")
    [[ $actual == "$wanted" ]] || fail "installed applications receive only their own setup" "$actual"
  done
done
pass "all package combinations start Dashboard only during deferred first-boot setup"
pass "hardware setup leaves optional Ollama service management alone"

export ROOT calls
export -f run_setup
for deferred in "" 1; do
  for failure in nvidia-ctk enable; do
    : > "$calls"
    # A separate shell preserves errexit while the caller checks the result.
    if bash -euo pipefail -c 'run_setup "nvidia-ai-workbench dgx-dashboard ollama" "$1" "$2"' bash "$failure" "$deferred"; then
      fail "failed $failure setup is propagated"
    fi
  done
done
pass "runtime configuration and service-enable failures stop setup"

: > "$calls"
bash -euo pipefail -c 'run_setup "dgx-dashboard" start 1'
[[ $(<"$calls") == $'systemctl enable dgx-dashboard.service\nsystemctl start --no-block dgx-dashboard.service' ]] ||
  fail "a refused Dashboard start is attempted without failing deferred setup" "$(<"$calls")"
pass "a refused Dashboard start does not fail deferred setup"
