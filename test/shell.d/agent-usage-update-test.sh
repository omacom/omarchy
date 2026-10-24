#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq

TEST_HOME=$(mktemp -d)
FAKE_OMARCHY=$(mktemp -d)
trap 'rm -rf "$TEST_HOME" "$FAKE_OMARCHY"' EXIT

mkdir -p "$FAKE_OMARCHY/bin"

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

require_command python3
PYTHONDONTWRITEBYTECODE=1 python3 - "$ROOT" <<'PY'
import json
import os
import sqlite3
import subprocess
import sys
import tempfile
from pathlib import Path

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory() as scratch:
  home = Path(scratch)
  fake = home / "omarchy"
  (fake / "bin").mkdir(parents=True)
  (fake / "bin/omarchy-agent-usage-opencodego").symlink_to(root / "bin/omarchy-agent-usage-opencodego")
  env = dict(os.environ, HOME=str(home), OMARCHY_PATH=str(fake),
             XDG_DATA_HOME=str(home / "data"), XDG_CACHE_HOME=str(home / "cache"),
             XDG_STATE_HOME=str(home / "state"), PI_CODING_AGENT_DIR="", OPENCODE_GO_API_KEY="")
  record = home / "state/omarchy/agents/usage/opencodego.json"
  record.parent.mkdir(parents=True)
  seeded = b'{ "id": "opencodego", "totalPrompts": 91, "limits": [{"percent":0.5}] }\n'
  record.write_bytes(seeded)
  db = home / "data/opencode/opencode.db"
  db.parent.mkdir(parents=True)
  db.write_bytes(b"not sqlite")
  def update():
    return subprocess.run([str(root / "bin/omarchy-agent-usage-update"), "opencodego", "--force"],
                          env=env, capture_output=True)
  failed = update()
  assert failed.returncode != 0, "incomplete collector scan must fail updater"
  assert record.read_bytes() == seeded, "failure must preserve complete record byte-for-byte"
  db.write_bytes(b"")
  with sqlite3.connect(db) as conn:
    conn.execute("CREATE TABLE message (session_id text, data text)")
    conn.execute("INSERT INTO message VALUES (?, ?)", ("recovered", json.dumps({
      "role": "assistant", "providerID": "opencode-go", "tokens": {"input": 5}})))
  recovered = update()
  assert recovered.returncode == 0, recovered.stderr.decode()
  assert json.loads(record.read_bytes())["totalPrompts"] == 1, "successful recovery must publish fresh stats"
PY
[[ $? == 0 ]] || fail "update preserves last-good OpenCode Go record and resumes after scan recovery"
pass "update preserves last-good OpenCode Go record and resumes after scan recovery"
