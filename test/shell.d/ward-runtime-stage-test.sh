#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stage_root=$(mktemp -d)
trap 'rm -r -- "$stage_root"' EXIT
runtime_dir="$stage_root/runtime with spaces"
OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-ward-stage-runtime" "$runtime_dir"
[[ $(jq -r '.version' "$runtime_dir/runtime.json") == "1" ]] || fail "runtime declares its protocol version"
[[ $(jq -r '.entryPoint' "$runtime_dir/runtime.json") == "worker" ]] || fail "runtime selects its worker bootstrap"
[[ -x $runtime_dir/worker && -x $runtime_dir/bin/omarchy-ward-exec ]] || fail "runtime entry and aliases are executable"
[[ -x $runtime_dir/bin/omarchy-ward-play ]] || fail "runtime stages its sandbox-local audio decoder"
for asset in worker.qml WidgetView.qml Ward/Desktop.qml Commons/Color.qml Ui/Panel.qml Services/PluginShellApi.qml; do
  [[ -f $runtime_dir/shell/$asset ]] || fail "runtime contains $asset"
done
[[ ! -e $runtime_dir/.git && ! -e $runtime_dir/shell/services && ! -e $runtime_dir/config ]] || fail "runtime excludes the host checkout and service tree"
[[ $(find "$runtime_dir" -type l -print -quit) == "" ]] || fail "runtime has no checkout symlinks"
pass "separately staged runtime contains only Omarchy adapter assets"

if OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-ward-stage-runtime" "$runtime_dir" 2>/dev/null; then
  fail "staging refuses to overwrite a selected runtime"
fi
ln -s "$stage_root/missing" "$stage_root/link"
if OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-ward-stage-runtime" "$stage_root/link" 2>/dev/null; then
  fail "staging refuses dangling symlink destinations"
fi
if OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-ward-stage-runtime" relative 2>/dev/null; then
  fail "staging refuses relative destinations"
fi
pass "staging cannot replace an existing runtime or follow a destination symlink"
