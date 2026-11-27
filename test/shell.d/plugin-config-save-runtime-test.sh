#!/bin/bash
# omarchy:exclusive
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_quickshell "plugin rename shell save"
setup_scratch_shell

# Pause the real writer after the shell supplies its old snapshot, before it
# takes the migration lock. The GUI edit must survive a rename in that gap.
rm "$SCRATCH_ROOT/bin"
mkdir "$SCRATCH_ROOT/bin"
for command in "$ROOT"/bin/*; do ln -s "$command" "$SCRATCH_ROOT/bin/"; done
rm "$SCRATCH_ROOT/bin/omarchy-plugin-id"
mkfifo "$SCRATCH_DIR/save-ready" "$SCRATCH_DIR/save-release"
cat > "$SCRATCH_ROOT/bin/omarchy-plugin-id" <<WRITER
#!/bin/bash
if [[ \$1 == "config-save" ]] && mkdir "$SCRATCH_DIR/gated" 2>/dev/null; then
  payload=\$(cat)
  printf ready > "$SCRATCH_DIR/save-ready"
  read -r go < "$SCRATCH_DIR/save-release"
  printf '%s' "\$payload" | "$ROOT/bin/omarchy-plugin-id" config-save
else
  "$ROOT/bin/omarchy-plugin-id" "\$@"
fi
WRITER
chmod +x "$SCRATCH_ROOT/bin/omarchy-plugin-id"
plugin="$SCRATCH_HOME/.config/omarchy/plugins/acme.old"
mkdir -p "$plugin"
printf '%s\n' '{"schemaVersion":1,"id":"acme.old","name":"Rename","version":"1","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"}}' > "$plugin/manifest.json"
printf '%s\n' 'import QtQuick; Item { implicitWidth: 20; implicitHeight: 20 }' > "$plugin/Widget.qml"
jq '.plugins += [{"id":"acme.old","settings":{"value":42}}] | .bar.layout.left += ["acme.old"]' "$ROOT/config/omarchy/shell.json" > "$SCRATCH_HOME/.config/omarchy/shell.json"
start_scratch_shell
wait_scratch_shell
[[ $(scratch_ipc shell setBarWidget omarchy.clock format '"HH:mm:ss"' '{}') == "ok" ]] || fail "shell accepts the settings edit"
# Bound both handshakes: a missing writer must fail, never hang the suite.
timeout 15 cat "$SCRATCH_DIR/save-ready" >/dev/null || { cat "$SCRATCH_LOG"; fail "shell starts its configuration writer"; }
[[ $(scratch_ipc shell setBarWidget omarchy.clock formatAlt '"yyyy"' '{}') == "ok" ]] || fail "shell queues another settings edit"
jq '.id = "acme.new" | .renamedFrom = ["acme.old"]' "$plugin/manifest.json" > "$SCRATCH_DIR/manifest"
mv "$SCRATCH_DIR/manifest" "$plugin/manifest.json"
HOME="$SCRATCH_HOME" OMARCHY_PATH="$SCRATCH_ROOT" "$ROOT/bin/omarchy-plugin-id" migrate "$plugin" acme.old >/dev/null
printf 'go\n' | timeout 15 tee "$SCRATCH_DIR/save-release" >/dev/null
for _ in {1..100}; do
  if jq -e '.pluginIdAliases["acme.old"] == "acme.new" and any(.plugins[]; .id == "acme.new" and .settings.value == 42) and (.bar.layout.left | index("acme.new")) and ([.bar.layout[][] | select(type == "object" and .id == "omarchy.clock") | select(.format == "HH:mm:ss" and .formatAlt == "yyyy")] | length > 0)' "$SCRATCH_HOME/.config/omarchy/shell.json" >/dev/null; then
    pass "real shell save preserves the rename and its queued settings edit"
    exit 0
  fi
  sleep 0.1
done
cat "$SCRATCH_LOG"
cat "$SCRATCH_HOME/.config/omarchy/shell.json"
fail "real shell save preserves the rename and its queued settings edit"
