"""Read-only SFTP v3 over the user's OpenSSH connection (no remote helper).

Wire format: https://www.openssh.org/specs.html (filexfer-02).
The client deliberately implements no write, remove, or exec-file operations.
"""
import hashlib
import os
from pathlib import Path
import re
import select
import shlex
import stat
import struct
import subprocess
import tempfile
import time


def target_value(value):
  if not value or value.startswith('-') or any(ord(c) < 33 for c in value):
    raise ValueError('Use an SSH alias, user@host, or ssh://user@host:port')
  authority = value.removeprefix('ssh://')
  if '@' in authority and ':' in authority.rsplit('@', 1)[0]:
    raise ValueError('Passwords must not be included in SSH targets')
  return value


def ssh_command(target):
  return ['ssh', '-T', '-oBatchMode=yes', '-oStrictHostKeyChecking=yes',
          '-oConnectTimeout=5', '-oConnectionAttempts=1', '-oServerAliveInterval=10',
          '-oServerAliveCountMax=1', '-oForwardAgent=no', '-oForwardX11=no',
          '-oClearAllForwardings=yes', target_value(target)]


def uint(value):
  return struct.pack('>I', value)


def string(value):
  value = value.encode() if isinstance(value, str) else value
  return uint(len(value)) + value


class Packet:
  def __init__(self, data):
    self.data = data
    self.offset = 0

  def take(self, size):
    if size < 0 or self.offset + size > len(self.data):
      raise OSError('Invalid SFTP response')
    value = self.data[self.offset:self.offset + size]
    self.offset += size
    return value

  def number(self):
    return struct.unpack('>I', self.take(4))[0]

  def string(self):
    return self.take(self.number())

  def attrs(self):
    flags = self.number()
    result = {}
    if flags & 1:
      result['size'] = struct.unpack('>Q', self.take(8))[0]
    if flags & 2:
      result.update(uid=self.number(), gid=self.number())
    if flags & 4:
      result['mode'] = self.number()
    if flags & 8:
      result.update(atime=self.number(), mtime=self.number())
    if flags & 0x80000000:
      for _ in range(self.number()):
        self.string()
        self.string()
    return result


class Sftp:
  def __init__(self, target=None, command=None, timeout=120):
    self.target = target
    self.deadline = time.monotonic() + timeout
    self.transferred = 0
    self.request_id = 0
    self.errors = tempfile.TemporaryFile()
    argv = command or (ssh_command(target)[:-1] + ['-s', target, 'sftp'])
    self.process = subprocess.Popen(argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                    stderr=self.errors, bufsize=0)
    try:
      self.send(bytes([1]) + uint(3))
      response = self.receive()
      if response.take(1) != bytes([2]) or response.number() != 3:
        raise OSError('SFTP version 3 is required')
    except Exception:
      self.close()
      raise

  def __enter__(self):
    return self

  def __exit__(self, *args):
    self.close()

  def close(self):
    if self.process.poll() is None:
      self.process.terminate()
      try:
        self.process.wait(timeout=2)
      except subprocess.TimeoutExpired:
        self.process.kill()
        self.process.wait()
    self.process.stdin.close()
    self.process.stdout.close()
    self.errors.close()

  def read_exact(self, count):
    result = bytearray()
    while len(result) < count:
      timeout = min(15, self.deadline - time.monotonic())
      if timeout <= 0 or not select.select([self.process.stdout], [], [], timeout)[0]:
        raise TimeoutError('SSH transfer timed out; the last successful usage is retained')
      block = os.read(self.process.stdout.fileno(), count - len(result))
      if not block:
        raise OSError('SSH/SFTP unavailable; check SSH access and the trusted host key in a terminal')
      result.extend(block)
    return bytes(result)

  def send(self, data):
    pending = memoryview(uint(len(data)) + data)
    while pending:
      written = self.process.stdin.write(pending)
      if not written:
        raise OSError('SSH transport closed')
      pending = pending[written:]

  def receive(self):
    size = struct.unpack('>I', self.read_exact(4))[0]
    if size > 2 * 1024 * 1024:
      raise OSError('Oversized SFTP response')
    return Packet(self.read_exact(size))

  def request(self, kind, payload=b''):
    self.request_id += 1
    self.send(bytes([kind]) + uint(self.request_id) + payload)
    response = self.receive()
    tag = response.take(1)[0]
    if response.number() != self.request_id:
      raise OSError('Unexpected SFTP response identity')
    if tag == 101:
      status = response.number()
      if status == 1:
        raise EOFError()
      if status == 2:
        raise FileNotFoundError()
      if status == 3:
        raise PermissionError('A usage source is not readable by this SSH account')
      if status:
        raise OSError('SFTP operation failed')
    return tag, response

  def realpath(self, path):
    tag, packet = self.request(16, string(path))
    if tag != 104 or packet.number() != 1:
      raise OSError('Cannot resolve remote home directory')
    return packet.string().decode('utf-8')

  def attrs(self, path):
    tag, packet = self.request(7, string(path))
    if tag != 105:
      raise OSError('Missing SFTP file attributes')
    return packet.attrs()

  def listdir(self, path):
    _, packet = self.request(11, string(path))
    handle = packet.string()
    try:
      while True:
        try:
          tag, packet = self.request(12, string(handle))
        except EOFError:
          break
        if tag != 104:
          raise OSError('Invalid SFTP directory response')
        for _ in range(packet.number()):
          name = packet.string().decode('utf-8')
          packet.string()
          attrs = packet.attrs()
          if name in ('.', '..'):
            continue
          if '/' in name or '\x00' in name:
            raise OSError('Invalid remote file name')
          yield name, attrs
    finally:
      self.request(4, string(handle))

  def read(self, path, offset=0, length=32768):
    _, packet = self.request(3, string(path) + uint(1) + uint(0))
    handle = packet.string()
    chunks = []
    try:
      while length:
        try:
          tag, packet = self.request(5, string(handle) + struct.pack('>Q', offset) + uint(min(length, 32768)))
        except EOFError:
          break
        if tag != 103:
          raise OSError('Invalid SFTP file response')
        block = packet.string()
        if not block:
          break
        chunks.append(block)
        offset += len(block)
        length -= len(block)
        self.transferred += len(block)
    finally:
      self.request(4, string(handle))
    return b''.join(chunks)

  def walk(self, root):
    try:
      if not stat.S_ISDIR(self.attrs(root).get('mode', 0)):
        raise OSError('Usage source must be a directory, not a symlink')
    except FileNotFoundError:
      return
    pending = [root]
    count = 0
    while pending:
      directory = pending.pop()
      try:
        entries = list(self.listdir(directory))
      except FileNotFoundError:
        continue
      for name, attrs in entries:
        count += 1
        if count > 100000:
          raise OSError('Usage inventory exceeds 100,000 entries')
        path = directory + '/' + name
        mode = attrs.get('mode', 0)
        if stat.S_ISDIR(mode):
          pending.append(path)
        elif stat.S_ISREG(mode):
          yield path, attrs
        elif stat.S_ISLNK(mode):
          raise OSError('Symlinked usage sources need an explicit source path')

  def identity(self):
    # Ask the login account, never infer it from an SFTP directory's owner.
    # This constant command uses existing OS tools and writes no remote files.
    result = subprocess.run(ssh_command(self.target) + [IDENTITY_COMMAND],
                            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=15, check=True)
    parts = result.stdout.decode('utf-8').splitlines()
    if len(parts) < 5:
      raise OSError('Cannot establish the Linux/macOS machine and SSH user identity')
    platform, uid, user, home = parts[:4]
    if not uid.isdecimal() or not user or not home.startswith('/'):
      raise OSError('Cannot establish SSH user identity and home directory')
    if platform == 'Linux':
      machine = parts[4].lower()
      if len(parts) != 5 or not re.fullmatch('[0-9a-f]{32}', machine):
        raise OSError('Invalid Linux machine identity')
    elif platform == 'Darwin':
      match = re.search(r'"IOPlatformUUID"\s*=\s*"([A-Fa-f0-9]{8}(?:-[A-Fa-f0-9]{4}){3}-[A-Fa-f0-9]{12})"', '\n'.join(parts[4:]))
      if not match:
        raise OSError('Invalid macOS machine identity')
      machine, platform = match[1].lower(), 'macOS'
    else:
      raise OSError('Only Linux and macOS computers are supported')
    directory = self.realpath(home)
    if not stat.S_ISDIR(self.attrs(directory).get('mode', 0)):
      raise OSError('SSH user home is not a readable directory')
    return {'identity': account_identity(platform, machine, int(uid)), 'platform': platform,
            'home': directory, 'uid': int(uid), 'user': user}


# SSH invokes the login shell; explicitly choose POSIX sh for fish/csh users.
IDENTITY_COMMAND = "/bin/sh -c " + shlex.quote(r"""set -eu
platform=$(uname -s)
printf '%s\n' "$platform"
id -u
id -un
printf '%s\n' "$HOME"
case "$platform" in
  Linux) cat /etc/machine-id ;;
  Darwin) ioreg -rd1 -c IOPlatformExpertDevice ;;
  *) exit 1 ;;
esac""")


def account_identity(platform, machine, uid):
  return hashlib.sha256(f'{platform}:{machine}:{uid}'.encode()).hexdigest()


def local_identity():
  try:
    machine = Path('/etc/machine-id').read_text().strip()
    return account_identity('Linux', machine, os.getuid())
  except OSError:
    return None
