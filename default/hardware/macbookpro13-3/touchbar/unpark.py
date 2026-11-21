#!/usr/bin/env python3
# SPDX-License-Identifier: GPL-2.0-only
"""MacBookPro13,3: validate T1, read report 3, unpark once, read back.

Default is sysfs-only preflight. --apply performs one HID feature write.
No ACPI methods, device resets, service changes or suspend hooks are used.
"""
import argparse
import datetime
import fcntl
import hashlib
import os
import platform
import signal
import stat
import struct
import time
from pathlib import Path

DESCRIPTOR_SHA256 = '80e03f014a8f288ca4da0eafcad13796f674926be383d4d5072ae3ab02c430ae'
REPORT = bytes([3, 2, 0xf4, 1] + [0] * 11)
# Linux x86_64 hidraw UAPI; lengths include report ID.
GET_FEATURE = 0xc00f4807
SET_FEATURE = 0xc00f4806
GET_INFO = 0x80084803
GET_DESC_SIZE = 0x80044801
GET_DESC = 0x90044802


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def attr(path):
    return path.read_text().strip()


def discover():
    matches = []
    for node in Path('/sys/class/hidraw').glob('hidraw*'):
        hid = (node / 'device').resolve(strict=True)
        parents = [hid, *hid.parents]
        usb = next((p for p in parents if (p / 'idVendor').is_file()), None)
        interface = next((p for p in parents if (p / 'bInterfaceNumber').is_file()), None)
        if usb is None or interface is None:
            continue
        if (attr(usb / 'idVendor'), attr(usb / 'idProduct')) != ('05ac', '8600'):
            continue
        if attr(interface / 'bInterfaceNumber') != '06':
            continue
        require(attr(usb / 'bConfigurationValue') == '2', 'T1 is not configuration 2.')
        descriptor = (hid / 'report_descriptor').read_bytes()
        require(hashlib.sha256(descriptor).hexdigest() == DESCRIPTOR_SHA256,
                'HID descriptor differs from the reviewed report layout.')
        matches.append((node, usb, descriptor))
    require(len(matches) == 1, f'Expected exactly one matching T1 interface; found {len(matches)}.')
    return matches[0]


def verify_fd(fd, node, descriptor):
    info = os.fstat(fd)
    expected = tuple(map(int, attr(node / 'dev').split(':')))
    require(stat.S_ISCHR(info.st_mode) and
            (os.major(info.st_rdev), os.minor(info.st_rdev)) == expected,
            'Opened device does not match discovered sysfs device.')
    raw = bytearray(8)
    fcntl.ioctl(fd, GET_INFO, raw, True)
    require(struct.unpack('=IHH', raw) == (3, 0x05ac, 0x8600), 'Opened device identity mismatch.')
    size = bytearray(4)
    fcntl.ioctl(fd, GET_DESC_SIZE, size, True)
    require(struct.unpack('=I', size)[0] == len(descriptor), 'Opened descriptor size mismatch.')
    desc = bytearray(4100)
    struct.pack_into('=I', desc, 0, len(descriptor))
    fcntl.ioctl(fd, GET_DESC, desc, True)
    require(bytes(desc[4:4 + len(descriptor)]) == descriptor, 'Opened descriptor mismatch.')


def read_feature(fd):
    report = bytearray([3] + [0] * 14)
    count = fcntl.ioctl(fd, GET_FEATURE, report, True)
    require(count == len(report) and report[0] == 3, 'Unexpected feature-report length or ID.')
    require(report[1] in (1, 2), 'Unknown display mode; no further write permitted.')
    return report


def show_feature(label, report):
    print(f'{label}: report=3 bytes={len(report)} mode={report[1]} '
          f'transition_value={int.from_bytes(report[2:6], "little")}', flush=True)


def trial(fd, if_parked=False):
    before = read_feature(fd)
    show_feature('Before', before)
    if if_parked and before[1] == 2:
        print('Panel already reports mode 2; no write sent.', flush=True)
        return
    started = time.monotonic()
    count = fcntl.ioctl(fd, SET_FEATURE, bytearray(REPORT), True)
    print(f'Single unpark write: returned={count} elapsed_ms={(time.monotonic()-started)*1000:.1f}', flush=True)
    require(count == len(REPORT), 'Short feature write; not retrying.')
    time.sleep(0.6)
    after = read_feature(fd)
    show_feature('After', after)
    require(after[1] == 2, 'Panel still reports parked; not retrying.')
    print('Physical illumination must be reported separately by the user.', flush=True)


def timed_out(signum, frame):
    raise TimeoutError('Trial deadline exceeded; no retry will be made.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--if-parked', action='store_true', help='Skip the write if already in mode 2.')
    args = parser.parse_args()
    require(platform.machine() == 'x86_64', 'This helper supports x86_64 only.')
    require(attr(Path('/sys/class/dmi/id/product_name')) == 'MacBookPro13,3',
            'This helper is restricted to MacBookPro13,3.')
    node, usb, descriptor = discover()
    print('Preflight passed: one T1, configuration 2, interface 6, reviewed descriptor.', flush=True)
    print('Planned write: one 15-byte feature report 3, mode 2, transition value 500.', flush=True)
    if not args.apply:
        print('Preflight only; no device node opened or feature request sent.')
        return
    require(os.geteuid() == 0, 'Administrator access is required for --apply.')
    signal.signal(signal.SIGALRM, timed_out)
    signal.alarm(20)
    fd = os.open('/dev/' + node.name, os.O_RDWR | os.O_CLOEXEC | os.O_NOFOLLOW | os.O_NONBLOCK)
    try:
        verify_fd(fd, node, descriptor)
        require(attr(usb / 'bConfigurationValue') == '2', 'T1 configuration changed.')
        print('Trial start: ' + datetime.datetime.now().astimezone().isoformat(timespec='seconds'), flush=True)
        trial(fd, if_parked=args.if_parked)
    finally:
        os.close(fd)
        signal.alarm(0)


if __name__ == '__main__':
    try:
        main()
    except (OSError, RuntimeError) as error:
        raise SystemExit(f'Trial stopped: {error}')
