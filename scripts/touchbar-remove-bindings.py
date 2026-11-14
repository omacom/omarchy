#!/usr/bin/python3
"""Remove only the Touch Bar's delimited managed block, preserving user binds."""
import os
from pathlib import Path
import re
import stat
import sys
import tempfile

path = Path(sys.argv[1])
try:
    fd = os.open(path, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK)
except FileNotFoundError:
    sys.exit(0)
with os.fdopen(fd, 'rb') as source:
    info = os.fstat(source.fileno())
    if not stat.S_ISREG(info.st_mode) or info.st_size > 262144:
        sys.exit('Refusing unsafe bindings file')
    text = source.read(262145).decode('utf-8')
pattern = r'(?m)^-- io\.github\.austindixson\.touchbar begin\n.*?^-- io\.github\.austindixson\.touchbar end\n?'
updated = re.sub(pattern, '', text, flags=re.S)
if updated != text:
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode='w', dir=path.parent, delete=False) as output:
            temporary = Path(output.name)
            os.fchmod(output.fileno(), stat.S_IMODE(info.st_mode))
            output.write(updated)
        os.replace(temporary, path)
    finally:
        if temporary:
            temporary.unlink(missing_ok=True)
