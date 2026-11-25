echo "Point git's GitHub credentials at the packaged gh"

# gh auth setup-git writes gh's own path into git's config. Once gh moved from
# mise to the github-cli package, a path into mise's installs is gone, and git
# can no longer push over HTTPS, so write the packaged gh's path instead.
if git config --global --get-regexp '^credential\..*\.helper$' 2>/dev/null | grep -q '/mise/installs/gh/' &&
  omarchy-cmd-present gh; then
  gh auth setup-git || true
fi
