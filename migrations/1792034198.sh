echo "Install Devin CLI coding agent mise wrapper"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]] && omarchy-cmd-missing devin; then
  omarchy-mise-install "http:devin[platforms_linux_x64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-x86_64-unknown-linux.tar.gz,platforms_linux_arm64_url=https://static.devin.ai/cli/{{ version }}/devin-{{ version }}-aarch64-unknown-linux.tar.gz,bin_path=bin,version_list_url=https://static.devin.ai/cli/current/manifest.json,version_json_path=.version]" devin
fi
