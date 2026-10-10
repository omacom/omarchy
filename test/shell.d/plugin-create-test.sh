#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/home/.config/omarchy" "$TMPDIR/bin"
PLUGINS="$TMPDIR/home/.config/omarchy/plugins"
CALLS="$TMPDIR/calls"

cat >"$TMPDIR/bin/omarchy-shell" <<'SH'
#!/bin/bash
if [[ $* == *"listPlugins"* ]]; then
  if [[ ${FAKE_NO_DISCOVERY:-0} == 1 ]]; then
    printf '[]\n'
  else
    find "$HOME/.config/omarchy/plugins" -mindepth 2 -maxdepth 2 -name manifest.json -print0 |
      xargs -0 -r jq -s 'map({id: .id, enabled: true})'
  fi
fi
exit 0
SH

cat >"$TMPDIR/bin/omarchy-plugin-enable" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$FAKE_CALLS"
SH
cat >"$TMPDIR/bin/fake-editor" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$FAKE_CALLS"
SH
chmod +x "$TMPDIR/bin/"*

create_plugin() {
  HOME="$TMPDIR/home" USER=tester OMARCHY_PATH="$ROOT" PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
    FAKE_CALLS="$CALLS" OMARCHY_TEST_ROOT="$ROOT" \
    omarchy-plugin-create "$@"
}

create_plugin my-plugin --kind bar-widget --yes >/dev/null
widget="$PLUGINS/tester.my-plugin"

for file in manifest.json README.md BarWidget.qml Panel.qml Model.js; do
  [[ -f $widget/$file ]] || fail "bar widget scaffold is missing $file"
done
pass "scaffold copies a complete built-in starter"

jq -e '
  .schemaVersion == 1 and
  .id == "tester.my-plugin" and
  .name == "my-plugin" and
  .version == "0.1.0" and
  .author == "tester" and
  .kinds == ["bar-widget"] and
  .entryPoints.barWidget == "BarWidget.qml" and
  .barWidget.displayName == "my-plugin" and
  (has("category") | not) and
  (.omarchy? == null)
' "$widget/manifest.json" >/dev/null || fail "bar widget manifest is incorrect"
pass "scaffold writes a manifest for the new plugin"

rg -qF "omarchy.clock" "$widget" -g '*.qml' -g '*.js' &&
  fail "scaffold keeps the starter's runtime id"
grep -q 'moduleName: "tester.my-plugin"' "$widget/BarWidget.qml" ||
  fail "scaffold does not adopt the new id as its module name"
pass "scaffold rewrites the starter's id to the new plugin's id"

[[ ! -e $widget/.git ]] || fail "scaffold starts a git repo without being asked"
pass "scaffold is a plain folder by default"

grep -q "tester.my-plugin" "$widget/README.md" || fail "README does not name the plugin"
pass "scaffold documents the new plugin"

HOME="$TMPDIR/home" OMARCHY_PATH="$ROOT" PATH="$TMPDIR/bin:$ROOT/bin:$PATH" \
  omarchy-plugin-validate "$widget" >/dev/null || fail "scaffold does not validate"
pass "scaffold passes plugin validation"

create_plugin Scratch --kind bar-widget --git --yes >/dev/null
[[ -d $PLUGINS/tester.scratch/.git ]] || fail "--git does not start a git repo"
! git -C "$PLUGINS/tester.scratch" log -1 >/dev/null 2>&1 || fail "--git commits on the author's behalf"
pass "--git starts an uncommitted git repo"

EDITOR="$TMPDIR/bin/fake-editor --wait" create_plugin Editable --kind bar-widget --edit --yes >/dev/null
grep -qx "fake-editor --wait $PLUGINS/tester.editable" "$CALLS" ||
  fail "--edit does not open the new plugin in \$EDITOR"
pass "--edit opens the new plugin in \$EDITOR"

create_plugin "Quick Notes" --kind overlay --yes >/dev/null
overlay="$PLUGINS/tester.quick-notes"
jq -e '
  .id == "tester.quick-notes" and
  .kinds == ["overlay"] and
  (.entryPoints | has("overlay")) and
  (.entryPoints | has("barWidget") | not)
' "$overlay/manifest.json" >/dev/null || fail "overlay scaffold manifest is incorrect"
pass "scaffold derives an id from a multi-word name"

create_plugin Combo --kind both --enable >/dev/null
combo="$PLUGINS/tester.combo"
jq -e '
  .kinds == ["bar-widget", "overlay"] and
  (.entryPoints | has("barWidget")) and
  (.entryPoints | has("overlay"))
' "$combo/manifest.json" >/dev/null || fail "both scaffold does not declare both kinds"
grep -qx 'omarchy-plugin-enable tester.combo' "$CALLS" ||
  fail "--enable does not enable the new plugin"
pass "scaffold combines a bar widget and an overlay starter"

create_plugin Timer --kind bar-widget --from omarchy.weather --yes >/dev/null
jq -e '.entryPoints.barWidget == "BarWidget.qml" and (.barWidget | has("settingsForm") | not)' \
  "$PLUGINS/tester.timer/manifest.json" >/dev/null || fail "--from starter was not used"
pass "--from scaffolds from a chosen built-in"

if create_plugin Broken --kind bar-widget --from omarchy.reminders --yes >/dev/null 2>&1; then
  fail "--from accepts a built-in without the requested kind"
fi
[[ ! -e $PLUGINS/tester.broken ]] || fail "rejected starter leaves a partial plugin behind"
pass "--from requires a built-in of the requested kind"

create_plugin Tray --kind bar-widget --from omarchy.tray --yes >/dev/null
[[ $(find "$PLUGINS/tester.tray" -mindepth 1 -printf '%f\n' | LC_ALL=C sort | paste -sd ' ') == "README.md Tray.qml TrayModel.js manifest.json" ]] ||
  fail "--from a shared-folder built-in copies its neighbours too"
pass "--from copies only the starter's own files out of a shared folder"

if create_plugin Media --kind bar-widget --from omarchy.media --yes >/dev/null 2>&1; then
  fail "--from accepts a built-in that is also a service"
fi
pass "--from refuses a built-in with kinds the scaffold would drop"

create_plugin "../Sneaky.Name" --kind bar-widget --yes >/dev/null
[[ -d $PLUGINS/tester.sneaky-name ]] || fail "dots in a name leak into the plugin id"
pass "scaffold keeps dots out of the derived id"

if create_plugin Combo2 --kind both --from omarchy.clock --yes >/dev/null 2>&1; then
  fail "--from is accepted alongside --kind both"
fi
pass "--from is refused with --kind both"

if create_plugin my-plugin --kind bar-widget --yes >/dev/null 2>&1; then
  fail "scaffold overwrites an existing plugin id"
fi
pass "scaffold refuses an id that is already taken"

if create_plugin Legit --kind service --yes >/dev/null 2>&1; then
  fail "scaffold accepts an unsupported kind"
fi
pass "scaffold refuses an unsupported kind"

if create_plugin --kind bar-widget --yes >/dev/null 2>&1; then
  fail "scaffold invents a name when none is given"
fi
pass "scaffold requires a plugin name"

if FAKE_NO_DISCOVERY=1 create_plugin Ghost --kind bar-widget --enable >/dev/null 2>&1; then
  fail "scaffold succeeds before the shell discovers it"
fi
pass "scaffold reports a plugin the shell never discovered"
