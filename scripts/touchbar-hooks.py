#!/usr/bin/python3
"""Preserve edited hooks and remove only exact installed/legacy wrappers."""
import os
from pathlib import Path
import stat
import sys
import tempfile

home = Path.home()
state = home / '.local/state/omarchy/touchbar'
events = ('font-set', 'post-boot')
# Historical bytes are intentional: recognize pkgrel 2 after its package files
# have gone, without treating custom scripts containing its path as owned.
legacy = b'''#!/bin/bash
# Omarchy passes the selected family to font-set; post-boot resolves the current one.
script="/usr/share/omarchy/shell/plugins/touchbar/sync-font.sh"
[[ -f $script ]] || exit 0
/usr/bin/python3 "${script%/*}/hardware.py" || exit 0
exec /usr/bin/bash "$script" "$@"
'''

def regular_bytes(path):
    try:
        descriptor = os.open(path, os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW)
    except FileNotFoundError:
        return None
    with os.fdopen(descriptor, 'rb') as source:
        if not stat.S_ISREG(os.fstat(source.fileno()).st_mode):
            raise ValueError(f'Refusing a non-regular hook: {path}')
        return source.read(65537)


def safe_parents(path):
    current = path.parent
    while current != home:
        if current.is_symlink():
            raise ValueError(f'Refusing a symlinked hook/state directory: {current}')
        current = current.parent


def atomic(path, data, mode):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(dir=path.parent, delete=False) as output:
            temporary = Path(output.name)
            os.fchmod(output.fileno(), mode)
            output.write(data)
        os.replace(temporary, path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


try:
    remove = sys.argv[1:] == ['--uninstall']
    if not remove and len(sys.argv) != 2:
        raise ValueError('Usage: touchbar-hooks.py SOURCE | --uninstall')
    expected = None if remove else regular_bytes(Path(sys.argv[1]))
    if not remove and (expected is None or len(expected) > 65536):
        raise ValueError('Invalid packaged font hook')
    # Preflight BOTH hooks before mutating either. Symlinks/FIFOs are refused,
    # never followed, backed up into an active hook directory, or overwritten.
    records = []
    for event in events:
        path = home / f'.config/omarchy/hooks/{event}.d/90-touchbar-font'
        record = state / f'{event}.hook'
        safe_parents(path)
        safe_parents(record)
        try:
            existing = regular_bytes(path)
        except (OSError, ValueError):
            if not remove:
                raise
            existing = None  # Preserve unsafe/custom hooks while cleaning others.
        try:
            installed = regular_bytes(record)
        except (OSError, ValueError):
            if not remove:
                raise
            installed = None
        records.append((event, path, record, existing, installed))
    for event, path, record, existing, installed in records:
        if remove:
            if existing is not None and len(existing) <= 65536 and (existing == installed or existing == legacy):
                path.unlink()
            if installed is not None and len(installed) <= 65536:
                record.unlink()
        else:
            if existing is not None and existing != expected:
                backups = state / 'backups' / event
                safe_parents(backups / 'hook')
                backups.mkdir(parents=True, exist_ok=True)
                descriptor, name = tempfile.mkstemp(prefix='90-touchbar-font-', dir=backups)
                os.close(descriptor)
                os.replace(path, name)
                print(f'Previous {event} hook retained at {name}')
            if existing != expected:
                atomic(path, expected, 0o755)
            atomic(record, expected, 0o600)
except (OSError, ValueError) as error:
    sys.exit(str(error))
