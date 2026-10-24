#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

HOME_DIR=$(mktemp -d)
trap 'rm -rf "$HOME_DIR"' EXIT

stub_dir="$HOME_DIR/stub"
mkdir -p "$stub_dir"

cat >"$stub_dir/pacman" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"${HOME}/pacman-calls.log"
if [[ $1 == -Qqe ]]; then
  [[ -f $HOME/explicit.list ]] && cat "$HOME/explicit.list"
  exit 0
fi
if [[ $1 == -Q ]]; then
  pkg="${!#}"
  [[ -f $HOME/installed.list ]] && grep -qxF -- "$pkg" "$HOME/installed.list"
  exit $?
fi
exit 0
EOF

cat >"$stub_dir/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >>"$HOME/calls.log"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  printf '%s\n' "$pkg" >>"$HOME/installed.list"
  printf '%s\n' "$pkg" >>"$HOME/explicit.list"
done
exit 0
EOF

cat >"$stub_dir/omarchy-pkg-aur-add" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-aur-add %s\n' "$*" >>"$HOME/calls.log"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  printf '%s\n' "$pkg" >>"$HOME/installed.list"
  printf '%s\n' "$pkg" >>"$HOME/explicit.list"
done
exit 0
EOF

cat >"$stub_dir/omarchy-pkg-aur-drop" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-aur-drop %s\n' "$*" >>"$HOME/calls.log"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  grep -vxF -- "$pkg" "$HOME/installed.list" >"$HOME/installed.list.next" || true
  mv -f "$HOME/installed.list.next" "$HOME/installed.list"
  grep -vxF -- "$pkg" "$HOME/explicit.list" >"$HOME/explicit.list.next" || true
  mv -f "$HOME/explicit.list.next" "$HOME/explicit.list"
done
exit 0
EOF

cat >"$stub_dir/omarchy-pkg-drop" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-drop %s\n' "$*" >>"$HOME/calls.log"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  grep -vxF -- "$pkg" "$HOME/installed.list" >"$HOME/installed.list.next" || true
  mv -f "$HOME/installed.list.next" "$HOME/installed.list"
  grep -vxF -- "$pkg" "$HOME/explicit.list" >"$HOME/explicit.list.next" || true
  mv -f "$HOME/explicit.list.next" "$HOME/explicit.list"
done
exit 0
EOF

for plugin_cmd in omarchy-plugin-add omarchy-plugin-remove omarchy-plugin-validate omarchy-plugin-list; do
  cat >"$stub_dir/$plugin_cmd" <<EOF
#!/bin/bash
printf '%s %s\\n' "$plugin_cmd" "\$*" >>"\$HOME/calls.log"
exit 1
EOF
done

cat >"$stub_dir/sudo" <<'EOF'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$HOME/calls.log"
exec "$@"
EOF

chmod +x "$stub_dir"/*

new_home() {
  local name="$1"
  local home="$HOME_DIR/homes/$name"
  rm -rf "$home"
  mkdir -p "$home/.local/share" "$home/.local/state" "$home/.config" "$home/.agents/skills"
  printf '%s\n' "$home"
}

run_bundle() {
  local home="$1"
  shift
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$@"
}

write_bundle() {
  local dir="$1" id="$2" name="$3" packages="$4" conflicts="${5:-[]}" aur="${6:-[]}"
  mkdir -p "$dir"
  jq -n \
    --arg id "$id" --arg name "$name" \
    --argjson packages "$packages" --argjson conflicts "$conflicts" --argjson aur "$aur" \
    '{
      schemaVersion: 1,
      packageType: "bundle",
      id: $id,
      name: $name,
      version: "1.0.0",
      description: $name,
      packages: $packages,
      aurPackages: $aur,
      plugins: [],
      skills: [],
      config: [],
      conflicts: $conflicts
    }' >"$dir/bundle.json"
}

calls_have() {
  local home="$1" expected="$2"
  [[ -f $home/calls.log ]] && grep -qxF -- "$expected" "$home/calls.log"
}

write_config_bundle() {
  local dir="$1" id="$2" content="${3:-from-bundle}"
  write_bundle "$dir" "$id" "$id" '[]'
  mkdir -p "$dir/config"
  printf '%s\n' "$content" >"$dir/config/note.txt"
  jq '.config = [{"source":"config/note.txt","target":"~/.config/note.txt"}]' \
    "$dir/bundle.json" >"$dir/bundle.json.next"
  mv "$dir/bundle.json.next" "$dir/bundle.json"
}

# 1. Shared package stays until both bundles are gone.
home=$(new_home shared)
write_bundle "$home/a" shared-a "Shared A" '["sharedpkg","only-a"]'
write_bundle "$home/b" shared-b "Shared B" '["sharedpkg","only-b"]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/a" >/dev/null
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/b" >/dev/null
calls_have "$home" "omarchy-pkg-add sharedpkg only-a" || fail "first bundle installs its packages" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-pkg-add only-b" || fail "second bundle installs only the missing package" "$(cat "$home/calls.log")"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes shared-a >/dev/null
calls_have "$home" "omarchy-pkg-drop only-a" || fail "removing one owner drops only its private package" "$(cat "$home/calls.log")"
grep -qxF sharedpkg "$home/installed.list" || fail "shared package remains installed" "$(cat "$home/installed.list")"
if grep -q 'omarchy-pkg-drop sharedpkg' "$home/calls.log"; then
  fail "shared package was dropped while another bundle still owns it" "$(cat "$home/calls.log")"
fi
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes shared-b >/dev/null
calls_have "$home" "omarchy-pkg-drop sharedpkg only-b" || calls_have "$home" "omarchy-pkg-drop only-b sharedpkg" \
  || fail "removing the last owner drops the shared package" "$(cat "$home/calls.log")"
if grep -qxF sharedpkg "$home/installed.list"; then
  fail "shared package is still installed after both bundles are removed" "$(cat "$home/installed.list")"
fi
pass "shared package stays until both bundles are removed"

# 1b. Official packages and AUR packages use different commands.
home=$(new_home aur)
write_bundle "$home/mix" mixed "Mixed" '["gamemode"]' '[]' '["protonup-qt"]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/mix" >/dev/null
calls_have "$home" "omarchy-pkg-add gamemode" || fail "official package uses omarchy-pkg-add" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-pkg-aur-add protonup-qt" || fail "AUR package uses omarchy-pkg-aur-add" "$(cat "$home/calls.log")"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes mixed >/dev/null
calls_have "$home" "omarchy-pkg-drop gamemode" || fail "official package uses omarchy-pkg-drop" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-pkg-aur-drop protonup-qt" || fail "AUR package uses omarchy-pkg-aur-drop" "$(cat "$home/calls.log")"
pass "official and AUR packages install and remove through their own commands"

# 2. A package you installed yourself is never removed. A file that already
# existed is kept too.
home=$(new_home yours)
printf '%s\n' mine >"$home/installed.list"
printf '%s\n' mine >"$home/explicit.list"
mkdir -p "$home/.config"
printf 'yours\n' >"$home/.config/preexisting.txt"
write_bundle "$home/mine-bundle" mine-bundle "Mine" '["mine","fresh"]'
jq '.config = [{"source":"config/note.txt","target":"~/.config/preexisting.txt"}]' \
  "$home/mine-bundle/bundle.json" >"$home/mine-bundle/bundle.json.next"
mv "$home/mine-bundle/bundle.json.next" "$home/mine-bundle/bundle.json"
mkdir -p "$home/mine-bundle/config"
printf 'bundle\n' >"$home/mine-bundle/config/note.txt"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/mine-bundle" >/dev/null
[[ $(<"$home/.config/preexisting.txt") == yours ]] || fail "an existing config file is not overwritten"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes mine-bundle >/dev/null
grep -qxF mine "$home/installed.list" || fail "a package installed before any bundle is kept" "$(cat "$home/installed.list" 2>/dev/null)"
if grep -q 'omarchy-pkg-drop mine' "$home/calls.log"; then
  fail "a preinstalled package was passed to omarchy-pkg-drop" "$(cat "$home/calls.log")"
fi
calls_have "$home" "omarchy-pkg-drop fresh" || fail "the bundle's own package is removed" "$(cat "$home/calls.log")"
[[ $(<"$home/.config/preexisting.txt") == yours ]] || fail "a pre-existing config file is kept"
pass "preinstalled packages and existing files are kept"

# 3. Conflicts.
home=$(new_home conflicts)
write_bundle "$home/left" left-bundle "Left" '["leftpkg"]' '["right-bundle"]'
write_bundle "$home/right" right-bundle "Right" '["rightpkg"]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/left" >/dev/null
if run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/right" >"$home/conflict.out" 2>&1; then
  fail "a conflicting bundle was installed" "$(cat "$home/conflict.out")"
fi
grep -q conflicts "$home/conflict.out" || fail "conflict refusal names the conflict" "$(cat "$home/conflict.out")"
if [[ -f $home/calls.log ]] && grep -q rightpkg "$home/calls.log"; then
  fail "a refused bundle installed a package" "$(cat "$home/calls.log")"
fi
pass "conflicting bundles are refused"

# 4. Dry run.
home=$(new_home dry)
write_bundle "$home/dry-bundle" dry-bundle "Dry" '["drypkg"]'
output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --dry-run "$home/dry-bundle")
grep -q 'Dry run: nothing was installed.' <<<"$output" || fail "dry run says nothing was installed" "$output"
grep -q drypkg <<<"$output" || fail "dry run names the package" "$output"
[[ ! -e $home/.local/state/omarchy/bundles/ledger.json ]] || fail "dry run wrote a ledger"
[[ ! -e $home/.local/share/omarchy-bundles ]] || fail "dry run copied the bundle"
[[ ! -e $home/calls.log ]] || fail "dry run called a package or plugin command" "$(cat "$home/calls.log")"
pass "dry run changes nothing"

# 4c. New plugins are enabled with --yes, and an interactive install can decline.
home=$(new_home plugin-yes)
write_bundle "$home/plug" plug-bundle "Plug" '["samplepkg"]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-plugin-add" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-add %s\n' "$*" >>"$HOME/calls.log"
echo "Added example.plugin into $HOME/plugins/example.plugin"
exit 0
EOF
chmod +x "$home/bin/omarchy-plugin-add"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --dry-run --yes "$home/plug"
)
grep -q 'New plugins are enabled.' <<<"$output" || fail "dry run with --yes says new plugins are enabled" "$output"
[[ ! -e $home/calls.log ]] || fail "dry run called plugin add" "$(cat "$home/calls.log")"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug"
)
calls_have "$home" "omarchy-pkg-add samplepkg" || fail "bundle add installs packages" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-plugin-add --yes --enable -- https://example.test/gamemode-switcher.git" \
  || fail "bundle add --yes enables new plugins" "$(cat "$home/calls.log")"
pkg_line=$(grep -n 'omarchy-pkg-add samplepkg' "$home/calls.log" | head -n 1 | cut -d: -f1)
plugin_line=$(grep -n 'omarchy-plugin-add --yes --enable' "$home/calls.log" | head -n 1 | cut -d: -f1)
(( pkg_line < plugin_line )) || fail "packages install before plugins" "$(cat "$home/calls.log")"
grep -q 'New plugins are enabled.' <<<"$output" || fail "install with --yes says new plugins are enabled" "$output"
pass "bundle add --yes enables new plugins"

home=$(new_home plugin-ask)
write_bundle "$home/plug" plug-ask "Plug Ask" '[]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --dry-run "$home/plug")
grep -q 'You will be asked whether to enable the new plugins.' <<<"$output" \
  || fail "interactive dry run says the enable prompt will be asked" "$output"
if script -qec true /dev/null >/dev/null 2>&1; then
  mkdir -p "$home/bin"
  cat >"$home/bin/omarchy-plugin-add" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-add %s\n' "$*" >>"$HOME/calls.log"
echo "Added example.plugin into $HOME/plugins/example.plugin"
exit 0
EOF
  cat >"$home/bin/gum" <<'EOF'
#!/bin/bash
printf 'gum %s\n' "$*" >>"$HOME/calls.log"
if [[ $* == *"Enable this bundle's plugins?"* ]]; then
  exit 1
fi
exit 0
EOF
  chmod +x "$home/bin/omarchy-plugin-add" "$home/bin/gum"
  status=0
  raw=$(
    HOME="$home" \
      XDG_DATA_HOME="$home/.local/share" \
      XDG_STATE_HOME="$home/.local/state" \
      XDG_CONFIG_HOME="$home/.config" \
      PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
      script -qec "'$ROOT/bin/omarchy-bundle-add' '$home/plug'" /dev/null
  ) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status == 0 )) || fail "declining plugin enable aborted the install" "$output"
  calls_have "$home" "omarchy-plugin-add --yes -- https://example.test/gamemode-switcher.git" \
    || fail "declining enable adds the plugin without --enable" "$(cat "$home/calls.log")"
  if grep -q -- '--enable' "$home/calls.log"; then
    fail "declining enable still passed --enable" "$(cat "$home/calls.log")"
  fi
  grep -q 'Leaving the new plugins disabled.' <<<"$output" || fail "declining enable says the plugins stay disabled" "$output"
  pass "an interactive install can leave new plugins disabled"
else
  skip "script -qec unavailable; skipping the interactive plugin-enable prompt"
fi

# A plugin failure after the packages are installed removes those packages.
home=$(new_home plugin-fail)
write_bundle "$home/plug" plug-fail "Plug Fail" '["failpkg"]' '[]' '["failaur"]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug" 2>&1); then
  fail "a failing plugin still installed the bundle" "$output"
fi
calls_have "$home" "omarchy-pkg-add failpkg" || fail "repo packages were installed before the plugin failed" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-pkg-aur-add failaur" || fail "AUR packages were installed before the plugin failed" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-pkg-drop failpkg" || fail "repo packages are removed when a later step fails" "$(cat "$home/calls.log")"
calls_have "$home" "omarchy-pkg-aur-drop failaur" || fail "AUR packages are removed when a later step fails" "$(cat "$home/calls.log")"
if [[ -f $home/installed.list ]] && grep -qxF failpkg "$home/installed.list"; then
  fail "the repo package stayed installed after the plugin failed" "$(cat "$home/installed.list")"
fi
[[ ! -e $home/.local/state/omarchy/bundles/ledger.json ]] || fail "a failed install wrote a ledger"
[[ ! -e $home/.local/share/omarchy-bundles/plug-fail ]] || fail "a failed install left the bundle copy"
pass "a plugin failure removes the packages installed in that run"

# Introduction notification, and the command that opens it.
home=$(new_home intro)
write_bundle "$home/intro-bundle" intro-bundle "Intro Bundle" '[]'
printf 'How to use Intro Bundle.\n' >"$home/intro-bundle/introduction.md"
jq '.introduction = "introduction.md"' \
  "$home/intro-bundle/bundle.json" >"$home/intro-bundle/bundle.json.next"
mv "$home/intro-bundle/bundle.json.next" "$home/intro-bundle/bundle.json"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-notification-send" <<'EOF'
#!/bin/bash
printf 'omarchy-notification-send %s\n' "$*" >>"$HOME/calls.log"
exit 0
EOF
chmod +x "$home/bin/omarchy-notification-send"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --dry-run "$home/intro-bundle"
)
grep -q 'introduction.md  (notification after install)' <<<"$output" \
  || fail "dry run names the introduction" "$output"
[[ ! -e $home/calls.log ]] || fail "dry run sent a notification" "$(cat "$home/calls.log" 2>/dev/null)"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "$home/intro-bundle"
)
calls_have "$home" "omarchy-notification-send -u normal -t 0 Bundle Intro Bundle installed Click to see the introduction. --exec omarchy-bundle-introduction -- intro-bundle" \
  || fail "install notifies with a click command for the introduction" "$(cat "$home/calls.log")"
cat >"$home/bin/omawrite" <<'EOF'
#!/bin/bash
printf 'omawrite %s\n' "$*" >>"$HOME/calls.log"
exit 0
EOF
cat >"$home/bin/hyprctl" <<'EOF'
#!/bin/bash
printf 'hyprctl %s\n' "$*" >>"$HOME/hypr.log"
if [[ $1 == clients ]]; then
  n=$(cat "$HOME/hypr-clients-n" 2>/dev/null || echo 0)
  n=$((n + 1))
  printf '%s\n' "$n" >"$HOME/hypr-clients-n"
  if (( n == 1 )); then
    printf '%s\n' '[]'
  else
    printf '%s\n' '[{"address":"0xabc","pid":1,"floating":false,"class":"omawrite","title":"introduction.md - Omawrite"}]'
  fi
fi
exit 0
EOF
chmod +x "$home/bin/omawrite" "$home/bin/hyprctl"
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-introduction" -- intro-bundle >/dev/null
grep -q 'omarchy-bundles/intro-bundle/introduction.md' "$home/calls.log" \
  || fail "introduction opens the installed file in omawrite" "$(cat "$home/calls.log")"
grep -F 'hl.dsp.window.float({ window = "address:0xabc", action = "toggle" })' "$home/hypr.log" >/dev/null \
  || fail "introduction floats the new omawrite window" "$(cat "$home/hypr.log")"
grep -F 'hl.dsp.window.center({ window = "address:0xabc" })' "$home/hypr.log" >/dev/null \
  || fail "introduction centers the new omawrite window" "$(cat "$home/hypr.log")"
pass "an introduction opens in omawrite, floating and centered"

# 4b. An installed machine symlinks ~/.local/share/omarchy at the system tree.
home=$(new_home share-link)
system="$HOME_DIR/fake-usr-share-omarchy"
mkdir -p "$system"
ln -s "$system" "$home/.local/share/omarchy"
write_bundle "$home/linked" linked-bundle "Linked" '["linkedpkg"]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/linked" >/dev/null
[[ -d $home/.local/share/omarchy-bundles/linked-bundle ]] \
  || fail "bundle copy missed ~/.local/share/omarchy-bundles" "$(ls -la "$home/.local/share")"
[[ ! -e $system/bundles ]] || fail "bundle copy followed the share/omarchy symlink" "$(find "$system" -maxdepth 2 -type d)"
pass "bundle copy stays off the system omarchy symlink"

# 5. Validate.
output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$ROOT/test/fixtures/bundles/web-developer")
grep -q 'Valid bundle: web-developer 1.0.0' <<<"$output" || fail "web-developer example validates" "$output"
output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$ROOT/test/fixtures/bundles/gamer")
grep -q 'Valid bundle: gamer 1.0.0' <<<"$output" || fail "gamer example validates" "$output"

bad="$HOME_DIR/bad"
mkdir -p "$bad"
jq 'del(.id)' "$ROOT/test/fixtures/bundles/gamer/bundle.json" >"$bad/bundle.json"
if output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$bad" 2>&1); then
  fail "validate accepted a bundle with no id" "$output"
fi
grep -q "missing required field 'id'" <<<"$output" || fail "validate names a missing id" "$output"

jq 'del(.version)' "$ROOT/test/fixtures/bundles/gamer/bundle.json" >"$bad/bundle.json"
if output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$bad" 2>&1); then
  fail "validate accepted a bundle with no version" "$output"
fi
grep -q "missing required field 'version'" <<<"$output" || fail "validate names a missing version" "$output"

jq '.hooks = []' "$ROOT/test/fixtures/bundles/gamer/bundle.json" >"$bad/bundle.json"
if output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$bad" 2>&1); then
  fail "validate accepted an unknown key" "$output"
fi
grep -q "unknown key 'hooks'" <<<"$output" || fail "validate names the unknown key" "$output"

jq '.introduction = "../outside.txt"' "$ROOT/test/fixtures/bundles/gamer/bundle.json" >"$bad/bundle.json"
if output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$bad" 2>&1); then
  fail "validate accepted an introduction path outside the bundle" "$output"
fi
grep -q "introduction path must be a safe relative path" <<<"$output" \
  || fail "validate names an unsafe introduction path" "$output"

jq '.introduction = "missing.md"' "$ROOT/test/fixtures/bundles/gamer/bundle.json" >"$bad/bundle.json"
if output=$(run_bundle "$HOME_DIR" "$ROOT/bin/omarchy-bundle-validate" "$bad" 2>&1); then
  fail "validate accepted a missing introduction file" "$output"
fi
grep -q "introduction file not found" <<<"$output" || fail "validate names a missing introduction" "$output"
pass "validate rejects a missing id, a missing version, and unknown keys"

# 6 and 7 and 9. Project creation, no execution during install, receipt fields.
home=$(new_home project)
bundle="$home/proj-bundle"
mkdir -p "$bundle/project" "$bundle/skills/demo" "$bundle/config"
cat >"$bundle/project/create.sh" <<'EOF'
#!/bin/bash
printf 'ran\n' >"$PROJECT_DIR/ran"
printf 'readme\n' >"$PROJECT_DIR/README.md"
EOF
chmod +x "$bundle/project/create.sh"
printf '# demo\n' >"$bundle/skills/demo/SKILL.md"
printf 'from-bundle\n' >"$bundle/config/sample.txt"
jq -n \
  --arg home "$home" \
  '{
    schemaVersion: 1,
    packageType: "bundle",
    id: "proj",
    name: "Proj",
    version: "2.0.0",
    description: "Project bundle",
    packages: ["projpkg"],
    aurPackages: [],
    plugins: [],
    skills: ["skills/demo"],
    config: [{source: "config/sample.txt", target: "~/.config/proj-sample.txt"}],
    conflicts: [],
    project: {root: "~/Work", layout: ["src", "public"], create: "project/create.sh"}
  }' >"$bundle/bundle.json"
# A second file that would show up if install executed arbitrary bundle files.
cat >"$bundle/escape.sh" <<EOF
#!/bin/bash
printf 'executed\n' >"$home/bundle-executed"
EOF
chmod +x "$bundle/escape.sh"

output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$bundle")
[[ ! -e $home/bundle-executed ]] || fail "install executed a file from the bundle"
[[ ! -e $home/Work/site/ran ]] || fail "install ran the project create script"
grep -q projpkg <<<"$output" || fail "install plan names the package" "$output"
[[ -L $home/.agents/skills/proj-demo ]] || fail "skill is linked into an existing agent folder"
[[ $(readlink "$home/.agents/skills/proj-demo") == "$home/.local/share/omarchy-bundles/proj/skills/demo" ]] \
  || fail "skill link points at the installed bundle"
[[ $(<"$home/.config/proj-sample.txt") == from-bundle ]] || fail "config file was copied"
receipt=$(jq -c '.bundles.proj' "$home/.local/state/omarchy/bundles/ledger.json")
jq -e '.source != "" and .version == "2.0.0" and (.sha256 | test("^[a-f0-9]{64}$")) and (.installed_at | test("^[0-9]{4}-[0-9]{2}-[0-9]{2}T")) and .commit == null' <<<"$receipt" >/dev/null \
  || fail "receipt records source, version, checksum, and installed time" "$receipt"
pass "install copies data, links skills, and records a receipt without running bundle files"

output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-project-new" proj my-site)
[[ -d $home/Work/my-site/src && -d $home/Work/my-site/public ]] || fail "project layout folders were created" "$output"
jq -e '.bundle_id == "proj" and .version == "2.0.0" and (.created_at | length) > 0' \
  "$home/Work/my-site/.omarchy-project" >/dev/null \
  || fail "project marker records the bundle id, version, and created time"
grep -q 'Create script: project/create.sh' <<<"$output" || fail "project creation shows the create script" "$output"
grep -q 'Not running the create script without confirmation.' <<<"$output" \
  || fail "project creation says the script was not run" "$output"
[[ ! -e $home/Work/my-site/ran && ! -e $home/Work/my-site/README.md ]] \
  || fail "create script ran without confirmation"
pass "project-new creates the folder and marker and does not run the script without confirmation"

# 8. Git URL warning, and a registry name stops.
home=$(new_home sources)
git_stub="$home/git-bin"
mkdir -p "$git_stub"
fixture="$home/git-fixture"
write_bundle "$fixture" git-bundle "Git Bundle" '["gitpkg"]'
printf 'abc123\n' >"$home/commit.txt"
BUNDLE_FIXTURE="$fixture" BUNDLE_COMMIT=$(<"$home/commit.txt")
cat >"$git_stub/git" <<'EOF'
#!/bin/bash
if [[ $1 == clone ]]; then
  dest="${!#}"
  mkdir -p "$dest"
  cp -a "$BUNDLE_FIXTURE"/. "$dest"/
  mkdir -p "$dest/.git"
  printf '%s\n' "$BUNDLE_COMMIT" >"$dest/.git/HEAD"
  exit 0
fi
if [[ $1 == -C ]]; then
  cat "$2/.git/HEAD"
  exit 0
fi
printf 'unexpected git %s\n' "$*" >&2
exit 1
EOF
chmod +x "$git_stub/git"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    BUNDLE_FIXTURE="$fixture" \
    BUNDLE_COMMIT=$(<"$home/commit.txt") \
    PATH="$git_stub:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "https://example.test/bundles/git-bundle.git" 2>&1
) || fail "git bundle add failed" "$output"
grep -q 'development/unsafe source' <<<"$output" || fail "git URL prints the unsafe-source warning" "$output"
jq -e --arg commit "$(<"$home/commit.txt")" \
  '.bundles["git-bundle"].source == "https://example.test/bundles/git-bundle.git" and .bundles["git-bundle"].commit == $commit and (.bundles["git-bundle"].sha256 | length) == 64' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "git receipt records the url and commit" "$(jq -c '.bundles["git-bundle"]' "$home/.local/state/omarchy/bundles/ledger.json")"
pass "a git URL warns and the receipt records the commit"

home=$(new_home registry)
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "acme/widgets@1.2.0" 2>&1); then
  fail "registry source was treated as available" "$output"
fi
grep -q 'registry not available yet' <<<"$output" || fail "registry source says the registry is not available" "$output"
[[ ! -e $home/.local/state/omarchy/bundles/ledger.json ]] || fail "registry source wrote a ledger"
pass "publisher/name@version stops because the registry is not available yet"

# Config files the bundle copied are removed when they still match. A file the
# user changed after install is kept. Reinstall leaves that file in place.
# Reset moves it aside and writes the bundle's copy.
home=$(new_home config-unmodified)
write_config_bundle "$home/cfg-bundle" cfg-bundle "from-bundle"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg-bundle" >/dev/null
[[ $(<"$home/.config/note.txt") == from-bundle ]] || fail "config file was copied"
jq -e '.configs["'"$home"'/.config/note.txt"].sha256 | test("^[a-f0-9]{64}$")' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "ledger records a checksum for a copied config" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes cfg-bundle >/dev/null
[[ ! -e $home/.config/note.txt ]] || fail "an unmodified config file is removed with the bundle"
pass "an unmodified copied config is removed"

home=$(new_home config-modified)
write_config_bundle "$home/cfg-bundle" cfg-bundle "from-bundle"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg-bundle" >/dev/null
printf 'user-edit\n' >"$home/.config/note.txt"
output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes cfg-bundle)
[[ $(<"$home/.config/note.txt") == user-edit ]] || fail "a config file changed after install is kept"
grep -q 'kept, you changed it' <<<"$output" || fail "remove plan says the changed config is kept" "$output"
pass "a config file changed after install is kept"

home=$(new_home config-reinstall)
write_config_bundle "$home/cfg-v1" cfg-bundle "from-bundle"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg-v1" >/dev/null
printf 'user-edit\n' >"$home/.config/note.txt"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes cfg-bundle >/dev/null
write_config_bundle "$home/cfg-v2" cfg-bundle "maintainer-v2"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg-v2" >/dev/null
[[ $(<"$home/.config/note.txt") == user-edit ]] || fail "reinstall leaves the user's config in place"
jq -e '.configs["'"$home"'/.config/note.txt"].user_owned == true' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "reinstall records a retained config as the user's" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-reset" --yes cfg-bundle)
[[ $(<"$home/.config/note.txt") == maintainer-v2 ]] || fail "reset writes the installed bundle's config"
shopt -s nullglob
backups=("$home/.config/note.txt.bak."*)
shopt -u nullglob
(( ${#backups[@]} == 1 )) || fail "reset moves the user's config aside" "$(ls -la "$home/.config")"
[[ $(<"${backups[0]}") == user-edit ]] || fail "the reset backup holds the user's config"
grep -q 'note.txt.bak.' <<<"$output" || fail "reset plan names the backup" "$output"
jq -e '.configs["'"$home"'/.config/note.txt"].user_owned == false and (.configs["'"$home"'/.config/note.txt"].sha256 | test("^[a-f0-9]{64}$"))' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "reset records the file as the bundle's copy" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes cfg-bundle >/dev/null
[[ ! -e $home/.config/note.txt ]] || fail "remove after reset deletes the unmodified maintainer copy"
[[ -f ${backups[0]} ]] || fail "the reset backup survives bundle removal"
pass "reset replaces a retained config and later remove deletes the bundle copy"

home=$(new_home config-reset-same)
write_config_bundle "$home/cfg-bundle" cfg-bundle "from-bundle"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg-bundle" >/dev/null
run_bundle "$home" "$ROOT/bin/omarchy-bundle-reset" --yes cfg-bundle >/dev/null
shopt -s nullglob
backups=("$home/.config/note.txt.bak."*)
shopt -u nullglob
(( ${#backups[@]} == 0 )) || fail "reset does not back up a file that already matches" "$(ls -la "$home/.config")"
[[ $(<"$home/.config/note.txt") == from-bundle ]] || fail "reset leaves a matching config in place"
pass "reset skips a config that already matches the bundle"

home=$(new_home config-reset-missing)
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-reset" --yes missing-bundle 2>&1); then
  fail "reset accepted a bundle that is not installed" "$output"
fi
grep -q "is not installed" <<<"$output" || fail "reset names a missing bundle" "$output"
pass "reset refuses a bundle that is not installed"

home=$(new_home config-reset-dry)
write_config_bundle "$home/cfg-bundle" cfg-bundle "from-bundle"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg-bundle" >/dev/null
printf 'user-edit\n' >"$home/.config/note.txt"
output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-reset" --dry-run --yes cfg-bundle)
[[ $(<"$home/.config/note.txt") == user-edit ]] || fail "dry-run reset leaves the user's config"
shopt -s nullglob
backups=("$home/.config/note.txt.bak."*)
shopt -u nullglob
(( ${#backups[@]} == 0 )) || fail "dry-run reset does not write a backup" "$(ls -la "$home/.config")"
grep -q 'Dry run: nothing was reset.' <<<"$output" || fail "dry-run reset says nothing was reset" "$output"
pass "dry-run reset changes nothing"

# A second bundle that names the same plugin git URL keeps the installed plugin.
home=$(new_home plugin-reuse)
write_bundle "$home/plug-a" plug-a "Plug A" '[]'
write_bundle "$home/plug-b" plug-b "Plug B" '[]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug-a/bundle.json" >"$home/plug-a/bundle.json.next"
mv "$home/plug-a/bundle.json.next" "$home/plug-a/bundle.json"
cp "$home/plug-a/bundle.json" "$home/plug-b/bundle.json.next"
jq '.id = "plug-b" | .name = "Plug B"' "$home/plug-b/bundle.json.next" >"$home/plug-b/bundle.json"
rm -f "$home/plug-b/bundle.json.next"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-plugin-add" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-add %s\n' "$*" >>"$HOME/calls.log"
echo "Added example.plugin into $HOME/.config/omarchy/plugins/example.plugin"
mkdir -p "$HOME/.config/omarchy/plugins/example.plugin"
exit 0
EOF
chmod +x "$home/bin/omarchy-plugin-add"
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug-a" >/dev/null
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug-b" >/dev/null
adds=$(grep -c 'omarchy-plugin-add ' "$home/calls.log" || true)
(( adds == 1 )) || fail "a shared plugin URL was added twice" "$(cat "$home/calls.log")"
jq -e '
  .plugins["example.plugin"].user_owned == false
  and ((.plugins["example.plugin"].owners | sort) == ["plug-a", "plug-b"])
  and .plugins["example.plugin"].source == "https://example.test/gamemode-switcher.git"
' "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "both bundles own the plugin that was already installed" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
pass "a second bundle keeps a plugin git URL that is already installed"

# A plugin you installed yourself is kept when a bundle names its git URL.
home=$(new_home plugin-yours)
plugin_dir="$home/.config/omarchy/plugins/example.plugin"
mkdir -p "$plugin_dir"
git -C "$plugin_dir" init -q
git -C "$plugin_dir" remote add origin "https://example.test/gamemode-switcher.git"
write_bundle "$home/plug" plug-yours "Plug Yours" '[]'
jq '.plugins = ["https://example.test/gamemode-switcher"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug" >/dev/null
if [[ -f $home/calls.log ]] && grep -q 'omarchy-plugin-add ' "$home/calls.log"; then
  fail "a bundle tried to add a plugin that is already installed" "$(cat "$home/calls.log")"
fi
jq -e '
  .plugins["example.plugin"].user_owned == true
  and .plugins["example.plugin"].owners == ["plug-yours"]
' "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "a preinstalled plugin is recorded as yours" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes plug-yours >/dev/null
if [[ -f $home/calls.log ]] && grep -q 'omarchy-plugin-remove ' "$home/calls.log"; then
  fail "removing the bundle removed a plugin you installed" "$(cat "$home/calls.log")"
fi
[[ -d $plugin_dir ]] || fail "the preinstalled plugin directory was removed"
pass "a bundle keeps a plugin you installed from the same git URL"

# A plugin that prints Added and then fails is removed with the rest of the install.
home=$(new_home plugin-added-fail)
write_bundle "$home/plug" plug-added-fail "Plug Added Fail" '["failpkg"]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-plugin-add" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-add %s\n' "$*" >>"$HOME/calls.log"
echo "Added demo.plugin into $HOME/.config/omarchy/plugins/demo.plugin"
exit 1
EOF
chmod +x "$home/bin/omarchy-plugin-add"
if output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug" 2>&1
); then
  fail "a plugin that fails after Added still installed the bundle" "$output"
fi
calls_have "$home" "omarchy-plugin-remove --yes -- demo.plugin" \
  || fail "a plugin that landed on disk is removed when enable fails" "$(cat "$home/calls.log")"
[[ ! -e $home/.local/state/omarchy/bundles/ledger.json ]] || fail "a failed plugin install wrote a ledger"
pass "a plugin that fails after it is added is rolled back"

# pacman -Rns must not delete a library that another bundle still owns.
home=$(new_home dep-protect)
printf 'libbar\n' >"$home/installed.list"
write_bundle "$home/owner" lib-owner "Lib Owner" '["libbar"]'
write_bundle "$home/app" app-owner "App Owner" '["app"]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/owner" >/dev/null
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/app" >/dev/null
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes app-owner >/dev/null
grep -qxF -- '-D --asexplicit -- libbar' "$home/pacman-calls.log" \
  || fail "a package another bundle owns is marked explicit before drop" "$(cat "$home/pacman-calls.log")"
calls_have "$home" "omarchy-pkg-drop app" || fail "the removed bundle drops its own package" "$(cat "$home/calls.log")"
if grep -q 'omarchy-pkg-drop libbar' "$home/calls.log"; then
  fail "a package another bundle owns was passed to drop" "$(cat "$home/calls.log")"
fi
grep -qxF libbar "$home/installed.list" || fail "the shared library is still installed" "$(cat "$home/installed.list")"
pass "removing a bundle marks packages another bundle owns before pacman -Rns"

# An install that rolls back also marks packages another bundle still owns.
home=$(new_home dep-rollback)
printf 'libbar\n' >"$home/installed.list"
write_bundle "$home/owner" lib-owner "Lib Owner" '["libbar"]'
write_bundle "$home/plug" roll-owner "Roll Owner" '["failpkg"]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/owner" >/dev/null
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/plug" 2>&1); then
  fail "the failing bundle was installed" "$output"
fi
grep -qxF -- '-D --asexplicit -- libbar' "$home/pacman-calls.log" \
  || fail "rollback marks packages another bundle owns before drop" "$(cat "$home/pacman-calls.log")"
calls_have "$home" "omarchy-pkg-drop failpkg" || fail "rollback drops the package from the failed install" "$(cat "$home/calls.log")"
if grep -q 'omarchy-pkg-drop libbar' "$home/calls.log"; then
  fail "rollback dropped a package another bundle owns" "$(cat "$home/calls.log")"
fi
grep -qxF libbar "$home/installed.list" || fail "the other bundle's package stayed installed" "$(cat "$home/installed.list")"
jq -e '.bundles["lib-owner"] != null and .bundles["roll-owner"] == null' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "rollback left the failed bundle in the ledger" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
pass "an install rollback marks packages another bundle owns before drop"

# Two config entries that land on one file are refused before anything is copied.
home=$(new_home config-dup)
dir="$home/cfg"
write_bundle "$dir" cfg-dup "Cfg Dup" '[]'
mkdir -p "$dir/config"
printf 'a\n' >"$dir/config/a.txt"
printf 'b\n' >"$dir/config/b.txt"
jq '.config = [
  {"source":"config/a.txt","target":"~/.config/note.txt"},
  {"source":"config/b.txt","target":".config/note.txt"}
]' "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$dir" 2>&1); then
  fail "install accepted two config entries for one target" "$output"
fi
grep -q 'same target' <<<"$output" || fail "install names the shared config target" "$output"
[[ ! -e $home/.config/note.txt ]] || fail "a refused bundle copied a config file"
[[ ! -e $home/.local/state/omarchy/bundles/ledger.json ]] || fail "a refused bundle wrote a ledger"
pass "two config entries for one target are refused"

# Two skill folders that share a final link name are refused.
home=$(new_home skill-dup)
dir="$home/skills-bundle"
write_bundle "$dir" skill-dup "Skill Dup" '[]'
mkdir -p "$dir/skills/frontend/setup" "$dir/skills/backend/setup"
printf '# setup\n' >"$dir/skills/frontend/setup/SKILL.md"
printf '# setup\n' >"$dir/skills/backend/setup/SKILL.md"
jq '.skills = ["skills/frontend/setup", "skills/backend/setup"]' \
  "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-validate" "$dir" 2>&1); then
  fail "validate accepted two skills that share a link name" "$output"
fi
grep -q 'skill-dup-setup' <<<"$output" || fail "validate names the shared skill link" "$output"
pass "two skills that share a link name are refused"

# A command waits for the ledger lock, then sees the bundle written while it waited.
home=$(new_home ledger-lock)
write_bundle "$home/first" held-bundle "Held" '[]'
write_bundle "$home/second" second-bundle "Second" '[]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/first" >/dev/null
lock="$home/.local/state/omarchy/bundles/ledger.lock"
flock "$lock" bash -c '
  echo holding >"'"$home"'/lock-state"
  while [[ ! -f "'"$home"'/release-lock" ]]; do sleep 0.05; done
' &
holder=$!
for _ in $(seq 1 50); do
  [[ -f $home/lock-state ]] && break
  sleep 0.05
done
[[ -f $home/lock-state ]] || fail "the lock holder did not start"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/second" >"$home/second.out" 2>&1 &
adder=$!
sleep 0.3
if jq -e '.bundles["second-bundle"] != null' "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null 2>&1; then
  touch "$home/release-lock"
  wait "$holder" || true
  wait "$adder" || true
  fail "the second add wrote the ledger while the lock was held" "$(cat "$home/second.out")"
fi
if ! kill -0 "$adder" 2>/dev/null; then
  touch "$home/release-lock"
  wait "$holder" || true
  fail "the second add exited while the ledger lock was held" "$(cat "$home/second.out")"
fi
touch "$home/release-lock"
wait "$holder"
wait "$adder"
jq -e '.bundles["held-bundle"] != null and .bundles["second-bundle"] != null' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "the waiting add did not keep the bundle written while it waited" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
pass "a bundle command waits for the ledger lock"

# Dry-run remove and reset do not take the ledger lock.
home=$(new_home lock-dry)
write_config_bundle "$home/cfg" cfg-bundle "from-bundle"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/cfg" >/dev/null
lock="$home/.local/state/omarchy/bundles/ledger.lock"
flock "$lock" bash -c '
  echo holding >"'"$home"'/lock-state"
  while [[ ! -f "'"$home"'/release-lock" ]]; do sleep 0.05; done
' &
holder=$!
for _ in $(seq 1 50); do
  [[ -f $home/lock-state ]] && break
  sleep 0.05
done
[[ -f $home/lock-state ]] || fail "the dry-run lock holder did not start"
status=0
timeout 2s env \
  HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-remove" --dry-run --yes cfg-bundle >/dev/null 2>"$home/dry.err" || status=$?
if (( status == 124 )); then
  touch "$home/release-lock"
  wait "$holder" || true
  fail "dry-run remove waited on the ledger lock"
fi
(( status == 0 )) || {
  touch "$home/release-lock"
  wait "$holder" || true
  fail "dry-run remove failed while the ledger lock was held" "$(cat "$home/dry.err")"
}
status=0
timeout 2s env \
  HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-reset" --dry-run --yes cfg-bundle >/dev/null 2>"$home/dry-reset.err" || status=$?
touch "$home/release-lock"
wait "$holder"
if (( status == 124 )); then
  fail "dry-run reset waited on the ledger lock"
fi
(( status == 0 )) || fail "dry-run reset failed while the ledger lock was held" "$(cat "$home/dry-reset.err")"
pass "dry-run remove and reset do not take the ledger lock"

# A package that was already installed, and was not explicit, is not removed.
home=$(new_home dep-keep)
printf 'libbar\n' >"$home/installed.list"
write_bundle "$home/owner" lib-owner "Lib Owner" '["libbar"]'
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/owner" >/dev/null
run_bundle "$home" "$ROOT/bin/omarchy-bundle-remove" --yes lib-owner >/dev/null
if [[ -f $home/calls.log ]] && grep -q 'omarchy-pkg-drop libbar' "$home/calls.log"; then
  fail "a preinstalled dependency was passed to drop" "$(cat "$home/calls.log")"
fi
grep -qxF libbar "$home/installed.list" || fail "the preinstalled dependency is still installed" "$(cat "$home/installed.list" 2>/dev/null)"
if [[ -f $home/.local/state/omarchy/bundles/ledger.json ]] && jq -e '.bundles["lib-owner"] != null' "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null; then
  fail "the bundle stayed installed after removal" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
fi
pass "a preinstalled dependency is kept when its bundle is removed"

# A failed package drop still removes the bundle record.
home=$(new_home drop-fail)
write_bundle "$home/app" app-owner "App Owner" '["stuckpkg"]'
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-pkg-drop" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-drop %s\n' "$*" >>"$HOME/calls.log"
exit 1
EOF
chmod +x "$home/bin/omarchy-pkg-drop"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$home/app" >/dev/null
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-remove" --yes app-owner 2>&1
) || fail "a failed package drop aborted bundle removal" "$output"
grep -q 'leaving those packages installed' <<<"$output" || fail "removal says the packages were left installed" "$output"
grep -qxF stuckpkg "$home/installed.list" || fail "the package that could not be dropped is still installed" "$(cat "$home/installed.list")"
if [[ -f $home/.local/state/omarchy/bundles/ledger.json ]] && jq -e '.bundles["app-owner"] != null' "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null; then
  fail "the bundle record survived a failed package drop" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
fi
pass "a failed package drop still removes the bundle record"

# Manifest text cannot repaint the install plan.
home=$(new_home controls)
dir="$home/bad"
write_bundle "$dir" control-bundle "Clean Name" '[]'
jq --arg name $'Bad\033[2Jname' '.name = $name' "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
if output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-validate" "$dir" 2>&1); then
  fail "validate accepted a name with a control character" "$output"
fi
grep -q 'control character' <<<"$output" || fail "validate names the control character" "$output"
[[ ! -e $home/.local/state/omarchy/bundles/ledger.json ]] || fail "a refused manifest wrote a ledger"
pass "a manifest name with a control character is refused"

# A config file that appears while packages install is left alone, and a failed
# install does not delete it.
home=$(new_home config-race)
dir="$home/cfg"
write_bundle "$dir" cfg-race "Cfg Race" '["racepkg"]'
mkdir -p "$dir/config"
printf 'from-bundle\n' >"$dir/config/note.txt"
jq '.config = [{"source":"config/note.txt","target":"~/.config/note.txt"}] | .plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >>"$HOME/calls.log"
mkdir -p "$HOME/.config"
printf 'user-during-install\n' >"$HOME/.config/note.txt"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  printf '%s\n' "$pkg" >>"$HOME/installed.list"
  printf '%s\n' "$pkg" >>"$HOME/explicit.list"
done
exit 0
EOF
chmod +x "$home/bin/omarchy-pkg-add"
if output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "$dir" 2>&1
); then
  fail "the plugin failure still installed the bundle" "$output"
fi
[[ $(<"$home/.config/note.txt") == user-during-install ]] || fail "a failed install deleted or replaced the config written during package install" "$(cat "$home/.config/note.txt" 2>/dev/null)"
pass "a failed install does not delete a config file it did not write"

# A config file created while packages install is not overwritten.
home=$(new_home config-appeared)
dir="$home/cfg"
write_bundle "$dir" cfg-appeared "Cfg Appeared" '["racepkg"]'
mkdir -p "$dir/config"
printf 'from-bundle\n' >"$dir/config/note.txt"
jq '.config = [{"source":"config/note.txt","target":"~/.config/note.txt"}]' \
  "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >>"$HOME/calls.log"
mkdir -p "$HOME/.config"
printf 'user-during-install\n' >"$HOME/.config/note.txt"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  printf '%s\n' "$pkg" >>"$HOME/installed.list"
  printf '%s\n' "$pkg" >>"$HOME/explicit.list"
done
exit 0
EOF
chmod +x "$home/bin/omarchy-pkg-add"
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-add" --yes "$dir" >/dev/null
[[ $(<"$home/.config/note.txt") == user-during-install ]] || fail "install overwrote a config file created while packages were installing" "$(cat "$home/.config/note.txt")"
jq -e --arg target "$home/.config/note.txt" '.configs[$target].user_owned == true' \
  "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "a config file created during install is recorded as the bundle's copy" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
pass "a config file created during install is left in place"

# An edit saved while packages are being removed is kept.
home=$(new_home config-during-remove)
dir="$home/cfg"
write_bundle "$dir" cfg-bundle "Cfg" '["apppkg"]'
mkdir -p "$dir/config"
printf 'from-bundle\n' >"$dir/config/note.txt"
jq '.config = [{"source":"config/note.txt","target":"~/.config/note.txt"}]' \
  "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --yes "$dir" >/dev/null
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-pkg-drop" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-drop %s\n' "$*" >>"$HOME/calls.log"
printf 'edited-during-remove\n' >"$HOME/.config/note.txt"
exit 0
EOF
chmod +x "$home/bin/omarchy-pkg-drop"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-remove" --yes cfg-bundle 2>&1
)
[[ $(<"$home/.config/note.txt") == edited-during-remove ]] || fail "an edit during package removal was deleted" "$(cat "$home/.config/note.txt" 2>/dev/null)"
pass "an edit saved during package removal is kept"

# A changed plugin checkout and a retargeted skill link are kept.
home=$(new_home plugin-dirty)
plugin_id="example.plugin"
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-plugin-add" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-add %s\n' "$*" >>"$HOME/calls.log"
dir="$HOME/.config/omarchy/plugins/example.plugin"
mkdir -p "$dir"
git -C "$dir" init -q
git -C "$dir" -c user.email=test@example.test -c user.name=test commit --allow-empty -q -m init
echo "Added example.plugin into $dir"
exit 0
EOF
cat >"$home/bin/omarchy-plugin-remove" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-remove %s\n' "$*" >>"$HOME/calls.log"
exit 0
EOF
chmod +x "$home/bin/omarchy-plugin-add" "$home/bin/omarchy-plugin-remove"
dir="$home/plug"
write_bundle "$dir" plug-dirty "Plug Dirty" '[]'
mkdir -p "$dir/skills/demo"
printf '# demo\n' >"$dir/skills/demo/SKILL.md"
jq '.plugins = ["https://example.test/gamemode-switcher.git"] | .skills = ["skills/demo"]' \
  "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-add" --yes "$dir" >/dev/null
git -C "$home/.config/omarchy/plugins/$plugin_id" -c user.email=test@example.test -c user.name=test commit --allow-empty -q -m edited
ln -sfn /tmp/not-the-bundle "$home/.agents/skills/plug-dirty-demo"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-remove" --yes plug-dirty 2>&1
)
if grep -q 'omarchy-plugin-remove ' "$home/calls.log"; then
  fail "a plugin with a new commit was removed" "$(cat "$home/calls.log")"
fi
[[ -d $home/.config/omarchy/plugins/$plugin_id ]] || fail "the edited plugin directory was removed"
[[ -L $home/.agents/skills/plug-dirty-demo ]] || fail "a retargeted skill link was removed"
grep -q 'local changes' <<<"$output" || fail "removal says the plugin was kept" "$output"
pass "a changed plugin and a retargeted skill link are kept"

# An unchanged plugin checkout and skill link are removed.
home=$(new_home plugin-clean)
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-plugin-add" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-add %s\n' "$*" >>"$HOME/calls.log"
dir="$HOME/.config/omarchy/plugins/example.plugin"
mkdir -p "$dir"
git -C "$dir" init -q
git -C "$dir" -c user.email=test@example.test -c user.name=test commit --allow-empty -q -m init
echo "Added example.plugin into $dir"
exit 0
EOF
cat >"$home/bin/omarchy-plugin-remove" <<'EOF'
#!/bin/bash
printf 'omarchy-plugin-remove %s\n' "$*" >>"$HOME/calls.log"
exit 0
EOF
chmod +x "$home/bin/omarchy-plugin-add" "$home/bin/omarchy-plugin-remove"
dir="$home/plug"
write_bundle "$dir" plug-clean "Plug Clean" '[]'
mkdir -p "$dir/skills/demo"
printf '# demo\n' >"$dir/skills/demo/SKILL.md"
jq '.plugins = ["https://example.test/gamemode-switcher.git"] | .skills = ["skills/demo"]' \
  "$dir/bundle.json" >"$dir/bundle.json.next"
mv "$dir/bundle.json.next" "$dir/bundle.json"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "$dir" 2>&1
)
grep -q 'unsandboxed' <<<"$output" || fail "bundle add did not warn that plugins are unsandboxed" "$output"
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-remove" --yes plug-clean >/dev/null
calls_have "$home" "omarchy-plugin-remove --yes -- example.plugin" \
  || fail "an unchanged plugin was not removed" "$(cat "$home/calls.log")"
[[ ! -L $home/.agents/skills/plug-clean-demo ]] || fail "an unchanged skill link was kept"
pass "an unchanged plugin and skill link are removed"

# A relative directory shaped like a git URL does not replace the clone.
home=$(new_home git-shadow)
mkdir -p "$home/work/https:/example.test/repo.git"
printf '{}\n' >"$home/work/https:/example.test/repo.git/bundle.json"
mkdir -p "$home/git-bin"
cat >"$home/git-bin/git" <<'EOF'
#!/bin/bash
printf 'git %s\n' "$*" >>"$HOME/git.log"
if [[ $1 == clone ]]; then
  dest="${!#}"
  mkdir -p "$dest"
  printf 'not-the-shadow\n' >"$dest/marker"
  exit 0
fi
if [[ $1 == -C ]]; then
  printf 'abc123\n'
  exit 0
fi
exit 0
EOF
chmod +x "$home/git-bin/git"
output=$(
  cd "$home/work" && \
    HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/git-bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "https://example.test/repo.git" 2>&1
) || true
grep -q 'development/unsafe source' <<<"$output" || fail "a shadowed git URL skipped the unsafe-source warning" "$output"
grep -q 'git clone -- https://example.test/repo.git' "$home/git.log" \
  || fail "a shadowed git URL was not cloned" "$(cat "$home/git.log" 2>/dev/null)"
pass "a git URL is cloned even when a relative directory has that shape"

# An existing folder named *.git is installed from its working tree.
home=$(new_home local-git-dir)
write_bundle "$home/work/demo.git" local-git "Local Git" '[]'
printf 'working-tree\n' >"$home/work/demo.git/extra.txt"
mkdir -p "$home/git-bin"
cat >"$home/git-bin/git" <<'EOF'
#!/bin/bash
printf 'git %s\n' "$*" >>"$HOME/git.log"
exit 1
EOF
chmod +x "$home/git-bin/git"
output=$(
  cd "$home/work" && \
    HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    PATH="$home/git-bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes demo.git 2>&1
) || fail "an existing .git folder was not installed" "$output"
if [[ -f $home/git.log ]] && grep -q 'git clone' "$home/git.log"; then
  fail "an existing .git folder was cloned" "$(cat "$home/git.log")"
fi
[[ $(<"$home/.local/share/omarchy-bundles/local-git/extra.txt") == working-tree ]] \
  || fail "the folder's working tree was not installed" "$(ls -la "$home/.local/share/omarchy-bundles/local-git" 2>/dev/null)"
jq -e '.bundles["local-git"] != null' "$home/.local/state/omarchy/bundles/ledger.json" >/dev/null \
  || fail "the local .git folder was not recorded" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
pass "an existing folder named .git is installed as a local bundle"

# A kept plugin is named by its id, and a credential in a git URL is not stored.
home=$(new_home redact)
plugin_dir="$home/.config/omarchy/plugins/example.plugin"
mkdir -p "$plugin_dir"
git -C "$plugin_dir" init -q
git -C "$plugin_dir" remote add origin "https://example.test/gamemode-switcher.git"
write_bundle "$home/plug" plug-shown "Plug Shown" '[]'
jq '.plugins = ["https://example.test/gamemode-switcher.git"]' \
  "$home/plug/bundle.json" >"$home/plug/bundle.json.next"
mv "$home/plug/bundle.json.next" "$home/plug/bundle.json"
output=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-add" --dry-run --yes "$home/plug")
grep -q 'example.plugin' <<<"$output" || fail "the plan hides the id of a plugin that will be kept" "$output"
mkdir -p "$home/git-bin"
fixture="$home/git-fixture"
write_bundle "$fixture" token-bundle "Token Bundle" '[]'
printf 'abc123\n' >"$home/commit.txt"
cat >"$home/git-bin/git" <<'EOF'
#!/bin/bash
printf 'git %s\n' "$*" >>"$HOME/git.log"
if [[ $1 == clone ]]; then
  dest="${!#}"
  mkdir -p "$dest"
  cp -a "$BUNDLE_FIXTURE"/. "$dest"/
  mkdir -p "$dest/.git"
  printf '%s\n' "$BUNDLE_COMMIT" >"$dest/.git/HEAD"
  exit 0
fi
if [[ $1 == -C ]]; then
  printf '%s\n' "$BUNDLE_COMMIT"
  exit 0
fi
exit 0
EOF
chmod +x "$home/git-bin/git"
output=$(
  HOME="$home" \
    XDG_DATA_HOME="$home/.local/share" \
    XDG_STATE_HOME="$home/.local/state" \
    XDG_CONFIG_HOME="$home/.config" \
    BUNDLE_FIXTURE="$fixture" \
    BUNDLE_COMMIT=$(<"$home/commit.txt") \
    PATH="$home/git-bin:$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-bundle-add" --yes "https://user:token@example.test/token-bundle.git" 2>&1
) || fail "a credentialed git URL failed to install" "$output"
grep -q 'git clone -- https://user:token@example.test/token-bundle.git' "$home/git.log" \
  || fail "clone did not receive the original URL" "$(cat "$home/git.log")"
if grep -q 'user:token@' "$home/.local/state/omarchy/bundles/ledger.json"; then
  fail "the ledger stored a credential from the git URL" "$(cat "$home/.local/state/omarchy/bundles/ledger.json")"
fi
list=$(run_bundle "$home" "$ROOT/bin/omarchy-bundle-list")
if grep -q 'user:token@' <<<"$list"; then
  fail "bundle list printed a credential" "$list"
fi
grep -q 'https://example.test/token-bundle.git' <<<"$list" || fail "bundle list omitted the redacted source" "$list"
pass "kept plugins are named, and git credentials are not stored or listed"

# The ledger lock fd is not inherited by a package-install child.
home=$(new_home lock-fd)
write_bundle "$home/app" lock-fd "Lock Fd" '["lockpkg"]'
mkdir -p "$home/bin"
cat >"$home/bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
printf 'omarchy-pkg-add %s\n' "$*" >>"$HOME/calls.log"
leaked=0
for fd in /proc/self/fd/*; do
  target=$(readlink -- "$fd" 2>/dev/null || true)
  if [[ $target == *ledger.lock ]]; then
    leaked=1
  fi
done
printf 'lock-leaked %s\n' "$leaked" >>"$HOME/calls.log"
touch "$HOME/installed.list" "$HOME/explicit.list"
for pkg in "$@"; do
  printf '%s\n' "$pkg" >>"$HOME/installed.list"
  printf '%s\n' "$pkg" >>"$HOME/explicit.list"
done
exit 0
EOF
chmod +x "$home/bin/omarchy-pkg-add"
HOME="$home" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_CONFIG_HOME="$home/.config" \
  PATH="$home/bin:$stub_dir:$ROOT/bin:$PATH" \
  "$ROOT/bin/omarchy-bundle-add" --yes "$home/app" >/dev/null
calls_have "$home" "lock-leaked 0" || fail "a package install child inherited the ledger lock" "$(cat "$home/calls.log")"
pass "package install does not inherit the ledger lock"

