"""Machine catalog and cached usage; all persistent files are local."""
import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import sys
import subprocess
import time
import uuid

from collection import ImportContinuing, collect_sources, read_json, write_json
from transport import Sftp, TransportError, local_identity, target_value


def paths(create=True):
  home = Path.home()
  config = Path(os.environ.get('XDG_CONFIG_HOME') or home / '.config') / 'omarchy/agents'
  state = Path(os.environ.get('XDG_STATE_HOME') or home / '.local/state') / 'omarchy/agents/remote'
  cache = Path(os.environ.get('XDG_CACHE_HOME') or home / '.cache') / 'omarchy/agents/remote'
  if create:
    for directory in (config, state, cache):
      directory.mkdir(parents=True, exist_ok=True, mode=0o700)
  return config, state, cache


@contextmanager
def locked(path, blocking=True):
  with path.open('a') as lock:
    try:
      fcntl.flock(lock, fcntl.LOCK_EX | (0 if blocking else fcntl.LOCK_NB))
    except BlockingIOError:
      yield False
    else:
      try:
        yield True
      finally:
        fcntl.flock(lock, fcntl.LOCK_UN)


def catalog(config):
  data = read_json(config / 'machines.json', {'schemaVersion': 1, 'machines': []})
  if not isinstance(data, dict) or data.get('schemaVersion') != 1 or not isinstance(data.get('machines'), list):
    raise ValueError('Unsupported or invalid machines.json; existing cached state was retained')
  ids, identities, targets = set(), set(), set()
  for machine in data['machines']:
    if not isinstance(machine, dict) or not all(isinstance(machine.get(k), str) and machine[k]
                                               for k in ('id', 'label', 'target', 'identity')):
      raise ValueError('Invalid machine profile')
    if not all(c in '0123456789abcdef' for c in machine['id']) or len(machine['id']) != 32:
      raise ValueError('Invalid machine profile ID')
    target_value(machine['target'])
    if machine['id'] in ids or machine['identity'] in identities or machine['target'] in targets:
      raise ValueError('Duplicate machine or SSH account in catalog')
    ids.add(machine['id'])
    identities.add(machine['identity'])
    targets.add(machine['target'])
  return data


def snapshot(config, state, updates=None):
  machines = catalog(config)['machines']
  old = read_json(state / 'state.json', {})
  previous = {row['id']: row for row in old.get('machines', [])}
  rows = []
  for machine in machines:
    value = (updates or {}).get(machine['id'], previous.get(machine['id'], {}))
    if value.get('identity') != machine['identity']:
      value = {}
    rows.append(dict(value, **machine))
  return old, rows


def publish(config, state, updates=None):
  # Reload membership under the same lock as mutations. A late refresh result
  # can never resurrect a removed profile or overwrite its renamed label.
  with locked(config / '.machines.lock'):
    old, rows = snapshot(config, state, updates)
    # FileView observes replacements. Leave both the file and timestamp alone
    # unless the actual panel input changed.
    if old.get('schemaVersion') != 1 or old.get('machines') != rows:
      write_json(state / 'state.json', {'schemaVersion': 1, 'machines': rows, 'updatedAtMs': round(time.time() * 1000)})
    return rows


def label_value(value):
  value = value.strip()
  if not value or len(value) > 64 or any(ord(c) < 32 for c in value):
    raise ValueError('Use a name of 1–64 characters without control characters')
  return value


def add(config, state, target, label, factory=Sftp):
  target = target_value(target)
  label = label_value(label or target)
  # Verify first, then save. No failed setup is presented as an empty machine.
  with factory(target) as remote:
    identity = remote.identity()
  if identity['identity'] == local_identity():
    raise ValueError('This SSH account is already included as This computer')
  with locked(config / '.machines.lock'):
    data = catalog(config)
    if any(m['identity'] == identity['identity'] or m['target'] == target for m in data['machines']):
      raise ValueError('This machine and SSH account are already included under another connection')
    machine = dict(identity, id=uuid.uuid4().hex, target=target, label=label)
    data['machines'].append(machine)
    write_json(config / 'machines.json', data)
  publish(config, state)
  return machine


def mutate(config, state, machine_id, label=None, remove=False):
  with locked(config / '.machines.lock'):
    data = catalog(config)
    machine = next((m for m in data['machines'] if m['id'] == machine_id), None)
    if machine is None:
      raise ValueError('Machine ID not found; use machine list')
    if remove:
      data['machines'].remove(machine)
    else:
      machine['label'] = label_value(label)
    write_json(config / 'machines.json', data)
  publish(config, state)


def refresh(config, state, cache, omarchy_path, force=False, factory=Sftp, *,
            budget_bytes=64 * 1024 * 1024, budget_seconds=45):
  with locked(state / '.refresh.lock', blocking=False) as acquired:
    if not acquired:
      return
    machines = publish(config, state)
    previous = {row['id']: row for row in machines}
    due = [m for m in machines if force or time.time() >= m.get('nextAttemptAt', m.get('attemptedAt', 0) + 3600)]

    def fetch(machine):
      old = previous[machine['id']]
      result = dict(old, attemptedAt=time.time())
      result.pop('nextAttemptAt', None)
      try:
        with factory(machine['target']) as remote:
          providers, issues = collect_sources(remote, machine, cache / machine['id'], omarchy_path,
                                             budget_bytes=budget_bytes, budget_seconds=budget_seconds)
          result.pop('error', None)
          result.update(providers=providers,
                        lastSuccess=time.time(), status='incomplete' if issues else 'current',
                        issues=issues, transferredBytes=remote.transferred)
      except ImportContinuing as error:
        result.update(status='importing', error=str(error),
                      nextAttemptAt=time.time() + (60 if error.progress else 300))
      except InterruptedError as error:
        result.update(status='importing', error=str(error))
      except (TransportError, OSError, ValueError) as error:
        result.update(status='stale' if old.get('lastSuccess') else 'unavailable', error=str(error))
      except Exception:
        result.update(status='stale' if old.get('lastSuccess') else 'unavailable',
                      error='Usage import failed; the last successful result is retained')
      return machine['id'], result

    with ThreadPoolExecutor(max_workers=2) as executor:
      futures = [executor.submit(fetch, machine) for machine in due]
      for future in as_completed(futures):
        machine_id, result = future.result()
        publish(config, state, {machine_id: result})


def main(argv=None):
  parser = argparse.ArgumentParser(description='Manage remote usage over existing SSH access; no remote installation.')
  sub = parser.add_subparsers(dest='action', required=True)
  listing = sub.add_parser('list')
  listing.add_argument('--json', action='store_true')
  adding = sub.add_parser('add')
  adding.add_argument('target')
  adding.add_argument('--label')
  removing = sub.add_parser('remove')
  removing.add_argument('id')
  renaming = sub.add_parser('rename')
  renaming.add_argument('id')
  renaming.add_argument('--label', required=True)
  updating = sub.add_parser('refresh')
  updating.add_argument('--force', action='store_true')
  args = parser.parse_args(argv)
  config, state, cache = paths(create=args.action != 'list')
  try:
    if args.action == 'add':
      machine = add(config, state, args.target, args.label)
      print(json.dumps(machine))
    elif args.action in ('rename', 'remove'):
      mutate(config, state, args.id, getattr(args, 'label', None), args.action == 'remove')
    elif args.action == 'refresh':
      refresh(config, state, cache, Path(os.environ['OMARCHY_PATH']), args.force)
    else:
      _, rows = snapshot(config, state)
      summary = [{key: row.get(key) for key in ('id', 'label', 'target', 'platform', 'user', 'uid', 'home', 'status', 'lastSuccess', 'error')} for row in rows]
      if args.json:
        print(json.dumps(summary))
      else:
        for row in summary:
          print('\t'.join(str(row.get(key) or '-') for key in ('id', 'label', 'target', 'user', 'platform', 'status', 'lastSuccess')))
  except subprocess.SubprocessError:
    print("SSH identity check failed; verify normal SSH access first", file=sys.stderr)
    return 1
  except (TransportError, OSError, ValueError, KeyError) as error:
    print(str(error), file=sys.stderr)
    return 1
  return 0


if __name__ == '__main__':
  raise SystemExit(main())
