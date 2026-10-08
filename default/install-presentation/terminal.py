"""A bounded libvterm screen. Child control sequences never reach the host UI."""
import ctypes as C
import os


class Pos(C.Structure):
  _fields_ = [("row", C.c_int), ("col", C.c_int)]


class Cell(C.Structure):
  # libvterm 0.x's public VTermScreenCell ABI. The attrs are unsigned bitfields.
  _fields_ = [("chars", C.c_uint32 * 6), ("width", C.c_char),
              ("attrs", C.c_uint), ("fg", C.c_ubyte * 4), ("bg", C.c_ubyte * 4)]


class Terminal:
  def __init__(self, rows, cols):
    self.lib = C.CDLL("libvterm.so.0")
    signatures = {
      "vterm_new": (C.c_void_p, [C.c_int, C.c_int]),
      "vterm_free": (None, [C.c_void_p]),
      "vterm_set_utf8": (None, [C.c_void_p, C.c_int]),
      "vterm_set_size": (None, [C.c_void_p, C.c_int, C.c_int]),
      "vterm_obtain_screen": (C.c_void_p, [C.c_void_p]),
      "vterm_obtain_state": (C.c_void_p, [C.c_void_p]),
      "vterm_screen_enable_altscreen": (None, [C.c_void_p, C.c_int]),
      "vterm_screen_reset": (None, [C.c_void_p, C.c_int]),
      "vterm_screen_flush_damage": (None, [C.c_void_p]),
      "vterm_screen_get_cell": (C.c_int, [C.c_void_p, Pos, C.POINTER(Cell)]),
      "vterm_state_get_cursorpos": (None, [C.c_void_p, C.POINTER(Pos)]),
      "vterm_screen_set_callbacks": (None, [C.c_void_p, C.c_void_p, C.c_void_p]),
      "vterm_input_write": (C.c_size_t, [C.c_void_p, C.c_char_p, C.c_size_t]),
      "vterm_output_read": (C.c_size_t, [C.c_void_p, C.c_void_p, C.c_size_t]),
    }
    for name, (result, args) in signatures.items():
      function = getattr(self.lib, name)
      function.restype, function.argtypes = result, args
    self.rows, self.cols = rows, cols
    self.vt = self.lib.vterm_new(rows, cols)
    if not self.vt:
      raise MemoryError("Could not create embedded terminal")
    self.lib.vterm_set_utf8(self.vt, 1)
    self.screen = self.lib.vterm_obtain_screen(self.vt)
    self.state = self.lib.vterm_obtain_state(self.vt)
    self.visible = True
    self.alternate = False

    @C.CFUNCTYPE(C.c_int, C.c_int, C.c_void_p, C.c_void_p)
    def property_changed(prop, value, _):
      if prop == 1:
        self.visible = bool(C.cast(value, C.POINTER(C.c_int))[0])
      elif prop == 3:
        self.alternate = bool(C.cast(value, C.POINTER(C.c_int))[0])
      return 1

    # Keep callback and table alive for the screen's lifetime.
    self.property_changed = property_changed
    self.callbacks = (C.c_void_p * 9)()
    self.callbacks[3] = C.cast(property_changed, C.c_void_p)
    self.lib.vterm_screen_set_callbacks(self.screen, self.callbacks, None)
    self.lib.vterm_screen_enable_altscreen(self.screen, 1)
    self.lib.vterm_screen_reset(self.screen, 1)

  def resize(self, rows, cols):
    if (rows, cols) != (self.rows, self.cols):
      self.rows, self.cols = rows, cols
      self.lib.vterm_set_size(self.vt, rows, cols)

  def feed(self, data):
    self.lib.vterm_input_write(self.vt, data, len(data))
    self.lib.vterm_screen_flush_damage(self.screen)
    # Cursor-position and device replies go to the child, not the host tty.
    result = bytearray()
    buffer = C.create_string_buffer(4096)
    while count := self.lib.vterm_output_read(self.vt, buffer, len(buffer)):
      result.extend(buffer.raw[:count])
    return bytes(result)

  def cursor(self):
    pos = Pos()
    self.lib.vterm_state_get_cursorpos(self.state, C.byref(pos))
    return min(self.rows - 1, max(0, pos.row)), min(self.cols - 1, max(0, pos.col))

  def lines(self):
    color = "NO_COLOR" not in os.environ
    result = []
    for row in range(self.rows):
      out, last_style = [], None
      for col in range(self.cols):
        cell = Cell()
        self.lib.vterm_screen_get_cell(self.screen, Pos(row, col), C.byref(cell))
        if cell.chars[0] == 0xFFFFFFFF:
          continue
        style = [0]
        for mask, code in ((1, 1), (6, 4), (8, 3), (32, 7), (64, 8), (128, 9)):
          if cell.attrs & mask:
            style.append(code)
        if color:
          for value, base in ((cell.fg, 38), (cell.bg, 48)):
            if value[0] & 6:
              continue
            style.extend([base, 5, value[1]] if value[0] & 1 else [base, 2, *value[1:]])
        if style != last_style:
          out.append("\033[" + ";".join(map(str, style)) + "m")
          last_style = style
        text = "".join(chr(c) for c in cell.chars if 32 <= c <= 0x10FFFF and not 0xD800 <= c <= 0xDFFF)
        out.append(text or " ")
      result.append("".join(out) + "\033[0m")
    return result

  def close(self):
    if self.vt:
      self.lib.vterm_free(self.vt)
      self.vt = None
