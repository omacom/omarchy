#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

checkout="$test_tmp/checkout & \"quoted\" \\ files | test"
ln -s "$ROOT" "$checkout"
for host in copy-url ytdlp; do
  HOME="$test_tmp/home" OMARCHY_PATH="$checkout" bash "$ROOT/bin/omarchy-install-chromium-$host"
  if [[ $host == "copy-url" ]]; then
    host_name=com.omarchy.copy_url
  else
    host_name=com.omarchy.ytdlp
  fi
  count=0
  while IFS= read -r -d '' manifest; do
    jq -e --arg expected "$checkout/bin/omarchy-chromium-$host-host" \
      '.path == $expected and .type == "stdio" and (.allowed_origins | length > 0)' \
      "$manifest" >/dev/null || fail "$host manifest preserves the executable path"
    count=$((count + 1))
  done < <(find "$test_tmp/home" -name "$host_name.json" -print0)
  (( count == 12 )) || fail "$host registers all supported browser profiles" "$count"
  pass "$host manifests preserve special characters in the checkout path"
done
