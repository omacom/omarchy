#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command setsid

speedtest="$ROOT/bin/omarchy-network-speedtest"
test_tmp=$(mktemp -d)

workers() {
  pgrep -f "^/bin/bash $speedtest $1\$" || true
}

cleanup() {
  local pid
  for pid in $(workers down) $(workers up); do
    kill -KILL "$pid" 2>/dev/null || true
  done
  rm -rf "$test_tmp"
}
trap cleanup EXIT

# Stubs keep the test offline: the route lookup lands on loopback, the fast.com
# API returns fixed targets, and each transfer just takes a moment.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/ip" <<'EOF'
#!/bin/bash
echo "1.1.1.1 dev lo src 127.0.0.1"
EOF
cat >"$test_tmp/bin/curl" <<'EOF'
#!/bin/bash
for arg in "$@"; do
  if [[ $arg == *api.fast.com* ]]; then
    echo '{"targets":[{"url":"https://a.invalid/x"},{"url":"https://b.invalid/x"}]}'
    exit 0
  fi
done
[[ -t 0 ]] || cat >/dev/null
sleep 0.2
EOF
chmod +x "$test_tmp/bin/ip" "$test_tmp/bin/curl"

for direction in down up; do
  PATH="$test_tmp/bin:$ROOT/bin:$PATH" setsid "$speedtest" "$direction" >/dev/null 2>&1 &
  main=$!

  for _ in {1..50}; do
    (( $(workers "$direction" | wc -l) > 1 )) && break
    sleep 0.1
  done
  (( $(workers "$direction" | wc -l) > 1 )) || fail "speedtest $direction starts traffic workers"

  # SIGKILL skips the EXIT trap, as when the shell tears the panel down hard.
  kill -KILL "$main"
  wait "$main" 2>/dev/null || true

  for _ in {1..50}; do
    [[ -z $(workers "$direction") ]] && break
    sleep 0.1
  done

  if [[ -n $(workers "$direction") ]]; then
    fail "speedtest $direction workers exit once the script is killed" "orphaned workers: $(workers "$direction" | xargs)"
  fi
  pass "speedtest $direction workers exit once the script is killed"
done
