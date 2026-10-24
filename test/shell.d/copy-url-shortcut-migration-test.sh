#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

require_command jq
require_command python3

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"
# Any browser prompt fails the run, so a pass also proves nobody was asked.
printf '#!/bin/bash\nexit 1\n' >"$stub_bin/gum"
chmod +x "$stub_bin/gum"

ghost_id="ikkebdkaanlebnifjnbeiaklodhbjcci"
pinned_id="bgpiichlckmfanooecilcjemknkcpngb"

run_rerun() {
  HOME="$home" PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" bash -euo pipefail "$ROOT/migrations/1792474908.sh" >/dev/null 2>&1
}

# The first repair skipped Brave Origin, so its ghost binding is still there.
brave_origin="$home/.config/BraveSoftware/Brave-Origin/Default/Preferences"
mkdir -p "$(dirname "$brave_origin")"
jq -n --arg ghost "$ghost_id" '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: $ghost}}, settings: {}}}' >"$brave_origin"

# A profile the first repair fixed keeps its backup, which that repair reads as
# still to verify; with the browser open the rerun must not ask again.
chromium="$home/.config/chromium/Default/Preferences"
mkdir -p "$(dirname "$chromium")"
jq -n --arg pinned "$pinned_id" '{extensions: {commands: {"linux:Alt+Shift+L": {command_name: "copy-url", extension: $pinned}}, settings: {}}}' >"$chromium"
cp "$chromium" "$chromium.omarchy-copy-url-repair.bak"
ln -sfn "test-host-1234" "$home/.config/chromium/SingletonLock"

run_rerun || fail "Brave Origin rerun completes without prompting for profiles the first repair fixed"
jq -e --arg pinned "$pinned_id" '.extensions.commands["linux:Alt+Shift+L"].extension == $pinned' "$brave_origin" >/dev/null ||
  fail "Brave Origin rerun rebinds the Copy URL shortcut to the pinned id"
pass "Brave Origin rerun repairs Brave Origin and leaves already-repaired profiles alone"
