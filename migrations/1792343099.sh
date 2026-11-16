echo "Leave Node to Omarchy's mise declaration instead of the user's config"

# Setup used to write `node = "latest"` into the user's mise config. Node now
# ships as a lazy default in /etc/mise/conf.d, and that entry would outrank it.
# Drop only the exact latest request, since a pinned version is the user's
# choice, and keep the install for the declaration to reuse. After an opt-out
# the entry is what still provides Node, so it stays.
if omarchy-mise-default-tools declares node; then
  mise unuse -g --no-prune node@latest
fi
