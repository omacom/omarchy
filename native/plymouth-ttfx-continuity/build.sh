#!/bin/bash
# Build omarchy-plymouth-continuity out of tree.
#
# Usage: build.sh [OUTPUT_DIR]
# OUTPUT_DIR defaults to a new ${TMPDIR:-/var/tmp}/omarchy-plymouth-continuity.XXXXXXXX
# directory, which is retained. Generated protocol code and the binary go
# there; nothing is written into the source tree.
# Needs gcc, pkg-config, wayland-client, wayland-scanner and wayland-protocols,
# plus cargo for the TTFX engine the desktop outro replays, unless
# TTFX_ENGINE_LIB names an already built libttfx_plymouth.a.
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
out=${1:-}
if [[ -z $out ]]; then
  out=$(mktemp -d "${TMPDIR:-/var/tmp}/omarchy-plymouth-continuity.XXXXXXXX")
else
  mkdir -p -- "$out"
fi
gen=$out/protocol
mkdir -p -- "$gen"

pkg_config=${PKG_CONFIG:-pkg-config}
scanner=${WAYLAND_SCANNER:-$("$pkg_config" --variable=wayland_scanner wayland-scanner 2>/dev/null || command -v wayland-scanner)}
protocols=$("$pkg_config" --variable=pkgdatadir wayland-protocols)
[[ -x $scanner ]] || { echo "wayland-scanner not found" >&2; exit 1; }

xmls=(
  "$root/protocol/wlr-layer-shell-unstable-v1.xml"
  "$protocols/stable/xdg-shell/xdg-shell.xml"
  "$protocols/stable/viewporter/viewporter.xml"
  "$protocols/staging/alpha-modifier/alpha-modifier-v1.xml"
  "$protocols/stable/presentation-time/presentation-time.xml"
)
sources=()
for xml in "${xmls[@]}"; do
  [[ -f $xml ]] || { echo "missing protocol: $xml" >&2; exit 1; }
  base=$(basename -- "$xml" .xml)
  "$scanner" client-header "$xml" "$gen/$base-client-protocol.h"
  "$scanner" private-code "$xml" "$gen/$base-protocol.c"
  sources+=("$gen/$base-protocol.c")
done

cflags=(-std=c11 -O2 -Wall -Wextra -Wpedantic -Werror -D_FORTIFY_SOURCE=2
  -fstack-protector-strong -fPIE)
# shellcheck disable=SC2207
wayland_cflags=($("$pkg_config" --cflags wayland-client))
# shellcheck disable=SC2207
wayland_libs=($("$pkg_config" --libs wayland-client))

engine=${TTFX_ENGINE_LIB:-}
if [[ -z $engine ]]; then
  (cd "$root/../plymouth-ttfx-engine" &&
    CARGO_TARGET_DIR="$out/engine-target" cargo build --locked --offline --profile plymouth >&2)
  engine=$out/engine-target/plymouth/libttfx_plymouth.a
fi
[[ -f $engine ]] || { echo "TTFX engine library not found: $engine" >&2; exit 1; }

gcc "${cflags[@]}" "${wayland_cflags[@]}" -I"$gen" -I"$root" \
  "$root/continuity.c" "$root/frame.c" "$root/outro.c" "$root/../plymouth-ttfx-plugin/state.c" \
  "${sources[@]}" \
  -pie -Wl,-z,relro,-z,now "${wayland_libs[@]}" "$engine" -ldl -lpthread -lm \
  -o "$out/omarchy-plymouth-continuity"
printf '%s\n' "$out/omarchy-plymouth-continuity"
