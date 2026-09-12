"""Capability-gated, bounded OpenCode metadata query over existing SSH."""
import json
import os
import select
import shlex
import subprocess
import time

from transport import ssh_command

MAX_ROWS = 10_000
MAX_STDOUT_BYTES = 8 * 1024 * 1024
QUERY_TIMEOUT_SECONDS = 15
MAX_SAFE_INTEGER = 9_007_199_254_740_991


class OpenCodeSourceError(Exception):
  """The optional source could not be queried within its safe contract."""


# This is intentionally a constant projection. It never returns message data,
# parts, content, credentials, or free-form tool payloads. Text metadata is
# length-bounded in SQL before sqlite3 serializes it to stdout.
QUERY = f"""
SELECT
  CASE WHEN typeof(session_id) = 'text' AND length(session_id) BETWEEN 1 AND 256
    THEN session_id END AS sessionId,
  json_extract(data, '$.role') AS role,
  json_extract(data, '$.providerID') AS providerId,
  CASE WHEN json_type(data, '$.modelID') = 'text'
         AND length(json_extract(data, '$.modelID')) <= 256
    THEN json_extract(data, '$.modelID') END AS modelId,
  CASE WHEN json_type(data, '$.time.created') IN ('integer', 'real')
    THEN json_extract(data, '$.time.created') END AS created,
  CASE WHEN json_type(data, '$.tokens.input') = 'integer'
         AND json_extract(data, '$.tokens.input') BETWEEN 0 AND {MAX_SAFE_INTEGER}
    THEN json_extract(data, '$.tokens.input') END AS inputTokens,
  CASE WHEN json_type(data, '$.tokens.output') = 'integer'
         AND json_extract(data, '$.tokens.output') BETWEEN 0 AND {MAX_SAFE_INTEGER}
    THEN json_extract(data, '$.tokens.output') END AS outputTokens,
  CASE WHEN json_type(data, '$.tokens.reasoning') = 'integer'
         AND json_extract(data, '$.tokens.reasoning') BETWEEN 0 AND {MAX_SAFE_INTEGER}
    THEN json_extract(data, '$.tokens.reasoning') END AS reasoningTokens,
  CASE WHEN json_type(data, '$.tokens.cache.read') = 'integer'
         AND json_extract(data, '$.tokens.cache.read') BETWEEN 0 AND {MAX_SAFE_INTEGER}
    THEN json_extract(data, '$.tokens.cache.read') END AS cacheReadTokens,
  CASE WHEN json_type(data, '$.tokens.cache.write') = 'integer'
         AND json_extract(data, '$.tokens.cache.write') BETWEEN 0 AND {MAX_SAFE_INTEGER}
    THEN json_extract(data, '$.tokens.cache.write') END AS cacheWriteTokens,
  CASE WHEN json_type(data, '$.service_tier') = 'text'
         AND length(json_extract(data, '$.service_tier')) <= 256
    THEN json_extract(data, '$.service_tier')
    WHEN json_type(data, '$.tokens.service_tier') = 'text'
         AND length(json_extract(data, '$.tokens.service_tier')) <= 256
    THEN json_extract(data, '$.tokens.service_tier') END AS serviceTier,
  CASE WHEN json_type(data, '$.speed') = 'text'
         AND length(json_extract(data, '$.speed')) <= 256
    THEN json_extract(data, '$.speed')
    WHEN json_type(data, '$.tokens.speed') = 'text'
         AND length(json_extract(data, '$.tokens.speed')) <= 256
    THEN json_extract(data, '$.tokens.speed') END AS speed,
  CASE WHEN json_type(data, '$.fast_mode') IN ('true', 'false')
    THEN json_type(data, '$.fast_mode')
    WHEN json_type(data, '$.tokens.fast_mode') IN ('true', 'false')
    THEN json_type(data, '$.tokens.fast_mode') END AS fastModeType,
  CASE WHEN json_type(data, '$.cache_duration') = 'text'
         AND length(json_extract(data, '$.cache_duration')) <= 256
    THEN json_extract(data, '$.cache_duration')
  WHEN json_type(data, '$.tokens.cache_duration') = 'text'
         AND length(json_extract(data, '$.tokens.cache_duration')) <= 256
    THEN json_extract(data, '$.tokens.cache_duration') END AS cacheDuration,
  CASE WHEN json_type(data, '$.inference_geo') = 'text'
         AND length(json_extract(data, '$.inference_geo')) <= 256
    THEN json_extract(data, '$.inference_geo')
  WHEN json_type(data, '$.tokens.inference_geo') = 'text'
         AND length(json_extract(data, '$.tokens.inference_geo')) <= 256
    THEN json_extract(data, '$.tokens.inference_geo') END AS inferenceGeo
FROM message
WHERE (SELECT json_valid('{{}}')) = 1
  AND json_valid(data)
  AND json_extract(data, '$.role') = 'assistant'
  AND json_extract(data, '$.providerID') IN ('openai', 'anthropic')
LIMIT {MAX_ROWS + 1}
""".strip()


def remote_command(database):
  if (not database.startswith('/') or '\x00' in database or '\n' in database or '\r' in database
      or any(part in ('', '.', '..') for part in database.split('/')[1:])):
    raise OpenCodeSourceError('OpenCode database path is not a canonical absolute path')
  invocation = ' '.join((
    'exec sqlite3 -readonly $safe -json -init /dev/null',
    '-cmd ' + shlex.quote('PRAGMA query_only=ON'),
    '-cmd ' + shlex.quote('PRAGMA temp_store=MEMORY'),
    shlex.quote(database),
    shlex.quote(QUERY),
  ))
  script = ('command -v sqlite3 >/dev/null 2>&1 || exit 64\n'
            "safe=''\n"
            "if sqlite3 -safe -init /dev/null :memory: 'SELECT 1' >/dev/null 2>&1; then safe=-safe; fi\n"
            + invocation)
  return '/bin/sh -c ' + shlex.quote(script)


def bounded_stdout(target, command, timeout=QUERY_TIMEOUT_SECONDS, max_bytes=MAX_STDOUT_BYTES):
  started = time.monotonic()
  try:
    process = subprocess.Popen(ssh_command(target) + [command], stdout=subprocess.PIPE,
                               stderr=subprocess.DEVNULL, bufsize=0)
  except OSError as error:
    raise OpenCodeSourceError('OpenCode SSH command capability is unavailable') from error
  output = bytearray()
  assert process.stdout is not None
  try:
    while True:
      remaining = timeout - (time.monotonic() - started)
      if remaining <= 0:
        raise OpenCodeSourceError('OpenCode query exceeded its time limit')
      try:
        ready = select.select([process.stdout], [], [], min(remaining, 0.25))[0]
      except OSError as error:
        raise OpenCodeSourceError('OpenCode query output could not be read') from error
      if not ready:
        if process.poll() is not None:
          break
        continue
      try:
        block = os.read(process.stdout.fileno(), min(65_536, max_bytes + 1 - len(output)))
      except OSError as error:
        raise OpenCodeSourceError('OpenCode query output could not be read') from error
      if not block:
        break
      output.extend(block)
      if len(output) > max_bytes:
        raise OpenCodeSourceError('OpenCode query exceeded its output limit')
    remaining = timeout - (time.monotonic() - started)
    if remaining <= 0:
      raise OpenCodeSourceError('OpenCode query exceeded its time limit')
    try:
      status = process.wait(timeout=remaining)
    except subprocess.TimeoutExpired as error:
      raise OpenCodeSourceError('OpenCode query exceeded its time limit') from error
    if status != 0:
      raise OpenCodeSourceError('compatible sqlite3, JSON functions, schema, or read-only access unavailable')
    return bytes(output)
  finally:
    if process.poll() is None:
      process.terminate()
      try:
        process.wait(timeout=1)
      except subprocess.TimeoutExpired:
        process.kill()
        process.wait()
    process.stdout.close()


def scalar_text(value):
  return value if isinstance(value, str) and len(value) <= 256 else None


def token_count(value):
  return value if type(value) is int and 0 <= value <= MAX_SAFE_INTEGER else None


def query_messages(target, database, timeout=QUERY_TIMEOUT_SECONDS, max_bytes=MAX_STDOUT_BYTES):
  raw = bounded_stdout(target, remote_command(database), timeout, max_bytes).strip()
  try:
    rows = json.loads(raw) if raw else []
  except (ValueError, UnicodeError) as error:
    raise OpenCodeSourceError('OpenCode query returned invalid JSON framing') from error
  if not isinstance(rows, list) or len(rows) > MAX_ROWS:
    raise OpenCodeSourceError('OpenCode query exceeded its row limit')
  result = []
  for row in rows:
    if not isinstance(row, dict):
      raise OpenCodeSourceError('OpenCode query returned an invalid row')
    session = scalar_text(row.get('sessionId'))
    provider = row.get('providerId')
    if not session or provider not in ('openai', 'anthropic') or row.get('role') != 'assistant':
      raise OpenCodeSourceError('OpenCode query returned unsupported scalar metadata')
    created = row.get('created')
    if type(created) not in (int, float) or not 0 <= created <= MAX_SAFE_INTEGER:
      created = None
    tokens = {
      'input': token_count(row.get('inputTokens')),
      'output': token_count(row.get('outputTokens')),
      'reasoning': token_count(row.get('reasoningTokens')),
      'cache': {'read': token_count(row.get('cacheReadTokens')),
                'write': token_count(row.get('cacheWriteTokens'))},
    }
    data = {'role': 'assistant', 'providerID': provider, 'modelID': scalar_text(row.get('modelId')),
            'time': {'created': created}, 'tokens': tokens}
    for source, target_key in (('serviceTier', 'service_tier'), ('speed', 'speed'),
                               ('cacheDuration', 'cache_duration'), ('inferenceGeo', 'inference_geo')):
      value = scalar_text(row.get(source))
      if value is not None:
        data[target_key] = value
    if row.get('fastModeType') in ('true', 'false'):
      data['fast_mode'] = row['fastModeType'] == 'true'
    result.append({'sessionId': session, 'data': data})
  return result
