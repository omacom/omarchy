echo "Scale the Cam Link 4K picture to its virtual camera and bound the relay's memory"

# Only machines that took the Cam Link relay in 1788862626.sh have its settings.
conf=/etc/v4l2-relayd.d/camlink.conf
[[ -f $conf ]] || exit 0

# The relay settings are the user's to tune, so only the source and format as
# shipped are replaced. A source someone already edited carries its own fix.
changed=false
if grep -qx 'VIDEOSRC="v4l2src device=/dev/camlink4k"' "$conf"; then
  videosrc=$(grep -m1 '^VIDEOSRC=' "$OMARCHY_PATH/default/v4l2-relayd/camlink.conf")
  sudo sed -i -e "s|^VIDEOSRC=\"v4l2src device=/dev/camlink4k\"\$|$videosrc|" -e 's/^FORMAT=NV12$/FORMAT=I420/' "$conf"
  changed=true
fi

drop_in=/etc/systemd/system/v4l2-relayd@camlink.service.d/camlink.conf
if ! cmp -s "$OMARCHY_PATH/default/systemd/system/v4l2-relayd@camlink.service.d/camlink.conf" "$drop_in"; then
  sudo install -Dm644 "$OMARCHY_PATH/default/systemd/system/v4l2-relayd@camlink.service.d/camlink.conf" "$drop_in"
  changed=true
fi

if $changed; then
  sudo systemctl daemon-reload
  sudo systemctl try-restart v4l2-relayd@camlink.service
fi
