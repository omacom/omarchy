#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Hardware setup runs during ISO finalization, before post-install/pacman.sh
# restores the online mirrors, so every package it installs has to be in the
# ISO's offline mirror. The ISO builder fills that mirror from these two lists.
mapfile -t mirrored < <(sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' \
  "$ROOT/install/omarchy-base.packages" "$ROOT/install/omarchy-other.packages")

# Collect the literal package names hardware setup can install: omarchy-pkg-add
# arguments (joining backslash continuations), PACKAGES=(...) arrays, and
# [Vendor]=package driver maps. Expansions like "${PACKAGES[@]}" are skipped,
# since the arrays they expand are collected on their own.
installed=()
while IFS= read -r line; do
  [[ $line =~ ^[[:space:]]*# ]] && continue

  if [[ $line =~ omarchy-pkg-add[[:space:]]+([^\;\&\|]*) ]]; then
    arguments=${BASH_REMATCH[1]}
    unresolved=${arguments//'${PACKAGES[@]}'/}
    if [[ $unresolved == *'$'* ]]; then
      fail "hardware setup package arguments can be resolved" \
        "cannot resolve package argument: ${unresolved//\"/}"
    fi
    read -ra words <<<"$arguments"
  elif [[ $line =~ PACKAGES\+?=\(([^\)]*)\) ]]; then
    read -ra words <<<"${BASH_REMATCH[1]}"
  elif [[ $line =~ ^[[:space:]]*\[[[:alnum:]]+\]=([^[:space:]]+) ]]; then
    words=("${BASH_REMATCH[1]}")
  else
    continue
  fi

  for word in "${words[@]}"; do
    [[ $word =~ ^[a-z0-9][a-z0-9@._+-]*$ ]] && installed+=("$word")
  done
done < <(find "$ROOT/install/hardware" -name '*.sh' -exec sed -e ':join' -e '/\\$/{N;s/\\\n//;b join' -e '}' {} +)

(( ${#installed[@]} > 0 )) || fail "hardware setup package names are found"

for package in "${installed[@]}"; do
  printf '%s\n' "${mirrored[@]}" | grep -qxF "$package" ||
    fail "every hardware setup package is in the ISO's offline mirror" \
      "$package is installed by install/hardware but not listed in omarchy-base.packages or omarchy-other.packages"
done
pass "every hardware setup package is in the ISO's offline mirror"
