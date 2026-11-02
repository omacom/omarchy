#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

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

# Real repositories exercise both installation formats and the shared updater.
package_home="$TMPDIR/package-home"
package_source="$TMPDIR/package-source"
package_dir="$package_home/.config/omarchy/plugins/acme.archive"
write_plugin "$package_source" "acme.archive" "Archive"
mkdir -p "$package_source/tests" "$package_source/docs"
printf 'fixture\n' >"$package_source/tests/fixture"
printf 'notes\n' >"$package_source/docs/notes"
printf 'obsolete\n' >"$package_source/obsolete"
printf '/tests export-ignore\n/docs export-ignore\n' >"$package_source/.gitattributes"
git -C "$package_source" init -q
commit_package() {
  git -C "$package_source" add -A
  git -C "$package_source" -c user.name=Test -c user.email=test@example.com commit -qm "$1"
}
package_command() {
  HOME="$package_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" PLUGIN_SHELL_LOG="$TMPDIR/package-shell.log" "$@"
}
commit_package "Initial package"

HOME="$TMPDIR/checkout-home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$package_source" --yes
checkout_dir="$TMPDIR/checkout-home/.config/omarchy/plugins/acme.archive"
[[ -d $checkout_dir/.git && -f $checkout_dir/tests/fixture ]] || fail "default install must remain a full checkout"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
[[ -z ${PLUGIN_SHELL_LOG:-} ]] || printf '%s\n' "$*" >>"$PLUGIN_SHELL_LOG"
exit 0
STUB
package_command omarchy-plugin-add "$package_source" --archive --yes
[[ -f $package_dir/Widget.qml && ! -e $package_dir/.git && ! -e $package_dir/tests && ! -e $package_dir/docs ]] ||
  fail "archive must contain runtime files without excluded files or git history"
[[ $(jq -r '.commit' "$package_dir/.omarchy-package.json") == "$(git -C "$package_source" rev-parse HEAD)" ]] ||
  fail "archive must record its exact source commit"
pass "archive installation honors export-ignore while default installation remains a checkout"
: >"$TMPDIR/package-shell.log"
package_command omarchy-plugin-update acme.archive --yes
[[ ! -s $TMPDIR/package-shell.log ]] || fail "an up-to-date archive must not rescan the shell"

printf 'changed upstream\n' >"$package_source/new-file"
rm "$package_source/obsolete"
# Changing export rules must also remove files that were previously installed.
printf '/new-file export-ignore\n' >>"$package_source/.gitattributes"
commit_package "Update package"
printf 'local file\n' >"$package_dir/personal"
if package_command omarchy-plugin-update acme.archive --yes; then
  fail "archive update must refuse untracked local files"
fi
[[ -f $package_dir/personal && -f $package_dir/obsolete ]] || fail "refused update changed local files"
rm "$package_dir/personal"
chmod +x "$package_dir/Widget.qml"
if package_command omarchy-plugin-update acme.archive --yes; then
  fail "archive update must preserve local executable-mode changes"
fi
chmod -x "$package_dir/Widget.qml"
# A failed rename after moving the old directory must restore it.
cat >"$stub_dir/mv" <<'STUB'
#!/bin/bash
for arg in "$@"; do
  [[ $arg == */.update.tmp.*/package ]] && exit 1
done
exec /usr/bin/mv "$@"
STUB
chmod +x "$stub_dir/mv"
if package_command omarchy-plugin-update acme.archive --yes; then
  fail "replacement failure must fail the update"
fi
[[ -f $package_dir/obsolete && -f $package_dir/Widget.qml ]] || fail "replacement failure lost the previous package"
rm "$stub_dir/mv"
package_command omarchy-plugin-update --yes
[[ ! -e $package_dir/obsolete && ! -e $package_dir/new-file ]] || fail "archive update left stale or excluded files"
HOME="$TMPDIR/checkout-home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-update acme.archive --yes
[[ -f $checkout_dir/new-file && -d $checkout_dir/.git ]] || fail "checkout update stopped following its original workflow"
pass "both formats update; archives protect local files and honor changed export rules"

installed_commit=$(jq -r '.commit' "$package_dir/.omarchy-package.json")
printf '/Widget.qml export-ignore\n' >>"$package_source/.gitattributes"
commit_package "Broken export"
if package_command omarchy-plugin-update acme.archive --yes; then
  fail "archive update must reject a missing entry point"
fi
[[ -f $package_dir/Widget.qml && $(jq -r '.commit' "$package_dir/.omarchy-package.json") == "$installed_commit" ]] ||
  fail "failed validation replaced the working package"
if HOME="$TMPDIR/broken-home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
  omarchy-plugin-add "$package_source" --archive --yes; then
  fail "archive install must reject a missing entry point"
fi
[[ ! -e $TMPDIR/broken-home/.config/omarchy/plugins/acme.archive ]] || fail "invalid archive was installed"
pass "invalid exports cannot replace or install a plugin"

sed -i '\|/Widget.qml export-ignore|d' "$package_source/.gitattributes"
sed -i 's/acme.archive/acme.changed/' "$package_source/manifest.json"
commit_package "Changed identity"
if package_command omarchy-plugin-update acme.archive --yes; then
  fail "archive update must reject a changed plugin id"
fi
[[ $(jq -r '.commit' "$package_dir/.omarchy-package.json") == "$installed_commit" ]] || fail "identity change replaced installed package"
package_command omarchy-plugin-remove acme.archive --yes
[[ ! -e $package_dir ]] || fail "archive removal left the plugin installed"
backups=("$package_home/.config/omarchy/plugins/.acme.archive.bak."*)
[[ -f ${backups[0]}/Widget.qml && -f ${backups[0]}/.omarchy-package.json ]] || fail "archive removal must preserve the existing non-checkout backup behavior"
pass "archive identity is stable and removal keeps the existing backup behavior"
