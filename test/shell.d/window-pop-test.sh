#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

cat >"$mock_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "activewindow" ]]; then
  printf '{"address":"0xabc","pinned":false,"fullscreen":%s}\n' "$OMARCHY_TEST_FULLSCREEN"
else
  printf '%s\n' "$*" >>"$OMARCHY_TEST_DISPATCH_LOG"
fi
SH
chmod +x "$mock_bin/hyprctl"

pop() {
  : >"$test_tmp/dispatch"
  PATH="$mock_bin:$PATH" OMARCHY_TEST_FULLSCREEN="$1" OMARCHY_TEST_DISPATCH_LOG="$test_tmp/dispatch" \
    bash "$ROOT/bin/omarchy-hyprland-window-pop"
}

for state in 1 2; do
  pop "$state"
  first=$(grep -n 'fullscreen(' "$test_tmp/dispatch" | head -1 | cut -d: -f1)
  float=$(grep -n 'float(' "$test_tmp/dispatch" | head -1 | cut -d: -f1)
  [[ -n $first && $first -lt $float ]] || fail "pop-out leaves fullscreen state $state before floating"
  grep -q 'mode = "maximized", action = "unset"' "$test_tmp/dispatch" || fail "pop-out keeps a maximized window maximized"
done

pop 0
! grep -q 'fullscreen(' "$test_tmp/dispatch" || fail "pop-out touches fullscreen on a tiled window"
grep -q 'pin(' "$test_tmp/dispatch" || fail "pop-out pins the window"
