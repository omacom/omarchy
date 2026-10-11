#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

shell_qml="$ROOT/shell/shell.qml"
registry_qml="$ROOT/shell/services/PluginRegistry.qml"

# Normalize horizontal and vertical whitespace so the wiring assertions survive
# harmless QML reflow. The registry contract fixture covers the behaviour with a
# compositor; these checks stay the guard for the parts a repository can supply:
# the claim in its manifest, which must not be enough on its own.
qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

qml_matches "$registry_qml" 'verifiedCloneSource\( *manifest *\)' ||
  fail "clone provenance is not verified before it is honoured"
qml_matches "$registry_qml" 'claimed === recordedCloneSource\( *config, *manifest\.id *\)' ||
  fail "clone provenance is not compared against the local record"
qml_matches "$registry_qml" 'delete *manifest\.omarchy\.clonedFrom' ||
  fail "an unverified clone claim is not dropped from the manifest"
qml_matches "$registry_qml" 'String\( *manifest\.__cloneSource *\|\| *"" *\) *=== *key' ||
  fail "resolveEnabledId routes a built-in id without the verified clone source"
qml_matches "$registry_qml" 'String\( *candidateManifest\.__cloneSource *\|\| *"" *\) *!== *sourceId' ||
  fail "activeCloneFor matches a clone without the verified clone source"
qml_matches "$registry_qml" 'manifest\.__cloneSource' ||
  fail "setEnabled does not use the verified clone source"
qml_matches "$shell_qml" 'recordCloneProvenance\( *id: *string, *sourceId: *string *\)' ||
  fail "the shell does not expose recordCloneProvenance to the CLI"
qml_matches "$shell_qml" 'forgetCloneProvenance\( *id: *string *\)' ||
  fail "the shell does not expose forgetCloneProvenance to the CLI"

# The record is written by `omarchy plugin clone` before the shell scans the new
# plugin and is withdrawn with the plugin, so it cannot outlive what it names.
grep -q 'omarchy-shell shell recordCloneProvenance "$new_id" "$source_id"' "$ROOT/bin/omarchy-plugin-clone" ||
  fail "omarchy-plugin-clone does not record provenance"
grep -q 'omarchy-shell shell forgetCloneProvenance "$new_id"' "$ROOT/bin/omarchy-plugin-clone" ||
  fail "omarchy-plugin-clone does not withdraw provenance when it fails"
grep -q 'omarchy-shell shell forgetCloneProvenance "$id"' "$ROOT/bin/omarchy-plugin-remove" ||
  fail "omarchy-plugin-remove leaves provenance behind"

# A repository cannot establish provenance, so `omarchy plugin add` refuses the
# claim where its author can see why instead of installing a plugin the shell
# will silently ignore.
grep -q "has(\"clonedFrom\")" "$ROOT/bin/omarchy-plugin-add" ||
  fail "omarchy-plugin-add does not look for a clonedFrom claim"
grep -q "which only a local 'omarchy plugin clone' can establish" "$ROOT/bin/omarchy-plugin-add" ||
  fail "omarchy-plugin-add does not refuse a clonedFrom claim from a repository"

# validate() explains the same thing and still accepts the plugin: a plugin
# being prepared for a local clone is a legitimate thing to validate.
mkdir -p "$TMPDIR/plugin"
cat >"$TMPDIR/plugin/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "tester.claim",
  "name": "Claim",
  "version": "1.0.0",
  "kinds": ["service"],
  "entryPoints": {"service": "Service.qml"},
  "omarchy": {"clonedFrom": "omarchy.polkit"}
}
JSON
cat >"$TMPDIR/plugin/Service.qml" <<'QML'
import QtQuick

Item {}
QML

# Relative path so the check works wherever the harness puts its temp dir.
note=$(cd "$TMPDIR" && PATH="$ROOT/bin:$PATH" omarchy-plugin-validate plugin 2>&1 >/dev/null) ||
  fail "a plugin claiming clonedFrom does not validate"
[[ $note == *"omarchy.clonedFrom is only honoured"* ]] ||
  fail "omarchy-plugin-validate does not explain that clonedFrom is ignored here"

pass "clone provenance is recorded locally and honoured only when it matches"
