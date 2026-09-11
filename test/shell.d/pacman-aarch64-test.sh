#!/bin/bash

# Each invocation has an isolated environment.
# shellcheck disable=SC2030,SC2031,SC2329

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/source/default" "$scratch/source/install/helpers" "$scratch/install/hardware"
cp -r "$ROOT/default/pacman" "$scratch/source/default/"
cp "$ROOT/install/helpers/pacman.sh" "$scratch/source/install/helpers/"
printf ':\n' >"$scratch/install/hardware/pacman.sh"

run_setup() (
  architecture=$1
  export OMARCHY_MIRROR=$2
  export OMARCHY_PATH="$scratch/source" OMARCHY_INSTALL="$scratch/install"
  export OMARCHY_PACMAN_CONFIG="$scratch/pacman.conf" OMARCHY_MIRRORLIST="$scratch/mirrorlist"
  uname() { printf '%s\n' "$architecture"; }
  omarchy-pkg-add() { printf 'add %s\n' "$*" >>"$scratch/keys"; }
  pacman-key() { printf 'key %s\n' "$*" >>"$scratch/keys"; }
  source "$ROOT/install/post-install/pacman.sh"
)

run_setup aarch64 edge
grep -Fxq "Server = https://pkgs.omarchy.org/edge/\$arch" "$scratch/pacman.conf" ||
  fail "ARM edge installations retain the published Omarchy repository"
grep -Fxq '[alarm]' "$scratch/pacman.conf" || fail "ARM installations retain ALARM repositories"
if grep -Fxq '[multilib]' "$scratch/pacman.conf"; then
  fail "ARM installations do not inherit x86 multilib"
fi
grep -Fxq 'add archlinuxarm-keyring' "$scratch/keys" || fail "ALARM keyring is installed"
grep -Fxq 'key --populate' "$scratch/keys" || fail "installed keyrings are trusted"

for mirror in stable rc; do
  run_setup aarch64 "$mirror"
  if grep -Fxq '[omarchy]' "$scratch/pacman.conf"; then
    fail "ARM $mirror does not select an unpublished repository or switch to edge"
  fi
done

run_setup x86_64 stable
cmp "$ROOT/default/pacman/pacman-stable.conf" "$scratch/pacman.conf" ||
  fail "x86 repository configuration remains unchanged"

pass "ARM edge retains Omarchy packages without switching other channels"
