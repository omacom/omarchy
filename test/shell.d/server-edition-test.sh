#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command python3
export SERVER_TEST_BASH=$BASH
python3 - <<'PY'
import os
import pathlib
import pty
import select
import subprocess
import tempfile

root = pathlib.Path(os.environ['ROOT'])
bash = os.environ['SERVER_TEST_BASH']

def check(condition, description):
  assert condition, description
  print('ok - ' + description)

with tempfile.TemporaryDirectory() as directory:
  tmp = pathlib.Path(directory)
  marker = tmp / 'edition'
  helper = tmp / 'omarchy-edition'
  # Redirect only the system marker in a disposable copy; never modify /etc.
  helper.write_text((root / 'bin/omarchy-edition').read_text().replace('/etc/omarchy-edition', str(marker)))
  helper.chmod(0o755)
  env = dict(os.environ, PATH=f'{tmp}:{root}/bin:' + os.environ['PATH'])
  def edition(*args):
    return subprocess.run([bash, str(helper), *args], env=env, capture_output=True, text=True)
  check(edition().stdout == 'desktop\n', 'missing marker defaults to desktop')
  for value in ['desktop', 'server', 'unknown']:
    marker.write_text(value + '\n')
    check(edition().stdout == value + '\n', 'reads edition marker: ' + value)
    for predicate in ['desktop', 'server']:
      result = subprocess.run([bash, str(root / ('bin/omarchy-edition-' + predicate))], env=env, capture_output=True)
      check(result.returncode == (0 if value == predicate else 1) and not result.stdout, 'quiet predicate: ' + value + '/' + predicate)
  check(edition('invalid').returncode == 2, 'invalid argument exits 2')
  marker.write_text('server\n')
  menu = tmp / 'omarchy-server-menu'
  menu.write_text('#!/bin/bash\nprintf GREETED\\\\n\n')
  menu.chmod(0o755)
  snippet = f'source "{root}/default/bash/server"'
  def greet(interactive=True, login=True, terminal=True, name='bash', **extra):
    child_env = dict(env, TERM='xterm')
    for key in ['SSH_ORIGINAL_COMMAND', 'TMUX']:
      child_env.pop(key, None)
    child_env.update(extra)
    args = [bash, '--noprofile', '--norc']
    if login:
      args.append('--login')
    if interactive:
      args.append('-i')
    args += ['-c', snippet, name]
    if terminal:
      master, slave = pty.openpty()
      try:
        result = subprocess.run(args, executable=bash, env=child_env, stdin=slave, stdout=slave, stderr=subprocess.PIPE, timeout=5)
        output = b''
        while select.select([master], [], [], 0.1)[0]:
          try:
            chunk = os.read(master, 4096)
            if not chunk:
              break
            output += chunk
          except OSError:
            break
      finally:
        if slave is not None:
          os.close(slave)
        os.close(master)
      return b'GREETED' in output
    result = subprocess.run(args, executable=bash, env=child_env, capture_output=True, timeout=5)
    return b'GREETED' in result.stdout
  check(greet(), 'interactive login with PTY greets')
  for options in [dict(interactive=False), dict(login=False), dict(terminal=False), dict(SSH_ORIGINAL_COMMAND='uptime'), dict(SSH_ORIGINAL_COMMAND=''), dict(TMUX='/tmp/tmux'), dict(TERM='dumb'), dict(name='scp'), dict(name='sftp'), dict(name='rsync')]:
    check(not greet(**options), 'greeting guard: ' + str(options))
  marker.write_text('desktop\n')
  check(not greet(), 'desktop login does not greet')

  marker.write_text('server\n')
  (tmp / 'gum').write_text('#!/bin/bash\nif [[ ! -e $SERVER_TEST_STATE ]]; then\n  touch "$SERVER_TEST_STATE"\n  echo Status\nelse\n  echo "[Q] Shell"\nfi\n')
  (tmp / 'btop').write_text('#!/bin/bash\necho STATUS_DOOR\nexit 1\n')
  for name in ['gum', 'btop']:
    (tmp / name).chmod(0o755)
  result = subprocess.run([bash, str(root / 'bin/omarchy-server-menu')], env=dict(env, SERVER_TEST_STATE=str(tmp / 'state')), capture_output=True, text=True, timeout=5)
  check(result.returncode == 0 and 'STATUS_DOOR' in result.stdout, 'failed door returns to menu and Shell returns to caller')
  (tmp / 'gum').write_text('#!/bin/bash\nexit 130\n')
  result = subprocess.run([bash, str(root / 'bin/omarchy-server-menu')], env=env, capture_output=True, timeout=5)
  check(result.returncode == 0, 'menu cancellation returns to shell')
PY
