#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
export OMARCHY_PATH="$ROOT"
export PYTHONDONTWRITEBYTECODE=1

python3 <<'PY'
import fcntl
import json
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import tempfile
import termios
import time

root = Path(os.environ['ROOT'])
command = [str(root / 'bin/omarchy'), 'doctrine']
helper = ['bash', str(root / 'default/omarchy/doctrine-reader.sh')]

def check(condition, message):
  if not condition:
    raise SystemExit('not ok - ' + message)
  print('ok - ' + message, flush=True)

def run(*args):
  return subprocess.run(command + list(args), capture_output=True, text=True)

short, full = run(), run('--full')
sections = (root / 'default/omarchy/doctrine.md').read_text().split('## ')[1:]
check(short.returncode == full.returncode == 0 and len(sections) == 10, 'plain output works without a terminal')
for section in sections:
  title, body = section.strip().split('\n', 1)
  check(title in short.stdout and ' '.join(body.split()) in ' '.join(full.stdout.split()), 'plain views preserve ' + title)
check('\x1b' not in short.stdout + full.stdout and run('--plain').stdout == short.stdout,
      'plain output and its explicit alias have no terminal escapes')
check(run('10').stdout.rstrip().endswith('#youre-somebody-now'), 'direct principle output preserves its website anchor')
for args in [('--invalid',), ('0',), ('11',), ('--full', 'extra'), ('--interactive',)]:
  result = run(*args)
  check(result.returncode == 2 and not result.stdout, 'invalid or non-terminal invocation is rejected: ' + ' '.join(args))

with tempfile.TemporaryDirectory() as scratch:
  scratch = Path(scratch)
  state = scratch / 'state'
  state.mkdir()
  os.environ['OMARCHY_DOCTRINE_STATE'] = str(state)
  (state / 'mode').write_text('index\n')
  browser = scratch / 'omarchy-launch-browser'
  browser.write_text('#!/bin/bash\nprintf "%s\\n" "$1" >> "$DOCTRINE_BROWSER_LOG"\n')
  browser.chmod(0o755)
  log = scratch / 'urls'
  os.environ['PATH'] = str(scratch) + ':' + os.environ['PATH']
  os.environ['DOCTRINE_BROWSER_LOG'] = str(log)

  def action(event, number='01', **env):
    return subprocess.check_output(helper + ['action', event, number], env=dict(os.environ, **env), text=True)

  run('--web')
  check(log.read_text().strip() == 'https://omarchy.org/doctrine/', '--web uses the default browser launcher')
  action('read')
  check((state / 'mode').read_text().strip() == 'read' and action('down') == 'preview-down', 'focused reading switches arrows to scrolling')
  action('full', '03')
  check('pos(3)' in action('back', '11'), 'leaving the full doctrine restores the previous principle')
  check(action('previous', '01') == 'pos(10)' and action('next', '10') == 'pos(1)', 'previous and next wrap across the ten principles')
  action('header', '10', FZF_CLICK_HEADER_WORD='Website')
  check(log.read_text().splitlines()[-1].endswith('#youre-somebody-now'), 'clicking Website opens the selected section')
  action('footer', '11', FZF_CLICK_FOOTER_LINE='1')
  check(log.read_text().splitlines()[-1] == 'https://omarchy.org/doctrine/', 'clicking the footer in the full view opens the whole doctrine')
  action('header', '03', FZF_CLICK_HEADER_WORD='Full')
  check((state / 'mode').read_text().strip() == 'read', 'the Full header control enters reading mode')
  action('header', '11', FZF_CLICK_HEADER_WORD='Index')
  check((state / 'mode').read_text().strip() == 'index', 'the Index header control returns to navigation')

  for width in [30, 48, 80, 120]:
    preview = subprocess.check_output(helper + ['preview', '03'], env=dict(os.environ, FZF_PREVIEW_COLUMNS=str(width)), text=True)
    check('Have some fun' in preview and '#have-some-fun' in preview, f'the preview renders at {width} columns')

  def terminal_session(interrupt=False):
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
          try: chunk = os.read(master, 65536)
          except OSError: return
          if not chunk: return
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
      if interrupt:
        send(b'\x03')
      else:
        send(b'\x1b[<0;27;5M\x1b[<0;27;5m')
        check(log.read_text().splitlines()[-1].endswith('#unite-the-nerds'), 'the real header mouse control opens the website')
        send(b'\x1b[<0;10;9M\x1b[<0;10;9m')
        send(b'w')
        check(log.read_text().splitlines()[-1].endswith('#have-some-fun'), 'the real mouse selects a principle and updates the browser target')
        send(b'1')
        send(b'j')
        send(b'\r')
        send(b'l')
        send(b'w')
        check(log.read_text().splitlines()[-1].endswith('#have-some-fun'), 'live keyboard navigation opens the correct principle online')
        send(b'f')
        check(b'The Omarchy Doctrine' in output, 'the full-document action renders the doctrine')
        send(b' ')
        fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack('HHHH', 24, 60, 0, 0))
        os.killpg(pid, signal.SIGWINCH)
        receive(0.2)
        send(b'\x1b')
        send(b'w')
        check(log.read_text().splitlines()[-1].endswith('#have-some-fun'), 'resize and returning from the full document preserve the selected principle')
        send(b'q')
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
  terminal_session()
  terminal_session(interrupt=True)
PY
