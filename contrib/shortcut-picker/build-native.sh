#!/bin/bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
mkdir -p build
"${CXX:-c++}" -std=c++17 -Os -s -Wall -Wextra -Werror -pedantic \
  native/selector.cpp -o build/omarchy-shortcut-select $(pkg-config --cflags --libs json-c)
install -m 755 build/omarchy-shortcut-select plugin/bin/omarchy-shortcut-select
