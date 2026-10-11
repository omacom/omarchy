#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
marker="$test_home/.local/state/omarchy/preinstalls-removed"
mise_config="$test_tmp/etc/mise/config.toml"
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

# Keeps disable_tools in a file so the opt-out round trip can be checked.
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
case "$*" in
'reshim --system') exit "${OMARCHY_TEST_RESHIM_STATUS:-0}" ;;
'settings get disable_tools')
  printf '[%s]\n' "$(sed 's/.*/"&"/' "$OMARCHY_TEST_DISABLED" | paste -sd, - | sed 's/,/, /g')" ;;
'settings add disable_tools '*)
  [[ ${OMARCHY_TEST_FAIL_BEFORE_DISABLE:-} == "$4" ]] && exit 1
  printf '%s\n' "$4" >>"$OMARCHY_TEST_DISABLED"
  [[ ${OMARCHY_TEST_FAIL_AFTER_DISABLE:-} == "$4" ]] && exit 1
  ;;
'settings set disable_tools '*) tr ',' '\n' <<<"$4" >"$OMARCHY_TEST_DISABLED" ;;
'settings unset disable_tools') : >"$OMARCHY_TEST_DISABLED" ;;
esac
exit 0
SH

cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
exit 1
SH

chmod +x "$mock_bin"/*

# $ROOT/bin after the mocks, so the real helpers answer wherever a mock does not
# shadow them.
export PATH="$mock_bin:$ROOT/bin:$PATH"
export HOME="$test_home"
export OMARCHY_PATH="$ROOT"
export OMARCHY_MISE_CONFIG_PATH="$mise_config"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise-log"
export OMARCHY_TEST_DISABLED="$test_tmp/disable-tools"
mkdir -p "$(dirname "$mise_config")"
cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config"
# The user's own entry must survive the opt-out round trip.
printf 'node\n' >"$OMARCHY_TEST_DISABLED"
export OMARCHY_TEST_PKG_LOG="$pkg_log"

# Both scripts restore and remove the same set, and every package in it has to be
# one Omarchy actually ships, or Remove Preinstalls takes out an app the user
# chose from the menu and Install Preinstalls puts back one we retired.
mapfile -t shipped < <(sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$ROOT/install/omarchy-base.packages")

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
mapfile -t restored <"$pkg_log"
grep -Fx 'reshim --system' "$OMARCHY_TEST_MISE_LOG" >/dev/null || fail "Install Preinstalls rebuilds the mise shims"
pass "Install Preinstalls rebuilds the mise shims"

"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
mapfile -t dropped <"$pkg_log"
for tool in codex gh uv npm:cf node; do
  grep -qxF "$tool" "$OMARCHY_TEST_DISABLED" || fail "Remove Preinstalls disables Omarchy's mise tools for this user" "$tool"
done
[[ $(grep -c . "$OMARCHY_TEST_DISABLED") == 21 ]] || fail "Remove Preinstalls disables each default tool once"
pass "Remove Preinstalls disables Omarchy's mise tools for this user"

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
[[ $(<"$OMARCHY_TEST_DISABLED") == node ]] || fail "Install Preinstalls re-enables only the tools Remove Preinstalls disabled"
pass "Install Preinstalls re-enables only the tools Remove Preinstalls disabled"

# A failure on either side of the settings write leaves recoverable progress.
for failure in OMARCHY_TEST_FAIL_BEFORE_DISABLE OMARCHY_TEST_FAIL_AFTER_DISABLE; do
  env "$failure=codex" "$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null && status=0 || status=$?
  ((status == 1)) || fail "disable reports an interrupted setting write" "$failure returned $status"
  record="$HOME/.local/state/omarchy/mise-disabled-default-tools"
  grep -qxF codex "$record" || fail "disable records recovery before changing a setting"
  "$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null
  [[ $(grep -cxF codex "$record") == 1 ]] || fail "retry keeps one recovery record per tool"
  "$ROOT/bin/omarchy-mise-default-tools" enable >/dev/null
  [[ $(<"$OMARCHY_TEST_DISABLED") == node ]] || fail "restore after interruption preserves only user-disabled tools"
done
pass "tool disabling is recoverable before and after a settings write"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null

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

for package in omacut monologue omacalc omawrite hype; do
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

for failure in OMARCHY_TEST_RESHIM_STATUS; do
  touch "$marker"
  : >"$pkg_log"
  env "$failure=1" "$ROOT/bin/omarchy-install-preinstalls" >/dev/null && status=0 || status=$?
  (( status == 1 )) || fail "restore reports a failed tool setup" "$failure returned $status"
  [[ -f $marker ]] || fail "restore keeps the opt-out marker after failed tool setup" "$failure"
  [[ ! -s $pkg_log ]] || fail "restore stops before installing packages when tool setup fails" "$failure"
done
pass "restore stops and preserves opt-out when shim setup fails"


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

mkdir -p "$(dirname "$mise_config")"
touch "$mise_config"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
[[ -f $mise_config ]] || fail "Remove Preinstalls leaves the package-owned mise declarations in place"
pass "Remove Preinstalls leaves the package-owned mise declarations in place"
