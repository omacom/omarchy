"""Coordinates and current weather for the world clock's cities.

argv[1] is a JSON list of {"label", "id"} rows. stdout is
{"cities": {"label|id": {"lat", "lon", "c", "w"}}}, any field omitted when unknown.

Geocodes are cached forever and weather for 20 minutes. Network failures fall
back to the cache, then to omitting the field; they are never fatal.
"""

import json
import os
import sys
import time
import urllib.parse
import urllib.request

CACHE = os.path.join(
  os.environ.get("XDG_CACHE_HOME") or os.path.expanduser("~/.cache"),
  "omarchy", "elsewhen.json",
)
WX_TTL = 20 * 60
TIMEOUT = 8

GEOCODE = "https://geocoding-api.open-meteo.com/v1/search"
FORECAST = "https://api.open-meteo.com/v1/forecast"

ZONE_TAB = "/usr/share/zoneinfo/zone1970.tab"


def load_cache():
  try:
    with open(CACHE) as fh:
      data = json.load(fh)
  except Exception:
    data = {}
  data.setdefault("geo", {})
  data.setdefault("wx", {})
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
  """The zone's representative city from the local tz database; the offline fallback."""
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

        return {"lat": round(dec(lat_s, 2), 4), "lon": round(dec(lon_s, 3), 4)}
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
    # A hit in the row's own zone disambiguates cities that share a name.
    best = next((r for r in results if r.get("timezone") == zone), None)
    if best is None and results:
      best = results[0]
    if best:
      found = {
        "lat": best["latitude"],
        "lon": best["longitude"],
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
          row = {"c": temp, "at": now}
          code = cur.get("weather_code")
          if code is not None:
            row["w"] = code
          fresh[key] = row
          cache["wx"][key] = row
    except Exception:
      pass

  for key in stale_keys:
    if key not in fresh and key in cache["wx"]:
      fresh[key] = cache["wx"][key]
  return fresh


def main():
  try:
    rows = json.loads(sys.argv[1])
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
      entry["lat"] = place["lat"]
      entry["lon"] = place["lon"]
    out[key] = entry

  temps = fetch_temps(points, cache)

  for key, entry in out.items():
    wx = temps.get(key)
    if not wx:
      continue
    if wx.get("c") is not None:
      entry["c"] = round(wx["c"], 1)
    if wx.get("w") is not None:
      entry["w"] = int(wx["w"])

  save_cache(cache)
  json.dump({"cities": out}, sys.stdout)


if __name__ == "__main__":
  main()
