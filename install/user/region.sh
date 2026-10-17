# A regional install points this user's developer tools at the region's
# registries; the installer wrote the marker before finalization.
region=
[[ -r /etc/omarchy/region ]] && read -r region </etc/omarchy/region
if [[ $region == "cn" ]]; then
  "$OMARCHY_PATH/bin/omarchy-region-user" cn
fi
