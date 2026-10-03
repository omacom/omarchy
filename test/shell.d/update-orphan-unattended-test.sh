#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

grep -Fq 'OMARCHY_UPDATE_UNATTENDED' "$ROOT/bin/omarchy-update-orphan-pkgs" ||
  fail "orphan checker must honor OMARCHY_UPDATE_UNATTENDED"

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
if [[ $1 == "-Qtdq" ]]; then
  printf '%s\n' orphan-a orphan-b
  exit 0
fi
exit 0
SH
chmod +x "$stub_bin/pacman"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
echo "gum should not run in unattended mode" >&2
exit 1
SH
chmod +x "$stub_bin/gum"

# Drive a real PTY so -t 0/-t 1 are true; without OMARCHY_UPDATE_UNATTENDED
# the checker would call gum and hang/fail (#13356).
python3 - "$stub_bin" "$ROOT" "$test_tmp/out" <<'PY'
import os, pty, sys

stub_bin, root, out_path = sys.argv[1:4]
env = os.environ.copy()
env["PATH"] = stub_bin + os.pathsep + root + "/bin" + os.pathsep + env.get("PATH", "")
env["OMARCHY_UPDATE_UNATTENDED"] = "1"

pid, fd = pty.fork()
if pid == 0:
  os.execvpe("omarchy-update-orphan-pkgs", ["omarchy-update-orphan-pkgs"], env)

chunks = []
while True:
  try:
    data = os.read(fd, 4096)
  except OSError:
    break
  if not data:
    break
  chunks.append(data)

os.close(fd)
_, status = os.waitpid(pid, 0)
with open(out_path, "wb") as fh:
  fh.write(b"".join(chunks))
sys.exit(0 if os.WIFEXITED(status) and os.WEXITSTATUS(status) == 0 else 1)
PY

grep -q 'orphaned package' "$test_tmp/out" || fail "unattended orphan step reports orphans" "$(cat "$test_tmp/out")"
if grep -q 'gum should not run' "$test_tmp/out"; then
  fail "unattended orphan step must not call gum" "$(cat "$test_tmp/out")"
fi
pass "unattended orphan step skips gum confirm on a TTY"
