#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for dependency in c++ make qmake6 pkg-config python3; do
  if ! command -v "$dependency" >/dev/null; then
    skip "native shortcut prototype requires optional build dependency: $dependency"
    exit 0
  fi
done

if ! pkg-config --exists json-c Qt6Core Qt6Qml Qt6Test; then
  skip "native shortcut prototype requires json-c and Qt 6 Core/Qml/Test development files"
  exit 0
fi

picker="$ROOT/contrib/shortcut-picker"
bash "$picker/build-native.sh"
bash "$picker/build-search.sh"
python3 "$picker/tests/verify-native.py"
pass "native shortcut model matches the independent reference and Qt model invariants"
python3 -m unittest discover -s "$picker/tests" -p 'test_*.py' -v
pass "native shortcut client preserves selection, cancellation, and stock fallback"
