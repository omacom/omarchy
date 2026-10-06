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

path = Path.home() / '.config/fontconfig/conf.d/50-omarchy-monospace.conf'


class ManualMigration(ValueError):
  pass


def override_range(data):
  parser = expat.ParserCreate()
  depth = 0
  replacements = []

  def declaration(version, encoding, standalone):
    if encoding and encoding.lower() not in ('utf-8', 'utf8', 'ascii', 'us-ascii'):
      raise ManualMigration('non-UTF-8 XML encoding')

  def entity(*args):
    raise ManualMigration('custom XML entities')

  def opened(name, attrs):
    nonlocal depth
    if depth >= 1:
      index = parser.CurrentByteIndex
      replacement = {'match': b'<alias binding="strong">', 'test': b'',
                     'edit': b'<prefer>', 'string': b'<family>'}.get(name)
      replacements.append((index, data.index(b'>', index) + 1, replacement))
    depth += 1

  def closed(name):
    nonlocal depth
    depth -= 1
    if depth >= 1:
      index = parser.CurrentByteIndex
      replacement = {'match': b'</alias>', 'test': b'',
                     'edit': b'</prefer>', 'string': b'</family>'}.get(name)
      replacements.append((index, data.index(b'>', index) + 1, replacement))

  parser.XmlDeclHandler = declaration
  parser.EntityDeclHandler = entity
  parser.StartElementHandler = opened
  parser.EndElementHandler = closed
  parser.Parse(data, True)
  root = ET.fromstring(data, parser=ET.XMLParser(target=ET.TreeBuilder(insert_comments=True, insert_pis=True)))
  annotations = (ET.Comment, ET.ProcessingInstruction)
  children = [item for item in root if item.tag not in annotations]
  if root.tag != 'fontconfig' or root.attrib or len(children) != 1:
    return None
  if (root.text or '').strip() or any((item.tail or '').strip() for item in root):
    return None
  node = children[0]
  elements = [item for item in node if item.tag not in annotations]
  if node.tag != 'match' or node.attrib != {'target': 'pattern'} or len(elements) != 2:
    return None
  test, edit = elements
  if test.tag != 'test' or test.attrib != {'name': 'family', 'qual': 'any'}:
    return None
  if edit.tag != 'edit' or edit.attrib != {'name': 'family', 'mode': 'prepend_first', 'binding': 'strong'}:
    return None
  tests = [item for item in test if item.tag not in annotations]
  edits = [item for item in edit if item.tag not in annotations]
  if len(tests) != 1 or len(edits) != 1:
    return None
  family, font = tests[0], edits[0]
  if any(item.tag != 'string' or item.attrib or any(child.tag not in annotations for child in item) for item in (family, font)):
    return None
  def text(item):
    return (item.text or '') + ''.join(child.tail or '' for child in item)

  if text(family) != 'monospace' or not text(font):
    return None
  if any((item.text or '').strip() for item in (node, test, edit)):
    return None
  if any((item.tail or '').strip() for item in [*node, *test, *edit]):
    return None
  # Change only the element wrappers. Text, comments and processing
  # instructions stay in their original order and position within the rule.
  for start, end, replacement in sorted(replacements, reverse=True):
    data = data[:start] + replacement + data[end:]
  return data


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
  # Preserve comments and other surrounding bytes, and follow dotfile symlinks.
  target = path.resolve(strict=True)
  fd, temporary = tempfile.mkstemp(prefix='.' + target.name + '.', dir=target.parent)
  try:
    with os.fdopen(fd, 'wb') as stream:
      stream.write(recognized)
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
