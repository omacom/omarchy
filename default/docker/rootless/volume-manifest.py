"""Fingerprint a quiesced volume, using the caller's numeric UID/GID namespace."""

import ctypes
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import stat
import sys


@contextmanager
def pinned_root(root):
    root = Path(root)
    descriptor = os.open(root, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        info = os.fstat(descriptor)
        current = root.lstat()
        if (not stat.S_ISDIR(info.st_mode) or current.st_dev != info.st_dev or
                current.st_ino != info.st_ino):
            raise RuntimeError("volume root is not a stable directory")
        yield descriptor, Path(f"/proc/self/fd/{descriptor}"), info.st_dev
    finally:
        os.close(descriptor)


def metadata_identity(info):
    return (
        info.st_dev, info.st_ino, info.st_mode, info.st_uid, info.st_gid,
        info.st_nlink, info.st_size, info.st_mtime_ns, info.st_ctime_ns, info.st_rdev,
    )


def object_identity(info):
    return info.st_dev, info.st_ino, stat.S_IFMT(info.st_mode)


def descriptor_attributes(descriptor):
    return [(name, os.getxattr(descriptor, name).hex())
            for name in sorted(os.listxattr(descriptor))]


def entry_attributes(parent_descriptor, name):
    path = f"/proc/self/fd/{parent_descriptor}/{name}"
    return [(attribute, os.getxattr(path, attribute, follow_symlinks=False).hex())
            for attribute in sorted(os.listxattr(path, follow_symlinks=False))]


def fingerprint_open(root_descriptor, root_device):
    digest = hashlib.sha256()
    hardlinks = {}

    def add_row(info, relative, attributes, contents=None, link=None):
        if info.st_dev != root_device:
            raise RuntimeError("volume contains a nested filesystem")
        # Unix sockets are transient process endpoints; tar does not copy them.
        if stat.S_ISSOCK(info.st_mode):
            return
        row = [str(relative), stat.S_IFMT(info.st_mode), stat.S_IMODE(info.st_mode),
               info.st_uid, info.st_gid, info.st_mtime_ns, attributes]
        if stat.S_ISREG(info.st_mode):
            first_link = hardlinks.setdefault((info.st_dev, info.st_ino), str(relative))
            row += [info.st_size, contents, first_link]
        elif stat.S_ISLNK(info.st_mode):
            row.append(link)
        elif stat.S_ISCHR(info.st_mode) or stat.S_ISBLK(info.st_mode):
            row.append(info.st_rdev)
        digest.update(json.dumps(row, ensure_ascii=True, separators=(',', ':')).encode() + b'\n')

    def visit_directory(descriptor, relative, info):
        add_row(info, relative, descriptor_attributes(descriptor))
        names = sorted(os.listdir(descriptor))
        for name in names:
            visit_entry(descriptor, name, relative / name)
        if sorted(os.listdir(descriptor)) != names:
            raise RuntimeError("volume changed while it was fingerprinted")

    def visit_entry(parent_descriptor, name, relative):
        before = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
        if before.st_dev != root_device:
            raise RuntimeError("volume contains a nested filesystem")
        if stat.S_ISDIR(before.st_mode):
            descriptor = os.open(
                name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                dir_fd=parent_descriptor,
            )
            try:
                opened = os.fstat(descriptor)
                if metadata_identity(opened) != metadata_identity(before):
                    raise RuntimeError("volume changed while it was fingerprinted")
                visit_directory(descriptor, relative, opened)
            finally:
                os.close(descriptor)
        elif stat.S_ISREG(before.st_mode):
            descriptor = os.open(
                name, os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK | os.O_CLOEXEC,
                dir_fd=parent_descriptor,
            )
            try:
                opened = os.fstat(descriptor)
                if metadata_identity(opened) != metadata_identity(before) or not stat.S_ISREG(opened.st_mode):
                    raise RuntimeError("volume changed while it was fingerprinted")
                contents = hashlib.sha256()
                with os.fdopen(os.dup(descriptor), "rb") as source:
                    for block in iter(lambda: source.read(1024 * 1024), b''):
                        contents.update(block)
                after_read = os.fstat(descriptor)
                if metadata_identity(after_read) != metadata_identity(opened):
                    raise RuntimeError("volume changed while it was fingerprinted")
                add_row(opened, relative, descriptor_attributes(descriptor), contents.hexdigest())
            finally:
                os.close(descriptor)
        else:
            link = os.readlink(name, dir_fd=parent_descriptor) if stat.S_ISLNK(before.st_mode) else None
            add_row(before, relative, entry_attributes(parent_descriptor, name), link=link)
        after = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
        if metadata_identity(after) != metadata_identity(before):
            raise RuntimeError("volume changed while it was fingerprinted")

    root_info = os.fstat(root_descriptor)
    visit_directory(root_descriptor, Path('.'), root_info)
    return digest.hexdigest()


def fingerprint(root):
    with pinned_root(root) as (descriptor, _pinned, root_device):
        return fingerprint_open(descriptor, root_device)


def archive(root):
    with pinned_root(root) as (descriptor, pinned, root_device):
        # Read the full tree through the descriptor before tar and reject any
        # nested filesystem. tar keeps the same root pinned and independently
        # refuses to cross a mount that appears during the copy.
        fingerprint_open(descriptor, root_device)
        os.set_inheritable(descriptor, True)
        os.execvpe("/usr/bin/tar", [
            "/usr/bin/tar", "--format=pax", "--numeric-owner", "--sparse",
            "--acls", "--xattrs", "--xattrs-include=*", "--one-file-system",
            "-C", str(pinned), "-cpf", "-", ".",
        ], {"PATH": "/usr/bin", "LC_ALL": "C"})


def clear(root):
    with pinned_root(root) as (root_descriptor, _pinned, root_device):
        def remove(parent_descriptor, name):
            info = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
            if info.st_dev != root_device:
                raise RuntimeError("volume contains a nested filesystem")
            if stat.S_ISDIR(info.st_mode):
                descriptor = os.open(
                    name, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW | os.O_CLOEXEC,
                    dir_fd=parent_descriptor,
                )
                try:
                    opened = os.fstat(descriptor)
                    if metadata_identity(opened) != metadata_identity(info):
                        raise RuntimeError("volume changed while it was cleared")
                    for child in os.listdir(descriptor):
                        remove(descriptor, child)
                finally:
                    os.close(descriptor)
                current = os.stat(name, dir_fd=parent_descriptor, follow_symlinks=False)
                if object_identity(current) != object_identity(info):
                    raise RuntimeError("volume changed while it was cleared")
                os.rmdir(name, dir_fd=parent_descriptor)
            else:
                os.unlink(name, dir_fd=parent_descriptor)

        for child in os.listdir(root_descriptor):
            remove(root_descriptor, child)


def sync_filesystem(root):
    with pinned_root(root) as (descriptor, _pinned, _root_device):
        libc = ctypes.CDLL(None, use_errno=True)
        if libc.syncfs(descriptor) != 0:
            error = ctypes.get_errno()
            raise OSError(error, os.strerror(error), root)


if __name__ == '__main__':
    if sys.argv[1:2] == ["--archive"] and len(sys.argv) == 3:
        archive(sys.argv[2])
    elif sys.argv[1:2] == ["--clear"] and len(sys.argv) == 3:
        clear(sys.argv[2])
    elif sys.argv[1:2] == ["--sync"] and len(sys.argv) == 3:
        sync_filesystem(sys.argv[2])
    elif len(sys.argv) == 2:
        print(fingerprint(sys.argv[1]))
    else:
        raise SystemExit("usage: volume-manifest.py [--archive|--clear|--sync] ROOT")
