#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command python3

python3 - "$ROOT" <<'PY'
import os
import runpy
import stat
import sys
import tempfile
from pathlib import Path

repo = Path(sys.argv[1])
for agent in ("claude", "codex"):
  with tempfile.TemporaryDirectory() as scratch:
    fixture = Path(scratch)
    os.environ["XDG_CACHE_HOME"] = str(fixture / "cache")
    root = fixture / "cache" / "omarchy" / "agent-usage"
    root.mkdir(parents=True)
    root.chmod(0o755)
    ordinary = root / "old-cache.json"
    ordinary.write_text("{}")
    ordinary.chmod(0o644)
    outside = fixture / "unrelated-file"
    outside.write_text("unchanged")
    outside.chmod(0o644)
    (root / "linked-cache.json").symlink_to(outside)
    (root / "dangling-cache.json").symlink_to(fixture / "absent")
    collector = runpy.run_path(str(repo / "bin" / f"omarchy-agent-usage-{agent}"))
    assert collector["cache_root"]() == root
    assert stat.S_IMODE(root.stat().st_mode) == 0o700
    assert stat.S_IMODE(ordinary.stat().st_mode) == 0o600
    assert stat.S_IMODE(outside.stat().st_mode) == 0o644
    assert outside.read_text() == "unchanged"
    assert (root / "linked-cache.json").is_symlink()
    assert (root / "dangling-cache.json").is_symlink()
PY
pass "usage collectors clamp cache files without chmodding symlink targets"
