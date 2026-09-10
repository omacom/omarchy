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
      variant = {'task_id': '1-1', 'review_status': 'Ok', 'settings': {'kickstart_file': 'internal', 'amiga_model': 'A500', 'floppy_drive_0': 'demo/media/a.adf'}, 'state': 'demo/state.uss', 'state_sha256': sha('demo/state.uss'), 'config': 'demo/demo.fs-uae', 'media': [{'option': 'floppy_drive_0', 'path': 'demo/media/a.adf', 'embedded_path': '/media/a.adf', 'sha256': sha('demo/media/a.adf')}]}
      catalog = {'schema': 'amiga-fullpack-v1', 'edition': 'top-minimal', 'counts': {'demos': 1, 'configurations': 1}, 'demos': [{'id': 'demo', 'title': 'Catalog Demo', 'preview': 'demo/preview.png', 'variants': [variant]}]}
      files['catalog.json'] = json.dumps(catalog).encode()
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
      catalog_path = dest / 'catalog.json'
      sums_path = dest / 'SHA256SUMS'
      original_catalog = catalog_path.read_bytes()
      original_sums = sums_path.read_text()
      for counts in (None, {'demos': True, 'configurations': 1}, {'demos': 1}):
        changed = json.loads(original_catalog)
        if counts is None:
          changed.pop('counts')
        else:
          changed['counts'] = counts
        catalog_path.write_text(json.dumps(changed))
        current = hashlib.sha256(catalog_path.read_bytes()).hexdigest()
        sums_path.write_text(original_sums.replace(sha('catalog.json'), current))
        with self.assertRaisesRegex(ValueError, 'count'):
          pack.load(dest)
      catalog_path.write_bytes(original_catalog)
      sums_path.write_text(original_sums)
      config_path = dest / 'demo/demo.fs-uae'
      original_config = config_path.read_text()
      # Real ConfigParser continuations, correctly checksum-bound, must not
      # become extra FS-UAE directives when the launcher serializes settings.
      for value in ('A500\n  load_state = 0', 'A500\tunsafe', 'A500\x7f', 'invented-model'):
        with self.subTest(value=value):
          changed = json.loads(original_catalog)
          changed['demos'][0]['variants'][0]['settings']['amiga_model'] = value.replace('\n  ', '\n')
          catalog_path.write_text(json.dumps(changed))
          config_path.write_text(original_config.replace('amiga_model = A500', 'amiga_model = ' + value))
          sums_path.write_text(original_sums.replace(sha('catalog.json'), pack.digest(catalog_path)).replace(sha('demo/demo.fs-uae'), pack.digest(config_path)))
          with self.assertRaisesRegex(ValueError, 'configuration'):
            pack.load(dest)
      catalog_path.write_bytes(original_catalog)
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
      self.assertFalse((other / 'catalog.json').exists())


if __name__ == '__main__':
  unittest.main()
