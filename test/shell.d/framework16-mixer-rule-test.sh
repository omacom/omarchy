#!/bin/bash

set -euo pipefail
ulimit -c 0
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v cc >/dev/null || ! command -v pkg-config >/dev/null ||
  ! pkg-config --exists wireplumber-0.5; then
  skip "native WirePlumber mixer rule checks require a C compiler and wireplumber-0.5 development files"
  exit 0
fi

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
read -ra compiler_flags <<< "$(pkg-config --cflags --libs wireplumber-0.5)"
cc -Wall -Wextra -Werror "$ROOT/test/shell.d/fixtures/framework16-speaker-volume/mixer-rule.c" \
  -o "$scratch/mixer-rule" "${compiler_flags[@]}"
# Load only the shipped rule, without user fragments or an audio connection.
"$scratch/mixer-rule" "$ROOT/default/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"
