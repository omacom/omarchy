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
omarchy-mise-install grok
omarchy-mise-install npm:@moonshot-ai/kimi-code kimi
omarchy-mise-install npm:@qwen-code/qwen-code qwen
# Pinned: every DSH release so far is a prerelease, which mise's npm backend skips.
omarchy-mise-install npm:@deepseek-ai/dsh@0.2.0-rc.2 dsh
omarchy-mise-install "npm:@minimax-ai/code[allow_builds=better-sqlite3]" mcode
omarchy-mise-install aqua:aaif-goose/goose goose
omarchy-mise-install "http:kiro-cli[platforms_linux_x64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-x86_64-linux.tar.gz,platforms_linux_arm64_url=https://prod.download.cli.kiro.dev/stable/{{version}}/kirocli-aarch64-linux.tar.gz,version_list_url=https://prod.download.cli.kiro.dev/stable/latest/manifest.json,version_json_path=.version]" kiro-cli
omarchy-mise-install "github:mistralai/mistral-vibe[matching=vibe-linux]" vibe
omarchy-mise-install npm:freebuff freebuff
omarchy-mise-install github:zeroclaw-labs/zeroclaw zeroclaw
omarchy-mise-install npm:@kilocode/cli kilo
omarchy-mise-install "http:devin[platforms_linux_x64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-x86_64-unknown-linux.tar.gz,platforms_linux_arm64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-aarch64-unknown-linux.tar.gz,bin_path=bin,version_list_url=https://static.devin.ai/cli/current/manifest.json,version_json_path=.version]" devin
omarchy-mise-install npm:command-code commandcode
omarchy-mise-install github:phantomyard/phantombot phantombot
omarchy-mise-install amp
omarchy-mise-install cursor-agent
omarchy-mise-install npm:@kitlangton/ghui ghui
omarchy-mise-install aqua:modem-dev/hunk hunk
omarchy-mise-install github:basecamp/hey-cli hey
omarchy-mise-install github:basecamp/basecamp-cli basecamp
omarchy-mise-install npm:cf cf
omarchy-mise-install github:OpenRouterLabs/ori-releases ori
omarchy-mise-install "http:muse[url=https://api.meta.ai/muse-launcher.sh,bin=muse,version_list_url=https://api.meta.ai/muse-code/channels/muse-stable,version_json_path=.version]" muse

# Build the account dispatchers declared by /etc/mise/conf.d.
mise reshim
