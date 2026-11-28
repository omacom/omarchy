echo "Point git's GitHub credentials at the packaged gh"

# gh auth setup-git writes gh's own path into git's config. Once gh moved from
# mise to the github-cli package, a path into mise's installs is gone, and git
# can no longer push over HTTPS. A logged-in gh writes its packaged path
# instead; without a login there is nothing to point at, so the stale lines go.
stale='/mise/installs/gh/'
if git config --global --get-regexp '^credential\..*\.helper$' 2>/dev/null | grep -q "$stale"; then
  if omarchy-cmd-present gh && gh auth status >/dev/null 2>&1; then
    gh auth setup-git
  else
    for host in https://github.com https://gist.github.com; do
      git config --global --unset-all "credential.$host.helper" "$stale" || (( $? == 5 ))
    done
  fi
fi
