#!/bin/bash
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command python3
python3 - "$ROOT" <<'PY'
from pathlib import Path
import os
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix='agent-desktops-integration-') as temporary:
  directory = Path(temporary)
  for command in ('omarchy-pkg-add', 'omarchy-pkg-drop', 'agent-desktops', 'omarchy-notification-send'):
    path = directory / command
    path.write_text('#!/bin/bash\nprintf "%s\\n" "' + command + ' $*" >> "$CALLS"\nif [[ "' + command + '" == "agent-desktops" && ${FAIL_SETUP:-0} == 1 ]]; then exit 1; fi\n')
    path.chmod(0o755)
  translate = directory / 'omarchy-i18n'
  translate.write_text('#!/bin/bash\nprintf \"%s\\n\" \"$1\"\n')
  translate.chmod(0o755)
  calls = directory / 'calls'
  env = {**os.environ, 'PATH': str(directory) + ':' + os.environ['PATH'], 'CALLS': str(calls)}
  install = root / 'bin/omarchy-install-ai-agent-desktop'
  remove = root / 'bin/omarchy-remove-ai-agent-desktop'
  result = subprocess.run([str(install), '--monitor', 'DP-1', '--port', '17873', '--no-start'], env=env, capture_output=True, text=True)
  assert result.returncode == 0, result.stderr
  entries = calls.read_text().splitlines()
  assert entries[:2] == ['omarchy-pkg-add agent-desktops', 'agent-desktops setup --monitor DP-1 --port 17873 --no-start'], entries
  calls.unlink()
  result = subprocess.run([str(remove)], env=env, capture_output=True, text=True)
  assert result.returncode == 0, result.stderr
  assert calls.read_text().splitlines() == ['agent-desktops remove', 'omarchy-pkg-drop agent-desktops']
  calls.unlink()
  failed = {**env, 'FAIL_SETUP': '1'}
  assert subprocess.run([str(install)], env=failed, capture_output=True).returncode != 0
  assert 'omarchy-notification-send' not in calls.read_text()
  calls.unlink()
  assert subprocess.run([str(remove)], env=failed, capture_output=True).returncode != 0
  assert 'omarchy-pkg-drop' not in calls.read_text()
PY
pass "agent desktop integration forwards setup options and only removes the package after successful cleanup"
