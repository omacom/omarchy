#!/usr/bin/env python3
"""Event-driven v4l2loopback watcher + 0ms live tuning bridge for Omarchy.

Subscribes to v4l2loopback's V4L2_EVENT_PRI_CLIENT_USAGE kernel push event via
poll(POLLPRI) and emits "active" or "inactive" on stdout whenever any PipeWire
or direct V4L2 consumer starts or stops streaming. Also forwards single-line
live tuning commands from stdin (e.g. "gamma=1.60 contrast=1.05 saturation=1.20")
straight to the relay's Unix datagram socket with zero process spawns.
"""

import ctypes
import errno
import fcntl
import os
import select
import shlex
import signal
import socket
import stat
import struct
import sys

PR_SET_PDEATHSIG = 1
VIDIOC_SUBSCRIBE_EVENT = 0x4020565A
VIDIOC_DQEVENT = 0x80885659
V4L2_EVENT_PRI_CLIENT_USAGE = 0x10E00001
V4L2_EVENT_SUB_FL_SEND_INITIAL = 1

SYS_V4L_DIR = "/sys/devices/virtual/video4linux"


def read_card_label() -> str:
    config_home = os.environ.get("XDG_CONFIG_HOME") or os.path.expanduser("~/.config")
    env_path = os.path.join(config_home, "omarchy", "camera-relay.env")
    try:
        with open(env_path, "r", encoding="utf-8") as fh:
            for raw_line in fh:
                line = raw_line.strip()
                if not line or line.startswith("#") or "=" not in line:
                    continue
                key, val = line.split("=", 1)
                if key.strip() == "CARD_LABEL":
                    parts = shlex.split(val)
                    return parts[0] if parts else "Front Camera"
    except OSError:
        pass
    return "Front Camera"


def find_loopback_device(card_label: str) -> str | None:
    try:
        entries = sorted(os.listdir(SYS_V4L_DIR))
    except OSError:
        return None
    for entry in entries:
        name_path = os.path.join(SYS_V4L_DIR, entry, "name")
        try:
            with open(name_path, "r", encoding="utf-8") as fh:
                if fh.read().strip() == card_label:
                    dev_path = os.path.join("/dev", entry)
                    if os.path.exists(dev_path):
                        return dev_path
        except OSError:
            continue
    return None


def relay_socket_path() -> str:
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR") or f"/run/user/{os.getuid()}"
    return os.environ.get(
        "OMARCHY_CAMERA_RELAY_SOCKET",
        os.path.join(runtime_dir, "omarchy-camera-relay.sock"),
    )


def emit(state: str) -> None:
    sys.stdout.write(state + "\n")
    sys.stdout.flush()


def main() -> int:
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(0))
    signal.signal(signal.SIGINT, lambda *_: sys.exit(0))
    try:
        ctypes.CDLL("libc.so.6").prctl(PR_SET_PDEATHSIG, signal.SIGTERM)
    except OSError:
        pass

    label = read_card_label()
    dev_path = find_loopback_device(label)
    if not dev_path:
        emit("inactive")
        return 0

    try:
        fd = os.open(dev_path, os.O_RDONLY | os.O_NONBLOCK)
    except OSError:
        emit("inactive")
        return 0

    try:
        sub = struct.pack(
            "III5I",
            V4L2_EVENT_PRI_CLIENT_USAGE,
            0,
            V4L2_EVENT_SUB_FL_SEND_INITIAL,
            0,
            0,
            0,
            0,
            0,
        )
        fcntl.ioctl(fd, VIDIOC_SUBSCRIBE_EVENT, sub)
    except OSError:
        os.close(fd)
        emit("inactive")
        return 0

    poller = select.poll()
    poller.register(fd, select.POLLPRI | select.POLLERR | select.POLLHUP)

    stdin_fd = sys.stdin.fileno()
    watch_stdin = False
    try:
        st_mode = os.fstat(stdin_fd).st_mode
        if stat.S_ISFIFO(st_mode) or stat.S_ISSOCK(st_mode):
            os.set_blocking(stdin_fd, False)
            poller.register(stdin_fd, select.POLLIN)
            watch_stdin = True
    except OSError:
        pass

    ctrl_sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    sock_path = relay_socket_path()

    last_state: str | None = None
    event_buf = bytearray(136)
    stdin_buf = b""

    try:
        while True:
            events = poller.poll()
            for ev_fd, mask in events:
                if ev_fd == fd:
                    if mask & (select.POLLERR | select.POLLHUP):
                        if last_state != "inactive":
                            emit("inactive")
                        return 0
                    if mask & select.POLLPRI:
                        while True:
                            try:
                                fcntl.ioctl(fd, VIDIOC_DQEVENT, event_buf)
                            except OSError as exc:
                                if exc.errno in (errno.EAGAIN, errno.ENOENT):
                                    break
                                return 0
                            ev_type = struct.unpack_from("I", event_buf, 0)[0]
                            if ev_type != V4L2_EVENT_PRI_CLIENT_USAGE:
                                continue
                            client_count = struct.unpack_from("I", event_buf, 8)[0]
                            next_state = "active" if client_count > 0 else "inactive"
                            if next_state != last_state:
                                emit(next_state)
                                last_state = next_state
                elif watch_stdin and ev_fd == stdin_fd:
                    if mask & select.POLLIN:
                        try:
                            chunk = os.read(stdin_fd, 4096)
                        except BlockingIOError:
                            chunk = b""
                        except OSError:
                            chunk = b""
                        if chunk:
                            stdin_buf += chunk
                            while b"\n" in stdin_buf:
                                line, stdin_buf = stdin_buf.split(b"\n", 1)
                                payload = line.strip()
                                if payload:
                                    try:
                                        ctrl_sock.sendto(payload, sock_path)
                                    except OSError:
                                        pass
                        elif mask & select.POLLHUP:
                            poller.unregister(stdin_fd)
                            watch_stdin = False
                    elif mask & (select.POLLHUP | select.POLLERR):
                        poller.unregister(stdin_fd)
                        watch_stdin = False
    finally:
        ctrl_sock.close()
        os.close(fd)


if __name__ == "__main__":
    raise SystemExit(main())
