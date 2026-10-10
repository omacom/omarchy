"""Parse generated desktop fields with GLib, then execute the terminal payload.

This checks argv construction without opening a graphical terminal. Field-code
handling here is limited to the literal %% emitted by the installer.
"""
import ctypes as c
import ctypes.util
import subprocess
import shlex
import sys

library = ctypes.util.find_library("glib-2.0")
if not library:
    raise SystemExit("GLib is required for the desktop parser regression")
g = c.CDLL(library)
g.g_key_file_new.restype = c.c_void_p
g.g_key_file_load_from_file.argtypes = [c.c_void_p, c.c_char_p, c.c_int, c.c_void_p]
g.g_key_file_get_string.argtypes = [c.c_void_p, c.c_char_p, c.c_char_p, c.c_void_p]
g.g_key_file_get_string.restype = c.c_char_p
g.g_shell_parse_argv.argtypes = [c.c_char_p, c.POINTER(c.c_int), c.POINTER(c.POINTER(c.c_char_p)), c.c_void_p]
g.g_strfreev.argtypes = [c.POINTER(c.c_char_p)]
g.g_key_file_free.argtypes = [c.c_void_p]
key = g.g_key_file_new()
assert g.g_key_file_load_from_file(key, sys.argv[1].encode(), 0, None)
command = g.g_key_file_get_string(key, b"Desktop Entry", b"Exec", None)
assert command is not None
count, values = c.c_int(), c.POINTER(c.c_char_p)()
assert g.g_shell_parse_argv(command, c.byref(count), c.byref(values), None)
args = [values[i].decode().replace("%%", "%") for i in range(count.value)]
g.g_strfreev(values)
g.g_key_file_free(key)
assert args[:3] == ["xdg-terminal-exec", "--app-id=TUI.float", "-e"], args
assert args[3:] == shlex.split(sys.argv[2]), args
result = subprocess.run(args[3:], check=True, capture_output=True, text=True)
assert result.stdout == sys.argv[3], repr(result.stdout)
