#!/usr/bin/env python3
"""Exercise the real helper with a native signal sink, never wvkbd or Wayland.

Usage: python3 test/helpers/desktop-keyboard-process.py [path/to/omarchy-toggle-desktop-keyboard]
Requires Linux /proc, cc, Bash and flock. No packages, services or live session
are touched. This checks helper routing/identity/locking, not keyboard behaviour,
focus retention, held-key release, overlay geometry or hardware acceptance.
"""
import json
import os
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from pathlib import Path

HELPER = (Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else
          Path(__file__).resolve().parents[2] / 'bin/omarchy-toggle-desktop-keyboard')

# The sink records signal receipt; it intentionally implements no keyboard logic.
FIXTURE = r'''
#include <signal.h>
#include <sys/signalfd.h>
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
    else if (getenv("STOCK_OPTIONS")) puts("--non-exclusive --wayland-layer");
    else puts("--non-exclusive --wayland-layer --output");
    return 0;
  }
  if (getenv("FAIL_START")) return 42;
  fd = open(getenv("SIGNALS"), O_WRONLY|O_CREAT|O_APPEND, 0600);
  if (fd < 0) return 43;
  const char *gate = getenv("START_GATE");
  if (gate) {
    (void)write(fd, "W", 1);
    while (access(gate, F_OK) != 0) usleep(5000);
  }
  sigset_t controls;
  sigemptyset(&controls);
  sigaddset(&controls, SIGUSR1);
  sigaddset(&controls, SIGUSR2);
  sigaddset(&controls, SIGRTMIN);
  sigaddset(&controls, SIGTERM);
  (void)write(fd, "B", 1);
  if (sigprocmask(SIG_BLOCK, &controls, NULL) != 0) return 44;
  int control_fd = signalfd(-1, &controls, SFD_CLOEXEC);
  if (control_fd < 0) return 45;
  for (;;) {
    struct signalfd_siginfo info;
    if (read(control_fd, &info, sizeof(info)) == sizeof(info)) handle(info.ssi_signo);
  }
}
'''


def starttime(pid):
    return Path(f'/proc/{pid}/stat').read_text().rsplit(') ', 1)[1].split()[19]


def main():
    assert HELPER.is_file(), f'Helper missing: {HELPER}'
    # The fixture path includes spaces and glob characters to check literal matching.
    with tempfile.TemporaryDirectory(prefix='desktop-keyboard [test]-') as temp:
        root = Path(temp)
        source = root / 'sink.c'
        source.write_text(FIXTURE)
        binary = root / 'wvkbd-mobintl'
        subprocess.run(['cc', '-Wall', '-Wextra', str(source), '-o', str(binary)], check=True)
        present = root / 'omarchy-cmd-present'
        present.write_text('#!/bin/bash\n[[ $1 == "wvkbd-mobintl" && -x $TEST_RENDERER ]]\n')
        present.chmod(0o700)
        monitors = root / 'monitors.json'
        (root / 'hyprctl').write_text('#!/bin/bash\ncat "$MONITORS"\n')
        (root / 'hyprctl').chmod(0o700)
        ally = root / 'omarchy-hw-rog-ally'
        ally.write_text('#!/bin/bash\n[[ -e $XDG_RUNTIME_DIR/rc71l ]]\n')
        ally.chmod(0o700)
        env = os.environ | {'PATH': f'{root}:{HELPER.parent}:/usr/bin:/bin',
                            'HOME': str(root), 'TEST_RENDERER': str(binary),
                            'XDG_RUNTIME_DIR': str(root), 'WAYLAND_DISPLAY': 'wayland-test',
                            'SIGNALS': str(root / 'signals'), 'MONITORS': str(monitors),
                            'XDG_DATA_HOME': str(root / 'data'),
                            'OMARCHY_PATH': str(HELPER.parent.parent),
                            'OMARCHY_SETUP_CONTEXT': 'provision-owner'}
        state = root / 'omarchy-desktop-keyboard-wayland-test'
        record = state / 'process'
        owned = set()

        def run(*args, ok=True, extra=None):
            result = subprocess.run(['/bin/bash', str(HELPER), *args], env=env | (extra or {}),
                                    capture_output=True, text=True, timeout=5)
            assert (result.returncode == 0) == ok, (args, result.returncode, result.stderr)
            if record.exists():
                pid, stamp, executable = record.read_text().split(maxsplit=2)
                executable = executable.rstrip('\n')
                if executable == str(binary) and Path(f'/proc/{pid}').exists() and starttime(pid) == stamp:
                    owned.add((int(pid), stamp))
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
            print('ok - help, argument and session checks, inactive hide and stop')

            for _ in range(3):
                run('show')
                saved = record.read_text()
                assert events().endswith('B')
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
                    wait_for(lambda: events().endswith('B' + suffix))
                    assert record.read_text() == saved
                run('stop')
                wait_for(lambda: events().endswith('B' + suffix + 'HX'))
                assert not record.exists()
            print('ok - renderer arguments, repeated show and hide, toggle, and hide before stop')

            # Hold startup beyond the old 200 ms wait while a second tap queues.
            toggle = ['/bin/bash', str(HELPER), 'toggle']
            gate = root / 'startup-ready'
            before = events()
            with subprocess.Popen(toggle, env=env | {'START_GATE': str(gate)}) as first:
                try:
                    wait_for(lambda: events() == before + 'W')
                    saved = record.read_text()
                    pid, stamp, _ = saved.split(maxsplit=2)
                    owned.add((int(pid), stamp))
                    with subprocess.Popen(toggle, env=env) as second:
                        try:
                            second.wait(timeout=.35)
                        except subprocess.TimeoutExpired:
                            assert first.poll() is None, 'First tap returned before signal readiness'
                            assert events() == before + 'W'
                        else:
                            raise AssertionError('Second tap returned before signal readiness')
                        finally:
                            gate.touch()
                        assert second.wait(timeout=5) == 0
                    assert first.wait(timeout=5) == 0
                finally:
                    gate.touch()
            wait_for(lambda: events() == before + 'WBT')
            assert record.read_text() == saved
            run('stop')
            wait_for(lambda: events() == before + 'WBTHX')
            print('ok - a second tap waits for slow startup and toggles the same renderer')

            # An inherited mask must not pass readiness before the renderer sets its own.
            before = events()
            blocked = ['/usr/bin/env', '--block-signal=USR1,USR2,RTMIN', *toggle]
            with subprocess.Popen(blocked, env=env | {'START_GATE': str(root / 'never-ready')},
                                  stderr=subprocess.PIPE, text=True) as stuck:
                wait_for(lambda: events() == before + 'W')
                pid, stamp, _ = record.read_text().split(maxsplit=2)
                owned.add((int(pid), stamp))
                _, err = stuck.communicate(timeout=5)
                assert stuck.returncode != 0 and 'startup failed' in err, err
            assert not record.exists() and not Path(f'/proc/{pid}').exists()
            assert events() == before + 'W'
            run('show')
            run('stop')
            print('ok - startup timeout removes the unready renderer and allows retry')

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
            print('ok - executable replacement preserves hide, show and stop ownership')

            # The real executable with a wrong birth time must not be signalled.
            run('show')
            saved = record.read_text()
            pid, stamp, executable = saved.rstrip('\n').split(maxsplit=2)
            before = events()
            for invalid_stamp in (str(int(stamp) + 1), '*'):
                record.write_text(f'{pid} {invalid_stamp} {executable}\n')
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
            print('ok - invalid start times, unrelated executables and malformed PIDs are ignored')

            run('show', ok=False, extra={'OLD_OPTIONS': '1'})
            assert not record.exists()
            run('show', ok=False, extra={'FAIL_START': '1'})
            assert not record.exists()
            binary.rename(root / 'disabled')
            result = run('show', ok=False)
            assert 'missing' in result.stderr
            (root / 'disabled').rename(binary)
            print('ok - obsolete options, failed startup and missing renderer')

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
                pid, stamp, _ = record.read_text().split(maxsplit=2)
                owned.add((int(pid), stamp))
                assert events()[len(before):].count('B') == 1
                # Standard signals may coalesce: process identity/count is the invariant.
                run('stop')
            finally:
                for call in calls:
                    if call.poll() is None:
                        call.kill(); call.wait()
                if lock.poll() is None:
                    lock.kill(); lock.wait()
            print('ok - the lock blocks work and six simultaneous shows create one process')

            setup = HELPER.parent.parent / 'install/user/hardware/asus/rog-ally-keyboard.sh'
            launcher = root / 'data/applications/omarchy-desktop-keyboard.desktop'

            def configure(extra=None):
                return subprocess.run(['/bin/bash', str(setup)], env=env | (extra or {}),
                                      capture_output=True, text=True, timeout=5)

            def outputs(*names):
                monitors.write_text(json.dumps([{'name': name, 'focused': index == 0}
                                                for index, name in enumerate(names)]))

            assert configure().returncode == 0 and not launcher.exists()
            outputs('DP-1')
            run('show')
            run('stop')
            (root / 'rc71l').touch()
            for options in ('OLD_OPTIONS', 'STOCK_OPTIONS'):
                result = configure({options: '1'})
                assert result.returncode == 0 and not launcher.exists(), options
            result = configure()
            assert result.returncode == 0, (result.stdout, result.stderr)
            assert launcher.is_file() and not record.exists()
            launcher.unlink()
            launcher.symlink_to(root / 'owner-launcher')
            assert configure().returncode == 0 and launcher.readlink() == root / 'owner-launcher'
            run('show', ok=False)
            outputs('eDP-1', 'DP-1')
            run('show', ok=False)
            assert not record.exists()
            outputs('eDP-1')
            run('show', ok=False, extra={'STOCK_OPTIONS': '1'})
            monitors.write_text(json.dumps([{'name': 'eDP-1', 'focused': True, 'mirrorOf': 1}]))
            run('show', ok=False)
            outputs('eDP-1')
            run('show')
            saved = record.read_text()
            pid = int(saved.split()[0])
            argv = Path(f'/proc/{pid}/cmdline').read_bytes().split(b'\0')[1:-1]
            assert argv[-2:] == [b'--output', b'eDP-1'], argv
            outputs('DP-1', 'eDP-1')
            run('show', ok=False)
            assert record.read_text() == saved
            run('toggle')
            wait_for(lambda: events().endswith('BH'))
            run('stop')
            assert not record.exists()
            print('ok - Ally launcher and explicit unmirrored eDP selection')
        finally:
            # Only terminate fixture PIDs recorded by this private test runtime.
            for pid, stamp in owned:
                try:
                    executable = os.readlink(f'/proc/{pid}/exe').removesuffix(' (deleted)')
                    if executable == str(binary) and starttime(pid) == stamp:
                        os.kill(pid, signal.SIGTERM)
                except (FileNotFoundError, ProcessLookupError):
                    pass


if __name__ == '__main__':
    main()
