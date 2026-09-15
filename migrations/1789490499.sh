echo "Regenerate mise wrappers that still print mise's output on every run"

# omarchy-mise-install passes --quiet to `mise use -g`, but wrappers written
# before that gained the flag still run the loud form on every invocation, and
# `mise use -g` writes its confirmation to stdout:
#
#   $ gh auth status 2>/dev/null | head -1
#   mise ~/.config/mise/config.toml tools: gh@2.100.0
#
# That corrupts anything reading one of these tools through a pipe. The sharpest
# case is git: with credential.https://github.com.helper set to
# `!gh auth git-credential`, the banner becomes the first line of the credential
# protocol and every HTTPS push fails with "invalid credential line" followed by
# "could not read Username".
#
# Only the shape omarchy-mise-install writes today is matched. The generation
# before it (`exec "<path>" "$@"`) was already converted by 1784909971.sh, and
# migrations are strictly ordered, so it cannot still be on disk here. A wrapper
# whose arguments were %q-escaped rather than double-quoted is left alone as
# well: skipping one is a stale wrapper, misparsing one is a broken command.
for wrapper in "$HOME/.local/bin"/*; do
  [[ -f $wrapper && -x $wrapper ]] || continue

  # Already regenerated, or never ours to begin with.
  grep -q '^mise use -g --quiet ' "$wrapper" && continue
  grep -q '^mise use -g ' "$wrapper" || continue

  package=""
  bin=""
  while IFS= read -r line; do
    if [[ $line =~ ^mise\ use\ -g\ \"([^\"]+)\"(\ \|\|\ exit\ 1)?$ ]]; then
      package=${BASH_REMATCH[1]}
    elif [[ $line =~ ^exec\ mise\ x\ \"[^\"]+\"\ --\ \"([^\"]+)\"\ \"\$@\"$ ]]; then
      bin=${BASH_REMATCH[1]}
    fi
  done <"$wrapper"

  # The package is read back rather than derived from the file name, so specs
  # like npm:@kitlangton/ghui, aqua:modem-dev/hunk and github:can1357/oh-my-pi
  # survive; regenerating from the command name alone would install the wrong
  # thing under the right name.
  if [[ -n $package && -n $bin ]]; then
    omarchy-mise-install "$package" "$(basename "$wrapper")" "$bin"
  fi
done
