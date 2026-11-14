#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PYTHON'
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import xml.etree.ElementTree as ET

root = Path(sys.argv[1])
legacy = '''<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="pattern">
    <test name="family" qual="any">
      <string>monospace</string>
    </test>
    <edit name="family" mode="prepend_first" binding="strong">
      <string>Adwaita Mono</string>
    </edit>
  </match>
</fontconfig>
'''

with tempfile.TemporaryDirectory() as directory:
  work = Path(directory)
  home = work / 'home'
  config = home / '.config/fontconfig'
  dropin = config / 'conf.d/50-omarchy-monospace.conf'
  dropin.parent.mkdir(parents=True)
  env = dict(os.environ, HOME=str(home), XDG_CONFIG_HOME=str(home / '.config'), OMARCHY_PATH=str(root))

  def migrate(first=False, success=True):
    if first:
      subprocess.run(['bash', '-euo', 'pipefail', str(root / 'migrations/1791479460.sh')], env=env, check=True, capture_output=True)
    result = subprocess.run(['bash', '-euo', 'pipefail', str(root / 'migrations/1791479461.sh')], env=env, capture_output=True)
    assert (result.returncode == 0) == success, result.stderr.decode()
    return result

  def alias():
    node = ET.parse(dropin).getroot()
    assert node.find('match') is None
    assert node.find("alias/prefer/family").text == 'Adwaita Mono'

  # Prove the whole upgrade chain, including the exact spelling Greptile found.
  for label, data in [
    ('attribute spacing', legacy.replace('target="pattern"', 'target = "pattern"')),
    ('CRLF', legacy.replace('\n', '\r\n')),
    ('single line', legacy.replace('\n', '')),
    ('comments', legacy.replace('  <match', '  <!-- keep -->\n  <match')),
    ('internal comments', legacy.replace('<test name=', '<!-- keep --><test name=')),
  ]:
    dropin.unlink(missing_ok=True)
    source = config / 'fonts.conf'
    source.write_bytes(data.encode())
    migrate(first=True)
    assert not source.exists(), label
    alias()
    if 'comments' in label:
      assert b'<!-- keep -->' in dropin.read_bytes()
    before = dropin.read_bytes()
    migrate()
    assert dropin.read_bytes() == before
    print(f'ok - both migrations repair {label} and rerun unchanged')

  # Semantically identical XML spellings must also work in an existing drop-in.
  data = legacy.replace('target="pattern"', "target='pattern'").replace('name="family" qual="any"', 'qual="any" name="family"')
  dropin.write_text(data)
  migrate()
  alias()
  print('ok - alias migration accepts reordered attributes and single quotes')

  # Only one complete legacy rule is eligible; additional content stays intact.
  for label, data in [
    ('extra rule', legacy.replace('</fontconfig>', '<match target="font"><edit name="rgba"><const>rgb</const></edit></match></fontconfig>')),
    ('custom attribute', legacy.replace('qual="any"', 'qual="first"')),
    ('family spaces', legacy.replace('>monospace<', '> monospace <')),
    ('extra text', legacy.replace('<fontconfig>', '<fontconfig>custom')),
  ]:
    dropin.write_bytes(data.encode())
    migrate()
    assert dropin.read_bytes() == data.encode(), label
    print(f'ok - alias migration preserves {label} byte-identically')

  dropin.write_text(legacy.replace('Adwaita Mono', 'A &amp; B &lt;Mono&gt;'))
  migrate()
  assert ET.parse(dropin).find('alias/prefer/family').text == 'A & B <Mono>'
  print('ok - alias migration escapes decoded font names')

  target = work / 'linked.conf'
  target.write_text(legacy)
  target.chmod(0o640)
  dropin.unlink()
  dropin.symlink_to(target)
  migrate()
  alias()
  assert dropin.is_symlink() and target.stat().st_mode & 0o777 == 0o640
  print('ok - alias migration preserves symlink and target mode')
  dropin.unlink()

  data = b'<fontconfig><match'
  dropin.write_bytes(data)
  result = migrate(success=False)
  assert dropin.read_bytes() == data and str(dropin).encode() in result.stderr
  print('ok - malformed XML reports failure and stays unchanged')

  for data in [legacy.encode('utf-16'), legacy.replace('<!DOCTYPE fontconfig SYSTEM "fonts.dtd">', '<!DOCTYPE fontconfig [<!ENTITY font "Adwaita Mono">]>').replace('Adwaita Mono', '&font;').encode()]:
    dropin.write_bytes(data)
    migrate()
    assert dropin.read_bytes() == data
  print('ok - unsupported XML formats remain byte-identical')

  # Processing instructions may carry tool metadata at any document depth.
  # Neither migration nor setter may delete them while retiring an old rule.
  instruction = '<?tool preserve="yes"?>'
  instruction_cases = [
    ('prolog', legacy.replace('<fontconfig>', instruction + '<fontconfig>')),
    ('root', legacy.replace('<fontconfig>', '<fontconfig>' + instruction)),
    ('match', legacy.replace('<test name=', instruction + '<test name=')),
    ('test', legacy.replace('<string>monospace', instruction + '<string>monospace')),
    ('edit', legacy.replace('<string>Adwaita', instruction + '<string>Adwaita')),
    ('string', legacy.replace('Adwaita Mono', 'Adwaita' + instruction + ' Mono')),
    ('epilog', legacy + instruction),
    ('stylesheet', legacy.replace('<fontconfig>', '<?xml-stylesheet href="custom.xsl"?><fontconfig>')),
    ('generic string', legacy.replace('>monospace<', '>mono' + instruction + 'space<')),
  ]
  for label, data in instruction_cases:
    dropin.write_bytes(data.encode())
    result = migrate()
    alias()
    assert instruction.encode() in dropin.read_bytes() or b'<?xml-stylesheet' in dropin.read_bytes(), label
    assert b'prepend_first' not in dropin.read_bytes()
    source = config / 'fonts.conf'
    source.write_bytes(data.encode())
    subprocess.run(['bash', '-euo', 'pipefail', str(root / 'migrations/1791479460.sh')], env=env, check=True, capture_output=True)
    assert source.exists() and source.read_bytes() == data.encode(), label
    setter_env = dict(env, PATH=str(work / 'bin') + ':' + str(root / 'bin') + ':' + env['PATH'])
    (work / 'bin').mkdir(exist_ok=True)
    for name, body in [('fc-list', 'echo "Adwaita Mono"'), ('omarchy-cmd-present', 'exit 1'), ('pgrep', 'exit 1'), ('omarchy-restart-shell', 'exit 0'), ('omarchy-hook', 'exit 0'), ('omarchy-notification-send', 'exit 0')]:
      command = work / 'bin' / name
      command.write_text('#!/bin/bash\n' + body + '\n')
      command.chmod(0o755)
    result = subprocess.run(['bash', str(root / 'bin/omarchy-font-set'), 'Adwaita Mono'], env=setter_env, capture_output=True, check=True)
    assert source.read_bytes() == data.encode(), label
    assert b'processing instructions' in result.stderr
    assert ET.parse(dropin).find('alias/prefer/family').text == 'Adwaita Mono'
    source.unlink()
    print(f'ok - migration and setter retain {label} processing instructions')

  if os.geteuid() != 0:
    dropin.write_text(legacy)
    dropin.parent.chmod(0o500)
    try:
      migrate(success=False)
      assert dropin.read_text() == legacy
      assert not list(dropin.parent.glob('.50-omarchy-monospace.conf.*'))
    finally:
      dropin.parent.chmod(0o700)
    print('ok - failed staging preserves override and leaves no temporary file')

  # Native resolution through the VM/host rules with only the packaged default swapped.
  if Path('/etc/fonts/conf.d/48-guessfamily.conf').exists():
    families = subprocess.check_output(['fc-list', '-f', '%{family}\n']).decode()
    if 'Adwaita Mono' in families and 'iA Writer Mono S' in families:
      fixture = work / 'fixture'
      (fixture / 'conf.d').mkdir(parents=True)
      for file in Path('/etc/fonts/conf.d').glob('*.conf'):
        if file.name != '50-omarchy.conf':
          (fixture / 'conf.d' / file.name).symlink_to(file)
      (fixture / 'conf.d/50-omarchy.conf').write_bytes((root / 'default/fontconfig/conf.avail/50-omarchy.conf').read_bytes())
      system = Path('/etc/fonts/fonts.conf').read_text()
      include = '<include ignore_missing="yes">conf.d</include>'
      assert include in system, 'system include changed; fixture would not test candidate'
      (fixture / 'fonts.conf').write_text(system.replace(include, f'<include ignore_missing="yes">{fixture}/conf.d</include>'))
      env['FONTCONFIG_FILE'] = str(fixture / 'fonts.conf')
      env['XDG_CACHE_HOME'] = str(work / 'cache')
      dropin.unlink()
      (config / 'fonts.conf').write_text(legacy.replace('target="pattern"', 'target = "pattern"'))
      migrate(first=True)
      for request, expected in [('monospace', 'Adwaita Mono'), ('iA Writer Mono S', 'iA Writer Mono S')]:
        answer = subprocess.check_output(['fc-match', '-f', '%{family}', request], env=env).decode()
        assert expected in answer.split(','), (request, answer)
      print('ok - reformatted upgrade selects generic font without capturing named font')
      for label, data in instruction_cases:
        dropin.write_bytes(data.encode())
        migrate()
        for request, expected in [('monospace', 'Adwaita Mono'), ('iA Writer Mono S', 'iA Writer Mono S')]:
          answer = subprocess.check_output(['fc-match', '-f', '%{family}', request], env=env).decode()
          assert expected in answer.split(','), (label, request, answer)
        assert b'<?tool' in dropin.read_bytes() or b'<?xml-stylesheet' in dropin.read_bytes()
      print('ok - instruction-bearing aliases preserve metadata and native font resolution')
    else:
      print('ok - native resolution # SKIP required fonts unavailable')
  else:
    print('ok - native resolution # SKIP system fontconfig unavailable')
PYTHON
