#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import time
from urllib.request import Request, build_opener, HTTPRedirectHandler
from urllib.parse import urlparse


class Watcher:
    def __init__(self, launch):
        self.launch = launch
        self.active = False
        self.known = {}

    def update(self, fleet):
        desktops, hosts = fleet['desktops'], fleet['hosts']
        if not isinstance(desktops, list) or not isinstance(hosts, list) or not hosts:
            raise ValueError('Invalid fleet snapshot')
        for host in hosts:
            if host.get('online') is True:
                self.known[host['id']] = sum(d['host'] == host['id'] for d in desktops)
        if any(d.get('ready') for d in desktops):
            if not self.active:
                self.launch()
                self.active = True
        elif self.known and not any(self.known.values()):
            self.active = False


def snapshot():
    try:
        config = json.loads((Path.home() / '.config/agent-desktops/fleet.json').read_text())
    except FileNotFoundError:
        state = Path.home() / '.local/share/hypr-desktop'
        config = {'url': (state / 'local-url').read_text().strip().removesuffix('/mcp'), 'tokenFile': str(state / 'token')}
    endpoint = urlparse(config['url'])
    local = endpoint.scheme == 'http' and endpoint.hostname in ('127.0.0.1', 'localhost')
    if (not local and endpoint.scheme != 'https') or endpoint.username or endpoint.password or endpoint.query or endpoint.fragment:
        raise ValueError('Viewer requires local loopback HTTP or HTTPS without URL credentials')
    if not Path(config['tokenFile']).is_absolute():
        raise ValueError('Viewer tokenFile must be an absolute path')
    token = Path(config['tokenFile']).read_text().strip()
    request = Request(config['url'].rstrip('/') + '/hypr-desktop/viewer/agents/fleet',
                      headers={'Authorization': 'Bearer ' + token})
    class NoRedirect(HTTPRedirectHandler):
        def redirect_request(self, *args, **kwargs):
            return None
    with build_opener(NoRedirect).open(request, timeout=10) as response:
        return json.load(response)


def running():
    from gi.repository import Gio, GLib
    bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    return bus.call_sync('org.freedesktop.DBus', '/org/freedesktop/DBus',
                         'org.freedesktop.DBus', 'NameHasOwner',
                         GLib.Variant('(s)', ('org.omarchy.AgentDesktops',)),
                         None, Gio.DBusCallFlags.NONE, 2000, None).unpack()[0]


def ready():
    from gi.repository import Gio, GLib
    try:
        bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
        result = bus.call_sync('org.omarchy.AgentDesktops', '/org/omarchy/AgentDesktops',
                               'org.gtk.Actions', 'Describe',
                               GLib.Variant('(s)', ('viewer-ready',)),
                               None, Gio.DBusCallFlags.NONE, 1000, None)
        return result.unpack()[0][2] == [True]
    except GLib.Error:
        return False


def await_ready(check=ready, sleep=time.sleep, attempts=20):
    for _ in range(attempts):
        if check():
            return
        sleep(0.5)
    raise OSError('Viewer did not finish starting; will retry')


class Launcher:
    def __init__(self):
        self.starting = False

    def __call__(self):
        from gi.repository import GLib
        try:
            exists = running()
        except GLib.Error as exc:
            raise OSError('Session bus unavailable') from exc
        if exists and not self.starting:
            return
        if not exists:
            subprocess.run(['systemd-run', '--user', '--collect', '--quiet',
                            '--property=Type=exec', '--property=PartOf=graphical-session.target',
                            '--setenv=PATH=' + os.environ['PATH'],
                            str(Path(__file__).with_name('agent-desktops')), '--auto-open'],
                           check=True, timeout=5)
            self.starting = True
        await_ready()
        self.starting = False


def main():
    watcher = Watcher(Launcher())
    error = None
    while True:
        try:
            watcher.update(snapshot())
            error = None
        except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as exc:
            message = str(exc)
            if message != error:
                print('Agent Desktops watcher: ' + message, flush=True)
            error = message
        time.sleep(3)


if __name__ == '__main__':
    main()
