# Development containers run in the install user's rootless daemon. The system
# daemon remains socket-activated for the Windows VM, whose KVM/TUN devices need
# an authenticated rootful boundary.
source "$OMARCHY_INSTALL/helpers/rootless-docker.sh"

if [[ -n ${OMARCHY_INSTALL_USER:-} ]]; then
  rootless_docker_ensure_subids "$OMARCHY_INSTALL_USER"
fi

install -d -m 0755 /var/lib/omarchy/rootless-docker
install -m 0644 /dev/null /var/lib/omarchy/rootless-docker/enabled
