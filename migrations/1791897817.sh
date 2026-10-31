echo "Move Docker's bridge and host DNS stub off 172.17.0.1, an address home routers use too"

# Docker's bridge, the containers' DNS server and a systemd-resolved stub
# listener all sat on 172.17.0.1. resolved refuses an upstream server that
# matches one of its own listeners, so a router at 172.17.0.1 could not be used
# for DNS ("Configured DNS server loops back to us"), Docker running or not. The
# package update has already moved daemon.json and the resolved drop-in to
# 172.30.0.1, unless their owner edited them. What is left is those edited
# copies, the firewall rules that let containers reach the stub, and a resolved
# restart so it stops listening on the old address.

machine_marker="${OMARCHY_DOCKER_DNS_MARKER:-/var/lib/omarchy/migrations/1791897817}"
docker_config="${OMARCHY_DOCKER_DNS_DAEMON_JSON:-/etc/docker/daemon.json}"
resolved_dropin="${OMARCHY_DOCKER_DNS_RESOLVED_DROPIN:-/etc/systemd/resolved.conf.d/20-docker-dns.conf}"
old_gateway=172.17.0.1
new_gateway=172.30.0.1

# The firewall and resolved are machine-wide, so the first account to run this
# does it for everyone.
[[ ! -e $machine_marker ]] || exit 0

# pacman leaves a .pacnew beside an edited copy instead of replacing it, so it
# still names the old address, and Docker and resolved would disagree about
# where container DNS lives. Move only the values that are still the old ones.
if [[ -f $docker_config ]] && grep -qE "\"${old_gateway//./\\.}(/16)?\"" "$docker_config"; then
  if moved=$(jq --arg old "$old_gateway" --arg new "$new_gateway" '
    if (.dns | type) == "array" then .dns |= map(if . == $old then $new else . end) else . end |
    if .bip == "\($old)/16" then .bip = "\($new)/16" else . end' "$docker_config"); then
    sudo tee "$docker_config" >/dev/null <<<"$moved"
  else
    echo "Could not read $docker_config: point its dns and bip at $new_gateway by hand"
  fi
fi

stub_line="^[[:space:]]*DNSStubListenerExtra[[:space:]]*=[[:space:]]*${old_gateway//./\\.}[[:space:]]*\$"
if [[ -f $resolved_dropin ]] && grep -qE "$stub_line" "$resolved_dropin"; then
  sudo sed -i -E "s/$stub_line/DNSStubListenerExtra=$new_gateway/" "$resolved_dropin"
fi

if omarchy-cmd-present ufw; then
  added=$(sudo ufw show added)

  # Only the rules install/config/firewall.sh added are moved. A machine whose
  # owner deleted them does not get them back. The new rule goes in before the
  # old one comes out, so an interrupted run still finds the old rule next time.
  for source in 172.16.0.0/12 192.168.0.0/16; do
    if grep -qxF "ufw allow from $source to $old_gateway port 53 proto udp comment 'allow-docker-dns'" <<<"$added"; then
      sudo ufw allow in proto udp from "$source" to "$new_gateway" port 53 comment 'allow-docker-dns' >/dev/null
      sudo ufw delete allow in proto udp from "$source" to "$old_gateway" port 53 comment 'allow-docker-dns' >/dev/null
    fi
  done
fi

sudo systemctl try-restart systemd-resolved.service

# Docker reads bip and dns only when it starts, and restarting it here would
# stop running containers. It is socket-activated, so usually it is not running
# and the next start picks up the new bridge. A running one keeps handing its
# containers the old address, which no longer answers.
if systemctl is-active --quiet docker.service; then
  echo "Containers have no DNS until Docker restarts onto $new_gateway: sudo systemctl restart docker"
fi

sudo install -Dm644 /dev/null "$machine_marker"
