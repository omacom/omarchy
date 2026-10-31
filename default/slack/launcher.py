"""Apply native theme preferences to packaged Slack over inherited pipes."""

import json
import os
from pathlib import Path
import signal
import sys

from gi.repository import Gio, GLib


class Slack:
    def __init__(self, directory):
        self.directory = Path(directory)
        self.theme_file = self.directory / 'theme.json'
        self.theme = ''
        self.script = Path(__file__).with_name('theme.js').read_text().strip()
        self.sessions = set()
        self.callbacks = {}
        self.next_id = 0
        self.buffer = b''
        self.outbox = []
        self.loop = GLib.MainLoop()

    def start(self, arguments, binary='/usr/bin/slack'):
        # Chromium reads descriptor 3 and writes descriptor 4. The inherited
        # pipes belong to this launch; no debugging socket or port is opened.
        outgoing, writer = os.pipe()
        reader, incoming = os.pipe()
        launcher = Gio.SubprocessLauncher.new(Gio.SubprocessFlags.NONE)
        launcher.take_fd(outgoing, 3)
        launcher.take_fd(incoming, 4)
        self.child = launcher.spawnv([binary, '--remote-debugging-pipe', *arguments])
        self.input = Gio.UnixInputStream.new(reader, True)
        self.output = Gio.UnixOutputStream.new(writer, True)
        self.input.read_bytes_async(65536, 0, None, self.received)
        self.child.wait_async(None, self.exited)
        self.monitor = Gio.File.new_for_path(str(self.directory)).monitor_directory(Gio.FileMonitorFlags.WATCH_MOVES, None)
        self.monitor.connect('changed', self.changed)
        self.theme = self.theme_file.read_text() if self.theme_file.exists() else ''
        self.send('Target.setAutoAttach', {'autoAttach': True, 'waitForDebuggerOnStart': False, 'flatten': True,
                                          'filter': [{'type': 'page'}, {'exclude': True}]})
        for number in (signal.SIGTERM, signal.SIGINT):
            GLib.unix_signal_add(0, number, self.stop, number)

    def send(self, method, params=None, session=None, callback=None):
        self.next_id += 1
        message = {'id': self.next_id, 'method': method, 'params': params or {}}
        if session:
            message['sessionId'] = session
        if callback:
            self.callbacks[self.next_id] = callback
        self.outbox.append(json.dumps(message).encode() + b'\0')
        if len(self.outbox) == 1:
            self.write()

    def write(self):
        self.output.write_all_async(self.outbox[0], 0, None, self.written)

    def written(self, stream, result):
        try:
            stream.write_all_finish(result)
            self.outbox.pop(0)
            if self.outbox:
                self.write()
        except GLib.Error as error:
            print('Slack theme pipe:', error.message, file=sys.stderr)

    def received(self, stream, result):
        try:
            data = stream.read_bytes_finish(result).get_data()
            if not data:
                return
            self.buffer += data
            while b'\0' in self.buffer:
                message, self.buffer = self.buffer.split(b'\0', 1)
                self.dispatch(json.loads(message))
            stream.read_bytes_async(65536, 0, None, self.received)
        except (GLib.Error, ValueError) as error:
            print('Slack theme pipe:', str(error), file=sys.stderr)

    def dispatch(self, message):
        callback = self.callbacks.pop(message.get('id'), None)
        if callback:
            callback(message)
        params, session = message.get('params', {}), message.get('sessionId')
        if message.get('method') == 'Target.attachedToTarget':
            session = params['sessionId']
            self.sessions.add(session)
            self.send('Runtime.enable', session=session)
        elif message.get('method') == 'Target.detachedFromTarget':
            self.sessions.discard(params['sessionId'])
        elif message.get('method') == 'Runtime.executionContextCreated':
            if params['context'].get('auxData', {}).get('isDefault'):
                self.apply(session)

    def apply(self, session):
        if self.theme and session in self.sessions:
            # Native preference actions are synchronous. Pipe ordering keeps
            # rapid changes in order, without stylesheet or navigation handles.
            self.send('Runtime.evaluate', {'expression': self.script + '(' + self.theme + ')'}, session)

    def changed(self, monitor, file, other, event):
        if any(item and item.get_basename() == 'theme.json' for item in (file, other)):
            try:
                theme = self.theme_file.read_text()
            except OSError:
                return
            if theme != self.theme:
                self.theme = theme
                for session in self.sessions:
                    self.apply(session)

    def stop(self, number):
        self.child.send_signal(number)
        return GLib.SOURCE_REMOVE

    def exited(self, child, result):
        child.wait_finish(result)
        self.monitor.cancel()
        self.loop.quit()

    def run(self, arguments):
        self.start(arguments)
        self.loop.run()
        return self.child.get_exit_status() if self.child.get_if_exited() else 128 + self.child.get_term_sig()


if __name__ == '__main__':
    directory = Path.home() / '.local/state/omarchy/slack'
    sys.exit(Slack(directory).run(sys.argv[1:]))
