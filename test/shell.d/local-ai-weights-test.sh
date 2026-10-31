#!/bin/bash
# Select only the named weight files, preserving the existing mmproj companion behavior.
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
export OMARCHY_PATH=$ROOT
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
sed '/^paths "\$HOME"$/,$d' "${BACKEND:-$ROOT/bin/omarchy-local-ai}" >"$TMP/functions"
source "$TMP/functions"
STATE=$TMP/state
mkdir -p "$STATE/trees"
rev=0000000000000000000000000000000000000001
printf 'config.json\t100\t-\ninference/engram.py\t200\t-\nmodel-01.safetensors\t300\t-\nmodel-02.safetensors\t400\t-\nmmproj.gguf\t50\t-\n' >"$STATE/trees/owner--model@$rev"
actual=$(tree owner/model "$rev" 'config.json,inference/engram.py,model-02.safetensors' | cut -f1)
[[ $actual == $'config.json\ninference/engram.py\nmodel-02.safetensors\nmmproj.gguf' ]] || { echo 'not ok - explicit weight-file list'; exit 1; }
[[ $(tree owner/model "$rev" '' | wc -l) == 5 ]] || exit 1
r=$(jq -c 'first(.hardware[].recipes[0])' "$ROOT/shell/plugins/panels/local-ai/recipes.json")
for files in 'config.json,inference/engram.py' 'model-02.safetensors'; do
 [[ $(policy "$(jq --arg f "$files" '.weights[0].files=$f' <<<"$r")" "$ROOT/shell/plugins/panels/local-ai/recipes.json") == ok ]] || exit 1
done
for files in '../escape' 'config.json,/absolute' 'a/../../escape'; do
 [[ $(policy "$(jq --arg f "$files" '.weights[0].files=$f' <<<"$r")" "$ROOT/shell/plugins/panels/local-ai/recipes.json") == 'invalid weights' ]] || exit 1
done
echo 'ok - weight lists select named files and reject traversal and absolute paths'
