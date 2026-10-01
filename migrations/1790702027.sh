echo "Regenerate mise wrappers so they stop recursing under a reduced environment"

# omarchy-mise-install now resolves the wrapped bin with `mise which` before
# handing it to `mise x`. Looked up by name, `mise x` can find the wrapper
# itself again whenever the wrapper runs with an activated PATH but without the
# variables `mise activate` exports, and then it loops until something kills
# it. Rewrite the wrappers on disk through omarchy-mise-install so the template
# stays in one place.

# The form omarchy-mise-install wrote before this change, rebuilt from the
# package and bin the file itself names.
stale_template() {
  local package=$1 bin=$2

  printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"' "$package" "$package" "$bin"
}

bin_dir="$HOME/.local/bin"

[[ -d $bin_dir ]] || exit 0

for wrapper in "$bin_dir"/*; do
  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || continue

  # A generated wrapper is a few short lines, and ~/.local/bin also holds real
  # binaries, so skip anything larger before reading it.
  (($(stat -c%s "$wrapper") <= 1024)) || continue

  contents=$(<"$wrapper")

  package=$(sed -n 's/^mise use -g --quiet "\(.*\)" || exit 1$/\1/p' <<<"$contents")
  bin=$(sed -n 's/^exec mise x ".*" -- "\(.*\)" "\$@"$/\1/p' <<<"$contents")

  [[ -n $package && -n $bin ]] || continue

  # Only an exact match is regenerated. A wrapper someone has edited keeps its
  # edits, and one already on the new template matches nothing here, which is
  # what makes re-running this a no-op.
  [[ $contents == "$(stale_template "$package" "$bin")" ]] || continue

  omarchy-mise-install "$package" "${wrapper##*/}" "$bin"
done
