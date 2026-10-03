#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v qs >/dev/null; then
  skip "no Quickshell; skipping catalog loader runtime checks"
  exit 0
fi

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT
mkdir -p "$TEMP_DIR/runtime" "$TEMP_DIR/config" "$TEMP_DIR/catalog/shell/translations"
chmod 700 "$TEMP_DIR/runtime"
cp "$SHELL_TEST_DIR/fixtures/i18n/Loader.qml" "$TEMP_DIR/config/shell.qml"
ln -s "$ROOT/shell/Commons" "$TEMP_DIR/config/Commons"
FIXTURE="$TEMP_DIR/config/shell.qml"

run_loader() {
  local source_root="$1" locale="$2"
  env OMARCHY_PATH="$source_root" LANG="$locale" LANGUAGE= LC_ALL= LC_MESSAGES= \
    XDG_RUNTIME_DIR="$TEMP_DIR/runtime" QT_QPA_PLATFORM=offscreen \
    timeout 10 qs -p "$FIXTURE" >"$TEMP_DIR/log" 2>&1 || fail "headless Quickshell loader exits cleanly" "$(cat "$TEMP_DIR/log")"
}

run_loader "$ROOT" zh_TW.UTF-8
grep -q 'NETWORK=網路' "$TEMP_DIR/log" || fail "Chinese catalog is available on the first lookup" "$(cat "$TEMP_DIR/log")"
grep -q 'CONFIRM=確定要解除安裝 example 嗎？' "$TEMP_DIR/log" || fail "runtime formats translated confirmation" "$(cat "$TEMP_DIR/log")"
grep -q 'UNKNOWN=Uncatalogued message' "$TEMP_DIR/log" || fail "runtime preserves unknown source text"
pass "Chinese catalog loads synchronously with literal arguments and English fallback"

run_loader "$ROOT" en_US.UTF-8
grep -q 'NETWORK=Network' "$TEMP_DIR/log" || fail "English locale remains English"
pass "English locale does not load Chinese translations"

run_loader "$TEMP_DIR/catalog" zh_TW.UTF-8
grep -q 'NETWORK=Network' "$TEMP_DIR/log" || fail "missing catalog falls back to English" "$(cat "$TEMP_DIR/log")"
pass "a missing catalog does not prevent shell startup"

printf '%s\n' '{malformed json' >"$TEMP_DIR/catalog/shell/translations/zh_TW.json"
run_loader "$TEMP_DIR/catalog" zh_TW.UTF-8
grep -q 'NETWORK=Network' "$TEMP_DIR/log" || fail "malformed catalog falls back to English"
pass "a malformed catalog does not prevent shell startup"
