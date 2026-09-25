# Upgrades must not delete the version a running process is executing from:
# mise up would prune the old install dir out from under a live session.
mise settings set upgrade.auto_prune false

omarchy-mise-install codex
omarchy-mise-install claude
omarchy-mise-install crush
omarchy-mise-install antigravity-cli agy
omarchy-mise-install gh
omarchy-mise-install copilot
omarchy-mise-install opencode
omarchy-mise-install npm:playwright playwright
omarchy-mise-install pi
omarchy-mise-install github:can1357/oh-my-pi omp
omarchy-mise-install npm:@xai-official/grok grok
# Cursor's own installer links the same path, so a re-provision keeps it.
omarchy-cmd-missing cursor-agent && omarchy-mise-install cursor-agent
omarchy-mise-install npm:@kitlangton/ghui ghui
omarchy-mise-install aqua:modem-dev/hunk hunk
omarchy-mise-install github:basecamp/hey-cli hey
omarchy-mise-install github:basecamp/basecamp-cli basecamp
omarchy-mise-install npm:cf cf
omarchy-mise-install github:OpenRouterLabs/ori-releases ori
if omarchy-cmd-missing muse; then
  omarchy-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse
fi
