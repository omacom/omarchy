#!/usr/bin/python3
# Rex worker for the engines Python can reach: Python's re, the third-party
# regex module, PCRE2 (libpcre2-8 through ctypes), and POSIX regcomp/regexec
# (glibc through ctypes).
#
# Protocol: one JSON object per line on stdin, replies one per line on stdout.
#   {"op": "match", "id", "flavor", "pattern", "flags", "text"?, "textId",
#    "all", "limit"}
#   {"op": "info"}
# A match reply carries flat [start, end, ...] offsets in UTF-16 code units,
# stride numbers per match. Long searches reply in slices with "done": false;
# a newer request arriving between slices abandons the older one.

import ctypes
import ctypes.util
import json
import os
import re
import select
import sys
import time

SLICE_SECONDS = 0.05
MATCH_LIMIT = 10_000_000


def send(obj):
    sys.stdout.write(json.dumps(obj, separators=(",", ":"), ensure_ascii=False) + "\n")
    sys.stdout.flush()


class Lines:
    """Line reader over the raw stdin fd, so select() tells the truth about
    whether another request is waiting."""

    def __init__(self):
        self.fd = sys.stdin.fileno()
        self.buffer = b""

    def waiting(self):
        if b"\n" in self.buffer:
            return True
        ready, _, _ = select.select([self.fd], [], [], 0)
        return bool(ready)

    def read(self):
        while b"\n" not in self.buffer:
            chunk = os.read(self.fd, 1 << 20)
            if not chunk:
                return None
            self.buffer += chunk
        line, _, self.buffer = self.buffer.partition(b"\n")
        return line.decode("utf-8", "surrogatepass")


# ---- offsets ----------------------------------------------------------------


class CodePoints:
    """Code point offsets to UTF-16: astral characters take two units."""

    def __init__(self, text):
        self.astral = [i for i, c in enumerate(text) if ord(c) > 0xFFFF] if not text.isascii() else []

    def utf16(self, cp):
        if cp < 0 or not self.astral:
            return cp
        lo, hi = 0, len(self.astral)
        while lo < hi:
            mid = (lo + hi) // 2
            if self.astral[mid] < cp:
                lo = mid + 1
            else:
                hi = mid
        return cp + lo


class Bytes:
    """UTF-8 byte offsets to UTF-16. Offsets mostly move forward, so the
    conversion decodes only the bytes between the last offset and this one."""

    def __init__(self, data):
        self.data = data
        self.ascii = data.isascii()
        self.at_byte = 0
        self.at_unit = 0

    def units(self, start, end):
        piece = self.data[start:end].decode("utf-8", "ignore")
        return len(piece.encode("utf-16-le", "surrogatepass")) // 2

    def utf16(self, b):
        if b < 0 or self.ascii:
            return b
        if b < self.at_byte:
            self.at_byte, self.at_unit = 0, 0
        self.at_unit += self.units(self.at_byte, b)
        self.at_byte = b
        return self.at_unit

    def relative(self, base_byte, base_unit, b):
        """b converted from a known nearby point, without moving the cursor."""
        if b < 0 or self.ascii:
            return b
        if b >= base_byte:
            return base_unit + self.units(base_byte, b)
        return base_unit - self.units(b, base_byte)


# ---- Python re / regex --------------------------------------------------------


def python_job(module, request, text):
    flags = 0
    names = {"i": "IGNORECASE", "m": "MULTILINE", "s": "DOTALL", "x": "VERBOSE", "a": "ASCII", "r": "REVERSE", "b": "BESTMATCH"}
    for f in request.get("flags", []):
        if f == "V1":
            flags |= module.VERSION1
        elif f in names and hasattr(module, names[f]):
            flags |= getattr(module, names[f])
    try:
        compiled = module.compile(request["pattern"], flags)
    except Exception as e:  # re.error, regex.error, OverflowError, ...
        yield {"ok": False, "error": str(e), "offset": getattr(e, "pos", None)}
        return
    groups = compiled.groups
    stride = (groups + 1) * 2
    convert = CodePoints(text)
    out = []
    count = 0
    limit = request.get("limit", 100000)
    started = time.monotonic()
    slice_start = started
    for m in compiled.finditer(text):
        for g in range(groups + 1):
            s, e = m.span(g)
            out.append(convert.utf16(s))
            out.append(convert.utf16(e))
        count += 1
        if count >= limit or not request.get("all", True):
            break
        if time.monotonic() - slice_start > SLICE_SECONDS:
            yield {"ok": True, "done": False, "matches": out, "stride": stride, "elapsed": elapsed(started)}
            out = []
            slice_start = time.monotonic()
    yield {"ok": True, "done": True, "matches": out, "stride": stride, "elapsed": elapsed(started), "names": dict(compiled.groupindex)}


def elapsed(started):
    return round((time.monotonic() - started) * 1000, 3)


# ---- PCRE2 --------------------------------------------------------------------


class Pcre2:
    CASELESS = 0x8
    MULTILINE = 0x400
    DOTALL = 0x20
    EXTENDED = 0x80
    EXTENDED_MORE = 0x01000000
    NO_AUTO_CAPTURE = 0x2000
    UNGREEDY = 0x40000
    DUPNAMES = 0x40
    ANCHORED = 0x80000000
    DOLLAR_ENDONLY = 0x10
    UTF = 0x80000
    UCP = 0x20000
    NOTEMPTY_ATSTART = 0x8
    NO_JIT = 0x2000
    ERROR_NOMATCH = -1
    ERROR_MATCHLIMIT = -47
    ERROR_DEPTHLIMIT = -53
    ERROR_HEAPLIMIT = -63
    ERROR_JIT_STACKLIMIT = -46
    INFO_CAPTURECOUNT = 4
    INFO_NAMECOUNT = 17
    INFO_NAMEENTRYSIZE = 18
    INFO_NAMETABLE = 19
    CONFIG_VERSION = 11

    def __init__(self):
        lib = ctypes.CDLL(ctypes.util.find_library("pcre2-8") or "libpcre2-8.so.0")
        self.lib = lib
        P, S, U32, I = ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint32, ctypes.c_int
        lib.pcre2_compile_8.restype = P
        lib.pcre2_compile_8.argtypes = [ctypes.c_char_p, S, U32, ctypes.POINTER(I), ctypes.POINTER(S), P]
        lib.pcre2_match_data_create_from_pattern_8.restype = P
        lib.pcre2_match_data_create_from_pattern_8.argtypes = [P, P]
        lib.pcre2_match_8.restype = I
        lib.pcre2_match_8.argtypes = [P, ctypes.c_char_p, S, S, U32, P, P]
        lib.pcre2_get_ovector_pointer_8.restype = ctypes.POINTER(S)
        lib.pcre2_get_ovector_pointer_8.argtypes = [P]
        lib.pcre2_get_error_message_8.restype = I
        lib.pcre2_get_error_message_8.argtypes = [I, ctypes.c_char_p, S]
        lib.pcre2_pattern_info_8.restype = I
        lib.pcre2_pattern_info_8.argtypes = [P, U32, P]
        lib.pcre2_jit_compile_8.restype = I
        lib.pcre2_jit_compile_8.argtypes = [P, U32]
        lib.pcre2_match_context_create_8.restype = P
        lib.pcre2_match_context_create_8.argtypes = [P]
        lib.pcre2_set_match_limit_8.argtypes = [P, U32]
        lib.pcre2_jit_stack_create_8.restype = P
        lib.pcre2_jit_stack_create_8.argtypes = [S, S, P]
        lib.pcre2_jit_stack_assign_8.argtypes = [P, P, P]
        lib.pcre2_code_free_8.argtypes = [P]
        lib.pcre2_match_data_free_8.argtypes = [P]
        lib.pcre2_config_8.restype = I
        lib.pcre2_config_8.argtypes = [U32, P]
        self.context = lib.pcre2_match_context_create_8(None)
        lib.pcre2_set_match_limit_8(self.context, MATCH_LIMIT)
        stack = lib.pcre2_jit_stack_create_8(32 * 1024, 8 * 1024 * 1024, None)
        lib.pcre2_jit_stack_assign_8(self.context, None, stack)

    def version(self):
        buffer = ctypes.create_string_buffer(64)
        self.lib.pcre2_config_8(self.CONFIG_VERSION, buffer)
        return buffer.value.decode()

    def message(self, code):
        buffer = ctypes.create_string_buffer(256)
        self.lib.pcre2_get_error_message_8(code, buffer, 256)
        return buffer.value.decode()

    def info(self, code, what):
        out = ctypes.c_uint32()
        self.lib.pcre2_pattern_info_8(code, what, ctypes.byref(out))
        return out.value

    def names(self, code):
        count = self.info(code, self.INFO_NAMECOUNT)
        if not count:
            return {}
        size = self.info(code, self.INFO_NAMEENTRYSIZE)
        table = ctypes.c_void_p()
        self.lib.pcre2_pattern_info_8(code, self.INFO_NAMETABLE, ctypes.byref(table))
        raw = ctypes.string_at(table.value, count * size)
        names = {}
        for i in range(count):
            entry = raw[i * size:(i + 1) * size]
            number = (entry[0] << 8) | entry[1]
            name = entry[2:].split(b"\0", 1)[0].decode("utf-8", "replace")
            names.setdefault(name, number)
        return names

    def options(self, flags):
        table = {"i": self.CASELESS, "m": self.MULTILINE, "s": self.DOTALL, "x": self.EXTENDED,
                 "n": self.NO_AUTO_CAPTURE, "U": self.UNGREEDY, "J": self.DUPNAMES,
                 "A": self.ANCHORED, "D": self.DOLLAR_ENDONLY}
        options = 0
        for f in flags:
            options |= table.get(f, 0)
        if "u" in flags:
            options |= self.UTF | self.UCP
        return options

    def compile(self, pattern, flags):
        """(code, error, offset). The pattern is UTF-8 in UTF mode, and
        Latin-1-ish bytes otherwise, as PHP hands it over."""
        data = pattern.encode("utf-8", "surrogatepass")
        error = ctypes.c_int()
        offset = ctypes.c_size_t()
        code = self.lib.pcre2_compile_8(data, len(data), self.options(flags), ctypes.byref(error), ctypes.byref(offset), None)
        if not code:
            return None, self.message(error.value), len(data[:offset.value].decode("utf-8", "ignore"))
        self.lib.pcre2_jit_compile_8(code, 1)
        return code, None, None

    def job(self, request, text):
        flags = request.get("flags", [])
        code, error, offset = self.compile(request["pattern"], flags)
        if error:
            yield {"ok": False, "error": error, "offset": offset}
            return
        lib = self.lib
        utf = "u" in flags
        subject = text.encode("utf-8", "surrogatepass")
        length = len(subject)
        groups = self.info(code, self.INFO_CAPTURECOUNT)
        names = self.names(code)
        stride = (groups + 1) * 2
        data = lib.pcre2_match_data_create_from_pattern_8(code, None)
        convert = Bytes(subject)
        out = []
        count = 0
        limit = request.get("limit", 100000)
        started = time.monotonic()
        slice_start = started
        start = 0
        options = 0
        no_jit = 0
        try:
            while True:
                rc = lib.pcre2_match_8(code, subject, length, start, options | no_jit, data, self.context)
                if rc == self.ERROR_JIT_STACKLIMIT and not no_jit:
                    no_jit = self.NO_JIT
                    continue
                if rc == self.ERROR_NOMATCH:
                    if options == 0:
                        break
                    # The empty match could not be extended; move on a character.
                    start += 1
                    if utf:
                        while start < length and (subject[start] & 0xC0) == 0x80:
                            start += 1
                    options = 0
                    if start > length:
                        break
                    continue
                if rc < 0:
                    kind = "limit" if rc in (self.ERROR_MATCHLIMIT, self.ERROR_DEPTHLIMIT, self.ERROR_HEAPLIMIT) else "match"
                    yield {"ok": False, "error": self.message(rc), "kind": kind, "matches": out, "stride": stride, "elapsed": elapsed(started)}
                    return
                ovector = lib.pcre2_get_ovector_pointer_8(data)
                match_start, match_end = ovector[0], ovector[1]
                unset = ctypes.c_size_t(-1).value
                base_unit = convert.utf16(match_start)
                out.append(base_unit)
                out.append(convert.relative(match_start, base_unit, match_end))
                for g in range(1, groups + 1):
                    if g < rc and ovector[2 * g] != unset:
                        out.append(convert.relative(match_start, base_unit, ovector[2 * g]))
                        out.append(convert.relative(match_start, base_unit, ovector[2 * g + 1]))
                    else:
                        out.append(-1)
                        out.append(-1)
                count += 1
                if count >= limit or not request.get("all", True):
                    break
                if match_start == match_end:
                    if match_end == length:
                        break
                    options = self.NOTEMPTY_ATSTART | self.ANCHORED
                else:
                    options = 0
                # \K can leave the reported start after the end.
                start = max(match_end, match_start) if match_start <= match_end else match_start
                if time.monotonic() - slice_start > SLICE_SECONDS:
                    yield {"ok": True, "done": False, "matches": out, "stride": stride, "elapsed": elapsed(started)}
                    out = []
                    slice_start = time.monotonic()
            yield {"ok": True, "done": True, "matches": out, "stride": stride, "elapsed": elapsed(started), "names": names}
        finally:
            lib.pcre2_match_data_free_8(data)
            lib.pcre2_code_free_8(code)


# ---- POSIX (glibc) --------------------------------------------------------------


class Posix:
    REG_EXTENDED = 1
    REG_ICASE = 2
    REG_NEWLINE = 4
    REG_NOTBOL = 1
    REG_STARTEND = 4
    REG_NOMATCH = 1
    # sizeof(regex_t) is 64 on LP64 glibc; leave room.
    REGEX_T_SIZE = 256
    # re_nsub follows six pointer-sized fields in struct re_pattern_buffer.
    NSUB_OFFSET = 6 * ctypes.sizeof(ctypes.c_void_p)

    class Match(ctypes.Structure):
        _fields_ = [("rm_so", ctypes.c_int), ("rm_eo", ctypes.c_int)]

    def __init__(self):
        libc = ctypes.CDLL(ctypes.util.find_library("c"))
        libc.setlocale.restype = ctypes.c_char_p
        libc.setlocale(6, b"C.UTF-8")
        libc.regcomp.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int]
        libc.regexec.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_void_p, ctypes.c_int]
        libc.regerror.argtypes = [ctypes.c_int, ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t]
        libc.regfree.argtypes = [ctypes.c_void_p]
        self.libc = libc

    def job(self, request, text):
        libc = self.libc
        flags = request.get("flags", [])
        cflags = 0 if request.get("flavor") == "posix-bre" else self.REG_EXTENDED
        if "i" in flags:
            cflags |= self.REG_ICASE
        if "n" in flags:
            cflags |= self.REG_NEWLINE
        regex = ctypes.create_string_buffer(self.REGEX_T_SIZE)
        rc = libc.regcomp(regex, request["pattern"].encode("utf-8", "surrogatepass"), cflags)
        if rc != 0:
            buffer = ctypes.create_string_buffer(256)
            libc.regerror(rc, regex, buffer, 256)
            yield {"ok": False, "error": buffer.value.decode()}
            return
        try:
            groups = ctypes.c_size_t.from_buffer(regex, self.NSUB_OFFSET).value
            stride = (groups + 1) * 2
            matches = (self.Match * (groups + 1))()
            subject = text.encode("utf-8", "surrogatepass")
            length = len(subject)
            convert = Bytes(subject)
            out = []
            count = 0
            limit = request.get("limit", 100000)
            started = time.monotonic()
            slice_start = started
            start = 0
            while start <= length:
                # REG_STARTEND searches subject[so:eo] while still seeing
                # the whole string, so offsets come back absolute.
                matches[0].rm_so = start
                matches[0].rm_eo = length
                eflags = self.REG_STARTEND
                if start > 0 and not ((cflags & self.REG_NEWLINE) and subject[start - 1] == 0x0A):
                    eflags |= self.REG_NOTBOL
                rc = libc.regexec(regex, subject, groups + 1, matches, eflags)
                if rc == self.REG_NOMATCH:
                    break
                if rc != 0:
                    buffer = ctypes.create_string_buffer(256)
                    libc.regerror(rc, regex, buffer, 256)
                    yield {"ok": False, "error": buffer.value.decode(), "matches": out, "stride": stride, "elapsed": elapsed(started)}
                    return
                match_start, match_end = matches[0].rm_so, matches[0].rm_eo
                base_unit = convert.utf16(match_start)
                for g in range(groups + 1):
                    if matches[g].rm_so < 0:
                        out.append(-1)
                        out.append(-1)
                    else:
                        out.append(convert.relative(match_start, base_unit, matches[g].rm_so))
                        out.append(convert.relative(match_start, base_unit, matches[g].rm_eo))
                count += 1
                if count >= limit or not request.get("all", True):
                    break
                if match_end == match_start:
                    start = match_end + 1
                    while start < length and (subject[start] & 0xC0) == 0x80:
                        start += 1
                else:
                    start = match_end
                if time.monotonic() - slice_start > SLICE_SECONDS:
                    yield {"ok": True, "done": False, "matches": out, "stride": stride, "elapsed": elapsed(started)}
                    out = []
                    slice_start = time.monotonic()
            yield {"ok": True, "done": True, "matches": out, "stride": stride, "elapsed": elapsed(started), "names": {}}
        finally:
            libc.regfree(regex)


# ---- dispatch ---------------------------------------------------------------------

engines = {}


def engine(name):
    if name not in engines:
        if name == "pcre2":
            engines[name] = Pcre2()
        elif name == "posix":
            engines[name] = Posix()
        elif name == "regex":
            import regex
            engines[name] = regex
    return engines[name]


def job_for(request, text):
    flavor = request.get("flavor")
    if flavor == "python":
        return python_job(re, request, text)
    if flavor == "python-regex":
        return python_job(engine("regex"), request, text)
    if flavor == "pcre2":
        return engine("pcre2").job(request, text)
    if flavor in ("posix-ere", "posix-bre"):
        return engine("posix").job(request, text)
    raise ValueError("this worker does not run " + str(flavor))


def info():
    out = {"python": sys.version.split()[0]}
    try:
        import regex
        out["python-regex"] = regex.__version__
    except ImportError:
        pass
    try:
        out["pcre2"] = engine("pcre2").version()
    except OSError:
        pass
    try:
        libc = ctypes.CDLL(ctypes.util.find_library("c"))
        libc.gnu_get_libc_version.restype = ctypes.c_char_p
        out["posix-ere"] = out["posix-bre"] = "glibc " + libc.gnu_get_libc_version().decode()
    except (OSError, AttributeError):
        pass
    return out


def main():
    lines = Lines()
    texts = {}
    while True:
        line = lines.read()
        if line is None:
            return
        try:
            request = json.loads(line)
        except ValueError:
            continue
        rid = request.get("id")
        if request.get("op") == "info":
            send({"id": rid, "ok": True, "done": True, "versions": info()})
            continue
        # The host sends a text once and refers to it by id afterwards.
        if "text" in request:
            texts.clear()
            texts[request.get("textId")] = request["text"]
        text = texts.get(request.get("textId"))
        if text is None:
            send({"id": rid, "ok": False, "done": True, "error": "missing-text"})
            continue
        try:
            for reply in job_for(request, text):
                reply["id"] = rid
                reply.setdefault("done", True)
                reply.setdefault("matches", [])
                reply.setdefault("stride", 2)
                send(reply)
                if reply["done"]:
                    break
                if lines.waiting():
                    break
        except Exception as e:
            send({"id": rid, "ok": False, "done": True, "error": str(e), "matches": [], "stride": 2})


if __name__ == "__main__":
    main()
