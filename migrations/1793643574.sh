echo "Let SSH commands and login shells find the .NET SDK from omarchy install dev-env dotnet"

# Only Omarchy's own launcher is replaced, never a dotnet an admin put there.
if [[ -d ${MISE_DATA_DIR:-$HOME/.local/share/mise}/installs/dotnet ]]; then
  if [[ ! -e /usr/local/bin/dotnet && ! -L /usr/local/bin/dotnet ]] || grep -qx "# omarchy-dotnet-launcher" /usr/local/bin/dotnet; then
    sudo install -Dm755 "$OMARCHY_PATH/default/dotnet/dotnet" /usr/local/bin/dotnet
  fi
fi
