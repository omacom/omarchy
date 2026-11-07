echo "Restore certificate validation in generated Sunshine Admin shortcuts"

desktop="$HOME/.local/share/applications/Sunshine Admin.desktop"
[[ -f $desktop && ! -L $desktop ]] || exit 0

# Match the complete generated entry, including the fallback icon used when
# Sunshine's packaged icon was unavailable. Leave customized launchers alone.
for icon in sunshine-admin logo-sunshine-45; do
  if cmp -s "$desktop" <(cat <<EOF
[Desktop Entry]
Version=1.0
Name=Sunshine Admin
Comment=Sunshine Admin
Exec=omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors
Terminal=false
Type=Application
Icon=$icon
StartupNotify=true
EOF
  ); then
    sed -i 's|^Exec=omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors$|Exec=omarchy-launch-webapp https://localhost:47990|' "$desktop"
    echo "Fully quit the browser before reopening Sunshine Admin to clear any previously used certificate bypass."
    break
  fi
done
