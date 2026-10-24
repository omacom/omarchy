#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
TMP_BIN="$TMPDIR/bin"
CALL_LOG="$TMPDIR/calls.txt"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TMP_BIN"

# No browser is running unless a case says so, so the policy cases never
# refresh a real browser on the host.
cat > "$TMP_BIN/ps" <<'FAKE'
#!/bin/bash
exit 0
FAKE
chmod +x "$TMP_BIN/ps"

# Stub the privileged writer so we can observe whether the setter calls it.
cat > "$TMP_BIN/omarchy-theme-set-browser-policy" <<'FAKE'
#!/bin/bash
printf '%s\n' "$*" >> "${CALL_LOG:?}"
exit 0
FAKE
chmod +x "$TMP_BIN/omarchy-theme-set-browser-policy"

# The policy takes an administrator; the cases run as one unless they say so.
cat > "$TMP_BIN/omarchy-sudo-allowed" <<'FAKE'
#!/bin/bash
[[ ${TEST_ADMIN:-yes} == "yes" ]]
FAKE
chmod +x "$TMP_BIN/omarchy-sudo-allowed"

# A policy directory that already carries the target color, so the setter can
# skip everything.
policy_tmp="$TMPDIR/policies"
mkdir -p "$policy_tmp"
printf '{"BrowserThemeColor": "#1c2027", "BrowserColorScheme": "device"}\n' > "$policy_tmp/color.json"

# A test cannot make a root-owned file, so stat reports the owner the writer
# leaves behind, or a user-owned one.
stat_bin="$TMPDIR/stat-bin"
mkdir -p "$stat_bin"
cat >"$stat_bin/stat" <<'FAKE'
#!/bin/bash
printf '%s\n' "${STAT_OWNER:?}"
FAKE
chmod +x "$stat_bin/stat"

# No theme file -> fallback color #1c2027, which matches the fixture.
HOME="$TMPDIR" PATH="$stat_bin:$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" STAT_OWNER="root:root 644" \
  OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

if [[ -e $CALL_LOG ]]; then
  fail "setter skipped the privileged write when color.json already matches"
fi
pass "setter skips the privileged write when color.json already matches"

# The same color in a file the writer did not leave behind is not trusted.
HOME="$TMPDIR" PATH="$stat_bin:$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" STAT_OWNER="user:user 666" \
  OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

if [[ ! -e $CALL_LOG ]]; then
  fail "setter rewrites a matching color.json that is not root-owned 0644"
fi
pass "setter rewrites a matching color.json that is not root-owned 0644"

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

# Only an administrator may write the machine-wide policy, so anyone else leaves
# it alone instead of being asked for an administrator's password.
rm -f "$CALL_LOG"
HOME="$TMPDIR" PATH="$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" TEST_ADMIN=no \
  OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null ||
  fail "setter fails for an account that isn't an administrator"

if [[ -e $CALL_LOG ]]; then
  fail "setter left the machine-wide policy to an administrator"
fi
pass "setter leaves the machine-wide policy alone for other accounts"

# No managed policy dirs at all must not vacuously skip the writer.
rm -f "$CALL_LOG"

HOME="$TMPDIR" PATH="$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_BROWSER_POLICY_DIRS="$TMPDIR/nonexistent" CALL_LOG="$CALL_LOG" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

if [[ ! -e $CALL_LOG ]]; then
  fail "setter invoked the privileged writer when no managed dirs exist"
fi
pass "setter invokes the privileged writer when no managed dirs exist"

# Refreshes go to exactly the running browsers. ps is stubbed with a process
# table; each browser command logs its refresh.
browser_bin="$TMPDIR/browser-bin"
mkdir -p "$browser_bin"
cat >"$browser_bin/ps" <<'FAKE'
#!/bin/bash
printf '%s\n' \
  'chromium /usr/lib/chromium/chromium --type=renderer' \
  'chrome /opt/google/chrome/chrome' \
  'brave /opt/brave-origin-bin/brave --profile' \
  'bash bash -c pgrep -f brave'
FAKE
for command in chromium google-chrome microsoft-edge-stable brave brave-origin; do
  printf '#!/bin/bash\nprintf "%%s\\n" "%s" >>"$REFRESH_LOG"\n' "$command" >"$browser_bin/$command"
done
# Only the stubs count as installed, so a real browser on the host, such as
# google-chrome-stable, is neither preferred nor launched.
cat >"$browser_bin/omarchy-cmd-present" <<'FAKE'
#!/bin/bash
[[ -x ${BROWSER_BIN:?}/$1 ]]
FAKE
chmod +x "$browser_bin"/*

printf '{"BrowserThemeColor": "#ff0000"}\n' >"$policy_tmp/color.json"
refresh_log="$TMPDIR/refreshes"
HOME="$TMPDIR" PATH="$browser_bin:$TMP_BIN:$ROOT/bin:$PATH" OMARCHY_PATH="$ROOT" \
  OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" CALL_LOG="$CALL_LOG" REFRESH_LOG="$refresh_log" BROWSER_BIN="$browser_bin" \
  bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null

refreshed=$(sort "$refresh_log" | tr '\n' ' ')
# Chrome running as plain google-chrome is refreshed through that name; Edge is
# installed but not running; brave-origin matches on its binary path, and the
# running "brave" process refreshes plain brave too.
[[ $refreshed == "brave brave-origin chromium google-chrome " ]] ||
  fail "setter refreshes exactly the running browsers (got: $refreshed)"
pass "setter refreshes exactly the running browsers"

grep -q '<&0 &$' "$ROOT/bin/omarchy-theme-set-browser" ||
  fail "setter keeps stdin for the backgrounded policy writer"
pass "setter keeps stdin for the backgrounded policy writer"
