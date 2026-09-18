#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
marker="$test_home/.local/state/omarchy/preinstalls-removed"
pkg_log="$test_tmp/packages"
mkdir -p "$mock_bin" "$test_home/.local/state/omarchy"

for command in omarchy-webapp-remove-all omarchy-tui-remove-all omarchy-refresh-applications hyprctl; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
done

cat >"$mock_bin/gum" <<'SH'
#!/bin/bash
[[ $1 == confirm ]] && exit "${OMARCHY_TEST_CONFIRM:-0}"
exit 0
SH

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_PKG_LOG"
exit "${OMARCHY_TEST_PKG_ADD_STATUS:-0}"
SH

cat >"$mock_bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_PKG_LOG"
SH

chmod +x "$mock_bin"/*

# $ROOT/bin after the mocks: Remove Preinstalls asks omarchy-install-hermes-cli
# whether the wrapper is Omarchy's rather than matching the marker itself, and
# that is the real command at runtime. The mocks still shadow what they name.
export PATH="$mock_bin:$ROOT/bin:$PATH"
export HOME="$test_home"
export OMARCHY_TEST_PKG_LOG="$pkg_log"

# Both scripts restore and remove the same set, and every package in it has to be
# one Omarchy actually ships, or Remove Preinstalls takes out an app the user
# chose from the menu and Install Preinstalls puts back one we retired.
mapfile -t shipped < <(sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$ROOT/install/omarchy-base.packages")

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
mapfile -t restored <"$pkg_log"

"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
mapfile -t dropped <"$pkg_log"

[[ ${restored[*]} == "${dropped[*]}" ]] ||
  fail "Install and Remove Preinstalls cover the same packages" \
    "restored: ${restored[*]}
dropped:  ${dropped[*]}"
pass "Install and Remove Preinstalls cover the same packages"

for package in "${restored[@]}"; do
  printf '%s\n' "${shipped[@]}" | grep -qxF "$package" ||
    fail "every preinstall is shipped in omarchy-base.packages" "$package is not shipped"
done
pass "every preinstall is shipped in omarchy-base.packages"

for package in omacut omacalc omawrite; do
  printf '%s\n' "${restored[@]}" | grep -qxF "$package" ||
    fail "preinstalls cover the Omacom apps" "$package is missing"
done
pass "preinstalls cover the Omacom apps"

# The bindings key off the marker, so clearing it before the packages land would
# point them at apps that never came back.
touch "$marker"
OMARCHY_TEST_PKG_ADD_STATUS=1 "$ROOT/bin/omarchy-install-preinstalls" >/dev/null && status=0 || status=$?
(( status == 1 )) || fail "restore reports a failed package transaction" "exit status was $status"
[[ -f $marker ]] || fail "restore keeps the opt-out marker when packages fail to install"
pass "restore keeps the opt-out marker when packages fail to install"

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
[[ ! -e $marker ]] || fail "restore clears the opt-out marker once the packages are back"
pass "restore clears the opt-out marker once the packages are back"

rm -f "$marker"
OMARCHY_TEST_CONFIRM=1 "$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ ! -e $marker ]] || fail "declining Remove Preinstalls changes nothing"
pass "declining Remove Preinstalls changes nothing"

"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -f $marker ]] || fail "Remove Preinstalls records the opt-out"
pass "Remove Preinstalls records the opt-out"

# Hermes' wrapper is only a preinstall when omarchy-install-hermes-cli wrote it.
# The desktop app's command and an official install live at the same path and
# are the user's, whether or not any package says so.
hermes="$test_home/.local/bin/hermes"
mkdir -p "$(dirname "$hermes")"

printf '%s\n' "#!/bin/bash" "# Written by omarchy-install-hermes-cli." >"$hermes"
chmod +x "$hermes"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ ! -e $hermes ]] || fail "Remove Preinstalls deletes the Omarchy Hermes wrapper"
pass "Remove Preinstalls deletes the Omarchy Hermes wrapper"

printf '%s\n' "#!/bin/bash" "exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\"" >"$hermes"
chmod +x "$hermes"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -x $hermes ]] || fail "Remove Preinstalls keeps the desktop app's Hermes command"
pass "Remove Preinstalls keeps the desktop app's Hermes command"

official_body="#!/bin/bash
unset PYTHONPATH
unset PYTHONHOME
exec $test_home/.hermes/hermes-agent/venv/bin/hermes \"\$@\""
printf '%s\n' "$official_body" >"$hermes"
chmod +x "$hermes"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -x $hermes && $(cat "$hermes") == "$official_body" ]] || fail "Remove Preinstalls keeps an official Hermes install"
pass "Remove Preinstalls keeps an official Hermes install"

printf '%s\n' "#!/bin/bash" "# Replaces the stub omarchy-install-hermes-cli used to write." >"$hermes"
chmod +x "$hermes"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -x $hermes ]] || fail "Remove Preinstalls keeps a wrapper that merely mentions the installer"
pass "Remove Preinstalls keeps a wrapper that merely mentions the installer"

rm -f "$hermes"
ln -s "$test_home/nowhere/hermes" "$hermes"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -L $hermes ]] || fail "Remove Preinstalls keeps a foreign hermes link"
pass "Remove Preinstalls keeps a foreign hermes link"

# Only the mise wrapper omarchy-mise-install wrote is a preinstall: the kilo
# stub line identifies it, and anything else at the same path is the user's,
# including the configuration and state the runtime keeps elsewhere.
kilo="$test_home/.local/bin/kilo"
mkdir -p "$test_home/.kilo"
printf '%s\n' '{}' >"$test_home/.kilo/tui.json"

"$ROOT/bin/omarchy-mise-install" npm:@kilocode/cli kilo
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ ! -e $kilo ]] || fail "Remove Preinstalls deletes the Omarchy kilo wrapper"
[[ -f $test_home/.kilo/tui.json ]] || fail "Remove Preinstalls keeps kilo's configuration and state"
pass "Remove Preinstalls deletes the Omarchy kilo wrapper and nothing else"

printf '#!/bin/bash\necho user-kilo\n' >"$kilo"
chmod +x "$kilo"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ $("$kilo") == "user-kilo" ]] || fail "Remove Preinstalls keeps a user-managed kilo"
pass "Remove Preinstalls keeps a user-managed kilo install"

printf '#!/bin/bash\n# replaced: mise use -g --quiet "npm:@kilocode/cli"\nexec /opt/apps/kilo "$@"\n' >"$kilo"
chmod +x "$kilo"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -x $kilo ]] || fail "Remove Preinstalls keeps a wrapper that merely mentions the kilo package"
pass "Remove Preinstalls keeps a wrapper that merely mentions the kilo package"

rm -f "$kilo"
ln -s "$test_home/nowhere/kilo" "$kilo"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -L $kilo ]] || fail "Remove Preinstalls keeps a foreign kilo link"
rm -f "$kilo"
pass "Remove Preinstalls keeps a foreign kilo link"

# Restore reaches the mise provisioning script through application refresh, so
# with the real refresher in place, the stub Remove Preinstalls deleted comes
# back. mise and the command probes stay mocked, so nothing downloads and no
# settings change.
rm -f "$mock_bin/omarchy-refresh-applications"
printf '#!/bin/bash\nexec "$OMARCHY_TEST_REAL_REFRESH" "$@"\n' >"$mock_bin/omarchy-refresh-applications"
printf '#!/bin/bash\n[[ $1 == ${OMARCHY_TEST_MISSING_COMMAND:-} ]]\n' >"$mock_bin/omarchy-cmd-missing"
printf '#!/bin/bash\nexit 0\n' >"$mock_bin/mise"
chmod +x "$mock_bin/omarchy-refresh-applications" "$mock_bin/omarchy-cmd-missing" "$mock_bin/mise"
export OMARCHY_TEST_REAL_REFRESH="$ROOT/bin/omarchy-refresh-applications"
export OMARCHY_PATH="$ROOT"
export OMARCHY_TEST_MISSING_COMMAND=kilo

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
[[ -x $kilo ]] || fail "Install Preinstalls recreates the kilo lazy stub"
grep -Fq 'mise use -g --quiet "npm:@kilocode/cli"' "$kilo" ||
  fail "the restored kilo stub selects its npm package"
[[ ! -f $marker ]] || fail "Install Preinstalls clears the kilo stub's opt-out marker"
pass "Install Preinstalls recreates the kilo lazy stub through application refresh"
