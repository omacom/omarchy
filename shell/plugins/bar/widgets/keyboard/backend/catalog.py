"""Installed XKB registry, without locale-based language guesses."""
from pathlib import Path
import hashlib
import json
import os
import tempfile
import xml.etree.ElementTree as ET

from .deferred_runtime import UnsafeState, read_path


class SettingsError(Exception):
  pass


SHORTCUTS = {
  "both-alt": ("Both Alt keys", "grp:alt_altgr_toggle"),
  "alt-shift": ("Alt + Shift", "grp:alt_shift_toggle"),
  "bar": ("The bar only", ""),
}


def pair_id(layout, variant=""):
  return layout + "/" + variant


class Catalog:
  CACHE_SCHEMA = 1
  MAX_CACHE_BYTES = 2 * 1024 * 1024

  def __init__(self, registry=Path("/usr/share/X11/xkb/rules/evdev.xml"), cache=None):
    registry = Path(registry)
    extra = registry.with_name(registry.stem + ".extras.xml")
    sources = self._source_hashes(registry, extra)
    if cache is None:
      base = Path(os.environ.get("XDG_CACHE_HOME") or Path.home() / ".cache")
      cache = base / "omarchy/keyboard-layouts/catalog-v1.json"
    self.cache = Path(cache) if cache is not False else None
    if self.cache and self._load_cache(sources):
      return

    root = ET.parse(registry).getroot()
    if extra.exists():
      for layout in ET.parse(extra).getroot().findall("./layoutList/layout"):
        name = layout.findtext("configItem/name")
        existing = next((l for l in root.findall("./layoutList/layout") if l.findtext("configItem/name") == name), None)
        if existing is None:
          root.find("layoutList").append(layout)
        else:
          variants = existing.find("variantList")
          if variants is None:
            variants = ET.SubElement(existing, "variantList")
          known = {v.findtext("configItem/name") for v in variants}
          for variant in layout.findall("./variantList/variant"):
            if variant.findtext("configItem/name") not in known:
              variants.append(variant)
    self.layouts = []
    self.pairs = {}
    self.groups = set()
    for group in root.findall("./optionList/group"):
      if group.findtext("configItem/name") == "grp":
        self.groups.update(o.findtext("configItem/name") for o in group.findall("option"))
    for layout in root.findall("./layoutList/layout"):
      info = layout.find("configItem")
      name = info.findtext("name")
      description = info.findtext("description")
      languages = [n.text for n in info.findall("languageList/iso639Id")]
      country = [n.text for n in info.findall("countryList/iso3166Id")]
      variants = [{"id": "", "label": "Standard"}]
      variants += [{"id": v.findtext("configItem/name"),
             "label": v.findtext("configItem/description")}
            for v in layout.findall("./variantList/variant")]
      row = {"id": name, "label": description,
         "code": (info.findtext("shortDescription") or name).upper()[:3],
         "country": country[0].lower() if len(country) == 1 else "",
         "search": " ".join([name, description] + languages + country).lower(),
         "variants": variants}
      # Registry country tags can be absent. Only explicit country layout IDs
      # receive a flag; a language such as Arabic is never assigned a nation.
      if not row["country"] and len(name) == 2 and name in {
          "us", "gb", "pl", "de", "fr", "es", "ua", "jp", "no", "se", "fi", "it"}:
        row["country"] = name
      for variant in variants:
        self.pairs[pair_id(name, variant["id"])] = {
          "id": pair_id(name, variant["id"]), "layout": name,
          "variant": variant["id"], "label": description,
          "variantLabel": variant["label"], "code": row["code"],
          "country": row["country"]}
      self.layouts.append(row)
    if self.cache:
      self._write_cache(sources)

  @staticmethod
  def _source_hashes(*paths):
    result = {}
    for path in paths:
      if path.exists():
        result[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    return result

  def _load_cache(self, sources):
    try:
      data = read_path(self.cache, self.MAX_CACHE_BYTES, missing_ok=True)
      if data is None:
        return False
      value = json.loads(data)
      if value.get("schema") != self.CACHE_SCHEMA or value.get("sources") != sources:
        return False
      layouts, pairs, groups = value["layouts"], value["pairs"], value["groups"]
      if not isinstance(layouts, list) or not isinstance(pairs, dict) or not isinstance(groups, list):
        return False
      self.layouts, self.pairs, self.groups = layouts, pairs, set(groups)
      return True
    except (OSError, UnsafeState, ValueError, UnicodeError, KeyError, TypeError):
      return False

  def _write_cache(self, sources):
    value = {"schema": self.CACHE_SCHEMA, "sources": sources, "layouts": self.layouts,
        "pairs": self.pairs, "groups": sorted(self.groups)}
    try:
      self.cache.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
      fd, temporary = tempfile.mkstemp(prefix=".catalog-", dir=self.cache.parent)
      try:
        with os.fdopen(fd, "w") as stream:
          json.dump(value, stream, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
          stream.flush()
          os.fsync(stream.fileno())
        os.replace(temporary, self.cache)
        directory = os.open(self.cache.parent, os.O_DIRECTORY)
        try:
          os.fsync(directory)
        finally:
          os.close(directory)
      finally:
        if os.path.exists(temporary):
          os.unlink(temporary)
    except OSError:
      # A cache must never make the installed registry unavailable.
      return

  def resolve(self, pairs):
    if not isinstance(pairs, list) or not 1 <= len(pairs) <= 4:
      raise SettingsError("Choose between one and four layouts.")
    if not all(isinstance(p, str) for p in pairs):
      raise SettingsError("Invalid layout selection.")
    if len(set(pairs)) != len(pairs):
      raise SettingsError("That exact layout and variant is already selected.")
    if any(p not in self.pairs for p in pairs):
      raise SettingsError("A selected layout or variant is not in the installed XKB catalog.")
    return [self.pairs[p] for p in pairs]

  def current_rows(self, keyboard):
    layouts = keyboard.get("layout", "").split(",")
    raw = keyboard.get("variant", "")
    variants = raw.split(",") if raw else [""] * len(layouts)
    if len(variants) == 1 and len(layouts) > 1:
      variants *= len(layouts)
    if len(variants) != len(layouts):
      raise SettingsError("The current layout and variant lists do not align.")
    rows = []
    for layout, variant in zip(layouts, variants):
      key = pair_id(layout, variant)
      rows.append(self.pairs.get(key, {"id": key, "layout": layout,
            "variant": variant, "label": layout, "variantLabel": variant or "Standard",
            "code": layout.upper()[:3], "country": "", "custom": True}))
    return rows

  def shortcut(self, options):
    group = [o for o in options.split(",") if o in self.groups or o.startswith("grp:")]
    if group == ["grp:alts_toggle"]:
      return "both-alt"
    for key, (_, option) in SHORTCUTS.items():
      if group == ([option] if option else []):
        return key
    return "custom"

  def options(self, original, intent):
    if intent == "custom":
      # Preserve unknown custom switching settings; never guess their semantics.
      return original
    if intent not in SHORTCUTS:
      raise SettingsError("Unknown switching shortcut.")
    tokens = [o for o in original.split(",") if o]
    if any(o.startswith("grp:") and o not in self.groups for o in tokens):
      raise SettingsError("A custom switching option needs manual review before it can be replaced.")
    kept = [o for o in tokens if o not in self.groups]
    option = SHORTCUTS[intent][1]
    return ",".join(kept + ([option] if option else []))
