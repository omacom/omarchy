"""Local synthetic SFTP/collector measurement; never connects to a real host."""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import resource
import subprocess
import sys
import time
from unittest.mock import patch

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('application', type=Path)
parser.add_argument('--files', type=int, default=4)
parser.add_argument('--records', type=int, default=2000)
args = parser.parse_args()
if not 1 <= args.files <= 16 or not 1 <= args.records <= 20000:
  parser.error('use 1–16 files and 1–20000 records per file')
app = args.application.resolve()
sys.argv = [str(app / 'test/shell.d/agent-remote.py'), str(app)]
spec = importlib.util.spec_from_file_location('remote_fixture', app / 'test/shell.d/agent-remote.py')
fixture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fixture)
if not fixture.SFTP_SERVER:
  raise SystemExit('read-only local sftp-server test prerequisite unavailable')
test = fixture.RemoteTests()
test.setUp()
try:
  sources = []
  for number in range(args.files):
    rows = fixture.native(100, 'bench-' + str(number))[:2]
    for count in range(1, args.records + 1):
      rows.append(fixture.native(count * 100)[-1])
      rows.append({'type': 'response_item', 'payload': {'role': 'user', 'content': 'PRIVATE BENCHMARK ' + 'x' * 1024}})
    sources.append(test.write('.codex/sessions/bench-' + str(number) + '.jsonl', rows))
  measurements = []
  def measure(phase):
    parent_before = resource.getrusage(resource.RUSAGE_SELF)
    child_before = resource.getrusage(resource.RUSAGE_CHILDREN)
    start = time.monotonic()
    scans = []
    run = subprocess.run
    def collect_call(command, **kwargs):
      if Path(command[0]).name.startswith('omarchy-agent-usage-'):
        scans.append(Path(command[0]).name)
      return run(command, **kwargs)
    with patch.object(subprocess, 'run', side_effect=collect_call):
      (providers, issues), transferred = test.collect()
    elapsed = time.monotonic() - start
    parent_after = resource.getrusage(resource.RUSAGE_SELF)
    child_after = resource.getrusage(resource.RUSAGE_CHILDREN)
    measurements.append({'phase': phase, 'wallSeconds': elapsed, 'sourceContentBytesTransferred': transferred,
      'collectorProcesses': scans, 'todayTokens': providers['codex']['todayTotalTokens'], 'issues': issues,
      'parentUserSeconds': parent_after.ru_utime - parent_before.ru_utime,
      'parentSystemSeconds': parent_after.ru_stime - parent_before.ru_stime,
      'localChildrenUserSeconds': child_after.ru_utime - child_before.ru_utime,
      'localChildrenSystemSeconds': child_after.ru_stime - child_before.ru_stime,
      'parentMaxRssBefore': parent_before.ru_maxrss, 'parentMaxRssAfter': parent_after.ru_maxrss,
      'childrenMaxRssBefore': child_before.ru_maxrss, 'childrenMaxRssAfter': child_after.ru_maxrss})
  initial_bytes = sum(path.stat().st_size for path in sources)
  measure('first')
  measure('unchanged')
  with sources[0].open('a') as stream:
    stream.write(json.dumps(fixture.native((args.records + 1) * 100)[-1]) + '\n')
  appended_bytes = sum(path.stat().st_size for path in sources) - initial_bytes
  measure('append')
  for path in test.cache.rglob('*'):
    if path.is_file():
      assert b'PRIVATE BENCHMARK' not in path.read_bytes(), path
  print(json.dumps({'fixture': {'files': args.files, 'recordsPerFile': args.records,
    'initialSourceBytes': initial_bytes, 'appendedSourceBytes': appended_bytes,
    'platform': sys.platform, 'python': sys.version.split()[0],
    'transport': 'real local OpenSSH sftp-server -R through synthetic ssh executable',
    'byteScope': 'SFTP file payload only; excludes protocol/SSH framing and directory attributes',
    'resourceScope': 'parent plus reaped local children (SFTP fixture, identity tools, collectors); no real remote CPU measurement',
    'maxRssUnit': 'KiB on Linux; bytes on macOS; cumulative high-water marks, not per-phase deltas'},
    'measurements': measurements}, indent=2))
finally:
  test.tearDown()
