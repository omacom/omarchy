#!/bin/bash

# Omarchy scripts must not name a fixed, predictable path under /tmp that they
# write through. On a machine where another local account can pre-create such
# a path, a fixed name lets them plant a symlink (so the victim's write
# clobbers a victim file through it) or keep the file readable (so the content
# is disclosed to them). fs.protected_symlinks and fs.protected_regular block
# both variants on default configurations, but those are kernel policy, not a
# property of the script; a private, unpredictable file (mktemp) is safe
# regardless of the host's sysctls.
#
# This is a net, not a proof: it flags every literal /tmp path a script in
# bin/, install/, or migrations/ names, so a new one cannot be introduced
# silently. Paths recorded below are allowed, with the reason. An mktemp
# template (a run of X) is unpredictable by construction and passes, as does a
# path constructed from a variable, which the using script validates itself.

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

python3 - "$ROOT" <<'PYTHON'
import re
import sys
from pathlib import Path

root = Path(sys.argv[1])

# Fixed /tmp paths named in comments (examples and documented attacks); never
# a destination the scripts write through.
allowed = {
    "/tmp/screenshot.png": "example in a usage comment",
    "/tmp/plymouth-preview.png": "example in a usage comment",
    "/tmp/logo.txt": "example in a usage comment",
    "/tmp/evil": "documented attack in a comment",
}

fixed_tmp_path = re.compile(r"/tmp/[A-Za-z0-9._/@+-]*[A-Za-z0-9._@/-]")


def fixed_paths_in(root_dir):
    for base in ("bin", "install", "migrations"):
        for path in sorted((root_dir / base).rglob("*")):
            if not path.is_file():
                continue
            rel = str(path.relative_to(root_dir))
            for number, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
                for match in fixed_tmp_path.finditer(line):
                    candidate = match.group(0)
                    if "XXX" in candidate or candidate in allowed:
                        continue
                    # A path continued by a variable is constructed, not a
                    # fixed literal; scripts using one validate it themselves.
                    if match.end() < len(line) and line[match.end()] == "$":
                        continue
                    yield f"{rel}:{number}: {line.strip()}"


problems = list(fixed_paths_in(root))
if problems:
    print("not ok - fixed /tmp path named in a script:", file=sys.stderr)
    for problem in problems:
        print(f"  {problem}", file=sys.stderr)
    print(
        "Temporary files under /tmp must be unpredictable (mktemp) or in a "
        "validated private directory. Record any legitimate fixed path in "
        "this test's allowlist with its reason.",
        file=sys.stderr,
    )
    sys.exit(1)

print("ok - no fixed /tmp write paths in bin/, install/, migrations/")
PYTHON

pass "scripts name /tmp paths only through unpredictable or validated forms"
