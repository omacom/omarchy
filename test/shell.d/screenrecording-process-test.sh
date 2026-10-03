#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"

require_command python3

# Stop and status match a recorder by its executable, so a file or argument
# named like one never counts, and signal it through a pidfd opened first.
python3 - "$ROOT" <<'PY'
import importlib.machinery
import importlib.util
import os
from pathlib import Path
import signal
import sys
import tempfile
from types import SimpleNamespace
from unittest import mock
root = Path(sys.argv[1])
sys.dont_write_bytecode = True
loader = importlib.machinery.SourceFileLoader('recorder', str(root / 'bin/omarchy-capture-screenrecording-process'))
spec = importlib.util.spec_from_loader(loader.name, loader)
m = importlib.util.module_from_spec(spec); loader.exec_module(m)
with tempfile.TemporaryDirectory() as temporary:
    proc = Path(temporary)
    def process(pid, executable, command):
        path = proc / str(pid); path.mkdir()
        (path / 'exe').symlink_to(executable)
        (path / 'cmdline').write_bytes(command)
        return path
    false = process(100, '/usr/bin/editor', b'editor\0/tmp/wf-recorder\0--edit\0')
    process(101, '/usr/bin/python3', b'python3\0/usr/bin/gpu-screen-recorder\0')
    process(102, '/usr/bin/wf-recorder-helper', b'wf-recorder-helper\0')
    process(105, '/usr/bin/bash', b'wf-recorder\0')
    assert not m.recording_processes(proc=proc), 'argument paths and suffix applications are not recorders'
    wf = process(103, '/opt/recording tools/wf-recorder', b'/opt/recording tools/wf-recorder\0-f\0test.mp4\0')
    gpu = process(104, '/usr/local/bin/gpu-screen-recorder (deleted)', b'/usr/local/bin/gpu-screen-recorder\0')
    assert m.recording_processes(proc=proc), 'both absolute executable paths must work'
    with mock.patch.object(m.os, 'pidfd_open', side_effect=lambda pid: pid + 1000) as opened, mock.patch.object(m.os, 'close') as closed, mock.patch.object(m.signal, 'pidfd_send_signal') as sent:
        assert m.recording_processes(signal.SIGINT, proc)
        assert {(call.args[0], call.args[1]) for call in sent.call_args_list} == {(1103, signal.SIGINT), (1104, signal.SIGINT)}
        assert opened.call_count == closed.call_count == 6
    with mock.patch.object(m.os, 'pidfd_open', side_effect=lambda pid: pid + 1000) as opened, mock.patch.object(m.os, 'close') as closed, mock.patch.object(m.signal, 'pidfd_send_signal') as sent:
        assert m.recording_processes(signal.SIGINT, proc, pids=[103])
        assert {(call.args[0], call.args[1]) for call in sent.call_args_list} == {(1103, signal.SIGINT)}
        assert opened.call_count == closed.call_count == 1
    # Opening the handle must precede identity validation, including forced stop.
    def change_identity(pid):
        path = proc / str(pid) / 'exe'
        if pid in (103, 104): path.unlink(); path.symlink_to('/usr/bin/unrelated')
        return pid + 1000
    with mock.patch.object(m.os, 'pidfd_open', side_effect=change_identity), mock.patch.object(m.os, 'close'), mock.patch.object(m.signal, 'pidfd_send_signal') as sent:
        assert not m.recording_processes(signal.SIGKILL, proc)
        sent.assert_not_called()
    with mock.patch.object(Path, 'stat', return_value=SimpleNamespace(st_uid=os.geteuid() + 1)), mock.patch.object(m.os, 'readlink') as readlink:
        assert not m.is_recorder(wf)
        readlink.assert_not_called()
    with mock.patch.object(m.os, 'readlink', side_effect=PermissionError), mock.patch.object(m.os, 'pidfd_open', return_value=999), mock.patch.object(m.os, 'close') as closed, mock.patch.object(m.signal, 'pidfd_send_signal') as sent:
        assert not m.recording_processes(signal.SIGINT, proc)
        sent.assert_not_called()
        assert closed.call_count == 6
print('ok - executable identity rejects recorder argument paths and safely shares status/signal selection')
PY

grep -Fq '["omarchy-capture-screenrecording", "--status"]' "$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml" ||
  fail "the bar recording indicator asks the recorder script, which stop also uses"
! grep -Fq 'gpu-screen-recorder' "$ROOT/shell/plugins/bar/indicators/ScreenRecording.qml" ||
  fail "the bar recording indicator still greps gpu-screen-recorder"
grep -Fq '"when":"omarchy-capture-screenrecording --status"' "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "Stop Screenrecording asks the recorder script, which its action also uses"
! grep -Fq "pgrep -f '^gpu-screen-recorder'" "$ROOT/default/omarchy/omarchy-menu.jsonc" ||
  fail "Stop Screenrecording still greps gpu-screen-recorder"
pass "the bar indicator and the menu ask the recorder script whether its stop has a recording to end"
