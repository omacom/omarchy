"""Offline validation using the installed libxkbcommon, never a virtual keyboard."""
import ctypes as C
from .catalog import SettingsError


class Names(C.Structure):
  _fields_ = [(name, C.c_char_p) for name in ("rules", "model", "layout", "variant", "options")]


class Keymap:
  def __init__(self, config):
    self.lib = C.CDLL("libxkbcommon.so.0")
    declarations = {
      "xkb_context_new": (C.c_void_p, [C.c_int]),
      "xkb_context_unref": (None, [C.c_void_p]),
      "xkb_keymap_new_from_names": (C.c_void_p, [C.c_void_p, C.POINTER(Names), C.c_int]),
      "xkb_keymap_unref": (None, [C.c_void_p]),
      "xkb_keymap_num_layouts": (C.c_uint32, [C.c_void_p]),
      "xkb_keymap_key_by_name": (C.c_uint32, [C.c_void_p, C.c_char_p]),
      "xkb_keymap_min_keycode": (C.c_uint32, [C.c_void_p]),
      "xkb_keymap_max_keycode": (C.c_uint32, [C.c_void_p]),
      "xkb_state_new": (C.c_void_p, [C.c_void_p]),
      "xkb_state_unref": (None, [C.c_void_p]),
      "xkb_state_update_key": (C.c_int, [C.c_void_p, C.c_uint32, C.c_int]),
      "xkb_state_update_latched_locked": (C.c_int, [C.c_void_p, C.c_uint32, C.c_uint32, C.c_bool, C.c_int32,
                            C.c_uint32, C.c_uint32, C.c_bool, C.c_int32]),
      "xkb_state_key_get_one_sym": (C.c_uint32, [C.c_void_p, C.c_uint32]),
      "xkb_state_serialize_layout": (C.c_uint32, [C.c_void_p, C.c_int]),
      "xkb_keysym_to_utf32": (C.c_uint32, [C.c_uint32]),
    }
    for name, (result, args) in declarations.items():
      fn = getattr(self.lib, name)
      fn.restype, fn.argtypes = result, args
    # NO_ENVIRONMENT_NAMES: unset fields must not import XKB_DEFAULT_* from the shell.
    self.context = self.lib.xkb_context_new(2)
    values = [(config.get(name) or ("evdev" if name == "rules" else "pc105" if name == "model" else "")).encode()
         for name, _ in Names._fields_]
    self.map = self.lib.xkb_keymap_new_from_names(self.context, C.byref(Names(*values)), 0)
    if not self.map:
      self.lib.xkb_context_unref(self.context)
      self.context = None
      raise SettingsError("XKB could not compile this keyboard setup. Nothing was applied.")
    self.groups = self.lib.xkb_keymap_num_layouts(self.map)

  def close(self):
    if self.map:
      self.lib.xkb_keymap_unref(self.map)
      self.map = None
    if self.context:
      self.lib.xkb_context_unref(self.context)
      self.context = None

  def __enter__(self):
    return self

  def __exit__(self, *_):
    self.close()

  def key(self, name):
    return self.lib.xkb_keymap_key_by_name(self.map, name.encode())

  def state(self, group=0):
    state = self.lib.xkb_state_new(self.map)
    if not state:
      raise SettingsError("Could not create an XKB validation state.")
    self.lib.xkb_state_update_latched_locked(state, 0, 0, False, 0, 0, 0, True, group)
    return state

  def altgr(self, group):
    state = self.state(group)
    try:
      return self.lib.xkb_state_key_get_one_sym(state, self.key("RALT")) in (0xfe03, 0xfe04, 0xfe05)
    finally:
      self.lib.xkb_state_unref(state)

  def printable(self, group, modifiers=()):
    state = self.state(group)
    try:
      for name in modifiers:
        key = self.key(name)
        if key != 0xffffffff:
          self.lib.xkb_state_update_key(state, key, 1)
      output = {}
      for key in range(self.lib.xkb_keymap_min_keycode(self.map), self.lib.xkb_keymap_max_keycode(self.map) + 1):
        symbol = self.lib.xkb_state_key_get_one_sym(state, key)
        char = self.lib.xkb_keysym_to_utf32(symbol)
        # Preserve printable characters and dead-key symbols, not group actions.
        if (char and chr(char).isprintable()) or 0xfe50 <= symbol <= 0xfe93:
          output[key] = symbol
      return output
    finally:
      self.lib.xkb_state_unref(state)

  def chord_group(self, group, modifiers):
    state = self.state(group)
    try:
      for name in modifiers:
        self.lib.xkb_state_update_key(state, self.key(name), 1)
      for name in reversed(modifiers):
        self.lib.xkb_state_update_key(state, self.key(name), 0)
      return self.lib.xkb_state_serialize_layout(state, 1 << 7)
    finally:
      self.lib.xkb_state_unref(state)


def validate(config, catalog):
  baseline = dict(config)
  baseline["options"] = ",".join(o for o in config.get("options", "").split(",") if o and o not in catalog.groups)
  with Keymap(baseline) as before, Keymap(config) as after:
    expected = len(config["layout"].split(","))
    if before.groups != expected or after.groups != expected:
      raise SettingsError("XKB did not produce every selected layout. Nothing was applied.")
    for group in range(expected):
      modifiers_to_check = [(), ("LFSH",)]
      # Plain US has ordinary Alt, so enabling AltGr can expose additional
      # levels on its ISO key. Compare AltGr levels only where they exist.
      if before.altgr(group):
        modifiers_to_check += [("RALT",), ("RALT", "LFSH")]
      for modifiers in modifiers_to_check:
        old, new = before.printable(group, modifiers), after.printable(group, modifiers)
        missing = [key for key, symbol in old.items() if new.get(key) != symbol]
        if missing:
          raise SettingsError("This shortcut conflicts with characters in the selected layouts. Choose another shortcut.")
    options = config.get("options", "").split(",")
    orders = [("LALT", "RALT"), ("RALT", "LALT")] if "grp:alt_altgr_toggle" in options else (
      [("LALT", "LFSH"), ("LFSH", "LALT")] if "grp:alt_shift_toggle" in options else [])
    if orders and expected > 1:
      for group in range(expected):
        for order in orders:
          if after.chord_group(group, order) not in {(group + 1) % expected, (group - 1) % expected}:
            raise SettingsError("This shortcut did not switch reliably in this keymap. Choose another shortcut.")
  return {"compiled": True, "characterChecks": "base, Shift, AltGr, Shift+AltGr",
      "physicalTypingVerified": False}
