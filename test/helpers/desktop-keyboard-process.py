#!/usr/bin/env python3
"""Exercise the real helper with a native signal sink, never wvkbd or Wayland.

Usage: python3 helper-process-test.py [path/to/omarchy-toggle-desktop-keyboard]
Requires Linux /proc, cc, Bash and flock. No packages, services or live session
are touched. This checks helper routing/identity/locking, not keyboard behaviour,
focus retention, held-key release, overlay geometry or hardware acceptance.
"""
import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import tempfile
import time

HELPER = (Path(sys.argv[1]) if len(sys.argv) > 1 else
          Path(__file__).resolve().parents[1] / 'source/bin/omarchy-toggle-desktop-keyboard')

# The sink records signal receipt; it intentionally implements no keyboard logic.
FIXTURE = r'''
#include <signal.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
static int fd;
static void handle(int sig) {
  char c = sig == SIGUSR1 ? 'H' : sig == SIGUSR2 ? 'S' : sig == SIGTERM ? 'X' : 'T';
  (void)write(fd, &c, 1);
  if (sig == SIGTERM) _exit(0);
}
int main(int argc, char **argv) {
  if (argc > 1 && !strcmp(argv[1], "--help")) {
    if (getenv("OLD_OPTIONS")) puts("old build");
    else puts("--non-exclusive --wayland-layer");
    return 0;
  }
  if (getenv("FAIL_START")) return 42;
  fd = open(getenv("SIGNALS"), O_WRONLY|O_CREAT|O_APPEND, 0600);
  if (fd < 0) return 43;
  signal(SIGUSR1, handle); signal(SIGUSR2, handle);
  signal(SIGRTMIN, handle); signal(SIGTERM, handle);
  (void)write(fd, "B", 1);
  for (int i=1; i<argc; i++) { (void)write(fd, argv[i], strlen(argv[i])); (void)write(fd, "\n", 1); }
  (void)write(fd, "E", 1);
  for (;;) pause();
}
'''


def starttime(pid):
    return Path(f'/proc/{pid}/stat').read_text().rsplit(') ', 1)[1].split()[19]


def main():
    assert HELPER.is_file(), f'Helper missing: {HELPER}'
    with tempfile.TemporaryDirectory(prefix='haki-keyboard-test-') as temp:
        root = Path(temp)
        source = root / 'sink.c'
        source.write_text(FIXTURE)
        binary = root / 'wvkbd-mobintl'
        subprocess.run(['cc', '-Wall', '-Wextra', str(source), '-o', str(binary)], check=True)
        present = root / 'omarchy-cmd-present'
        present.write_text('#!/bin/bash\ncommand -v "$1" >/dev/null\n')
        present.chmod(0o700)
        env = os.environ | {'PATH': str(root) + ':' + os.environ['PATH'],
                            'XDG_RUNTIME_DIR': str(root), 'WAYLAND_DISPLAY': 'wayland-test',
                            'SIGNALS': str(root / 'signals')}
        state = root / 'omarchy-desktop-keyboard-wayland-test'
        record = state / 'process'
        owned = set()

        def run(*args, ok=True, extra=None):
            result = subprocess.run(['/bin/bash', str(HELPER), *args], env=env | (extra or {}),
                                    capture_output=True, text=True, timeout=5)
            assert (result.returncode == 0) == ok, (args, result.returncode, result.stderr)
            if record.exists():
                pid, stamp, executable = record.read_text().split()
                if executable == str(binary) and Path(f'/proc/{pid}').exists() and starttime(pid) == stamp:
                    owned.add(int(pid))
            return result

        def events():
            return (root / 'signals').read_text()

        def wait_for(predicate):
            until = time.monotonic() + 2
            while time.monotonic() < until:
                if predicate():
                    return
                time.sleep(.01)
            raise AssertionError('Timed out waiting for fixture event')

        try:
            run('--help', extra={'WAYLAND_DISPLAY': '', 'XDG_RUNTIME_DIR': ''})
            run('invalid', ok=False)
            run('show', 'extra', ok=False)
            run('show', ok=False, extra={'WAYLAND_DISPLAY': ''})
            run('hide'); run('stop')
            assert not record.exists()
            print('[Haki] PASS help, invalid arguments, missing session, inactive hide/stop')

            for _ in range(3):
                run('show')
                saved = record.read_text()
                assert events().endswith('E')
                pid = int(saved.split()[0])
                # Real argv observed by the native child, not source-text assertions.
                argv = Path(f'/proc/{pid}/cmdline').read_bytes().split(b'\0')[1:-1]
                assert argv == [b'-H', b'180', b'-L', b'180', b'--non-exclusive',
                                b'--wayland-layer', b'overlay', b'-l', b'full,special',
                                b'--landscape-layers', b'full,special', b'--no-popup'], argv
                suffix = ''
                for action, expected in [('show', 'S'), ('show', 'S'), ('toggle', 'T'),
                                         ('hide', 'H'), ('hide', 'H'), ('show', 'S')]:
                    run(action)
                    suffix += expected
                    wait_for(lambda: events().endswith('E' + suffix))
                    assert record.read_text() == saved
                run('stop')
                wait_for(lambda: events().endswith('E' + suffix + 'HX'))
                assert not record.exists()
            print('[Haki] PASS three cycles: real argv, repeated show/hide, toggle signals, hide-before-TERM stop')

            # A package upgrade unlinks the running executable inode. Keep ownership.
            run('show')
            saved = record.read_text()
            replacement = root / 'new-keyboard'
            shutil.copy2(binary, replacement)
            os.replace(replacement, binary)
            assert os.readlink(f'/proc/{saved.split()[0]}/exe').endswith(' (deleted)')
            before = events()
            run('hide'); run('show')
            assert record.read_text() == saved
            wait_for(lambda: events().endswith('HS'))
            assert events()[len(before):].count('B') == 0
            run('stop')
            wait_for(lambda: events().endswith('HX'))
            assert not record.exists()
            print('[Haki] PASS executable replacement preserves hide/show/stop ownership')

            # The real executable with a wrong birth time must not be signalled.
            run('show')
            saved = record.read_text()
            pid, stamp, executable = saved.split()
            before = events()
            record.write_text(f'{pid} {int(stamp)+1} {executable}\n')
            run('stop')
            assert events() == before and Path(f'/proc/{pid}').exists()
            record.write_text(saved)
            run('stop')
            # A live unrelated executable must survive even with a matching birth time.
            other = subprocess.Popen(['/bin/sleep', '20'])
            try:
                record.write_text(f'{other.pid} {starttime(other.pid)} {binary}\n')
                run('stop')
                assert other.poll() is None and not record.exists()
            finally:
                other.terminate(); other.wait(timeout=2)
            record.write_text('not-a-pid 0 missing\n'); run('hide')
            assert not record.exists()
            print('[Haki] PASS stale birth time, unrelated executable and malformed PID isolation')

            run('show', ok=False, extra={'OLD_OPTIONS': '1'})
            assert not record.exists()
            run('show', ok=False, extra={'FAIL_START': '1'})
            assert not record.exists()
            binary.rename(root / 'disabled')
            result = run('show', ok=False)
            assert 'missing' in result.stderr
            (root / 'disabled').rename(binary)
            print('[Haki] PASS obsolete options, failed startup and missing dependency')

            # Hold the actual flock: no helper may start or signal through it.
            lock = subprocess.Popen(['/usr/bin/flock', '-x', str(state / 'lock'),
                                     '/bin/sh', '-c', 'echo ready; read line'],
                                    stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
            assert lock.stdout.readline().strip() == 'ready'
            before = events()
            calls = [subprocess.Popen(['/bin/bash', str(HELPER), 'show'], env=env,
                                      stdout=subprocess.PIPE, stderr=subprocess.PIPE) for _ in range(6)]
            try:
                time.sleep(.15)
                assert all(p.poll() is None for p in calls)
                assert events() == before and not record.exists()
                lock.communicate('release\n', timeout=2)
                for call in calls:
                    out, err = call.communicate(timeout=5)
                    assert call.returncode == 0, (out, err)
                owned.add(int(record.read_text().split()[0]))
                assert events()[len(before):].count('B') == 1
                # Standard signals may coalesce: process identity/count is the invariant.
                run('stop')
            finally:
                for call in calls:
                    if call.poll() is None:
                        call.kill(); call.wait()
                if lock.poll() is None:
                    lock.kill(); lock.wait()
            print('[Haki] PASS lock blocks work; six simultaneous shows create one process')
        finally:
            # Only terminate fixture PIDs recorded by this private test runtime.
            for pid in owned:
                try:
                    if os.readlink(f'/proc/{pid}/exe') == str(binary):
                        os.kill(pid, signal.SIGTERM)
                except (FileNotFoundError, ProcessLookupError):
                    pass
    print('[Haki] LIMIT: fixture tests helper process safety only; focus/hardware acceptance UNTESTED')


if __name__ == '__main__':
    main()
