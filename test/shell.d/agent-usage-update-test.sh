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
require_command flock

TEST_HOME="$TEST_HOME" FAKE_OMARCHY="$FAKE_OMARCHY" python3 - <<'PY'
import json
import os
import subprocess
import time
from pathlib import Path

home = Path(os.environ['TEST_HOME'])
fake = Path(os.environ['FAKE_OMARCHY'])
updater = Path(os.environ['ROOT']) / 'bin/omarchy-agent-usage-update'
collector = fake / 'bin/omarchy-agent-usage-racy'
collector.write_text('''#!/bin/bash
touch "$STARTED"
if [[ -n $WAIT_FOR ]]; then
  while [[ ! -e $WAIT_FOR ]]; do sleep .02; done
fi
printf '%s\\n' "$RECORD"
exit "${COLLECT_EXIT:-0}"
''')
collector.chmod(0o755)
env = {**os.environ, 'HOME': str(home), 'OMARCHY_PATH': str(fake), 'XDG_STATE_HOME': ''}
usage_dir = home / '.local/state/omarchy/agents/usage'
def published_record():
  record = json.loads((usage_dir / 'racy.json').read_text())
  sequence = record.pop('_collectionSequence')
  assert isinstance(sequence, int) and sequence > 0
  return record

# A published service error is authoritative too: an older success must not
# undo a newer sign-out. Only a hard failure to emit a record permits fallback.
good_old = {'id': 'racy', 'limits': [{'percent': .1}]}
good_new = {'id': 'racy', 'limits': [{'percent': .8}], 'usageStatusText': ''}
error = {'id': 'racy', 'limits': [], 'usageStatusText': 'sign-in required'}
for index, (old, new) in enumerate([(good_old, good_new), (error, good_new), (good_old, error)]):
  started = home / f'started-{index}'
  release = home / f'release-{index}'
  older = subprocess.Popen([str(updater), 'racy'], env={**env, 'STARTED': str(started), 'WAIT_FOR': str(release), 'RECORD': json.dumps(old)},
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  try:
    deadline = time.monotonic() + 5
    while not started.exists() and older.poll() is None and time.monotonic() < deadline:
      time.sleep(.02)
    assert started.exists(), 'older collector started'
    subprocess.run([str(updater), 'racy'], env={**env, 'STARTED': str(home / 'newer-started'), 'WAIT_FOR': '', 'RECORD': json.dumps(new)},
                   capture_output=True, text=True, check=True, timeout=5)
    assert published_record() == new
  finally:
    release.touch()
    stdout, stderr = older.communicate(timeout=5)
  assert older.returncode == 0, stderr
  assert published_record() == new, 'older completion replaced newer data'
  assert sorted(p.name for p in usage_dir.glob('.racy.*')) == ['.racy.lock', '.racy.sequence'], 'temporary records are cleaned up'
print('ok - older updates cannot overwrite a newer valid record, including sign-out errors')

for index, failed in enumerate([{'RECORD': 'not json', 'COLLECT_EXIT': '0'},
                                {'RECORD': '{}\n{}', 'COLLECT_EXIT': '0'},
                                {'RECORD': '{}', 'COLLECT_EXIT': '1'}]):
  started = home / f'failure-started-{index}'
  release = home / f'failure-release-{index}'
  good = {'id': 'racy', 'limits': [{'percent': .4}]}
  older = subprocess.Popen([str(updater), 'racy'], env={**env, 'STARTED': str(started), 'WAIT_FOR': str(release), 'RECORD': json.dumps(good)},
                           stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
  try:
    deadline = time.monotonic() + 5
    while not started.exists() and older.poll() is None and time.monotonic() < deadline:
      time.sleep(.02)
    assert started.exists()
    result = subprocess.run([str(updater), 'racy'], env={**env, 'STARTED': str(home / 'failure-newer'), 'WAIT_FOR': '', **failed},
                            capture_output=True, text=True, timeout=5)
    assert result.returncode != 0, 'hard collector failures are reported'
  finally:
    release.touch()
    stdout, stderr = older.communicate(timeout=5)
  assert older.returncode == 0, stderr
  assert published_record() == good, 'a failed newer request suppressed a valid in-flight result'
print('ok - failed collectors do not cancel valid in-flight publications')
PY
