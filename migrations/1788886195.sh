echo "Replace Docker with Podman and enable rootless containers"

# sudo-run upgrades drop the session environment when returning to this user.
# Pin the local user runtime before Podman opens its database or Docker changes.
migration_uid=$(id -u)
if (( migration_uid == 0 )); then
  echo "Run the migration as the desktop user" >&2
  exit 1
fi
export XDG_RUNTIME_DIR="/run/user/$migration_uid"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
if ! systemctl --user show-environment >/dev/null; then
  echo "Log in as $USER and rerun omarchy-migrate. Docker has not been changed." >&2
  exit 1
fi

# Pacman resolves virtual providers too. A failed package database query must
# not turn an installed engine into an apparently empty machine.
if ! docker_provider=$(pacman -Qq docker 2>/dev/null); then
  pacman -Qq >/dev/null
  docker_provider=""
fi

# Validate existing grants and allocate safe ranges before any engine work.
sudo python3 "$OMARCHY_PATH/default/podman/allocate-subids.py" "$USER"

omarchy-pkg-add podman podman-compose
if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  omarchy-pkg-add podman-desktop podman-tui
fi

# Check every workload before stopping any. Windows keeps its external disk;
# compatible unprivileged containers transfer their images and volumes rootlessly.
docker_installed=0
container_names=()
# Only the Podman shim is already migrated. Alternate real engines need the
# same workload inventory and verification before their provider is replaced.
if [[ -n $docker_provider && $docker_provider != "podman-docker" ]]; then
  docker_installed=1
  sudo systemctl start docker.socket
  docker_inventory=$(sudo docker --host unix:///var/run/docker.sock ps -a --no-trunc --format '{{.ID}} {{.Names}}' | sort)
  docker_names=$(printf '%s\n' "$docker_inventory" | awk '{print $2}')
  if printf '%s\n' "$docker_names" | grep -qx omarchy-windows; then
    sudo python3 "$OMARCHY_PATH/default/podman/migrate-windows.py" --check "$USER"
  fi
  mapfile -t container_names < <(printf '%s\n' "$docker_names" | sed '/^omarchy-windows$/d; /^$/d')
  if ! python3 "$OMARCHY_PATH/default/podman/migrate-databases.py" --check "${container_names[@]}"; then
    echo "Docker and its data have been retained. This migration remains pending." >&2
    exit 1
  fi
fi


podman --remote=false info >/dev/null
if ((docker_installed)); then
  python3 "$OMARCHY_PATH/default/podman/migrate-databases.py" "${container_names[@]}"
  if printf '%s\n' "$docker_names" | grep -qx omarchy-windows; then
    sudo python3 "$OMARCHY_PATH/default/podman/migrate-windows.py" --stop "$USER"
  fi
  # A long transfer is not a lock on the Docker daemon. Confirm every completed
  # source still matches its receipt, and catch added/replaced/renamed containers
  # before retiring the engine. Any change keeps the migration pending.
  python3 "$OMARCHY_PATH/default/podman/migrate-databases.py" --check-completed "${container_names[@]}"
  latest_inventory=$(sudo docker --host unix:///var/run/docker.sock ps -a --no-trunc --format '{{.ID}} {{.Names}}' | sort)
  if [[ $latest_inventory != "$docker_inventory" ]]; then
    echo "Docker containers changed during migration. Docker and its data have been retained; rerun after reviewing both engines." >&2
    exit 1
  fi
  # Keep Docker's stopped containers and volume data as recovery copies.
  sudo systemctl disable --now docker.socket docker.service
  # Docker leaves bridge interfaces and netfilter chains behind when stopped.
  # Reboot clears that transient state without flushing administrator rules.
  omarchy-state set reboot-required
fi
sudo systemctl --global enable podman.socket podman-restart.service
systemctl --user enable --now podman.socket
systemctl --user enable podman-restart.service

# Packages provide the default for future sessions. Refresh activation for apps
# launched now, while preserving an explicitly configured Docker endpoint.
systemctl --user daemon-reload
if [[ -n $docker_provider && -z ${DOCKER_CONTEXT:-} ]]; then
  export DOCKER_HOST="${DOCKER_HOST:-unix://$XDG_RUNTIME_DIR/podman/podman.sock}"
  dbus-update-activation-environment --systemd DOCKER_HOST
fi

# Replace only Omarchy's Docker DNS rules, leaving unrelated firewall policy.
ufw_available=0
if omarchy-cmd-present ufw; then
  ufw_available=1
  sudo ufw --force delete allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53
  sudo ufw --force delete allow in proto udp from 192.168.0.0/16 to 172.17.0.1 port 53
  sudo ufw allow in on podman+ to any port 53 proto udp comment omarchy-podman-dns
  sudo ufw allow in on podman+ to any port 53 proto tcp comment omarchy-podman-dns
  sudo ufw route allow in on podman+ comment omarchy-podman-egress
fi

# Remove the retired managed block, preserving administrator rules around it.
# Archive it first so a later failure or a deliberate rollback is recoverable.
sudo python3 - <<'PY'
from pathlib import Path
import shutil

for name in ('after.rules', 'after6.rules'):
    path = Path('/etc/ufw') / name
    if not path.exists():
        continue
    contents = path.read_text()
    begin, end = '# BEGIN UFW AND DOCKER', '# END UFW AND DOCKER'
    if begin in contents and end in contents:
        first = contents.index(begin)
        last = contents.index(end, first) + len(end)
        backup = path.with_name(name + '.before-podman')
        if not backup.exists():
            shutil.copy2(path, backup)
        path.write_text(contents[:first] + contents[last:].lstrip('\n'))
PY

if ((ufw_available)) && sudo ufw status | grep '^Status: active' >/dev/null; then
  sudo ufw reload
fi

# Keep the real Docker CLI until all transfers finish. Its replacement also
# provides docker to packages such as once-bin. Replace the engine in the same
# transaction so those dependencies remain satisfied. --ask 4 accepts only
# package-conflict removal, which --noconfirm alone would refuse.
# Native-only users keep compatibility optional, including on a later retry
# after they have deliberately removed the shim.
if [[ -n $docker_provider ]]; then
  sudo pacman -S --needed --noconfirm --ask 4 podman-docker
  omarchy-pkg-drop docker-buildx docker-compose ufw-docker lazydocker lazydocker-bin
fi

# Retired package config may be a .pacsave after the package transaction. Keep
# custom content as inactive backups instead of deleting it.
for retired in /etc/docker/daemon.json \
  /etc/systemd/resolved.conf.d/20-docker-dns.conf \
  /etc/systemd/system/docker.service.d/no-block-boot.conf; do
  if sudo test -f "$retired"; then
    sudo mv --backup=numbered -- "$retired" "$retired.before-podman"
  fi
done
sudo systemctl daemon-reload
sudo systemctl restart systemd-resolved

if id -nG "$USER" | grep -qw docker; then
  sudo gpasswd -d "$USER" docker
  omarchy-state set reboot-required
fi

# Keep the established Windows configuration path and credentials. Only the
# registry qualification changes; storage paths and disk contents stay intact.
if sudo test -f /var/lib/omarchy/windows/docker-compose.yml; then
  sudo sed -i 's|^    image: dockurr/windows$|    image: docker.io/dockurr/windows|' /var/lib/omarchy/windows/docker-compose.yml
  sudo chown root:root /var/lib/omarchy/windows/docker-compose.yml
  sudo chmod 0600 /var/lib/omarchy/windows/docker-compose.yml
fi

rm -f "$HOME/.local/share/applications/Docker.desktop"
if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  install -Dm644 "$OMARCHY_PATH/applications/io.podman_desktop.PodmanDesktop.desktop" "$HOME/.local/share/applications/io.podman_desktop.PodmanDesktop.desktop"
  install -Dm644 "$OMARCHY_PATH/applications/Podman TUI.desktop" "$HOME/.local/share/applications/Podman TUI.desktop"
fi
if [[ -f $HOME/.local/share/applications/windows-vm.desktop ]]; then
  sed -i 's/Windows VM via Docker/Windows VM via Podman/' "$HOME/.local/share/applications/windows-vm.desktop"
fi

echo "Podman is ready. Existing Docker storage remains on disk for recovery."
