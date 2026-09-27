#!/usr/bin/env python3
"""Temperature and currency for the world clock's cities.

Reads a JSON list of {"label", "id"} rows on stdin, writes a JSON map of
per-row facts on stdout. Everything is cached on disk with its own TTL, so the
plugin can call this as often as it likes without hammering anyone:

  geocode  forever   a city does not move
  currency 6 hours   published once a day
  weather  20 min    the resolution the source actually offers

Network failures are never fatal. Anything that cannot be fetched falls back
to the cached value, and failing that is simply omitted - a row with no
temperature renders without one rather than blocking the panel.
"""

import json
import os
import sys
import time
import urllib.parse
import urllib.request

CACHE = os.path.join(
    os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")),
    "omacom-elsewhen", "data.json",
)
FX_TTL = 6 * 3600
WX_TTL = 20 * 60
TIMEOUT = 8

GEOCODE = "https://geocoding-api.open-meteo.com/v1/search"
FORECAST = "https://api.open-meteo.com/v1/forecast"
FX = "https://open.er-api.com/v6/latest/USD"

ZONE_TAB = "/usr/share/zoneinfo/zone1970.tab"

# ISO 3166-1 alpha-2 -> ISO 4217. Every code here is validated against the
# system's iso-codes data and against the FX feed by tests/currency_check.py.
# Note BG and HR map to EUR: both have adopted the euro, and the FX feed still
# publishes legacy peg rates for BGN and HRK that would otherwise show a
# retired currency.
COUNTRY_CURRENCY = {}


def _put(codes, ccy):
    for code in codes.split():
        COUNTRY_CURRENCY[code] = ccy


_put("AD AT BE BG CY DE EE ES FI FR GR HR IE IT LT LU LV MC ME MT NL PT SI SK SM VA XK", "EUR")
_put("US EC SV PR GU VI AS MP TC VG BQ MH FM PW TL", "USD")
_put("GB", "GBP"); _put("CH LI", "CHF")
_put("AU CX CC NF NR TV KI", "AUD"); _put("NZ CK NU PN TK", "NZD")
_put("DK FO GL", "DKK"); _put("NO SJ BV", "NOK"); _put("SE", "SEK"); _put("IS", "ISK")
_put("ZA", "ZAR"); _put("BJ BF CI GW ML NE SN TG", "XOF"); _put("CM CF TD CG GQ GA", "XAF")
_put("AG DM GD KN LC VC AI MS", "XCD"); _put("PF NC WF", "XPF")
_put("JP", "JPY"); _put("CN", "CNY"); _put("IN", "INR"); _put("RU", "RUB"); _put("BR", "BRL")
_put("MX", "MXN"); _put("CA", "CAD"); _put("KR", "KRW"); _put("SG", "SGD"); _put("HK", "HKD")
_put("TW", "TWD"); _put("TH", "THB"); _put("MY", "MYR"); _put("ID", "IDR"); _put("PH", "PHP")
_put("VN", "VND"); _put("TR", "TRY"); _put("PL", "PLN"); _put("CZ", "CZK"); _put("HU", "HUF")
_put("RO", "RON"); _put("UA", "UAH"); _put("IL", "ILS"); _put("AE", "AED")
_put("SA", "SAR"); _put("QA", "QAR"); _put("KW", "KWD"); _put("BH", "BHD"); _put("OM", "OMR")
_put("JO", "JOD"); _put("LB", "LBP"); _put("EG", "EGP"); _put("MA", "MAD"); _put("DZ", "DZD")
_put("TN", "TND"); _put("LY", "LYD"); _put("NG", "NGN"); _put("KE", "KES"); _put("TZ", "TZS")
_put("UG", "UGX"); _put("GH", "GHS"); _put("ET", "ETB"); _put("RW", "RWF"); _put("ZM", "ZMW")
_put("MU", "MUR"); _put("MZ", "MZN"); _put("AO", "AOA"); _put("BW", "BWP"); _put("MW", "MWK")
_put("SD", "SDG"); _put("SO", "SOS"); _put("CD", "CDF"); _put("NA", "NAD"); _put("LS", "LSL")
_put("SZ", "SZL"); _put("MG", "MGA"); _put("SC", "SCR"); _put("GM", "GMD"); _put("GN", "GNF")
_put("SL", "SLE"); _put("LR", "LRD"); _put("BI", "BIF"); _put("DJ", "DJF"); _put("ER", "ERN")
_put("AR", "ARS"); _put("CL", "CLP"); _put("CO", "COP"); _put("PE", "PEN"); _put("VE", "VES")
_put("UY", "UYU"); _put("PY", "PYG"); _put("BO", "BOB"); _put("CR", "CRC"); _put("GT", "GTQ")
_put("HN", "HNL"); _put("NI", "NIO"); _put("DO", "DOP"); _put("CU", "CUP"); _put("JM", "JMD")
_put("TT", "TTD"); _put("BB", "BBD"); _put("BS", "BSD"); _put("BZ", "BZD"); _put("HT", "HTG")
_put("GY", "GYD"); _put("SR", "SRD"); _put("PA", "PAB")
_put("PK", "PKR"); _put("BD", "BDT"); _put("LK", "LKR"); _put("NP", "NPR"); _put("AF", "AFN")
_put("IR", "IRR"); _put("IQ", "IQD"); _put("KZ", "KZT"); _put("UZ", "UZS"); _put("KG", "KGS")
_put("TJ", "TJS"); _put("TM", "TMT"); _put("AZ", "AZN"); _put("AM", "AMD"); _put("GE", "GEL")
_put("MN", "MNT"); _put("MM", "MMK"); _put("KH", "KHR"); _put("LA", "LAK"); _put("BN", "BND")
_put("MV", "MVR"); _put("BT", "BTN"); _put("SY", "SYP"); _put("YE", "YER")
_put("FJ", "FJD"); _put("PG", "PGK"); _put("SB", "SBD"); _put("VU", "VUV"); _put("WS", "WST")
_put("TO", "TOP"); _put("AL", "ALL"); _put("MK", "MKD"); _put("RS", "RSD"); _put("BA", "BAM")
_put("MD", "MDL"); _put("BY", "BYN"); _put("ZW", "ZWG"); _put("SS", "SSP")


def load_cache():
    try:
        with open(CACHE) as fh:
            data = json.load(fh)
    except Exception:
        data = {}
    data.setdefault("geo", {})
    data.setdefault("wx", {})
    data.setdefault("fx", {})
    return data


def save_cache(data):
    try:
        os.makedirs(os.path.dirname(CACHE), exist_ok=True)
        tmp = CACHE + ".tmp"
        with open(tmp, "w") as fh:
            json.dump(data, fh)
        os.replace(tmp, CACHE)
    except Exception:
        pass


def get_json(url):
    req = urllib.request.Request(url, headers={"User-Agent": "omarchy-elsewhen/1.0"})
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        return json.loads(resp.read().decode("utf-8"))


def zone_tab_coords(zone):
    """Coordinates and country for an IANA zone, from the local tz database.

    The fallback when a label cannot be geocoded. Less precise than a real
    geocode - it returns the zone's representative city, so an alias like
    Boca Raton lands on New York - but it needs no network and always
    resolves to somewhere in the right country.
    """
    try:
        with open(ZONE_TAB) as fh:
            for line in fh:
                if line.startswith("#"):
                    continue
                parts = line.rstrip("\n").split("\t")
                if len(parts) < 3 or parts[2] != zone:
                    continue
                coords = parts[1]
                # ISO 6709: +DDMM+DDDMM or +DDMMSS+DDDMMSS
                sign_positions = [i for i, ch in enumerate(coords) if ch in "+-"]
                if len(sign_positions) < 2:
                    return None
                lat_s, lon_s = coords[:sign_positions[1]], coords[sign_positions[1]:]

                def dec(text, deg_digits):
                    sign = -1 if text[0] == "-" else 1
                    body = text[1:]
                    deg = int(body[:deg_digits])
                    minutes = int(body[deg_digits:deg_digits + 2])
                    seconds = int(body[deg_digits + 2:deg_digits + 4] or 0)
                    return sign * (deg + minutes / 60 + seconds / 3600)

                return {
                    "lat": round(dec(lat_s, 2), 4),
                    "lon": round(dec(lon_s, 3), 4),
                    "country": parts[0].split(",")[0],
                }
    except Exception:
        pass
    return None


def geocode(label, zone, cache):
    key = label + "|" + zone
    hit = cache["geo"].get(key)
    if hit:
        return hit

    try:
        url = GEOCODE + "?" + urllib.parse.urlencode(
            {"name": label, "count": 10, "language": "en", "format": "json"})
        results = get_json(url).get("results") or []
        # Prefer a hit whose timezone is the row's zone - that disambiguates
        # the many cities that share a name across countries.
        best = next((r for r in results if r.get("timezone") == zone), None)
        if best is None and results:
            best = results[0]
        if best:
            found = {
                "lat": best["latitude"],
                "lon": best["longitude"],
                "country": best.get("country_code") or "",
                "exact": best.get("timezone") == zone,
            }
            cache["geo"][key] = found
            return found
    except Exception:
        pass

    fallback = zone_tab_coords(zone)
    if fallback:
        fallback["exact"] = False
        cache["geo"][key] = fallback
        return fallback
    return None


def fetch_rates(cache):
    fx = cache.get("fx") or {}
    if fx.get("rates") and time.time() - fx.get("at", 0) < FX_TTL:
        return fx["rates"], False
    try:
        payload = get_json(FX)
        if payload.get("result") == "success" and payload.get("rates"):
            cache["fx"] = {"rates": payload["rates"], "at": time.time()}
            return payload["rates"], False
    except Exception:
        pass
    return fx.get("rates") or {}, True


def fetch_temps(points, cache):
    """One batched call for every distinct coordinate that needs refreshing."""
    now = time.time()
    fresh, stale_keys = {}, []
    for key, (lat, lon) in points.items():
        hit = cache["wx"].get(key)
        if hit and now - hit.get("at", 0) < WX_TTL:
            fresh[key] = hit
        else:
            stale_keys.append(key)

    if stale_keys:
        try:
            lats = ",".join(str(points[k][0]) for k in stale_keys)
            lons = ",".join(str(points[k][1]) for k in stale_keys)
            url = FORECAST + "?" + urllib.parse.urlencode({
                "latitude": lats, "longitude": lons,
                "current": "temperature_2m,weather_code",
                "temperature_unit": "celsius",
            })
            payload = get_json(url)
            if isinstance(payload, dict):
                payload = [payload]
            for key, entry in zip(stale_keys, payload):
                cur = entry.get("current") or {}
                temp = cur.get("temperature_2m")
                if temp is not None:
                    # The WMO code travels with the temperature; both come
                    # from the same reading, so they cannot disagree.
                    row = {"c": temp, "at": now}
                    code = cur.get("weather_code")
                    if code is not None:
                        row["w"] = code
                    fresh[key] = row
                    cache["wx"][key] = row
        except Exception:
            pass

    # Anything still missing falls back to whatever the cache last saw.
    for key in stale_keys:
        if key not in fresh and key in cache["wx"]:
            fresh[key] = cache["wx"][key]
    return fresh


def main():
    # Rows arrive as argv[1] when the caller finds that easier than a pipe
    # (Quickshell's Process does), or on stdin otherwise.
    try:
        args = [a for a in sys.argv[1:] if not a.startswith("--")]
        rows = json.loads(args[0]) if args else json.load(sys.stdin)
    except Exception:
        rows = []

    cache = load_cache()
    out = {}
    points = {}

    for row in rows:
        label, zone = str(row.get("label", "")), str(row.get("id", ""))
        if not zone:
            continue
        key = label + "|" + zone
        place = geocode(label, zone, cache)
        entry = {}
        if place:
            points[key] = (place["lat"], place["lon"])
            # Coordinates travel with the row so the globe can place a tracked
            # city even when it is not one of the globe's own built-ins.
            entry["lat"] = place["lat"]
            entry["lon"] = place["lon"]
            ccy = COUNTRY_CURRENCY.get((place.get("country") or "").upper())
            if ccy:
                entry["ccy"] = ccy
        out[key] = entry

    # The panel passes --no-fx when it is not drawing currency; there is no
    # point spending a request on rates nobody will see.
    if "--no-fx" in sys.argv:
        rates, fx_stale = {}, False
    else:
        rates, fx_stale = fetch_rates(cache)
    temps = fetch_temps(points, cache)

    for key, entry in out.items():
        if key in temps:
            wx = temps[key]
            if wx.get("c") is not None:
                entry["c"] = round(wx["c"], 1)
            # Entries cached before weather codes were fetched have no "w";
            # the row simply renders without an icon until the next refresh.
            if wx.get("w") is not None:
                entry["w"] = int(wx["w"])
        ccy = entry.get("ccy")
        if ccy and ccy != "USD":
            rate = rates.get(ccy)
            # rates are units-per-USD; invert to price one unit in dollars
            if rate:
                entry["usd"] = 1.0 / rate
        elif ccy == "USD":
            entry.pop("ccy", None)  # nothing to say about dollars in dollars

    save_cache(cache)
    json.dump({"cities": out, "fxStale": fx_stale}, sys.stdout)


if __name__ == "__main__":
    main()
