"""Exact-owned Pulse control for the Amiga emulator's audio stream."""
import json
import re
import subprocess


class OwnedAudio:
  """No default-sink or system mute commands; identity checked each operation.

  Random per-child application.id is inherited by ONLY the registered sandbox.
  The caller additionally verifies the actual child ancestry/namespace before apply.
  Native connect wrapper guarantees initial server mute + 10% linear stream gain.
  """

  def __init__(self, token, environment):
    if not re.fullmatch(r'org\.omarchy\.amiga-screensaver\.[a-f0-9]{32}', token):
      raise ValueError('Invalid owned audio token')
    self.token = token
    self.env = dict(environment, LC_ALL='C')
    self.index = None

  def command(self, *args):
    return subprocess.check_output(['pactl', *args], env=self.env, text=True, timeout=3)

  def find(self):
    matches = [x for x in json.loads(self.command('-f', 'json', 'list', 'sink-inputs'))
               if x.get('properties', {}).get('application.id') == self.token
               and x.get('properties', {}).get('application.process.binary') == 'fs-uae']
    if len(matches) > 1:
      raise RuntimeError('Ambiguous owned stream')
    if not matches:
      return None
    stream = matches[0]
    if self.index is not None and stream['index'] != self.index:
      raise RuntimeError('Owned stream replaced unexpectedly')
    return stream

  def apply(self, muted):
    stream = self.find()
    if stream is None:
      return None
    self.index = stream['index']
    # Require bounded native startup volume before ANY unmute operation.
    volumes = [channel['value'] for channel in stream['volume'].values()]
    if not volumes or any(v > round(65536 * (0.10 ** (1 / 3))) for v in volumes):
      self.command('set-sink-input-mute', str(self.index), '1')
      raise RuntimeError('Unsafe stream gain; kept muted')
    self.command('set-sink-input-mute', str(self.index), '1' if muted else '0')
    actual = self.find()
    if actual is None or actual['mute'] is not muted:
      raise RuntimeError('Audio mute readback failed')
    return actual
