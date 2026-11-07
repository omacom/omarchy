#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
python3 - <<'PY'
import json
import os
import shlex
import subprocess
import tempfile
from pathlib import Path

root = Path(os.environ["ROOT"])
installer = (root / "bin/omarchy-install-service-sunshine").read_text()
# Source only declarations and functions. Never install packages, start
# Sunshine, modify the firewall, or launch a real browser from this test.
declarations = installer.split('\necho "Installing Sunshine..."', 1)[0]
assert declarations != installer
assert "--ignore-certificate-errors" not in installer

with tempfile.TemporaryDirectory() as temporary:
  scratch = Path(temporary)
  test_home = scratch / "home"
  binaries = scratch / "bin"
  applications = test_home / ".local/share/applications"
  applications.mkdir(parents=True)
  binaries.mkdir()
  environment = dict(os.environ, SUNSHINE_TEST_HOME=str(test_home),
    SUNSHINE_TEST_LOG=str(scratch / "launch.json"), SUNSHINE_TEST_HANDOFF="1",
    SUNSHINE_TEST_BROWSER="google-chrome-sunshine-test.desktop",
    PATH=str(binaries) + ":" + os.environ["PATH"])

  def executable(name, source):
    target = binaries / name
    target.write_text(source)
    target.chmod(0o755)
    return target

  def run(*command):
    return subprocess.run(command, env=environment, check=True, text=True, capture_output=True)

  # Redirect fixed user paths in copies without changing the test runner's HOME.
  executable("omarchy-webapp-install", (root / "bin/omarchy-webapp-install").read_text().replace("$HOME", "${SUNSHINE_TEST_HOME}"))
  launcher = (root / "bin/omarchy-launch-webapp").read_text()
  executable("omarchy-launch-webapp", launcher.replace("~/.local", "${SUNSHINE_TEST_HOME}/.local").replace("~/.nix-profile", "${SUNSHINE_TEST_HOME}/.nix-profile"))
  executable("omarchy-cmd-default-browser", '#!/bin/bash\nprintf "%s\\n" "$SUNSHINE_TEST_BROWSER"\n')
  executable("gtk-update-icon-cache", "#!/bin/bash\nexit 0\n")
  capture = 'import json, os, sys\nfrom pathlib import Path\nPath(os.environ["SUNSHINE_TEST_LOG"]).write_text(json.dumps(sys.argv[1:]))\n'
  executable("omarchy-cmd-browser-handoff", '#!/usr/bin/python3\n' + capture + 'sys.exit(int(os.environ["SUNSHINE_TEST_HANDOFF"]))\n')
  executable("setsid", '#!/usr/bin/python3\n' + capture)
  for name, command in (("google-chrome-sunshine-test", "google-chrome-stable"), ("chromium", "chromium")):
    (applications / (name + ".desktop")).write_text("[Desktop Entry]\nExec=" + command + " %U\n")

  icon = scratch / "sunshine.png"
  icon.write_bytes(b"fixture icon")
  script = declarations.replace("$HOME", "${SUNSHINE_TEST_HOME}")
  script += '\nSUNSHINE_ICON_SOURCE="$1"\ninstall_admin_webapp\n$SUNSHINE_ADMIN_EXEC\n'
  run("bash", "-c", script, "sunshine-admin-fixture", str(icon))
  desktop = applications / "Sunshine Admin.desktop"
  generated = desktop.read_text()
  exec_line = next(line[5:] for line in generated.splitlines() if line.startswith("Exec="))
  assert shlex.split(exec_line) == ["omarchy-launch-webapp", "https://localhost:47990"]
  log = scratch / "launch.json"
  assert json.loads(log.read_text()) == ["uwsm-app", "--", "google-chrome-stable", "--app=https://localhost:47990"]
  print("ok - Sunshine shortcut and initial launch preserve certificate validation")

  for browser, executable_name in (("google-chrome-sunshine-test.desktop", "google-chrome-stable"), ("firefox.desktop", "chromium")):
    environment["SUNSHINE_TEST_BROWSER"] = browser
    for handoff in ("0", "1"):
      environment["SUNSHINE_TEST_HANDOFF"] = handoff
      for url in ("https://localhost:47990", "https://example.com"):
        run("omarchy-launch-webapp", url)
        expected = [executable_name, "--app=" + url]
        if handoff == "1":
          expected = ["uwsm-app", "--"] + expected
        assert json.loads(log.read_text()) == expected
  print("ok - running/new browser launches and normal webapps receive only their expected URL")

  migration = scratch / "migration.sh"
  migration.write_text((root / "migrations/1791640217.sh").read_text().replace("$HOME", "${SUNSHINE_TEST_HOME}"))
  old = generated.replace(exec_line, exec_line + " --ignore-certificate-errors")
  for icon_name in ("sunshine-admin", "logo-sunshine-45"):
    legacy = old.replace("Icon=sunshine-admin", "Icon=" + icon_name)
    desktop.write_text(legacy)
    desktop.chmod(0o755)
    output = run("bash", "-euo", "pipefail", str(migration)).stdout
    assert "Fully quit the browser" in output
    assert desktop.read_text() == legacy.replace(" --ignore-certificate-errors", "")
    assert desktop.stat().st_mode & 0o777 == 0o755
    repaired = desktop.read_bytes()
    run("bash", "-euo", "pipefail", str(migration))
    assert desktop.read_bytes() == repaired
  print("ok - both generated icon variants migrate idempotently and retain executable permissions")

  for custom in (old + "# User customization\n", old.replace("localhost", "host.local"),
      old.replace("Icon=sunshine-admin", "Icon=custom-icon"),
      old.replace(" --ignore-certificate-errors", " --ignore-certificate-errors --profile-directory=Work")):
    desktop.write_text(custom)
    run("bash", "-euo", "pipefail", str(migration))
    assert desktop.read_text() == custom
  desktop.unlink()
  target = scratch / "custom.desktop"
  target.write_text(old)
  desktop.symlink_to(target)
  run("bash", "-euo", "pipefail", str(migration))
  assert desktop.is_symlink() and target.read_text() == old
  desktop.unlink()
  run("bash", "-euo", "pipefail", str(migration))
  assert not desktop.exists()
  print("ok - custom, symlinked, and absent Sunshine shortcuts remain untouched")
PY
