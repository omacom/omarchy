"""Fingerprint a quiesced volume, using the caller's numeric UID/GID namespace."""

import hashlib
import json
import os
from pathlib import Path
import stat
import sys


def fingerprint(root):
    digest = hashlib.sha256()
    hardlinks = {}

    def visit(path, relative):
        info = path.lstat()
        # Unix sockets are transient process endpoints; tar does not copy them.
        if stat.S_ISSOCK(info.st_mode):
            return
        attributes = [(name, os.getxattr(path, name, follow_symlinks=False).hex())
                      for name in sorted(os.listxattr(path, follow_symlinks=False))]
        row = [str(relative), stat.S_IFMT(info.st_mode), stat.S_IMODE(info.st_mode),
               info.st_uid, info.st_gid, info.st_mtime_ns, attributes]
        if stat.S_ISREG(info.st_mode):
            contents = hashlib.sha256()
            with path.open('rb') as source:
                for block in iter(lambda: source.read(1024 * 1024), b''):
                    contents.update(block)
            first_link = hardlinks.setdefault((info.st_dev, info.st_ino), str(relative))
            row += [info.st_size, contents.hexdigest(), first_link]
        elif stat.S_ISLNK(info.st_mode):
            row.append(os.readlink(path))
        elif stat.S_ISCHR(info.st_mode) or stat.S_ISBLK(info.st_mode):
            row.append(info.st_rdev)
        digest.update(json.dumps(row, ensure_ascii=True, separators=(',', ':')).encode() + b'\n')
        if stat.S_ISDIR(info.st_mode):
            for child in sorted(path.iterdir(), key=lambda item: item.name):
                visit(child, relative / child.name)

    visit(Path(root), Path('.'))
    return digest.hexdigest()


if __name__ == '__main__':
    print(fingerprint(sys.argv[1]))
