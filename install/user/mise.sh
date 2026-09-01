# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

mise reshim --system
# Cursor's own installer links the same path, so a re-provision keeps it.
omarchy-cmd-missing cursor-agent && omarchy-mise-install cursor-agent
omarchy-mise-install github:basecamp/basecamp-cli basecamp
# The calls above leave cold tools uninstalled. This call can fail:
# non-zero when Hermes Desktop owns Hermes but has not finished setting it up,
# and this leaf is sourced under `bash -eE`, so that would abort the rest of
# omarchy-provision-user -- the default browser, the mailto handler and the
# finalize-user marker all come after it.
omarchy-install-hermes-cli || true
if omarchy-cmd-missing muse; then
  omarchy-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse
fi
