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
printf '%s' "${MLFLOW_ALLOW_FILE_STORE:-}" >"$TRACE.environment"
exit "${TOOL_STATUS:-0}"
STUB
chmod +x "$fixture/bin/mlflow"
export PATH="$fixture/bin:$ROOT/bin:$PATH" TRACE="$fixture/args" MLFLOW_ALLOW_FILE_STORE=false

bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/local runs" --port 5001 >/dev/null
mapfile -d '' -t args <"$TRACE"
(( ${#args[@]} == 10 )) && [[ ${args[0]} == "server" && ${args[1]} == "--backend-store-uri" && ${args[2]} == "file://$fixture/local%20runs" && ${args[3]} == "--registry-store-uri" && ${args[4]} == "file://$fixture/local%20runs" && ${args[5]} == "--no-serve-artifacts" && ${args[6]} == "--host" && ${args[7]} == "127.0.0.1" && ${args[8]} == "--port" && ${args[9]} == "5001" ]] || fail "MLflow receives a literal local store with loopback serving"
[[ $(cat "$TRACE.environment") == "true" && $MLFLOW_ALLOW_FILE_STORE == "false" ]] || fail "legacy compatibility is enabled only in the launched process"
mkdir "$fixture/local%20runs?phase#1"
bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/local%20runs?phase#1" >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[2]} == "file://$fixture/local%2520runs%3Fphase%231" ]] || fail "legacy folder names survive URI decoding"
pass "MLflow uses the selected local store for tracking and registry without an artifact proxy"

printf 'SQLite format 3\0' >"$fixture/experiment data.db"
bash "$ROOT/bin/omarchy-launch-mlflow" "$fixture/experiment data.db" >/dev/null
mapfile -d '' -t args <"$TRACE"
[[ ${args[2]} == "sqlite:///$fixture/experiment%20data.db" ]] || fail "SQLite path becomes an escaped absolute SQLite URI"
[[ $(cat "$TRACE.environment") == "false" ]] || fail "SQLite does not enable legacy compatibility"
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
