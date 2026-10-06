echo "Rewrite the font override that captured every family named *mono*"

# `omarchy font set` wrote the chosen family as a prepend_first edit on any
# pattern carrying the monospace generic. /etc/fonts/conf.d/48-guessfamily.conf
# appends that generic to every pattern whose family name merely contains
# "mono", so the edit fired for a request naming Liberation Mono as readily as
# for one naming monospace, and put the chosen family at the head of the list,
# ahead of the family the application actually asked for. The previous
# migration moved that override into conf.d unchanged. Restate it as the alias
# it should have been, which inserts the family at the generic instead.

# Match XML structure, not spelling: the previous migration preserves formatting.
python3 - <<'PYTHON'
import os
from pathlib import Path
import sys
import tempfile
import xml.etree.ElementTree as ET
from xml.parsers import expat
from xml.sax.saxutils import escape

path = Path.home() / '.config/fontconfig/conf.d/50-omarchy-monospace.conf'


class ManualMigration(ValueError):
  pass


def override_range(data):
  parser = expat.ParserCreate()
  depth = 0
  start = 0
  spans = []
  comments = []

  def declaration(version, encoding, standalone):
    if encoding and encoding.lower() not in ('utf-8', 'utf8', 'ascii', 'us-ascii'):
      raise ManualMigration('non-UTF-8 XML encoding')

  def entity(*args):
    raise ManualMigration('custom XML entities')

  def opened(name, attrs):
    nonlocal depth, start
    if depth == 1:
      start = parser.CurrentByteIndex
    depth += 1

  def closed(name):
    nonlocal depth
    depth -= 1
    if depth == 1:
      end = parser.CurrentByteIndex
      if not data[start:end].rstrip().endswith(b'/>'):
        end = data.index(b'>', end) + 1
      spans.append((start, end))

  def comment(value):
    index = parser.CurrentByteIndex
    comments.append((index, data.index(b'-->', index) + 3))

  parser.CommentHandler = comment
  parser.XmlDeclHandler = declaration
  parser.EntityDeclHandler = entity
  parser.StartElementHandler = opened
  parser.EndElementHandler = closed
  parser.Parse(data, True)
  root = ET.fromstring(data, parser=ET.XMLParser(target=ET.TreeBuilder(insert_comments=True)))
  children = [item for item in root if item.tag is not ET.Comment]
  if root.tag != 'fontconfig' or root.attrib or len(children) != 1 or len(spans) != 1:
    return None
  if (root.text or '').strip() or any((item.tail or '').strip() for item in root):
    return None
  node = children[0]
  elements = [item for item in node if item.tag is not ET.Comment]
  if node.tag != 'match' or node.attrib != {'target': 'pattern'} or len(elements) != 2:
    return None
  test, edit = elements
  if test.tag != 'test' or test.attrib != {'name': 'family', 'qual': 'any'}:
    return None
  if edit.tag != 'edit' or edit.attrib != {'name': 'family', 'mode': 'prepend_first', 'binding': 'strong'}:
    return None
  tests = [item for item in test if item.tag is not ET.Comment]
  edits = [item for item in edit if item.tag is not ET.Comment]
  if len(tests) != 1 or len(edits) != 1:
    return None
  family, font = tests[0], edits[0]
  if any(item.tag != 'string' or item.attrib or len(item) for item in (family, font)):
    return None
  if family.text != 'monospace' or not font.text:
    return None
  if any((item.text or '').strip() for item in (node, test, edit)):
    return None
  if any((item.tail or '').strip() for item in [*node, *test, *edit]):
    return None
  start, end = spans[0]
  retained_comments = b''.join(data[a:b] + b'\n  ' for a, b in comments if start <= a < end)
  return (start, end, font.text, retained_comments)


try:
  if not path.exists():
    sys.exit(0)
  data = path.read_bytes()
  try:
    if b'\x00' in data:
      raise ManualMigration('non-UTF-8 XML encoding')
    data.decode('utf-8')
    recognized = override_range(data)
  except (UnicodeError, ManualMigration) as error:
    print(f'Leaving {path} unchanged ({error}); select a font again to replace its override.', file=sys.stderr)
    sys.exit(0)
  if recognized is None:
    sys.exit(0)
  start, end, font, comments = recognized
  alias = ('<alias binding="strong">\n'
           '    <family>monospace</family>\n'
           '    <prefer>\n'
           f'      <family>{escape(font)}</family>\n'
           '    </prefer>\n'
           '  </alias>').encode('utf-8')
  # Preserve comments and other surrounding bytes, and follow dotfile symlinks.
  target = path.resolve(strict=True)
  fd, temporary = tempfile.mkstemp(prefix='.' + target.name + '.', dir=target.parent)
  try:
    with os.fdopen(fd, 'wb') as stream:
      stream.write(data[:start] + comments + alias + data[end:])
      stream.flush()
      os.fsync(stream.fileno())
      os.fchmod(stream.fileno(), target.stat().st_mode & 0o777)
    os.replace(temporary, target)
  finally:
    if os.path.exists(temporary):
      os.unlink(temporary)
except (OSError, ValueError, ET.ParseError, expat.ExpatError) as error:
  print(f'Could not migrate {path}: {error}', file=sys.stderr)
  sys.exit(1)
PYTHON
