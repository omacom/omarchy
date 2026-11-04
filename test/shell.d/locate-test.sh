#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3

python3 - <<'PY'
import os
from pathlib import Path
import shlex
import subprocess
import tempfile

root = Path(os.environ["ROOT"])

def check(condition, description):
  if not condition:
    raise SystemExit("not ok - " + description)
  print("ok - " + description, flush=True)

drop_in = root / "default/systemd/system/plocate-updatedb.service.d/10-omarchy.conf"
directives = [line.strip() for line in drop_in.read_text().splitlines() if line.strip() and not line.startswith("#")]
check(len(directives) == 3 and directives[:2] == ["[Service]", "ExecStart="] and directives[2].startswith("ExecStart="),
      "locate drop-in replaces the command and preserves upstream service restrictions")
command = shlex.split(directives[2].removeprefix("ExecStart="))
options = ["--prune-bind-mounts=no", "--add-prunepaths=/.snapshots"]
check(command == ["/usr/bin/updatedb", *options],
      "locate service runs updatedb directly with fixed Btrfs options")

with tempfile.TemporaryDirectory(prefix="omarchy-locate-") as scratch:
  scratch = Path(scratch)
  fake_bin = scratch / "bin"
  fake_bin.mkdir()
  stubs = {
    "updatedb": 'printf "%s\\n" "$@" >"$TEST_CALLS"',
    "sudo": 'exec "$@"',
    "fzf": 'cat >/dev/null\nprintf "%s\\n" test-package',
    "yay": 'if [[ ${1:-} == "-Slqa" ]]; then printf "%s\\n" test-package; fi',
    "omarchy-sudo-keepalive": ':',
    "omarchy-show-done": ':',
  }
  for name, body in stubs.items():
    path = fake_bin / name
    path.write_text("#!/bin/bash\n" + body + "\n")
    path.chmod(0o755)
  calls = scratch / "updatedb-arguments"
  env = dict(os.environ, PATH=str(fake_bin) + ":" + os.environ["PATH"], TEST_CALLS=str(calls))
  for relative in ("install/post-install/localdb.sh", "bin/omarchy-pkg-aur-install"):
    subprocess.run(["bash", "-euo", "pipefail", str(root / relative)], env=env, check=True)
    check(calls.read_text().splitlines() == options,
          relative + " passes the scheduled service options directly")
    calls.unlink()
PY
