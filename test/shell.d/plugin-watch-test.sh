#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

registry="$ROOT/shell/services/PluginRegistry.qml"
shell="$ROOT/shell/shell.qml"

grep -Fq -- "--exclude" "$registry" || fail "plugin watcher excludes .git and cache dirs"
grep -Fq '__pycache__' "$registry" || fail "plugin watcher exclude lists __pycache__"
grep -Fq '.git' "$registry" || fail "plugin watcher exclude lists .git"
grep -A3 'id: localPluginReloadTimer' "$shell" | grep -Fq 'interval: 1000' \
  || fail "plugin reload timer coalesces to 1s"

pass "plugin watcher ignores git/cache and coalesces reloads"
