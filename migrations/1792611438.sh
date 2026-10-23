echo "Replace the leftover Kimi mise wrapper with its lazy shim"

# 1791382872 retired every omarchy-mise-install wrapper except Kimi's, which
# 1786967403 installed. The wrapper shadows the lazy shim and writes a
# `latest` request into the user's config that outranks Omarchy's declaration.
# Migrations stop at the first failure, so 1791382872 has already created the
# shims. A user who removed the preinstalls lost the wrapper with them.
package="npm:@moonshot-ai/kimi-code"
wrapper="$HOME/.local/bin/kimi"

if [[ ! -f $HOME/.local/state/omarchy/preinstalls-removed ]]; then
  # Only the exact wrapper omarchy-mise-install wrote, so a customized or
  # user-owned launcher at the same path stays.
  if [[ -f $wrapper && ! -L $wrapper ]] &&
    cmp -s "$wrapper" <(printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "kimi" "$@"\n' "$package" "$package"); then
    # Drop only the request this wrapper wrote; without the wrapper, a latest
    # request is the user's own. Keep the install for the declaration to reuse.
    # Dropped before the wrapper goes, so a failed or interrupted run finds the
    # wrapper again and retries instead of leaving the request behind.
    mise unuse -g --no-prune "$package@latest"
    rm -f "$wrapper"
  fi
fi
