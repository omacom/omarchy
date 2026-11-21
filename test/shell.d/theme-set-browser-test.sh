#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
TMP_BIN="$TMPDIR/bin"
CALL_LOG="$TMPDIR/calls.txt"
# The hanging browser stub below ignores TERM, so if an assertion fails before
# its refresh is bounded it would outlive this file.
cleanup() {
  local pid
  if [[ -f $TMPDIR/m2/chromium.pid ]]; then
    while read -r pid; do kill -9 "$pid" 2>/dev/null || true; done <"$TMPDIR/m2/chromium.pid"
  fi
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

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
exit "${POLICY_STATUS:-0}"
FAKE
chmod +x "$TMP_BIN/omarchy-theme-set-browser-policy"

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

# etc/sudoers.d/omarchy-theme-browser admits six bare hex digits and nothing
# else, so a leading # would send every write to a password prompt.
[[ $(<"$CALL_LOG") == "1c2027" ]] ||
  fail "setter hands the writer the bare hex its sudoers rule admits" "got: $(<"$CALL_LOG")"
pass "setter hands the writer the bare hex its sudoers rule admits"

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
# Each one holds its default profile, with this shell standing in for its pid.
for profile in chromium google-chrome BraveSoftware/Brave-Browser BraveSoftware/Brave-Origin; do
  mkdir -p "$TMPDIR/.config/$profile"
  ln -s "$(uname -n)-$$" "$TMPDIR/.config/$profile/SingletonLock"
done

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

unset CHROME_USER_DATA_DIR CHROME_CONFIG_HOME

# Only the browsers listed in $running are in this process table.
running="$TMPDIR/running"
hang_bin="$TMPDIR/hang-bin"
mkdir -p "$hang_bin"
cp "$browser_bin/omarchy-cmd-present" "$hang_bin/"
cat >"$hang_bin/ps" <<'FAKE'
#!/bin/bash
while read -r name; do
  printf '%s /usr/lib/%s/%s\n' "$name" "$name" "$name"
done <"$RUNNING_BROWSERS"
FAKE
# Exits immediately, like a browser that takes the policy handoff and returns.
cat >"$hang_bin/brave" <<'FAKE'
#!/bin/bash
printf '%s\n' "$*" >"$REFRESH_MARKER_DIR/brave"
FAKE
# Never returns, and ignores TERM: plain `timeout` waits out a child like this
# instead of bounding it, which is why the refresh needs a kill fallback.
cat >"$hang_bin/chromium" <<'FAKE'
#!/bin/bash
trap '' TERM
sleep 120 &
printf '%s\n%s\n' "$$" "$!" >"$REFRESH_MARKER_DIR/chromium.pid"
wait
FAKE
chmod +x "$hang_bin"/*

run_theme_set() {
  local markers=$1 rc=0
  mkdir -p "$markers"
  HOME="$TMPDIR" PATH="$hang_bin:$TMP_BIN:$ROOT/bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" \
    OMARCHY_BROWSER_POLICY_DIRS="$policy_tmp" OMARCHY_BROWSER_FLAGS_DIR="$TMPDIR/etc" \
    CALL_LOG="$CALL_LOG" POLICY_STATUS="${POLICY_STATUS:-0}" \
    RUNNING_BROWSERS="$running" BROWSER_BIN="$hang_bin" REFRESH_MARKER_DIR="$markers" \
    timeout -k 5s 30s bash "$ROOT/bin/omarchy-theme-set-browser" >/dev/null 2>&1 || rc=$?
  return "$rc"
}

# A browser that answers promptly still gets its refresh.
printf 'brave\n' >"$running"
rc=0
run_theme_set "$TMPDIR/m1" || rc=$?
(( rc == 0 )) || fail "theme-set-browser succeeds when a running browser refreshes cleanly" "exit $rc"
[[ -f $TMPDIR/m1/brave ]] || fail "theme-set-browser refreshes a running browser"
grep -q -- '--refresh-platform-policy' "$TMPDIR/m1/brave" ||
  fail "theme-set-browser passes --refresh-platform-policy" "$(<"$TMPDIR/m1/brave")"
pass "theme-set-browser refreshes a running browser"

# A browser that never returns must not hold up the theme change, and must not
# take the browsers listed after it down with it.
printf 'chromium\nbrave\n' >"$running"
started=$SECONDS
rc=0
run_theme_set "$TMPDIR/m2" || rc=$?
elapsed=$((SECONDS - started))

# run_theme_set is itself bounded, so an unbounded refresh fails here instead of
# hanging the suite.
(( rc != 124 && rc != 137 )) ||
  fail "theme-set-browser converges when a browser refresh never returns" "still running after ${elapsed}s"
pass "theme-set-browser converges when a browser refresh never returns"

[[ -f $TMPDIR/m2/brave ]] ||
  fail "theme-set-browser still refreshes later browsers after one hangs"
pass "theme-set-browser still refreshes later browsers after one hangs"

(( rc == 0 )) ||
  fail "a timed-out browser refresh does not fail the theme change" "exit $rc"
pass "a timed-out browser refresh does not fail the theme change"

# The whole tree, not just the process timeout signalled: a browser leaves
# children behind, and they are what turns a bounded refresh into litter.
sleep 1
while read -r hung_pid; do
  if kill -0 "$hung_pid" 2>/dev/null; then
    fail "a timed-out browser refresh leaves no process behind" "pid $hung_pid still running"
  fi
done <"$TMPDIR/m2/chromium.pid"
pass "a timed-out browser refresh leaves no process behind"

# Policy writing owns the exit status; refreshing never did.
printf 'brave\n' >"$running"
rc=0
POLICY_STATUS=1 run_theme_set "$TMPDIR/m3" || rc=$?
(( rc == 1 )) || fail "a failed policy write still fails theme-set-browser" "exit $rc"
[[ -f $TMPDIR/m3/brave ]] || fail "a failed policy write still refreshes running browsers"
pass "a failed policy write still fails theme-set-browser"

# With no live owner on the default profile, a refresh would start a browser
# there instead of reaching one. pid_max is never handed out.
brave_lock="$TMPDIR/.config/BraveSoftware/Brave-Browser/SingletonLock"
printf 'brave\n' >"$running"
for case in "no lock:" "a dead pid:$(uname -n)-$(</proc/sys/kernel/pid_max)" "another host:not-$(uname -n)-$$"; do
  label=${case%%:*}
  owner=${case#*:}
  if [[ -z $owner ]]; then
    rm "$brave_lock"
  else
    ln -sfn "$owner" "$brave_lock"
  fi
  markers=$TMPDIR/unowned-${label// /-}
  rc=0
  run_theme_set "$markers" || rc=$?
  (( rc == 0 )) || fail "theme-set-browser succeeds without refreshing a profile with $label" "exit $rc"
  [[ ! -e $markers/brave ]] || fail "theme-set-browser skips the refresh for a profile with $label"
  pass "theme-set-browser skips the refresh for a profile with $label"
done

# A browser on another data directory holds that directory's lock, not the
# default profile's, so its refresh still runs.
rm -f "$brave_lock"
rc=0
CHROME_CONFIG_HOME=$TMPDIR/elsewhere run_theme_set "$TMPDIR/other-env" || rc=$?
(( rc == 0 )) && [[ -f $TMPDIR/other-env/brave ]] ||
  fail "theme-set-browser refreshes a browser on a data directory from the environment" "exit $rc"
pass "theme-set-browser refreshes a browser on a data directory from the environment"

printf -- '--user-data-dir=%s\n' "$TMPDIR/elsewhere" >"$TMPDIR/.config/brave-flags.conf"
rc=0
run_theme_set "$TMPDIR/other-flags" || rc=$?
rm "$TMPDIR/.config/brave-flags.conf"
(( rc == 0 )) && [[ -f $TMPDIR/other-flags/brave ]] ||
  fail "theme-set-browser refreshes a browser on a data directory from its flags file" "exit $rc"
pass "theme-set-browser refreshes a browser on a data directory from its flags file"

mkdir -p "$TMPDIR/etc"
printf -- '--user-data-dir=%s\n' "$TMPDIR/elsewhere" >"$TMPDIR/etc/brave-flags.conf"
rc=0
run_theme_set "$TMPDIR/other-system-flags" || rc=$?
rm "$TMPDIR/etc/brave-flags.conf"
(( rc == 0 )) && [[ -f $TMPDIR/other-system-flags/brave ]] ||
  fail "theme-set-browser refreshes a browser on a data directory from the system flags file" "exit $rc"
pass "theme-set-browser refreshes a browser on a data directory from the system flags file"
