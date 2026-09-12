#!/usr/bin/python3
"""Measure indexing and detail reads against local data, without network calls."""
import argparse
import json
import os
import statistics
import subprocess
import sys
import tempfile
import time
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--cold', action='store_true', help='Also build a disposable index from scratch')
args = parser.parse_args()
collector = Path(__file__).with_name('tracking.py')


def run(extra, env):
    start = time.monotonic()
    with tempfile.TemporaryFile() as output, tempfile.TemporaryFile() as errors:
        child = subprocess.Popen([sys.executable, str(collector), '--period', 'day', *extra], env=env, stdout=output, stderr=errors)
        _, status, usage = os.wait4(child.pid, 0)
        child.returncode = os.waitstatus_to_exitcode(status)
        elapsed = time.monotonic() - start
        output.seek(0)
        raw = output.read()
        if child.returncode:
            errors.seek(0)
            raise RuntimeError(errors.read().decode())
    data = json.loads(raw)
    return data, dict(wallMs=round(elapsed*1000, 1), cpuMs=round((usage.ru_utime+usage.ru_stime)*1000, 1),
                      peakChildMiB=round(usage.ru_maxrss/1024, 1), responseKiB=round(len(raw)/1024, 1), scan=data.get('scan', {}))



with tempfile.TemporaryDirectory(prefix='tracking-benchmark-') as tmp:
    env = os.environ.copy()
    if args.cold:
        env['OMARCHY_TRACKING_STATE'] = tmp
    first, first_metric = run([], env)
    samples = []
    for _ in range(5):
        data, metric = run([], env)
        samples.append(metric)
    detail_metric = None
    if first.get('rows'):
        _, detail_metric = run(['--detail', first['rows'][0]['id']], env)
    cpu = statistics.median(m['cpuMs'] for m in samples)
    print(json.dumps(dict(initial=first_metric, warm=samples, detail=detail_metric,
                         medianWarmMs=statistics.median(m['wallMs'] for m in samples),
                         medianCpuMs=cpu, estimatedOneCorePercentAt5Seconds=round(cpu/50, 2),
                         errors=first.get('errors'), rows=first.get('records'),
                         indexMiB=round((Path(env.get('OMARCHY_TRACKING_STATE', str(Path.home()/'.local/state/omarchy/agents/tracking')))/'ledger.sqlite').stat().st_size/1024**2, 2)), indent=2))
