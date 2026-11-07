#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

fixture=$(mktemp -d)
fixture=$(cd -- "$fixture" && pwd -P)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/logs with spaces"
cat >"$fixture/bin/tensorboard" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$TRACE"
exit "${TOOL_STATUS:-0}"
STUB
chmod +x "$fixture/bin/tensorboard"
export PATH="$fixture/bin:$ROOT/bin:$PATH" TRACE="$fixture/args"

bash "$ROOT/bin/omarchy-launch-tensorboard" "$fixture/logs with spaces" --port 6007 >/dev/null
mapfile -d '' -t args <"$TRACE"
(( ${#args[@]} == 6 )) && [[ ${args[0]} == "--logdir" && ${args[1]} == "$fixture/logs with spaces" && ${args[2]} == "--host" && ${args[3]} == "127.0.0.1" && ${args[4]} == "--port" && ${args[5]} == "6007" ]] || fail "TensorBoard receives the literal directory and loopback address"
pass "TensorBoard receives the literal log directory and selected loopback port"

rm "$TRACE"
for bad in 0 65536 1e3 --host; do
  if bash "$ROOT/bin/omarchy-launch-tensorboard" "$fixture/logs with spaces" --port "$bad" >/dev/null 2>&1; then
    fail "invalid TensorBoard port is refused"
  fi
done
if bash "$ROOT/bin/omarchy-launch-tensorboard" "$fixture/missing" >/dev/null 2>&1; then fail "missing logs are refused"; fi
[[ ! -e $TRACE ]] || fail "invalid input never starts TensorBoard"
pass "invalid ports and missing logs are rejected before launch"

status=0
TOOL_STATUS=7 bash "$ROOT/bin/omarchy-launch-tensorboard" "$fixture/logs with spaces" >/dev/null || status=$?
(( status == 7 )) || fail "TensorBoard errors reach the caller"
pass "TensorBoard errors reach the caller"
bash "$ROOT/bin/omarchy-launch-tensorboard" --help >/dev/null

mkdir -p "$fixture/project/runs" "$fixture/elsewhere/runs"
(
  cd -- "$fixture/project"
  CDPATH="$fixture/elsewhere:." bash "$ROOT/bin/omarchy-launch-tensorboard" runs >/dev/null
)
mapfile -d '' -t args <"$TRACE"
[[ ${args[1]} == "$fixture/project/runs" ]] || fail "CDPATH cannot redirect or contaminate the log directory"
pass "relative log directories are independent of CDPATH"

mkdir -p "$fixture/other/models" "$fixture/other/runs"
ln -s "$fixture/other/models" "$fixture/project/link"
(
  cd -- "$fixture/project"
  bash "$ROOT/bin/omarchy-launch-tensorboard" link/../runs >/dev/null
)
mapfile -d '' -t args <"$TRACE"
[[ ${args[1]} == "$fixture/other/runs" ]] || fail "symlink traversal selects the checked log directory"
pass "symlinks followed by parent traversal preserve the selected log directory"
