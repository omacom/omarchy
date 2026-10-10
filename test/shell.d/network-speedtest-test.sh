#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq
require_command pgrep
require_command setsid

speedtest="$ROOT/bin/omarchy-network-speedtest"
test_tmp=$(mktemp -d)
sessions=()

cleanup() {
  local session
  for session in ${sessions+"${sessions[@]}"}; do
    pkill -KILL -s "$session" 2>/dev/null || true
  done
  rm -rf "$test_tmp"
}
trap cleanup EXIT

# Stubs keep the test offline: the route lookup lands on loopback, the fast.com
# API returns three fixed targets, and every transfer acts out $TEST_CURL_MODE.
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/ip" <<'EOF'
#!/bin/bash
echo "1.1.1.1 dev lo src 127.0.0.1"
EOF
cat >"$test_tmp/bin/omarchy-cmd-present" <<'EOF'
#!/bin/bash
exit 0
EOF
cat >"$test_tmp/bin/curl" <<'EOF'
#!/bin/bash
url=${*: -1}
if [[ $url == *api.fast.com* ]]; then
  echo '{"targets":[{"url":"https://a.invalid/x"},{"url":"https://b.invalid/x"},{"url":"https://c.invalid/x"}]}'
  exit 0
fi

# The worker that asked, past the timeout wrapping curl.
worker=$PPID
if [[ $(ps -o comm= -p "$worker") == "timeout" ]]; then
  worker=$(ps -o ppid= -p "$worker" | tr -d ' ')
fi
printf '%s %s\n' "$worker" "$url" >>"$TEST_DIR/requests"

case $TEST_CURL_MODE in
  fail)
    exit 22
    ;;
  stall)
    # Healthy transfers until 6s in, then every endpoint hangs.
    [[ -f $TEST_DIR/started ]] || date +%s >"$TEST_DIR/started"
    if (( $(date +%s) - $(<"$TEST_DIR/started") >= 6 )); then
      touch "$TEST_DIR/stalled"
      exec sleep 60
    fi
    sleep 0.2
    ;;
esac
EOF
chmod +x "$test_tmp/bin/"*

start_speedtest() {
  local direction="$1" mode="$2" dir="$test_tmp/$1-$2"

  mkdir -p "$dir"
  TEST_DIR="$dir" TEST_CURL_MODE="$mode" PATH="$test_tmp/bin:$PATH" \
    setsid "$speedtest" "$direction" >/dev/null 2>&1 &
  sessions+=("$!")
}

# A worker whose request fails moves on to the next endpoint, and does not
# hammer the one that failed.
declare -A failing=()
for direction in down up; do
  start_speedtest "$direction" fail
  failing[$direction]=${sessions[-1]}
done

for direction in down up; do
  main=${failing[$direction]}
  for _ in {1..120}; do
    kill -0 "$main" 2>/dev/null || break
    sleep 0.1
  done
  if kill -0 "$main" 2>/dev/null; then
    fail "speedtest $direction ends by itself when every endpoint fails"
  fi

  requests="$test_tmp/$direction-fail/requests"
  [[ -s $requests ]] || fail "speedtest $direction tries the endpoints"
  repeats=$(sort -s -k1,1 "$requests" | awk '$1 == worker && $2 == url { n++ } { worker = $1; url = $2 } END { print n + 0 }')
  (( repeats == 0 )) || fail "a failed $direction request moves the worker to the next endpoint" "$(sort -s -k1,1 "$requests" | head -20)"
  (( $(wc -l <"$requests") > 8 )) || fail "a $direction worker keeps going after a failed request" "$(<"$requests")"
  (( $(wc -l <"$requests") < 100 )) || fail "a failing $direction endpoint is not retried in a tight loop" "$(wc -l <"$requests") requests"
  pass "a failed $direction request moves the worker to the next endpoint"
done

# SIGKILL skips the EXIT trap, as when the shell tears the panel down hard. The
# workers must still stop on their own, mid-transfer included, near the script's
# 8s cap rather than a whole transfer timeout past it.
started=$SECONDS
start_speedtest down stall
start_speedtest up stall
sleep 2
declare -A killed=([down]=${sessions[-2]} [up]=${sessions[-1]})
kill -KILL "${killed[@]}"
wait "${killed[@]}" 2>/dev/null || true

for direction in down up; do
  session=${killed[$direction]}

  while (( SECONDS - started < 12 )) && pgrep -s "$session" >/dev/null; do
    sleep 0.2
  done

  if pgrep -s "$session" >/dev/null; then
    fail "speedtest $direction traffic stops by itself after the script is killed" "$(pgrep -a -s "$session")"
  fi
  [[ -f $test_tmp/$direction-stall/stalled ]] || fail "speedtest $direction reaches a hung transfer before its deadline"
  pass "speedtest $direction traffic stops by itself after the script is killed"
done
