# Apply the install's regional app exclusions before refreshing launchers.
region=
[[ -r /etc/omarchy/region ]] && region=$(</etc/omarchy/region)
if [[ $region =~ ^[a-z]{2}$ ]] && ! omarchy-done check finalize-user; then
  "$OMARCHY_PATH/bin/omarchy-region-preinstalls" "$region"
fi
