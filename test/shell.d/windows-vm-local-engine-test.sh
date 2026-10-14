#!/bin/bash

set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
export PATH="$ROOT/bin:$PATH"

# An empty remote engine must never authorize removal of an active local disk.
# Stub all mount/destructive operations; no real engine or filesystem changes.
export CONTAINER_HOST=unix:///tmp/omarchy-test-remote.sock
USERS_DIR=/fixture/users
CALLER_UID=1000
CALLER_DATA_ROOT="$USERS_DIR/$CALLER_UID"
EXPECTED_STORAGE="$USERS_DIR/$CALLER_UID/storage"
EXPECTED_SHARED="$USERS_DIR/$CALLER_UID/shared"
assert_mounts_safe() { :; }
mount_layer_count() { echo 1; }
mount_descendant_count() { echo 0; }
mounts_ready() { :; }
removal_trees_disjoint() { :; }
deleted=0
find() { [[ $* != *-delete* ]] || deleted=1; }
umount() { :; }
rm() { :; }
rmdir() { :; }
podman-compose() {
  [[ $1 == --podman-path="$ROOT/bin/omarchy-podman-local" ]] || fail "Windows Compose can use a remote engine"
  # Simulate an apparently successful down that left the local container.
  return 0
}
podman() {
  if [[ $1 == --remote=false ]]; then
    shift
    # Local container is still present; removal must refuse to delete its disk.
    [[ $1 != inspect ]] || return 0
  else
    # The unrelated remote is healthy but has no matching Windows container.
    [[ $1 != inspect ]] || return 1
  fi
  return 0
}

__priv_remove 2>/dev/null && fail "empty remote state authorized local Windows disk removal"
(( deleted == 0 )) || fail "local Windows disk was deleted while its container remained"
pass "Windows Compose and removal inspect the local engine despite a remote endpoint"

# Use the real Compose frontend so this catches global options incorrectly
# inserted after a Podman subcommand. Only the engine executable is a fixture.
python3 - <<'PY'
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

provider = shutil.which('podman-compose')
if provider is None:
    print('ok - podman-compose unavailable; skipping real frontend argument ordering')
else:
    with tempfile.TemporaryDirectory() as directory:
        root = Path(directory)
        engine = root / 'podman'
        engine.write_text('''#!/usr/bin/python3
import json, os, sys
with open(os.environ['ENGINE_LOG'], 'a') as log:
    log.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1] != '--remote=false':
    sys.exit('global local-engine option must precede the subcommand')
if sys.argv[2] == '--version':
    print('podman version 6.1.1')
elif sys.argv[2] == 'ps':
    print('[]')
else:
    sys.exit('unexpected engine action')
''')
        engine.chmod(0o755)
        compose = root / 'compose.yml'
        compose.write_text('services:\n  windows:\n    image: docker.io/library/alpine:latest\n')
        log = root / 'engine.jsonl'
        env = dict(os.environ, HOME=str(root), ENGINE_LOG=str(log), COMPOSE_FIXTURE=str(compose),
                   PATH=f"{root}:{os.environ['ROOT']}/bin:{os.environ['PATH']}",
                   CONTAINER_HOST='unix:///nonexistent/remote.sock', CONTAINER_CONNECTION='unavailable')
        result = subprocess.run(['/bin/bash', '-c', '''
set -- help
source "$ROOT/bin/omarchy-windows-vm" >/dev/null
COMPOSE_FILE=$COMPOSE_FIXTURE
dc ps
'''], env=env, capture_output=True, text=True, timeout=20)
        assert result.returncode == 0, (result.stdout, result.stderr)
        calls = [json.loads(line) for line in log.read_text().splitlines()]
        assert any(call[1] == 'ps' for call in calls), calls
        assert all(call[0] == '--remote=false' for call in calls), calls
        print('ok - real Compose frontend places the local-engine option before every subcommand')
PY
