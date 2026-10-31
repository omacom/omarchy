"""Exercise the real controller's inherited-pipe and file-monitor transport."""

import json
import os
from pathlib import Path
import shlex
import sys
import tempfile

from gi.repository import Gio, GLib

root = Path(os.environ['ROOT'])
sys.path.insert(0, str(root / 'default/slack'))
from launcher import Slack

with tempfile.TemporaryDirectory() as directory:
    scratch = Path(directory)
    theme_file = scratch / 'theme.json'
    theme_file.write_text('{"mode":"stale"}')
    # A separate process speaks CDP on descriptors 3/4. No Slack installation,
    # socket server or simulated file watcher is involved in this transport test.
    server = scratch / 'server.py'
    server.write_text('''
import json,os
from pathlib import Path
root=Path(os.environ['TEST_PIPE_ROOT'])
reader=os.fdopen(3,'rb',buffering=0)
writer=os.fdopen(4,'wb',buffering=0)
buffer=b'';stage=0

def emit(message):
    writer.write(json.dumps(message).encode()+b'\\0')

def attach(session):
    emit({'method':'Target.attachedToTarget','params':{'sessionId':session,'targetInfo':{'type':'page'}}})

while True:
    chunk=reader.read(65536)
    if not chunk:break
    buffer+=chunk
    while b'\\0' in buffer:
        raw,buffer=buffer.split(b'\\0',1);m=json.loads(raw)
        with (root/'events').open('a') as f:f.write(json.dumps(m)+'\\n')
        result={};session=m.get('sessionId');method=m['method']
        emit({'id':m['id'],'result':result})
        if method=='Target.setAutoAttach':attach('one')
        if method=='Runtime.enable':
            emit({'method':'Runtime.executionContextCreated','sessionId':session,
                  'params':{'context':{'auxData':{'isDefault':True}}}})
        if method=='Runtime.evaluate':
            expression=m['params']['expression']
            assert expression.startswith('(colors => {')
            theme=json.loads(expression[expression.rfind(')(')+2:-1])
            if stage==0:
                assert theme['mode']=='dark';stage=1
                (root/'theme.next').write_text('{"mode":"light"}');(root/'theme.next').replace(root/'theme.json')
            elif stage==1:
                assert theme['mode']=='light';stage=2;attach('two')
            elif stage==2 and session=='two':
                assert theme['mode']=='light';stage=3
                emit({'method':'Runtime.executionContextCreated','sessionId':'one',
                      'params':{'context':{'auxData':{'isDefault':True}}}})
            elif stage==3 and session=='one':
                assert theme['mode']=='light';(root/'complete').touch();raise SystemExit(0)
''')
    binary = scratch / 'slack'
    binary.write_text('#!/bin/bash\nprintf "%s\\0" "$@" >"$TEST_PIPE_ROOT/arguments"\nexec /usr/bin/python ' + shlex.quote(str(server)) + '\n')
    binary.chmod(0o755)
    os.environ['TEST_PIPE_ROOT'] = str(scratch)
    app = Slack(scratch)
    # A switch between construction and starting the monitor must not leave
    # the helper serving an obsolete theme for the rest of this launch.
    (scratch / 'theme.next').write_text('{"mode":"dark"}')
    (scratch / 'theme.next').replace(theme_file)
    app.start(['--user-data-dir=' + str(scratch / 'profile with spaces')], str(binary))
    timed_out = []
    def deadline():
        timed_out.append(True)
        app.child.force_exit()
        return GLib.SOURCE_REMOVE
    timeout = GLib.timeout_add_seconds(5, deadline)
    app.loop.run()
    if not timed_out:
        GLib.source_remove(timeout)
    assert not timed_out and app.child.get_successful(), (scratch / 'events').read_text()
    assert (scratch / 'complete').exists()
    arguments = (scratch / 'arguments').read_bytes().split(b'\0')[:-1]
    assert arguments == [b'--remote-debugging-pipe', ('--user-data-dir=' + str(scratch / 'profile with spaces')).encode()]
    assert app.monitor.is_cancelled()
    assert not (scratch / '.cache').exists()
    print('ok - packaged-app transport uses inherited pipes, observes atomic theme writes, themes new windows and navigation, and exits with Slack')
