import hashlib
import importlib.util
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
import zipfile

for namespace in ('pid', 'user', 'mnt', 'net'):
  assert os.environ.get('OMARCHY_TEST_HOST_' + namespace)
  assert os.environ['OMARCHY_TEST_HOST_' + namespace] != os.readlink('/proc/self/ns/' + namespace)
ROOT = Path(os.environ['ROOT'])
sys.path.insert(0, str(ROOT / 'shell/plugins/services/idle'))


class PackTest(unittest.TestCase):
  def test_safe_install_and_approved_state_validation(self):
    self.assertIsNotNone(importlib.util.find_spec('pack'), 'Native pack reader/installer is missing')
    import pack
    with tempfile.TemporaryDirectory() as tmp:
      root = Path(tmp)
      files = {'demo/media/a.adf': b'media', 'demo/state.uss': b'ASF state',
               'demo/demo.fs-uae': b'[fs-uae]\nkickstart_file = internal\namiga_model = A500\nfloppy_drive_0 = $CONFIG/media/a.adf\n', 'demo/preview.png': b'preview'}
      sha = lambda p: hashlib.sha256(files[p]).hexdigest()
      variant = {'task_id': '1-1', 'review_status': 'Ok', 'settings': {'kickstart_file': 'internal', 'amiga_model': 'A500', 'floppy_drive_0': 'media/a.adf'}, 'state': 'state.uss', 'state_sha256': sha('demo/state.uss'), 'config': 'demo.fs-uae', 'media': [{'option': 'floppy_drive_0', 'path': 'media/a.adf', 'embedded_path': '/media/a.adf', 'sha256': sha('demo/media/a.adf')}]}
      # Each production owns its complete playback contract; the collection has no central catalog.
      config = {'schema': 'amiga-demo-v1', 'id': 'demo', 'title': 'Folder Demo',
                'preview': 'preview.png', 'variants': [variant]}
      files['demo/config.json'] = json.dumps(config).encode()
      files['SHA256SUMS'] = ''.join(f'{sha(p)}  {p}\n' for p in list(files)).encode()
      archive = root / 'pack.zip'
      with zipfile.ZipFile(archive, 'w') as z:
        for p, data in files.items():
          z.writestr('AMIGA/' + p, data)
      dest = root / 'Wallpapers/AMIGA'
      pack.install(archive, dest)
      pack.install(archive, dest)
      records = pack.load(dest)
      self.assertEqual(len(records), 1)
      self.assertEqual(records[0]['task_id'], '1-1')
      config_path_json = dest / 'demo/config.json'
      sums_path = dest / 'SHA256SUMS'
      original_demo_config = config_path_json.read_bytes()
      original_sums = sums_path.read_text()
      # A per-demo config must bind to its own folder, not a collection index.
      changed = json.loads(original_demo_config)
      changed['id'] = 'other'
      config_path_json.write_text(json.dumps(changed))
      sums_path.write_text(original_sums.replace(sha('demo/config.json'), pack.digest(config_path_json)))
      with self.assertRaisesRegex(ValueError, 'production ID'):
        pack.load(dest)
      config_path_json.write_bytes(original_demo_config)
      sums_path.write_text(original_sums)
      config_path = dest / 'demo/demo.fs-uae'
      original_config = config_path.read_text()
      # Real ConfigParser continuations, correctly checksum-bound, must not
      # become extra FS-UAE directives when the launcher serializes settings.
      for value in ('A500\n  load_state = 0', 'A500\tunsafe', 'A500\x7f', 'invented-model'):
        with self.subTest(value=value):
          changed = json.loads(original_demo_config)
          changed['variants'][0]['settings']['amiga_model'] = value.replace('\n  ', '\n')
          config_path_json.write_text(json.dumps(changed))
          config_path.write_text(original_config.replace('amiga_model = A500', 'amiga_model = ' + value))
          sums_path.write_text(original_sums.replace(sha('demo/config.json'), pack.digest(config_path_json)).replace(sha('demo/demo.fs-uae'), pack.digest(config_path)))
          with self.assertRaisesRegex(ValueError, 'configuration'):
            pack.load(dest)
      config_path_json.write_bytes(original_demo_config)
      config_path.write_text(original_config)
      sums_path.write_text(original_sums)
      (dest / 'demo/state.uss').write_bytes(b'changed')
      with self.assertRaises(ValueError):
        pack.load(dest)
      with self.assertRaises(ValueError):
        pack.install(archive, dest)
      self.assertEqual((dest / 'demo/state.uss').read_bytes(), b'changed')
      other = root / 'incompatible/AMIGA'
      (other / 'demo').mkdir(parents=True)
      (other / 'demo/user.txt').write_text('original')
      with self.assertRaises(ValueError):
        pack.install(archive, other)
      self.assertEqual((other / 'demo/user.txt').read_text(), 'original')
      self.assertFalse((other / 'demo/config.json').exists())


  def build_pack(self, root, production, title, media=b'media'):
    files = {f'{production}/media/a.adf': media, f'{production}/state.uss': b'ASF state',
             f'{production}/demo.fs-uae': b'[fs-uae]\nkickstart_file = internal\namiga_model = A500\nfloppy_drive_0 = $CONFIG/media/a.adf\n',
             f'{production}/preview.png': b'preview'}
    sha = lambda p: hashlib.sha256(files[p]).hexdigest()
    variant = {'task_id': production + '-1', 'review_status': 'Ok',
               'settings': {'kickstart_file': 'internal', 'amiga_model': 'A500', 'floppy_drive_0': 'media/a.adf'},
               'state': 'state.uss', 'state_sha256': sha(f'{production}/state.uss'), 'config': 'demo.fs-uae',
               'media': [{'option': 'floppy_drive_0', 'path': 'media/a.adf', 'embedded_path': '/media/a.adf',
                          'sha256': sha(f'{production}/media/a.adf')}]}
    config = {'schema': 'amiga-demo-v1', 'id': production, 'title': title, 'preview': 'preview.png', 'variants': [variant]}
    files[f'{production}/config.json'] = json.dumps(config).encode()
    files['SHA256SUMS'] = ''.join(f'{sha(p)}  {p}\n' for p in list(files)).encode()
    archive = root / (production + '-' + hashlib.sha256(media).hexdigest()[:8] + '.zip')
    with zipfile.ZipFile(archive, 'w') as z:
      for p, data in files.items():
        z.writestr('AMIGA/' + p, data)
    return archive

  def test_additional_pack_merges_checksums_and_conflicts_roll_back(self):
    import pack
    with tempfile.TemporaryDirectory() as tmp:
      root = Path(tmp)
      dest = root / 'Wallpapers/AMIGA'
      pack.install(self.build_pack(root, 'first', 'First'), dest)
      records = pack.install(self.build_pack(root, 'second', 'Second'), dest)
      self.assertEqual(sorted(r['task_id'] for r in records), ['first-1', 'second-1'])
      listed = pack.inventory(dest)
      self.assertTrue(any(name.startswith('first/') for name in listed))
      self.assertTrue(any(name.startswith('second/') for name in listed))
      before = (dest / 'SHA256SUMS').read_bytes()
      # Same production path, different bytes: refuse before touching anything.
      with self.assertRaisesRegex(ValueError, 'differs'):
        pack.install(self.build_pack(root, 'second', 'Second', media=b'other media'), dest)
      self.assertEqual((dest / 'SHA256SUMS').read_bytes(), before)
      self.assertEqual(sorted(r['task_id'] for r in pack.load(dest)), ['first-1', 'second-1'])
      # A pack that fails after moving its folders restores the previous list.
      original_load = pack.load
      calls = []
      def failing_load(root_path=None):
        calls.append(root_path)
        if Path(root_path) == dest:
          raise ValueError('late failure')
        return original_load(root_path)
      from unittest.mock import patch
      with patch.object(pack, 'load', side_effect=failing_load), self.assertRaisesRegex(ValueError, 'late failure'):
        pack.install(self.build_pack(root, 'third', 'Third'), dest)
      self.assertEqual((dest / 'SHA256SUMS').read_bytes(), before)
      self.assertFalse((dest / 'third').exists())

if __name__ == '__main__':
  unittest.main()
