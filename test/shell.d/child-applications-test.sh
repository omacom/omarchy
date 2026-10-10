#!/bin/bash
#
# A child install still copies the adult launcher set from applications/ (and
# from skel), then omarchy-refresh-applications deletes the hidden names.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"

for command in omarchy-cmd-present omarchy-mise-install omarchy-install-hermes-cli update-desktop-database mise; do
  printf '#!/bin/bash\nexit 1\n' >"$mock_bin/$command"
done
# mise.sh is sourced after the copy; the installers must succeed so the
# refresh does not look like it failed for an unrelated reason. Each wrapper
# install is recorded, since a config reset must not replace the wrappers.
export MISE_INSTALL_CALLS="$test_tmp/mise-install-calls"
cat >"$mock_bin/omarchy-mise-install" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$MISE_INSTALL_CALLS"
exit 0
SH
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/update-desktop-database" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$mock_bin"/*

export PATH="$mock_bin:$ROOT/bin:$PATH"
export HOME="$test_home"
export OMARCHY_PATH="$ROOT"

adult_marker="$test_tmp/profile-default"
printf 'default\n' >"$adult_marker"
child_marker="$test_tmp/profile-child"
printf 'child\n' >"$child_marker"

OMARCHY_PROFILE_FILE="$adult_marker" omarchy-refresh-applications
[[ -f $test_home/.local/share/applications/WhatsApp.desktop ]] ||
  fail "a default profile keeps WhatsApp"
[[ -f $test_home/.local/share/applications/YouTube.desktop ]] ||
  fail "a default profile keeps YouTube"
[[ -s $MISE_INSTALL_CALLS ]] || fail "a full refresh sets up the mise wrappers"
pass "a default profile keeps the adult launcher set"

OMARCHY_PROFILE_FILE="$child_marker" omarchy-refresh-applications
[[ ! -e $test_home/.local/share/applications/WhatsApp.desktop ]] ||
  fail "a child profile drops WhatsApp"
[[ ! -e $test_home/.local/share/applications/Docker.desktop ]] ||
  fail "a child profile drops Docker"
[[ ! -e $test_home/.local/share/applications/HEY.desktop ]] ||
  fail "a child profile drops HEY"
[[ ! -e $test_home/.local/share/applications/Google\ Contacts.desktop ]] ||
  fail "a child profile drops Google Contacts"
[[ -f $test_home/.local/share/applications/YouTube.desktop ]] ||
  fail "a child profile keeps YouTube"
[[ -f $test_home/.local/share/applications/foot.desktop ]] ||
  fail "a child profile keeps foot"
pass "a child profile drops the hidden adult launchers"

# Skel already planted WhatsApp. Refresh must delete it, not only skip the copy.
cp "$ROOT/applications/WhatsApp.desktop" "$test_home/.local/share/applications/WhatsApp.desktop"
OMARCHY_PROFILE_FILE="$child_marker" omarchy-refresh-applications
[[ ! -e $test_home/.local/share/applications/WhatsApp.desktop ]] ||
  fail "a child profile removes a WhatsApp launcher that skel planted"
pass "a child profile removes hidden launchers that skel planted"

# The config reset refreshes launchers only: skel replanted the adult set, the
# child install drops its hidden names again, and the mise wrappers in
# ~/.local/bin, which skel never carried, keep whatever the user made of them.
rm -f "$MISE_INSTALL_CALLS"
cp "$ROOT/applications/WhatsApp.desktop" "$test_home/.local/share/applications/WhatsApp.desktop"
OMARCHY_PROFILE_FILE="$child_marker" omarchy-refresh-applications --launchers-only
[[ ! -e $test_home/.local/share/applications/WhatsApp.desktop ]] ||
  fail "the launchers-only refresh still drops the hidden launchers on a child install"
[[ -f $test_home/.local/share/applications/YouTube.desktop ]] ||
  fail "the launchers-only refresh still installs the launchers"
[[ ! -e $MISE_INSTALL_CALLS ]] || fail "the launchers-only refresh leaves the mise wrappers alone" "$(cat "$MISE_INSTALL_CALLS")"
if omarchy-refresh-applications --no-such-flag 2>/dev/null; then
  fail "an unknown flag is refused"
fi
pass "a launchers-only refresh drops hidden launchers without touching the mise wrappers"

grep -Fq 'omarchy-refresh-applications --launchers-only' "$ROOT/bin/omarchy-reinstall-configs" ||
  fail "omarchy-reinstall-configs refreshes launchers only after replaying skel"
grep -Fq 'omarchy-profile-child' "$ROOT/bin/omarchy-provision-user" ||
  fail "omarchy-provision-user skips the HEY mailto handler on a child install"
pass "config resync and user finalize honor the child launcher set"
