#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
log="$tmpdir/hyprctl.log"
mkdir -p "$stub_bin"

cat >"$stub_bin/hyprctl" <<'SH'
#!/bin/bash
printf '<%s>' "$@" >>"$HYPRCTL_LOG"
printf '\n' >>"$HYPRCTL_LOG"

if [[ $1 == "activewindow" ]]; then
  printf '{"pinned": %s, "address": "0xabc"}\n' "${WINDOW_PINNED:-false}"
elif [[ $1 == "--batch" && ${BATCH_FAIL:-0} == "1" ]]; then
  exit 1
fi
SH
chmod +x "$stub_bin/hyprctl"

run_pop() {
  HYPRCTL_LOG="$log" PATH="$stub_bin:$PATH" \
    bash "$ROOT/bin/omarchy-hyprland-window-pop" "$@"
}

run_pop
(( $(wc -l <"$log") == 2 )) ||
  fail "window pop uses one compositor batch" "$(cat "$log")"
grep -q '<--batch><dispatch hl.dsp.window.float.*hl.dsp.window.resize.*hl.dsp.window.center.*hl.dsp.window.pin.*hl.dsp.window.alter_zorder.*hl.dsp.window.tag' "$log" ||
  fail "window pop batches its six actions in order" "$(cat "$log")"
pass "window pop uses one compositor batch"

: >"$log"
if BATCH_FAIL=1 run_pop; then
  fail "a compositor connection failure reaches the caller"
fi
(( $(wc -l <"$log") == 2 )) || fail "a failed batch is not replayed"
pass "window pop reports connection failures without replaying actions"

: >"$log"
run_pop 800 500 100 120
grep -q 'x = 800, y = 500.*x = 100, y = 120' "$log" || fail "explicit size and position are batched"
! grep -q 'center' "$log" || fail "explicit placement does not also center the window"
! grep -q ' ; >' "$log" || fail "the batch has no trailing empty command"
pass "explicit pop geometry is preserved"

: >"$log"
WINDOW_PINNED=true run_pop
(( $(wc -l <"$log") == 2 )) ||
  fail "window unpop uses one compositor batch" "$(cat "$log")"
grep -q '<--batch><dispatch hl.dsp.window.pin.*hl.dsp.window.float.*hl.dsp.window.tag' "$log" ||
  fail "window unpop batches its three actions in order" "$(cat "$log")"
pass "window unpop uses one compositor batch"
