# Regional installs get their region's default packages on first boot with a
# network (bin/omarchy-region-packages); the ISO carries none of them.
region=
[[ -r /etc/omarchy/region ]] && region=$(</etc/omarchy/region)
if [[ $region =~ ^[a-z]{2}$ && -r $OMARCHY_PATH/default/regions/$region/packages-add ]]; then
  install -Dm644 "$OMARCHY_PATH/default/systemd/system/omarchy-region-packages.service" \
    /etc/systemd/system/omarchy-region-packages.service
  systemctl enable omarchy-region-packages.service
fi
