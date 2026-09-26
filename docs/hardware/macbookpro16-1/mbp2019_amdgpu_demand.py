#!/usr/bin/python3
"""Conservative two-state GPU policy for one verified MacBook board.

This is not firmware DPM auto and does not choose an application's GPU.
No writes to voltages, clock tables, fans, power caps, or runtime PM.
"""

import argparse
import dataclasses
import fcntl
import json
import os
from pathlib import Path
import signal
import sys
import threading
import time

GPU = Path('/sys/bus/pci/devices/0000:03:00.0')
RUNTIME = Path('/run/mbp2019-amdgpu-demand')


class SafetyError(RuntimeError):
    pass


def read_text(path):
    return path.read_text(encoding='ascii').strip()


def read_number(path, minimum, maximum):
    text = read_text(path)
    if not text.isdecimal():
        raise SafetyError(f'Invalid numeric sensor: {path.name}')
    value = int(text)
    if not minimum <= value <= maximum:
        raise SafetyError(f'Out-of-range sensor: {path.name}={value}')
    return value


@dataclasses.dataclass(frozen=True)
class Sample:
    busy: int
    edge: int
    junction: int
    power_uw: int


@dataclasses.dataclass
class Policy:
    mode: str = 'low'
    busy_since: float | None = None
    idle_since: float | None = None
    cool_since: float | None = None
    high_since: float | None = None
    last_low: float = -1000.0
    hot: bool = False

    def step(self, now, sample):
        """Pure policy: timestamps are monotonic seconds; temperatures are mC."""
        if not (0 <= sample.busy <= 100 and 0 < sample.edge < 150000
                and 0 < sample.junction < 150000):
            raise SafetyError('Invalid policy sample')
        if sample.edge >= 80000 or sample.junction >= 90000:
            self.hot = True
            self.cool_since = None
        if self.hot:
            if sample.edge <= 70000 and sample.junction <= 80000:
                if self.cool_since is None:
                    self.cool_since = now
                if now - self.cool_since >= 30:
                    self.hot = False
                    self.cool_since = None
            else:
                self.cool_since = None
            self.busy_since = None
            self.idle_since = None
            if self.mode == 'high':
                self.mode = 'low'
                self.last_low = now
                self.high_since = None
            return self.mode, 'thermal-cooldown'

        if self.mode == 'low':
            self.idle_since = None
            if sample.busy >= 70 and now - self.last_low >= 8:
                if self.busy_since is None:
                    self.busy_since = now
                if now - self.busy_since >= 1:
                    self.mode = 'high'
                    self.high_since = now
                    self.busy_since = None
                    return self.mode, 'sustained-gpu-load'
            else:
                self.busy_since = None
            return self.mode, 'low-load'

        self.busy_since = None
        if sample.busy <= 3:
            if self.idle_since is None:
                self.idle_since = now
            if now - self.idle_since >= 10 and now - self.high_since >= 12:
                self.mode = 'low'
                self.last_low = now
                self.high_since = None
                self.idle_since = None
                return self.mode, 'gpu-idle'
        else:
            self.idle_since = None
        return self.mode, 'gpu-active'


class Hardware:
    def __init__(self):
        if read_text(Path('/sys/class/dmi/id/product_name')) != 'MacBookPro16,1':
            raise SafetyError('Unsupported MacBook model')
        for field, expected in (
            ('vendor', '0x1002'), ('device', '0x7340'),
            ('subsystem_vendor', '0x106b'), ('subsystem_device', '0x020f'),
        ):
            if read_text(GPU / field) != expected:
                raise SafetyError(f'Unsupported GPU {field}')
        if (GPU / 'driver').resolve() != Path('/sys/bus/pci/drivers/amdgpu'):
            raise SafetyError('Expected the amdgpu driver')
        candidates = list((GPU / 'hwmon').glob('hwmon*'))
        if len(candidates) != 1 or read_text(candidates[0] / 'name') != 'amdgpu':
            raise SafetyError('Cannot identify AMD temperature sensors')
        self.hwmon = candidates[0]
        self.cap = read_number(self.hwmon / 'power1_cap', 1, 50000000)
        if self.mode() != 'low':
            raise SafetyError('Start only from the verified low state')
        self.sample()

    def mode(self):
        return read_text(GPU / 'power_dpm_force_performance_level')

    def set_mode(self, value):
        if value not in ('low', 'high'):
            raise SafetyError('Only low/high transitions are allowed')
        with (GPU / 'power_dpm_force_performance_level').open('w', encoding='ascii') as output:
            output.write(value + '\n')
        if self.mode() != value:
            raise SafetyError(f'The driver did not accept {value}')

    def sample(self):
        if read_text(GPU / 'power/control') != 'on':
            raise SafetyError('Runtime-PM policy changed; stop and revalidate')
        if read_number(self.hwmon / 'power1_cap', 1, 50000000) != self.cap:
            raise SafetyError('Power cap changed while the controller was running')
        return Sample(
            busy=read_number(GPU / 'gpu_busy_percent', 0, 100),
            edge=read_number(self.hwmon / 'temp1_input', 1, 149999),
            junction=read_number(self.hwmon / 'temp2_input', 1, 149999),
            power_uw=read_number(self.hwmon / 'power1_average', 0, 100000000),
        )


def emit(event, **fields):
    print(json.dumps({'time': time.strftime('%Y-%m-%dT%H:%M:%S%z'),
                      'event': event, **fields}, sort_keys=True), flush=True)


def save_status(**record):
    temporary = RUNTIME / 'status.json.tmp'
    with temporary.open('w', encoding='utf-8') as output:
        json.dump({'time': time.time(), **record}, output)
        output.write('\n')
    temporary.replace(RUNTIME / 'status.json')


def run(apply, duration):
    if apply and os.geteuid() != 0:
        raise SafetyError('Live mode requires system authorization')
    hardware = Hardware()
    lock_fd = None
    if apply:
        RUNTIME.mkdir(mode=0o755, exist_ok=True)
        directory = RUNTIME.lstat()
        if RUNTIME.is_symlink() or directory.st_uid != 0 or directory.st_mode & 0o022:
            raise SafetyError('Unsafe runtime directory')
        lock_fd = os.open(RUNTIME / 'lock', os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
        fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)

    stop = threading.Event()
    for signum in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
        signal.signal(signum, lambda *_: stop.set())
    policy = Policy()
    start = time.monotonic()
    last_log = -1000.0
    last_status = -1000.0
    log_interval = 5 if duration else 60
    last_boot_time = time.clock_gettime(time.CLOCK_BOOTTIME)
    last_tick = start
    emit('started', apply=apply, cap_uw=hardware.cap)
    try:
        while not stop.is_set():
            tick = time.monotonic()
            if duration and tick - start >= duration:
                break
            # CLOCK_BOOTTIME includes suspend; monotonic does not. A missed
            # sleep hook must fail closed, not resume an old high-state policy.
            boot_time = time.clock_gettime(time.CLOCK_BOOTTIME)
            if (boot_time - last_boot_time) - (tick - last_tick) > 2:
                raise SafetyError('Uncoordinated suspend detected')
            last_boot_time, last_tick = boot_time, tick
            actual = hardware.mode()
            expected = policy.mode if apply else 'low'
            if actual != expected:
                raise SafetyError(f'Another writer changed DPM to {actual}')
            sample = hardware.sample()
            desired, reason = policy.step(tick, sample)
            changing = desired != actual
            if apply and changing:
                hardware.set_mode(desired)
            record = dict(mode=hardware.mode(), desired=desired, reason=reason,
                          **dataclasses.asdict(sample))
            if changing or tick - last_log >= log_interval:
                emit('sample', **record)
                last_log = tick
            if apply and (changing or tick - last_status >= 5):
                save_status(running=True, **record)
                last_status = tick
            stop.wait(1)
    finally:
        if apply:
            try:
                if hardware.mode() != 'low':
                    hardware.set_mode('low')
                emit('stopped', mode=hardware.mode())
                save_status(running=False, mode=hardware.mode(), reason='controller-stopped')
            finally:
                if lock_fd is not None:
                    os.close(lock_fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--run', action='store_true', help='Apply low/high policy (root only)')
    parser.add_argument('--seconds', type=int, default=60, help='Duration; 0 runs until stopped')
    args = parser.parse_args()
    if not 0 <= args.seconds <= 86400:
        parser.error('--seconds must be between 0 and 86400')
    try:
        run(args.run, args.seconds)
    except (SafetyError, OSError) as error:
        emit('safety-stop', error=str(error))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
