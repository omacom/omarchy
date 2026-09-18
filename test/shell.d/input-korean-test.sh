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
      printf '2\n'
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
# (InputMethodGroupInfo) with the current group: a us keyboard plus a German
# one carrying its own layout, so the rewrite has both an empty and a set item
# layout to carry over.
cat >"$work/bin/busctl" <<'SH'
#!/bin/bash
printf 'busctl' >>"$TEST_LOG"
printf ' <%s>' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

case " $* " in
  *" InputMethodGroupInfo "*)
    if [[ ${HANGUL_PRESENT:-false} == "true" ]]; then
      printf '%s\n' '{"type":"sa(ss)","data":["us",[["keyboard-us",""],["keyboard-de","de"],["hangul",""]]]}'
    else
      printf '%s\n' '{"type":"sa(ss)","data":["us",[["keyboard-us",""],["keyboard-de","de"]]]}'
    fi
    ;;
esac
SH

chmod +x "$work/bin/omarchy-pkg-add" "$work/bin/omarchy-restart-xcompose" "$work/bin/fcitx5-remote" "$work/bin/busctl"

export TEST_LOG="$log"
export PATH="$work/bin:$PATH"

"$ROOT/bin/omarchy-setup-input-hangul" >"$work/output"

grep -Fx 'pkg-add fcitx5-hangul' "$log" >/dev/null ||
  fail "Korean input installs the hangul engine"
grep -Fx 'restart-fcitx5' "$log" >/dev/null ||
  fail "Korean input restarts fcitx5 so it discovers the newly installed engine"
grep -F '<SetInputMethodGroupInfo> <ssa(ss)> <Default> <us> <3> <keyboard-us> <> <keyboard-de> <de> <hangul> <>' "$log" >/dev/null ||
  fail "Korean input preserves the current group and appends hangul" "$(cat "$log")"
grep -F '<Save>' "$log" >/dev/null ||
  fail "Korean input asks fcitx5 to save the updated group"
grep -F 'Korean input is ready' "$work/output" >/dev/null ||
  fail "Korean input reports when setup is complete" "$(cat "$work/output")"
grep -F '한/영' "$work/output" >/dev/null ||
  fail "Korean input names the 한/영 key as the toggle" "$(cat "$work/output")"
! grep -Fx '2' "$work/output" >/dev/null ||
  fail "Korean input keeps the fcitx5 state probe out of the terminal" "$(cat "$work/output")"
pass "Korean input installs and registers hangul"

: >"$log"
HANGUL_PRESENT=true "$ROOT/bin/omarchy-setup-input-hangul" >"$work/output-existing"

grep -Fx 'pkg-add fcitx5-hangul' "$log" >/dev/null ||
  fail "Korean input keeps package installation idempotent"
! grep -F '<SetInputMethodGroupInfo>' "$log" >/dev/null ||
  fail "Korean input does not duplicate an existing hangul entry" "$(cat "$log")"
grep -F 'Korean input is ready' "$work/output-existing" >/dev/null ||
  fail "Korean input reports an existing setup as ready"
pass "Korean input setup is idempotent"

: >"$log"
status=0
FCITX_RUNNING=false "$ROOT/bin/omarchy-setup-input-hangul" >"$work/output-down" 2>"$work/stderr-down" || status=$?

(( status == 1 )) ||
  fail "Korean input fails when fcitx5 never comes up" "exit status: $status"
grep -F 'Fcitx 5 is not running' "$work/stderr-down" >/dev/null ||
  fail "Korean input says fcitx5 is not running" "$(cat "$work/stderr-down")"
! grep -F 'Could not open DBus connection' "$work/stderr-down" >/dev/null ||
  fail "Korean input keeps the probe's bus errors out of the terminal" "$(cat "$work/stderr-down")"
! grep -F 'busctl' "$log" >/dev/null ||
  fail "Korean input leaves the input method group alone without fcitx5" "$(cat "$log")"
pass "Korean input refuses to configure a stopped fcitx5"
