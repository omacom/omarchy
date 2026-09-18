#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export OMARCHY_PATH="$ROOT"
source "$ROOT/install/helpers/pacman.sh"
omarchy-hw-apple-silicon() { [[ ${apple:-0} == 1 ]]; }
for apple in 0 1; do
  for channel in stable rc edge; do
    omarchy_pacman_stage "$channel" "$work"
    if [[ $apple == 1 ]]; then
      for repo in asahi-alarm core extra alarm aur omarchy; do
        grep -Fxq "[$repo]" "$work/pacman.conf" || fail "ARM staging preserves $repo"
      done
      ! grep -Fq '[multilib]' "$work/pacman.conf" || fail 'no x86 repository on ARM'
      grep -Fq '/$arch/$repo' "$work/mirrorlist" || fail 'ALARM mirror layout'
      ! omarchy_pacman_channel_qualified "$channel" || fail 'unqualified ARM channel refused'
    else
      grep -Fq '[multilib]' "$work/pacman.conf" || fail 'x86 retains multilib'
      omarchy_pacman_channel_qualified "$channel" || fail 'x86 channels remain available'
    fi
    grep -Fq "https://pkgs.omarchy.org/$channel/" "$work/pacman.conf" || fail 'selected channel URL'
  done
done
! omarchy_pacman_stage nonsense "$work" || fail 'invalid channel refused'
pass 'staging preserves architecture repositories for every channel'

# Exercise the source-controlled enablement seam with a test-only copy.
sed 's/qualified_arm_channels=()/qualified_arm_channels=(stable rc edge)/' "$ROOT/install/helpers/pacman.sh" >"$work/qualified.sh"
source "$work/qualified.sh"
apple=1
for channel in stable rc edge; do omarchy_pacman_channel_qualified "$channel" || fail 'qualified ARM channel selectable'; done

# Preflight failures occur in an isolated database; no live package command.
sudo() { "$@"; }
pacman() { printf '%s\n' "$*" >>"$work/calls"; return "${pacman_status:-0}"; }
omarchy_pacman_stage edge "$work"
omarchy_pacman_preflight "$work" edge
for target in omarchy-dev omarchy-settings-dev omarchy-settings-asahi linux-asahi asahi-alarm-keyring; do
  grep -Fq "$target" "$work/calls" || fail "ARM preflight checks $target"
done
grep -Fq -- "--dbpath $work/db" "$work/calls" || fail 'preflight database isolated'
! grep -Fq '/etc/pacman.d/mirrorlist' "$work/check.conf" || fail 'preflight mirrorlist isolated'
pacman_status=42
status=0
omarchy_pacman_preflight "$work" edge || status=$?
[[ $status == 1 ]] || fail 'preflight failure blocks staging into live configuration'
pass 'qualified path preflights required packages and propagates failures'

# Shipped ARM finalization preserves the ISO-managed configuration without I/O.
source "$ROOT/install/helpers/pacman.sh"
cp() { fail 'offline unqualified ARM finalization must preserve existing files'; }
omarchy_pacman_finalize stable
pass 'offline finalization performs no sync or live configuration replacement'
