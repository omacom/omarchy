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

# Review a real local Git update: the default view must not dump source code,
# and inspecting code must return to a choice rather than approving the update.
if script -qec true /dev/null >/dev/null 2>&1; then
  update_home="$TMPDIR/update-home"
  update_dir="$update_home/.config/omarchy/plugins/acme.same"
  mkdir -p "${update_dir%/*}"
  git -C "$incoming" -c user.name=Test -c user.email=test@example.com commit --allow-empty -qm "Installed revision"
  git clone -q "$incoming" "$update_dir"
  before=$(git -C "$update_dir" rev-parse HEAD)
  previous=$(git -C "$update_dir" rev-parse HEAD^)
  printf 'import QtQuick\nItem { property string detail: "SOURCE_BODY_MARKER" }\n' >"$incoming/Widget.qml"
  git -C "$incoming" add .
  git -C "$incoming" -c user.name=Test -c user.email=test@example.com commit -qm "Improve the weather display"
  after=$(git -C "$incoming" rev-parse HEAD)

  cat >"$stub_dir/gum" <<'STUB'
#!/bin/bash
[[ $1 == "choose" ]] || exit 1
IFS= read -r choice <"$TEST_CHOICES" || exit 130
sed -i '1d' "$TEST_CHOICES"
if [[ $choice == "Update" && -n ${TEST_FETCH_HEAD:-} ]]; then
  printf '%s\n' "$TEST_FETCH_HEAD" >"$TEST_PLUGIN/.git/FETCH_HEAD"
fi
if [[ $choice == "Update" && -n ${TEST_CHECKOUT:-} ]]; then
  git -C "$TEST_PLUGIN" reset --hard -q "$TEST_CHECKOUT"
fi
printf '%s\n' "$choice"
STUB
  cat >"$stub_dir/less" <<'STUB'
#!/bin/bash
cat
STUB
  chmod +x "$stub_dir/gum" "$stub_dir/less"
  choices="$TMPDIR/update-choices"

  review_update() {
    HOME="$update_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
      TEST_CHOICES="$choices" TEST_PLUGIN="$update_dir" TEST_FETCH_HEAD="${TEST_FETCH_HEAD:-}" TEST_CHECKOUT="${TEST_CHECKOUT:-}" \
      script -qec 'omarchy-plugin-update acme.same' /dev/null
  }

  printf 'Skip\n' >"$choices"
  output=$(review_update)
  [[ $output == *"Improve the weather display"* && $output != *"SOURCE_BODY_MARKER"* ]] ||
    fail "plugin update starts with a concise summary instead of source code" "$output"
  [[ $(git -C "$update_dir" rev-parse HEAD) == $before ]] ||
    fail "skipping an update changes the checkout"
  pass "plugin update summarizes changes and skip leaves the checkout alone"

  printf 'Show code changes\nSkip\n' >"$choices"
  output=$(review_update)
  [[ $output == *"SOURCE_BODY_MARKER"* && ! -s $choices ]] ||
    fail "code review returns to the update choices" "$output"
  [[ $(git -C "$update_dir" rev-parse HEAD) == $before ]] ||
    fail "reviewing code applies an update without confirmation"
  pass "plugin update shows code only on request and reviewing does not approve it"

  printf 'Update\n' >"$choices"
  if output=$(TEST_CHECKOUT="$previous" review_update); then
    fail "plugin update accepts a checkout changed during review" "$output"
  fi
  [[ $output == *"changed while reviewing"* ]] ||
    fail "plugin update explains why a changed checkout was refused" "$output"
  [[ $(git -C "$update_dir" rev-parse HEAD) == $previous ]] ||
    fail "plugin update changes the checkout again after refusing a changed HEAD"
  pass "plugin update refuses a changed HEAD even when a fast-forward would still work"
  git -C "$update_dir" reset --hard -q "$before"

  printf 'Update\n' >"$choices"
  output=$(TEST_FETCH_HEAD="$before" review_update)
  [[ $(git -C "$update_dir" rev-parse HEAD) == $after ]] ||
    fail "plugin update applies the reviewed revision even if another fetch changes FETCH_HEAD" "$output"
  [[ $output == *"Updated acme.same."* ]] || fail "plugin update reports completion" "$output"
  pass "plugin update applies exactly the reviewed revision after confirmation"

  git -C "$update_dir" reset --hard -q "$before"
  if output=$(HOME="$update_home" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-plugin-update acme.same 2>&1); then
    fail "non-interactive plugin update proceeds without --yes" "$output"
  fi
  [[ $(git -C "$update_dir" rev-parse HEAD) == $before ]] ||
    fail "non-interactive review mutates the checkout"
  HOME="$update_home" PATH="$stub_dir:$ROOT/bin:$PATH" omarchy-plugin-update acme.same --yes >/dev/null
  [[ $(git -C "$update_dir" rev-parse HEAD) == $after ]] ||
    fail "explicit scripted update no longer works"
  pass "plugin update requires consent and preserves the explicit --yes workflow"
else
  skip "script -qec unavailable; skipping interactive plugin-update review"
fi
