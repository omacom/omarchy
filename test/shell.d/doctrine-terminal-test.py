"""Exercise the real fzf reader; invoked by doctrine-test.sh with an isolated browser."""

import fcntl
import os
from pathlib import Path
import pty
import select
import signal
import struct
import termios
import time

log = Path(os.environ['DOCTRINE_BROWSER_LOG'])


def check(condition, message):
  if not condition:
    raise SystemExit('not ok - ' + message)
  print('ok - ' + message, flush=True)


def terminal_session(interrupt=False, exit_key=b'q'):
  pid, master = pty.fork()
  if pid == 0:
    os.environ['TERM'] = 'xterm-256color'
    os.execvp('bash', ['bash', '-c', '''
 before=$(stty -g)
 "$ROOT/bin/omarchy" doctrine --interactive
 result=$?
 after=$(stty -g)
 [[ $before == "$after" ]] || exit 91
 exit "$result"
'''])
  output = bytearray()
  reaped = False
  def receive(seconds):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
      ready, _, _ = select.select([master], [], [], max(0, deadline - time.monotonic()))
      if ready:
        try:
          chunk = os.read(master, 65536)
        except OSError:
          return
        if not chunk:
          return
        output.extend(chunk)
  def send(keys):
    os.write(master, keys)
    receive(0.2)
  try:
    fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack('HHHH', 36, 120, 0, 0))
    deadline = time.monotonic() + 5
    while b'PRINCIPLE' not in output and time.monotonic() < deadline:
      receive(0.1)
    check(b'PRINCIPLE' in output, 'the real fzf reader displays a live preview')
    check(b'Read the full doctrine' in output and b'11  Read' not in output,
          'the full-document action is visible without a principle number')
    if interrupt:
      send(b'\x03')
    else:
      send(b'\x1b[<0;27;5M\x1b[<0;27;5m')
      check(log.read_text().splitlines()[-1].endswith('#unite-the-nerds'), 'the real header mouse control opens the website')
      send(b'\x1b[<0;10;9M\x1b[<0;10;9m')
      send(b'w')
      check(log.read_text().splitlines()[-1].endswith('#have-some-fun'), 'the real mouse selects a principle and updates the browser target')
      output.clear()
      send(b'\x1b[<0;17;5M\x1b[<0;17;5m')
      check(b'Reading the full doctrine' in output, 'clicking the Full button border opens the full view')
      send(b'\x1b')
      send(b'\x1b[<0;17;32M\x1b[<0;17;32m')
      check(log.read_text().splitlines()[-1] == 'https://omarchy.org/doctrine/',
            'the real footer URL opens its displayed destination')
      send(b'1')
      send(b'j')
      send(b'\r')
      send(b'\x1b[B')
      send(b'w')
      check(log.read_text().splitlines()[-1].endswith('#have-some-fun'), 'live keyboard navigation opens the correct principle online')
      send(b'h')
      send(b'l')
      send(b'f')
      check(b'The Omarchy Doctrine' in output, 'the full-document action renders the doctrine')
      send(b' ')
      fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 60, 0, 0))
      os.killpg(pid, signal.SIGWINCH)
      receive(0.2)
      send(b'\x1b')
      send(b'w')
      check(log.read_text().splitlines()[-1].endswith('#have-some-fun'), 'resize and returning from the full document preserve the selected principle')
      send(b'\x1b')
      send(exit_key)
    receive(1)
    completed, status = os.waitpid(pid, os.WNOHANG)
    reaped = completed == pid
    check(reaped, 'the reader exits promptly')
    check(os.waitstatus_to_exitcode(status) == (130 if interrupt else 0), 'terminal settings are restored after ' + ('Ctrl-C' if interrupt else 'reading, navigation, resize, and quit'))
    check(b'\x1b[?1049l' in output, 'the reader restores the original terminal screen')
  finally:
    if not reaped:
      os.killpg(pid, signal.SIGKILL)
      os.waitpid(pid, 0)
    os.close(master)

if __name__ == "__main__":
  terminal_session()
  terminal_session(interrupt=True)
  terminal_session(exit_key=b'\x1b')
