"""Stream legacy clipboard text to files before handing bounded JSON to QML.

Only the current entry and the small resulting history are held in memory.
Large JSON strings are decoded in chunks, including escapes and surrogate pairs.
The original is archived before entries are converted or skipped. Migration and
QML saves share one lock and atomic writer; failed writes preserve saved history.
"""

import fcntl
import hashlib
import json
import os
import re
import signal
import stat
import sys
import tempfile
import time
from contextlib import ExitStack, contextmanager
from pathlib import Path

INLINE_LIMIT = 256 * 1024
LARGE_LIMIT = 256 * 1024 * 1024
LARGE_BUDGET = 1024 * 1024 * 1024
HISTORY_BUDGET = 8 * 1024 * 1024
PREVIEW_LIMIT = 8192
SPECIAL = re.compile(r'["\\\x00-\x1f]')
JS_SPACE = '\t\n\v\f\r \u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u2028\u2029\u202f\u205f\u3000\ufeff'


class StorageLimit(Exception):
  pass


class Reader:
  def __init__(self, source):
    self.source = source
    self.buffer = ''
    self.index = 0

  def peek(self):
    if self.index == len(self.buffer):
      self.buffer = self.source.read(65536)
      self.index = 0
    return self.buffer[self.index:self.index + 1]

  def take(self):
    value = self.peek()
    if not value:
      raise ValueError('unexpected end of JSON')
    self.index += 1
    return value

  def expect(self, value):
    if self.take() != value:
      raise ValueError('unexpected JSON token')

  def space(self):
    while self.peek() and self.peek() in ' \t\r\n':
      self.index += 1

  def string(self, emit):
    self.expect('"')
    escapes = {'"': '"', '\\': '\\', '/': '/', 'b': '\b', 'f': '\f', 'n': '\n', 'r': '\r', 't': '\t'}
    while self.peek():
      match = SPECIAL.search(self.buffer, self.index)
      end = match.start() if match else len(self.buffer)
      if end > self.index:
        emit(self.buffer[self.index:end])
        self.index = end
      if not match:
        continue
      value = self.take()
      if value == '"':
        return
      if value != '\\':
        raise ValueError('unescaped control character')
      escaped = self.take()
      if escaped in escapes:
        emit(escapes[escaped])
      elif escaped == 'u':
        digits = ''.join(self.take() for _ in range(4))
        if not re.fullmatch('[0-9a-fA-F]{4}', digits):
          raise ValueError('invalid Unicode escape')
        code = int(digits, 16)
        if 0xD800 <= code <= 0xDBFF:
          self.expect('\\')
          self.expect('u')
          digits = ''.join(self.take() for _ in range(4))
          if not re.fullmatch('[0-9a-fA-F]{4}', digits):
            raise ValueError('invalid surrogate pair')
          low = int(digits, 16)
          if not 0xDC00 <= low <= 0xDFFF:
            raise ValueError('invalid surrogate pair')
          code = 0x10000 + ((code - 0xD800) << 10) + low - 0xDC00
        elif 0xDC00 <= code <= 0xDFFF:
          raise ValueError('unpaired surrogate')
        emit(chr(code))
      else:
        raise ValueError('invalid JSON escape')
    raise ValueError('unterminated JSON string')

  def value(self, stack, text=False, depth=0):
    if depth > 32:
      raise ValueError('JSON nesting exceeds limit')
    self.space()
    token = self.peek()
    if token == '"':
      if text:
        value = Text(stack)
        self.string(value.write)
        return value
      chunks = []
      size = 0
      def collect(chunk):
        nonlocal size
        size += len(chunk)
        if size > 65536:
          raise ValueError('oversized clipboard metadata')
        chunks.append(chunk)
      self.string(collect)
      return ''.join(chunks)
    if token in ('{', '['):
      opening = self.take()
      closing = '}' if opening == '{' else ']'
      values = {} if opening == '{' else []
      self.space()
      if self.peek() == closing:
        self.take()
        return values
      for _ in range(64):
        key = None
        if opening == '{':
          key = self.value(stack, depth=depth + 1)
          if not isinstance(key, str):
            raise ValueError('object key must be a string')
          self.space()
          self.expect(':')
        value = self.value(stack, text=key == 'text' and depth == 0, depth=depth + 1)
        if opening == '{':
          values[key] = value
        else:
          values.append(value)
        self.space()
        delimiter = self.take()
        if delimiter == closing:
          return values
        if delimiter != ',':
          raise ValueError('invalid JSON delimiter')
        self.space()
      raise ValueError('oversized clipboard metadata')
    scalar = ''
    while self.peek() and self.peek() not in ',]} \t\r\n':
      scalar += self.take()
      if len(scalar) > 128:
        raise ValueError('oversized JSON scalar')
    return json.loads(scalar, parse_constant=lambda _: (_ for _ in ()).throw(ValueError('invalid JSON constant')))


class Text:
  def __init__(self, stack):
    self.file = stack.enter_context(tempfile.SpooledTemporaryFile(max_size=INLINE_LIMIT))
    self.digest = hashlib.sha256()
    self.size = 0
    self.preview = b''
    self.nonempty = False

  def write(self, chunk):
    data = chunk.encode('utf-8')
    self.size += len(data)
    if self.size > LARGE_LIMIT:
      self.file.close()
      return
    self.digest.update(data)
    self.file.write(data)
    self.preview += data[:max(0, PREVIEW_LIMIT - len(self.preview))]
    self.nonempty = self.nonempty or bool(chunk.strip(JS_SPACE))

  def inline(self):
    self.file.seek(0)
    return {'type': 'text', 'text': self.file.read().decode('utf-8')}

  def descriptor(self, directory):
    path = directory / (self.digest.hexdigest() + '.txt')
    return {'type': 'largetext', 'path': str(path), 'bytes': self.size, 'preview': self.preview.decode('utf-8', errors='ignore')}

  def external(self, directory):
    directory.mkdir(parents=True, exist_ok=True)
    if directory.is_symlink():
      raise OSError('clipboard-text is a symlink')
    path = directory / (self.digest.hexdigest() + '.txt')
    self.file.seek(0)
    with tempfile.NamedTemporaryFile(dir=directory, prefix='clipboard.', delete=False) as output:
      temporary = Path(output.name)
      try:
        while data := self.file.read(65536):
          output.write(data)
        output.flush()
        os.fsync(output.fileno())
        os.replace(temporary, path)
      finally:
        temporary.unlink(missing_ok=True)
    return self.descriptor(directory)


def encoded(value):
  return json.dumps(value, ensure_ascii=False, separators=(',', ':'), allow_nan=False).encode('utf-8')


def migrate(source, directory, ceiling):
  reader = Reader(source)
  result = []
  used = 2
  large_used = 0
  changed = False
  skipped = False
  budget = min(ceiling, HISTORY_BUDGET)
  reader.space()
  if not reader.peek():
    return b'[]', False, False
  reader.expect('[')
  reader.space()
  if reader.peek() != ']':
    while True:
      with ExitStack() as stack:
        value = reader.value(stack, text=reader.peek() == '"')
        text = value if isinstance(value, Text) else value.get('text') if isinstance(value, dict) and value.get('type', value.get('kind')) == 'text' else None
        entry = None
        pending_text = None
        if isinstance(text, Text) and text.nonempty and text.size <= LARGE_LIMIT:
          if text.size <= INLINE_LIMIT:
            entry = text.inline()
          if entry is None or used + len(encoded(entry)) + 1 > budget:
            entry = text.descriptor(directory)
            pending_text = text
            changed = True
        elif isinstance(value, dict):
          kind = value.get('type', value.get('kind'))
          if kind == 'image' and isinstance(value.get('path'), str) and value['path']:
            entry = {'type': 'image', 'path': value['path'], 'mime': value.get('mime') or 'image/png'}
            if value.get('capturedAt') is not None:
              entry['capturedAt'] = str(value['capturedAt'])
          elif kind == 'largetext':
            path = value.get('path', '')
            size = value.get('bytes')
            if (isinstance(path, str) and re.fullmatch(r'/(?:[^/]+/)*omarchy/clipboard-text/[0-9a-f]{64}\.txt', path)
                and '..' not in Path(path).parts
                and isinstance(size, (int, float)) and not isinstance(size, bool) and 0 < size <= LARGE_LIMIT and int(size) == size):
              entry = {'type': 'largetext', 'path': path, 'bytes': int(size), 'preview': str(value.get('preview') or '')[:PREVIEW_LIMIT]}
        if entry:
          size = len(encoded(entry)) + 1
          # Legacy histories may have used UTF-16 units instead of UTF-8 bytes.
          # Spill earlier inline entries to make room for later small entries.
          for index in range(len(result) - 1, -1, -1):
            if used + size <= budget:
              break
            previous = result[index]
            if previous['type'] != 'text':
              continue
            replacement = Text(stack)
            replacement.write(previous['text'])
            descriptor = replacement.descriptor(directory)
            saving = len(encoded(previous)) - len(encoded(descriptor))
            if saving <= 0 or large_used + entry.get('bytes', 0) + replacement.size > LARGE_BUDGET:
              continue
            result[index] = replacement.external(directory)
            used -= saving
            large_used += replacement.size
            changed = True
          if len(result) >= 500 or used + size > budget or large_used + entry.get('bytes', 0) > LARGE_BUDGET:
            changed = True
            skipped = True
          else:
            if pending_text:
              pending_text.external(directory)
            used += size
            large_used += entry.get('bytes', 0)
            result.append(entry)
        else:
          changed = True
          skipped = True
      reader.space()
      delimiter = reader.take()
      if delimiter == ']':
        break
      if delimiter != ',':
        raise ValueError('invalid history delimiter')
      reader.space()
  else:
    reader.take()
  reader.space()
  if reader.peek():
    raise ValueError('more than one JSON document')
  return encoded(result), changed, skipped


@contextmanager
def history_lock(path):
  path.parent.mkdir(parents=True, exist_ok=True)
  descriptor = os.open(str(path) + '.lock', os.O_RDWR | os.O_CREAT | os.O_NOFOLLOW | os.O_NONBLOCK, 0o600)
  try:
    if not stat.S_ISREG(os.fstat(descriptor).st_mode):
      raise OSError('history lock is not a regular file')
    fcntl.flock(descriptor, fcntl.LOCK_EX)
    yield
  finally:
    os.close(descriptor)


def atomic_write(path, payload, original=None, backup=False):
  with tempfile.NamedTemporaryFile(dir=path.parent, prefix='clipboard-history.', delete=False) as output:
    temporary = Path(output.name)
    try:
      output.write(payload)
      output.flush()
      os.fsync(output.fileno())
      if original is not None:
        current = path.lstat()
        if (current.st_dev, current.st_ino, current.st_size, current.st_mtime_ns) != (original.st_dev, original.st_ino, original.st_size, original.st_mtime_ns):
          raise OSError('history changed during migration')
      if backup:
        recovery = str(path) + '.migrated-' + str(time.time_ns())
        os.link(path, recovery, follow_symlinks=False)
        print('clipboard: migrated existing history; original kept at ' + recovery, file=sys.stderr)
      os.replace(temporary, path)
    finally:
      temporary.unlink(missing_ok=True)


def reject(path):
  backup = str(path) + '.rejected-' + str(time.time_ns())
  os.rename(path, backup)
  print('clipboard: history set aside at ' + backup, file=sys.stderr)
  return b'[]'


def load_history(path, directory, ceiling):
  try:
    info = path.lstat()
  except FileNotFoundError:
    return b'[]'
  if not stat.S_ISREG(info.st_mode):
    return reject(path)
  try:
    flags = os.O_RDONLY | os.O_NOFOLLOW | os.O_NONBLOCK
    with os.fdopen(os.open(path, flags), 'r', encoding='utf-8', newline='') as source:
      original = os.fstat(source.fileno())
      if not stat.S_ISREG(original.st_mode):
        raise OSError('history is not a regular file')
      payload, changed, skipped = migrate(source, directory, ceiling)
      source.seek(0)
      digest = hashlib.sha256()
      while chunk := source.read(65536):
        digest.update(chunk.encode('utf-8'))
  except (ValueError, UnicodeError, RecursionError) as error:
    print('clipboard: invalid history: ' + str(error), file=sys.stderr)
    return reject(path)
  if digest.digest() != hashlib.sha256(payload).digest():
    atomic_write(path, payload, original=original, backup=changed)
  if skipped:
    print('clipboard: some entries kept only in the recovery backup', file=sys.stderr)
  return payload


def save_history(path, ceiling):
  # All QML saves use this same lock and atomic writer as migration. FileView
  # watches the path but never writes it, so a pending save cannot land halfway
  # through a migration commit.
  budget = min(ceiling, HISTORY_BUDGET)
  raw = sys.stdin.buffer.read(budget + 1)
  if len(raw) > budget:
    raise StorageLimit('save exceeds the history byte budget')
  entries = json.loads(raw, parse_constant=lambda _: (_ for _ in ()).throw(ValueError('invalid JSON constant')))
  if not isinstance(entries, list) or len(entries) > 500:
    raise ValueError('save must be a history of at most 500 entries')
  payload = encoded(entries)
  if len(payload) > budget:
    raise StorageLimit('save exceeds the history byte budget')
  if path.is_symlink() or path.exists() and not path.is_file():
    raise OSError('history is not a regular file')
  atomic_write(path, payload)


def main():
  saving = sys.argv[1] == '--save'
  args = sys.argv[2:] if saving else sys.argv[1:]
  path = Path(args[0])
  ceiling = int(args[1])
  state = Path(os.environ.get('XDG_STATE_HOME') or Path.home() / '.local/state')
  directory = state / 'omarchy/clipboard-text'
  with history_lock(path):
    if saving:
      save_history(path, ceiling)
    else:
      sys.stdout.buffer.write(load_history(path, directory, ceiling))


if __name__ == '__main__':
  # Let temporary-file and lock cleanup run if the wrapper's deadline expires.
  signal.signal(signal.SIGTERM, lambda *_: sys.exit(143))
  try:
    main()
  except (OSError, StorageLimit, ValueError, UnicodeError, RecursionError) as error:
    print('clipboard: history operation failed: ' + str(error) + '; previous history kept', file=sys.stderr)
    sys.exit(3)
