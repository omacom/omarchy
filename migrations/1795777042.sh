echo "Remove the Image Viewer launcher, now that Omaview has replaced imv"

# 1794774234 kept a copy the user had changed or linked, but imv went with it,
# so the launcher goes too, changed or not. Omaview opens those files now.
applications="$HOME/.local/share/applications"
rm -f "$applications/imv.desktop"
if [[ -d $applications ]]; then
  update-desktop-database "$applications"
fi
