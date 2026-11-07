echo "Let SSH commands and login shells find the .NET SDK from omarchy install dev-env dotnet"

if [[ -d ${MISE_DATA_DIR:-$HOME/.local/share/mise}/installs/dotnet ]]; then
  sudo install -Dm755 "$OMARCHY_PATH/default/dotnet/dotnet" /usr/local/bin/dotnet
fi
