#!/usr/bin/env python3
"""Read and control Shure MV7+ (14ed:1019) onboard DSP over /dev/hidraw."""
import errno
import fcntl
import glob
import json
import os
import select
import struct
import sys
import time

CMD_GET_FEAT = bytes([0x01, 0x02, 0x02])
CMD_SET_FEAT = bytes([0x02, 0x02, 0x02])
CMD_CONFIRM = bytes([0x01, 0x00, 0x00])
RES_GET_FEAT = bytes([0x03, 0x02, 0x02])

# (name, prefix, feat_hi, feat_lo, format, min_val, max_val)
FEATURES = [
    ("auto_level",       0x00, 0x01, 0x85, "u8",      0,    1),
    ("gain_db",          0x00, 0x01, 0x02, "u16x100", 0.0,  36.0),
    ("mute",             0x00, 0x01, 0x04, "u8",      0,    1),
    ("hpf",              0x00, 0x01, 0x06, "u8",      0,    2),
    ("limiter",          0x00, 0x01, 0x51, "u8",      0,    1),
    ("compressor",       0x00, 0x01, 0x5C, "u8",      0,    3),
    ("denoiser",         0x00, 0x01, 0x58, "u8",      0,    1),
    ("popper_stopper",   0x00, 0x03, 0x81, "u8",      0,    1),
    ("tone_pct",         0x00, 0x02, 0x04, "i16",     -100, 100),
    ("reverb_output",    0x00, 0x03, 0x82, "u8",      0,    1),
    ("reverb_type",      0x00, 0x03, 0x83, "u8",      0,    2),
    ("reverb_intensity", 0x00, 0x03, 0x84, "u8",      0,    100),
    ("reverb_monitor",   0x00, 0x03, 0x85, "u8",      0,    1),
    ("mic_level",        0x00, 0x01, 0x86, "u8",      0,    100),
    ("playback_level",   0x03, 0x01, 0x86, "u8",      0,    100),
]

FEATURE_MAP = {f[0]: f for f in FEATURES}


def find_mv7plus(sysfs_glob="/sys/class/hidraw/hidraw*/device/uevent"):
    for uev in sorted(glob.glob(sysfs_glob)):
        try:
            with open(uev, "r", encoding="utf-8", errors="ignore") as f:
                txt = f.read()
        except OSError:
            continue
        if "000014ED:00001019" in txt.upper():
            return "/dev/" + os.path.basename(os.path.dirname(os.path.dirname(uev)))
    return None


def crc16_ansi(data: bytes) -> int:
    crc = 0x0000
    for b in data:
        for _ in range(8):
            crc = ((crc >> 1) ^ 0xA001) if ((crc ^ b) & 1) else (crc >> 1)
            b >>= 1
    return crc


def build_packet(seq: int, hdr: int, cmd: bytes, payload: bytes) -> bytes:
    data_len = 3 + len(payload) + 2
    inner = bytes([0x11, 0x22, seq & 0xFF, hdr, 0x08, data_len, 0x70, data_len]) + cmd + payload
    total_len = len(inner) + 2
    crc = crc16_ansi(inner)
    pkt = bytes([0x01, total_len]) + inner + bytes([(crc >> 8) & 0xFF, crc & 0xFF])
    return pkt.ljust(64, b"\x00")


def parse_response(buf: bytes):
    if len(buf) < 18 or buf[2:4] != b"\x11\x22":
        return None
    total_len = buf[1]
    if total_len < 16 or total_len + 2 > len(buf):
        return None
    inner = buf[2:total_len]
    crc_got = (buf[total_len] << 8) | buf[total_len + 1]
    if crc_got != crc16_ansi(inner):
        return None
    if buf[10:13] != RES_GET_FEAT:
        return None
    return buf[13], (buf[14], buf[15]), buf[16:total_len]


def encode_value(fmt: str, value, min_val, max_val) -> bytes:
    if fmt == "u8":
        iv = max(int(min_val), min(int(max_val), int(round(float(value)))))
        return bytes([iv])
    if fmt == "u16x100":
        fv = max(float(min_val), min(float(max_val), float(value)))
        # Snap to 0.5 dB steps as MV7+ hardware uses
        fv = round(fv * 2.0) / 2.0
        return struct.pack(">H", int(round(fv * 100)))
    if fmt == "i16":
        iv = max(int(min_val), min(int(max_val), int(round(float(value)))))
        return struct.pack(">h", iv)
    raise ValueError(f"unsupported format: {fmt}")


def decode_value(fmt: str, raw: bytes):
    if fmt == "u8":
        return raw[0] if raw else None
    if fmt == "u16x100":
        return round(struct.unpack(">H", raw[:2])[0] / 100.0, 1) if len(raw) >= 2 else None
    if fmt == "i16":
        return struct.unpack(">h", raw[:2])[0] if len(raw) >= 2 else None
    return None


class MV7Plus:
    def __init__(self, path: str):
        self.fd = os.open(path, os.O_RDWR | os.O_NONBLOCK)
        self.seq = 1

    def close(self):
        os.close(self.fd)

    def _next_seq(self) -> int:
        s = self.seq
        self.seq = (self.seq + 1) & 0xFF
        return s

    def drain(self, timeout_ms: int = 12):
        while True:
            r, _, _ = select.select([self.fd], [], [], timeout_ms / 1000.0)
            if not r:
                break
            try:
                os.read(self.fd, 64)
            except BlockingIOError:
                break

    def get_feat(self, pfx: int, feat):
        self.drain(5)
        pkt = build_packet(self._next_seq(), 0x03, CMD_GET_FEAT, bytes([pfx, feat[0], feat[1]]))
        os.write(self.fd, pkt)
        deadline = time.monotonic() + 0.35
        while time.monotonic() < deadline:
            r, _, _ = select.select([self.fd], [], [], 0.04)
            if not r:
                continue
            try:
                buf = os.read(self.fd, 64)
            except BlockingIOError:
                continue
            parsed = parse_response(buf)
            if parsed and parsed[0] == pfx and parsed[1] == feat:
                return parsed[2]
        return None

    def set_feat(self, pfx: int, feat, val: bytes):
        self.drain(5)
        pkt = build_packet(self._next_seq(), 0x00, CMD_SET_FEAT, bytes([pfx, feat[0], feat[1]]) + val)
        os.write(self.fd, pkt)
        confirm = build_packet(self._next_seq(), 0x03, CMD_CONFIRM, b"")
        os.write(self.fd, confirm)
        # Drain the device's SET/CONFIRM echoes; callers verify via read_one/read_all.
        for _ in range(2):
            r, _, _ = select.select([self.fd], [], [], 0.04)
            if r:
                try:
                    os.read(self.fd, 64)
                except BlockingIOError:
                    pass

    def set_named(self, name: str, value):
        if name not in FEATURE_MAP:
            raise ValueError(f"unknown feature: {name}")
        _, pfx, f0, f1, fmt, mn, mx = FEATURE_MAP[name]
        self.set_feat(pfx, (f0, f1), encode_value(fmt, value, mn, mx))

    def read_one(self, name: str):
        if name not in FEATURE_MAP:
            raise ValueError(f"unknown feature: {name}")
        _, pfx, f0, f1, fmt, _, _ = FEATURE_MAP[name]
        raw = self.get_feat(pfx, (f0, f1))
        if raw is None:
            raise TimeoutError(f"MV7+ did not confirm {name}")
        return {name: decode_value(fmt, raw)}

    def read_all(self, require_complete: bool = False):
        out = {}
        missing = []
        for name, pfx, f0, f1, fmt, _, _ in FEATURES:
            raw = self.get_feat(pfx, (f0, f1))
            if raw is None:
                out[name] = None
                missing.append(name)
            else:
                out[name] = decode_value(fmt, raw)
        if len(missing) == len(FEATURES) or (require_complete and missing):
            raise TimeoutError(f"MV7+ did not reply for: {', '.join(missing[:3])}")
        return out


def lock_path():
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if runtime and os.path.isdir(runtime):
        return os.path.join(runtime, "omarchy-mv7plus-hid.lock")
    return os.path.join("/tmp", f"omarchy-mv7plus-hid-{os.getuid()}.lock")


def acquire_lock(path: str, timeout_s: float = 3.0):
    fd = os.open(path, os.O_CREAT | os.O_WRONLY | os.O_NOFOLLOW, 0o600)
    deadline = time.monotonic() + timeout_s
    while True:
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            return fd
        except OSError as exc:
            if exc.errno not in (errno.EACCES, errno.EAGAIN) or time.monotonic() >= deadline:
                os.close(fd)
                raise TimeoutError("HID device lock busy")
            time.sleep(0.05)


def emit(obj):
    print(json.dumps(obj, separators=(",", ":")))


def main():
    action = sys.argv[1] if len(sys.argv) > 1 else "read"
    dev = find_mv7plus()
    if not dev:
        emit({"connected": False})
        return

    try:
        lock_fd = acquire_lock(lock_path())
    except OSError as exc:
        emit({"connected": True, "device": dev, "error": str(exc)})
        return
    except TimeoutError as exc:
        emit({"connected": True, "device": dev, "error": str(exc)})
        return

    try:
        try:
            mic = MV7Plus(dev)
        except PermissionError:
            emit({"connected": True, "device": dev, "error": "permission"})
            return
        except OSError as exc:
            emit({"connected": False, "error": str(exc)})
            return

        try:
            if action == "set" and len(sys.argv) >= 4:
                key = sys.argv[2]
                mic.set_named(key, sys.argv[3])
                time.sleep(0.03)
                state = mic.read_one(key)
            elif action == "preset" and len(sys.argv) >= 3:
                preset = sys.argv[2]
                if preset == "neutral":
                    for k, v in [
                        ("auto_level", 0),
                        ("mute", 0),
                        ("hpf", 0),
                        ("limiter", 0),
                        ("compressor", 0),
                        ("denoiser", 0),
                        ("popper_stopper", 0),
                        ("tone_pct", 0),
                        ("reverb_output", 0),
                        ("reverb_monitor", 0),
                    ]:
                        mic.set_named(k, v)
                elif preset == "factory":
                    for k, v in [
                        ("mute", 0),
                        ("hpf", 0),
                        ("limiter", 0),
                        ("compressor", 0),
                        ("denoiser", 0),
                        ("popper_stopper", 0),
                        ("tone_pct", 0),
                        ("reverb_output", 0),
                        ("reverb_type", 0),
                        ("reverb_intensity", 0),
                        ("reverb_monitor", 0),
                        ("mic_level", 100),
                        ("playback_level", 100),
                        ("auto_level", 1),
                    ]:
                        mic.set_named(k, v)
                else:
                    raise ValueError(f"unknown preset: {preset}")
                time.sleep(0.08)
                state = mic.read_all(require_complete=True)
            else:
                state = mic.read_all()
            emit({"connected": True, "device": dev, "state": state})
        except Exception as exc:
            emit({"connected": True, "device": dev, "error": str(exc)})
        finally:
            mic.close()
    finally:
        try:
            fcntl.flock(lock_fd, fcntl.LOCK_UN)
        finally:
            os.close(lock_fd)


if __name__ == "__main__":
    main()
