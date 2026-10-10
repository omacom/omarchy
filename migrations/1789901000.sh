echo "Repair 1Password polkit owners and MCP setgid after a skipped after-install"

if [[ -d /opt/1Password ]]; then
  omarchy-1password-finish-install
fi
