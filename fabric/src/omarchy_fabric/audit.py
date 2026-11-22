"""Tamper-evident audit log: append-only JSONL with a SHA-256 hash chain.

Every decision, approval and execution is recorded with who asked, what they
asked for, why they said they wanted it, and what happened. Each line carries
the hash of the previous line, so editing or deleting a record breaks the chain
from that point on (`ofab audit verify`). With an HMAC key (kept where agents
cannot read it, e.g. on the Pi node) a rewrite of the whole file is detectable
too.
"""

from __future__ import annotations

import hashlib
import hmac
import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from .util import Clock, iso

GENESIS = "0" * 64


def _canonical(record: dict[str, Any]) -> bytes:
    return json.dumps(record, sort_keys=True, separators=(",", ":"), ensure_ascii=False, default=str).encode()


def _digest(prev: str, record: dict[str, Any], key: bytes | None) -> str:
    payload = prev.encode() + b"\n" + _canonical(record)
    if key:
        return hmac.new(key, payload, hashlib.sha256).hexdigest()
    return hashlib.sha256(payload).hexdigest()


@dataclass
class VerifyResult:
    ok: bool
    records: int
    first_bad_seq: int | None = None
    message: str = ""

    def to_dict(self) -> dict[str, Any]:
        return {"ok": self.ok, "records": self.records, "first_bad_seq": self.first_bad_seq,
                "message": self.message}


class AuditLog:
    def __init__(self, path: Path | None, clock: Clock, key: bytes | None = None, fsync: bool = True,
                 memory: int = 200):
        self.path = Path(path) if path else None
        self.clock = clock
        self.key = key
        self.fsync = fsync
        self._memory: list[dict[str, Any]] = []
        self._memory_max = memory
        self.seq = 0
        self.prev = GENESIS
        if self.path and self.path.exists():
            last = _last_line(self.path)
            if last:
                record = json.loads(last)
                self.seq = int(record["seq"])
                self.prev = record["hash"]

    def append(self, kind: str, **fields: Any) -> dict[str, Any]:
        self.seq += 1
        now = self.clock.now()
        record: dict[str, Any] = {"seq": self.seq, "ts": iso(now), "kind": kind}
        record.update({k: v for k, v in fields.items() if v is not None})
        record["prev"] = self.prev
        record["hash"] = _digest(self.prev, record, self.key)
        self.prev = record["hash"]
        if self.path:
            self.path.parent.mkdir(parents=True, exist_ok=True)
            with open(self.path, "a", encoding="utf-8") as fh:
                fh.write(json.dumps(record, ensure_ascii=False, default=str) + "\n")
                if self.fsync:
                    fh.flush()
                    os.fsync(fh.fileno())
        self._memory.append(record)
        del self._memory[: -self._memory_max]
        return record

    def tail(self, n: int = 20) -> list[dict[str, Any]]:
        if self.path and self.path.exists():
            with open(self.path, encoding="utf-8") as fh:
                lines = fh.readlines()[-n:]
            return [json.loads(line) for line in lines if line.strip()]
        return self._memory[-n:]

    def verify(self) -> VerifyResult:
        if self.path is None:
            return verify_records(self._memory, self.key, partial=True)
        return verify_file(self.path, self.key)


def verify_records(records: list[dict[str, Any]], key: bytes | None, partial: bool = False) -> VerifyResult:
    prev = records[0]["prev"] if (partial and records) else GENESIS
    expected_seq = records[0]["seq"] if (partial and records) else 1
    for record in records:
        body = {k: v for k, v in record.items() if k != "hash"}
        if record.get("seq") != expected_seq:
            return VerifyResult(False, expected_seq - 1, record.get("seq"),
                                f"sequence gap: expected {expected_seq}, found {record.get('seq')}")
        if body.get("prev") != prev:
            return VerifyResult(False, expected_seq - 1, expected_seq, f"record {expected_seq} does not chain to the previous one")
        if _digest(prev, body, key) != record.get("hash"):
            return VerifyResult(False, expected_seq - 1, expected_seq, f"record {expected_seq} was modified")
        prev = record["hash"]
        expected_seq += 1
    return VerifyResult(True, len(records), None, "chain intact")


def verify_file(path: Path, key: bytes | None = None) -> VerifyResult:
    records = []
    with open(path, encoding="utf-8") as fh:
        for n, line in enumerate(fh, 1):
            if not line.strip():
                continue
            try:
                records.append(json.loads(line))
            except json.JSONDecodeError:
                return VerifyResult(False, len(records), len(records) + 1, f"line {n} is not valid JSON")
    return verify_records(records, key)


def _last_line(path: Path) -> str:
    with open(path, "rb") as fh:
        fh.seek(0, os.SEEK_END)
        size = fh.tell()
        block = min(size, 65536)
        fh.seek(size - block)
        lines = [line for line in fh.read().splitlines() if line.strip()]
    return lines[-1].decode() if lines else ""
