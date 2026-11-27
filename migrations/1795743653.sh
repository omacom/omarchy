echo "Point git's retired gh shim credentials at the packaged gh"

# The earlier repair covered versioned mise installs. A new migration also
# reaches users who completed that repair with a stale shim still configured.
stale="/mise/shims/gh([[:space:]\"']|$)"
if git config --global --get-regexp '^credential\.https://(github\.com|gist\.github\.com)\.helper$' 2>/dev/null | grep -qE "$stale"; then
  if omarchy-cmd-present gh && gh auth status >/dev/null 2>&1; then
    gh auth setup-git
  else
    for host in https://github.com https://gist.github.com; do
      git config --global --unset-all "credential.$host.helper" "$stale" || (( $? == 5 ))
    done
  fi
fi
