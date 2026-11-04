# Build the lazy shims for Omarchy's default tools and the account dispatchers,
# both declared by /etc/mise/conf.d, without resolving versions over the network.
# Offline, every `latest` declaration warns that it found no versions, yet the
# shims are made all the same, so --quiet keeps that noise out of the install log.
MISE_OFFLINE=true mise reshim --system --quiet
MISE_OFFLINE=true mise reshim --quiet
