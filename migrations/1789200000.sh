echo "Stop mise wrappers from rewriting global config on every run"

# Wrappers used to call `mise use -g` before every exec. That mutates global
# mise state and races when a caller times out mid-install (#11886).
# omarchy-mise-install now pins once at install time and writes an exec-only
# wrapper; rewrite any still-mutating wrappers through it.

bin_dir="$HOME/.local/bin"
[[ -d $bin_dir ]] || exit 0

for wrapper in "$bin_dir"/*; do
  [[ -f $wrapper && ! -L $wrapper && -r $wrapper ]] || continue

  # ~/.local/bin also holds real binaries; skip anything that is not a short
  # shell wrapper. Prefer portable size checks over GNU stat -c.
  size=$(wc -c <"$wrapper" | tr -d ' ')
  (( size <= 1024 )) || continue

  contents=$(<"$wrapper")

  # Only rewrite wrappers that still mutate global config on each run.
  grep -q '^mise use -g' <<<"$contents" || continue

  package=$(sed -n -E \
    -e 's/^mise use -g --quiet "([^"]+)"( \|\| exit 1)?$/\1/p' \
    -e 's/^mise use -g "([^"]+)"( \|\| exit 1)?$/\1/p' \
    <<<"$contents" | head -n1)
  bin=$(sed -n -E \
    -e 's/^exec mise x ".*" -- "([^"]+)" "\$@"$/\1/p' \
    -e 's/^exec mise exec ".*" -- "([^"]+)" "\$@"$/\1/p' \
    -e 's/^exec "([^"]+)" "\$@"$/\1/p' \
    <<<"$contents" | head -n1)

  [[ -n $package && -n $bin ]] || continue

  omarchy-mise-install "$package" "${wrapper##*/}" "$bin"
done
