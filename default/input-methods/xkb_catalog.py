"""Installed XKB choices and validation for the shared keyboard setup picker."""

import ctypes as C
from pathlib import Path
import re
import xml.etree.ElementTree as ET


def catalog(registry=Path("/usr/share/X11/xkb/rules/evdev.xml")):
  result = {}
  for source in (registry, registry.with_name(registry.stem + ".extras.xml")):
    if source != registry and not source.exists():
      continue
    for layout in ET.parse(source).findall("./layoutList/layout"):
      name = layout.findtext("configItem/name")
      description = layout.findtext("configItem/description")
      result.setdefault(name, description)
      for variant in layout.findall("variantList/variant"):
        key = name + ":" + variant.findtext("configItem/name")
        result.setdefault(key, variant.findtext("configItem/description"))
  return result


def latin_leading(layouts, variants):
  """Compile the selection and check for Latin letters without AltGr or Shift."""
  lib = C.CDLL("libxkbcommon.so.0")
  class Names(C.Structure):
    _fields_ = [(key, C.c_char_p) for key in ("rules", "model", "layout", "variant", "options")]
  functions = {
    "xkb_context_new": (C.c_void_p, [C.c_int]),
    "xkb_context_unref": (None, [C.c_void_p]),
    "xkb_keymap_new_from_names": (C.c_void_p, [C.c_void_p, C.POINTER(Names), C.c_int]),
    "xkb_keymap_unref": (None, [C.c_void_p]),
    "xkb_keymap_min_keycode": (C.c_uint32, [C.c_void_p]),
    "xkb_keymap_max_keycode": (C.c_uint32, [C.c_void_p]),
    "xkb_keymap_key_get_syms_by_level": (C.c_int, [C.c_void_p, C.c_uint32, C.c_uint32, C.c_uint32, C.POINTER(C.POINTER(C.c_uint32))]),
    "xkb_keysym_to_utf32": (C.c_uint32, [C.c_uint32]),
  }
  for name, (result, arguments) in functions.items():
    function = getattr(lib, name)
    function.restype, function.argtypes = result, arguments
  context = lib.xkb_context_new(0)
  if not context:
    raise ValueError("The keyboard layout could not be validated")
  keymap = None
  try:
    names = Names(b"evdev", b"pc105", layouts.encode(), variants.encode(), b"")
    keymap = lib.xkb_keymap_new_from_names(context, C.byref(names), 0)
    if not keymap:
      raise ValueError("The selected layouts and variants could not be compiled")
    letters = set()
    symbols = C.POINTER(C.c_uint32)()
    for key in range(lib.xkb_keymap_min_keycode(keymap), lib.xkb_keymap_max_keycode(keymap) + 1):
      count = lib.xkb_keymap_key_get_syms_by_level(keymap, key, 0, 0, C.byref(symbols))
      letters.update(chr(lib.xkb_keysym_to_utf32(symbols[index])).lower() for index in range(count))
    return set("abcdefghijklmnopqrstuvwxyz") <= letters
  finally:
    if keymap:
      lib.xkb_keymap_unref(keymap)
    lib.xkb_context_unref(context)


def keyboard_values(selected, non_latin):
  if (not isinstance(selected, list) or not 1 <= len(selected) <= 4
      or any(not isinstance(value, str) or not re.fullmatch(r"[A-Za-z0-9_+-]+(?::[A-Za-z0-9_+-]+)?", value) for value in selected)
      or len(set(selected)) != len(selected)):
    raise ValueError("Select between one and four different keyboard layouts")
  parts = [value.split(":", 1) for value in selected]
  def values():
    return ",".join(part[0] for part in parts), ",".join(part[1] if len(part) > 1 else "" for part in parts)
  # Keep the installer's protection, also covering non-Latin variants of
  # otherwise Latin layouts now exposed by the complete XKB catalogue.
  latin = latin_leading(*values())
  if parts[0][0] in non_latin or not latin:
    parts = [["us"]] + [part for part in parts if part != ["us"]]
    if len(parts) > 4:
      raise ValueError("Keep one of the four slots for US, which is required for desktop shortcuts")
    latin_leading(*values())
  return values()
