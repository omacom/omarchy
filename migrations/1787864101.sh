echo "Enable docker.service so Install > Docker DB containers survive reboot"

omarchy-cmd-present docker || exit 0

if systemctl is-enabled docker.service >/dev/null 2>&1; then
  exit 0
fi

# Docker switched off entirely has nothing to bring back, and docker info below
# would fail on every update and hold up every migration queued after this one.
if ! systemctl is-enabled docker.socket >/dev/null 2>&1; then
  exit 0
fi

# docker info talks to the socket, which is enough to start dockerd for the query.
# Let a cancelled sudo or a down dockerd fail the script so omarchy-migrate
# leaves this pending instead of marking it complete.
sudo docker info >/dev/null

# Keep query errors distinct from successfully finding no database containers.
containers=$(sudo docker container ls --all --format '{{.Names}}')

found=0
# postgres16 and postgres17 are the names earlier installers used.
for name in mysql8 postgres16 postgres17 postgres18 mariadb11 redis mongodb mssql; do
  if grep -Fxq -- "$name" <<<"$containers"; then
    found=1
    break
  fi
done

(( found )) || exit 0

sudo systemctl enable --now docker.service
