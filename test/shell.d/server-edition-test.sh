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
  for value in [' server\r\n', '\t desktop \r\n', '\n server \n']:
    marker.write_text(value)
    expected = value.strip()
    check(edition().stdout == expected + '\n' and edition(expected).returncode == 0, 'edition trims surrounding whitespace: ' + repr(value))
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
      check(b'command not found' not in result.stderr, 'login hook does not invoke a missing helper')
      return b'GREETED' in output
    result = subprocess.run(args, executable=bash, env=child_env, capture_output=True, timeout=5)
    return b'GREETED' in result.stdout
  helper.rename(tmp / 'saved-edition')
  check(not greet(PATH=str(tmp)), 'half-updated login without edition helper is inert')
  (tmp / 'saved-edition').rename(helper)
  check(greet(), 'interactive login with PTY greets')
  for options in [dict(interactive=False), dict(login=False), dict(terminal=False), dict(SSH_ORIGINAL_COMMAND='uptime'), dict(SSH_ORIGINAL_COMMAND=''), dict(TMUX='/tmp/tmux'), dict(TERM='dumb'), dict(name='scp'), dict(name='sftp'), dict(name='rsync')]:
    check(not greet(**options), 'greeting guard: ' + str(options))
  marker.write_text('desktop\n')
  check(not greet(), 'desktop login does not greet')

  marker.write_text('server\n')
  (tmp / 'gum').write_text('#!/bin/bash\nif [[ ! -e $SERVER_TEST_STATE ]]; then\n  touch "$SERVER_TEST_STATE"\n  echo Status\nelse\n  echo "Shell"\nfi\n')
  (tmp / 'btop').write_text('#!/bin/bash\necho STATUS_DOOR\nexit 1\n')
  for name in ['gum', 'btop']:
    (tmp / name).chmod(0o755)
  result = subprocess.run([bash, str(root / 'bin/omarchy-server-menu')], env=dict(env, SERVER_TEST_STATE=str(tmp / 'state')), capture_output=True, text=True, timeout=5)
  check(result.returncode == 0 and 'STATUS_DOOR' in result.stdout, 'failed door returns to menu and Shell returns to caller')
  (tmp / 'gum').write_text('#!/bin/bash\nprintf "%s\\n" "$@" >"$SERVER_TEST_CHOICES"\nif [[ ! -e $SERVER_TEST_STATE ]]; then\n  touch "$SERVER_TEST_STATE"\n  echo Network\nelse\n  echo Shell\nfi\n')
  (tmp / 'ip').write_text('#!/bin/bash\necho INTERFACES\n')
  (tmp / 'sudo').write_text('#!/bin/bash\necho UNEXPECTED_SUDO >&2\nexit 1\n')
  for name in ['ip', 'sudo']:
    (tmp / name).chmod(0o755)
  choices = tmp / 'choices'
  result = subprocess.run([bash, str(root / 'bin/omarchy-server-menu')], env=dict(env, SERVER_TEST_STATE=str(tmp / 'network-state'), SERVER_TEST_CHOICES=str(choices)), input='\n', capture_output=True, text=True, timeout=5)
  check(result.returncode == 0 and 'INTERFACES' in result.stdout and 'firewall: run omarchy setup security' in result.stdout and 'UNEXPECTED_SUDO' not in result.stderr, 'Network provides guidance without requesting privilege')
  check('Theme' not in choices.read_text().splitlines(), 'menu hides Theme until the terminal bridge exists')
  (tmp / 'gum').write_text('#!/bin/bash\nexit 130\n')
  result = subprocess.run([bash, str(root / 'bin/omarchy-server-menu')], env=env, capture_output=True, timeout=5)
  check(result.returncode == 0, 'menu cancellation returns to shell')
PY

python3 - <<'PY_PACKAGES'
import os
from pathlib import Path
root = Path(os.environ['ROOT'])
def packages(path):
  return {line for line in path.read_text().splitlines() if line and not line.startswith('#')}
base = packages(root / 'install/omarchy-base.packages')
path = root / 'install/omarchy-server.packages'
server = packages(path)
dropped = {line.removeprefix('# dropped: ') for line in path.read_text().splitlines() if line.startswith('# dropped: ')}
assert server - base == {'openssh'}, 'only openssh is a server-only addition'
assert not server & dropped, 'a package cannot be both retained and dropped'
assert base == (server - {'openssh'}) | dropped, 'every base package needs a retain/drop decision'
print('ok - server package subtraction accounts for every base package')
PY_PACKAGES
