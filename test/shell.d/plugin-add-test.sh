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

# --- Commit pinning -------------------------------------------------------
#
# A pinned add installs the exact reviewed commit instead of the default
# branch HEAD. From then on a plain update must not silently leave that
# commit: it skips the detached checkout and only an explicit --commit moves
# it. The breakage this catches is a pinned plugin drifting back to mutable
# upstream code while its listing still looks reviewed.

pin_home="$TMPDIR/pin-home"
mkdir -p "$pin_home"
pin_env=(HOME="$pin_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH")
pinned_dir="$pin_home/.config/omarchy/plugins/acme.pinned"

pin_src="$TMPDIR/pin-src"
write_plugin "$pin_src" "acme.pinned" "Pinned"
git -C "$pin_src" init -q
git -C "$pin_src" add .
git -C "$pin_src" -c user.name=Test -c user.email=test@example.com commit -qm one
first=$(git -C "$pin_src" rev-parse HEAD)
printf 'import QtQuick\nItem { property int revision: 2 }\n' >"$pin_src/Widget.qml"
git -C "$pin_src" add .
git -C "$pin_src" -c user.name=Test -c user.email=test@example.com commit -qm two
second=$(git -C "$pin_src" rev-parse HEAD)

output=$(env "${pin_env[@]}" omarchy-plugin-add "$pin_src" --commit "$first" --yes 2>&1) ||
  fail "plugin add --commit installs the requested commit" "$output"
[[ $(git -C "$pinned_dir" rev-parse HEAD) == "$first" ]] ||
  fail "plugin add --commit checks out the exact commit"
! git -C "$pinned_dir" symbolic-ref -q HEAD >/dev/null ||
  fail "plugin add --commit leaves a pinned detached HEAD"

output=$(env "${pin_env[@]}" omarchy-plugin-update --yes 2>&1) ||
  fail "plain update tolerates a pinned plugin" "$output"
grep -qF "pinned at" <<<"$output" ||
  fail "plain update explains why the pinned plugin is skipped" "$output"
[[ $(git -C "$pinned_dir" rev-parse HEAD) == "$first" ]] ||
  fail "plain update leaves the pinned commit untouched"

env "${pin_env[@]}" omarchy-plugin-update acme.pinned --commit "$second" --yes >/dev/null 2>&1 ||
  fail "update --commit moves the pinned plugin"
[[ $(git -C "$pinned_dir" rev-parse HEAD) == "$second" ]] ||
  fail "update --commit lands on the requested commit"

output=$(env "${pin_env[@]}" omarchy-plugin-add "$pin_src" --commit deadbeef --yes 2>&1) &&
  fail "plugin add refuses a short --commit SHA" "$output"
grep -qF "40-character" <<<"$output" ||
  fail "plugin add explains the full-SHA requirement" "$output"

# An empty --commit is a missing review pin, not a floating install: scripts
# passing "--commit $reviewed_sha" with an empty variable must be refused.
output=$(env "${pin_env[@]}" omarchy-plugin-add "$pin_src" --commit "" --yes 2>&1) &&
  fail "plugin add refuses an empty --commit value" "$output"
grep -qF "40-character" <<<"$output" ||
  fail "plugin add names the empty --commit rejection" "$output"

# A pin request for the commit already checked out must still detach a
# branch-attached plugin; otherwise a later plain update would fast-forward
# it to unreviewed code. And a failed pin attempt must restore the original
# branch, not leave the plugin falsely pinned.
float_home="$TMPDIR/float-home"
mkdir -p "$float_home"
float_env=(HOME="$float_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH")
float_dir="$float_home/.config/omarchy/plugins/acme.pinned"

env "${float_env[@]}" omarchy-plugin-add "$pin_src" --yes >/dev/null 2>&1 ||
  fail "floating add still works beside the pinning cases"
printf '{broken\n' >"$pin_src/manifest.json"
git -C "$pin_src" add .
git -C "$pin_src" -c user.name=Test -c user.email=test@example.com commit -qm broken
broken=$(git -C "$pin_src" rev-parse HEAD)

output=$(env "${float_env[@]}" omarchy-plugin-update acme.pinned --commit "$broken" --yes 2>&1) &&
  fail "update --commit refuses a commit that fails validation" "$output"
grep -qF "rolled back" <<<"$output" ||
  fail "failed pinned update reports the rollback" "$output"
git -C "$float_dir" symbolic-ref -q HEAD >/dev/null ||
  fail "failed pinned update restores the original branch attachment"
[[ $(git -C "$float_dir" rev-parse HEAD) == "$second" ]] ||
  fail "failed pinned update restores the original commit"

output=$(env "${float_env[@]}" omarchy-plugin-update acme.pinned --commit "" --yes 2>&1) &&
  fail "plugin update refuses an empty --commit value" "$output"
grep -qF "40-character" <<<"$output" ||
  fail "plugin update names the empty --commit rejection" "$output"

env "${float_env[@]}" omarchy-plugin-update acme.pinned --commit "$second" --yes >/dev/null 2>&1 ||
  fail "an equal-commit pin request succeeds"
! git -C "$float_dir" symbolic-ref -q HEAD >/dev/null ||
  fail "an equal-commit pin request still detaches the floating checkout"

output=$(env "${float_env[@]}" omarchy-plugin-update --yes 2>&1) ||
  fail "plain update tolerates the newly pinned plugin" "$output"
grep -qF "pinned at" <<<"$output" ||
  fail "plain update skips the newly pinned plugin" "$output"
pass "plugin add/update keep a pinned plugin on its exact commit"
