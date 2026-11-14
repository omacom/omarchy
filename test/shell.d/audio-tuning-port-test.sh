#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command jq

python3 - "$ROOT" <<'PY'
import json, os, pathlib, shutil, subprocess, sys, tempfile, time

root = pathlib.Path(sys.argv[1])
with tempfile.TemporaryDirectory(prefix='audio-tuning-port-') as temporary:
  stage = pathlib.Path(temporary)
  (stage / 'bin').mkdir()
  (stage / 'home').mkdir()
  tuning = stage / 'default/audio/tunings/macbook'
  tuning.mkdir(parents=True)
  (tuning / 'tuning.conf').write_text('description="MacBook speakers"\nmatch_dmi=("MacBookPro11,4")\nsink_pattern="^physical$"\nsink_port="analog-output-speaker"\n')
  (tuning / 'filter-chain.conf').write_text('target.object = "@SPEAKER_SINK@"\n')
  (stage / 'default/systemd/user').mkdir(parents=True)
  (stage / 'default/audio/filter-chain-host.conf').write_text('host\n')
  for name in ['omarchy-speaker-tuning.service', 'omarchy-speaker-tuning-port.service']:
    shutil.copyfile(root / 'default/systemd/user' / name, stage / 'default/systemd/user' / name)

  fake = r'''#!/usr/bin/python3
import json, os, pathlib, signal, sys, time
base = pathlib.Path(os.environ['PORT_TEST_STAGE'])
name = pathlib.Path(sys.argv[0]).name
args = sys.argv[1:]
def state(): return json.loads((base / 'state').read_text())
def log(action):
  with (base / 'actions').open('a') as f: f.write(action + '\n')
if name == 'omarchy-hw-match': sys.exit(0)
if name == 'ls': sys.exit(0)
if name == 'systemctl':
  log('systemctl ' + ' '.join(args))
  sys.exit(1 if 'easyeffects.service' in args else 0)
if name == 'omarchy-audio-output-sink':
  if (base / 'host').exists(): print('physical')
  sys.exit(0)
if name == 'pipewire':
  log('host start')
  (base / 'host').touch()
  def stop(*_): raise SystemExit(0)
  signal.signal(signal.SIGTERM, stop)
  try:
    while True: time.sleep(.05)
  finally:
    (base / 'host').unlink(missing_ok=True)
    log('host stop')
  sys.exit(0)
if name != 'pactl': sys.exit(1)
if args == ['subscribe']:
  previous = None
  while True:
    if state().get('subscription_failure'): sys.exit(1)
    current = (base / 'state').read_text()
    if current != previous:
      if not state().get('omit_port_event'):
        print("Event 'change' on sink #1", flush=True)
      previous = current
    print("Event 'new' on client #99", flush=True)
    time.sleep(.02)
log('query ' + ' '.join(args))
s = state()
if args == ['get-default-sink']:
  print((base / 'default-sink').read_text()); sys.exit(0)
if args[0] == 'set-default-sink':
  (base / 'default-sink').write_text(args[1]); log('default ' + args[1]); sys.exit(0)
if args[0] == 'move-sink-input':
  (base / ('stream-' + args[1])).write_text(args[2]); log('move ' + args[1] + ' ' + args[2]); sys.exit(0)
if s.get('query_failure'): sys.exit(1)
sinks = [{'name':'physical','index':1,'active_port':s.get('port')}, {'name':'hdmi','index':3,'active_port':None}]
if not s.get('present', True): sinks = sinks[1:]
if (base / 'host').exists(): sinks.append({'name':'omarchy_speaker_tuning','index':2,'active_port':None})
if args == ['list','sinks','short']:
  for sink in sinks: print(str(sink['index']) + '\t' + sink['name'])
elif args == ['-f','json','list','sinks']:
  print(json.dumps(sinks))
elif args == ['-f','json','list','sink-inputs']:
  indexes = {'physical':1,'omarchy_speaker_tuning':2,'hdmi':3}
  streams = [{'index':7,'sink':indexes[(base/'stream-7').read_text()],'properties':{'application.name':'Music'}},
             {'index':8,'sink':3,'properties':{'application.name':'Video'}},
             {'index':9,'sink':1,'properties':{'node.name':'filter_output'}},
             {'index':10,'sink':1,'properties':{'application.name':'EasyEffects'}}]
  print(json.dumps(streams))
else: sys.exit(1)
'''
  launcher = stage / 'bin/fake'
  launcher.write_text(fake)
  launcher.chmod(0o755)
  for name in ['pactl','pipewire','systemctl','omarchy-hw-match','omarchy-audio-output-sink','ls']:
    (stage / 'bin' / name).symlink_to(launcher)
  env = os.environ.copy()
  env.update(OMARCHY_PATH=str(stage), HOME=str(stage / 'home'), XDG_CONFIG_HOME=str(stage / 'home/.config'), PORT_TEST_STAGE=str(stage), PATH=str(stage / 'bin') + ':' + env['PATH'])
  command = [str(root / 'bin/omarchy-audio-tuning')]
  def set_state(port, **kwargs):
    temporary_state = stage / 'next-state'
    temporary_state.write_text(json.dumps(dict(port=port, **kwargs)))
    temporary_state.replace(stage / 'state')
  def wait_for(predicate, label, seconds=5):
    deadline = time.monotonic() + seconds
    while time.monotonic() < deadline:
      if predicate():
        print('ok - ' + label, flush=True)
        return
      time.sleep(.05)
    raise AssertionError(label + '\n' + (stage / 'actions').read_text())
  def run(action): return subprocess.run(command + [action], env=env, text=True, capture_output=True, timeout=8)
  (stage / 'actions').touch()
  (stage / 'default-sink').write_text('physical')
  (stage / 'stream-7').write_text('physical')
  set_state('analog-output-headphones')
  assert run('match').stdout.strip() == str(tuning)
  print('ok - hardware match remains available with headphones connected')
  result = run('on')
  assert result.returncode == 0 and 'waiting' in result.stdout, result.stderr
  unit = stage / 'home/.config/systemd/user/omarchy-speaker-tuning.service'
  assert 'watch-port' in unit.read_text() and not (stage / 'host').exists()
  print('ok - installation with headphones keeps the port-aware host enabled without starting DSP')
  with (stage / 'host-log').open('w') as log:
    host = subprocess.Popen(command + ['watch-port'], env=env, stdout=log, stderr=log)
    try:
      time.sleep(.3)
      assert host.poll() is None and not (stage / 'host').exists()
      print('ok - startup on headphones leaves audio unprocessed')
      queries_before = (stage/'actions').read_text().count('query list sinks short')
      time.sleep(1.2)
      queries_after = (stage/'actions').read_text().count('query list sinks short')
      assert queries_after - queries_before <= 4
      print('ok - unrelated client events do not trigger repeated audio queries')
      set_state('analog-output-speaker')
      wait_for(lambda: (stage/'stream-7').read_text() == 'omarchy_speaker_tuning', 'speaker port starts DSP and moves only speaker streams')
      assert (stage/'default-sink').read_text() == 'omarchy_speaker_tuning'
      assert run('fronted-sink').stdout.strip() == 'physical'
      print('ok - speaker port exposes the physical sink as fronted')
      set_state('analog-output-headphones')
      wait_for(lambda: not (stage/'host').exists() and (stage/'stream-7').read_text() == 'physical', 'plugging headphones stops DSP and restores raw headphone audio')
      assert (stage/'default-sink').read_text() == 'physical'
      assert run('fronted-sink').returncode != 0
      print('ok - headphone port keeps the physical sink selectable')
      (stage/'default-sink').write_text('hdmi')
      set_state('analog-output-speaker')
      wait_for(lambda: (stage/'stream-7').read_text() == 'omarchy_speaker_tuning', 'unplugging headphones restores speaker DSP')
      assert (stage/'default-sink').read_text() == 'hdmi'
      assert 'move 8' not in (stage/'actions').read_text() and 'move 9' not in (stage/'actions').read_text() and 'move 10' not in (stage/'actions').read_text()
      print('ok - separate outputs, DSP playback streams and EasyEffects retain their routing')
      set_state(None, omit_port_event=True)
      wait_for(lambda: not (stage/'host').exists(), 'unknown active port stops DSP despite continuous unrelated events')
      set_state('analog-output-speaker')
      wait_for(lambda: (stage/'host').exists(), 'speaker DSP resumes after a known port returns')
      set_state('analog-output-speaker', query_failure=True)
      wait_for(lambda: not (stage/'host').exists(), 'audio-server query failures stop DSP')
      set_state('analog-output-speaker', present=False)
      time.sleep(.3)
      assert not (stage/'host').exists()
      set_state('analog-output-speaker')
      wait_for(lambda: (stage/'host').exists(), 'device removal and return resume the speaker host')
      host.terminate()
      host.wait(timeout=5)
      assert not (stage/'host').exists() and (stage/'default-sink').read_text() == 'hdmi'
      print('ok - stopping the service cleans up its graph without changing another default output')
    finally:
      if host.poll() is None:
        host.terminate()
        host.wait(timeout=5)
  # A dead subscription must clean up even when the watcher returns normally
  # through its error path, rather than exiting inside the signal handler.
  (stage/'default-sink').write_text('physical')
  (stage/'stream-7').write_text('physical')
  set_state('analog-output-speaker')
  with (stage/'host-log').open('a') as log:
    host = subprocess.Popen(command + ['watch-port'], env=env, stdout=log, stderr=log)
    try:
      wait_for(lambda: (stage/'stream-7').read_text() == 'omarchy_speaker_tuning', 'a restarted watcher resumes its speaker graph')
      set_state('analog-output-speaker', subscription_failure=True)
      host.wait(timeout=5)
      assert host.returncode != 0 and not (stage/'host').exists()
      assert (stage/'default-sink').read_text() == 'physical' and (stage/'stream-7').read_text() == 'physical'
      print('ok - subscription loss fails closed and cleans up the graph and default routing')
    finally:
      if host.poll() is None:
        host.terminate()
        host.wait(timeout=5)
  # off must not reroute HDMI/USB/Bluetooth streams after the port host exits.
  (stage/'default-sink').write_text('hdmi')
  result = run('off')
  assert result.returncode == 0 and (stage/'default-sink').read_text() == 'hdmi'
  assert 'move 8' not in (stage/'actions').read_text()
  print('ok - disabling a port-aware tuning preserves unrelated default outputs and streams')
  # Ungated profiles keep the original service template and hardware match.
  (tuning/'tuning.conf').write_text('description="Speakers"\nmatch_dmi=("MacBookPro11,4")\nsink_pattern="^physical$"\n')
  (stage/'host').touch()
  assert run('fronted-sink').stdout.strip() == 'physical'
  print('ok - profiles without a port restriction retain existing fronted-sink behavior')
  result = run('on')
  assert result.returncode == 0, result.stderr
  assert 'watch-port' not in unit.read_text() and 'pipewire -c' in unit.read_text()
  print('ok - profiles without a port restriction retain the original host service')

PY
