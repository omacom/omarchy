echo "Install CMake for building Omarchy-style apps"

# The omarchy-app agent skill now builds apps with CMake, Qt 6's own build
# system, as Folio does, rather than qmake6.
omarchy-pkg-add cmake
