echo "Install the compiler and Qt pieces for building Omarchy-style apps"

# The omarchy-app agent skill builds apps the way Hype, Monologue, and Omacut
# are built: C++ and Qt Quick, compiled with qmake6 and make. Qt arrived only
# as a dependency of those apps, and the compiler not at all.
omarchy-pkg-add base-devel qt6-base qt6-declarative qt6-wayland
