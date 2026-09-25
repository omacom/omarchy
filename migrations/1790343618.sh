echo "Regenerate mise wrappers that exec a bare command name"

# omarchy-mise-install wrappers used to run `exec mise x "<pkg>" -- "<bin>"
# "$@"`, which depends on PATH resolving the bare bin inside mise's sandbox.
# The generator now resolves the tool to an absolute path first
# (`bin_path=$(mise which --tool ...)`) and execs that, so a wrapper keeps
# working when the bin is not on the caller's PATH. Regenerate every wrapper
# still in the previous form through omarchy-mise-install so the template
# stays in one place.

stale_template() {
  local package=$1 bin=$2

  printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"' "$package" "$package" "$bin"
}

bin_dir="$HOME/.local/bin"

[[ -d $bin_dir ]] || exit 0

for wrapper in "$bin_dir"/*; do
  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || continue

  # A generated wrapper is a few short lines. ~/.local/bin also holds real
  # binaries -- uv and uvx land here from the Python dev env -- so check the
  # size before reading rather than pulling a 30MB executable into memory to
  # discover it is not a wrapper.
  (($(stat -c%s "$wrapper") <= 1024)) || continue

  contents=$(<"$wrapper")

  package=$(sed -n 's/^mise use -g --quiet "\(.*\)" || exit 1$/\1/p' <<<"$contents")
  bin=$(sed -n 's/^exec mise x ".*" -- "\(.*\)" "\$@"$/\1/p' <<<"$contents")

  [[ -n $package && -n $bin ]] || continue

  # The whole file has to be the previous form exactly. A wrapper someone has
  # added a line to is left as it is rather than silently regenerated without
  # that line, and one already resolving bin_path matches nothing here, which
  # is what makes re-running this a no-op.
  [[ $contents == "$(stale_template "$package" "$bin")" ]] || continue

  omarchy-mise-install "$package" "${wrapper##*/}" "$bin"
done
