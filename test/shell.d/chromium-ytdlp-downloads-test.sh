#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

python3 <<'PY'
import json
import os
from pathlib import Path
import signal
import struct
import subprocess
import tempfile
import time

root = Path(os.environ['ROOT'])
host = root / 'bin/omarchy-chromium-ytdlp-host'

def check(condition, message):
  if not condition:
    raise AssertionError(message)
  print('ok - ' + message, flush=True)

def until(predicate, message):
  deadline = time.monotonic() + 8
  while time.monotonic() < deadline:
    result = predicate()
    if result:
      return result
    time.sleep(0.04)
  raise AssertionError(message)

def alive(pid):
  try:
    return Path(f'/proc/{pid}/stat').read_text().rsplit(') ', 1)[1].split()[0] != 'Z'
  except FileNotFoundError:
    return False

with tempfile.TemporaryDirectory() as scratch:
  tmp = Path(scratch)
  fake = tmp / 'fake'
  binaries = fake / 'bin'
  binaries.mkdir(parents=True)
  runtime = tmp / 'runtime'
  runtime.mkdir()
  videos = tmp / 'videos'
  videos.mkdir()
  env = dict(os.environ, OMARCHY_PATH=str(fake), XDG_RUNTIME_DIR=str(runtime),
             OMARCHY_YTDLP_DIR=str(videos), TEST_DOWNLOADS=str(tmp))

  def stub(name, body):
    file = binaries / name
    file.write_text('#!/bin/bash\n' + body)
    file.chmod(0o755)

  stub('omarchy-shell', 'exit 0\n')
  stub('ffmpeg', 'exit 0\n')
  stub('omarchy-notification-send', 'printf "%s\\n" "$*" >>"$TEST_DOWNLOADS/notifications"\n')
  stub('yt-dlp', r'''
url=${@: -1}
name=${url##*/}
if [[ " $* " == *" --simulate "* ]]; then
  touch "$TEST_DOWNLOADS/probe-$name"
  if [[ $name == "probe" ]]; then
    sleep 300
  fi
  exit 0
fi
[[ $name == "fail" ]] && exit 1
sleep 300 &
child=$!
printf '%s' "$child" >"$TEST_DOWNLOADS/child-$name"
printf 'OMARCHY_TITLE\t"Clip %s — test"\n' "$name"
printf 'OMARCHY_PROG\t 37.4%%\n'
while [[ ! -f $TEST_DOWNLOADS/release-$name ]]; do sleep 0.05; done
printf 'OMARCHY_STATUS\tprocessing\n'
while [[ ! -f $TEST_DOWNLOADS/finish-$name ]]; do sleep 0.05; done
kill "$child"
wait "$child" 2>/dev/null || true
printf 'video' >"$OMARCHY_YTDLP_DIR/$name.mp4"
printf 'OMARCHY_FILE\t%s/%s.mp4\n' "$OMARCHY_YTDLP_DIR" "$name"
''')

  workers = set()

  def invoke(*args, **kwargs):
    return subprocess.run([str(host), *args], env=env, capture_output=True, timeout=5, **kwargs)

  def jobs():
    result = invoke('--list')
    check_result = result.returncode == 0
    if not check_result:
      raise AssertionError(result.stderr.decode())
    return json.loads(result.stdout)

  def start(name):
    payload = json.dumps({'url': 'https://example.test/' + name, 'title': 'Page ' + name}).encode()
    result = invoke(input=struct.pack('<I', len(payload)) + payload)
    check(result.stdout == b'\x02\0\0\0{}', 'native messaging acknowledges ' + name)
    def find_job():
      for job in jobs():
        if job['url'].endswith('/' + name):
          workers.add(job['id'])
          return job
    return until(find_job, 'worker did not register ' + name)

  def current(job):
    return next((j for j in jobs() if j['id'] == job['id']), None)

  def cancel(job):
    result = invoke('--cancel', job['id'])
    check(result.returncode == 0, 'cancel request accepted for ' + job['title'])
    until(lambda: current(job) is None, 'cancelled job stayed visible')
    until(lambda: not alive(int(job['id'].split('-')[0])), 'cancelled worker survived')

  def notifications():
    file = tmp / 'notifications'
    return file.read_text() if file.exists() else ''

  try:
    a = start('one')
    b = start('two')
    until(lambda: len(jobs()) == 2 and all(j['progress'] == 37 for j in jobs()), 'parallel progress missing')
    check({j['title'] for j in jobs()} == {'Clip one — test', 'Clip two — test'}, 'parallel downloads retain independent titles and progress')
    check((runtime / 'omarchy-video-downloads').stat().st_mode & 0o777 == 0o700, 'download state stays private')
    child = int((tmp / 'child-one').read_text())
    cancel(a)
    until(lambda: not alive(child), 'cancel left a descendant running')
    check(current(b)['progress'] == 37 and alive(int(b['id'].split('-')[0])), 'cancelling one download preserves its parallel peer')
    check(not notifications(), 'cancellation emits neither a completion nor a failure toast')
    check(invoke('--cancel', a['id']).returncode != 0, 'repeated cancellation cannot target a finished worker')

    pid, started = b['id'].split('-')
    stale = f'{pid}-{int(started) + 1}'
    stale_file = runtime / 'omarchy-video-downloads' / (stale + '.json')
    stale_file.write_text('{}')
    check(invoke('--cancel', stale).returncode != 0, 'stale PID identity cannot cancel a live worker')
    check(invoke('--cancel', '../anything').returncode != 0, 'cancel rejects path traversal')
    check(len(jobs()) == 1 and not stale_file.exists(), 'listing removes stale state without disturbing active jobs')

    (tmp / 'release-two').touch()
    until(lambda: current(b)['status'] == 'Processing…', 'processing state missing')
    check(current(b)['title'] == 'Clip two — test', 'processing keeps the correct download row')
    (tmp / 'finish-two').touch()
    until(lambda: current(b) is None, 'completed job stayed visible')
    until(lambda: 'Download complete Clip two — test' in notifications(), 'completion toast missing')
    check('--exec mpv -- ' + str(videos / 'two.mp4') in notifications(), 'completed downloads keep the playable notification')

    probe = start('probe')
    until(lambda: (tmp / 'probe-probe').exists(), 'probe did not start')
    check(current(probe)['status'] == 'Preparing…', 'preparation appears before video probing finishes')
    cancel(probe)

    processing = start('processing')
    (tmp / 'release-processing').touch()
    until(lambda: current(processing)['status'] == 'Processing…', 'processing did not start')
    cancel(processing)
    until(lambda: not alive(int((tmp / 'child-processing').read_text())), 'processing cancellation left a child alive')
    check('Download failed' not in notifications(), 'probe and processing cancellation do not report failure')

    # A hard-killed worker cannot run its EXIT trap; the next listing prunes it.
    killed = start('killed')
    os.killpg(int(killed['id'].split('-')[0]), signal.SIGKILL)
    until(lambda: current(killed) is None, 'dead worker left stale progress')
    check(not jobs(), 'abrupt worker exit is removed from the active list')

    payload = json.dumps({'url': 'https://example.test/fail'}).encode()
    invoke(input=struct.pack('<I', len(payload)) + payload)
    until(lambda: 'Download failed' in notifications(), 'failed download did not report failure')
    until(lambda: not jobs(), 'failed download stayed visible')
    check(not jobs(), 'failed downloads clear their active state')
  finally:
    for worker in workers:
      invoke('--cancel', worker)
PY

run_node_test <<'JS'
const fs = require('fs');
const vm = require('vm');
let toolbar, shortcut;
let sent = [];
let tab = { id: 42, url: 'https://example.test/video', title: 'A page title' };
const chrome = {
  runtime: { sendNativeMessage: (host, payload, callback) => { sent.push({ host, payload }); callback(); } },
  commands: { onCommand: { addListener: fn => shortcut = fn } },
  action: { onClicked: { addListener: fn => toolbar = fn } },
  tabs: { query: (query, callback) => callback([tab]) },
  scripting: { executeScript: () => Promise.resolve([{ result: 'https://example.test/fallback' }]) }
};
vm.runInNewContext(fs.readFileSync(path.join(root, 'default/chromium/extensions/yt-dlp/background.js'), 'utf8'), { chrome });
toolbar(tab);
shortcut('download-video');
assertEqual(sent.length, 2, 'toolbar and shortcut each dispatch a download');
assertEqual(sent[0].payload.title, tab.title, 'extension passes the page title for the preparing row');
assertEqual(sent[0].host, 'com.omarchy.ytdlp', 'extension retains the native host protocol');
toolbar({ url: 'chrome://settings' });
assertEqual(sent.length, 2, 'extension ignores browser-internal URLs');
toolbar({ id: 42, title: 'Fallback title' });
setImmediate(() => {
  assertEqual(sent[2].payload.url, 'https://example.test/fallback', 'script fallback still downloads the page URL');
  assertEqual(sent[2].payload.title, 'Fallback title', 'script fallback preserves the page title');
});
JS
