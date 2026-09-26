#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

shell_qml="$ROOT/shell/shell.qml"

# Normalize horizontal and vertical whitespace so the wiring assertions survive
# harmless QML reflow.
qml_matches() {
  local file=$1
  local pattern=$2

  tr '\n\r\t' '   ' < "$file" | grep -Eq "$pattern"
}

# Cloned / third-party keepLoaded menus only get `shell` in Loader.onLoaded.
# prunePluginApis can destroy that scoped facade during startup (before
# shell.json resolves enabled state) or on a capability-profile change; without
# a follow-up reinjection the live Loader item keeps a null shell and apps
# vanish from search (#12944 / #12989).
qml_matches "$shell_qml" 'function +reinjectLoadedPanelShellApis\( *\)' ||
  fail "keepLoaded panels have no shell-API reinjection helper after prune"
qml_matches "$shell_qml" 'shell\.reinjectLoadedPanelShellApis\( *\)' ||
  fail "syncPluginApis does not reinject scoped APIs into loaded panels"
qml_matches "$shell_qml" 'for *\( *var +id +in +panelLoaders *\)' ||
  fail "panel shell reinjection does not walk registered panel loaders"
qml_matches "$shell_qml" 'item\.shell *= *shell\.pluginShellFor\( *manifest *\)' ||
  fail "panel shell reinjection does not reassign pluginShellFor"
# Initial mount path must still inject once on load.
qml_matches "$shell_qml" 'onLoaded: *\{[^}]*item\.shell *= *shell\.pluginShellFor\( *panelEntry\.manifest *\)' ||
  fail "panel Loader.onLoaded no longer injects scoped shell on first mount"
pass "keepLoaded panel/menu shell APIs are reinjected after prune"

# Services already recover via _syncServices; this bug is panels/menus only.
qml_matches "$shell_qml" 'kept\.shell *= *shell\.pluginShellFor\( *m *\)' ||
  fail "kept services no longer receive a refreshed scoped shell"
pass "service keepLoaded shell reassignment remains in place"
