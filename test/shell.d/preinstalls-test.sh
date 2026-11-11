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

cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_MISE_LOG"
[[ $* == 'reshim --system' ]] && exit "${OMARCHY_TEST_RESHIM_STATUS:-0}"
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
mkdir -p "$(dirname "$mise_config")"
cp "$ROOT/etc/mise/conf.d/omarchy-tools.toml" "$mise_config"
# The user's own setting must survive the opt-out round trip, and the opt-out
# line must start on a line of its own.
miserc="$test_home/.config/mise/miserc.toml"
ignore_line="ignored_config_paths = [\"$mise_config\"]"
mkdir -p "$(dirname "$miserc")"
printf 'env = ["work"]' >"$miserc"
export OMARCHY_TEST_PKG_LOG="$pkg_log"

# Both scripts restore and remove the same set, and every package in it has to be
# one Omarchy actually ships, or Remove Preinstalls takes out an app the user
# chose from the menu and Install Preinstalls puts back one we retired.
mapfile -t shipped < <(sed -e 's/[[:space:]]*#.*$//' -e '/^[[:space:]]*$/d' "$ROOT/install/omarchy-base.packages")

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
mapfile -t restored <"$pkg_log"
grep -Fx 'reshim --system' "$OMARCHY_TEST_MISE_LOG" >/dev/null || fail "Install Preinstalls rebuilds the mise shims"
pass "Install Preinstalls rebuilds the mise shims"

: >"$OMARCHY_TEST_MISE_LOG"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null
mapfile -t dropped <"$pkg_log"
[[ $(<"$miserc") == "env = [\"work\"]"$'\n'"$ignore_line" ]] ||
  fail "Remove Preinstalls has mise skip Omarchy's declarations for this user" "$(<"$miserc")"
grep -Fx 'reshim' "$OMARCHY_TEST_MISE_LOG" >/dev/null || fail "Remove Preinstalls retires the lazy shims"
pass "Remove Preinstalls has mise skip Omarchy's declarations for this user"

"$ROOT/bin/omarchy-install-preinstalls" >/dev/null
[[ $(<"$miserc") == 'env = ["work"]' ]] || fail "Install Preinstalls removes only its own miserc line" "$(<"$miserc")"
pass "Install Preinstalls removes only its own miserc line"

rm "$miserc"
"$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null
"$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null
[[ $(<"$miserc") == "$ignore_line" ]] || fail "opting out twice adds the line once" "$(<"$miserc")"
"$ROOT/bin/omarchy-mise-default-tools" enable >/dev/null
[[ ! -e $miserc ]] || fail "opting back in removes a miserc that held only the opt-out"
pass "opting out is idempotent and reversible"

# A list the user wrote is theirs to edit. Once it names the file, both
# directions agree that the user has opted out.
printf 'ignored_config_paths = ["~/old"]\n' >"$miserc"
"$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null 2>&1 && status=0 || status=$?
((status == 1)) || fail "opting out refuses to add a second ignored_config_paths" "exit status was $status"
[[ $(<"$miserc") == 'ignored_config_paths = ["~/old"]' ]] || fail "opting out leaves the user's list alone"
printf 'ignored_config_paths = ["~/old", "%s"]\n' "$mise_config" >"$miserc"
"$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null || fail "opting out accepts the file in the user's own list"
"$ROOT/bin/omarchy-mise-default-tools" declares codex && fail "a user's own list keeps Omarchy's tools undeclared"
"$ROOT/bin/omarchy-mise-default-tools" enable >/dev/null 2>&1 && status=0 || status=$?
((status == 1)) || fail "opting back in reports a list it cannot edit" "exit status was $status"
rm "$miserc"
pass "an existing ignored_config_paths is left to the user"

printf '# %s\n' "$ignore_line" >"$miserc"
"$ROOT/bin/omarchy-mise-default-tools" declares codex || fail "a commented-out opt-out keeps Omarchy's tools declared"
"$ROOT/bin/omarchy-mise-default-tools" disable >/dev/null
grep -qxF "$ignore_line" "$miserc" || fail "opting out is not skipped by a commented-out opt-out"
"$ROOT/bin/omarchy-mise-default-tools" enable >/dev/null || fail "opting back in succeeds past a commented-out opt-out"
rm "$miserc"
pass "a commented-out opt-out does not count"
"$ROOT/bin/omarchy-remove-preinstalls" >/dev/null

[[ ${restored[*]} == "${dropped[*]}" ]] ||
  fail "Install and Remove Preinstalls cover the same packages" \
    "restored: ${restored[*]}
dropped:  ${dropped[*]}"
pass "Install and Remove Preinstalls cover the same packages"

for package in "${restored[@]}"; do
  grep -qxF "$package" <<<"$(printf '%s\n' "${shipped[@]}")" ||
    fail "every preinstall is shipped in omarchy-base.packages" "$package is not shipped"
done
pass "every preinstall is shipped in omarchy-base.packages"

for package in omacut monologue omacalc omawrite hype signed; do
  grep -qxF "$package" <<<"$(printf '%s\n' "${restored[@]}")" ||
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

# Exercise regional exclusions through the real setup, dock, refresh and Lua
# bindings, with only desktop IPC and the desktop database update stubbed.
require_command lua
require_command node
rm "$mock_bin/omarchy-refresh-applications"
for command in omarchy-shell update-desktop-database; do
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/$command"
  chmod +x "$mock_bin/$command"
done

region_leaf="$test_tmp/region-preinstalls.sh"
sed "s|/etc/omarchy/region|$test_tmp/region|g" "$ROOT/install/user/region-preinstalls.sh" >"$region_leaf"
printf cn >"$test_tmp/region"
restore_disabled=$(node -e '
const fs = require("fs");
const menu = require(process.env.ROOT + "/shell/plugins/menu/MenuModel.js");
console.log(menu.parseMenuJsonc(fs.readFileSync(process.env.ROOT + "/default/omarchy/omarchy-menu.jsonc", "utf8")).find(item => item.id === "install.preinstalls").disabled);
')

regional_bindings() {
  lua <<'LUA'
package.path = os.getenv("OMARCHY_PATH") .. "/?.lua;" .. package.path
hl = {
  dsp = { exec_cmd = function(command) return command end },
  bind = function(keys, dispatcher, options) print(keys .. "\t" .. options.description) end,
}
require("default.hypr.helpers")
require("default.hypr.bindings.applications")
o.bind("USER", "X", { webapp = "https://x.com/" })
LUA
}

(
  export HOME="$test_tmp/regional-home"
  mkdir -p "$HOME/.local/share/applications"
  "$ROOT/bin/omarchy-refresh-applications"
  "$ROOT/bin/omarchy-region-preinstalls" us
  [[ ! -e $HOME/.local/state/omarchy/preinstalls-skipped ]] || fail "a region without exclusions leaves no record"
  [[ -f $HOME/.local/share/applications/YouTube.desktop ]] || fail "global launchers stay installed"
  grep -qxF $'SUPER + SHIFT + X\tX' <<<"$(regional_bindings)" || fail "global preinstalled bindings stay enabled"
  pass "a region without exclusions keeps launchers and bindings"

  for state_home in "" "$test_tmp/custom-state"; do
    export XDG_STATE_HOME="$state_home"
    export HOME="$test_tmp/regional-home-${state_home:+custom}"
    mkdir -p "$HOME/.local/share/applications"
    "$ROOT/bin/omarchy-refresh-applications"
    bash -eE "$region_leaf"
    [[ ! -e $HOME/.local/share/applications/YouTube.desktop && ! -e $HOME/.local/share/applications/X.desktop ]] ||
      fail "regional setup removes skipped launchers"
    [[ -f $HOME/.local/share/applications/Basecamp.desktop ]] || fail "regional setup keeps unrelated launchers"
    pins=$("$ROOT/bin/omarchy-dock" pinned)
    ! grep -qxF YouTube <<<"$pins" && ! grep -qxF X <<<"$pins" || fail "regional setup unpins skipped apps"
    grep -qxF org.gnome.Nautilus <<<"$pins" || fail "regional setup preserves unrelated pins"

    bindings=$(regional_bindings)
    for name in YouTube X ChatGPT Signal Music; do
      ! grep -q $'\t'"$name"'$' <<<"${bindings%$'\n'USER*}" || fail "regional setup omits the $name preinstalled binding"
    done
    for name in Terminal Calendar Obsidian "Music TUI"; do
      grep -q $'\t'"$name"'$' <<<"$bindings" || fail "regional setup keeps the $name binding"
    done
    grep -qxF $'USER\tX' <<<"$bindings" || fail "a personal binding can restore a skipped app"

    # A region with no list and a later refresh must not undo the install.
    printf 'user-installed launcher\n' >"$HOME/.local/share/applications/ChatGPT.desktop"
    "$ROOT/bin/omarchy-region-preinstalls" us
    "$ROOT/bin/omarchy-refresh-applications"
    [[ ! -e $HOME/.local/share/applications/YouTube.desktop && -f $HOME/.local/share/applications/Basecamp.desktop ]] ||
      fail "refresh preserves exclusions rather than reading the current region"
    [[ $(<"$HOME/.local/share/applications/ChatGPT.desktop") == "user-installed launcher" ]] ||
      fail "refresh does not delete a user's non-shipped launcher with a skipped binding's name"
    printf 'user-installed launcher\n' >"$HOME/.local/share/applications/YouTube.desktop"
    "$ROOT/bin/omarchy-refresh-applications"
    [[ $(<"$HOME/.local/share/applications/YouTube.desktop") == "user-installed launcher" ]] ||
      fail "refresh preserves an explicitly restored launcher even when its default was skipped"

    bash -c "$restore_disabled" && fail "the menu offers Restore Preinstalls after regional exclusions"
    OMARCHY_TEST_PKG_ADD_STATUS=1 "$ROOT/bin/omarchy-install-preinstalls" >/dev/null && fail "failed restore reports success"
    [[ -f ${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/preinstalls-skipped ]] || fail "failed restore preserves regional exclusions"
    "$ROOT/bin/omarchy-install-preinstalls" >/dev/null
    [[ ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/preinstalls-skipped ]] || fail "explicit restore clears regional exclusions"
    cmp "$ROOT/applications/YouTube.desktop" "$HOME/.local/share/applications/YouTube.desktop" || fail "explicit restore brings back skipped default launchers"
    grep -qxF $'SUPER + SHIFT + X\tX' <<<"$(regional_bindings)" || fail "explicit restore brings back skipped bindings"
    bash -c "$restore_disabled" || fail "the menu disables Restore once nothing is excluded"

    "$ROOT/bin/omarchy-done" mark finalize-user
    printf 'user-installed launcher\n' >"$HOME/.local/share/applications/YouTube.desktop"
    bash -eE "$region_leaf"
    [[ ! -e ${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/preinstalls-skipped ]] || fail "re-finalization does not undo an explicit restore"
    [[ $(<"$HOME/.local/share/applications/YouTube.desktop") == "user-installed launcher" ]] || fail "re-finalization preserves a user's launcher"
  done
  pass "regional exclusions survive refresh and user overrides until an explicit successful restore"
)
