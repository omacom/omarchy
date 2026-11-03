# Optional iwd positioning

`omarchy setup iwd-geolocation` installs dependencies and explicitly opts into BeaconDB Wi-Fi positioning. Nearby public BSS MAC addresses and RSSI go over HTTPS to BeaconDB only while a GeoClue client is connected. SSIDs are never sent for lookups; hidden, `_nomap`, `_optout`, local and multicast addresses are excluded. GPS contribution, phone access, location history and timezone changes are absent. The GeoClue drop-in explicitly disables Wi-Fi data submission so NMEA fixes cannot silently enable contributions or feed derived positions back into a database. The `--scan` mode prints local AP/SSID JSON for separately opted-in tools; it makes no HTTP request. Never log its output in a public bug report.

The service uses iwd's system D-Bus API and a private-group Unix NMEA socket. Missing group or failed ownership assignment is fatal; there is no world-access fallback. The directory is systemd-owned, the socket starts at 0600 and becomes 0660 only after group assignment. Network access is permitted for lookup; iwd access uses the network group. GeoClue still controls app authorization. The service is idle without clients, refreshes every 180 seconds while requested and responds to iwd ConnectedAccessPoint changes. Scans wait at most twelve seconds; HTTP requests time out after ten seconds. There is no cached fix replay: failed lookups never get a new timestamp. GeoClue may retain its last location with its original timestamp; consumers must enforce freshness.

GeoClue's GGA HDOP decoder represents at most 300 m. To avoid falsely reporting a coarse fix as accurate, this bridge rejects accuracy above 300 m rather than using DAILY's 2 km limit. It rounds accuracy upward into GeoClue's supported 50/100/300 m buckets. This loses some rural coverage intentionally.

After setup, let an inactive GeoClue start on demand. If GeoClue was already running, restart **only GeoClue** in an owner-approved window so it reads its new drop-in. No PipeWire, Hyprland or audio restart is needed. Use an authorized existing location client and check its timestamp and coordinates. This setup does not replace iwd or NetworkManager and never disconnects Wi-Fi. Linux systemd, actual iwd D-Bus permissions and GeoClue integration require a staging/owner window; unit tests do not prove these.

Disable with `sudo systemctl disable --now iwd-geolocate.service`, remove the feature's GeoClue drop-in and reload GeoClue when convenient. Remove the installed script/unit only after checking that no optional caller uses them. Dependencies may be shared; do not remove blindly.

## Contribution compatibility, separate opt-in

This change does not enable a contribution timer or call a phone. An owner tool which expects `/usr/local/bin/iwd-geolocate --scan` can opt in by linking that path to `/usr/local/lib/omarchy/iwd-geolocate.py`, after reviewing an existing path rather than overwriting it. The JSON retains `aps` with `macAddress`, `signalStrength`, `ssid`, plus `connected`. The existing owner tool remains responsible for phone GPS age/accuracy/speed checks, overlapping AP checks, opt-out filtering, quotas and consent. Even its dry run may request phone GPS and scan radios; it is an attended check, not a unit test.

## Provenance and tests

New implementation from public iwd D-Bus interfaces, BeaconDB's MLS-compatible API and GeoClue's NMEA interface. DAILY's owner-written bridge was read to establish compatibility and identify defects; this is not a claim of formal two-person clean-room isolation. No private Apple driver code, firmware implementation, disassembly or unpublished hardware interface was used. The code is proposed under this repository's MIT license. Public references:

- https://kernel.googlesource.com/pub/scm/network/wireless/iwd/+/master/doc/station-api.txt
- https://kernel.googlesource.com/pub/scm/network/wireless/iwd/+/master/doc/network-api.txt
- https://kernel.googlesource.com/pub/scm/network/wireless/iwd/+/master/doc/basic-service-set.txt
- https://beacondb.net/ and https://beacondb.net/privacy/
- https://gitlab.freedesktop.org/geoclue/geoclue/-/blob/master/src/gclue-location.c (`get_accuracy_from_hdop`, inspected November 3, 2026)

Run `python3 test/geolocation/test_bridge.py` and `python3 -O test/geolocation/test_bridge.py`. Tests cover opt-out/private AP filtering, JSON compatibility, SSID exclusion from HTTP, disabled IP fallback, coordinate/accuracy validation, NMEA checksum/hemispheres/rounding and socket ownership failures. No real scan or network call is made.
