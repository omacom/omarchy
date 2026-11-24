#!/bin/bash
#
# omarchy_compression.conf picks zstd where nothing sets COMPRESSION, so an
# aarch64 build no longer takes Arch Linux ARM's gzip fallback, and leaves a
# compressor the machine set itself alone.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

conf="$ROOT/etc/mkinitcpio.conf.d/omarchy_compression.conf"

# The compressor mkinitcpio uses once mkinitcpio.conf ($1, shell code) and the
# drop-in are sourced, with Arch Linux ARM's fallback: COMPRESSION or gzip.
compressor() {
  (
    set +u
    eval "$1"
    source "$conf"
    printf '%s\n' "${COMPRESSION:-gzip}"
  )
}

assert_compressor() {
  local description=$1 config=$2 expected=$3 actual
  actual=$(compressor "$config") || fail "$description" "sourcing $conf failed"
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

assert_compressor "an unset COMPRESSION becomes zstd" "" zstd
assert_compressor "the stock mkinitcpio.conf, which only comments COMPRESSION, gets zstd" '#COMPRESSION="gzip"' zstd
assert_compressor "a COMPRESSION set in mkinitcpio.conf stays" 'COMPRESSION="lz4"' lz4
assert_compressor "an explicit gzip stays" 'COMPRESSION="gzip"' gzip
