#!/bin/bash

# Marketplace-verified plugin installs. `omarchy plugin add` installs the
# snapshot the plugin marketplace verified unless --head asks for upstream HEAD,
# and `omarchy plugin update` keeps each plugin on the track it was added with.
# Everything runs offline: the catalog is a local file, and git rewrites the
# github.com URL to a local upstream repository.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

REPO_URL="https://github.com/acme/weather"
PLUGIN_ID="acme.weather"

stubs="$TMPDIR/stubs"
mkdir -p "$stubs"
cat >"$stubs/omarchy-shell" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$stubs/omarchy-shell"

upstream="$TMPDIR/upstream"
mkdir -p "$upstream"
cat >"$upstream/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$PLUGIN_ID",
  "name": "Weather",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "Weather",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
git -C "$upstream" init -q -b main

commit_upstream() {
  printf 'import QtQuick\nItem { objectName: "%s" }\n' "$1" >"$upstream/Widget.qml"
  git -C "$upstream" add .
  git -C "$upstream" -c user.name=Test -c user.email=test@example.com -c commit.gpgsign=false \
    commit -qm "$1"
  git -C "$upstream" rev-parse HEAD
}

c1=$(commit_upstream one)
c2=$(commit_upstream two)

catalog="$TMPDIR/catalog.json"
missing_catalog="file://$TMPDIR/missing.json"

# write_catalog <snapshot-status> <verification-commit> <upstream-commit>
write_catalog() {
  jq -n --arg repo "$REPO_URL" --arg status "$1" --arg commit "$2" --arg upstream "$3" '
    (if $commit == "" then null else $commit end) as $verified
    | { plugins: [
        { id: "acme.weather", repo: $repo, sourceType: "community", repositoryLayout: "root-plugin",
          verificationSnapshotStatus: $status, verificationCommit: $verified, upstreamObservedCommit: $upstream },
        { id: "acme.listed", repo: "https://github.com/acme/listed", sourceType: "community", repositoryLayout: "root-plugin",
          verificationSnapshotStatus: "unverified", verificationCommit: null, upstreamObservedCommit: $upstream },
        { id: "acme.suite", repo: "https://github.com/acme/suite", sourceType: "community", repositoryLayout: "suite",
          verificationSnapshotStatus: "verified", verificationCommit: $verified, upstreamObservedCommit: $upstream },
        { id: "omarchy.clock", repo: "https://github.com/omacom/omarchy", sourceType: "builtin" }
      ] }
  ' >"$catalog"
}

test_home="$TMPDIR/home"
plugins_dir="$test_home/.config/omarchy/plugins"
plugin_dir="$plugins_dir/$PLUGIN_ID"

run() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stubs:$ROOT/bin:$PATH" \
    OMARCHY_PLUGIN_CATALOG_URL="${CATALOG_URL:-file://$catalog}" \
    GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0="url.$upstream.insteadOf" GIT_CONFIG_VALUE_0="$REPO_URL" \
    "$@" 2>&1
}

installed_commit() {
  git -C "$plugin_dir" rev-parse HEAD
}

installed_channel() {
  git -C "$plugin_dir" config --get omarchy.channel || true
}

reset_install() {
  rm -rf "$plugins_dir"
}

# --- Lookup ----------------------------------------------------------------

write_catalog verified "$c1" "$c2"
output=$(run omarchy-plugin-marketplace-lookup \
  "https://github.com/Acme/Weather.git" \
  "git@github.com:acme/weather.git" \
  "ssh://git@github.com/acme/weather/" \
  "https://github.com/acme/listed" \
  "https://github.com/acme/suite" \
  "https://github.com/acme/elsewhere" \
  "https://github.com/omacom/omarchy" \
  "$upstream")
expected="verified $c1 $c2
verified $c1 $c2
verified $c1 $c2
unverified - $c2
unverified - -
unlisted - -
unlisted - -
unlisted - -"
[[ $output == "$expected" ]] ||
  fail "marketplace lookup classifies verified, listed, unlisted, and non-GitHub repositories" "$output"
pass "marketplace lookup classifies verified, listed, unlisted, and non-GitHub repositories"

output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-marketplace-lookup "$REPO_URL" "$upstream")
[[ $output == $'unreachable - -\nunlisted - -' ]] ||
  fail "marketplace lookup reports a missing catalog as unreachable for GitHub URLs only" "$output"
printf 'not json\n' >"$TMPDIR/broken.json"
output=$(CATALOG_URL="file://$TMPDIR/broken.json" run omarchy-plugin-marketplace-lookup "$REPO_URL")
[[ $output == "unreachable - -" ]] ||
  fail "marketplace lookup reports an unparseable catalog as unreachable" "$output"
pass "marketplace lookup reports an unusable catalog as unreachable"

# --- Add -------------------------------------------------------------------

write_catalog verified "$c1" "$c2"
output=$(run omarchy-plugin-add "$REPO_URL" --yes) ||
  fail "plugin add installs a marketplace-verified plugin" "$output"
[[ $(installed_commit) == $c1 ]] ||
  fail "plugin add installs the verified snapshot rather than upstream HEAD" "$output"
[[ $(installed_channel) == "verified" ]] ||
  fail "plugin add records that the plugin follows verified snapshots" "$output"
grep -qF "not a security audit" <<<"$output" ||
  fail "plugin add does not present verification as a security audit" "$output"
grep -qF "pass --head to install those instead" <<<"$output" ||
  fail "plugin add says newer upstream commits are unverified" "$output"
pass "plugin add installs the marketplace-verified snapshot by default"

# --- Update on the verified track ------------------------------------------

c3=$(commit_upstream three)
write_catalog verified "$c2" "$c3"
output=$(run omarchy-plugin-update "$PLUGIN_ID" --yes) ||
  fail "plugin update moves a verified plugin forward" "$output"
[[ $(installed_commit) == $c2 ]] ||
  fail "plugin update moves a verified plugin to the new verified snapshot, not upstream HEAD" "$output"
grep -qF "omarchy plugin update $PLUGIN_ID --head" <<<"$output" ||
  fail "plugin update points at --head for newer unverified commits" "$output"
pass "plugin update moves a verified plugin to the newest verified snapshot"

output=$(run omarchy-plugin-update --yes) ||
  fail "a bulk plugin update succeeds with a verified plugin already current" "$output"
[[ $(installed_commit) == $c2 ]] && grep -qF "is up to date with verified snapshot" <<<"$output" ||
  fail "plugin update leaves a plugin at the current verified snapshot alone" "$output"
pass "plugin update leaves a plugin at the current verified snapshot alone"

write_catalog unverified "" "$c3"
output=$(run omarchy-plugin-update "$PLUGIN_ID" --yes) ||
  fail "plugin update succeeds when a verified plugin's snapshot is withdrawn" "$output"
[[ $(installed_commit) == $c2 ]] && grep -qF "has no verified snapshot" <<<"$output" ||
  fail "plugin update holds a plugin in place when its verified snapshot is withdrawn" "$output"
pass "plugin update holds a plugin in place when its verified snapshot is withdrawn"

output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-update "$PLUGIN_ID" --yes) &&
  fail "plugin update reports an unreachable marketplace for a verified plugin" "$output"
[[ $(installed_commit) == $c2 ]] ||
  fail "plugin update leaves a verified plugin in place when the marketplace is unreachable" "$output"
pass "plugin update fails without moving a verified plugin when the marketplace is unreachable"

output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-update "$PLUGIN_ID" --head --yes) ||
  fail "plugin update --head follows upstream without asking the marketplace" "$output"
[[ $(installed_commit) == $c3 && $(installed_channel) == "head" ]] ||
  fail "plugin update --head moves a verified plugin onto upstream HEAD for good" "$output"
c4=$(commit_upstream four)
output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-update "$PLUGIN_ID" --yes) ||
  fail "a plugin switched to upstream HEAD updates without the marketplace" "$output"
[[ $(installed_commit) == $c4 ]] ||
  fail "a plugin switched to upstream HEAD keeps following it" "$output"
pass "plugin update --head switches a verified plugin to following upstream HEAD"

# --- Add on the upstream HEAD track ----------------------------------------

reset_install
write_catalog verified "$c1" "$c4"
output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-add "$REPO_URL" --head --yes) ||
  fail "plugin add --head installs without asking the marketplace" "$output"
[[ $(installed_commit) == $c4 && $(installed_channel) == "head" ]] ||
  fail "plugin add --head installs upstream HEAD" "$output"
grep -qF "skips marketplace verification" <<<"$output" ||
  fail "plugin add --head warns that it skips verification" "$output"
pass "plugin add --head installs upstream HEAD with a warning"

reset_install
write_catalog unverified "" "$c4"
output=$(run omarchy-plugin-add "$REPO_URL" --yes) ||
  fail "plugin add installs a listed plugin that has no verified snapshot" "$output"
[[ $(installed_commit) == $c4 && $(installed_channel) == "head" ]] &&
  grep -qF "has no verified snapshot" <<<"$output" ||
  fail "plugin add installs upstream HEAD with a warning when no snapshot is verified" "$output"
pass "plugin add warns and installs upstream HEAD for a listed plugin with no verified snapshot"

reset_install
printf '{"plugins":[]}\n' >"$catalog"
output=$(run omarchy-plugin-add "$REPO_URL" --yes) ||
  fail "plugin add installs an unlisted plugin" "$output"
[[ $(installed_commit) == $c4 ]] && grep -qF "is not listed on the plugin marketplace" <<<"$output" ||
  fail "plugin add warns that an unlisted plugin is unverified" "$output"
pass "plugin add warns and installs upstream HEAD for an unlisted plugin"

# --- Add fallbacks ---------------------------------------------------------

reset_install
output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-add "$REPO_URL" --yes) ||
  fail "plugin add installs when the marketplace is unreachable" "$output"
[[ $(installed_commit) == $c4 && $(installed_channel) == "head" ]] ||
  fail "plugin add installs upstream HEAD when the marketplace is unreachable" "$output"
grep -qF "Could not reach the plugin marketplace" <<<"$output" ||
  fail "plugin add warns that the marketplace was unreachable" "$output"
pass "plugin add warns and installs upstream HEAD when the marketplace is unreachable"

reset_install
write_catalog verified "ffffffffffffffffffffffffffffffffffffffff" "$c4"
output=$(run omarchy-plugin-add "$REPO_URL" --yes) &&
  fail "plugin add refuses when the verified snapshot is gone upstream" "$output"
[[ ! -e $plugin_dir ]] ||
  fail "plugin add installs nothing when the verified snapshot is gone upstream" "$output"
[[ -z $(find "$plugins_dir" -mindepth 1 -maxdepth 1 -name '.add.tmp.*') ]] ||
  fail "plugin add cleans up its staging checkout when the verified snapshot is gone upstream" "$output"
grep -qF "no longer available upstream" <<<"$output" &&
  grep -qF "omarchy plugin add $REPO_URL --head" <<<"$output" ||
  fail "plugin add explains the missing snapshot and points at --head" "$output"
pass "plugin add refuses to install upstream HEAD in place of a verified snapshot gone upstream"

# --- Checkouts from before verified installs --------------------------------

reset_install
mkdir -p "$plugins_dir"
run git clone -q "$REPO_URL" "$plugin_dir" >/dev/null
git -C "$plugin_dir" reset -q --hard "$c1"
output=$(CATALOG_URL="$missing_catalog" run omarchy-plugin-update "$PLUGIN_ID" --yes) ||
  fail "plugin update updates a checkout with no recorded channel" "$output"
[[ $(installed_commit) == $c4 ]] ||
  fail "plugin update keeps checkouts from before verified installs on upstream HEAD" "$output"
pass "plugin update keeps checkouts from before verified installs on upstream HEAD"
