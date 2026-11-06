#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

fixture=$(mktemp -d)
fixture=$(cd -- "$fixture" && pwd -P)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin"
cat >"$fixture/bin/marimo" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$TRACE"
exit "${TOOL_STATUS:-0}"
STUB
chmod +x "$fixture/bin/marimo"
export PATH="$fixture/bin:$ROOT/bin:$PATH" TRACE="$fixture/args"
printf 'import marimo\napp = marimo.App()\n' >"$fixture/model study.py"

bash "$ROOT/bin/omarchy-launch-marimo" "$fixture/model study.py" --port 2719 --no-browser >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[0]} == "edit" && ${args[2]} == "127.0.0.1" && ${args[4]} == "2719" && ${args[5]} == "--token" && ${args[6]} == "--no-sandbox" && ${args[7]} == "--skip-update-check" && ${args[8]} == "--headless" && ${args[9]} == "$fixture/model study.py" ]] || fail "marimo receives a literal local notebook with authentication"
pass "marimo opens the selected notebook with loopback, authentication and the active environment"

bash "$ROOT/bin/omarchy-launch-marimo" "$fixture/model study.py" >/dev/null
mapfile -d '' -t args <"$TRACE"
(( ${#args[@]} == 9 )) && [[ ${args[8]} == "$fixture/model study.py" ]] || fail "normal marimo launch leaves browser handling enabled"
pass "normal launch lets marimo open its authenticated browser URL"

rm "$TRACE"
touch "$fixture/empty.py"
for input in "$fixture/missing.py" "$fixture/empty.py" "$fixture" 'https://remote.invalid/notebook.py'; do
  if bash "$ROOT/bin/omarchy-launch-marimo" "$input" >/dev/null 2>&1; then fail "invalid notebooks are rejected"; fi
done
if bash "$ROOT/bin/omarchy-launch-marimo" "$fixture/model study.py" --port 65536 >/dev/null 2>&1; then fail "invalid port is rejected"; fi
[[ ! -e $TRACE ]] || fail "invalid input never starts marimo"
pass "missing, empty, directory and remote inputs are rejected before launch"

status=0
TOOL_STATUS=7 bash "$ROOT/bin/omarchy-launch-marimo" "$fixture/model study.py" >/dev/null || status=$?
(( status == 7 )) || fail "marimo errors reach the caller"
pass "marimo errors reach the caller"
