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

# --- Interactive placement of a clone ----------------------------------------
#
# Enabling a clone swaps it into its source's slot, so an interactive add only
# asks for a section when the source is not on the bar to take over.

if script -qec true /dev/null >/dev/null 2>&1; then
  place_stubs="$TMPDIR/place-stubs"
  mkdir -p "$place_stubs"
  cat >"$place_stubs/omarchy-shell" <<'STUB'
#!/bin/bash
case $2 in
  listPlugins)
    printf '[{"id":"omarchy.monitor","enabled":%s},{"id":"acme.display","enabled":false,"clonedFrom":"omarchy.monitor"},{"id":"acme.odd","enabled":false,"clonedFrom":""}]\n' "$SOURCE_ON_BAR" ;;
  enablePlugin)
    printf '%s\n' "$4" >"$ENABLE_LOG"
    echo ok ;;
esac
STUB
  cat >"$place_stubs/gum" <<'STUB'
#!/bin/bash
case $1 in
  choose)
    touch "$CHOOSE_MARKER"
    echo right ;;
esac
STUB
  chmod +x "$place_stubs/omarchy-shell" "$place_stubs/gum"

  clone_repo="$TMPDIR/clone-repo"
  write_plugin "$clone_repo" "acme.display" "Display"
  jq '.omarchy = { clonedFrom: "omarchy.monitor" }' "$clone_repo/manifest.json" >"$clone_repo/manifest.tmp"
  mv "$clone_repo/manifest.tmp" "$clone_repo/manifest.json"
  git -C "$clone_repo" init -q
  git -C "$clone_repo" add .
  git -C "$clone_repo" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"

  add_clone() {
    local home="$TMPDIR/place-home-$1"
    rm -rf "$home" "$TMPDIR/enable-log" "$TMPDIR/choose-marker"
    mkdir -p "$home"
    SOURCE_ON_BAR="$1" ENABLE_LOG="$TMPDIR/enable-log" CHOOSE_MARKER="$TMPDIR/choose-marker" \
      HOME="$home" OMARCHY_PATH="$ROOT" PATH="$place_stubs:$ROOT/bin:$PATH" \
      script -qec "omarchy-plugin-add '${2:-$clone_repo}' --enable" /dev/null 2>&1
  }

  output=$(add_clone true) || fail "plugin add enables a clone whose source is on the bar" "$output"
  [[ ! -e $TMPDIR/choose-marker ]] ||
    fail "plugin add asks for a section for a clone whose source is on the bar" "$output"
  [[ $(cat "$TMPDIR/enable-log") == "{}" ]] ||
    fail "plugin add leaves a clone in its source's slot" "$(cat "$TMPDIR/enable-log")"
  pass "plugin add puts a clone in its source's slot without asking for a section"

  output=$(add_clone false) || fail "plugin add enables a clone whose source is off the bar" "$output"
  [[ -e $TMPDIR/choose-marker ]] ||
    fail "plugin add asks for a section for a clone whose source is off the bar" "$output"
  [[ $(cat "$TMPDIR/enable-log") == '{"section":"right"}' ]] ||
    fail "plugin add places a clone whose source is off the bar where asked" "$(cat "$TMPDIR/enable-log")"
  pass "plugin add asks where to put a clone whose source is off the bar"

  odd_repo="$TMPDIR/odd-repo"
  write_plugin "$odd_repo" "acme.odd" "Odd"
  jq '.omarchy = "not an object"' "$odd_repo/manifest.json" >"$odd_repo/manifest.tmp"
  mv "$odd_repo/manifest.tmp" "$odd_repo/manifest.json"
  git -C "$odd_repo" init -q
  git -C "$odd_repo" add .
  git -C "$odd_repo" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"

  output=$(add_clone false "$odd_repo") || fail "plugin add enables a widget whose omarchy metadata is not an object" "$output"
  [[ $(cat "$TMPDIR/enable-log") == '{"section":"right"}' ]] ||
    fail "plugin add places a widget whose omarchy metadata is not an object" "$output"
  pass "plugin add treats omarchy metadata that is not an object as no clone"
else
  skip "script -qec unavailable; skipping the interactive clone placement cases"
fi
