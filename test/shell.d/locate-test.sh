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

with tempfile.TemporaryDirectory(prefix="omarchy-locate-") as scratch:
  scratch = Path(scratch)
  fake_bin = scratch / "bin"
  fake_bin.mkdir()
  stubs = {
    "updatedb": 'printf "%s\\n" "$@" >"$TEST_CALLS"',
    "sudo": 'exec "$@"',
  }
  for name, body in stubs.items():
    path = fake_bin / name
    path.write_text("#!/bin/bash\n" + body + "\n")
    path.chmod(0o755)
  calls = scratch / "updatedb-arguments"
  env = dict(os.environ, PATH=str(fake_bin) + ":" + os.environ["PATH"], TEST_CALLS=str(calls))
  subprocess.run(["bash", "-euo", "pipefail", str(root / "install/post-install/localdb.sh")], env=env, check=True)
  check(calls.read_text().splitlines() == options,
        "initial installation passes the scheduled service options directly")

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

# The AUR picker runs through its protected interpreter and real security
# helpers, with privileged paths redirected by the shared harmless fixture.
# Its install result must never trigger another filesystem scan.
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-pkg-aur-install
rm "$SUDO_TEST_ROOT/bin/yay" "$SUDO_TEST_ROOT/bin/systemd-run"

cat >"$SUDO_TEST_ROOT/bin/yay" <<'STUB'
#!/bin/bash
if [[ $1 == "-Slqa" ]]; then
  echo test-package
else
  echo build >>"$SUDO_TEST_LOG"
  exit "${SUDO_TEST_AUR_STATUS:-0}"
fi
STUB
cat >"$SUDO_TEST_ROOT/bin/fzf" <<'STUB'
#!/bin/bash
cat
STUB
cat >"$SUDO_TEST_ROOT/bin/omarchy-show-done" <<'STUB'
#!/bin/bash
exit 0
STUB
cat >"$SUDO_TEST_ROOT/bin/updatedb" <<'STUB'
#!/bin/bash
echo unexpected-indexing >>"$SUDO_TEST_LOG"
exit 99
STUB
chmod +x "$SUDO_TEST_ROOT/bin/"{yay,fzf,omarchy-show-done,updatedb}
ln -s updatedb "$SUDO_TEST_ROOT/bin/systemctl"
ln -s updatedb "$SUDO_TEST_ROOT/bin/systemd-run"

for result in 0 42; do
  reset_boundary
  status=0
  SUDO_TEST_AUR_STATUS=$result "$SUDO_TEST_ROOT/bin/omarchy-pkg-aur-install" >"$boundary_tmp/output" 2>&1 || status=$?
  (( status == result )) || fail "AUR install returns status $result" "$(<"$boundary_tmp/output")"
  grep -qx build "$SUDO_TEST_LOG" || fail "AUR install did not exercise the package transaction"
  if grep -qx unexpected-indexing "$SUDO_TEST_LOG"; then
    fail "AUR install must leave filesystem indexing to the scheduled service"
  fi
  assert_boundary_cold "AUR result $result"
  pass "AUR install result $result leaves indexing to the scheduled service"
done
