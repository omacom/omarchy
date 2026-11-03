#!/usr/bin/python3
"""Opt-in iwd positioning; no GPS contribution or persistent scan storage."""
import argparse
import datetime
import grp
import json
import math
import os
import re
import socket
import subprocess
import time
import urllib.request

SOCKET = '/run/iwd-geolocate/nmea.sock'
IWD = 'net.connman.iwd'
STATION = IWD + '.Station'
NETWORK = IWD + '.Network'
BSS = IWD + '.BasicServiceSet'


def call(*args):
    result = subprocess.run(['busctl', '--system', '--json=short', *args],
                            check=True, capture_output=True, text=True, timeout=15)
    return json.loads(result.stdout)['data']


def objects():
    raw = call('call', IWD, '/', 'org.freedesktop.DBus.ObjectManager', 'GetManagedObjects')[0]
    return {path: {interface: {key: value['data'] for key, value in props.items()}
                   for interface, props in interfaces.items()} for path, interfaces in raw.items()}


def collect(tree, ordered, with_ssid=False):
    aps = {}
    for path, strength in ordered:
        network = tree.get(path, {}).get(NETWORK, {})
        name = network.get('Name', '')
        if not name or '_nomap' in name or '_optout' in name:
            continue
        for entry in network.get('ExtendedServiceSet', []):
            address = tree.get(entry, {}).get(BSS, {}).get('Address', '').lower()
            if not re.fullmatch(r'(?:[0-9a-f]{2}:){5}[0-9a-f]{2}', address):
                continue
            # MLS excludes locally administered/multicast addresses.
            if int(address[:2], 16) & 3 or address == '00:00:00:00:00:00':
                continue
            ap = dict(macAddress=address, signalStrength=round(strength / 100))
            if with_ssid:
                ap['ssid'] = name
            aps[address] = ap
    return list(aps.values())


def scan(with_ssid=False):
    tree = objects()
    stations = [path for path, interfaces in tree.items() if STATION in interfaces]
    ordered = []
    for path in stations:
        try:
            call('call', IWD, path, STATION, 'Scan')
        except subprocess.CalledProcessError:
            pass  # Busy: consume the in-progress scan, never disconnect.
        deadline = time.monotonic() + 12
        while time.monotonic() < deadline:
            time.sleep(.25)
            # busctl JSON wraps even a single boolean in its data array.
            if not call('get-property', IWD, path, STATION, 'Scanning')[0]:
                break
        else:
            raise TimeoutError('iwd scan timed out')
        ordered.extend(call('call', IWD, path, STATION, 'GetOrderedNetworks')[0])
    tree = objects()
    connected = next((interfaces[STATION].get('ConnectedAccessPoint')
                      for interfaces in tree.values() if STATION in interfaces), None)
    address = tree.get(connected, {}).get(BSS, {}).get('Address')
    return dict(aps=collect(tree, ordered, with_ssid), connected=address)


def validate(data):
    lat, lon, accuracy = (float(data['location']['lat']), float(data['location']['lng']), float(data['accuracy']))
    # GeoClue's GGA HDOP encoding tops out at 300 metres. Do not publish a
    # coarser fix as a falsely precise one.
    if not all(map(math.isfinite, (lat, lon, accuracy))) or not (-90 <= lat <= 90 and -180 <= lon <= 180 and 0 < accuracy <= 300):
        raise ValueError('Unusable location or accuracy')
    return dict(latitude=lat, longitude=lon, accuracy=accuracy)


def lookup(aps):
    if len(aps) < 2:
        raise ValueError('At least two public access points required')
    body = json.dumps(dict(considerIp=False, wifiAccessPoints=[
        {key: ap[key] for key in ('macAddress', 'signalStrength')} for ap in aps])).encode()
    request = urllib.request.Request('https://api.beacondb.net/v1/geolocate', data=body,
                                    headers={'Content-Type': 'application/json', 'User-Agent': 'omarchy-iwd-geolocate/1'})
    with urllib.request.urlopen(request, timeout=10) as response:
        return validate(json.loads(response.read(65537)))


def gga(fix):
    def coordinate(value, width):
        ticks = round(abs(value) * 60 * 100000)
        degrees, minutes = divmod(ticks, 60 * 100000)
        return f'{degrees:0{width}d}{minutes / 100000:08.5f}'
    lat, lon = fix['latitude'], fix['longitude']
    hdop = 10 if fix['accuracy'] <= 50 else 20 if fix['accuracy'] <= 100 else 25
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime('%H%M%S.00')
    body = f'GPGGA,{stamp},{coordinate(lat, 2)},{"N" if lat >= 0 else "S"},{coordinate(lon, 3)},{"E" if lon >= 0 else "W"},1,00,{hdop},,M,,M,,'
    checksum = 0
    for byte in body.encode():
        checksum ^= byte
    return f'${body}*{checksum:02X}\r\n'.encode()


def listen(path=SOCKET):
    # RuntimeDirectory is owned by the service; fail before bind if the
    # GeoClue group is missing. Never fall back to access for every user.
    group = grp.getgrnam('geoclue').gr_gid
    server = socket.socket(socket.AF_UNIX)
    try:
        if os.path.lexists(path):
            os.unlink(path)
        mask = os.umask(0o177)
        try:
            server.bind(path)
        finally:
            os.umask(mask)
        os.chown(path, -1, group)
        os.chmod(path, 0o660)
        server.listen(4)
        server.setblocking(False)
        return server
    except BaseException:
        server.close()
        if os.path.lexists(path):
            os.unlink(path)
        raise


def serve():
    from gi.repository import Gio, GLib
    server = listen()
    clients = set()
    pending = None

    def update():
        nonlocal pending
        pending = None
        if clients:
            try:
                sentence = gga(lookup(scan()['aps']))
                for client in list(clients):
                    try:
                        client.sendall(sentence)
                    except OSError:
                        drop(client)
            except Exception as error:
                print(f'Location unavailable: {type(error).__name__}', flush=True)
            pending = GLib.timeout_add_seconds(180, update)
        return False

    def schedule(*args):
        nonlocal pending
        if clients:
            if pending is not None:
                GLib.source_remove(pending)
            pending = GLib.timeout_add_seconds(2, update)

    def drop(client):
        clients.discard(client)
        client.close()
        nonlocal pending
        if not clients and pending is not None:
            GLib.source_remove(pending)
            pending = None

    def client_ready(client, condition):
        try:
            if not client.recv(1024):
                drop(client)
                return False
        except OSError:
            drop(client)
            return False
        return True

    def accept(*args):
        client, _ = server.accept()
        client.setblocking(False)
        if len(clients) >= 4:
            client.close()
        else:
            clients.add(client)
            GLib.io_add_watch(client, GLib.IO_IN | GLib.IO_HUP | GLib.IO_ERR, client_ready)
            schedule()
        return True

    bus = Gio.bus_get_sync(Gio.BusType.SYSTEM, None)
    bus.signal_subscribe(IWD, 'org.freedesktop.DBus.Properties', 'PropertiesChanged',
                         None, STATION, Gio.DBusSignalFlags.NONE,
                         lambda *args: schedule() if 'ConnectedAccessPoint' in args[5].unpack()[1] else None)
    GLib.io_add_watch(server, GLib.IO_IN, accept)
    GLib.MainLoop().run()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--scan', action='store_true', help='local JSON only, including SSIDs; no lookup or submission')
    mode.add_argument('--once', action='store_true', help='print one BeaconDB fix as JSON')
    args = parser.parse_args()
    if args.scan:
        print(json.dumps(scan(with_ssid=True)))
    elif args.once:
        print(json.dumps(lookup(scan()['aps'])))
    else:
        serve()


if __name__ == '__main__':
    main()
