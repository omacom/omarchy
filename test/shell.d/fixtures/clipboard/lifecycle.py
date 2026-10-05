"""Run real clipboard processes offscreen, with an isolated history and clipboard."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

root = Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory(prefix='clipboard-lifecycle-') as temporary:
  folder = Path(temporary)
  for name in ['bin', 'home/.local/state/omarchy/clipboard-text', 'runtime', 'cache']:
    (folder / name).mkdir(parents=True)
  (folder / 'runtime').chmod(0o700)
  state = folder / 'home/.local/state/omarchy'
  history = state / 'clipboard-history.json'
  history.write_text('[{"type":"text","text":"open this in the editor"}]')
  orphan = state / ('clipboard-text/' + 'a' * 64 + '.txt')
  orphan.write_text('recently evicted')
  for name in ['Commons', 'Ui']:
    (folder / name).symlink_to(root / 'shell' / name)
  (folder / 'ClipboardHistory.js').symlink_to(root / 'shell/plugins/clipboard/ClipboardHistory.js')
  qml = (root / 'shell/plugins/clipboard/Clipboard.qml').read_text()
  qml = qml.replace('import QtQuick\n', 'import QtQuick\nimport QtQuick.Window\n')
  qml = qml.replace('  property string omarchyPath:', '  property bool testStorageBusy: loadProc.running || saveProc.running || saveRequested || reloadRequested\n  property string omarchyPath:')
  # Exercise the actual controller without creating a layer-shell surface.
  qml = qml.replace('  OverlayWindow {', '  Window {\n    width: 1100\n    height: 780').replace('    shown: root.opened', '    visible: root.opened')
  qml = '\n'.join(line for line in qml.splitlines() if 'WlrLayershell.namespace:' not in line)
  qml = qml.replace('interval: 60000', 'interval: 100')
  (folder / 'Clipboard.qml').write_text(qml)
  (folder / 'shell.qml').write_text('''import QtQuick
import Quickshell
import Quickshell.Io
ShellRoot {
  Clipboard { id: clipboard }
  property int phase: 0
  property int quietTicks: 0
  Timer {
    interval: 50; running: true; repeat: true
    onTriggered: {
      if (phase === 0 && clipboard.historyWritable) {
        clipboard.openSelected({entryType: "text", historyIndex: 0})
        clipboard.addClipboardEntry({type: "text", text: "中".repeat(87000)})
        clipboard.addClipboardEntry({type: "text", text: "newest captured copy"})
        phase = 1
      } else if (phase === 1 && !clipboard.testStorageBusy) {
        clipboard.copySelected({entryType: "text", fullText: clipboard.history[0].text, historyIndex: 0})
        phase = 2
      } else if (phase === 2 && !clipboard.testStorageBusy && ++quietTicks > 8) {
        // The fresh file must survive early prune passes. Age it only after
        // storage settles, then let the real periodic timer remove it.
        age.running = true
        phase = 3
      }
    }
  }
  Process {
    id: age
    command: ["python3", "-c", "import os,time; p=os.environ['CLIPBOARD_TEST_ORPHAN']; assert os.path.isfile(p); os.utime(p,(time.time()-120,)*2)"]
    onExited: function(code) {
      if (code !== 0) { console.log("CLIPBOARD_LIFECYCLE_FAIL: fresh orphan removed early"); Qt.quit() }
      else finish.start()
    }
  }
  Timer { id: finish; interval: 500; onTriggered: { console.log("CLIPBOARD_LIFECYCLE_PASS"); Qt.quit() } }
  Timer { interval: 8000; running: true; onTriggered: { console.log("CLIPBOARD_LIFECYCLE_FAIL: timed out"); Qt.quit() } }
}
''')
  stubs = {
    'pkill': 'exit 0',
    'wl-paste': 'if [[ $* == *--watch* ]]; then exec sleep 30; fi; exit 0',
    'wl-copy': 'cat > "$CLIPBOARD_TEST_DIR/copied"',
    'omarchy-launch-editor': 'cat "$1" > "$CLIPBOARD_TEST_DIR/editor-opened"; sleep 5; touch "$CLIPBOARD_TEST_DIR/editor-finished"',
    'wtype': 'exit 0',
    'hyprctl': "printf '{\"int\":0}\\n'",
  }
  for name, body in stubs.items():
    script = folder / 'bin' / name
    script.write_text('#!/bin/bash\n' + body + '\n')
    script.chmod(0o755)
  env = {**os.environ, 'QT_QPA_PLATFORM': 'offscreen', 'QT_QPA_PLATFORMTHEME': '',
    'QT_STYLE_OVERRIDE': '', 'QT_QUICK_BACKEND': 'software', 'OMARCHY_PATH': str(root),
    'HOME': str(folder / 'home'), 'XDG_RUNTIME_DIR': str(folder / 'runtime'),
    'XDG_STATE_HOME': str(folder / 'home/.local/state'), 'XDG_CACHE_HOME': str(folder / 'cache'),
    'PATH': str(folder / 'bin') + ':/usr/bin', 'CLIPBOARD_TEST_DIR': str(folder),
    'CLIPBOARD_TEST_ORPHAN': str(orphan)}
  result = subprocess.run(['quickshell', '-p', str(folder / 'shell.qml'), '--no-color'], env=env, capture_output=True, text=True, timeout=12)
  log = result.stdout + result.stderr
  assert result.returncode == 0 and 'CLIPBOARD_LIFECYCLE_PASS' in log and 'CLIPBOARD_LIFECYCLE_FAIL' not in log, log
  assert (folder / 'editor-opened').read_text() == 'open this in the editor', log
  assert (folder / 'copied').read_text() == 'newest captured copy', log
  assert not (folder / 'editor-finished').exists(), log
  print('ok - clipboard copies the selected snapshot while an editor action is still running')
  entries = json.loads(history.read_text())
  assert [e['text'] for e in entries] == ['newest captured copy', '中' * 87000, 'open this in the editor'], log
  print('ok - clipboard queued saves and file notifications retain every captured entry')
  assert not orphan.exists(), log
  print('ok - clipboard periodic cleanup removes an expired orphan after copying stops')
