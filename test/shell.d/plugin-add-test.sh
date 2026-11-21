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

# --- Bar section prompt ---------------------------------------------------
#
# Enabling interactively asks which bar section a new widget goes in. A clone
# (manifest `omarchy.clonedFrom`) whose source is on the bar takes over the
# source's slot instead, so it must not be asked: the answer would become a move
# out of that slot. With its source off the bar it has no slot to take and is
# asked like any new widget. Runs on a pty like the gum-prompt case above; gum,
# the shell and enable are stubbed.

if script -qec true /dev/null >/dev/null 2>&1; then
  place_stubs="$TMPDIR/place-stubs"
  mkdir -p "$place_stubs"
  cat >"$place_stubs/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
  cat >"$place_stubs/omarchy-plugin-catalog" <<'STUB'
#!/bin/bash
echo '[]'
STUB
  cat >"$place_stubs/omarchy-plugin-list" <<'STUB'
#!/bin/bash
jq -n --arg id "$PLACE_ID" --arg on "$PLACE_SOURCE_ON_BAR" \
  '[{id: $id, enabled: false}, {id: "omarchy.monitor", enabled: ($on == "1")}]'
STUB
  cat >"$place_stubs/omarchy-plugin-enable" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >"$PLACE_ENABLED"
STUB
  cat >"$place_stubs/gum" <<'STUB'
#!/bin/bash
if [[ $1 == "choose" ]]; then
  touch "$PLACE_ASKED"
  echo right
fi
exit 0
STUB
  chmod +x "$place_stubs"/*

  add_and_enable() {
    local id="$1"
    local source="$TMPDIR/place-$id"
    local home="$TMPDIR/place-home-$id"
    write_plugin "$source" "$id" "Placed"
    if [[ -n ${2:-} ]]; then
      jq --arg from "$2" '. + {omarchy: {clonedFrom: $from}}' "$source/manifest.json" >"$source/manifest.tmp"
      mv "$source/manifest.tmp" "$source/manifest.json"
    fi
    git -C "$source" init -q
    git -C "$source" add .
    git -C "$source" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"
    rm -f "$TMPDIR/place-asked" "$TMPDIR/place-enabled"
    PLACE_ID="$id" PLACE_SOURCE_ON_BAR="${3:-1}" PLACE_ASKED="$TMPDIR/place-asked" PLACE_ENABLED="$TMPDIR/place-enabled" \
      HOME="$home" OMARCHY_PATH="$ROOT" PATH="$place_stubs:$ROOT/bin:$PATH" \
      script -qec "omarchy-plugin-add '$source' --enable" /dev/null 2>&1
  }

  output=$(add_and_enable acme.fresh) ||
    fail "plugin add enables a new bar widget interactively" "$output"
  [[ -e $TMPDIR/place-asked ]] ||
    fail "plugin add asks where to place a new bar widget" "$output"
  [[ $(cat "$TMPDIR/place-enabled") == "acme.fresh --section right" ]] ||
    fail "plugin add enables a new bar widget in the chosen section" "$(cat "$TMPDIR/place-enabled")"
  pass "plugin add asks which bar section a new widget goes in"

  output=$(add_and_enable acme.clone omarchy.monitor) ||
    fail "plugin add enables a cloned bar widget interactively" "$output"
  [[ ! -e $TMPDIR/place-asked ]] ||
    fail "plugin add does not ask where to place a clone" "$output"
  [[ $(cat "$TMPDIR/place-enabled") == "acme.clone" ]] ||
    fail "plugin add enables a clone without a placement" "$(cat "$TMPDIR/place-enabled")"
  pass "plugin add leaves a clone in the slot of the widget it replaces"

  output=$(add_and_enable acme.loose omarchy.monitor 0) ||
    fail "plugin add enables a clone of a widget that is off the bar" "$output"
  [[ -e $TMPDIR/place-asked ]] ||
    fail "plugin add asks where to place a clone whose source is off the bar" "$output"
  [[ $(cat "$TMPDIR/place-enabled") == "acme.loose --section right" ]] ||
    fail "plugin add enables a clone with no slot to take in the chosen section" "$(cat "$TMPDIR/place-enabled")"
  pass "plugin add asks where a clone goes when its source is off the bar"
else
  skip "script -qec unavailable; skipping the bar section prompt cases"
fi
