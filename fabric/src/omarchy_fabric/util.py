"""Small shared helpers: clocks, globbing, untrusted-text hygiene, ids."""

from __future__ import annotations

import datetime as _dt
import fnmatch
import re
import secrets
import time
import unicodedata

# ---------------------------------------------------------------- clocks


class Clock:
    """Wall clock. Everything time-based (holds, leases, rate limits, approval
    expiry) goes through a Clock so tests can run deterministic timelines."""

    def now(self) -> float:
        return time.time()

    def local(self) -> _dt.datetime:
        return _dt.datetime.fromtimestamp(self.now()).astimezone()


class FakeClock(Clock):
    def __init__(self, start: float | None = None):
        # Default start: a fixed Wednesday at 12:00 local time, outside quiet hours.
        if start is None:
            start = _dt.datetime(2026, 11, 18, 12, 0, 0).timestamp()
        self._now = start

    def now(self) -> float:
        return self._now

    def advance(self, seconds: float) -> None:
        self._now += seconds

    def set_local_time(self, hour: int, minute: int = 0) -> None:
        current = _dt.datetime.fromtimestamp(self._now)
        target = current.replace(hour=hour, minute=minute, second=0, microsecond=0)
        self._now = target.timestamp()


def iso(ts: float) -> str:
    return _dt.datetime.fromtimestamp(ts, _dt.timezone.utc).isoformat(timespec="seconds")


# ---------------------------------------------------------------- matching


def match_thing(pattern: str, thing) -> bool:
    """Patterns: "*", "ha:light.*" (id glob), "area:kitchen", "kind:heater", "tag:x"."""
    if pattern in ("*", ""):
        return True
    if pattern.startswith("area:"):
        return fnmatch.fnmatchcase((thing.area or "").lower(), pattern[5:].lower())
    if pattern.startswith("kind:"):
        return fnmatch.fnmatchcase(thing.kind or "", pattern[5:])
    if pattern.startswith("tag:"):
        return any(fnmatch.fnmatchcase(t, pattern[4:]) for t in thing.tags)
    return fnmatch.fnmatchcase(thing.id, pattern)


def glob(pattern: str, value: str) -> bool:
    return pattern in ("*", "") or fnmatch.fnmatchcase(value, pattern)


# ---------------------------------------------------------------- untrusted text

# Device names and string attributes come from devices, other controllers and
# whoever paired them. They reach the agent's context, so treat them as data:
# strip control / bidi characters, cap the length, and flag text that looks
# like it is trying to instruct the model.
_INVISIBLE = re.compile("[\u0000-\u001f\u007f-\u009f​-‏ -‮⁠-⁯﻿]")
_SUSPICIOUS = re.compile(
    r"(ignore|disregard|forget|override)\W+(all\W+)?(previous|prior|above|earlier|your)\W+"
    r"|\b(system prompt|developer message|you are now|new instructions?)\b"
    r"|<\s*/?\s*(system|instructions?|assistant|tool)\s*>"
    r"|\b(assistant|system)\s*:",
    re.IGNORECASE,
)
MAX_NAME = 64


def clean_text(text: object, limit: int = MAX_NAME) -> str:
    s = unicodedata.normalize("NFKC", str(text))
    s = _INVISIBLE.sub(" ", s)
    s = " ".join(s.split())
    if len(s) > limit:
        s = s[: limit - 1] + "…"
    return s


def looks_like_injection(text: object) -> bool:
    s = unicodedata.normalize("NFKC", str(text))
    return bool(_SUSPICIOUS.search(s)) or len(s) > 2 * MAX_NAME


# ---------------------------------------------------------------- ids

_ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # no 0/O, 1/I: easy to read aloud and type


def short_id(n: int = 6) -> str:
    return "".join(secrets.choice(_ALPHABET) for _ in range(n))


def parse_hhmm(text: str) -> _dt.time:
    hh, _, mm = text.partition(":")
    return _dt.time(int(hh), int(mm or 0))
