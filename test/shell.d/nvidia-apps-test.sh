#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
calls="$scratch/calls"

run_setup() (
  installed=$1
  failure=${2:-}
  export OMARCHY_INSTALL="$ROOT/install"
  omarchy-pkg-present() { [[ " $installed " == *" $1 "* ]]; }
  nvidia-ctk() {
    echo "nvidia-ctk $*" >> "$calls"
    [[ $failure != "nvidia-ctk" ]]
  }
  systemctl() {
    echo "systemctl $*" >> "$calls"
    [[ $failure != "$2" ]]
  }
  # Exercise installer wiring without running unrelated hardware setup.
  run_logged() {
    if [[ $1 == "$OMARCHY_INSTALL/hardware/nvidia-apps.sh" ]]; then
      source "$1"
    fi
  }
  source "$OMARCHY_INSTALL/hardware/all.sh"
)

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
  fi
  if (( mask & 4 )); then
    packages+=(ollama)
  fi
  : > "$calls"
  run_setup "${packages[*]}"
  actual=$(cat "$calls")
  wanted=$(printf '%s\n' "${expected[@]}")
  [[ $actual == "$wanted" ]] || fail "installed applications receive only their own setup" "$actual"
done
pass "all package combinations run through installer wiring without starting services"
pass "hardware setup leaves optional Ollama service management alone"

export ROOT calls
export -f run_setup
for failure in nvidia-ctk dgx-dashboard.service; do
  : > "$calls"
  # A separate shell preserves errexit while the caller checks the result.
  if bash -euo pipefail -c 'run_setup "nvidia-ai-workbench dgx-dashboard ollama" "$1"' bash "$failure"; then
    fail "failed $failure setup is propagated"
  fi
done
pass "runtime configuration and service-enable failures stop setup"
