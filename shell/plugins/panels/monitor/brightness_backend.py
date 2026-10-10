"""Bounded hardware adapters with explicit selection and readback.

DDC requires ddcutil >= 2.2.4: bus and EDID must BOTH match.
No persistent connector-to-bus cache is trusted for a write.
"""
import json
import os
from pathlib import Path
import re
import subprocess

from brightness_devices import BrightnessError, backlight, apple_hid, text


def run(command, timeout=8):
  try:
    result = subprocess.run(command, capture_output=True, text=True, timeout=timeout,
                env=dict(os.environ, LC_ALL='C'), stdin=subprocess.DEVNULL)
  except subprocess.TimeoutExpired:
    raise BrightnessError('timeout', 'The display took too long to respond. Try again.') from None
  except FileNotFoundError:
    raise BrightnessError('missing_dependency', f'{command[0]} is not installed.') from None
  except PermissionError:
    raise BrightnessError('permission_denied', 'Permission to control this display was denied.') from None
  if result.returncode:
    detail = (result.stderr + '\n' + result.stdout).lower()
    if any(s in detail for s in ('permission denied', 'password is required', 'not allowed to execute')):
      status, message = 'permission_denied', 'Permission to control this display was denied.'
    elif 'display not found' in detail:
      status, message = 'disconnected', 'Display identity changed or its control channel is unavailable.'
    elif 'unsupported feature' in detail or 'unsupported device' in detail:
      status, message = 'unsupported', 'This device does not support this brightness control.'
    else:
      # VCP 10 ERR does not distinguish an unsupported feature from I/O failure.
      status, message = 'io_error', 'Could not communicate with this display. Check its connection and monitor controls.'
    raise BrightnessError(status, message)
  return result.stdout.strip()


def percent(current, maximum, minimum=0):
  if not minimum <= current <= maximum or maximum <= minimum:
    raise BrightnessError('io_error', 'The display returned an invalid brightness range.')
  return ((current - minimum) * 100 + (maximum - minimum) // 2) // (maximum - minimum)


def parse_vcp(output):
  match = re.search(r'^VCP 10 C (\d+) (\d+)\s*$', output, re.M)
  if not match:
    raise BrightnessError('io_error', 'The display did not return a valid brightness value.')
  current, maximum = map(int, match.groups())
  percent(current, maximum)
  return current, maximum


def detect_bus(output, connector):
  matches, bus = [], None
  for line in output.splitlines():
    if re.match(r'^(Display \d+|Invalid display|Phantom display)', line):
      bus = None
    match = re.search(r'I2C bus:\s*/dev/i2c-(\d+)\s*$', line)
    if match:
      bus = match[1]
    match = re.search(r'DRM connector:\s*(\S+)\s*$', line)
    if match:
      if match[1] == connector and bus is not None:
        matches.append(bus)
      bus = None
  if len(matches) != 1:
    raise BrightnessError('ambiguous', 'No unique brightness channel matches this display.')
  return matches[0]


class Ddc:
  backend = 'ddc'
  scope = 'unknown'  # A control channel does not prove independent physical backlights.

  def __init__(self, display, connected):
    version = re.search(r'ddcutil (\d+)\.(\d+)\.(\d+)', run(['ddcutil', '--version'], 2))
    if not version or tuple(map(int, version.groups())) < (2, 2, 4):
      raise BrightnessError('missing_dependency', 'ddcutil 2.2.4 or newer is required for safe display selection.')
    edid = display.edid[:128]
    if len(edid) != 128 or edid[:8] != b'\x00\xff\xff\xff\xff\xff\xff\x00' or sum(edid) % 256:
      raise BrightnessError('ambiguous', 'The display does not provide a valid hardware identity.')
    direct = display.path / 'ddc'
    if direct.exists() and re.fullmatch(r'i2c-\d+', direct.resolve().name):
      bus = direct.resolve().name[4:]
    else:
      # Without a kernel link, identical EDIDs cannot establish a unique MST route.
      if sum(d.edid[:128] == edid for d in connected) != 1:
        raise BrightnessError('ambiguous', 'These displays report identical identities; brightness cannot be mapped safely.')
      bus = detect_bus(run(['ddcutil', '--noconfig', '--skip-ddc-checks', 'detect', '--brief']), display.path.name)
    self.key = f'ddc:{bus}:{edid.hex()}'
    self.command = ['ddcutil', '--noconfig', '--bus', bus, '--edid', edid.hex(), '--skip-ddc-checks']

  def read(self):
    current, self.maximum = parse_vcp(run(self.command + ['getvcp', '10', '--brief']))
    return percent(current, self.maximum)

  def write(self, value):
    # read() must precede write(): never reuse a different monitor's range.
    raw = max(1, (value * self.maximum + 50) // 100)
    run(self.command + ['--noverify', 'setvcp', '10', str(raw)])


class Backlight:
  backend = 'backlight'
  scope = 'display'

  def __init__(self, display, connected):
    self.path = backlight(display, connected)
    self.key = f'backlight:{self.path.resolve()}'

  def read(self):
    self.maximum = int(text(self.path / 'max_brightness'))
    return percent(int(text(self.path / 'actual_brightness')), self.maximum)

  def write(self, value):
    raw = max(1, (value * self.maximum + 50) // 100)
    run(['brightnessctl', '--device', self.path.name, 'set', str(raw)])


class Apple:
  backend = 'apple'
  scope = 'display'
  # Supported ranges from asdcontrol's device database. Unknown models stay disabled.
  ranges = {'1114': (400, 60000), '9243': (400, 60000)}

  def __init__(self, monitor, monitors):
    serial = self.serial(monitor)
    if sum(self.serial(m) == serial for m in monitors) != 1:
      raise BrightnessError('ambiguous', 'Apple displays do not have unique serial numbers.')
    node, product, path = apple_hid(serial)
    if product not in self.ranges:
      raise BrightnessError('unsupported', 'This Apple model needs a verified brightness range.')
    self.minimum, self.maximum = self.ranges[product]
    self.key = f'apple:{path}:{serial}:{product}'
    # Noninteractive: missing permission is a state, never a password prompt in the panel.
    self.command = ['sudo', '-n', 'asdcontrol', str(node)]

  @staticmethod
  def serial(monitor):
    return monitor.get('serial') or monitor.get('serialNumber') or ''

  def read(self):
    match = re.search(r'BRIGHTNESS=(\d+)', run(self.command))
    if not match:
      raise BrightnessError('io_error', 'The display did not return a valid brightness value.')
    return percent(int(match[1]), self.maximum, self.minimum)

  def write(self, value):
    raw = self.minimum + (value * (self.maximum - self.minimum) + 50) // 100
    run(self.command + ['--', str(raw)])


def resolve(display, connected, monitor, monitors):
  if display.internal:
    return Backlight(display, connected)
  if monitor.get('make') == 'Apple Computer Inc' and re.search(r'StudioDisplay|ProDisplayXDR|Studio XDR', monitor.get('model', '')):
    return Apple(monitor, monitors)
  return Ddc(display, connected)


def policy(selected, connected, path=None):
  """Optional, explicitly verified groups. No brand/serial-based sharing guesses."""
  if path is None:
    path = Path(os.environ.get('XDG_CONFIG_HOME', str(Path.home() / '.config'))) / 'omarchy/display-brightness.json'
  if not path.exists():
    return selected, None, []
  try:
    config = json.loads(path.read_text())
    if set(config) != {'groups'} or not isinstance(config['groups'], list):
      raise ValueError()
    seen, chosen = set(), None
    for group in config['groups']:
      members, controller = group['members'], group['controller']
      if (not isinstance(members, list) or len(members) < 1
          or any(not isinstance(k, str) or not re.fullmatch(r'[0-9a-f]{64}', k) for k in members)
          or len(set(members)) != len(members) or seen.intersection(members)
          or controller not in members):
        raise ValueError()
      seen.update(members)
      if selected.fingerprint in members:
        chosen = group
    if chosen is None:
      return selected, None, []
    for fingerprint in chosen['members']:
      if sum(d.fingerprint == fingerprint for d in connected) > 1:
        raise BrightnessError('ambiguous', 'The brightness group contains duplicate display identities.')
    controllers = [d for d in connected if d.fingerprint == chosen['controller']]
    if len(controllers) != 1:
      raise BrightnessError('disconnected', 'The brightness controller for this display group is disconnected.')
    affected = [d.name for d in connected if d.fingerprint in chosen['members']]
    return controllers[0], 'shared' if len(chosen['members']) > 1 else 'display', affected
  except (KeyError, TypeError, ValueError) as error:
    if isinstance(error, BrightnessError):
      raise
    raise BrightnessError('invalid_config', 'The display brightness group configuration is invalid.') from None
