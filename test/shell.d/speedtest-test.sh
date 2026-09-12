#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$stub_bin/ip" <<'SH'
#!/bin/bash
echo "1.1.1.1 dev lo src 127.0.0.1 uid 1000"
SH

cat >"$stub_bin/curl" <<'SH'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == *"api.fast.com"* ]]; then
    cat <<'JSON'
{"targets":[{"url":"http://127.0.0.1:9/mock1"},{"url":"http://127.0.0.1:9/mock2"}]}
JSON
    exit 0
  fi
done

sleep 0.05
exit 0
SH

chmod +x "$stub_bin"/*

# Run speedtest in background, then kill parent with SIGKILL to simulate abrupt crash / panel teardown
PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-network-speedtest" down >/dev/null 2>&1 &
speedtest_pid=$!

sleep 0.3

child_pids=$(pgrep -P "$speedtest_pid" || true)
[[ -n $child_pids ]] || fail "speedtest workers were spawned"

kill -9 "$speedtest_pid" 2>/dev/null || true
wait "$speedtest_pid" 2>/dev/null || true

# Wait up to 1.5 seconds for workers to detect that parent is gone and terminate
for attempt in {1..15}; do
  survivors=0
  for cpid in $child_pids; do
    if kill -0 "$cpid" 2>/dev/null; then
      survivors=$(( survivors + 1 ))
    fi
  done
  if (( survivors == 0 )); then
    break
  fi
  sleep 0.1
done

leaked_workers=""
for cpid in $child_pids; do
  if kill -0 "$cpid" 2>/dev/null; then
    leaked_workers="$leaked_workers $cpid"
    kill -9 "$cpid" 2>/dev/null || true
  fi
done

[[ -z $leaked_workers ]] || fail "speedtest workers leaked after parent was killed with SIGKILL: $leaked_workers"

pass "speedtest workers terminate when parent process dies abruptly"
