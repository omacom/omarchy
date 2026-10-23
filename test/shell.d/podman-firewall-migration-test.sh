#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import os
from pathlib import Path
import tempfile

root = Path(os.environ['ROOT'])
migration = (root / 'migrations/1788886195.sh').read_text()
section = migration.split('# Remove the retired managed block,', 1)[1]
program = section.split("<<'PY'\n", 1)[1].split('\nPY\n', 1)[0]
with tempfile.TemporaryDirectory() as directory:
    # Execute the actual inline repair with only its filesystem root redirected.
    program = program.replace('/etc/ufw', directory)
    paths = [Path(directory) / name for name in ('after.rules', 'after6.rules')]
    before = '*filter\n:administrator-rule - [0:0]\nCOMMIT\n'
    block = '# BEGIN UFW AND DOCKER\n*filter\n:DOCKER-USER - [0:0]\nCOMMIT\n# END UFW AND DOCKER\n'
    after = '# Administrator settings after the managed section\n'
    for path in paths:
        path.write_text(before + block + after)
        path.chmod(0o640)
    exec(program, {})
    for path in paths:
        assert path.read_text() == before + after, path
        assert path.stat().st_mode & 0o777 == 0o640
        backup = path.with_name(path.name + '.before-podman')
        assert backup.read_text() == before + block + after
        assert backup.stat().st_mode & 0o777 == 0o640
    exec(program, {})
    for path in paths:
        assert path.read_text() == before + after
        assert path.with_name(path.name + '.before-podman').read_text() == before + block + after
    paths[1].unlink()
    exec(program, {})
print('ok - both firewall families lose only the managed Docker block, retain backups/modes and tolerate retries or missing IPv6 config')
PY
