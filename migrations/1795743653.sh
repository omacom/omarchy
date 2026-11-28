echo "Point git's retired gh shim credentials at the packaged gh"

# A user-owned mise gh keeps its shim and must keep its credential helper.
shim="${MISE_SHIMS_DIR:-${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims}/gh"
shim_pattern=$(printf '%s' "$shim" | sed 's/[][\\.^$*+?(){}|]/\\&/g')
stale="(/mise/shims/gh|$shim_pattern)([[:space:]\"']|$)"
if [[ ! -e $shim ]] &&
  git config --global --get-regexp '^credential\.https://(github\.com|gist\.github\.com)\.helper$' 2>/dev/null | grep -qE "$stale"; then
  if omarchy-cmd-present gh && gh auth status >/dev/null 2>&1; then
    gh auth setup-git
  else
    for host in https://github.com https://gist.github.com; do
      git config --global --unset-all "credential.$host.helper" "$stale" || (( $? == 5 ))
    done
  fi
fi
