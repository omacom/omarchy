#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT" <<'PYTEST'
import os
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(sys.argv[1])
migration = root / 'migrations/1789164756.sh'
# Execute the actual migration preflight up to its first mutation/setup step.
text = migration.read_text()
preflight = text.split('migration_uid=$(id -u)', 1)[0]
with tempfile.TemporaryDirectory() as directory:
    work = Path(directory)
    preflight_path = work / 'preflight'
    preflight_path.write_text(preflight + '\necho guard-passed\n')
    for name in ('pacman', 'systemctl', 'id'):
        command = work / name
        command.write_text('''#!/bin/bash
set -eu
case "${0##*/}" in
  id) echo 1000 ;;
  systemctl)
    if [[ $1 == --user ]]; then exit 0; fi
    [[ $TEST_LEGACY == "$1" ]] ;;
  pacman)
    [[ $TEST_DB != broken ]] || exit 2
    if [[ $* == '-Qq once-bin' ]]; then
      [[ $TEST_ONCE != missing ]] || exit 1
      echo "$TEST_ONCE"
    elif [[ $* == '-Qq docker' ]]; then
      echo podman-docker
    fi ;;
esac
''')
        command.chmod(0o755)
    for provider in ('missing', 'once', 'once-bin', 'custom-once'):
        for legacy in ('none', 'is-active', 'is-enabled'):
            env = dict(os.environ, PATH=f'{work}:/usr/bin', TEST_ONCE=provider,
                       TEST_LEGACY=legacy, TEST_DB='available')
            result = subprocess.run(['bash', '-euo', 'pipefail', str(preflight_path)],
                                    env=env, capture_output=True, text=True)
            allowed = provider in ('missing', 'once') and legacy == 'none'
            assert (result.returncode == 0) == allowed, (provider, legacy, result)
            assert ('guard-passed' in result.stdout) == allowed, (provider, legacy, result)
            if not allowed:
                assert 'Legacy ONCE' in result.stderr, result
    env.update(TEST_ONCE='missing', TEST_LEGACY='none', TEST_DB='broken')
    result = subprocess.run(['bash', '-euo', 'pipefail', str(preflight_path)],
                            env=env, capture_output=True, text=True)
    assert result.returncode != 0 and 'guard-passed' not in result.stdout, result
print('ok - rootless ONCE providers pass migration while legacy managers and failed package queries block it')
PYTEST
