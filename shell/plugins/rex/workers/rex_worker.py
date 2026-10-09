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
    NO_UTF_CHECK = 0x40000000
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
        utf_checked = 0
        try:
            while True:
                # In UTF mode PCRE2 checks the whole subject on every call
                # unless told it already has; the first call checks it.
                rc = lib.pcre2_match_8(code, subject, length, start, options | no_jit | utf_checked, data, self.context)
                utf_checked = self.NO_UTF_CHECK if utf else 0
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


class CalloutBlock(ctypes.Structure):
    _fields_ = [
        ("version", ctypes.c_uint32),
        ("callout_number", ctypes.c_uint32),
        ("capture_top", ctypes.c_uint32),
        ("capture_last", ctypes.c_uint32),
        ("offset_vector", ctypes.POINTER(ctypes.c_size_t)),
        ("mark", ctypes.c_void_p),
        ("subject", ctypes.c_void_p),
        ("subject_length", ctypes.c_size_t),
        ("start_match", ctypes.c_size_t),
        ("current_position", ctypes.c_size_t),
        ("pattern_position", ctypes.c_size_t),
        ("next_item_length", ctypes.c_size_t),
        ("callout_string_offset", ctypes.c_size_t),
        ("callout_string_length", ctypes.c_size_t),
        ("callout_string", ctypes.c_void_p),
        ("callout_flags", ctypes.c_uint32),
    ]


CALLOUT = ctypes.CFUNCTYPE(ctypes.c_int, ctypes.POINTER(CalloutBlock), ctypes.c_void_p)

DEBUG_MAX_STEPS = 200_000
DEBUG_MAX_TEXT = 65_536


def utf16_table(data):
    """UTF-16 offset of every UTF-8 byte offset, for positions that jump
    back and forth as a match backtracks."""
    table = [0] * (len(data) + 1)
    unit = 0
    i = 0
    n = len(data)
    while i < n:
        b = data[i]
        size = 1 if b < 0x80 else 4 if b >= 0xF0 else 3 if b >= 0xE0 else 2 if b >= 0xC0 else 1
        for k in range(size):
            if i + k <= n:
                table[i + k] = unit
        unit += 2 if size == 4 else 1
        i += size
    table[n] = unit
    return table


def pcre2_debug(pcre, request, text):
    """Every step PCRE2 takes until the first match (or failure), from its
    automatic callouts. With optimizations off, as by default, the steps are
    the textbook backtracking algorithm; with them on, they are what PCRE2
    really does, skipping work it can prove pointless."""
    lib = pcre.lib
    flags = request.get("flags", [])
    truncated_text = len(text) > DEBUG_MAX_TEXT
    text = text[:DEBUG_MAX_TEXT]
    options = pcre.options(flags) | 0x4  # PCRE2_AUTO_CALLOUT
    if not request.get("optimize"):
        options |= 0x4000 | 0x8000 | 0x10000  # NO_AUTO_POSSESS, NO_DOTSTAR_ANCHOR, NO_START_OPTIMIZE
    pattern = request["pattern"].encode("utf-8", "surrogatepass")
    error = ctypes.c_int()
    offset = ctypes.c_size_t()
    code = lib.pcre2_compile_8(pattern, len(pattern), options, ctypes.byref(error), ctypes.byref(offset), None)
    if not code:
        yield {"ok": False, "error": pcre.message(error.value)}
        return
    subject = text.encode("utf-8", "surrogatepass")
    text_units = utf16_table(subject)
    pattern_units = utf16_table(pattern)
    groups = pcre.info(code, pcre.INFO_CAPTURECOUNT)
    steps = []
    unset = ctypes.c_size_t(-1).value

    def unit(table, b):
        return table[b] if b <= len(table) - 1 else table[-1]

    def on_callout(block_pointer, _):
        block = block_pointer.contents
        if len(steps) >= DEBUG_MAX_STEPS:
            return -37  # PCRE2_ERROR_CALLOUT: stop here
        step = [
            unit(text_units, block.start_match),
            unit(text_units, block.current_position),
            unit(pattern_units, block.pattern_position),
            unit(pattern_units, block.pattern_position + block.next_item_length) - unit(pattern_units, block.pattern_position),
            block.callout_flags,
        ]
        ovector = block.offset_vector
        for g in range(1, groups + 1):
            if g < block.capture_top and ovector[2 * g] != unset:
                step.append(unit(text_units, ovector[2 * g]))
                step.append(unit(text_units, ovector[2 * g + 1]))
            else:
                step.append(-1)
                step.append(-1)
        steps.append(step)
        return 0

    callback = CALLOUT(on_callout)
    context = lib.pcre2_match_context_create_8(None)
    lib.pcre2_set_match_limit_8(context, MATCH_LIMIT)
    lib.pcre2_set_callout_8.argtypes = [ctypes.c_void_p, CALLOUT, ctypes.c_void_p]
    lib.pcre2_set_callout_8(context, callback, None)
    data = lib.pcre2_match_data_create_from_pattern_8(code, None)
    started = time.monotonic()
    try:
        rc = lib.pcre2_match_8(code, subject, len(subject), 0, pcre.NO_JIT, data, context)
        match = None
        error_text = ""
        if rc > 0:
            ovector = lib.pcre2_get_ovector_pointer_8(data)
            match = [unit(text_units, ovector[0]), unit(text_units, ovector[1])]
        elif rc not in (pcre.ERROR_NOMATCH, -37):
            error_text = pcre.message(rc)
        yield {
            "ok": True, "done": True, "steps": steps, "groups": groups, "match": match,
            "stopped": rc == -37, "limit": error_text, "textTruncated": truncated_text,
            "elapsed": elapsed(started), "matches": [], "stride": 2,
        }
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

    def compile(self, pattern, cflags):
        """A compiled regex_t and its group count, or None and the error."""
        regex = ctypes.create_string_buffer(self.REGEX_T_SIZE)
        rc = self.libc.regcomp(regex, pattern.encode("utf-8", "surrogatepass"), cflags)
        if rc != 0:
            buffer = ctypes.create_string_buffer(256)
            self.libc.regerror(rc, regex, buffer, 256)
            return None, buffer.value.decode()
        return regex, ctypes.c_size_t.from_buffer(regex, self.NSUB_OFFSET).value

    def free(self, regex):
        self.libc.regfree(regex)

    def groups_at(self, regex, groups, subject, line_start, line_end, start):
        """Every group's [start, end) for the match found at start within
        one line, or None when the engine does not match there."""
        matches = (self.Match * (groups + 1))()
        # REG_STARTEND counts from the line handed over, so hand over the line.
        line = subject[line_start:line_end]
        matches[0].rm_so = start - line_start
        matches[0].rm_eo = len(line)
        eflags = self.REG_STARTEND | (self.REG_NOTBOL if start > line_start else 0)
        if self.libc.regexec(regex, line, groups + 1, matches, eflags) != 0:
            return None
        return [(m.rm_so + line_start, m.rm_eo + line_start) if m.rm_so >= 0 else (-1, -1) for m in matches]

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


# ---- grep, sed, gawk ------------------------------------------------------------
#
# The tools run once per request on the whole text, the way a user runs them
# on a file, and report matches line by line as they do.

import subprocess

TOOL_ENV = dict(os.environ, LC_ALL="C.UTF-8")


def run_tool(command, data, env=None):
    result = subprocess.run(command, input=data, capture_output=True, env=env or TOOL_ENV, timeout=60)
    return result.returncode, result.stdout, result.stderr.decode("utf-8", "replace").strip()


def tool_error(stderr, name):
    # "grep: Unmatched ( or \(" -> "Unmatched ( or \("
    return stderr.split("\n")[0].split(": ", 1)[-1] if stderr else name + " failed"


# A group whose position the engine does not report is -2, which Rex shows
# as unknown rather than guessing.
UNKNOWN = -2


def grep_job(request, text):
    flags = request.get("flags", [])
    command = ["grep", "-o", "-b", "-a"]
    if request.get("flavor") == "grep-e":
        command.append("-E")
    command += ["-" + f for f in flags if f in ("i", "w", "x")]
    command += ["-e", request["pattern"]]
    subject = text.encode("utf-8", "surrogatepass")
    started = time.monotonic()
    code, stdout, stderr = run_tool(command, subject)
    if code > 1:
        yield {"ok": False, "error": tool_error(stderr, "grep")}
        return
    convert = Bytes(subject)
    out = []
    limit = request.get("limit", 100000)
    for line in stdout.split(b"\n"):
        if not line:
            continue
        offset, _, value = line.partition(b":")
        start = int(offset)
        out.append(convert.utf16(start))
        out.append(convert.utf16(start + len(value)))
        if len(out) // 2 >= limit or not request.get("all", True):
            break
    yield {"ok": True, "done": True, "matches": out, "stride": 2, "elapsed": elapsed(started), "names": {}}


def marker_bytes(subject):
    """Two bytes that do not occur in the text, to mark where matches are."""
    for a, b in ((1, 2), (3, 4), (5, 6), (14, 15), (16, 17), (18, 19), (20, 21), (22, 23)):
        if bytes([a]) not in subject and bytes([b]) not in subject:
            return bytes([a]), bytes([b])
    return None, None


def sed_job(request, text):
    flags = request.get("flags", [])
    groups = min(int(request.get("groups", 0)), 9)
    subject = text.encode("utf-8", "surrogatepass")
    open_mark, close_mark = marker_bytes(subject)
    if open_mark is None:
        yield {"ok": False, "error": "Rex cannot mark matches in a text that uses every control character"}
        return
    # Each match becomes OPEN match SEP group1 SEP group2 ... CLOSE. sed only
    # says what groups matched; where they matched comes from glibc's regex,
    # the engine GNU sed is built on, run at the place sed found the match. A
    # group it cannot place keeps the text sed gave it.
    separator = b"\x7f" if b"\x7f" not in subject else b"\x1f"
    replacement = open_mark + b"&" + b"".join(separator + b"\\" + str(g).encode() for g in range(1, groups + 1)) + close_mark
    pattern = request["pattern"].encode("utf-8", "surrogatepass")
    # The s command's delimiter must not occur in the pattern or replacement.
    delimiter = next((bytes([c]) for c in range(1, 32) if c != 10 and bytes([c]) not in pattern and bytes([c]) not in replacement), None)
    if delimiter is None or b"\0" in pattern:
        yield {"ok": False, "error": "Rex cannot hand this pattern to sed"}
        return
    script = b"s" + delimiter + pattern + delimiter + replacement + delimiter + b"g"
    script += b"".join(f.upper().encode() for f in flags if f in ("i", "m"))
    command = [b"sed"] + ([b"-E"] if request.get("flavor") == "sed-e" else []) + [b"-e", script]
    started = time.monotonic()
    code, stdout, stderr = run_tool(command, subject)
    if code != 0:
        yield {"ok": False, "error": tool_error(stderr, "sed")}
        return
    posix = engine("posix")
    located = None
    if groups:
        cflags = (posix.REG_EXTENDED if request.get("flavor") == "sed-e" else 0) | (posix.REG_ICASE if "i" in flags else 0)
        located, located_groups = posix.compile(request["pattern"], cflags)
        if located is not None and located_groups != groups:
            posix.free(located)
            located = None
    try:
        convert = Bytes(subject)
        out = []
        texts = {}
        count = 0
        position = 0
        index = 0
        # The line holding the current match; matches only move forward, so
        # each line boundary is found once.
        line_start, line_end = 0, subject.find(b"\n")
        line_end = len(subject) if line_end < 0 else line_end
        limit = request.get("limit", 100000)
        while True:
            at = stdout.find(open_mark, index)
            if at < 0:
                break
            position += at - index
            end = stdout.find(close_mark, at)
            parts = stdout[at + 1:end].split(separator)
            whole = parts[0]
            base_unit = convert.utf16(position)
            out.append(base_unit)
            out.append(convert.relative(position, base_unit, position + len(whole)))
            spans = None
            if located is not None:
                while line_end < position:
                    line_start = line_end + 1
                    line_end = subject.find(b"\n", line_start)
                    line_end = len(subject) if line_end < 0 else line_end
                spans = posix.groups_at(located, groups, subject, line_start, line_end, position)
                if spans and spans[0] != (position, position + len(whole)):
                    spans = None
            for g in range(1, groups + 1):
                if spans is None:
                    out.extend((UNKNOWN, UNKNOWN))
                elif spans[g][0] < 0:
                    out.extend((-1, -1))
                else:
                    out.append(convert.relative(position, base_unit, spans[g][0]))
                    out.append(convert.relative(position, base_unit, spans[g][1]))
            if groups and spans is None:
                texts[str(count)] = [part.decode("utf-8", "replace") for part in parts[1:1 + groups]]
            count += 1
            position += len(whole)
            index = end + 1
            if count >= limit or not request.get("all", True):
                break
        yield {"ok": True, "done": True, "matches": out, "stride": (groups + 1) * 2, "elapsed": elapsed(started), "names": {}, "groupTexts": texts}
    finally:
        if located is not None:
            posix.free(located)


GAWK_PROGRAM = r"""
BEGIN { re = ENVIRON["REX_PATTERN"]; groups = ENVIRON["REX_GROUPS"] + 0; IGNORECASE = ENVIRON["REX_ICASE"] + 0; RS = "\n" }
{
  line = $0
  n = split(line, pieces, re, seps)
  at = 0
  for (i = 1; i < n; i++) {
    at += length(pieces[i])
    printf "%d %d %d", NR, at, length(seps[i])
    if (groups > 0 && match(substr(line, at + 1), re, m)) {
      for (g = 1; g <= groups; g++) {
        if ((g, "start") in m) printf " %d %d", at + m[g, "start"] - 1, m[g, "length"]
        else printf " -1 -1"
      }
    } else {
      for (g = 1; g <= groups; g++) printf " -1 -1"
    }
    printf "\n"
    at += length(seps[i])
  }
}
"""


def gawk_job(request, text):
    groups = int(request.get("groups", 0))
    env = dict(TOOL_ENV, REX_PATTERN=request["pattern"], REX_GROUPS=str(groups), REX_ICASE="1" if "i" in request.get("flags", []) else "0")
    started = time.monotonic()
    code, stdout, stderr = run_tool(["gawk", "--re-interval", GAWK_PROGRAM], text.encode("utf-8", "surrogatepass"), env)
    if code != 0 or (stderr and "fatal" in stderr):
        yield {"ok": False, "error": tool_error(stderr, "gawk")}
        return
    # gawk counts characters in a UTF-8 locale; lines are split on \n.
    line_starts = [0]
    for i, c in enumerate(text):
        if c == "\n":
            line_starts.append(i + 1)
    convert = CodePoints(text)
    out = []
    limit = request.get("limit", 100000)
    for row in stdout.decode("utf-8", "replace").splitlines():
        numbers = [int(x) for x in row.split()]
        base = line_starts[numbers[0] - 1]
        start = base + numbers[1]
        out.append(convert.utf16(start))
        out.append(convert.utf16(start + numbers[2]))
        for g in range(groups):
            gs, gl = numbers[3 + 2 * g], numbers[4 + 2 * g]
            if gs < 0:
                out.extend((-1, -1))
            else:
                out.append(convert.utf16(base + gs))
                out.append(convert.utf16(base + gs + gl))
        if len(out) // ((groups + 1) * 2) >= limit or not request.get("all", True):
            break
    yield {"ok": True, "done": True, "matches": out, "stride": (groups + 1) * 2, "elapsed": elapsed(started), "names": {}}


# ---- Resid ------------------------------------------------------------------------


class Resid:
    """Resid's lib/regex.resid, compiled into a small program that speaks
    escaped lines (workers/resid/rex_worker.resid). The program path comes
    from omarchy-rex-worker, which builds it."""

    def __init__(self, program):
        def die_with_parent():
            libc = ctypes.CDLL(ctypes.util.find_library("c"))
            libc.prctl(1, 15)  # PR_SET_PDEATHSIG, SIGTERM

        self.process = subprocess.Popen([program], stdin=subprocess.PIPE, stdout=subprocess.PIPE, preexec_fn=die_with_parent)
        self.text = None

    @staticmethod
    def escape(s):
        return s.replace("\\", "\\\\").replace("\n", "\\n")

    def job(self, request, text):
        flags = "".join(f for f in request.get("flags", []) if f in "imsx")
        if self.text is text:
            body = "="
        else:
            body = "+" + self.escape(text)
            self.text = text
        message = flags + "\n" + self.escape(request["pattern"]) + "\n" + body + "\n"
        started = time.monotonic()
        self.process.stdin.write(message.encode("utf-8", "surrogatepass"))
        self.process.stdin.flush()
        line = self.process.stdout.readline().decode("utf-8", "replace").rstrip("\n")
        if not line:
            self.text = None
            yield {"ok": False, "error": "The Resid worker stopped unexpectedly"}
            return
        if line.startswith("ERR "):
            yield {"ok": False, "error": line[4:]}
            return
        fields = line.split("\t")
        groups = int(fields[1])
        names = {name: i for i, name in enumerate(fields[2:2 + groups]) if name}
        offsets = [int(x) for x in fields[2 + groups:]]
        convert = CodePoints(text)
        stride = groups * 2
        limit = request.get("limit", 100000)
        if not request.get("all", True):
            limit = 1
        out = [convert.utf16(x) for x in offsets[:limit * stride]]
        yield {"ok": True, "done": True, "matches": out, "stride": stride, "elapsed": elapsed(started), "names": names}


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
        elif name == "resid":
            engines[name] = Resid(os.environ["REX_RESID_PROGRAM"])
    return engines[name]


def job_for(request, text):
    flavor = request.get("flavor")
    if request.get("op") == "debug":
        if flavor != "pcre2":
            raise ValueError("the debugger runs on PCRE2 only")
        return pcre2_debug(engine("pcre2"), request, text)
    if flavor == "python":
        return python_job(re, request, text)
    if flavor == "python-regex":
        return python_job(engine("regex"), request, text)
    if flavor == "pcre2":
        return engine("pcre2").job(request, text)
    if flavor in ("posix-ere", "posix-bre"):
        return engine("posix").job(request, text)
    if flavor in ("grep", "grep-e"):
        return grep_job(request, text)
    if flavor in ("sed", "sed-e"):
        return sed_job(request, text)
    if flavor == "gawk":
        return gawk_job(request, text)
    if flavor == "resid":
        return engine("resid").job(request, text)
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
    for tool, flavors in (("grep", ("grep", "grep-e")), ("sed", ("sed", "sed-e")), ("gawk", ("gawk",))):
        try:
            first = subprocess.run([tool, "--version"], capture_output=True, timeout=5).stdout.decode().splitlines()[0]
            for flavor in flavors:
                out[flavor] = first
        except (OSError, IndexError, subprocess.SubprocessError):
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
        elif "textPath" in request:
            # A file opened in Rex is read here rather than sent over the pipe.
            texts.clear()
            with open(request["textPath"], encoding="utf-8", errors="replace", newline="") as f:
                texts[request.get("textId")] = f.read()
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
                # A newer request supersedes this one, unless it was kept.
                if lines.waiting() and not request.get("keep"):
                    break
        except Exception as e:
            send({"id": rid, "ok": False, "done": True, "error": str(e), "matches": [], "stride": 2})


if __name__ == "__main__":
    main()
