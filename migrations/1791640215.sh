echo "Regenerate mise wrappers to execute resolved binaries instead of their own PATH entries"

bin_dir="$HOME/.local/bin"
[[ -d $bin_dir ]] || exit 0

for wrapper in "$bin_dir"/*; do
  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || continue
  (($(stat -c%s "$wrapper") <= 1024)) || continue

  contents=$(<"$wrapper")
  package=$(sed -n 's/^mise use -g --quiet "\([^"]*\)" || exit 1$/\1/p' <<<"$contents")
  bin=$(sed -n 's/^exec mise x "[^"]*" -- "\([^"]*\)" "\$@"$/\1/p' <<<"$contents")
  [[ -n $package && -n $bin ]] || continue

  # Earlier pending migrations regenerate pre-quiet wrappers through the current
  # installer. Match the last shipped template exactly; preserve custom scripts.
  expected=$(printf '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"' "$package" "$package" "$bin")
  [[ $contents == "$expected" ]] || continue

  "$OMARCHY_PATH/bin/omarchy-mise-install" "$package" "${wrapper##*/}" "$bin"
done
