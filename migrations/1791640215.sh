echo "Let generated mise launchers respect the configured release-age policy"

# Only the exact current Omarchy template belongs to us. Preserve symlinks,
# custom launchers and modified wrappers, including intentional age overrides.
bin_dir="$HOME/.local/bin"
[[ -d $bin_dir ]] || exit 0

for wrapper in "$bin_dir"/*; do
  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || continue
  (($(stat -c%s "$wrapper") <= 1024)) || continue
  contents=$(<"$wrapper")
  package=$(sed -n 's/^mise use -g --quiet "\([^"$`\\]*\)" || exit 1$/\1/p' <<<"$contents")
  bin=$(sed -n 's/^exec mise x "[^"$`\\]*" -- "\([^"$`\\]*\)" "\$@"$/\1/p' <<<"$contents")
  [[ -n $package && -n $bin ]] || continue

  printf -v expected '#!/bin/bash\nexport MISE_MINIMUM_RELEASE_AGE=0\nmise use -g --quiet "%s" || exit 1\nexec mise x "%s" -- "%s" "$@"' "$package" "$package" "$bin"
  [[ $contents == "$expected" ]] || continue
  omarchy-mise-install "$package" "${wrapper##*/}" "$bin"
done
