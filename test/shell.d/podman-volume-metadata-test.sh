#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

python3 - <<'PY'
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
spec = importlib.util.spec_from_file_location('manifest', root / 'default/podman/volume-manifest.py')
manifest = importlib.util.module_from_spec(spec)
spec.loader.exec_module(manifest)
with tempfile.TemporaryDirectory() as directory:
    source, target = [Path(directory) / name for name in ('source', 'target')]
    source.mkdir(mode=0o775)
    source.chmod(0o775)
    target.mkdir(mode=0o755)
    payload = source / 'data'
    payload.write_bytes(b'database contents\n')
    payload.chmod(0o640)
    os.link(payload, source / 'hardlink')
    (source / 'symlink').symlink_to('data')
    os.setxattr(payload, 'user.migration', b'preserve-me')
    os.mkfifo(source / 'fifo')
    sparse = source / 'sparse'
    with sparse.open('wb') as output:
        output.seek(8 * 1024 * 1024)
        output.write(b'end')
    timestamp = 1720000000123456789
    for path in source.iterdir():
        os.utime(path, ns=(timestamp, timestamp), follow_symlinks=False)
    os.utime(source, ns=(timestamp, timestamp))
    spec = importlib.util.spec_from_file_location('migration', root / 'default/podman/migrate-databases.py')
    migration = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(migration)
    migration.inspect = lambda *args: {'Mountpoint': str(target)}
    # This fixture owns both trees. Strip only privilege/namespace dispatch;
    # execute the production transfer and verification with real tar/Python.
    def local(args):
        return list(args[1:] if args[0] == 'sudo' else args[2:])
    def run(*args, capture=False):
        result = subprocess.run(local(args), check=True, text=True, capture_output=capture)
        return result.stdout.strip() if capture else None
    def pipe(producer, consumer):
        with subprocess.Popen(local(producer), stdout=subprocess.PIPE) as process:
            result = subprocess.run(local(consumer), stdin=process.stdout)
            process.stdout.close()
            assert process.wait() == 0 and result.returncode == 0
    migration.run = run
    migration.pipe = pipe
    migration.transfer_volume({'Mountpoint': str(source)}, 'fixture-volume')
    expected = manifest.fingerprint(source)
    assert manifest.fingerprint(target) == expected
    assert (target / 'sparse').stat().st_blocks * 512 < (target / 'sparse').stat().st_size
    target.chmod(0o755)
    assert manifest.fingerprint(target) != expected, 'volume root permission change was missed'
    target.chmod(0o775)
    (target / 'data').write_bytes(b'different content!')
    os.utime(target / 'data', ns=(timestamp, timestamp))
    assert manifest.fingerprint(target) != expected, 'content corruption was missed'
print('ok - native volume transfer preserves root mode, timestamps, xattrs, sparse files, links and FIFO')
print('ok - verification detects volume-root permission changes and content corruption')
PY
