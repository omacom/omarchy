echo "Move development containers to rootless Docker"

migration_uid=$(id -u)
migration_user=$(id -un)
if (( migration_uid == 0 )); then
  echo "Run this migration as the desktop user" >&2
  exit 1
fi

export XDG_RUNTIME_DIR="/run/user/$migration_uid"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
if ! systemctl --user show-environment >/dev/null; then
  echo "Log in as $migration_user and rerun omarchy-migrate. Rootful Docker has not been changed." >&2
  exit 1
fi

remove_legacy_docker_group() {
  if id -nG "$migration_user" | grep -qw docker; then
    sudo /usr/bin/gpasswd -d "$migration_user" docker >/dev/null
    omarchy-state set reboot-required
  fi
}

# A second invocation by the same account could otherwise race destination
# creation and let one rollback disturb the other's transfer.
exec {migration_lock_fd}>"$XDG_RUNTIME_DIR/omarchy-rootless-docker-migration.lock"
if ! /usr/bin/flock -n "$migration_lock_fd"; then
  echo "Another rootless Docker migration is already running for $migration_user." >&2
  exit 1
fi

target_was_active=0
if systemctl --user is-active --quiet docker.service; then
  target_was_active=1
fi

omarchy-pkg-add docker-rootless-extras rootlesskit slirp4netns fuse-overlayfs

# Allocate a nonoverlapping subordinate-ID range before the rootless daemon can
# open its store. The root lock also serializes simultaneous user migrations.
sudo /usr/bin/bash -euo pipefail -c '
  # This absolute path is intentional: privileged migration code must come
  # from the root-owned package tree, never a caller-controlled checkout.
  source /usr/share/omarchy/install/helpers/rootless-docker.sh
  rootless_docker_ensure_subids "$1"
' bash "$migration_user"

rootless_state="$HOME/.local/state/omarchy/rootless-docker"
machine_state=/var/lib/omarchy/rootless-docker
migrator="$OMARCHY_PATH/default/docker/rootless/migrate.py"
machine_migration_complete=0
if sudo /usr/bin/test -f "$machine_state/enabled"; then
  machine_migration_complete=1
fi
mkdir -p "$HOME/.config/docker" "$rootless_state"
if [[ ! -e $HOME/.config/docker/daemon.json ]]; then
  install -m 0644 "$OMARCHY_PATH/config/docker/daemon.json" "$HOME/.config/docker/daemon.json"
fi

# An active rootless daemon can already host unrelated development workloads.
# Prove its live policy before touching the unit when this account will migrate
# the shared rootful store; a rejected migration must not restart those apps.
if (( target_was_active == 1 && machine_migration_complete == 0 )); then
  if ! /usr/bin/python3 "$migrator" --check-target-policy; then
    echo "The active rootless Docker daemon is customized or changed. Its workloads were left running." >&2
    echo "Restore Omarchy's rootless daemon policy or migrate the rootful containers explicitly, then rerun." >&2
    exit 1
  fi
fi

systemctl --user daemon-reload
# A global user-unit enablement would start this daemon for secondary accounts
# before their subordinate IDs and per-user daemon config exist. Enable only
# this initialized account and clear any early start-limit failure. Preserve an
# existing daemon and its workloads; only start a daemon that was inactive.
systemctl --user reset-failed docker.service
systemctl --user enable docker.service
if (( target_was_active == 0 )); then
  systemctl --user start docker.service
fi
target_host="unix://$XDG_RUNTIME_DIR/docker.sock"
if ! /usr/bin/docker --host "$target_host" info >/dev/null; then
  if (( target_was_active == 0 )); then
    systemctl --user stop docker.service >/dev/null 2>&1 || true
  fi
  echo "Rootless Docker did not start. Rootful Docker has not been changed." >&2
  exit 1
fi

# Completion of the shared rootful-store migration is machine-wide. Later
# accounts only need their own rootless daemon and marker; they must never
# inspect or claim the retained recovery copies owned by the first account.
if (( machine_migration_complete == 1 )); then
  remove_legacy_docker_group
  touch "$rootless_state/enabled"
  chmod 0600 "$rootless_state/enabled"
  export DOCKER_HOST="$target_host"
  systemctl --user set-environment DOCKER_HOST="$DOCKER_HOST"
  dbus-update-activation-environment --systemd DOCKER_HOST
  echo "Rootless Docker is ready for $migration_user. The machine-wide rootful recovery store was left untouched."
  exit 0
fi

# Recheck after any start and before the first rootful source operation. If this
# invocation started an incompatible daemon, restore its original inactive
# lifecycle rather than leaving an unexpected user service behind.
if ! /usr/bin/python3 "$migrator" --check-target-policy; then
  if (( target_was_active == 0 )); then
    systemctl --user stop docker.service >/dev/null 2>&1 || true
  fi
  echo "Rootless Docker does not match Omarchy's safe migration policy. Rootful Docker has not been changed." >&2
  exit 1
fi

sudo /usr/bin/systemctl daemon-reload
sudo /usr/bin/systemctl start docker.socket docker.service
listener_verifier=/usr/share/omarchy/default/docker/rootless/rootful-listeners.py

restrict_rootful_socket() {
  local main_pid socket_owner socket_path
  main_pid=$(sudo /usr/bin/systemctl show docker.service --property MainPID --value)
  [[ $main_pid =~ ^[1-9][0-9]*$ ]] || return 1
  socket_path="/proc/$main_pid/root/run/docker.sock"
  if sudo /usr/bin/test -S "$socket_path"; then
    sudo /usr/bin/setfacl -b "$socket_path"
    sudo /usr/bin/chown root:root "$socket_path"
    sudo /usr/bin/chmod 0600 "$socket_path"
  fi
  socket_owner=$(sudo /usr/bin/stat -Lc '%u:%g:%a' "$socket_path")
  if [[ $socket_owner != "0:0:600" ]]; then
    echo "The rootful Docker socket could not be restricted to root. This migration remains pending." >&2
    return 1
  fi
}

verify_rootful_listeners() {
  local main_pid verifier_mode verified_host
  if sudo /usr/bin/test -L "$listener_verifier" || ! sudo /usr/bin/test -f "$listener_verifier"; then
    echo "The packaged rootful Docker listener verifier is not trusted. This migration remains pending." >&2
    return 1
  fi
  verifier_mode=$(sudo /usr/bin/stat -Lc '%u:%g:%a' "$listener_verifier")
  if [[ $verifier_mode != "0:0:644" ]]; then
    echo "The packaged rootful Docker listener verifier is not trusted. This migration remains pending." >&2
    return 1
  fi
  main_pid=$(sudo /usr/bin/systemctl show docker.service --property MainPID --value)
  verified_host=$(sudo /usr/bin/python3 "$listener_verifier" "$main_pid") || return 1
  if [[ ! $verified_host =~ ^unix:///proc/[1-9][0-9]*/root/run/docker\.sock$ ]]; then
    echo "The packaged rootful Docker listener verifier returned an invalid endpoint." >&2
    return 1
  fi
  source_host=$verified_host
  export OMARCHY_ROOTFUL_DOCKER_HOST="$source_host"
}

verify_rootful_socket_unit() {
  local socket_group socket_listen socket_mode socket_user
  socket_user=$(sudo /usr/bin/systemctl show docker.socket --property=SocketUser --value)
  socket_group=$(sudo /usr/bin/systemctl show docker.socket --property=SocketGroup --value)
  socket_mode=$(sudo /usr/bin/systemctl show docker.socket --property=SocketMode --value)
  socket_listen=$(sudo /usr/bin/systemctl show docker.socket --property=Listen --value)
  if [[ $socket_user != "root" || $socket_group != "root" || $socket_mode != "0600" ||
    $socket_listen != "/run/docker.sock (Stream)" ]]; then
    echo "The effective rootful Docker socket unit is not root-only. Remove custom overrides before migration." >&2
    return 1
  fi
}

# Load the packaged socket policy and prevent new unprivileged rootful clients
# before taking the source inventory. Existing accepted connections are closed
# by the daemon restart after every workload has been safely quiesced below.
restrict_rootful_socket
verify_rootful_socket_unit
verify_rootful_listeners
sudo /usr/bin/docker --host "$source_host" info >/dev/null
remove_legacy_docker_group

# Migrate any legacy user-side definition, pin its data into the protected root
# anchors, and rewrite the credential-bearing Compose file to root:root 0600.
# An existing managed VM is recreated through dockerd's own mount namespace
# while its running or stopped lifecycle is preserved.
/usr/bin/omarchy-windows-vm __migration-secure

# A killed runtime-limit probe is journaled before it starts and uses a bounded,
# auto-removing container. Clear any such verified probe before taking the
# machine-wide source inventory so it can never be mistaken for a workload.
/usr/bin/python3 "$migrator" --cleanup-probes
docker_inventory=$(sudo /usr/bin/docker --host "$source_host" ps -a --no-trunc --format '{{.ID}} {{.Names}}' | sort)
container_names=()
windows_id=""
while read -r container_id container_name; do
  [[ -n $container_id ]] || continue
  if [[ $container_name == "omarchy-windows" ]]; then
    windows_id="$container_id"
  else
    container_names+=("$container_name")
  fi
done <<<"$docker_inventory"

# A container is exempt from rootless transfer only when its immutable runtime
# identity matches the Windows VM Omarchy manages through authenticated actions.
if [[ -n $windows_id ]]; then
  /usr/bin/python3 "$migrator" --check-windows "$windows_id"
fi

if (( ${#container_names[@]} )); then
  if ! /usr/bin/python3 "$migrator" --check "${container_names[@]}"; then
    echo "Rootful Docker and its data have been retained. This migration remains pending." >&2
    exit 1
  fi
fi

# The rootful store is machine-wide. Claim it only after this account proves it
# can secure any existing UID-bound Windows VM and migrate the complete source
# inventory. The root lock serializes users that finish preflight together.
sudo /usr/bin/python3 - "$migration_uid" "$migration_user" <<'PY'
import fcntl
import os
from pathlib import Path
import stat
import sys


uid, name = int(sys.argv[1]), sys.argv[2]
root = Path("/var/lib/omarchy/rootless-docker")
root_was_missing = not root.exists()
root.mkdir(mode=0o755, parents=True, exist_ok=True)
metadata = root.lstat()
if not stat.S_ISDIR(metadata.st_mode) or metadata.st_uid != 0 or metadata.st_mode & 0o022:
    raise SystemExit("unsafe rootless Docker machine-state directory")
if root_was_missing:
    parent_fd = os.open(root.parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    try:
        os.fsync(parent_fd)
    finally:
        os.close(parent_fd)
lock_fd = os.open("/run/lock/omarchy-rootless-docker-owner.lock",
                  os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
with os.fdopen(lock_fd, "w") as lock:
    metadata = os.fstat(lock.fileno())
    if not stat.S_ISREG(metadata.st_mode) or metadata.st_uid != 0 or metadata.st_mode & 0o022:
        raise SystemExit("unsafe rootless Docker owner lock")
    fcntl.flock(lock, fcntl.LOCK_EX)
    owner = root / "migration-owner"
    expected = f"{uid}:{name}\n"
    if owner.exists():
        if owner.is_symlink() or owner.read_text() != expected:
            raise SystemExit("another user owns the rootful Docker migration; finish it from that account")
    else:
        temporary = root / f".migration-owner.{os.getpid()}"
        fd = os.open(temporary, os.O_CREAT | os.O_EXCL | os.O_WRONLY | os.O_NOFOLLOW, 0o600)
        with os.fdopen(fd, "w") as output:
            output.write(expected)
            output.flush()
            os.fsync(output.fileno())
        temporary.replace(owner)
        directory_fd = os.open(root, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
PY

if [[ -n $windows_id ]]; then
  windows_arg=$windows_id
else
  windows_arg="-"
fi
/usr/bin/python3 "$migrator" --quiesce-all "$windows_arg" "${container_names[@]}"

# All source restart policies and lifecycle intent are durable before this
# restart. Stopping the daemon closes rootful connections accepted before the
# socket became root-only; those clients cannot reconnect afterward.
verify_rootful_listeners
sudo /usr/bin/systemctl restart docker.service
sudo /usr/bin/systemctl start docker.socket
restrict_rootful_socket
verify_rootful_socket_unit
verify_rootful_listeners

revoked_inventory=$(sudo /usr/bin/docker --host "$source_host" ps -a --no-trunc --format '{{.ID}} {{.Names}}' | sort)
if [[ $revoked_inventory != "$docker_inventory" ]]; then
  echo "Rootful Docker containers changed while access was being revoked. Workloads remain journaled for recovery." >&2
  exit 1
fi

if [[ -n $windows_id ]]; then
  /usr/bin/python3 "$migrator" --check-windows "$windows_id"
  /usr/bin/python3 "$migrator" --restore-windows "$windows_id"
fi

if (( ${#container_names[@]} )); then
  /usr/bin/python3 "$migrator" --check "${container_names[@]}"
  /usr/bin/python3 "$migrator" "${container_names[@]}"
  /usr/bin/python3 "$migrator" --check-completed "${container_names[@]}"
fi

latest_inventory=$(sudo /usr/bin/docker --host "$source_host" ps -a --no-trunc --format '{{.ID}} {{.Names}}' | sort)
if [[ $latest_inventory != "$docker_inventory" ]]; then
  echo "Rootful Docker containers changed during migration. Both stores were retained; review them and rerun." >&2
  exit 1
fi

sudo /usr/bin/touch /var/lib/omarchy/rootless-docker/enabled
sudo /usr/bin/chown root:root /var/lib/omarchy/rootless-docker/enabled
sudo /usr/bin/chmod 0644 /var/lib/omarchy/rootless-docker/enabled
sudo /usr/bin/python3 - <<'PY'
import os


path = "/var/lib/omarchy/rootless-docker/enabled"
descriptor = os.open(path, os.O_RDONLY | os.O_NOFOLLOW)
try:
    os.fsync(descriptor)
finally:
    os.close(descriptor)
directory = os.open(os.path.dirname(path), os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
try:
    os.fsync(directory)
finally:
    os.close(directory)
PY
touch "$rootless_state/enabled"
chmod 0600 "$rootless_state/enabled"

export DOCKER_HOST="$target_host"
systemctl --user set-environment DOCKER_HOST="$DOCKER_HOST"
dbus-update-activation-environment --systemd DOCKER_HOST

echo "Rootless Docker is ready. Rootful development containers remain stopped as recovery copies; Windows stays on authenticated rootful Docker."
