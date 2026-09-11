#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command updatedb
require_command plocate

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
check("ConditionACPower=true" in (root / "etc/systemd/system/plocate-updatedb.service.d/ac-only.conf").read_text(),
      "scheduled locate indexing keeps its AC-power condition")
check(not (root / "install/config/locate.sh").exists() and not (root / "migrations/1784809451.sh").exists(),
      "the retired locate configuration helper and migration are absent")
for directory in ("bin", "install", "migrations"):
  for path in (root / directory).rglob("*"):
    if path.is_file():
      content = path.read_bytes()
      if b"OMARCHY_UPDATEDB_CONF_PATH" in content or b"config/locate.sh" in content:
        raise SystemExit("not ok - retired locate configuration path remains in " + str(path))
check(True, "runtime and installation no longer reference the configuration rewrite")

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

  tree = scratch / "tree"
  visible = tree / "home/current-file"
  excluded = tree / "private&pipe|directory"
  hidden = excluded / "private-file"
  visible.parent.mkdir(parents=True)
  excluded.mkdir()
  visible.touch()
  hidden.touch()
  conf = scratch / "updatedb.conf"
  conf.write_text('PRUNE_BIND_MOUNTS = "yes"\nPRUNEPATHS = "' + str(excluded) + '"\n')
  conf.chmod(0o640)
  original = conf.read_bytes()
  metadata = conf.stat()
  database = scratch / "plocate.db"
  run = [*command, "--config-file", str(conf), "--database-root", str(tree),
         "--output", str(database), "--require-visibility", "no", "--debug-pruning"]
  result = subprocess.run(run, capture_output=True, text=True, check=True)
  debug = result.stdout + result.stderr
  check("prune_bind_mounts\\000\n0\\000" in debug and "/.snapshots\\000" in debug,
        "real updatedb overrides bind-mount pruning and adds root snapshots to exclusions")
  entries = subprocess.check_output(["plocate", "--database", str(database), ""], text=True).splitlines()
  check(str(visible) in entries and str(hidden) not in entries,
        "real locate indexes current files and preserves literal administrator exclusions")
  check(conf.read_bytes() == original and (conf.stat().st_mode, conf.stat().st_uid, conf.stat().st_gid, conf.stat().st_mtime_ns)
        == (metadata.st_mode, metadata.st_uid, metadata.st_gid, metadata.st_mtime_ns),
        "indexing preserves configuration bytes, permissions, ownership, and modification time")
  subprocess.run(run, capture_output=True, check=True)
  repeated = subprocess.check_output(["plocate", "--database", str(database), ""], text=True).splitlines()
  check(repeated == entries, "repeated indexing retains the same results and exclusions")
PY
