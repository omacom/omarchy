"""Renderer policy, in the mandatory outer namespace."""
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch
for ns in ('pid', 'user', 'mnt', 'net'):
  assert os.environ['OMARCHY_TEST_HOST_' + ns] != os.readlink('/proc/self/ns/' + ns)
sys.path.insert(0, str(Path(os.environ['ROOT']) / 'shell/plugins/services/idle'))

class RendererTest(unittest.TestCase):
  def test_hardware_policy(self):
    import importlib.util
    self.assertIsNotNone(importlib.util.find_spec('renderer'), 'Hardware policy missing')
    import renderer
    self.assertFalse(renderer.is_hardware('llvmpipe (LLVM 21)'))
    self.assertFalse(renderer.is_hardware('softpipe'))
    self.assertFalse(renderer.is_hardware('Software Rasterizer'))
    self.assertFalse(renderer.is_hardware(''))
    self.assertTrue(renderer.is_hardware('Mali-G610 (Panfrost)'))
    self.assertTrue(renderer.is_hardware('Mesa Intel UHD Graphics 620'))
    with patch.object(renderer, 'render_nodes', return_value=['/dev/dri/renderD128']), patch.object(renderer, 'probe', return_value='Mali-G610 (Panfrost)') as probe:
      selected = renderer.select(['bwrap'], mode='auto')
      self.assertEqual(selected['node'], '/dev/dri/renderD128')
      self.assertNotIn('LIBGL_ALWAYS_SOFTWARE', selected['environment'])
      probe.assert_called_once()
    with patch.object(renderer, 'render_nodes', return_value=['/dev/dri/renderD128']), patch.object(renderer, 'probe', return_value='llvmpipe'):
      selected = renderer.select(['bwrap'], mode='auto')
      self.assertIsNone(selected['node'])
      self.assertEqual(selected['environment']['LIBGL_ALWAYS_SOFTWARE'], '1')
      with self.assertRaises(ValueError): renderer.select(['bwrap'], mode='hardware')
    with patch.object(renderer, 'probe') as probe:
      renderer.select(['bwrap'], mode='software')
      probe.assert_not_called()
    with self.assertRaises(ValueError): renderer.select([], mode='invalid')

  def test_runtime_manifest_binds_architecture_and_every_required_file(self):
    import hashlib
    import json
    import runtime
    with tempfile.TemporaryDirectory() as tmp:
      root = Path(tmp)
      required = ('fs-uae/bin/fs-uae', 'audio/libopenal.so.1')
      all_files = required + ('controller/state.py',)
      for name in all_files:
        path = root / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(name.encode())
      sums = {name: hashlib.sha256(name.encode()).hexdigest() for name in all_files}
      (root / 'runtime-manifest.json').write_text(json.dumps({
        'schema_version': 1, 'architecture': 'x86_64', 'files': sums}))
      with patch.object(runtime.platform, 'machine', return_value='x86_64'):
        runtime.verify(root, required)
      (root / 'controller/state.py').write_bytes(b'changed controller')
      with patch.object(runtime.platform, 'machine', return_value='x86_64'), self.assertRaisesRegex(ValueError, 'hash'):
        runtime.verify(root, required)
      (root / 'controller/state.py').write_bytes(b'controller/state.py')
      (root / required[0]).write_bytes(b'changed')
      with patch.object(runtime.platform, 'machine', return_value='x86_64'), self.assertRaisesRegex(ValueError, 'hash'):
        runtime.verify(root, required)
      (root / required[0]).write_bytes(required[0].encode())
      with patch.object(runtime.platform, 'machine', return_value='riscv64'), self.assertRaisesRegex(ValueError, 'architecture'):
        runtime.verify(root, required)
      data = json.loads((root / 'runtime-manifest.json').read_text())
      del data['files'][required[1]]
      (root / 'runtime-manifest.json').write_text(json.dumps(data))
      with patch.object(runtime.platform, 'machine', return_value='x86_64'), self.assertRaisesRegex(ValueError, 'manifest'):
        runtime.verify(root, required)

if __name__ == '__main__': unittest.main()
