# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

# Build the lazy shims for Omarchy's default tools and the account dispatchers,
# both declared by /etc/mise/conf.d.
mise reshim --system
mise reshim
