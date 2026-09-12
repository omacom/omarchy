"""Verify that rootful Docker accepts API connections only through its protected Unix socket."""

import json
import os
from pathlib import Path
import re
import socket
import stat
import struct
import sys


EXPECTED_SOCKET = "/run/docker.sock"
INTERNAL_UNIX_SOCKETS = re.compile(
    r"/(?:var/)?run/docker/(?:metrics\.sock|libnetwork/[a-f0-9]+\.sock)"
)
EXPECTED_DAEMON_CONFIG = {
    "log-driver": "json-file",
    "log-opts": {"max-size": "10m", "max-file": "5"},
    # The rootful bridge exposes systemd-resolved on its gateway. RootlessKit
    # supplies the corresponding resolver inside the user network namespace.
    "dns": ["172.17.0.1"],
    "bip": "172.17.0.1/16",
}


def process_start_time(pid, proc=Path("/proc")):
    try:
        process_directory_time = (proc / str(pid)).stat().st_ctime
        process_fields = (proc / str(pid) / "stat").read_text().rsplit(")", 1)[1].split()
        start_ticks = int(process_fields[19])
        boot_line = next(line for line in (proc / "stat").read_text().splitlines()
                         if line.startswith("btime "))
        boot_time = int(boot_line.split()[1])
        ticks_per_second = os.sysconf("SC_CLK_TCK")
    except (IndexError, OSError, StopIteration, ValueError) as error:
        raise RuntimeError("rootful Docker process start time cannot be verified") from error
    if start_ticks <= 0 or boot_time <= 0 or ticks_per_second <= 0:
        raise RuntimeError("rootful Docker process start time is invalid")
    # btime is reported at whole-second precision. The proc directory carries
    # the kernel's finer process-creation timestamp, while the stat fields keep
    # the check tied to the PID's start ticks rather than directory contents.
    return max(process_directory_time, boot_time + start_ticks / ticks_per_second)


def process_socket_inodes(pid, proc=Path("/proc")):
    if not isinstance(pid, int) or pid <= 1:
        raise RuntimeError("rootful Docker has no valid main process")
    inodes = set()
    try:
        descriptors = (proc / str(pid) / "fd").iterdir()
        for descriptor in descriptors:
            try:
                target = os.readlink(descriptor)
            except FileNotFoundError:
                continue
            match = re.fullmatch(r"socket:\[(\d+)]", target)
            if match:
                inodes.add(match.group(1))
    except FileNotFoundError as error:
        raise RuntimeError("rootful Docker process disappeared while its listeners were checked") from error
    return inodes


def unix_listeners(pid, inodes, proc=Path("/proc")):
    listeners = []
    for line in (proc / str(pid) / "net/unix").read_text().splitlines()[1:]:
        fields = line.split(maxsplit=7)
        if (len(fields) >= 7 and fields[3] == "00010000" and fields[4] == "0001" and
                fields[6] in inodes):
            listeners.append(fields[7] if len(fields) == 8 else "")
    return listeners


def has_tcp_listener(pid, inodes, proc=Path("/proc")):
    for table in ("net/tcp", "net/tcp6"):
        for line in (proc / str(pid) / table).read_text().splitlines()[1:]:
            fields = line.split()
            if len(fields) > 9 and fields[3] == "0A" and fields[9] in inodes:
                return True
    return False


def trusted_configuration(pid, config_path, proc=Path("/proc"), filesystem=None,
                          trusted_uid=0):
    if config_path != "/etc/docker/daemon.json":
        raise RuntimeError("rootful Docker uses a custom configuration path")
    root = Path(filesystem) if filesystem is not None else proc / str(pid) / "root"
    try:
        root_flags = os.O_RDONLY | os.O_DIRECTORY
        if filesystem is not None:
            root_flags |= os.O_NOFOLLOW
        root_fd = os.open(root, root_flags)
    except OSError as error:
        raise RuntimeError("rootful Docker mount namespace cannot be opened safely") from error
    descriptors = [root_fd]
    try:
        root_metadata = os.fstat(root_fd)
        if (not stat.S_ISDIR(root_metadata.st_mode) or root_metadata.st_uid != trusted_uid or
                root_metadata.st_mode & 0o022):
            raise RuntimeError("rootful Docker mount namespace has an unsafe root")
        parent_fd = root_fd
        for component in ("etc", "docker"):
            descriptor = os.open(
                component, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW,
                dir_fd=parent_fd,
            )
            descriptors.append(descriptor)
            metadata = os.fstat(descriptor)
            if (not stat.S_ISDIR(metadata.st_mode) or metadata.st_uid != trusted_uid or
                    metadata.st_mode & 0o022):
                raise RuntimeError("rootful Docker configuration has an unsafe parent")
            parent_fd = descriptor
        descriptor = os.open(
            "daemon.json", os.O_RDONLY | os.O_NONBLOCK | os.O_NOFOLLOW, dir_fd=parent_fd,
        )
        descriptors.append(descriptor)
        metadata = os.fstat(descriptor)
        if (not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != trusted_uid or
                metadata.st_mode & 0o022):
            raise RuntimeError("rootful Docker daemon configuration is not trusted")
        with os.fdopen(os.dup(descriptor), "r") as source:
            configured = json.load(source)
        latest = os.fstat(descriptor)
        if ((latest.st_dev, latest.st_ino, latest.st_mode, latest.st_uid,
             latest.st_gid, latest.st_size, latest.st_mtime_ns, latest.st_ctime_ns) !=
                (metadata.st_dev, metadata.st_ino, metadata.st_mode, metadata.st_uid,
                 metadata.st_gid, metadata.st_size, metadata.st_mtime_ns, metadata.st_ctime_ns)):
            raise RuntimeError("rootful Docker daemon configuration changed while it was read")
    except (OSError, json.JSONDecodeError) as error:
        raise RuntimeError("rootful Docker daemon configuration cannot be read safely") from error
    finally:
        for descriptor in reversed(descriptors):
            os.close(descriptor)
    if metadata.st_ctime > process_start_time(pid, proc):
        raise RuntimeError(
            "rootful Docker configuration changed after the daemon started; restart Docker before migration"
        )
    return configured


def daemon_configuration(pid, proc=Path("/proc"), filesystem=None, trusted_uid=0):
    try:
        arguments = (proc / str(pid) / "cmdline").read_bytes().split(b"\0")
        arguments = [argument.decode() for argument in arguments if argument]
        executable = os.readlink(proc / str(pid) / "exe")
    except (FileNotFoundError, PermissionError, UnicodeDecodeError) as error:
        raise RuntimeError("rootful Docker daemon process cannot be inspected") from error
    if (not arguments or arguments[0] != "/usr/bin/dockerd" or
            executable != "/usr/bin/dockerd"):
        raise RuntimeError("rootful Docker does not use the packaged daemon executable")
    hosts = []
    config_path = "/etc/docker/daemon.json"
    index = 1
    while index < len(arguments):
        argument = arguments[index]
        if argument in ("-H", "--host"):
            index += 1
            if index >= len(arguments):
                raise RuntimeError("rootful Docker has an incomplete host option")
            hosts.append(arguments[index])
        elif argument.startswith("-H=") or argument.startswith("--host="):
            hosts.append(argument.split("=", 1)[1])
        elif argument in ("--config-file",):
            index += 1
            if index >= len(arguments):
                raise RuntimeError("rootful Docker has an incomplete config-file option")
            config_path = arguments[index]
        elif argument.startswith("--config-file="):
            config_path = argument.split("=", 1)[1]
        elif argument == "--containerd":
            index += 1
            if index >= len(arguments) or arguments[index] != "/run/containerd/containerd.sock":
                raise RuntimeError("rootful Docker uses a custom containerd service")
        elif argument.startswith("--containerd="):
            if argument.split("=", 1)[1] != "/run/containerd/containerd.sock":
                raise RuntimeError("rootful Docker uses a custom containerd service")
        else:
            # Daemon flags such as --init, --dns, and --default-ulimit can
            # change a container without appearing in docker inspect.
            raise RuntimeError(f"rootful Docker uses an unsupported daemon option: {argument}")
        index += 1

    configured = trusted_configuration(pid, config_path, proc, filesystem, trusted_uid)
    if not isinstance(configured, dict):
        raise RuntimeError("rootful Docker has an invalid daemon configuration")
    file_hosts = configured.get("hosts") or []
    if not isinstance(file_hosts, list) or any(not isinstance(host, str) for host in file_hosts):
        raise RuntimeError("rootful Docker has an invalid hosts configuration")
    if hosts and file_hosts:
        raise RuntimeError("rootful Docker has conflicting host configuration")
    workload_config = {key: value for key, value in configured.items() if key != "hosts"}
    if workload_config != EXPECTED_DAEMON_CONFIG:
        raise RuntimeError(
            "rootful Docker has custom workload defaults; restore Omarchy's daemon.json or migrate containers explicitly"
        )
    return hosts or file_hosts or ["unix:///var/run/docker.sock"]


def configured_hosts(pid, proc=Path("/proc"), filesystem=None, trusted_uid=0):
    return daemon_configuration(pid, proc, filesystem, trusted_uid)


def unix_peer_credentials(path):
    connection = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        connection.connect(path)
        payload = connection.getsockopt(socket.SOL_SOCKET, socket.SO_PEERCRED,
                                        struct.calcsize("3i"))
    except OSError as error:
        raise RuntimeError("rootful Docker API endpoint cannot be identified") from error
    finally:
        connection.close()
    return struct.unpack("3i", payload)


def verify(pid, proc=Path("/proc"), filesystem=None, trusted_uid=0,
           peer_credentials=unix_peer_credentials):
    inodes = process_socket_inodes(pid, proc)
    listeners = unix_listeners(pid, inodes, proc)
    hosts = configured_hosts(pid, proc, filesystem, trusted_uid)
    safe_hosts = (["fd://"], ["unix:///run/docker.sock"], ["unix:///var/run/docker.sock"])
    if (hosts not in safe_hosts or has_tcp_listener(pid, inodes, proc) or
            listeners.count(EXPECTED_SOCKET) != 1 or
            any(path != EXPECTED_SOCKET and not INTERNAL_UNIX_SOCKETS.fullmatch(path)
                for path in listeners)):
        raise RuntimeError("rootful Docker has a custom API listener; remove it before automatic migration")
    endpoint = f"/proc/{pid}/root{EXPECTED_SOCKET}"
    peer_pid, peer_uid, _peer_gid = peer_credentials(endpoint)
    # A daemon-created socket reports dockerd. A systemd-activated socket can
    # report PID 1, whose root-owned endpoint is separately pinned to the
    # verified docker.socket unit by the migration shell.
    if peer_uid != 0 or peer_pid not in (1, pid):
        raise RuntimeError("rootful Docker API endpoint belongs to a different process")
    if peer_pid == 1:
        try:
            peer_executable = os.readlink(proc / "1/exe")
        except OSError as error:
            raise RuntimeError("rootful Docker socket activator cannot be identified") from error
        if peer_executable != "/usr/lib/systemd/systemd":
            raise RuntimeError("rootful Docker API endpoint has an unexpected socket activator")
    return f"unix://{endpoint}"


if __name__ == "__main__":
    if len(sys.argv) != 2 or not sys.argv[1].isdigit():
        raise SystemExit("usage: rootful-listeners.py DOCKER_PID")
    try:
        print(verify(int(sys.argv[1])))
    except (OSError, RuntimeError) as error:
        print(f"Rootful Docker listener verification failed: {error}", file=sys.stderr)
        raise SystemExit(1) from error
