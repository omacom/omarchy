#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
CATALOG=$TMP/cache/recipes.json
RECIPES=$ROOT/shell/plugins/panels/local-ai/recipes.json
SOURCE=$ROOT/shell/plugins/panels/local-ai/recipes.json
MODE=ok
now() { echo 2026-09-29T00:00:00Z; }
die() { echo "local-ai: $*" >&2; exit 1; }
eval "$(sed -n '/^policy() {/,/^# cdi_stale:/p' "${BACKEND:-$ROOT/bin/omarchy-local-ai}" | sed '$d')"
curl() {
  if [[ $* == *commits/main* ]]; then printf '{"sha":"%040d"}\n' 1
  elif [[ $MODE == offline ]]; then return 22
  elif [[ $MODE == malformed ]]; then echo broken
  elif [[ $MODE == unpinned ]]; then jq '.gateway.image = "gateway:latest"' "$SOURCE"
  else cat "$SOURCE"; fi
}
phase_registry
jq -e '.registryCommit == "0000000000000000000000000000000000000001" and (.hardware|length > 0)' "$CATALOG" >/dev/null
before=$(sha256sum "$CATALOG")
for MODE in offline malformed unpinned; do
  set +e
  (set -e; phase_registry) >"$TMP/out" 2>&1
  rc=$?
  set -e
  [[ $rc != 0 && $(sha256sum "$CATALOG") == "$before" ]] || { echo "not ok - $MODE replaced the catalog"; exit 1; }
done
echo 'ok - registry updates atomically and retains the previous catalog on network, schema and pin failures'
