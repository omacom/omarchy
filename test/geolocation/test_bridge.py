import importlib.util
from pathlib import Path
import socket
import tempfile
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location('bridge', Path(__file__).resolve().parents[2] / 'default/geolocation/iwd-geolocate.py')
b = importlib.util.module_from_spec(spec)
spec.loader.exec_module(b)


class Bridge(unittest.TestCase):
    def test_scan_filters_private_nomap_and_duplicates(self):
        tree = {'/n': {b.NETWORK: dict(Name='Cafe', ExtendedServiceSet=['/b', '/p', '/b'])},
                '/b': {b.BSS: dict(Address='00:11:22:33:44:55')},
                '/p': {b.BSS: dict(Address='02:11:22:33:44:55')},
                '/hidden': {b.NETWORK: dict(Name='secret_nomap', ExtendedServiceSet=['/b'])}}
        self.assertEqual(b.collect(tree, [('/n', -5200), ('/hidden', -2000)]),
                         [dict(macAddress='00:11:22:33:44:55', signalStrength=-52)])
        self.assertEqual(b.collect(tree, [('/n', -5200)], True)[0]['ssid'], 'Cafe')

    def test_scan_waits_for_busctl_false_then_collects_networks(self):
        tree = {'/station': {b.STATION: dict(ConnectedAccessPoint='/b')},
                '/n': {b.NETWORK: dict(Name='Cafe', ExtendedServiceSet=['/b'])},
                '/b': {b.BSS: dict(Address='00:11:22:33:44:55')}}
        replies = [Mock(stdout=value) for value in (
            '{"data":[]}', '{"data":[true]}', '{"data":[false]}',
            '{"data":[[["/n",-5200]]]}')]
        with patch.object(b, 'objects', return_value=tree), \
                patch.object(b.subprocess, 'run', side_effect=replies) as run, \
                patch.object(b.time, 'sleep'), \
                patch.object(b.time, 'monotonic', side_effect=[0, 0, 1, 13]):
            result = b.scan()
        self.assertEqual(result, dict(
            aps=[dict(macAddress='00:11:22:33:44:55', signalStrength=-52)],
            connected='00:11:22:33:44:55'))
        self.assertEqual([args.args[0][-1] for args in run.call_args_list],
                         ['Scan', 'Scanning', 'Scanning', 'GetOrderedNetworks'])

    def test_invalid_or_coarse_fix(self):
        for lat, lon, accuracy in [(91, 0, 1), (0, 181, 1), (float('nan'), 0, 5),
                                   (0, 0, -1), (0, 0, float('inf')), (0, 0, 301)]:
            with self.assertRaises(ValueError):
                b.validate(dict(location=dict(lat=lat, lng=lon), accuracy=accuracy))

    def test_lookup_never_transmits_ssid_or_uses_ip(self):
        import io, json
        with patch.object(b.urllib.request, 'urlopen', return_value=io.BytesIO(b'{"location":{"lat":1,"lng":2},"accuracy":50}')) as request:
            b.lookup([dict(macAddress='00:11:22:33:44:55', signalStrength=-50, ssid='PRIVATE')]*2)
        data = json.loads(request.call_args.args[0].data)
        self.assertIs(data['considerIp'], False)
        self.assertNotIn('PRIVATE', str(data))
        with patch.object(b.urllib.request, 'urlopen') as request:
            with self.assertRaises(ValueError): b.lookup([])
            request.assert_not_called()

    def test_nmea_hemispheres_and_checksum(self):
        sentence = b.gga(dict(latitude=-33.5, longitude=-70.25, accuracy=100))
        self.assertIn(b',3330.00000,S,07015.00000,W,', sentence)
        body, checksum = sentence[1:].strip().split(b'*')
        result = 0
        for byte in body: result ^= byte
        self.assertEqual(int(checksum, 16), result)
        self.assertIn(b',9000.00000,N,18000.00000,E,', b.gga(dict(latitude=89.999999999, longitude=179.999999999, accuracy=50)))

    def test_socket_permissions_fail_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            path = str(Path(directory) / 'nmea.sock')
            with patch.object(b.grp, 'getgrnam', side_effect=KeyError('geoclue')):
                with self.assertRaises(KeyError): b.listen(path)
            self.assertFalse(Path(path).exists())
            with patch.object(b.grp, 'getgrnam') as group, patch.object(b.os, 'chown', side_effect=PermissionError):
                group.return_value.gr_gid = 1
                with self.assertRaises(PermissionError): b.listen(path)
            self.assertFalse(Path(path).exists())
            with patch.object(b.grp, 'getgrnam') as group, patch.object(b.os, 'chown'):
                group.return_value.gr_gid = 1
                server = b.listen(path)
            self.assertEqual(Path(path).stat().st_mode & 0o777, 0o660)
            server.close()


if __name__ == '__main__': unittest.main()
