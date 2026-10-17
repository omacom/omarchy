#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
echo "pkg-add $*" >>"$OMARCHY_TEST_CALLS"
SH

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
echo "cmd-present $*" >>"$OMARCHY_TEST_CALLS"
[[ $1 == "flatpak" ]]
SH

cat >"$mock_bin/flatpak" <<'SH'
#!/bin/bash
echo "flatpak $*" >>"$OMARCHY_TEST_CALLS"
if [[ $1 == "info" ]]; then
  [[ ${OMARCHY_TEST_ORCA_INSTALLED:-1} == "1" ]]
fi
SH

cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
echo "setsid $*" >>"$OMARCHY_TEST_CALLS"
SH

chmod +x "$mock_bin"/*

PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$calls" \
  "$ROOT/bin/omarchy-install-orca-slicer" >/dev/null

expected_install=$(cat <<'EOF'
pkg-add flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.orcaslicer.OrcaSlicer
setsid uwsm-app -- flatpak run com.orcaslicer.OrcaSlicer
EOF
)
[[ $(cat "$calls") == "$expected_install" ]] || fail "OrcaSlicer installs from Flathub and launches in the session" "$(cat "$calls")"
pass "OrcaSlicer installs from Flathub and launches in the session"

: >"$calls"
PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$calls" \
  "$ROOT/bin/omarchy-remove-orca-slicer" >/dev/null

expected_remove=$(cat <<'EOF'
cmd-present flatpak
flatpak info com.orcaslicer.OrcaSlicer
flatpak uninstall -y --delete-data com.orcaslicer.OrcaSlicer
EOF
)
[[ $(cat "$calls") == "$expected_remove" ]] || fail "OrcaSlicer removal deletes the Flatpak and its data" "$(cat "$calls")"
pass "OrcaSlicer removal deletes the Flatpak and its data"

: >"$calls"
PATH="$mock_bin:$PATH" OMARCHY_TEST_CALLS="$calls" OMARCHY_TEST_ORCA_INSTALLED=0 \
  "$ROOT/bin/omarchy-remove-orca-slicer" >/dev/null

expected_absent=$(cat <<'EOF'
cmd-present flatpak
flatpak info com.orcaslicer.OrcaSlicer
EOF
)
[[ $(cat "$calls") == "$expected_absent" ]] || fail "OrcaSlicer removal is harmless when the app is absent" "$(cat "$calls")"
pass "OrcaSlicer removal is harmless when the app is absent"
