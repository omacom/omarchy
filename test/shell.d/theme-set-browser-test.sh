#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
TMP_BIN="$TMPDIR/bin"
CALL_LOG="$TMPDIR/calls.txt"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMP_BIN"

# Stub the privileged writer so we can observe whether the setter calls it.
cat > "$TMP_BIN/omarchy-theme-set-browser-policy" <<'FAKE'
#!/bin/bash
printf '%s\n' "$*" >> "${CALL_LOG:?}"
exit 0
FAKE
chmod +x "$TMP_BIN/omarchy-theme-set-browser-policy"

# A policy directory that already carries the target color, so the setter can
# skip everything.
policy_tmp="$TMPDIR/policies"
mkdir -p "$policy_tmp"
printf '{"BrowserThemeColor": "#1c2027", "BrowserColorScheme": "device"}\n' > "$policy_tmp/color.json"

# No theme file -> fallback color #1c2027, which matches the fixture.
HOME="$TMPDIR" PATH="$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

if [[ -e $CALL_LOG ]]; then
  fail "setter skipped the privileged write when color.json already matches"
fi
pass "setter skips the privileged write when color.json already matches"

# Now point it at a policy dir whose color.json does not match.
rm -f "$CALL_LOG"
printf '{"BrowserThemeColor": "#ff0000"}\n' > "$policy_tmp/color.json"

HOME="$TMPDIR" PATH="$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

if [[ ! -e $CALL_LOG ]]; then
  fail "setter invoked the privileged writer when color.json mismatched"
fi
pass "setter invokes the privileged writer when color.json mismatches"

# No managed policy dirs at all must not vacuously skip the writer.
rm -f "$CALL_LOG"

HOME="$TMPDIR" PATH="$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_BROWSER_POLICY_DIRS="$TMPDIR/nonexistent" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

if [[ ! -e $CALL_LOG ]]; then
  fail "setter invoked the privileged writer when no managed dirs exist"
fi
pass "setter invokes the privileged writer when no managed dirs exist"

# Structural checks on the parallel refresh path.
if ! grep -q 'pids=\(\)' "$ROOT/bin/omarchy-theme-set-browser"; then
  fail "theme-set-browser collects browser refresh pids in an array"
fi
pass "theme-set-browser collects browser refresh pids in an array"

if ! grep -q 'for pid in "${pids\[@\]}"; do' "$ROOT/bin/omarchy-theme-set-browser"; then
  fail "theme-set-browser waits for parallel browser refreshes"
fi
pass "theme-set-browser waits for parallel browser refreshes"
