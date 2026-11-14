#!/usr/bin/python3
import sys
import re
import gi
from gi.repository import Gio, GLib

if len(sys.argv) != 2 or not re.fullmatch(r'(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}', sys.argv[1]):
    sys.exit(2)
address = sys.argv[1].upper()
loop = GLib.MainLoop()
xml = '''<node><interface name="org.bluez.Agent1">
<method name="Release"/><method name="Cancel"/>
<method name="DisplayPinCode"><arg type="o" direction="in"/><arg type="s" direction="in"/></method>
<method name="DisplayPasskey"><arg type="o" direction="in"/><arg type="u" direction="in"/><arg type="q" direction="in"/></method>
<method name="RequestPinCode"><arg type="o" direction="in"/><arg type="s" direction="out"/></method>
<method name="RequestPasskey"><arg type="o" direction="in"/><arg type="u" direction="out"/></method>
<method name="RequestConfirmation"><arg type="o" direction="in"/><arg type="u" direction="in"/></method>
<method name="RequestAuthorization"><arg type="o" direction="in"/></method>
<method name="AuthorizeService"><arg type="o" direction="in"/><arg type="s" direction="in"/></method>
</interface></node>'''
def emit(kind, message):
    print(kind + '\t' + str(message).replace('\n', ' '), flush=True)
def agent(connection, sender, path, interface, method, params, invocation):
    args = params.unpack()
    if method == 'DisplayPasskey':
        emit('code', f'{args[1]:06d}')
    elif method == 'DisplayPinCode':
        emit('code', args[1])
    elif method == 'Cancel':
        emit('error', 'Pairing was cancelled.')
    elif method not in ('Release',):
        emit('error', 'This device requires a pairing prompt that this card cannot handle.')
        invocation.return_dbus_error('org.bluez.Error.Rejected', 'Unsupported pairing request')
        return
    invocation.return_value(None)
def call(bus, path, interface, method, params=None, result=None):
    return bus.call_sync('org.bluez', path, interface, method, params, result, Gio.DBusCallFlags.NONE, 10000, None)
try:
    bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    objects = call(bus, '/', 'org.freedesktop.DBus.ObjectManager', 'GetManagedObjects', None, GLib.VariantType.new('(a{oa{sa{sv}}})')).unpack()[0]
    paths = [p for p, interfaces in objects.items() if interfaces.get('org.bluez.Device1', {}).get('Address', '').upper() == address]
    if not paths:
        raise RuntimeError('Device no longer available. Put it in pairing mode and try again.')
    device = paths[0]
    agent_path = '/org/fperez/bluetooth/pair_agent'
    bus.register_object(agent_path, Gio.DBusNodeInfo.new_for_xml(xml).interfaces[0], agent, None, None)
    call(bus, '/org/bluez', 'org.bluez.AgentManager1', 'RegisterAgent', GLib.Variant('(os)', (agent_path, 'KeyboardDisplay')))
    def completed(conn, result, data):
        try:
            conn.call_finish(result)
            call(bus, device, 'org.freedesktop.DBus.Properties', 'Set', GLib.Variant('(ssv)', ('org.bluez.Device1', 'Trusted', GLib.Variant('b', True))))
            emit('done', 'Pairing complete.')
        except Exception as exc:
            emit('error', 'Pairing failed: ' + str(exc))
        loop.quit()
    emit('status', 'Waiting for pairing…')
    bus.call('org.bluez', device, 'org.bluez.Device1', 'Pair', None, None, Gio.DBusCallFlags.NONE, 90000, None, completed, None)
    loop.run()
except Exception as exc:
    emit('error', str(exc))
    sys.exit(1)
