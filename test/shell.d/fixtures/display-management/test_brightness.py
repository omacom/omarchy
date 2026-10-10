import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import Mock, patch

import brightness_backend as backend
import brightness_devices as devices
from brightness_devices import BrightnessError, Display
import monitor_state


def edid(identifier):
  data = bytearray(b'\x00\xff\xff\xff\xff\xff\xff\x00' + bytes(120))
  data[12] = identifier
  data[127] = -sum(data) % 256
  return bytes(data)


class BrightnessTests(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.root = Path(self.tmp.name)
    env = patch.dict(os.environ, XDG_RUNTIME_DIR=str(self.root), XDG_CONFIG_HOME=str(self.root))
    env.start()
    self.addCleanup(env.stop)
    self.monitors = [dict(name=f'DP-{i}', description=f'Monitor {i}', serialNumber=str(i),
               focused=i == 1) for i in (1, 2)]
    self.displays = [Display(f'DP-{i}', self.root / f'card0-DP-{i}', edid(i), f'token-{i}') for i in (1, 2)]
    self.adapter = Mock(backend='ddc', scope='unknown', key='bus2')
    self.adapter.read.return_value = 42
    for target, attribute, value in ((monitor_state, 'hypr', json.dumps(self.monitors)),
                    (monitor_state, 'hardware_displays', self.displays),
                    (backend, 'resolve', self.adapter)):
      mocked = patch.object(target, attribute, return_value=value)
      mocked.start()
      self.addCleanup(mocked.stop)

  def control(self, value=None, token='token-2'):
    return monitor_state.brightness('DP-2', 'Monitor 2', value, token)

  def assert_status(self, status, result):
    self.assertEqual(result['status'], status)
    self.assertIsNone(result['brightness'])

  def test_selection_is_not_focus_and_scope_is_not_inferred(self):
    result = self.control()
    self.assertEqual(result['brightness'], 42)
    self.assertEqual(backend.resolve.call_args.args[0].name, 'DP-2')
    self.assertEqual(result['scope'], 'unknown')
    self.assertEqual(result['affectedDisplays'], [])

  def test_stale_hardware_identity_blocks_read_and_write(self):
    for value in (None, 50):
      self.assert_status('disconnected', self.control(value, 'old-token'))
    backend.resolve.assert_not_called()

  def test_reused_connector_description_blocks_access(self):
    result = monitor_state.brightness('DP-2', 'Replacement', 50, 'token-2')
    self.assert_status('disconnected', result)
    backend.resolve.assert_not_called()

  def test_missing_token_blocks_write(self):
    self.assert_status('disconnected', self.control(50, ''))
    backend.resolve.assert_not_called()

  def test_invalid_values_do_not_probe_hardware(self):
    for value in (0, 101, float('nan'), 42.5, True):
      self.assert_status('invalid_value', self.control(value))
    backend.resolve.assert_not_called()

  def test_readback_reports_hardware_clamping(self):
    self.adapter.read.side_effect = [42, 60]
    result = self.control(75)
    self.assertEqual(result['brightness'], 60)
    self.adapter.write.assert_called_once_with(75)

  def test_failed_readback_never_claims_success(self):
    self.adapter.read.side_effect = [42, BrightnessError('timeout', 'Readback timed out')]
    self.assert_status('timeout', self.control(75))

  def test_unplug_during_read_prevents_write(self):
    def unplug():
      monitor_state.hardware_displays.return_value = self.displays[:1]
      return 42
    self.adapter.read.side_effect = unplug
    self.assert_status('disconnected', self.control(75))
    self.adapter.write.assert_not_called()

  def test_replacement_with_same_description_prevents_write(self):
    def replace():
      replacement = Display('DP-2', self.displays[1].path, edid(3), 'new-token')
      monitor_state.hardware_displays.return_value = [self.displays[0], replacement]
      return 42
    self.adapter.read.side_effect = replace
    self.assert_status('disconnected', self.control(75))
    self.adapter.write.assert_not_called()

  def test_unavailable_selected_display_has_no_fallback(self):
    self.adapter.read.side_effect = BrightnessError('io_error', 'VCP error')
    self.assert_status('io_error', self.control())
    backend.resolve.assert_called_once()
    self.adapter.write.assert_not_called()

  def test_operation_contention_is_retryable(self):
    with monitor_state.operation_lock():
      self.assert_status('busy', self.control(50))
    backend.resolve.assert_not_called()

  def group(self):
    path = self.root / 'omarchy/display-brightness.json'
    path.parent.mkdir(exist_ok=True)
    path.write_text(json.dumps({'groups': [{'controller': self.displays[0].fingerprint,
                       'members': [d.fingerprint for d in self.displays]}]}))
    return path

  def test_explicit_group_routes_to_controller_and_reports_all_members(self):
    self.group()
    result = self.control(50)
    self.assertEqual(result['scope'], 'shared')
    self.assertEqual(result['affectedDisplays'], ['DP-1', 'DP-2'])
    self.assertEqual(backend.resolve.call_args.args[0].name, 'DP-1')

  def test_missing_shared_controller_does_not_fall_back(self):
    self.group()
    monitor_state.hardware_displays.return_value = self.displays[1:]
    self.assert_status('disconnected', self.control(50))
    backend.resolve.assert_not_called()

  def test_group_changed_during_read_blocks_write(self):
    path = self.group()
    def change_group():
      path.write_text('{"groups": []}')
      return 42
    self.adapter.read.side_effect = change_group
    self.assert_status('disconnected', self.control(50))
    self.adapter.write.assert_not_called()

  def test_bad_group_is_not_silently_ignored(self):
    path = self.group()
    path.write_text('{"groups": [{"members": ["invalid"]}]}')
    self.assert_status('invalid_config', self.control(50))
    backend.resolve.assert_not_called()

  def test_duplicate_group_identities_are_ambiguous(self):
    self.group()
    duplicate = Display('DP-3', self.root / 'card0-DP-3', edid(1), 'token-3')
    monitor_state.hardware_displays.return_value = self.displays + [duplicate]
    self.assert_status('ambiguous', self.control(50))
    backend.resolve.assert_not_called()


class AdapterTests(unittest.TestCase):
  def setUp(self):
    self.tmp = tempfile.TemporaryDirectory()
    self.addCleanup(self.tmp.cleanup)
    self.root = Path(self.tmp.name)

  def display(self, name='DP-1', identifier=1):
    path = self.root / f'card0-{name}'
    path.mkdir(exist_ok=True)
    return Display(name, path, edid(identifier), f'token-{identifier}')

  def test_ddc_requires_bus_and_edid_on_every_read_and_write(self):
    display = self.display()
    bus = self.root / 'i2c-9'
    bus.mkdir()
    (display.path / 'ddc').symlink_to(bus)
    with patch.object(backend, 'run', side_effect=['ddcutil 2.2.7', 'VCP 10 C 80 200', '', 'VCP 10 C 150 200']) as run:
      adapter = backend.Ddc(display, [display])
      self.assertEqual(adapter.read(), 40)
      adapter.write(75)
      self.assertEqual(adapter.read(), 75)
    commands = [call.args[0] for call in run.call_args_list[1:]]
    for command in commands:
      self.assertEqual(command[command.index('--bus') + 1], '9')
      self.assertEqual(command[command.index('--edid') + 1], edid(1).hex())
    self.assertEqual(commands[1][-3:], ['setvcp', '10', '150'])

  def test_mst_uses_full_drm_connector_not_suffix(self):
    output = 'Display 1\n I2C bus: /dev/i2c-4\n DRM connector: card1-DP-1\nInvalid display\n I2C bus: /dev/i2c-9\n DRM connector: card0-DP-1\n'
    self.assertEqual(backend.detect_bus(output, 'card0-DP-1'), '9')
    with self.assertRaises(BrightnessError):
      backend.detect_bus(output + output, 'card0-DP-1')

  def test_old_ddcutil_cannot_silently_ignore_identity(self):
    display = self.display()
    with patch.object(backend, 'run', return_value='ddcutil 2.1.0'):
      with self.assertRaises(BrightnessError) as raised:
        backend.Ddc(display, [display])
    self.assertEqual(raised.exception.status, 'missing_dependency')

  def test_identical_edids_without_kernel_route_are_rejected(self):
    first, second = self.display(), self.display('DP-2')
    with patch.object(backend, 'run', return_value='ddcutil 2.2.7') as run:
      with self.assertRaises(BrightnessError):
        backend.Ddc(first, [first, second])
    self.assertEqual(run.call_count, 1)

  def test_invalid_edid_never_reaches_ddc_bus(self):
    first = self.display()
    bad = Display(first.name, first.path, bytes(128), first.token)
    with patch.object(backend, 'run', return_value='ddcutil 2.2.7') as run:
      with self.assertRaises(BrightnessError):
        backend.Ddc(bad, [bad])
    self.assertEqual(run.call_count, 1)

  def test_error_classes_preserve_uncertainty(self):
    cases = [('VCP 10 ERR', '', 'io_error'), ('', 'Permission denied', 'permission_denied'),
        ('', 'Display not found', 'disconnected'), ('', 'Unsupported feature', 'unsupported')]
    for out, err, status in cases:
      with patch.object(backend.subprocess, 'run', return_value=subprocess.CompletedProcess([], 1, out, err)):
        with self.assertRaises(BrightnessError) as raised:
          backend.run(['ddcutil'])
      self.assertEqual(raised.exception.status, status)

  def test_timeout_and_missing_dependency_are_distinct(self):
    for error, status in [(subprocess.TimeoutExpired('ddcutil', 8), 'timeout'), (FileNotFoundError(), 'missing_dependency')]:
      with patch.object(backend.subprocess, 'run', side_effect=error):
        with self.assertRaises(BrightnessError) as raised:
          backend.run(['ddcutil'])
      self.assertEqual(raised.exception.status, status)

  def test_invalid_ranges_and_malformed_vcp_are_rejected(self):
    for output in ('VCP 10 C 5 0', 'VCP 10 C 201 200', 'VCP 10 ERR', 'garbage'):
      with self.assertRaises(BrightnessError):
        backend.parse_vcp(output)

  def test_backlight_uses_exact_connector_ancestry(self):
    first, second = self.display('eDP-1'), self.display('eDP-2', 2)
    root = self.root / 'backlight'
    root.mkdir()
    for display in (first, second):
      physical = display.path / 'backlight' / f'panel-{display.name}'
      physical.mkdir(parents=True)
      (root / physical.name).symlink_to(physical)
    selected = devices.backlight(second, [first, second], root)
    self.assertEqual(selected.name, 'panel-eDP-2')

  def test_unrelated_backlight_is_not_a_default_fallback(self):
    display = self.display('eDP-1')
    gpu = self.root / 'gpu' / 'drm' / 'card0'
    gpu.mkdir(parents=True)
    (display.path / 'device').symlink_to(gpu)
    root = self.root / 'backlight'
    (root / 'acpi_video0').mkdir(parents=True)
    with self.assertRaises(BrightnessError):
      devices.backlight(display, [display], root)

  def test_duplicate_apple_serials_never_pick_first_device(self):
    monitors = [dict(serialNumber='same'), dict(serialNumber='same')]
    with patch.object(backend, 'apple_hid') as match:
      with self.assertRaises(BrightnessError):
        backend.Apple(monitors[0], monitors)
    match.assert_not_called()

  def test_apple_accepts_hyprland_serial_field(self):
    monitor = dict(serial='unique')
    with patch.object(backend, 'apple_hid', return_value=(Path('/dev/usb/hiddev7'), '1114', '/sys/device7')) as match:
      backend.Apple(monitor, [monitor])
    match.assert_called_once_with('unique')

  def test_apple_rejects_duplicate_serial_across_field_names(self):
    monitors = [dict(serial='same'), dict(serialNumber='same')]
    with patch.object(backend, 'apple_hid') as match:
      with self.assertRaises(BrightnessError):
        backend.Apple(monitors[0], monitors)
    match.assert_not_called()

  def test_single_backlight_on_matching_gpu_is_supported(self):
    display = self.display('eDP-1')
    gpu = self.root / 'gpu'
    card = gpu / 'drm' / 'card0'
    card.mkdir(parents=True)
    (card / 'device').symlink_to(gpu)
    (display.path / 'device').symlink_to(card)
    physical = gpu / 'backlight' / 'intel_backlight'
    physical.mkdir(parents=True)
    root = self.root / 'backlights'
    root.mkdir()
    (root / 'intel_backlight').symlink_to(physical)
    self.assertEqual(devices.backlight(display, [display], root).name, 'intel_backlight')
    other = self.display('eDP-2', 2)
    (other.path / 'device').symlink_to(card)
    with self.assertRaises(BrightnessError):
      devices.backlight(display, [display, other], root)

  def test_apple_hid_mapping_matches_serial_and_rejects_multiple_interfaces(self):
    root, dev = self.root / 'usbmisc', self.root / 'dev'
    root.mkdir()
    (dev / 'usb').mkdir(parents=True)
    for index, serial in ((1, 'first'), (2, 'second')):
      usb = self.root / f'usb-{index}'
      hid = usb / 'interface' / f'hiddev{index}'
      hid.mkdir(parents=True)
      (usb / 'idVendor').write_text('05ac')
      (usb / 'idProduct').write_text('1114')
      (usb / 'serial').write_text(serial)
      (root / f'hiddev{index}').symlink_to(hid)
      (dev / 'usb' / f'hiddev{index}').touch()
    self.assertEqual(devices.apple_hid('second', root, dev)[0], dev / 'usb/hiddev2')
    with self.assertRaises(BrightnessError):
      devices.apple_hid('missing', root, dev)
    (self.root / 'usb-1' / 'serial').write_text('second')
    with self.assertRaises(BrightnessError):
      devices.apple_hid('second', root, dev)

  def test_apple_passes_exact_device_and_noninteractive_permissions(self):
    monitor = dict(serialNumber='unique')
    with patch.object(backend, 'apple_hid', return_value=(Path('/dev/usb/hiddev7'), '1114', '/sys/device7')), \
      patch.object(backend, 'run', side_effect=['/dev/usb/hiddev7: BRIGHTNESS=30200', '']) as run:
      adapter = backend.Apple(monitor, [monitor])
      self.assertEqual(adapter.read(), 50)
      adapter.write(50)
    self.assertEqual(run.call_args_list[0].args[0], ['sudo', '-n', 'asdcontrol', '/dev/usb/hiddev7'])
    self.assertEqual(run.call_args_list[1].args[0][-2:], ['--', '30200'])

  def test_sysfs_replacement_changes_identity_with_same_name(self):
    display = self.display()
    (display.path / 'status').write_text('connected')
    (display.path / 'connector_id').write_text('1')
    (display.path / 'edid').write_bytes(edid(1))
    first = devices.displays(self.root)[0]
    (display.path / 'edid').write_bytes(edid(2))
    second = devices.displays(self.root)[0]
    self.assertEqual(first.name, second.name)
    self.assertNotEqual(first.token, second.token)


if __name__ == '__main__':
  unittest.main()
