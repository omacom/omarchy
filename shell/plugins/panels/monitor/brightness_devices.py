"""Resolve display identities and controls from sysfs; never choose a default device."""
from dataclasses import dataclass
import hashlib
from pathlib import Path
import re


class BrightnessError(ValueError):
  def __init__(self, status, message):
    super().__init__(message)
    self.status = status


@dataclass(frozen=True)
class Display:
  name: str
  path: Path
  edid: bytes
  token: str

  @property
  def internal(self):
    return re.match(r'^(eDP|LVDS|DSI)-', self.name) is not None

  @property
  def fingerprint(self):
    return hashlib.sha256(self.edid).hexdigest() if self.edid else ''


def text(path):
  try:
    return path.read_text().strip()
  except FileNotFoundError:
    return ''


def displays(drm=Path('/sys/class/drm')):
  result = []
  for path in sorted(drm.glob('card*-*')):
    try:
      if text(path / 'status') != 'connected':
        continue
      edid = (path / 'edid').read_bytes()
      # Include connector and EDID changes, not just model/serial strings.
      # Reconnection with identical sysfs identity and EDID is indistinguishable.
      identity = (str(path.resolve()), str(path.stat().st_ino),
            text(path / 'connector_id'), edid.hex())
      token = hashlib.sha256('|'.join(identity).encode()).hexdigest()
      result.append(Display(re.sub(r'^card\d+-', '', path.name), path, edid, token))
    except FileNotFoundError:
      continue  # Unplugged while enumerating.
  return result


def unique_display(items, name):
  matches = [d for d in items if d.name == name]
  if len(matches) != 1:
    raise BrightnessError('disconnected' if not matches else 'ambiguous',
               'Display connection is missing or cannot be identified uniquely.')
  return matches[0]


def backlight(display, connected, root=Path('/sys/class/backlight')):
  devices = [p for p in root.iterdir() if p.name != 'appletb_backlight'] if root.exists() else []
  # Prefer an explicit connector ancestry. Do not rank competing drivers.
  direct = [p for p in devices if p.resolve().is_relative_to(display.path.resolve())
       or (p / 'device').resolve() == display.path.resolve()]
  if len(direct) == 1:
    return direct[0]
  gpu = (display.path / 'device' / 'device').resolve()
  same_gpu_panels = [d for d in connected if d.internal and (d.path / 'device' / 'device').resolve() == gpu]
  candidates = [p for p in devices if p.resolve().is_relative_to(gpu)]
  if not direct and len(same_gpu_panels) == 1 and len(candidates) == 1:
    return candidates[0]
  raise BrightnessError('ambiguous' if devices else 'unsupported',
             'No unique backlight control could be matched to this display.')


def apple_hid(serial, root=Path('/sys/class/usbmisc'), dev=Path('/dev')):
  if not serial or serial.strip('0 ') == '':
    raise BrightnessError('ambiguous', 'This display has no unique serial number for brightness control.')
  candidates = []
  for path in root.glob('hiddev*'):
    for parent in path.resolve().parents:
      if not (parent / 'idVendor').exists():
        continue
      if text(parent / 'idVendor') == '05ac' and text(parent / 'serial') == serial:
        nodes = [p for p in (dev / 'usb' / path.name, dev / path.name) if p.exists()]
        if len(nodes) == 1:
          candidates.append((nodes[0], text(parent / 'idProduct'), str(path.resolve())))
      break
  if len(candidates) != 1:
    raise BrightnessError('ambiguous', 'No unique Apple brightness device matches this display.')
  return candidates[0]
