#!/bin/bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
sandbox=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-embedded-smoke.XXXXXX")
printf 'Test artifacts: %s\n' "$sandbox"
cd "$root"
cargo build --locked --offline --profile plymouth -j1
target=${CARGO_TARGET_DIR:-$root/target}
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror -Iinclude tests/smoke.c \
  "$target/plymouth/libttfx_plymouth.a" -ldl -lpthread -lm -o "$sandbox/smoke"
strace -f -s 256 \
  -e trace=ioctl,clone,clone3,fork,vfork,execve,nanosleep,clock_nanosleep,rt_sigaction,write,writev \
  -o "$sandbox/trace" "$sandbox/smoke" > "$sandbox/stdout"
python3 - "$sandbox" <<'PY'
from pathlib import Path
import re
import sys

sandbox = Path(sys.argv[1])
trace = (sandbox / "trace").read_text()
output = (sandbox / "stdout").read_bytes()
syscalls = re.findall(r"^\d+\s+(\w+)\(", trace, re.MULTILINE)
assert syscalls == ["execve", "write"], trace
assert re.search(r'^\d+\s+write\(1, "C smoke passed:', trace, re.MULTILINE), trace
assert output.startswith(b"C smoke passed:") and output.count(b"\n") == 1, output
assert b"\x1b" not in output, output
print(output.decode(), end="")
print("embedded terminal isolation: PASS (no tty queries, child processes, sleeps, signal setup or ANSI output)")
PY
