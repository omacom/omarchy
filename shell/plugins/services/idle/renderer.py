"""Select acceleration by creating GL in the actual emulator sandbox."""
import os
from pathlib import Path
import re
import stat
import subprocess
import tempfile
import amiga

SOFTWARE = {'LIBGL_ALWAYS_SOFTWARE': '1', 'GALLIUM_DRIVER': 'llvmpipe', 'LP_NUM_THREADS': '2'}


def is_hardware(name):
  return bool(name.strip()) and not any(word in name.lower() for word in
    ('llvmpipe', 'softpipe', 'software', 'swrast', 'swiftshader'))


def render_nodes():
  # Never expose a card node, all of /dev/dri, or an input device.
  return [str(p) for p in sorted(Path('/dev/dri').glob('renderD*'))
          if re.fullmatch(r'renderD[0-9]+', p.name) and not p.is_symlink()
          and stat.S_ISCHR(p.stat().st_mode) and os.access(p, os.R_OK | os.W_OK)]


def arguments(selection):
  result = []
  if selection['node']:
    node = selection['node']
    result += ['--dev-bind', node, node, '--ro-bind', '/sys', '/sys']
  for key, value in selection['environment'].items():
    result += ['--setenv', key, value]
  return result


def probe(base, node):
  with tempfile.TemporaryFile(mode='w+') as log:
    process = amiga.launch_command(base + arguments({'node': node, 'environment': {}})
      + ['/opt/amiga/bin/gl-probe'], log)
    try:
      process.wait(timeout=8)
      log.seek(0)
      text = log.read()
      if process.returncode != 0:
        raise ValueError('GL initialization failed: ' + text[-1000:])
      lines = [line.removeprefix('AMIGA_GL_RENDERER=') for line in text.splitlines()
               if line.startswith('AMIGA_GL_RENDERER=')]
      if len(lines) != 1:
        raise ValueError('GL probe returned no unambiguous renderer')
      return lines[0]
    finally:
      amiga.stop(process)


def select(base, mode=None):
  mode = mode or os.environ.get('OMARCHY_AMIGA_RENDERER', 'auto')
  if mode not in ('auto', 'hardware', 'software'):
    raise ValueError('OMARCHY_AMIGA_RENDERER must be auto, hardware or software')
  failures = []
  if mode != 'software':
    for node in render_nodes():
      try:
        name = probe(base, node)
        if is_hardware(name):
          return {'node': node, 'environment': {}, 'renderer': name, 'mode': 'hardware'}
        failures.append(node + ': software renderer ' + name)
      except (ValueError, OSError, subprocess.SubprocessError) as error:
        failures.append(node + ': ' + str(error))
  if mode == 'hardware':
    raise ValueError('Hardware renderer unavailable: ' + '; '.join(failures))
  return {'node': None, 'environment': dict(SOFTWARE), 'renderer': 'software fallback',
          'mode': 'software', 'reason': '; '.join(failures) or ('debug override' if mode == 'software' else 'no accessible render node')}
