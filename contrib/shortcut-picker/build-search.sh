#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p build/search
(
  cd build/search
  qmake6 ../../native/search/search.pro
  # Make does not track compiler flags as object dependencies. Rebuild when
  # qmake's Qt version or generated build settings change.
  build_config=$({
    qmake6 -v
    sed -n -E '/^(CXX|CXXFLAGS|DEFINES|INCPATH|LINK|LFLAGS|LIBS)[[:space:]]*=/p' Makefile
  } | sha256sum | cut -d ' ' -f 1)
  if [[ ! -f .build-config ]] || [[ $(<.build-config) != "$build_config" ]]; then
    make clean
  fi
  make -j2
  printf '%s\n' "$build_config" > .build-config
)
module_dir="${1:-$PWD/plugin/Native}"
mkdir -p "$module_dir"
module_dir="$(cd -- "$module_dir" && pwd)"
# Replace the library atomically: a running shell may still map the old inode.
staged_library=$(mktemp "$module_dir/.shortcutsearch.XXXXXXXX")
install -m 755 build/search/libshortcutsearch.so "$staged_library"
mv -f "$staged_library" "$module_dir/libshortcutsearch.so"
# Quickshell virtualizes QML paths. The binary needs an actual filesystem path.
staged_manifest=$(mktemp "$module_dir/.qmldir.XXXXXXXX")
printf 'plugin shortcutsearch %s\nclassname ShortcutSearchPlugin\n' "$module_dir" > "$staged_manifest"
chmod 644 "$staged_manifest"
mv -f "$staged_manifest" "$module_dir/qmldir"
