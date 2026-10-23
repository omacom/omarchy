#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin" "$test_tmp/home"

# The real command handles marker writes. Only process discovery/signaling is
# intercepted, so these tests never inspect or signal a live picker.
cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
[[ $# == 2 && $1 == "-x" && $2 == "slurp" ]] || exit 99
exit "${PICKER_STATUS:-0}"
SH

cat >"$mock_bin/pkill" <<'SH'
#!/bin/bash
[[ $# == 2 && $1 == "-x" && $2 == "slurp" ]] || exit 99
if [[ -f $EXPECTED_MARKER ]]; then
  printf 'marker-ready\n' >>"$PKILL_LOG"
else
  printf 'marker-missing\n' >>"$PKILL_LOG"
fi
SH
chmod +x "$mock_bin/pgrep" "$mock_bin/pkill"

run_take() {
  HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$PATH" \
    XDG_RUNTIME_DIR="$runtime_dir" EXPECTED_MARKER="$marker" PKILL_LOG="$pkill_log" \
    "$ROOT/bin/omarchy-capture-region" "--take-$mode"
}

for mode in fullscreen window; do
  pkill_log="$test_tmp/$mode-pkill"
  : >"$pkill_log"

  # An existing file in place of the runtime directory makes the actual touch
  # fail deterministically, including when the suite runs as root.
  runtime_dir="$test_tmp/$mode-blocked"
  printf 'keep-runtime-entry\n' >"$runtime_dir"
  marker="$runtime_dir/omarchy-capture-region-$mode"
  status=0
  run_take >"$test_tmp/output" 2>"$test_tmp/error" || status=$?
  (( status != 0 )) || fail "a failed $mode marker write reports failure"
  [[ -s $test_tmp/error ]] || fail "the failed $mode marker write reports its error"
  [[ ! -e $marker ]] || fail "a failed $mode marker write leaves no marker"
  [[ ! -s $pkill_log ]] || fail "a failed $mode marker write does not dismiss the picker"
  [[ $(cat "$runtime_dir") == "keep-runtime-entry" ]] || fail "the blocked runtime entry is preserved"
  pass "a failed $mode marker write leaves the picker active and reports failure"

  runtime_dir="$test_tmp/$mode-runtime"
  mkdir -p "$runtime_dir"
  marker="$runtime_dir/omarchy-capture-region-$mode"
  run_take
  [[ -f $marker ]] || fail "a successful $mode take writes its marker"
  [[ $(cat "$pkill_log") == "marker-ready" ]] || fail "a successful $mode take writes its marker before dismissing the picker"
  pass "a successful $mode marker write precedes picker dismissal"

  rm -f "$marker"
  : >"$pkill_log"
  PICKER_STATUS=1 run_take
  [[ ! -e $marker ]] || fail "no $mode marker is written without an active picker"
  [[ ! -s $pkill_log ]] || fail "no picker is dismissed when none is active"
  pass "a $mode take without an active picker is a successful no-op"
done
