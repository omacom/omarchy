echo "Remove the .NET 9 runtime Omarchy installed for Pinta"

# 1765846739 installed dotnet-runtime-9.0 for Pinta, which runs on
# dotnet-runtime now. .NET 9 is out of support and Arch has dropped the
# package, so the AUR helper tries to build it from source and fails the
# update. It goes when nothing installed still needs it.
if omarchy-pkg-present dotnet-runtime-9.0 &&
  LC_ALL=C pacman -Qi dotnet-runtime-9.0 | grep -qx 'Required By *: None'; then
  omarchy-pkg-drop dotnet-runtime-9.0
fi
