#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

fixture=$(mktemp -d)
fixture=$(cd -- "$fixture" && pwd -P)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin"
cat >"$fixture/bin/netron" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$TRACE"
exit "${TOOL_STATUS:-0}"
STUB
chmod +x "$fixture/bin/netron"
export PATH="$fixture/bin:$ROOT/bin:$PATH" TRACE="$fixture/args"
printf 'model fixture' >"$fixture/model with spaces.onnx"

bash "$ROOT/bin/omarchy-launch-netron" "$fixture/model with spaces.onnx" --port 8081 >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[0]} == "--host" && ${args[1]} == "127.0.0.1" && ${args[3]} == "8081" && ${args[4]} == "--browse" && ${args[5]} == "$fixture/model with spaces.onnx" ]] || fail "Netron gets the literal model and loopback port"
bash "$ROOT/bin/omarchy-launch-netron" --no-browser "$fixture/model with spaces.onnx" >/dev/null
mapfile -d '' -t args <"$TRACE"
(( ${#args[@]} == 5 )) && [[ ${args[4]} == "$fixture/model with spaces.onnx" ]] || fail "headless Netron omits browser launch"
pass "Netron gets the local model as one argument and opens a browser only when requested"

rm "$TRACE"
touch "$fixture/empty.onnx"
for input in "$fixture/missing" "$fixture/empty.onnx" "$fixture" 'https://remote.invalid/model.onnx'; do
  if bash "$ROOT/bin/omarchy-launch-netron" "$input" >/dev/null 2>&1; then fail "invalid models are rejected"; fi
done
if bash "$ROOT/bin/omarchy-launch-netron" "$fixture/model with spaces.onnx" --port 0 >/dev/null 2>&1; then fail "invalid port is rejected"; fi
[[ ! -e $TRACE ]] || fail "invalid input never starts Netron"
pass "missing, empty, directory and remote inputs are refused before launch"

status=0
TOOL_STATUS=7 bash "$ROOT/bin/omarchy-launch-netron" "$fixture/model with spaces.onnx" >/dev/null || status=$?
(( status == 7 )) || fail "Netron errors reach the caller"
pass "Netron errors reach the caller"
