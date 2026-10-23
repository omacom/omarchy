#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import importlib.util
import os
from pathlib import Path
from types import SimpleNamespace
import tempfile
from unittest.mock import patch

root = Path(os.environ['ROOT'])
spec = importlib.util.spec_from_file_location('subids', root / 'default/podman/allocate-subids.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
account = SimpleNamespace(pw_name='tester', pw_uid=1000, pw_gid=1000)
other = SimpleNamespace(pw_name='high-id', pw_uid=100001, pw_gid=110001)

with tempfile.TemporaryDirectory() as directory:
    work = Path(directory)
    real_open = os.open
    def run(uid_ranges, gid_ranges):
        commands = []
        with patch.object(module.pwd, 'getpwnam', return_value=account), \
             patch.object(module.pwd, 'getpwall', return_value=[account, other]), \
             patch.object(module.grp, 'getgrall', return_value=[SimpleNamespace(gr_gid=120001)]), \
             patch.object(module.os, 'open', side_effect=lambda *args: real_open(work / 'lock', os.O_CREAT | os.O_RDWR, 0o600)), \
             patch.object(module, 'read_ranges', side_effect=[uid_ranges, gid_ranges]), \
             patch.object(module.subprocess, 'run', side_effect=lambda command, **kw: commands.append(command)), \
             patch.object(module.sys, 'argv', ['allocate-subids.py', 'tester']):
            try:
                module.main()
            except ValueError:
                assert not commands, ('unsafe maps modified before refusal', commands)
                raise
        return commands

    commands = run([], [])
    assert commands == [
        ['usermod', '--add-subuids', '100002-165537', 'tester'],
        ['usermod', '--add-subgids', '120002-185537', 'tester'],
    ], commands
    print('ok - allocation excludes host UIDs, groups and unlisted primary groups')
    assert run([('tester', 200000, 65536)], [('1000', 300000, 65536)]) == []
    for uid_ranges, gid_ranges in [
        ([('tester', 100000, 65536)], []),
        ([], [('tester', 100000, 65536)]),
        ([('tester', 200000, 65536), ('other', 220000, 65536)], []),
        ([('1000', 100001, 1)], []),
    ]:
        try:
            run(uid_ranges, gid_ranges)
        except ValueError:
            pass
        else:
            raise AssertionError(('unsafe grant accepted', uid_ranges, gid_ranges))
    print('ok - existing safe grants are idempotent and unsafe grants abort both allocations')
    assert module.allocation(account, [('other', 100000, 65536)], {0, 1000}) == 165536
    assert module.allocation(account, [], {0, 1000, 165536}) == 100000
    assert module.allocation(account, [], {0, 1000, 165535}) == 165536
    path = work / 'subuid'
    for content in ('tester:-1:65536\n', 'tester:100000:0\n', 'tester:4294967294:65536\n'):
        path.write_text(content)
        try:
            module.read_ranges(path)
        except ValueError:
            pass
        else:
            raise AssertionError(('invalid range accepted', content))
    print('ok - range boundaries and malformed grants are validated')
PY
