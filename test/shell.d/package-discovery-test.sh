#!/bin/bash

set -euo pipefail
source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PYTHON'
import os
from pathlib import Path
import subprocess
import sys
import tempfile

source = Path(sys.argv[1]) / "test/shell.d/unowned-system-paths-test.sh"
# Run the actual ownership-check block against isolated checkout layouts.
code = source.read_text().split("<<'PYTHON'\n", 1)[1].split("\nPYTHON", 1)[0]
locations = [
  "../omarchy-pkgs/pkgbuilds",
  "../omarchy/omarchy-pkgs/pkgbuilds",
  "../../omarchy-pkgs/pkgbuilds",
  "../omacom/omarchy-pkgs/pkgbuilds",
  "../../omacom/omarchy-pkgs/pkgbuilds",
  "HOME/Work/omacom/omarchy-pkgs/pkgbuilds",
]
for location in locations:
  with tempfile.TemporaryDirectory() as tmp:
    root = Path(tmp) / "projects/checkout"
    (root / "bin").mkdir(parents=True)
    destination = "/usr/share/discovery-regression"
    (root / "bin/write-file").write_text(f"cp source {destination}\n")
    home = Path(tmp) / "home"
    pkgs = home / location.removeprefix("HOME/") if location.startswith("HOME/") else root / location
    (pkgs / "fixture").mkdir(parents=True)
    pkgbuild = pkgs / "fixture/PKGBUILD"
    pkgbuild.write_text(f'install source "$pkgdir{destination}"\n')
    env = dict(os.environ, HOME=str(home))
    env.pop("OMARCHY_PKGS_PATH", None)

    def run(**overrides):
      return subprocess.run(["python3", "-", str(root)], input=code, text=True,
                            capture_output=True, env=dict(env, **overrides))

    result = run()
    assert result.returncode == 0 and "# SKIP" not in result.stdout, (location, result.stdout, result.stderr)
    for override in ("", str(Path(tmp) / "missing")):
      result = run(OMARCHY_PKGS_PATH=override)
      assert result.returncode != 0 and "OMARCHY_PKGS_PATH" in result.stderr, result
    for override in (str(pkgs), str(pkgs.parent)):
      assert run(OMARCHY_PKGS_PATH=override).returncode == 0, override
    pkgbuild.write_text("# package no longer owns the destination\n")
    result = run()
    assert result.returncode != 0 and destination in result.stderr, (location, result.stdout, result.stderr)
    pkgbuild.unlink()
    (pkgs / "fixture").rmdir()
    pkgs.rmdir()
    result = run()
    assert result.returncode == 0 and "# SKIP" in result.stdout, (location, result.stdout, result.stderr)
print("ok - ownership checks discover every conventional checkout and reject invalid overrides")
PYTHON
