#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

resume_monitor="$ROOT/bin/omarchy-system-resume-monitor"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
producer_pid_file="$tmpdir/producer-pid"
mkdir -p "$mock_bin"

# Emits a sleep event, a resume event, then another sleep/resume pair, to
# prove the monitor keeps running rather than exiting after the first line —
# unlike the pre-sleep monitor, this one has to last the life of the shell.
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

echo "$$" >"$PRODUCER_PID_FILE"
printf '   boolean true\n'
printf '   boolean false\n'
printf '   boolean true\n'
printf '   boolean false\n'
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

output_file="$tmpdir/output"
PATH="$mock_bin:$PATH" PRODUCER_PID_FILE="$producer_pid_file" \
  "$resume_monitor" >"$output_file" &
monitor_pid=$!
sleep 0.5
kill "$monitor_pid" 2>/dev/null || true
wait "$monitor_pid" 2>/dev/null || true

mapfile -t lines <"$output_file"

[[ ${#lines[@]} -eq 2 && ${lines[0]} == "resume" && ${lines[1]} == "resume" ]] ||
  fail "resume monitor prints one line per resume, ignoring sleep events" \
    "output: $(cat "$output_file" 2>/dev/null)"
pass "resume monitor prints one line per resume, ignoring sleep events"

# Terminating the monitor must also clean up the dbus-monitor producer instead
# of orphaning it, same contract as the pre-sleep monitor.
rm -f "$producer_pid_file"
cat >"$mock_bin/dbus-monitor" <<'SH'
#!/bin/bash

sleep 0.1
echo "$$" >"$PRODUCER_PID_FILE"
exec sleep 30
SH
chmod +x "$mock_bin/dbus-monitor"

PATH="$mock_bin:$PATH" PRODUCER_PID_FILE="$producer_pid_file" "$resume_monitor" &
monitor_pid=$!

for _ in {1..100}; do
  [[ -s $producer_pid_file ]] && break
  sleep 0.01
done
if [[ ! -s $producer_pid_file ]]; then
  kill "$monitor_pid" 2>/dev/null || true
  wait "$monitor_pid" 2>/dev/null || true
  fail "resume monitor starts its event producer"
fi

producer_pid=$(<"$producer_pid_file")
kill "$monitor_pid"
wait "$monitor_pid" 2>/dev/null || true

if kill -0 "$producer_pid" 2>/dev/null; then
  kill "$producer_pid" 2>/dev/null || true
  fail "resume monitor cleans up its producer when terminated" "producer still running: $producer_pid"
fi
pass "resume monitor cleans up its producer when terminated"

# --consume reads events straight off stdin, the same seam the pre-sleep
# monitor's tests use, so the parsing logic is testable without a real (or
# even mocked) dbus-monitor process.
consume_output=$(printf '   boolean true\n   boolean false\n   garbage\n   boolean false\n' \
  | "$resume_monitor" --consume)
mapfile -t consume_lines <<<"$consume_output"

[[ ${#consume_lines[@]} -eq 2 && ${consume_lines[0]} == "resume" && ${consume_lines[1]} == "resume" ]] ||
  fail "resume monitor --consume emits resume only for boolean false lines" \
    "output: ${consume_output:-<empty>}"
pass "resume monitor --consume emits resume only for boolean false lines"
