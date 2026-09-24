# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

mise reshim --system
# Hermes needs its Python pin and Desktop ownership checks. Leave its custom
# wrapper lazy, and let an unfinished Desktop setup wait until the next launch
# instead of aborting the rest of user finalization.
omarchy-install-hermes-cli || true
