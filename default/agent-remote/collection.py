"""Incremental source reads, retaining only usage metadata on this computer."""
from copy import deepcopy
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import subprocess
import shutil
import tempfile
import time

ROOTS = ('.codex/sessions', '.codex/archived_sessions', '.claude/projects',
         '.pi/agent/sessions', '.omp/agent/sessions', '.kimi/sessions')
TOKEN_KEYS = ('input_tokens', 'output_tokens', 'cached_input_tokens', 'cache_read_input_tokens',
              'cache_creation_input_tokens', 'cache_write_input_tokens', 'reasoning_output_tokens',
              'total_tokens', 'input', 'output', 'cacheRead', 'cacheWrite', 'totalTokens',
              'inputTokens', 'outputTokens', 'cacheReadInputTokens', 'cacheCreationInputTokens',
              'input_other', 'input_cache_read', 'input_cache_creation')
TARIFF_KEYS = ('service_tier', 'speed', 'fast_mode', 'cache_duration', 'inference_geo')


class ImportContinuing(InterruptedError):
  def __init__(self, progress):
    super().__init__('Import is continuing; the last successful snapshot is retained')
    self.progress = progress


class WorkBudget:
  """Bound transfer bytes and work between requests, below the hard timeout."""
  def __init__(self, size, seconds):
    self.remaining = max(0, size)
    self.deadline = time.monotonic() + max(0, seconds)
    self.progress = False

  def check(self):
    if time.monotonic() >= self.deadline:
      raise ImportContinuing(self.progress)

  def read(self, remote, path, offset=0, length=32768, exact=False):
    self.check()
    if length and (self.remaining <= 0 or exact and self.remaining < length):
      raise ImportContinuing(self.progress)
    data = remote.read(path, offset, min(length, self.remaining))
    self.remaining -= len(data)
    return data


def write_json(path, value):
  path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
  fd, name = tempfile.mkstemp(dir=path.parent, prefix='.' + path.name)
  try:
    with os.fdopen(fd, 'w') as stream:
      json.dump(value, stream, separators=(',', ':'), allow_nan=False)
      stream.write('\n')
    os.replace(name, path)
  finally:
    if os.path.exists(name):
      os.unlink(name)


def read_json(path, default=None):
  try:
    return json.loads(path.read_text())
  except FileNotFoundError:
    return default


def fields(value, keys):
  if not isinstance(value, dict):
    return {}
  # Bounded scalar metadata only. Invalid numeric values remain invalid for
  # the existing collector to explain, without retaining arbitrary payloads.
  return {key: item for key, item in value.items() if key in keys and
          (item is None or type(item) in (int, float, bool) or isinstance(item, str) and len(item) <= 256)}


def usage(value):
  if value is not None and not isinstance(value, dict):
    raise ValueError('Usage fields must be an object')
  result = fields(value, TOKEN_KEYS + TARIFF_KEYS)
  if isinstance(value, dict) and isinstance(value.get('cache_creation'), dict):
    result['cache_creation'] = fields(value['cache_creation'], ('ephemeral_5m_input_tokens', 'ephemeral_1h_input_tokens'))
  return result


def reject_json_constant(value):
  raise ValueError('Non-finite JSON number')


def metadata(raw, relative):
  try:
    entry = json.loads(raw, parse_constant=reject_json_constant)
    if not isinstance(entry, dict):
      raise ValueError('Usage record must be an object')
  except (ValueError, UnicodeError) as error:
    raise ValueError('Invalid usage JSON record') from error
  result = fields(entry, ('type', 'timestamp', 'id', 'messageId', 'requestId', 'sessionId', 'uuid', 'model', 'protocol_version'))
  if relative.startswith('.codex/'):
    payload = entry.get('payload')
    if not isinstance(payload, dict):
      if entry.get('type') in ('session_meta', 'turn_context', 'event_msg', 'response_item'):
        raise ValueError('Invalid native payload')
      return b'{}\n'
    kind = entry.get('type')
    if kind == 'session_meta':
      result['payload'] = fields(payload, ('id',))
    elif kind == 'turn_context':
      result['payload'] = fields(payload, ('model', 'model_slug') + TARIFF_KEYS)
    else:
      if kind == 'response_item':
        payload = payload.get('payload', payload)
      if not isinstance(payload, dict) or payload.get('type') != 'token_count':
        return b'{}\n'
      info = payload.get('info')
      if info is None:
        return b'{}\n'  # Rate-limit-only notifications carry no usage.
      if not isinstance(info, dict):
        raise ValueError('Invalid native token information')
      if any(not isinstance(info[key], dict) for key in ('last_token_usage', 'total_token_usage') if key in info):
        raise ValueError('Invalid native token usage')
      result.update(type='event_msg', payload={'type': 'token_count', 'info': {
        key: usage(info[key]) for key in ('last_token_usage', 'total_token_usage') if key in info}})
  elif relative.startswith('.kimi/'):
    if entry.get('type') == 'metadata':
      return (json.dumps(result) + '\n').encode()
    message = entry.get('message')
    if not isinstance(message, dict):
      raise ValueError('Invalid Wire message')
    payload = message.get('payload') or {}
    result['message'] = dict(fields(message, ('type',)), payload={})
    if isinstance(payload, dict) and 'token_usage' in payload:
      result['message']['payload']['token_usage'] = usage(payload['token_usage'])
  elif relative == '.claude/history.jsonl':
    pass
  else:
    message = entry.get('message')
    if not isinstance(message, dict):
      if entry.get('type') in ('assistant', 'message'):
        raise ValueError('Invalid assistant message')
      return b'{}\n'
    if message.get('role') != 'assistant':
      return b'{}\n'
    result['message'] = fields(message, ('id', 'role', 'model', 'provider', 'api', 'timestamp') + TARIFF_KEYS)
    result['message']['usage'] = usage(message.get('usage', entry.get('usage')))
    result.update(fields(entry, TARIFF_KEYS))
  # A timestamp without an offset cannot be attributed to the remote clock.
  # Preserve usage as unallocated instead of inventing the displaying timezone.
  for value in (result, result.get('message', {})):
    stamp = value.get('timestamp')
    if isinstance(stamp, str):
      try:
        if datetime.fromisoformat(stamp.replace('Z', '+00:00')).tzinfo is None:
          value['timestamp'] = None
      except ValueError:
        pass
  return (json.dumps(result, separators=(',', ':'), allow_nan=False) + '\n').encode()


def compact(record):
  record.pop('stats', None)
  for day in record.get('dailyUsage', {}).get('days', []):
    groups = {}
    extra = []
    for bucket in day.get('buckets', []):
      tokens = bucket.get('tokens', {})
      values = list(tokens.values())
      total = bucket.get('totalTokens')
      if any(value is not None and type(value) is not int for value in values) or type(total) not in (int, type(None)):
        extra.append(bucket)
        continue
      key = json.dumps([bucket.get('rawModel'), bucket.get('source'), bucket.get('tariff'),
                        bucket.get('issues'), sorted(k for k, v in tokens.items() if v is None), total is None], sort_keys=True)
      if key not in groups:
        groups[key] = dict(bucket, tokens=dict(tokens))
      else:
        group = groups[key]
        if total is not None:
          group['totalTokens'] += total
        for name, value in tokens.items():
          if value is not None:
            group['tokens'][name] = group['tokens'].get(name, 0) + value
        # Cache-creation splits contain counts, so groups with this attribute
        # must retain each original bucket rather than duplicating one split.
        if bucket.get('tariff', {}).get('cache_creation'):
          extra.append(bucket)
          for name, value in tokens.items():
            if value is not None:
              group['tokens'][name] -= value
          if total is not None:
            group['totalTokens'] -= total
    day['buckets'] = list(groups.values()) + extra
  return record


def digest(data):
  return hashlib.sha256(data).hexdigest()


def sync_file(remote, path, attrs, relative, cache, budget):
  key = digest(relative.encode())
  state_path = cache / 'positions' / (key + '.json')
  progress_path = cache / 'progress' / (key + '.json')
  working = cache / 'progress' / (key + '.jsonl')
  destination = cache / 'sources' / relative
  progress = read_json(progress_path, {})
  state = progress or read_json(state_path, {})
  candidate = working if progress else destination
  size, mtime = attrs['size'], attrs.get('mtime', 0)
  offset = state.get('offset', 0)
  if (not progress and state.get('stable') and size == state.get('size') and mtime == state.get('mtime')
      and state.get('mode') == attrs.get('mode') and (offset == size or state.get('partialLine'))
      and destination.exists() and destination.stat().st_size == state.get('metadataSize')):
    return False
  head = budget.read(remote, path, length=min(size, 4096), exact=True)
  old_head_length = state.get('headLength', 0)
  tail = budget.read(remote, path, max(0, offset - 4096), min(offset, 4096), exact=True) if offset else b''
  same_prefix = old_head_length <= len(head) and digest(head[:old_head_length]) == state.get('head')
  append = candidate.exists() and offset <= size and same_prefix and digest(tail) == state.get('tail')
  if size == state.get('size') and mtime != state.get('mtime'):
    append = False
  metadata_size = state.get('metadataSize', 0)
  if append and (candidate.stat().st_size < metadata_size or not progress and candidate.stat().st_size != metadata_size):
    append = False
  if (append and not progress and size == state.get('size') and mtime == state.get('mtime')
      and state.get('mode') == attrs.get('mode') and (offset == size or state.get('partialLine'))):
    # A recent file needs conservative prefix/tail validation once it settles,
    # but unchanged sanitized contents must not invalidate collector caches.
    after = remote.attrs(path)
    if all(after.get(key) == attrs.get(key) for key in ('size', 'mtime', 'mode')):
      write_json(state_path, dict(state, stable=mtime < time.time() - 2))
      return False
  working.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
  if append and candidate != working:
    shutil.copyfile(candidate, working)
    working.chmod(0o600)
  elif not append:
    working.write_bytes(b'')
    working.chmod(0o600)
    offset, metadata_size = 0, 0
  consumed = offset
  tail_buffer = tail if append else b''
  try:
    with working.open('r+b') as output:
      # Any bytes appended before a crash but not described by the atomic
      # progress record are discarded. Only sanitized complete lines persist.
      output.truncate(metadata_size)
      output.seek(metadata_size)
      pending = b''
      cursor = offset
      checkpoint = dict(state, offset=offset, size=size, mtime=mtime, mode=attrs.get('mode'),
                        headLength=min(len(head), offset), head=digest(head[:min(len(head), offset)]),
                        tail=digest(tail_buffer), metadataSize=metadata_size)
      while cursor < size:
        block = budget.read(remote, path, cursor, min(1024 * 1024, size - cursor))
        if not block:
          raise OSError('Usage source changed during transfer')
        cursor += len(block)
        pending += block
        lines = pending.split(b'\n')
        pending = lines.pop()
        for line in lines:
          if len(line) > 16 * 1024 * 1024:
            raise OSError('Usage record exceeds the 16 MiB read limit')
          output.write(metadata(line, relative))
          consumed += len(line) + 1
          tail_buffer = (tail_buffer + line + b'\n')[-4096:]
        if len(pending) > 16 * 1024 * 1024:
          raise OSError('Usage record exceeds the 16 MiB read limit')
        output.flush()
        checkpoint = {'offset': consumed, 'size': size, 'mtime': mtime, 'mode': attrs.get('mode'),
                      'headLength': min(len(head), consumed), 'head': digest(head[:min(len(head), consumed)]),
                      'tail': digest(tail_buffer), 'metadataSize': output.tell()}
        write_json(progress_path, checkpoint)
        budget.progress = budget.progress or consumed > offset
    budget.check()
    after = remote.attrs(path)
    if after.get('size', 0) < size or after.get('size') == size and after.get('mtime') != mtime:
      raise OSError('Usage source was replaced during transfer; retrying next refresh')
    destination.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.replace(working, destination)
    write_json(state_path, dict(checkpoint, stable=mtime < time.time() - 2, partialLine=consumed < size))
    progress_path.unlink(missing_ok=True)
    return True
  except InterruptedError:
    raise
  except (OSError, ValueError):
    # Source corruption invalidates tentative progress; a transport failure
    # has its own exception type and retains it for revalidation next pass.
    progress_path.unlink(missing_ok=True)
    working.unlink(missing_ok=True)
    raise


def collect_sources(remote, machine, cache, omarchy_path, budget_bytes=64 * 1024 * 1024, budget_seconds=45):
  budget = WorkBudget(budget_bytes, budget_seconds)
  budget.check()
  identity = remote.identity()
  if identity['identity'] != machine['identity']:
    raise OSError('Machine or SSH user identity changed; remove and add this connection again')
  root = identity['home']
  previous = read_json(cache / 'result.json', {})
  source_states = previous.get('sources', {})
  inventory = []
  failed = {}
  for directory in ROOTS:
    walk_errors = []
    try:
      for path, attrs in remote.walk(root + '/' + directory, walk_errors.append, base=root, check=budget.check):
        relative = path[len(root) + 1:]
        if path.endswith('.jsonl') and (not directory.startswith('.kimi') or path.endswith('/wire.jsonl')):
          inventory.append((path, attrs, relative))
    except InterruptedError:
      raise
    except OSError:
      walk_errors.append('Could not inventory source')
    if walk_errors:
      failed[directory] = '; '.join(sorted(set(walk_errors))) + '; last known metadata retained'
  changed = False
  present = set()
  for path, attrs, relative in sorted(inventory):
    present.add(relative)
    budget.check()
    try:
      changed = sync_file(remote, path, attrs, relative, cache, budget) or changed
    except InterruptedError:
      raise
    except (OSError, ValueError):
      directory = next(directory for directory in ROOTS if relative.startswith(directory + '/'))
      failed[directory] = 'Could not read or parse source file; last known metadata retained'
  budget.check()
  # An incomplete inventory cannot prove deletion. Keep the last metadata for
  # that root, replacing each recovered file in place rather than adding it.
  source_root = cache / 'sources'
  if source_root.exists():
    for path in source_root.rglob('*.jsonl'):
      relative = str(path.relative_to(source_root))
      if relative not in present and not any(relative.startswith(directory + '/') for directory in failed):
        path.unlink()
        changed = True
  verified_at = time.time()
  for directory in ROOTS:
    old = source_states.get(directory, {})
    if directory in failed:
      source_states[directory] = dict(old, status='stale' if old.get('lastSuccess') else 'unavailable')
    else:
      # This is the last verified source pass, not the file-change time.
      source_states[directory] = {'status': 'current', 'lastSuccess': verified_at}
  issues = [directory + ': ' + reason for directory, reason in failed.items()]
  try:
    remote.attrs(root + '/.local/share/opencode/opencode.db')
    issues.append('Remote OpenCode databases are not supported; local usage remains available')
  except FileNotFoundError:
    pass
  except OSError:
    # This optional probe must not discard usage already read from native logs.
    issues.append('Could not check optional OpenCode data')
  if not any(relative.startswith('.claude/') for _, _, relative in inventory):
    try:
      remote.attrs(root + '/.claude/stats-cache.json')
      issues.append('Claude aggregate-only history is not supported remotely; native project logs are required')
    except FileNotFoundError:
      pass
    except OSError:
      issues.append('Could not check optional Claude aggregate history')
  day = time.strftime('%Y-%m-%d')
  timezone = {'names': list(time.tzname), 'offset': time.timezone, 'dstOffset': time.altzone,
              'spec': os.environ.get('TZ')}
  source_version = digest(json.dumps(sorted((str(path.relative_to(source_root)), path.stat().st_size, path.stat().st_mtime_ns)
                                           for path in source_root.rglob('*.jsonl'))).encode())
  collector_states = previous.get('collectors', {})
  collector_failures = {}
  if (not changed and not previous.get('collectorFailures') and previous.get('sourceVersion') == source_version
      and previous.get('day') == day and previous.get('timezone') == timezone):
    providers = previous['providers']
  else:
    providers, collector_failures = run_collectors(source_root, cache, omarchy_path, previous.get('providers', {}))
    for provider in ('codex', 'claude', 'kimi'):
      old = collector_states.get(provider, {})
      if provider in collector_failures:
        collector_states[provider] = dict(old, status='stale' if old.get('lastSuccess') else 'unavailable')
      else:
        collector_states[provider] = {'status': 'current', 'lastSuccess': time.time()}
  write_json(cache / 'result.json', {'day': day, 'timezone': timezone,
                                   'sourceVersion': source_version, 'providers': providers, 'sources': source_states,
                                   'collectors': collector_states, 'collectorFailures': collector_failures})
  result = deepcopy(providers)
  for provider, directories in {
      'codex': ('.codex/sessions', '.codex/archived_sessions', '.pi/agent/sessions', '.omp/agent/sessions'),
      'claude': ('.claude/projects', '.pi/agent/sessions', '.omp/agent/sessions'),
      'kimi': ('.kimi/sessions',)}.items():
    source_issues = [directory + ': ' + failed[directory] for directory in directories if directory in failed]
    if provider in collector_failures:
      source_issues.append(provider + ': ' + collector_failures[provider])
      issues.append(source_issues[-1])
    if provider not in result and not source_issues:
      continue
    record = result.setdefault(provider, {'id': provider, 'name': provider.title(), 'todayTotalTokens': None,
                                         'dailyUsage': {'schemaVersion': 1, 'unit': 'tokens',
                                                        'complete': False, 'issues': [], 'days': []}})
    record['remoteCollector'] = collector_states.get(provider, {})
    for reason in record['dailyUsage'].get('issues', []):
      issues.append(provider + ': ' + reason)
    record['remoteSources'] = {directory: source_states[directory] for directory in directories}
    if source_issues:
      record['dailyUsage']['complete'] = False
      record['dailyUsage']['issues'] = record['dailyUsage'].get('issues', []) + source_issues
  return result, issues


def run_collectors(source_root, cache, omarchy_path, previous):
  source_root.mkdir(parents=True, exist_ok=True, mode=0o700)
  env = dict(os.environ, OMARCHY_AGENT_SOURCE_ROOT=str(source_root),
             CODEX_HOME=str(source_root / '.codex'), CLAUDE_CONFIG_DIR=str(source_root / '.claude'),
             KIMI_SHARE_DIR=str(source_root / '.kimi'), XDG_DATA_HOME=str(source_root / '.local/share'),
             XDG_CACHE_HOME=str(cache / 'collector-cache'), PYTHONDONTWRITEBYTECODE='1')
  providers = {}
  failures = {}
  for provider in ('codex', 'claude', 'kimi'):
    command = [str(omarchy_path / 'bin' / ('omarchy-agent-usage-' + provider)), '--force']
    if provider != 'kimi':
      command.append('--stats-only')
    try:
      proc = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=60, check=True)
      record = json.loads(proc.stdout, parse_constant=reject_json_constant)
      if (not isinstance(record, dict) or record.get('id') != provider
          or not isinstance(record.get('dailyUsage'), dict)
          or record['dailyUsage'].get('schemaVersion') != 1
          or type(record['dailyUsage'].get('complete')) is not bool
          or not isinstance(record['dailyUsage'].get('issues'), list)
          or not all(isinstance(issue, str) for issue in record['dailyUsage']['issues'])
          or not isinstance(record['dailyUsage'].get('days'), list)):
        raise ValueError('Invalid collector record')
      if record.get('totalSessions', 0) or record.get('todayTotalTokens', 0) or not record['dailyUsage'].get('complete'):
        providers[provider] = compact(record)
    except (OSError, ValueError, TypeError, KeyError, AttributeError, subprocess.SubprocessError):
      # Never expose process output: it can contain source content or secrets.
      failures[provider] = 'Collector failed; last successful contribution retained where available'
      if provider in previous:
        providers[provider] = previous[provider]
  return providers, failures
