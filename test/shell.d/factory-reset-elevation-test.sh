#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

if (( EUID == 0 )); then
  skip "factory-reset self-elevation requires an unprivileged caller"
  exit 0
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/checkout with spaces"

# Exercise the real startup, but never include the destructive reset body.
awk '
  /^export PATH=/ { found = 1; print "exit 99"; exit }
  { print }
  END { if (!found) exit 1 }
' "$ROOT/bin/omarchy-system-factory-reset" >"$tmp/checkout with spaces/reset"
grep -Fxq 'PACKAGED_PATH=/usr/bin/omarchy-system-factory-reset' "$ROOT/bin/omarchy-system-factory-reset" || fail "factory reset pins the packaged path"
sed -i "s|^PACKAGED_PATH=.*|PACKAGED_PATH=\"$tmp/packaged-reset\"|" "$tmp/checkout with spaces/reset"
cp "$tmp/checkout with spaces/reset" "$tmp/packaged-reset"
chmod +x "$tmp/checkout with spaces/reset" "$tmp/packaged-reset"
ln -s "$tmp/checkout with spaces/reset" "$tmp/reset-link"

cat >"$tmp/bin/sudo" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >"$CALL_LOG"
exit "${SUDO_STATUS:-0}"
SH
chmod +x "$tmp/bin/sudo"

args=('argument with spaces' '' '--flag' '$(touch should-not-run)' $'two\nlines')
expected=(env -- $'GUM_INPUT_PROMPT=Reset\nthis computer? ' 'GUM_STYLE=' "$tmp/packaged-reset" "${args[@]}")
for invocation in "$tmp/checkout with spaces/reset" './checkout with spaces/reset' "$tmp/reset-link" "$tmp/packaged-reset" reset; do
  for status in 0 1 127; do
    actual_status=0
    (cd "$tmp" && env -i HOME="$tmp" PATH="$tmp/bin:$tmp/checkout with spaces:/usr/bin:/bin" \
      OMARCHY_PATH="$tmp/checkout with spaces" PACKAGED_PATH="$tmp/wrong-target" \
      GUM_INPUT_PROMPT=$'Reset\nthis computer? ' GUM_STYLE='' \
      NON_GUM_NOTE=$'ordinary note\nGUM_LABEL=still a note' CALL_LOG="$tmp/call" SUDO_STATUS="$status" \
      "$invocation" "${args[@]}") || actual_status=$?
    (( actual_status == status )) || fail "elevation status is preserved for $invocation"
    mapfile -d '' -t actual <"$tmp/call"
    (( ${#actual[@]} == ${#expected[@]} )) || fail "elevation argument count is preserved"
    for i in "${!expected[@]}"; do
      [[ ${actual[i]} == "${expected[i]}" ]] || fail "elevation argument $i is preserved for $invocation"
    done
    [[ ! -e $tmp/should-not-run ]] || fail "caller arguments were executed"
  done
  pass "factory reset pins $invocation to the packaged command and preserves arguments, styling and status"
done

env -i HOME="$tmp" PATH="$tmp/bin:/usr/bin:/bin" CALL_LOG="$tmp/call" \
  NON_GUM_NOTE=$'ordinary note\nGUM_LABEL=still a note' "$tmp/packaged-reset" "${args[@]}"
mapfile -d '' -t actual <"$tmp/call"
expected=(env -- "$tmp/packaged-reset" "${args[@]}")
(( ${#actual[@]} == ${#expected[@]} )) || fail "no-GUM elevation argument count is preserved"
for i in "${!expected[@]}"; do
  [[ ${actual[i]} == "${expected[i]}" ]] || fail "no-GUM elevation argument $i is preserved"
done
pass "factory reset forwards no assignments when GUM variables are absent"

if unshare -Ur true >/dev/null 2>&1; then
  status=0
  unshare -Ur "$tmp/packaged-reset" || status=$?
  (( status == 99 )) || fail "matching root invocation did not reach the guarded body"
  pass "matching packaged root invocation reaches the reset body"
else
  skip "user namespaces unavailable; root invocation coverage"
fi

# A checkout must not hand off to older installed code, even with explicit sudo.
printf '\n# older packaged copy\n' >>"$tmp/packaged-reset"
rm -f "$tmp/call"
if CALL_LOG="$tmp/call" PATH="$tmp/bin:/usr/bin:/bin" "$tmp/reset-link" >"$tmp/mismatch" 2>&1; then
  fail "mismatched reset implementation was accepted"
fi
[[ ! -e $tmp/call ]] || fail "mismatched reset requested elevation"
grep -Fq 'Install the matching Omarchy package' "$tmp/mismatch" || fail "mismatch explains recovery"
if unshare -Ur true >/dev/null 2>&1; then
  status=0
  unshare -Ur "$tmp/reset-link" >"$tmp/root-mismatch" 2>&1 || status=$?
  (( status == 1 )) || fail "root invocation did not refuse mismatch before the reset body"
  pass "root checkout invocation refuses a mismatched packaged reset"
fi
pass "mismatched checkout refuses before elevation"
