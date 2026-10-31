echo "Invite owners of a supported Dell XPS IR camera to set up face authentication"

# The invitation is installed by first-run, which existing accounts have already
# marked complete, so they would never receive it. Post-update hooks run later in
# this same update; the hook decides whether to notify.
omarchy-hook-install post-update "$OMARCHY_PATH/install/user/first-run/setup-face.hook"
