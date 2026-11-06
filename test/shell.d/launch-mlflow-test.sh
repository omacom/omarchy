#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

fixture=$(mktemp -d)
fixture=$(cd -- "$fixture" && pwd -P)
trap 'rm -rf "$fixture"' EXIT
mkdir -p "$fixture/bin" "$fixture/local runs"
cat >"$fixture/bin/mlflow" <<'STUB'
#!/bin/bash
printf '%s\0' "$@" >"$TRACE"
exit "${TOOL_STATUS:-0}"
STUB
chmod +x "$fixture/bin/mlflow"
export PATH="$fixture/bin:$ROOT/bin:$PATH" TRACE="$fixture/args"

bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/local runs" --port 5001 >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[0]} == "server" && ${args[2]} == "$fixture/local runs" && ${args[4]} == "$fixture/local runs" && ${args[5]} == "--no-serve-artifacts" && ${args[7]} == "127.0.0.1" && ${args[9]} == "5001" ]] || fail "MLflow receives a literal local store with loopback serving"
pass "MLflow uses the selected local store for tracking and registry without an artifact proxy"

printf 'SQLite format 3\0' >"$fixture/experiment data.db"
bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/experiment data.db" >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[2]} == "sqlite:///$fixture/experiment%20data.db" ]] || fail "SQLite path becomes an escaped absolute SQLite URI"
printf 'SQLite format 3\0' >"$fixture/study?phase=1#100%.db"
bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/study?phase=1#100%.db" >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[2]} == "sqlite:///$fixture/study%3Fphase%3D1%23100%25.db" ]] || fail "SQLite filename characters cannot become URI options"
pass "SQLite paths with spaces and URL characters address the intended database"

rm "$TRACE"
printf 'valuable data' >"$fixture/not a database"
for input in "$fixture/missing" "$fixture/not a database" 'https://remote.invalid'; do
  if bash "$ROOT/bin/omarchy-launch-mlflow" "$input" >/dev/null 2>&1; then fail "invalid stores are rejected"; fi
done
if bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/local runs" --port 65536 >/dev/null 2>&1; then fail "invalid port is rejected"; fi
[[ ! -e $TRACE && $(cat "$fixture/not a database") == "valuable data" ]] || fail "invalid stores stay untouched"
pass "missing, remote and non-database inputs are refused without touching their contents"

status=0
TOOL_STATUS=7 bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/local runs" >/dev/null || status=$?
(( status == 7 )) || fail "MLflow errors reach the caller"
pass "MLflow errors reach the caller"
