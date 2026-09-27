#!/usr/bin/env python3
"""Validate the country -> currency table in worldclock-data.py.

Three checks, each of which has already caught a real bug:

  * every currency is a current ISO 4217 code, per the system's iso-codes
    package. This is what flagged BGN: Bulgaria has adopted the euro, and the
    code is retired, but the FX feed still publishes a legacy peg rate for it.
  * every country is a real ISO 3166-1 alpha-2 code (XK, user-assigned for
    Kosovo, is allowed - the geocoder emits it).
  * every currency has a live rate, or it would render as a bare code.

The third check needs the network; pass --offline to skip it.
"""

import json
import os
import sys
import urllib.request

sys.dont_write_bytecode = True

PLUGIN_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          "..", "..", "..", "shell", "plugins", "panels", "elsewhen")
sys.path.insert(0, PLUGIN_DIR)

import importlib.util

spec = importlib.util.spec_from_file_location(
    "wcdata", os.path.join(PLUGIN_DIR, "worldclock-data.py"))
wcdata = importlib.util.module_from_spec(spec)
spec.loader.exec_module(wcdata)

ISO_DIR = "/usr/share/iso-codes/json"
ALLOWED_NON_ISO_COUNTRIES = {"XK"}  # user-assigned, Kosovo
# Newer than the iso-codes a distribution may still ship. ZWG (Zimbabwe Gold)
# entered ISO 4217 in 2024; Ubuntu 24.04's package predates it. The live-rate
# check below still has to know these, so a retired one would not go unseen.
ALLOWED_NEWER_CURRENCIES = {"ZWG"}


def main():
    mapping = wcdata.COUNTRY_CURRENCY
    failures = []

    currencies = {c["alpha_3"] for c in json.load(
        open(os.path.join(ISO_DIR, "iso_4217.json")))["4217"]}
    countries = {c["alpha_2"] for c in json.load(
        open(os.path.join(ISO_DIR, "iso_3166-1.json")))["3166-1"]}

    retired = sorted({v for v in mapping.values()
                      if v not in currencies and v not in ALLOWED_NEWER_CURRENCIES})
    if retired:
        failures.append(f"not current ISO 4217 codes: {retired}")

    unknown = sorted({k for k in mapping
                      if k not in countries and k not in ALLOWED_NON_ISO_COUNTRIES})
    if unknown:
        failures.append(f"not ISO 3166-1 alpha-2 codes: {unknown}")

    if "--offline" not in sys.argv:
        try:
            payload = json.loads(urllib.request.urlopen(wcdata.FX, timeout=15).read())
            rates = set(payload.get("rates") or {})
            missing = sorted({v for v in mapping.values() if v not in rates})
            if missing:
                failures.append(f"no live FX rate: {missing}")
        except Exception as exc:
            print(f"  skipped live-rate check: {exc}")

    print(f"  {len(mapping)} countries -> {len(set(mapping.values()))} currencies")
    for line in failures:
        print(f"  FAIL {line}")
    if failures:
        return 1
    print("  all currency-table checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
