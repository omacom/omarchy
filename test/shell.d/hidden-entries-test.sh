#!/bin/bash

set -euo pipefail

# hidden-entries.sh decides which desktop entries the launcher never shows.
# It is run here against a throwaway HOME and a stubbed omarchy-pkg-present,
# so what lands in its output -- and specifically that the upstream Hermes
# launcher is hidden only while the packaged desktop app owns Hermes -- is
# read off the script's actual answer rather than its source.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
user_apps="$test_tmp/home/.local/share/applications"
mkdir -p "$mock_bin" "$user_apps"

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
[[ $1 == "hermes-desktop" && ${OMARCHY_TEST_DESKTOP_INSTALLED:-0} == "1" ]]
SH

# The upstream runtime's own launcher entry, as its install writes it. The
# Exec path is resolved at write time by the real installer, so the fixture
# writes the throwaway home's absolute path the same way -- and the runtime
# the entry points at.
cat >"$user_apps/hermes.desktop" <<SH
[Desktop Entry]
Type=Application
Name=Hermes
Exec=$test_tmp/home/.local/bin/hermes desktop
SH
mkdir -p "$test_tmp/home/.local/bin"
: >"$test_tmp/home/.local/bin/hermes"
chmod +x "$test_tmp/home/.local/bin/hermes"

# A genuinely hidden entry, to prove the scan still does its old job.
cat >"$user_apps/hidden-helper.desktop" <<'SH'
[Desktop Entry]
Type=Application
Name=Hidden Helper
Exec=/usr/bin/true
Hidden=true
SH

run_scan() {
  # The script's exit code is the last scan_dir's, and an absent
  # ~/.nix-profile answers 1; the shell reads its stdout, not its status.
  OMARCHY_TEST_DESKTOP_INSTALLED="${1:-0}" \
    HOME="$test_tmp/home" \
    PATH="$mock_bin:$ROOT/bin:$PATH" \
    bash "$ROOT/shell/services/hidden-entries.sh" || true
}

chmod +x "$mock_bin"/*

# Package present: the packaged app owns Hermes, so the upstream launcher's
# entry goes the way of every other superseded entry.
run_scan 1 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" || fail "the Hermes launcher is hidden while the package owns Hermes"
grep -qx hidden-helper "$test_tmp/output" || fail "a Hidden=true entry is still hidden"
pass "the Hermes launcher is hidden while the packaged app owns Hermes"

# Package absent: the runtime's launcher is the only Hermes launcher there is,
# and hiding it would leave the desktop app unreachable from search.
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" && fail "the Hermes launcher stays hidden without the package"
grep -qx hidden-helper "$test_tmp/output" || fail "a Hidden=true entry is still hidden without the package"
pass "a Hermes installed without the package stays launchable"

# Target gone: a runtime deleted by hand, or a removal that never reached the
# entry, leaves it pointing at nothing. An entry whose Exec target is gone
# cannot launch anything, so it goes back to being hidden instead of surfacing
# as search noise -- without touching a working standalone install, whose
# target still exists.
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" && fail "the removal probe ran against a working install"
pass "a launcher whose target exists is never treated as removed"
rm -f "$test_tmp/home/.local/bin/hermes"
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" || fail "the launcher survives with its Exec target removed"
grep -qx hidden-helper "$test_tmp/output" || fail "a Hidden=true entry is still hidden after Hermes removal"
pass "a launcher left behind by removal is hidden again"

# An entry whose Exec quotes its path resolves the quoted target.
# The spec quotes only the executable: the binary up to the closing quote,
# arguments after it. The upstream installer writes exactly this shape when
# the home path contains spaces. The removal case above deleted the binary,
# so the runtime comes back first.
: >"$test_tmp/home/.local/bin/hermes"
chmod +x "$test_tmp/home/.local/bin/hermes"
cat >"$user_apps/hermes.desktop" <<SH
[Desktop Entry]
Type=Application
Name=Hermes
Exec="$test_tmp/home/.local/bin/hermes" desktop
SH
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" && fail "a quoted Exec target was not resolved"
pass "a quoted Exec target resolves before the existence check"

# An Exec naming a bare command is looked up on PATH, as the launcher would
# run it: found, the entry works; gone, it is hidden like a dead path.
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/hermes-probe"
chmod +x "$mock_bin/hermes-probe"
cat >"$user_apps/hermes.desktop" <<'SH'
[Desktop Entry]
Type=Application
Name=Hermes
Exec=hermes-probe desktop
SH
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" && fail "a bare Exec command found on PATH was treated as dead"
rm -f "$mock_bin/hermes-probe"
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" || fail "a bare Exec command missing from PATH was treated as live"
pass "a bare Exec command is resolved on PATH"

# A relative Exec resolves against the entry's own Path=, which the scan does
# not read, so it is never judged dead.
cat >"$user_apps/hermes.desktop" <<'SH'
[Desktop Entry]
Type=Application
Name=Hermes
Path=/nowhere
Exec=./launch desktop
SH
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" && fail "a relative Exec command was judged from the wrong directory"
pass "a relative Exec command is left to the launcher"

# A desktop-entry escape in the command, \s for a space, is decoded by the
# launcher and not by the scan, so such an entry is never judged dead.
mkdir -p "$test_tmp/home/Hermes Desktop/bin"
: >"$test_tmp/home/Hermes Desktop/bin/hermes"
chmod +x "$test_tmp/home/Hermes Desktop/bin/hermes"
cat >"$user_apps/hermes.desktop" <<SH
[Desktop Entry]
Type=Application
Name=Hermes
Exec="$test_tmp/home/Hermes\sDesktop/bin/hermes" desktop
SH
run_scan 0 >"$test_tmp/output"
grep -qx hermes "$test_tmp/output" && fail "an escaped Exec path was judged without decoding it"
pass "an escaped Exec path is left to the launcher"
