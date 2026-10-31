"""Exercise a locally installed package only inside the namespace test runner."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

# Never execute lifecycle fixtures in the desktop's namespaces.
for namespace in ('pid', 'user', 'mnt', 'net'):
  host = os.environ.get('OMARCHY_TEST_HOST_' + namespace)
  assert host and os.readlink('/proc/self/ns/' + namespace) != host, 'Use the verified outer namespace test runner'

root = Path(os.environ['ROOT'])
prefix = Path(os.environ['AMIGA_TEST_PREFIX'])
runtime = prefix / 'lib/omarchy-amiga-runtime'
sys.path.insert(0, str(root / 'shell/plugins/services/idle'))
import amiga
import state
from unittest.mock import patch

with patch.object(state, 'runtime_path', return_value=runtime):
  state.runtime_check()
assert (runtime / 'guard/AmigaInput/qmldir').read_text() == 'module AmigaInput\nplugin amigainput\n', 'QML module must relocate with its real filesystem URL'
print('Installed package preflight: OK', flush=True)
with tempfile.TemporaryDirectory(prefix='amiga-package-') as temporary:
  temporary = Path(temporary)
  qml = '''import QtQuick
import QtTest
import NATIVE_URL as Native
TestCase {
  name: "InstalledAmigaNativePlugin"
  Native.RelativeMotion { id: motion }
  function test_unsupported_platform_fails_closed() { verify(!motion.ready) }
}
'''.replace('NATIVE_URL', json.dumps((runtime / 'guard/AmigaInput').as_uri()))
  (temporary / 'tst_native.qml').write_text(qml)
  env = dict(os.environ, QT_QPA_PLATFORM='offscreen', QT_QUICK_BACKEND='software', XDG_RUNTIME_DIR=str(temporary))
  result = subprocess.run(['/usr/lib/qt6/bin/qmltestrunner', '-input', str(temporary)], env=env, capture_output=True, text=True, timeout=15)
  print(result.stdout, result.stderr, flush=True)
  assert result.returncode == 0 and 'test_unsupported_platform_fails_closed' in result.stdout
  # Exercise the built interposer, with a fake next Pulse connector and no server.
  fake = temporary / 'pulse-fixture.c'
  fake.write_text("""#include <pulse/pulseaudio.h>
#include <assert.h>
const pa_sample_spec *pa_stream_get_sample_spec(pa_stream *s) {
  static pa_sample_spec spec = { PA_SAMPLE_S16LE, 44100, 2 }; return &spec;
}
int pa_stream_connect_playback(pa_stream *s, const char *d, const pa_buffer_attr *a,
    pa_stream_flags_t f, const pa_cvolume *v, pa_stream *sync) {
  assert(f & PA_STREAM_START_MUTED);
  assert(!(f & PA_STREAM_START_UNMUTED));
  assert(v && v->channels == 2 && v->values[0] == pa_sw_volume_from_linear(0.10));
  return 73;
}
""")
  main = temporary / 'pulse-main.c'
  main.write_text("""#include <pulse/pulseaudio.h>
int main(void) { return pa_stream_connect_playback(0,0,0,PA_STREAM_START_UNMUTED,0,0) == 73 ? 0 : 1; }
""")
  subprocess.run(['cc', '-shared', '-fPIC', str(fake), '-lpulse', '-o', str(temporary / 'fake.so')], check=True)
  subprocess.run(['cc', str(main), '-lpulse', '-o', str(temporary / 'pulse-main')], check=True)
  subprocess.run([str(temporary / 'pulse-main')], env=dict(os.environ,
                 LD_PRELOAD=str(runtime / 'audio/libamiga-pulse.so') + ':' + str(temporary / 'fake.so')), check=True)
  print('Built Pulse interposer: atomic startup mute and -20dB gain verified', flush=True)
  # A no-media software-renderer boot checks installed binary/data layout, not a demo.
  command = ['bwrap', '--unshare-all', '--die-with-parent', '--new-session', '--clearenv',
             '--ro-bind', '/usr', '/usr', '--symlink', 'usr/bin', '/bin', '--symlink', 'usr/lib', '/lib',
             '--symlink', 'usr/lib', '/lib64', '--proc', '/proc', '--dev', '/dev', '--tmpfs', '/tmp',
             '--ro-bind', str(runtime), '/opt/amiga']
  for key, value in dict(PATH='/usr/bin', HOME='/tmp', SDL_VIDEODRIVER='offscreen',
                         LIBGL_ALWAYS_SOFTWARE='1', ALSOFT_DRIVERS='null', LANG='C.UTF-8').items():
    command += ['--setenv', key, value]
  command += ['/opt/amiga/fs-uae/bin/fs-uae', '--stdout', '--base-dir=/tmp/base',
              '--kickstart-file=internal', '--suppress-warning-hud=1', '--volume=0']
  with (temporary / 'fs-uae.log').open('w') as log:
    process = amiga.launch_command(command, log)
    try:
      time.sleep(4)
      assert process.poll() is None, 'Installed emulator exited before boot smoke deadline'
    finally:
      amiga.stop(process)
  text = (temporary / 'fs-uae.log').read_text()
  print(text[-6000:], flush=True)
  assert 'FS-UAE' in text and 'llvmpipe' in text, 'Real software renderer was not initialized'
  print('Installed FS-UAE no-media offscreen boot and exact pidfd cleanup: OK', flush=True)
