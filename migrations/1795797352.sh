echo "Remove the .NET 9 runtime Omarchy installed for Pinta"

# 1765846739 installed dotnet-runtime-9.0 for Pinta, which runs on
# dotnet-runtime now. .NET 9 is out of support and Arch has dropped the
# package, so the AUR helper tries to build it from source and fails the
# update. It goes when pacman can remove it without breaking a dependency.
# Required By can't tell that: it also names a package whose unversioned
# dependency dotnet-runtime satisfies.
if omarchy-pkg-present dotnet-runtime-9.0 &&
  pacman -Rs --print dotnet-runtime-9.0 >/dev/null 2>&1; then
  omarchy-pkg-drop dotnet-runtime-9.0
fi
