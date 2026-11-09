# An upgrade, or a run of omarchy-setup-git, can have set the identity already.
if [[ -z $(git config --global user.name) || -z $(git config --global user.email) ]]; then
  omarchy-provision-first-run-card git
fi
