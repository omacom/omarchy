# Shared paths for the distro-managed NetClaw installation.
netclaw_dir="$HOME/.local/share/omarchy/netclaw"
netclaw_state="$HOME/.local/state/omarchy/netclaw"
netclaw_python="$HOME/.local/share/omarchy/netclaw-python"
export NETCLAW_RUNTIME=openclaw
export NETCLAW_PY="$netclaw_python/bin/python3"
export NETCLAW_VENV="$netclaw_python"
export PATH="$netclaw_python/bin:$HOME/.local/bin:$PATH"

# Adapter fixes can ship without changing the upstream NetClaw source pin.
netclaw_integration_revision() {
  (
    cd "$OMARCHY_PATH" || exit 1
    sha256sum bin/omarchy-netclaw-setup default/netclaw/*.sh default/netclaw/*.py default/netclaw/*.mjs default/netclaw/*.yaml | sha256sum | cut -d ' ' -f 1
  )
}
