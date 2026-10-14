import os
import pathlib
import pwd
import signal
import shutil
import socket
import subprocess
import tempfile
import time

root = pathlib.Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory(prefix='theme-ssh-') as directory:
  stage = pathlib.Path(directory)
  for name in ('host', 'identity'):
    subprocess.run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '', '-f', str(stage / name)], check=True)
  try:
    with socket.socket() as port_probe:
      port_probe.bind(('127.0.0.1', 0))
      port = port_probe.getsockname()[1]
  except PermissionError:
    print('ok - sandbox blocks loopback sockets; skipping real SSH connection reuse # SKIP')
    raise SystemExit(0)
  remote = stage / 'remote'
  remote.write_text('#!/bin/bash\ncat >>"' + str(stage / 'received') + '"\necho theme-received\n')
  remote.chmod(0o700)
  server_config = stage / 'sshd.conf'
  server_config.write_text(f'''Port {port}
ListenAddress 127.0.0.1
HostKey {stage / 'host'}
PidFile {stage / 'server.pid'}
AuthorizedKeysFile {stage / 'identity.pub'}
PasswordAuthentication no
KbdInteractiveAuthentication no
UsePAM no
StrictModes no
AllowUsers {pwd.getpwuid(os.getuid()).pw_name}
LogLevel VERBOSE
ForceCommand /bin/bash {remote}
''')
  host_key = (stage / 'host.pub').read_text().split()
  (stage / 'known_hosts').write_text(f'[127.0.0.1]:{port} {host_key[0]} {host_key[1]}\n')
  client_config = stage / 'ssh.conf'
  client_config.write_text(f'''Host fixture
  HostName 127.0.0.1
  Port {port}
  User {pwd.getpwuid(os.getuid()).pw_name}
  IdentityFile {stage / 'identity'}
  IdentityAgent none
  IdentitiesOnly yes
  StrictHostKeyChecking yes
  UserKnownHostsFile {stage / 'known_hosts'}
''')
  home = stage / 'home'
  current = home / '.local/state/omarchy/current'
  current.mkdir(parents=True)
  toggles = home / '.local/state/omarchy/toggles'
  toggles.mkdir()
  (toggles / 'herdr-theme-sync').touch()
  runtime = stage / 'run'
  runtime.mkdir(mode=0o700)
  stub_bin = stage / 'bin'
  stub_bin.mkdir()
  scripts = {
    'herdr': "#!/bin/bash\nprintf 'id\\tfixture\\tfixture\\tdefault\\tenabled\\n'\n",
    'ssh': '#!/bin/bash\nexec /usr/bin/ssh -F "' + str(client_config) + '" "$@"\n',
  }
  for name, content in scripts.items():
    path = stub_bin / name
    path.write_text(content)
    path.chmod(0o700)
  environment = {**os.environ, 'HOME': str(home), 'XDG_RUNTIME_DIR': str(runtime), 'PATH': str(stub_bin) + ':' + str(root / 'bin') + ':' + os.environ['PATH']}
  log_path = stage / 'sshd.log'
  with log_path.open('w') as log:
    server = subprocess.Popen([shutil.which('sshd'), '-D', '-e', '-f', str(server_config)], stdout=log, stderr=log, start_new_session=True)
    try:
      deadline = time.monotonic() + 5
      while True:
        try:
          with socket.create_connection(('127.0.0.1', port), timeout=0.1):
            break
        except OSError:
          if server.poll() is not None and 'Missing privilege separation directory' in log_path.read_text():
            print('ok - SSH server runtime directory is unavailable; skipping real SSH connection reuse # SKIP')
            raise SystemExit(0)
          assert server.poll() is None and time.monotonic() < deadline, log_path.read_text()
          time.sleep(0.05)
      for theme in ('tokyo-night', 'nord'):
        (current / 'theme.name').write_text(theme + '\n')
        result = subprocess.run([str(root / 'bin/omarchy-theme-set-herdr-machines')], env=environment, capture_output=True, text=True, timeout=10)
        assert result.returncode == 0 and 'theme-received' in result.stdout, (result.stdout, result.stderr, log_path.read_text())
        if theme == 'tokyo-night':
          (stage / 'identity').rename(stage / 'identity-unavailable')
      assert log_path.read_text().count('Accepted publickey') == 1, log_path.read_text()
      received = (stage / 'received').read_text()
      assert 'theme=tokyo-night' in received and 'theme=nord' in received
      assert (runtime / 'omarchy-theme-sync').stat().st_mode & 0o777 == 0o700
      lock = runtime / 'omarchy-theme-set-herdr-machines.lock'
      assert subprocess.run(['flock', '-n', str(lock), 'true']).returncode == 0, 'SSH master retained the theme sync lock'
      print('ok - two theme syncs authenticate once, even with the key removed before the second sync')
      print('ok - persistent SSH master leaves the sync lock available')
    finally:
      subprocess.run(['/usr/bin/ssh', '-F', str(client_config), '-o', 'ControlPath=' + str(runtime / 'omarchy-theme-sync/%C'), '-O', 'exit', 'fixture'], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=5)
      if server.poll() is None:
        os.killpg(server.pid, signal.SIGTERM)
      server.wait(timeout=5)
