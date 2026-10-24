#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
export OMARCHY_PATH="$ROOT"
export OMARCHY_NVIDIA_MODESET_NODE="$scratch/nvidia-modeset"
source_rule="$ROOT/default/udev/nvidia-modeset.rules"
installed_rule=/etc/udev/rules.d/61-nvidia-modeset.rules
migration="$ROOT/migrations/1792737693.sh"
replay=(
  "udevadm control --reload"
  "udevadm trigger --action=bind --subsystem-match=pci --attr-match=vendor=0x10de --attr-match=class=0x03*"
  "udevadm settle"
)

if udevadm verify --help &>/dev/null; then
  udevadm verify --resolve-names=never "$source_rule" >/dev/null || fail "modeset rule parses"
  pass "modeset rule parses with udevadm verify"
else
  skip "modeset rule parses with udevadm verify"
fi

# Exercise the migration, redirecting privileged writes to a temporary root.
omarchy-hw-nvidia() { [[ $gpu != "none" ]]; }
omarchy-hw-aarch64-n1x() { [[ $gpu == "n1x" ]]; }
omarchy-cmd-present() { [[ $1 == "nvidia-modprobe" && $gpu != "no-driver" ]]; }
sudo() {
  case "$1" in
    install) command install "$2" "$3" "$scratch$4" ;;
    udevadm) printf '%s\n' "$*" >>"$scratch/udev" ;;
    *) fail "unexpected privileged command" "$*" ;;
  esac
}
cmp() { command cmp -s "$2" "$scratch$3"; }

assert_replayed() {
  [[ $(cat "$scratch/udev") == "$(printf '%s\n' "${replay[@]}")" ]] || fail "$1" "$(cat "$scratch/udev")"
}

bash -n "$migration"
for gpu in nvidia n1x no-driver none; do
  rm -rf "$scratch/etc" "$scratch/udev"
  source "$migration" >/dev/null
  if [[ $gpu == "nvidia" ]]; then
    command cmp "$source_rule" "$scratch$installed_rule" || fail "migration installs the rule"
    [[ $(stat -c %a "$scratch$installed_rule") == "644" ]] || fail "rule is not writable by other users"
    assert_replayed "migration replays only NVIDIA display controllers' bind"

    # A run that installed the rule but failed before udev saw it must still replay it when retried.
    rm "$scratch/udev"
    touch -d @0 "$scratch$installed_rule"
    source "$migration" >/dev/null
    [[ $(stat -c %Y "$scratch$installed_rule") == "0" ]] || fail "retry leaves an identical rule in place"
    assert_replayed "retry replays the bind for an already installed rule"

    # Once the node exists, another user's run changes nothing.
    rm "$scratch/udev"
    touch "$OMARCHY_NVIDIA_MODESET_NODE"
    source "$migration" >/dev/null
    [[ ! -e $scratch/udev ]] || fail "migration replays the bind when the node already exists" "$(cat "$scratch/udev")"
    rm "$OMARCHY_NVIDIA_MODESET_NODE"
  else
    [[ ! -e $scratch/etc && ! -e $scratch/udev ]] || fail "migration leaves $gpu machines untouched"
  fi
done
pass "migration installs the rule only on NVIDIA machines with the driver, replays the bind until the node exists"
