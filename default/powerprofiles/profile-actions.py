#!/usr/bin/python3
"""Root-owned actions only; the daemon's ActiveProfile is authoritative."""
import logging
import os
import stat
import subprocess
from pathlib import Path
from gi.repository import Gio, GLib

logging.basicConfig(level=logging.INFO)
bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
pending = False


def apply():
    global pending
    pending = False
    try:
        reply = bus.call_sync('net.hadess.PowerProfiles', '/net/hadess/PowerProfiles',
                              'org.freedesktop.DBus.Properties', 'Get',
                              GLib.Variant('(ss)', ('net.hadess.PowerProfiles', 'ActiveProfile')),
                              None, Gio.DBusCallFlags.NONE, 3000, None)
        profile = reply.unpack()[0]
        if profile not in ('power-saver', 'balanced', 'performance'):
            raise ValueError(profile)
        for script in sorted(Path('/etc/omarchy/powerprofiles/actions.d').glob('*')):
            status = script.lstat()
            if (stat.S_ISREG(status.st_mode) and status.st_uid == 0
                    and not status.st_mode & 0o022 and os.access(script, os.X_OK)):
                try:
                    subprocess.run([str(script), profile], check=True, timeout=10)
                except (subprocess.SubprocessError, OSError):
                    logging.exception('Profile action failed: %s', script)
    except GLib.Error:
        logging.exception('Cannot read ActiveProfile')
    return GLib.SOURCE_REMOVE


def changed(*args):
    global pending
    if not pending:
        pending = True
        GLib.timeout_add(100, apply)


bus.signal_subscribe(None, 'org.freedesktop.DBus.Properties', 'PropertiesChanged',
                     '/net/hadess/PowerProfiles', None, Gio.DBusSignalFlags.NONE, changed)
# Reapply after activation/reconnection and newly added Wi-Fi devices.
bus.signal_subscribe('org.freedesktop.NetworkManager', 'org.freedesktop.DBus.Properties',
                     'PropertiesChanged', None, 'org.freedesktop.NetworkManager.Device',
                     Gio.DBusSignalFlags.NONE,
                     lambda *args: changed() if 'State' in args[5].unpack()[1] else None)
for name in ('net.hadess.PowerProfiles', 'org.freedesktop.NetworkManager'):
    bus.signal_subscribe('org.freedesktop.DBus', 'org.freedesktop.DBus', 'NameOwnerChanged',
                         '/org/freedesktop/DBus', name, Gio.DBusSignalFlags.NONE, changed)
changed()
GLib.MainLoop().run()
