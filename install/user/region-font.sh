# The installer wrote the region before user finalization; no download is needed.
region=
[[ -r /etc/omarchy/region ]] && region=$(</etc/omarchy/region)
if [[ $region =~ ^[a-z]{2}$ ]]; then
  "$OMARCHY_PATH/bin/omarchy-region-font" "$region"
fi
