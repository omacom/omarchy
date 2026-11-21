echo "Point Battle.net's launcher entry at the window class its client actually uses"

# The installer copies the shipped desktop entry, whose StartupWMClass was
# battle.net.exe. Under umu/Proton every Battle.net window carries the class
# steam_app_battlenet (the same class default/hypr/apps/battlenet.lua matches),
# so docks could not tie the running launcher to its icon. Repair only the
# exact stale value; leave any user-chosen class alone.
entry="$HOME/.local/share/applications/battlenet.desktop"

[[ -f $entry && ! -L $entry ]] || exit 0
sed -i 's/^StartupWMClass=battle\.net\.exe$/StartupWMClass=steam_app_battlenet/' "$entry"
