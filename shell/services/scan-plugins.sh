#!/bin/bash
# Omarchy plugin manifest scanner.
#
# Outputs manifests in the format consumed by PluginRegistry.parseScanOutput:
#   ===<kind>::<absolute-source-dir>===
#   ... raw manifest.json content ...
#   === EOM ===
#
# $1: first-party plugin directory (e.g. /usr/share/omarchy/shell/plugins)
# $2: third-party plugin directory (e.g. ~/.config/omarchy/plugins)

set -euo pipefail

emit_manifest() {
  local kind="$1"
  local manifest="$2"
  local sub

  if [[ ${manifest##*/} == "manifest.json" ]]; then
    sub="${manifest%/manifest.json}"
  else
    sub="$(dirname -- "$manifest")"
  fi

  printf '===%s::%s===\n' "$kind" "$sub"
  cat "$manifest"
  printf '\n=== EOM ===\n'
}

scan_firstparty() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  while IFS= read -r manifest; do
    [[ -n $manifest ]] || continue
    emit_manifest firstparty "$manifest"
  done < <(find "$dir" -mindepth 2 -maxdepth 3 -type f \( -name manifest.json -o -name '*.manifest.json' \) | sort)
}

scan_thirdparty() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0

  for sub in "$dir"/*/; do
    [[ -f "$sub/manifest.json" ]] || continue
    emit_manifest thirdparty "$sub/manifest.json"
  done
}

scan_firstparty "${1:-}"
scan_thirdparty "${2:-}"
