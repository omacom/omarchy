echo "Install the Fingerprint Setup launcher"

launcher="org.omarchy.FingerprintSetup.desktop"
applications="$HOME/.local/share/applications"
if [[ ! -e $applications/$launcher && ! -L $applications/$launcher ]]; then
  install -Dm644 "$OMARCHY_PATH/applications/$launcher" "$applications/$launcher"
fi
update-desktop-database "$applications"
