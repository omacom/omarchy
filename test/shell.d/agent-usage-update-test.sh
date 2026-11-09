#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq

TEST_HOME=$(mktemp -d)
FAKE_OMARCHY=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$FAKE_OMARCHY"' EXIT

mkdir -p "$FAKE_OMARCHY/bin" "$FAKE_OMARCHY/shell/plugins/agents"
cp "$ROOT/shell/plugins/agents/runner.py" "$FAKE_OMARCHY/shell/plugins/agents/"

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-good" <<'EOF'
#!/bin/bash
echo '{"schemaVersion":1,"id":"good","name":"Good Agent","totalPrompts":3}'
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-noisy" <<'EOF'
#!/bin/bash
echo "this is not json"
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-skipped" <<'EOF'
#!/bin/bash
echo '{"id":"skipped"}'
EOF

# The updater itself lives in the same namespace as the collectors it globs.
cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-update" <<'EOF'
#!/bin/bash
echo '{"id":"update"}'
EOF

chmod +x "$FAKE_OMARCHY/bin/"omarchy-agent-usage-*

usage_dir="$TEST_HOME/.local/state/omarchy/agents/usage"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --except skipped 2>/dev/null && fail "update reports a failing collector"
pass "update reports a failing collector"

[[ $(jq -r '.name' "$usage_dir/good.json") == "Good Agent" ]] ||
  fail "update writes each collector's record to the usage directory"
pass "update writes each collector's record to the usage directory"

[[ ! -e $usage_dir/noisy.json ]] ||
  fail "update refuses records that are not valid JSON"
pass "update refuses records that are not valid JSON"

[[ ! -e $usage_dir/skipped.json ]] ||
  fail "update skips agents excluded with --except"
pass "update skips agents excluded with --except"

[[ ! -e $usage_dir/update.json ]] ||
  fail "update does not treat itself as a collector"
pass "update does not treat itself as a collector"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" skipped 2>/dev/null ||
  fail "update succeeds when the requested collectors all pass"
pass "update succeeds when the requested collectors all pass"

[[ -e $usage_dir/skipped.json && ! -e $usage_dir/noisy.json ]] ||
  fail "update with agent arguments only runs the named collectors"
pass "update with agent arguments only runs the named collectors"

# Python collectors share one start of Python and one import of the shared
# module: the refresh forks them from a process that already loaded it,
# instead of starting Python once per collector.
SHARED_OMARCHY=$(mktemp -d)
SHARED_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$FAKE_OMARCHY" "$SHARED_OMARCHY" "$SHARED_HOME"' EXIT
mkdir -p "$SHARED_OMARCHY/bin" "$SHARED_OMARCHY/shell/plugins/agents"
cp "$ROOT/shell/plugins/agents/runner.py" "$SHARED_OMARCHY/shell/plugins/agents/"
cat >"$SHARED_OMARCHY/shell/plugins/agents/collectors.py" <<'EOF2'
import os
with open(os.path.join(os.environ["HOME"], "imports"), "a") as log:
  log.write("collectors\n")
def preload_shared():
  with open(os.path.join(os.environ["HOME"], "imports"), "a") as log:
    log.write("preload\n")
EOF2
for agent in one two three broken; do
  cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-$agent" <<EOF2
#!/usr/bin/python3
import json, os, sys
sys.dont_write_bytecode = True
sys.path.insert(0, os.path.join(os.environ["OMARCHY_PATH"], "shell", "plugins", "agents"))
import collectors
if "$agent" == "broken":
  raise RuntimeError("collector bug")
print(json.dumps({"id": "$agent", "argv": sys.argv[1:]}))
EOF2
done
# A collector leaves Python the way a script does: its non-daemon threads
# finish, then its exit handlers run, with the script still __main__.
cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-late" <<'EOF2'
#!/usr/bin/python3
import atexit, json, threading, time
AGENT = "late"
DONE = False
def record():
  import __main__
  print(json.dumps({"id": __main__.AGENT, "done": __main__.DONE}))
atexit.register(record)
def late():
  global DONE
  time.sleep(0.2)
  DONE = True
threading.Thread(target=late).start()
EOF2
# One that closes its stdout and then waits for another's record: the
# refresh writes that record meanwhile, as each collect() did on its own.
cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-waiter" <<'EOF2'
#!/usr/bin/python3
import os, sys, time
print('{"id": "waiter"}', flush=True)
os.close(1)
record = os.path.join(os.environ["HOME"], ".local/state/omarchy/agents/usage/quick.json")
for _ in range(50):
  if os.path.exists(record):
    sys.exit(0)
  time.sleep(0.1)
sys.exit(1)
EOF2
cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-quick" <<'EOF2'
#!/usr/bin/python3
import time
time.sleep(0.5)
print('{"id": "quick"}')
EOF2
# A shell collector gets SIGPIPE as a shell starts it, and its output is
# taken as $(...) takes it, NUL bytes dropped.
cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-piped" <<'EOF2'
#!/bin/bash
set -o pipefail
yes | head -n 1 >/dev/null
printf '{"status": %d, "id": "pi\0ped"}\n' "$?"
EOF2
# Each runs as the background job collect() was: stdin from /dev/null,
# SIGINT ignored. And it fails with the status Python gives a huge exit.
cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-job" <<'EOF2'
#!/usr/bin/python3
import json, signal, sys
print(json.dumps({"stdin": sys.stdin.read(), "sigint": signal.getsignal(signal.SIGINT) == signal.SIG_IGN}))
EOF2
cat >"$SHARED_OMARCHY/bin/omarchy-agent-usage-huge" <<'EOF2'
#!/usr/bin/python3
import sys
print('{"id": "huge"}')
sys.exit(2**63)
EOF2
chmod +x "$SHARED_OMARCHY/bin/"omarchy-agent-usage-*
shared_usage="$SHARED_HOME/.local/state/omarchy/agents/usage"
mkdir -p "$shared_usage"
echo '{"id":"broken","kept":true}' >"$shared_usage/broken.json"

HOME="$SHARED_HOME" OMARCHY_PATH="$SHARED_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --force 2>"$SHARED_HOME/stderr" &&
  fail "update reports a Python collector that raises"
pass "update reports a Python collector that raises"

[[ $(grep -c collectors "$SHARED_HOME/imports") == 1 && $(grep -c preload "$SHARED_HOME/imports") == 1 ]] ||
  fail "update imports the shared collector module once per refresh ($(grep -c collectors "$SHARED_HOME/imports") imports)"
pass "update imports the shared collector module once per refresh"

[[ $(jq -c . "$shared_usage/two.json") == '{"id":"two","argv":["--force"]}' ]] ||
  fail "update runs each Python collector with its own arguments and record"
pass "update runs each Python collector with its own arguments and record"

if [[ $(jq -c . "$shared_usage/broken.json") != '{"id":"broken","kept":true}' ]] ||
  ! grep -q "broken collector failed" "$SHARED_HOME/stderr"; then
  fail "update keeps the last record of a collector that raises"
fi
pass "update keeps the last record of a collector that raises"

[[ $(jq -c . "$shared_usage/late.json" 2>/dev/null) == '{"id":"late","done":true}' ]] ||
  fail "update waits for a collector's threads and runs its exit handlers"
pass "update waits for a collector's threads and runs its exit handlers"

# A record that can't be written fails that collector, not the refresh.
chmod 555 "$shared_usage"
HOME="$SHARED_HOME" OMARCHY_PATH="$SHARED_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" one two 2>"$SHARED_HOME/stderr" &&
  fail "update reports each collector whose record it can't write"
chmod 755 "$shared_usage"
if ! grep -q "one collector failed" "$SHARED_HOME/stderr" ||
  ! grep -q "two collector failed" "$SHARED_HOME/stderr" ||
  grep -q Traceback "$SHARED_HOME/stderr"; then
  fail "update reports each collector whose record it can't write"
fi
pass "update reports each collector whose record it can't write"

[[ $(jq -c . "$shared_usage/waiter.json" 2>/dev/null) == '{"id":"waiter"}' && -e $shared_usage/quick.json ]] ||
  fail "update writes other records while a collector that closed its stdout runs on"
pass "update writes other records while a collector that closed its stdout runs on"

# The same where the kernel gives no pidfd: the exits are polled instead.
mkdir -p "$SHARED_HOME/no-pidfd"
echo 'import os; del os.pidfd_open' >"$SHARED_HOME/no-pidfd/sitecustomize.py"
rm -f "$shared_usage/waiter.json" "$shared_usage/quick.json"
HOME="$SHARED_HOME" OMARCHY_PATH="$SHARED_OMARCHY" XDG_STATE_HOME="" PYTHONPATH="$SHARED_HOME/no-pidfd" \
  "$ROOT/bin/omarchy-agent-usage-update" waiter quick 2>/dev/null
[[ $(jq -c . "$shared_usage/waiter.json" 2>/dev/null) == '{"id":"waiter"}' && -e $shared_usage/quick.json ]] ||
  fail "update writes other records while a collector that closed its stdout runs on, without pidfds"
pass "update writes other records while a collector that closed its stdout runs on, without pidfds"

[[ $(jq -c . "$shared_usage/piped.json" 2>/dev/null) == '{"status":141,"id":"piped"}' ]] ||
  fail "update runs a shell collector with SIGPIPE and takes its output as \$(...) does ($(cat "$shared_usage/piped.json" 2>/dev/null))"
pass "update runs a shell collector with SIGPIPE and takes its output as \$(...) does"

# The shared reads pay off only when several collectors rescan: not for one
# collector, and not for --limits-only, which mostly reuses its scans.
rm -f "$SHARED_HOME/imports"
HOME="$SHARED_HOME" OMARCHY_PATH="$SHARED_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" --limits-only one two 2>/dev/null
HOME="$SHARED_HOME" OMARCHY_PATH="$SHARED_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" one 2>/dev/null
[[ $(grep -c collectors "$SHARED_HOME/imports") == 2 && $(grep -c preload "$SHARED_HOME/imports") == 0 ]] ||
  fail "update reads the shared history only when several collectors rescan"
pass "update reads the shared history only when several collectors rescan"

rm -f "$shared_usage/huge.json"
printf 'typed\n' | HOME="$SHARED_HOME" OMARCHY_PATH="$SHARED_OMARCHY" XDG_STATE_HOME="" \
  "$ROOT/bin/omarchy-agent-usage-update" job huge 2>"$SHARED_HOME/stderr"
[[ $(jq -c . "$shared_usage/job.json" 2>/dev/null) == '{"stdin":"","sigint":true}' ]] ||
  fail "update runs collectors as background jobs, stdin empty and SIGINT ignored ($(cat "$shared_usage/job.json" 2>/dev/null))"
pass "update runs collectors as background jobs, stdin empty and SIGINT ignored"
if [[ -e $shared_usage/huge.json ]] || ! grep -q "huge collector failed" "$SHARED_HOME/stderr"; then
  fail "update fails a collector whose exit status is past a C long long"
fi
pass "update fails a collector whose exit status is past a C long long"
