#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
calls="$TMPDIR/calls"

write_plugin() {
  local dir="$1"
  local id="$2"
  local name="$3"

  mkdir -p "$dir"
  cat >"$dir/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$id",
  "name": "$name",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "$name",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
  printf 'import QtQuick\nItem {}\n' >"$dir/Widget.qml"
}

stub_dir="$TMPDIR/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
[[ -n ${OMARCHY_TEST_CALLS:-} ]] && printf '%s\n' "$*" >>"$OMARCHY_TEST_CALLS"
if [[ ${1:-} == shell && ${2:-} == listPlugins ]]; then
  find "$HOME/.config/omarchy/plugins" -mindepth 2 -maxdepth 2 -name manifest.json -type f -print0 2>/dev/null |
    xargs -0 -r jq '{id: .id, name: .name, version: .version, kinds: .kinds, enabled: false, canDisable: true, firstParty: false, clonedFrom: ""}' |
    jq -s .
elif [[ ${1:-} == shell && ${2:-} == enablePlugin ]]; then
  printf 'ok\n'
fi
exit 0
STUB
chmod +x "$stub_dir/omarchy-shell"

test_home="$TMPDIR/home"
write_plugin "$test_home/.config/omarchy/plugins/different-folder" "acme.same" "Installed"

incoming="$TMPDIR/incoming"
write_plugin "$incoming" "acme.same" "Incoming"
git -C "$incoming" init -q
git -C "$incoming" add .
git -C "$incoming" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"

output=$(HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$incoming" --yes 2>&1) &&
  fail "plugin add accepts an id already installed under another directory" "$output"
grep -qF "plugin id 'acme.same' is already used by" <<<"$output" ||
  fail "plugin add explains the installed id collision" "$output"
[[ ! -e $test_home/.config/omarchy/plugins/acme.same ]] ||
  fail "plugin add leaves a target behind after refusing a duplicate id"
pass "plugin add refuses an installed manifest id regardless of directory name"

new_home() {
  test_home="$TMPDIR/home-$1"
  mkdir -p "$test_home"
}

run_add() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" \
    PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-plugin-add "$@"
}

assert_no_stage() {
  local stage
  stage=$(find "$test_home/.config/omarchy/plugins" -maxdepth 1 -name '.add.tmp.*' -print -quit 2>/dev/null || true)
  [[ -z $stage ]] || fail "plugin add leaves a staging directory after failure"
}

valid_source="$TMPDIR/valid-source"
write_plugin "$valid_source" acme.local "Local source"
git -C "$valid_source" init -q
git -C "$valid_source" add .
git -C "$valid_source" -c user.name=Test -c user.email=test@example.com commit -qm Initial

new_home failed-clone
if run_add "$TMPDIR/does-not-exist" --yes >/dev/null 2>&1; then
  fail "plugin add accepts a failed clone"
fi
assert_no_stage
[[ ! -e $test_home/.config/omarchy/plugins/acme.local ]] || fail "failed clone installs a plugin"
pass "failed clones leave no installed plugin or staging directory"

invalid_source="$TMPDIR/invalid-source"
mkdir -p "$invalid_source"
printf '{invalid\n' >"$invalid_source/manifest.json"
git -C "$invalid_source" init -q
git -C "$invalid_source" add .
git -C "$invalid_source" -c user.name=Test -c user.email=test@example.com commit -qm Initial
new_home invalid
if run_add "$invalid_source" --yes >/dev/null 2>&1; then
  fail "plugin add accepts an invalid manifest"
fi
assert_no_stage
[[ -z $(find "$test_home/.config/omarchy/plugins" -mindepth 1 -maxdepth 1 ! -name '.*' -print -quit 2>/dev/null) ]] ||
  fail "invalid manifest leaves a visible installed plugin"
pass "invalid manifests leave no installed plugin or registry-visible directory"

new_home existing-destination
mkdir -p "$test_home/.config/omarchy/plugins/acme.local"
printf 'keep\n' >"$test_home/.config/omarchy/plugins/acme.local/sentinel"
if run_add "$valid_source" --yes >/dev/null 2>&1; then
  fail "plugin add overwrites an existing destination"
fi
grep -q '^keep$' "$test_home/.config/omarchy/plugins/acme.local/sentinel" ||
  fail "plugin add modifies an existing destination"
assert_no_stage
pass "existing destinations are rejected without modification"

new_home local-path
: >"$calls"
run_add "$valid_source" --yes >/dev/null
[[ -f $test_home/.config/omarchy/plugins/acme.local/manifest.json ]] ||
  fail "local path plugin is not installed"
grep -Fqx 'shell discoverPlugins acme.local' "$calls" ||
  fail "local path add does not request targeted discovery"
pass "local repository paths install through targeted discovery"

new_home remote-url
: >"$calls"
run_add "file://$valid_source" --yes --enable >/dev/null
[[ -f $test_home/.config/omarchy/plugins/acme.local/manifest.json ]] ||
  fail "URL plugin is not installed"
grep -Fqx 'shell discoverPlugins acme.local' "$calls" ||
  fail "URL add does not request targeted discovery"
grep -Fq 'shell enablePlugin acme.local {}' "$calls" ||
  fail "add --enable does not enable the discovered plugin"
(( $(grep -Fc 'shell discoverPlugins acme.local' "$calls") == 1 )) ||
  fail "add --enable requests explicit discovery more than once"
pass "URL add --enable discovers once and then enables the new plugin"

# --- URL transport-helper guard -------------------------------------------
#
# The guard refuses git transport helpers (`<name>::…`) and option-shaped URLs
# before `git clone` runs, matching omarchy-theme-install. A git stub records
# whether clone was reached, so the guard is exercised with no network: reaching
# the stub proves a URL passed the guard; not reaching it proves the guard
# rejected the URL first.

guard_stubs="$TMPDIR/guard-stubs"
mkdir -p "$guard_stubs"
cat >"$guard_stubs/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$guard_stubs/omarchy-shell"

clone_marker="$TMPDIR/git-clone-reached"
cat >"$guard_stubs/git" <<STUB
#!/bin/bash
if [[ \$1 == "clone" ]]; then
  touch "$clone_marker"
  exit 1
fi
exit 0
STUB
chmod +x "$guard_stubs/git"

# A gum stub that answers `gum input` with a caller-chosen value, so a test can
# drive any URL through the interactive prompt path.
cat >"$guard_stubs/gum" <<'STUB'
#!/bin/bash
if [[ $1 == "input" ]]; then
  printf '%s\n' "$GUM_INPUT_VALUE"
fi
STUB
chmod +x "$guard_stubs/gum"

add_url() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$guard_stubs:$ROOT/bin:$PATH" \
    omarchy-plugin-add "$1" --yes 2>&1
}

# Transport helpers reach the guard, are named as such, and never reach clone.
for bad in "ext::sh -c touch /tmp/omarchy-guard-test" "fd::17"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects a transport-helper URL: $bad" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add names the transport-helper rejection: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for a transport-helper URL: $bad"
done
pass "plugin add rejects transport-helper URLs before cloning"

# The `://` spelling of the same thing: git resolves git-remote-<scheme> for any
# scheme it does not implement itself, so `ext::` and `ext://` reach the same
# helper and both have to be refused.
for bad in "ext://sh -c id" "gcrypt://example.com/x"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects a transport-scheme URL: $bad" "$output"
  grep -qF "which Omarchy does not clone from" <<<"$output" ||
    fail "plugin add names the transport-scheme rejection: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for a transport-scheme URL: $bad"
done
pass "plugin add rejects transport-scheme URLs before cloning"

# Option-shaped URLs on argv are refused before clone — by the option parser
# (`-*` falls to "unknown add option"), not the guard. The guard's own
# leading-dash arm is only reachable through the interactive gum prompt and is
# exercised separately below.
for bad in "-oProxyCommand=x" "--upload-pack=x"; do
  rm -f "$clone_marker"
  output=$(add_url "$bad") &&
    fail "plugin add rejects an option-shaped URL: $bad" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for an option-shaped URL: $bad"
done
pass "plugin add rejects option-shaped URLs before cloning"

# The guard's leading-dash arm is only reachable through `gum input`: argv
# dashes die in the option parser first. interactive() requires a TTY on stdin
# and stdout, so run this one case on a pty via util-linux `script -qec` (the
# suite's existing pty idiom); gum itself is stubbed, so no rendering happens.
# Probe script's util-linux syntax first and skip cleanly where it is missing.
if script -qec true /dev/null >/dev/null 2>&1; then
  rm -f "$clone_marker"
  status=0
  raw=$(GUM_INPUT_VALUE="-oProxyCommand=x" HOME="$test_home" OMARCHY_PATH="$ROOT" \
    PATH="$guard_stubs:$ROOT/bin:$PATH" \
    script -qec "omarchy-plugin-add --yes" /dev/null) || status=$?
  output=$(tr -d '\r' <<<"$raw")
  (( status != 0 )) ||
    fail "plugin add rejects an option-shaped URL from the gum prompt" "$output"
  grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add names the guard rejection for the gum-prompt URL" "$output"
  [[ ! -e $clone_marker ]] ||
    fail "plugin add reached git clone for an option-shaped gum-prompt URL"
  pass "plugin add guard rejects an option-shaped URL from the interactive prompt"
else
  skip "script -qec unavailable; skipping the interactive gum-prompt guard case"
fi

# Legitimate URL forms pass the guard and reach git clone (stubbed, no network).
for good in \
  "https://github.com/acme/omarchy-weather.git" \
  "git@github.com:acme/repo.git" \
  "ssh://git@github.com/acme/repo.git" \
  "git@[2001:db8::1]:org/repo.git"; do
  rm -f "$clone_marker"
  output=$(add_url "$good") || true
  ! grep -qF "names a git option or transport helper" <<<"$output" ||
    fail "plugin add wrongly rejected a legitimate URL: $good" "$output"
  [[ -e $clone_marker ]] ||
    fail "plugin add did not reach git clone for a legitimate URL: $good" "$output"
done
pass "plugin add lets legitimate git URLs reach git clone"
