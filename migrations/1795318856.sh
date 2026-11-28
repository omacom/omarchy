echo "Install Pi as a package instead of a mise tool"

# The settings package drops Pi's mise declaration. Until it has, stay pending:
# the declaration would only install Pi through mise again.
if omarchy-mise-default-tools list | grep -qx pi; then
  echo "Waiting for the omarchy-settings package that drops Pi from the default mise tools" >&2
  exit 75
fi

omarchy-pkg-add pi-coding-agent

# mise's shims come before /usr/bin on PATH, and the shim left by the dropped
# declaration fails rather than falling through to the package. A Pi the user
# declared in a mise config of their own is theirs and stays.
if ! mise ls pi --json | jq -e 'any(.[]; .source)' >/dev/null; then
  mise uninstall --all pi
  mise reshim
fi
