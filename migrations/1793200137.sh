echo "Remove old versions of Omarchy's mise tools"

# Upgrade pruning was off, so every agent CLI auto_update left its previous
# version installed. mise removes what upgrades replace from now on; this
# clears what piled up before. Only Omarchy's declared tools are pruned, and
# mise keeps any version a config, a tool stub or a running process still uses.
omarchy-cmd-present mise || exit 0

mapfile -t tools < <(omarchy-mise-default-tools list)
(( ${#tools[@]} )) || exit 0

# Naming no tools would prune every tool, which the check above rules out.
if ! mise prune --tools --yes "${tools[@]}"; then
  echo "Could not remove old versions of Omarchy's mise tools"
fi
