#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - "$ROOT/bin/omarchy-agent-inspect-gguf" <<'PY'
import json
from pathlib import Path
import struct
import subprocess
import sys
from tempfile import TemporaryDirectory


def fixture(endian, version):
  def number(fmt, *values):
    return struct.pack(endian + fmt, *values)

  def string(text):
    return number("Q", len(text)) + text

  return (b"GGUF" + number("IQQ", version, 7, 4)
          + string(b"tokenizer.ggml.tokens") + number("IIQ", 9, 8, 2) + string(b"a") + string(b"bc")
          + string(b"llama.context_length") + number("II", 4, 32768)
          + string(b"general.architecture") + number("I", 8) + string(b"llama")
          + string(b"general.file_type") + number("II", 4, 15))


def inspect(path):
  return subprocess.run([sys.executable, sys.argv[1], str(path), "--json"], capture_output=True, timeout=5)


with TemporaryDirectory() as temp:
  model = Path(temp) / "model.gguf"
  for endian, version in [("<", 2), ("<", 3), (">", 3)]:
    model.write_bytes(fixture(endian, version))
    result = inspect(model)
    assert result.returncode == 0, result.stderr
    assert json.loads(result.stdout) == {
      "gguf_version": version,
      "name": None,
      "architecture": "llama",
      "context_tokens": 32768,
      "file_type": 15,
      "tensor_count": 7,
    }, result.stdout

  for damaged in [fixture("<", 3)[:-2], b"GGUF" + struct.pack("<IQQQ", 3, 0, 1, 2**63)]:
    model.write_bytes(damaged)
    result = inspect(model)
    assert result.returncode == 1 and b"limit" in result.stderr, result.stderr
PY

pass "GGUF inspection reads both byte orders and rejects truncated or oversized metadata"
