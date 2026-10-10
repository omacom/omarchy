"""Fast metadata reads, with isolated and bounded DDC operations on demand."""
import argparse
import json
import subprocess
import sys

sys.dont_write_bytecode = True
from display_runtime import hypr, operation_lock, OperationBusy
from brightness_devices import BrightnessError, displays as hardware_displays, unique_display
import brightness_backend

FIELDS = ('name', 'description', 'make', 'model', 'serial', 'serialNumber', 'width', 'height', 'scale', 'transform',
     'x', 'y', 'focused', 'disabled', 'mirrorOf')


def read_state(name=''):
  monitors = json.loads(hypr('monitors', 'all', '-j'))
  monitors.sort(key=lambda m: (m.get('description', m['name']), m['name']))
  active = [m for m in monitors if not m.get('disabled')]
  selected = next((m for m in active if m['name'] == name), None)
  if selected is None:
    selected = next((m for m in active if m.get('focused')), active[0] if active else None)
  try:
    connected = hardware_displays()
  except OSError:
    connected = []
  result = []
  for monitor in monitors:
    matches = [d for d in connected if d.name == monitor['name']]
    device = matches[0] if len(matches) == 1 else None
    result.append(dict({k: monitor.get(k) for k in FIELDS}, enabled=not monitor.get('disabled', False),
             brightnessIdentity=device.token if device else '',
             hardwareId=device.fingerprint if device else ''))
  return dict(selected=selected['name'] if selected else '', displays=result)


def brightness(name, identity, value=None, expected_token=''):
  result = dict(name=name, description=identity, brightness=None, status='loading',
         scope='unknown', affectedDisplays=[], backend='', message='', identity=expected_token)
  try:
    if value is not None and (type(value) is not int or not 1 <= value <= 100):
      raise BrightnessError('invalid_value', 'Brightness must be between 1 and 100.')
    with operation_lock():
      monitors = json.loads(hypr('monitors', '-j'))
      selected = next((m for m in monitors if m['name'] == name and m.get('description') == identity
              and not m.get('disabled')), None)
      if selected is None:
        raise BrightnessError('disconnected', 'Display connection changed; select the display again.')
      connected = hardware_displays()
      display = unique_display(connected, name)
      if expected_token and expected_token != display.token:
        raise BrightnessError('disconnected', 'Display connection changed; select the display again.')
      if value is not None and not expected_token:
        raise BrightnessError('disconnected', 'Refresh the display identity before changing brightness.')
      result['identity'] = display.token
      controller, scope, affected = brightness_backend.policy(display, connected)
      monitor = next((m for m in monitors if m['name'] == controller.name and not m.get('disabled')), None)
      if monitor is None:
        raise BrightnessError('disconnected', 'The brightness controller is no longer active.')
      adapter = brightness_backend.resolve(controller, connected, monitor, monitors)
      result.update(backend=adapter.backend, scope=scope or adapter.scope,
             affectedDisplays=affected or ([name] if adapter.scope == 'display' else []))

      def validate():
        current = hardware_displays()
        if (unique_display(current, name).token != display.token
            or unique_display(current, controller.name).token != controller.token):
          raise BrightnessError('disconnected', 'Display connection changed during brightness control.')
        target, current_scope, current_affected = brightness_backend.policy(unique_display(current, name), current)
        if (target.token, current_scope, current_affected) != (controller.token, scope, affected):
          raise BrightnessError('disconnected', 'Brightness group changed; refresh before trying again.')
        # DDC checks bus AND EDID in each command. Other backends need
        # their sysfs mapping checked again before every operation.
        if adapter.backend != 'ddc' and brightness_backend.resolve(target, current, monitor, monitors).key != adapter.key:
          raise BrightnessError('disconnected', 'The brightness device mapping changed.')

      validate()
      actual = adapter.read()
      if value is not None:
        validate()
        adapter.write(value)
        validate()
        actual = adapter.read()
      validate()
      result.update(brightness=actual, status='available')
  except BrightnessError as error:
    result.update(status=error.status, message=str(error))
  except OperationBusy as error:
    result.update(status='busy', message=str(error))
  except PermissionError:
    result.update(status='permission_denied', message='Permission to access this display was denied.')
  except FileNotFoundError:
    result.update(status='disconnected', message='The display or brightness device was disconnected.')
  except subprocess.TimeoutExpired:
    result.update(status='timeout', message='The display service took too long to respond.')
  except (OSError, ValueError, subprocess.CalledProcessError):
    result.update(status='io_error', message='Could not read the display control state.')
  return result


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument('monitor', nargs='?', default='')
  parser.add_argument('--brightness')
  parser.add_argument('--identity', default='')
  parser.add_argument('--token', default='')
  parser.add_argument('--value', type=int)
  args = parser.parse_args()
  if args.value is not None and not args.brightness:
    parser.error('--value requires --brightness')
  result = brightness(args.brightness, args.identity, args.value, args.token) if args.brightness else read_state(args.monitor)
  print(json.dumps(result))


if __name__ == '__main__':
  try:
    main()
  except Exception as error:
    print(str(error), file=sys.stderr)
    sys.exit(1)
