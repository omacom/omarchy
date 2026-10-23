echo "Regenerate mise wrappers that can recurse through PATH when a tool is missing"

# omarchy-mise-install stubs used `mise x … -- bin`, which falls back to PATH
# when the tool does not provide that binary. The stub lives on PATH, so a
# missing tool re-executes itself until the machine stalls (#13177). New stubs
# resolve and execute an absolute tool path; rewrite every generated wrapper
# still on the old quiet template.

unguarded_quiet_template() {
  local package=$1 bin=$2

  printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"' \
    "$package" "$package" "$bin"
}

bin_dir="$HOME/.local/bin"

[[ -d $bin_dir ]] || exit 0

for wrapper in "$bin_dir"/*; do
  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || continue

  # A generated wrapper is a few short lines. ~/.local/bin also holds real
  # binaries, so check the size before reading rather than pulling a large
  # executable into memory to discover it is not a wrapper.
  (($(stat -c%s "$wrapper") <= 1024)) || continue

  contents=$(<"$wrapper")

  package=$(sed -n 's/^mise use -g --quiet "\(.*\)" || exit 1$/\1/p' <<<"$contents")
  bin=$(sed -n 's/^exec mise x ".*" -- "\(.*\)" "\$@"$/\1/p' <<<"$contents")

  [[ -n $package && -n $bin ]] || continue

  # Exact match only: a wrapper someone has edited is left alone, and one that
  # already carries the re-entry guard matches nothing here.
  [[ $contents == "$(unguarded_quiet_template "$package" "$bin")" ]] || continue

  omarchy-mise-install "$package" "${wrapper##*/}" "$bin"
done
