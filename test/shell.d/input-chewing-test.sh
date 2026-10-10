#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

mkdir -p "$work/bin"
log="$work/calls"
: >"$log"

cat >"$work/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add %s\n' "$*" >>"$TEST_LOG"
SH

cat >"$work/bin/omarchy-restart-xcompose" <<'SH'
#!/bin/bash
printf 'restart-fcitx5\n' >>"$TEST_LOG"
SH

# A bare --check also prints the input state (0, 1 or 2) once fcitx5 answers,
# and errors on stderr until it does; the script has to keep both out of the
# presentation terminal.
cat >"$work/bin/fcitx5-remote" <<'SH'
#!/bin/bash
case "$1" in
  --check)
    if [[ ${FCITX_RUNNING:-true} == "true" ]]; then
      printf '1\n'
    else
      printf 'Could not open DBus connection\n' >&2
      exit 1
    fi
    ;;
  -q) printf 'Default\n' ;;
  *) exit 1 ;;
esac
SH

# Log every call the way the script makes it, and answer the one read it does
# (InputMethodGroupInfo) with the current group: a us keyboard plus a Japanese
# engine carrying its own layout, so the rewrite has both an empty and a set
# item layout to carry over, and a second CJK engine to leave alone.
cat >"$work/bin/busctl" <<'SH'
#!/bin/bash
printf 'busctl' >>"$TEST_LOG"
printf ' <%s>' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

case " $* " in
  *" InputMethodGroupInfo "*)
    if [[ ${CHEWING_PRESENT:-false} == "true" ]]; then
      printf '%s\n' '{"type":"sa(ss)","data":["us",[["keyboard-us",""],["mozc","jp"],["chewing",""]]]}'
    else
      printf '%s\n' '{"type":"sa(ss)","data":["us",[["keyboard-us",""],["mozc","jp"]]]}'
    fi
    ;;
esac
SH

chmod +x "$work/bin/omarchy-pkg-add" "$work/bin/omarchy-restart-xcompose" "$work/bin/fcitx5-remote" "$work/bin/busctl"

export TEST_LOG="$log"
export PATH="$work/bin:$PATH"

"$ROOT/bin/omarchy-setup-input-chewing" >"$work/output"

grep -Fx 'pkg-add fcitx5-chewing' "$log" >/dev/null ||
  fail "Traditional Chinese input installs the chewing engine"
grep -Fx 'restart-fcitx5' "$log" >/dev/null ||
  fail "Traditional Chinese input restarts fcitx5 so it discovers the newly installed engine"
grep -F '<SetInputMethodGroupInfo> <ssa(ss)> <Default> <us> <3> <keyboard-us> <> <mozc> <jp> <chewing> <>' "$log" >/dev/null ||
  fail "Traditional Chinese input preserves the current group and appends chewing" "$(cat "$log")"
grep -F '<Save>' "$log" >/dev/null ||
  fail "Traditional Chinese input asks fcitx5 to save the updated group"
grep -F 'Traditional Chinese input is ready' "$work/output" >/dev/null ||
  fail "Traditional Chinese input reports when setup is complete" "$(cat "$work/output")"
grep -F 'Ctrl+Space' "$work/output" >/dev/null ||
  fail "Traditional Chinese input names Ctrl+Space as the toggle" "$(cat "$work/output")"
! grep -Fx '1' "$work/output" >/dev/null ||
  fail "Traditional Chinese input keeps the fcitx5 state probe out of the terminal" "$(cat "$work/output")"
pass "Traditional Chinese input installs and registers chewing"

: >"$log"
CHEWING_PRESENT=true "$ROOT/bin/omarchy-setup-input-chewing" >"$work/output-existing"

grep -Fx 'pkg-add fcitx5-chewing' "$log" >/dev/null ||
  fail "Traditional Chinese input keeps package installation idempotent"
! grep -F '<SetInputMethodGroupInfo>' "$log" >/dev/null ||
  fail "Traditional Chinese input does not duplicate an existing chewing entry" "$(cat "$log")"
grep -F 'Traditional Chinese input is ready' "$work/output-existing" >/dev/null ||
  fail "Traditional Chinese input reports an existing setup as ready"
pass "Traditional Chinese input setup is idempotent"

: >"$log"
status=0
FCITX_RUNNING=false "$ROOT/bin/omarchy-setup-input-chewing" >"$work/output-down" 2>"$work/stderr-down" || status=$?

(( status == 1 )) ||
  fail "Traditional Chinese input fails when fcitx5 never comes up" "exit status: $status"
grep -F 'Fcitx 5 is not running' "$work/stderr-down" >/dev/null ||
  fail "Traditional Chinese input says fcitx5 is not running" "$(cat "$work/stderr-down")"
! grep -F 'Could not open DBus connection' "$work/stderr-down" >/dev/null ||
  fail "Traditional Chinese input keeps the probe's bus errors out of the terminal" "$(cat "$work/stderr-down")"
! grep -F 'busctl' "$log" >/dev/null ||
  fail "Traditional Chinese input leaves the input method group alone without fcitx5" "$(cat "$log")"
pass "Traditional Chinese input refuses to configure a stopped fcitx5"
