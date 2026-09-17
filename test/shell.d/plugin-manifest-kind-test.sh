#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command quickshell
require_command python3
python3 - "$ROOT" <<'PY'
import os, pathlib, re, subprocess, sys, tempfile, time
root = pathlib.Path(sys.argv[1])
source = (root / 'shell/shell.qml').read_text()
function = re.search(r'  function manifestHasKind\(manifest, kind\) \{.*?\n  \}', source, re.S).group()
with tempfile.TemporaryDirectory(prefix='omarchy-kind-test-') as directory:
  path = pathlib.Path(directory)
  (path / 'shell.qml').write_text('''import QtQuick
import Quickshell
ShellRoot {
  property list<string> qtKinds: ["menu"]
''' + function + '''
  Component.onCompleted: {
    var checks = [
      manifestHasKind({kinds: qtKinds}, "menu"),
      !manifestHasKind({kinds: qtKinds}, "bar"),
      manifestHasKind({kinds: ["bar"]}, "bar"),
      !manifestHasKind({kinds: "menu"}, "menu"),
      !manifestHasKind({kinds: {menu: true}}, "menu"),
      !manifestHasKind(null, "menu")
    ]
    console.log("QT_SEQUENCE=" + !Array.isArray(qtKinds))
    console.log("KIND_CHECKS=" + checks.every(function(value) { return value }))
  }
}
''')
  env = os.environ.copy()
  env['QT_QPA_PLATFORM'] = 'offscreen'
  with (path / 'output.log').open('w+') as log:
    process = subprocess.Popen(['quickshell', '-p', directory, '--no-color'], env=env, stdout=log, stderr=log)
    try:
      for _ in range(50):
        time.sleep(0.1)
        log.seek(0)
        output = log.read()
        if 'KIND_CHECKS=' in output or process.poll() is not None:
          break
      if 'QT_SEQUENCE=true' not in output or 'KIND_CHECKS=true' not in output:
        raise SystemExit(output)
    finally:
      process.terminate()
      process.wait(timeout=5)
print('ok - menu capabilities recognize Qt sequences and reject invalid kind values')
PY
