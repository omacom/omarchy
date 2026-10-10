#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'chmod -R u+rw "$TMPDIR"; rm -rf "$TMPDIR"' EXIT

fix() {
  PATH="$ROOT/bin:$PATH" omarchy-plugin-fix-palette "$@"
}

write_manifest() {
  mkdir -p "$1"
  cat >"$1/manifest.json" <<JSON
{
  "schemaVersion": 1,
  "id": "$2",
  "name": "Test",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": { "displayName": "Test", "category": "Test", "allowMultiple": false }
}
JSON
}

expect_file() {
  local file="$1" expected="$2" message="$3"
  [[ $(cat "$file") == "$expected" ]] || fail "$message" "$(cat "$file")"
}

# --- QML ---------------------------------------------------------------------

plugin="$TMPDIR/qml"
write_manifest "$plugin" acme.qml
cat >"$plugin/Widget.qml" <<'QML'
pragma ComponentBehavior: Bound
import QtQuick
  import qs.Commons
import qs.Ui

// Bound to Color.qml through the bar section.
Item {
  property color accent: Color.bar.accent
  property string label: "Color.accent"
  property var spread: [...Color.list, Theme.Color.x]
  Connections { target: Color }
  Connections {
    target: Color
    function onReloaded() { console.log(Color.background) }
  }
}
QML
fix "$plugin"
expect_file "$plugin/Widget.qml" "$(cat <<'QML'
pragma ComponentBehavior: Bound
import QtQuick
  import qs.Commons as Commons
  import qs.Commons
import qs.Ui

// Bound to Color.qml through the bar section.
Item {
  property color accent: Commons.Color.bar.accent
  property string label: "Color.accent"
  property var spread: [...Commons.Color.list, Theme.Color.x]
  Connections { target: Commons.Color }
  Connections {
    target: Commons.Color
    function onReloaded() { console.log(Commons.Color.background) }
  }
}
QML
)" "QML palette references and the alias are rewritten"
pass "QML that imports qs.Commons gets Commons.Color and the alias beside its import"

before=$(sha256sum <"$plugin/Widget.qml")
fix "$plugin"
[[ $(sha256sum <"$plugin/Widget.qml") == "$before" ]] || fail "a second run changes nothing"
pass "the rewrite is idempotent"

plugin="$TMPDIR/aliased"
write_manifest "$plugin" acme.aliased
printf 'import QtQuick\nimport qs.Commons 1.0\nimport qs.Commons as Commons\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
fix "$plugin"
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport qs.Commons 1.0\nimport qs.Commons as Commons\nItem { color: Commons.Color.accent }' \
  "an existing alias is reused"
pass "an existing Commons alias is reused, not duplicated"

plugin="$TMPDIR/foreign"
write_manifest "$plugin" acme.foreign
printf 'import QtQuick\nimport "theme"\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
fix "$plugin"
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport "theme"\nItem { color: Color.accent }' \
  "a file without qs.Commons is left alone"
pass "bare Color in a file that does not import qs.Commons is not the shell palette"

plugin="$TMPDIR/own-color"
write_manifest "$plugin" acme.own
printf 'import QtQuick\nimport qs.Commons\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
printf 'import QtQuick\nQtObject {}\n' >"$plugin/Color.qml"
output=$(fix "$plugin" 2>&1)
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport qs.Commons\nItem { color: Color.accent }' \
  "a plugin with its own Color type is left alone"
grep -qF "defines its own Color type" <<<"$output" || fail "skipping a plugin says why" "$output"
pass "a plugin that ships its own Color type is skipped with a warning"

plugin="$TMPDIR/crlf"
write_manifest "$plugin" acme.crlf
printf 'import QtQuick\r\nimport qs.Commons\r\nItem { color: Color.accent }\r\n' >"$plugin/Widget.qml"
fix "$plugin"
[[ $(cat "$plugin/Widget.qml") == $'import QtQuick\r\nimport qs.Commons as Commons\r\nimport qs.Commons\r\nItem { color: Commons.Color.accent }\r' ]] ||
  fail "CRLF line endings survive" "$(od -c "$plugin/Widget.qml")"
pass "CRLF files keep CRLF on the inserted import"

# --- JavaScript --------------------------------------------------------------

plugin="$TMPDIR/js"
write_manifest "$plugin" acme.js
printf 'import QtQuick\nimport qs.Commons\nimport "Model.js" as Model\nItem { color: Model.accent() }\n' >"$plugin/Widget.qml"
printf 'function accent() { return Color.accent }\n' >"$plugin/Model.js"
printf '.import "theme.js" as Theme\nfunction accent() { return Color.accent }\n' >"$plugin/Other.js"
fix "$plugin"
expect_file "$plugin/Model.js" 'function accent() { return Commons.Color.accent }' \
  "an inheriting script is rewritten"
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport qs.Commons as Commons\nimport qs.Commons\nimport "Model.js" as Model\nItem { color: Model.accent() }' \
  "QML that lends its imports to a rewritten script gains the alias"
expect_file "$plugin/Other.js" $'.import "theme.js" as Theme\nfunction accent() { return Color.accent }' \
  "a script with imports of its own is left alone"
pass "scripts are rewritten only where Color is the shell palette"

plugin="$TMPDIR/js-without-commons"
write_manifest "$plugin" acme.nocommons
printf 'import QtQuick\nimport "Model.js" as Model\nItem {}\n' >"$plugin/Widget.qml"
printf 'function accent() { return Color.accent }\n' >"$plugin/Model.js"
fix "$plugin"
expect_file "$plugin/Model.js" 'function accent() { return Color.accent }' \
  "a script is left alone when no QML in its plugin imports qs.Commons"
pass "a script is only rewritten where a QML file can lend it the alias"

plugin="$TMPDIR/bare-git"
write_manifest "$plugin" acme.baregit
printf 'import qs.Commons\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
git -C "$plugin" init -q --template=
git -C "$plugin" add .
git -C "$plugin" -c user.name=Test -c user.email=test@example.com commit -qm "Initial"
[[ ! -e $plugin/.git/info ]] || fail "the fixture has no .git/info"
fix "$plugin" >/dev/null || fail "a checkout without .git/info is still repaired"
[[ -s $plugin/.git/info/omarchy-fix-palette ]] || fail "the rewrite is recorded"
pass "a checkout without .git/info is repaired and recorded"

plugin="$TMPDIR/edges"
write_manifest "$plugin" acme.edges
printf 'import QtQuick\n// Palette and helpers\nimport qs.Commons // shell palette\nimport "Color.js" as Helpers\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
printf 'function shade(c) { return c }\n' >"$plugin/Color.js"
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" $'import QtQuick\n// Palette and helpers\nimport qs.Commons as Commons\nimport qs.Commons // shell palette\nimport "Color.js" as Helpers\nItem { color: Commons.Color.accent }' \
  "a commented import is recognised and a Color.js path is left alone"
pass "an import with a trailing comment is recognised, and paths and strings are never rewritten"

plugin="$TMPDIR/named"
write_manifest "$plugin" acme.named
printf 'import QtQuick\nimport qs.Commons\nimport "Model.js" as Model\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
printf 'function accent(Color) { return Color.accent }\n' >"$plugin/Model.js"
output=$(fix "$plugin" 2>&1)
expect_file "$plugin/Model.js" 'function accent(Color) { return Color.accent }' \
  "a script that binds Color itself is left alone"
grep -qF "Model.js: Color is also used as a plain name" <<<"$output" || fail "skipping a script says why" "$output"
grep -qF "Commons.Color.accent" "$plugin/Widget.qml" || fail "the QML beside it is still repaired"
pass "a file that binds Color as a plain name is skipped with a warning"

plugin="$TMPDIR/mixed"
write_manifest "$plugin" acme.mixed
printf 'import QtQuick\nimport qs.Commons\nimport "Model.js" as Model\nItem {}\n' >"$plugin/Widget.qml"
printf 'import QtQuick\nimport "Model.js" as Model\nItem {}\n' >"$plugin/Zebra.qml"
printf 'function accent() { return Color.accent }\n' >"$plugin/Model.js"
fix "$plugin" >/dev/null 2>&1
expect_file "$plugin/Model.js" 'function accent() { return Color.accent }' \
  "a script loaded by a QML file without qs.Commons is left alone"
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport qs.Commons\nimport "Model.js" as Model\nItem {}' \
  "its loaders are left alone too"
pass "a script is rewritten only when every QML file loading it imports qs.Commons"

plugin="$TMPDIR/large"
write_manifest "$plugin" acme.large
{ printf 'import QtQuick\nimport qs.Commons\nItem { color: Color.accent }\n'; for i in $(seq 20000); do printf 'Item { width: %s }\n' "$i"; done; } >"$plugin/Widget.qml"
fix "$plugin" >/dev/null
grep -qF "Commons.Color.accent" "$plugin/Widget.qml" || fail "a file larger than a pipe buffer is repaired"
pass "a file larger than a pipe buffer is repaired"

plugin="$TMPDIR/header-example"
write_manifest "$plugin" acme.header
printf '/*\n  Usage:\n  import qs.Commons\n*/\nimport QtQuick\nimport qs.Commons\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" $'/*\n  Usage:\n  import qs.Commons\n*/\nimport QtQuick\nimport qs.Commons as Commons\nimport qs.Commons\nItem { color: Commons.Color.accent }' \
  "the alias goes beside the live import, not an example in a comment"
pass "the alias goes beside the live import when a header comment shows one"

plugin="$TMPDIR/crlf-comment"
write_manifest "$plugin" acme.crlfcomment
printf 'import qs.Commons // palette\r\nItem { color: Color.accent }\r\n' >"$plugin/Widget.qml"
fix "$plugin" >/dev/null
[[ $(cat "$plugin/Widget.qml") == $'import qs.Commons as Commons\r\nimport qs.Commons // palette\r\nItem { color: Commons.Color.accent }\r' ]] ||
  fail "a commented import in a CRLF file is aliased with CRLF" "$(od -c "$plugin/Widget.qml")"
pass "a commented import in a CRLF file is aliased with CRLF"

plugin="$TMPDIR/footer-example"
write_manifest "$plugin" acme.footer
printf 'import QtQuick\nimport qs.Commons\nRectangle { color: Color.accent }\n/* Usage:\nimport qs.Commons\nimport qs.Commons as Commons\n*/\n' >"$plugin/Widget.qml"
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport qs.Commons as Commons\nimport qs.Commons\nRectangle { color: Commons.Color.accent }\n/* Usage:\nimport qs.Commons\nimport qs.Commons as Commons\n*/' \
  "imports shown in a trailing comment are neither aliased nor taken as the alias"
plugin="$TMPDIR/commented-only"
write_manifest "$plugin" acme.commentedonly
printf 'import QtQuick\n// import qs.Commons\n/* import qs.Commons */\nItem { color: Color.accent }\n' >"$plugin/Widget.qml"
before=$(cat "$plugin/Widget.qml")
fix "$plugin" >/dev/null
[[ $(cat "$plugin/Widget.qml") == "$before" ]] || fail "a commented-out import is not an import" "$(cat "$plugin/Widget.qml")"
plugin="$TMPDIR/inline-comment"
write_manifest "$plugin" acme.inline
printf 'import QtQuick /* header note\n   documentation\n*/\nimport qs.Commons\nRectangle { color: Color.accent }\n' >"$plugin/Widget.qml"
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" $'import QtQuick /* header note\n   documentation\n*/\nimport qs.Commons as Commons\nimport qs.Commons\nRectangle { color: Commons.Color.accent }' \
  "a block comment opened after an import does not end the header"
plugin="$TMPDIR/block-after-import"
write_manifest "$plugin" acme.blockafter
printf 'import QtQuick\nimport qs.Commons /* palette */\nimport "Model.js" as Model\nItem {}\n' >"$plugin/Widget.qml"
printf 'function accent() { return Color.accent }\n' >"$plugin/Model.js"
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" $'import QtQuick\nimport qs.Commons as Commons\nimport qs.Commons /* palette */\nimport "Model.js" as Model\nItem {}' \
  "an import followed by a block comment still gets the alias"
expect_file "$plugin/Model.js" 'function accent() { return Commons.Color.accent }' \
  "its script is rewritten once the alias is in place"

plugin="$TMPDIR/unaliasable"
write_manifest "$plugin" acme.unaliasable
printf 'import QtQuick\n/* note */ import qs.Commons\nimport "Model.js" as Model\nItem {}\n' >"$plugin/Widget.qml"
printf 'function accent() { return Color.accent }\n' >"$plugin/Model.js"
output=$(fix "$plugin" 2>&1)
expect_file "$plugin/Model.js" 'function accent() { return Color.accent }' \
  "a script is not rewritten when its loader could not take the alias"
expect_file "$plugin/Widget.qml" $'import QtQuick\n/* note */ import qs.Commons\nimport "Model.js" as Model\nItem {}' \
  "a loader that cannot take the alias is left exactly as it was"
grep -qF "could not rewrite" <<<"$output" || fail "a loader it cannot alias is reported" "$output"
pass "only the live import header counts, whatever the comments around it show"

for source in 'Item { color: Color["accent"] }' $'Connections {\n  target:\n    Color\n}' 'Connections { target: Color; function onChanged() { const Color = {}; x = Color.accent } }'; do
  plugin="$TMPDIR/unclear"
  rm -rf "$plugin"
  write_manifest "$plugin" acme.unclear
  printf 'import qs.Commons\n%s\n' "$source" >"$plugin/Widget.qml"
  before=$(cat "$plugin/Widget.qml")
  output=$(fix "$plugin" 2>&1)
  [[ $(cat "$plugin/Widget.qml") == "$before" ]] || fail "an unclear reference is not rewritten" "$source"
  grep -qF "Color is also used as a plain name" <<<"$output" || fail "an unclear reference is reported" "$source"
done
pass "references it cannot place are reported, never silently left or guessed at"

plugin="$TMPDIR/spaced-target"
write_manifest "$plugin" acme.spaced
printf 'import qs.Commons\nConnections { target : Color }\n' >"$plugin/Widget.qml"
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" $'import qs.Commons as Commons\nimport qs.Commons\nConnections { target : Commons.Color }' \
  "a target with a space before its colon is qualified"
pass "a target with a space before its colon is qualified"

# --- Literal preservation and exact helper paths -----------------------------

plugin="$TMPDIR/literals"
write_manifest "$plugin" acme.literals
cat >"$plugin/Widget.qml" <<'QML'
import QtQuick
import qs.Commons
Item {
  property string label: "Use Color.accent"
  property string key: 'lookup: Color.foreground'
  property string escaped: "quote \" then Color.background // not a comment"
  property string template: `Use Color.accent`
  /* documentation
     Use Color.accent; target: Color
  */
  property color accent: Color.accent /* Use Color.accent */
}
QML
expected=$(cat <<'QML'
import QtQuick
import qs.Commons as Commons
import qs.Commons
Item {
  property string label: "Use Color.accent"
  property string key: 'lookup: Color.foreground'
  property string escaped: "quote \" then Color.background // not a comment"
  property string template: `Use Color.accent`
  /* documentation
     Use Color.accent; target: Color
  */
  property color accent: Commons.Color.accent /* Use Color.accent */
}
QML
)
fix "$plugin" >/dev/null
expect_file "$plugin/Widget.qml" "$expected" "only real palette references change, not strings or comments"
pass "complete QML strings, escapes, template text, and multiline/inline comments are preserved"

plugin="$TMPDIR/literal-only"
write_manifest "$plugin" acme.literalonly
printf 'import qs.Commons\nItem { property string label: "Use Color.accent" }\n' >"$plugin/Widget.qml"
before=$(sha256sum <"$plugin/Widget.qml")
fix "$plugin" >/dev/null
[[ $(sha256sum <"$plugin/Widget.qml") == "$before" ]] || fail "literal-only files are untouched"
pass "literal-only palette mentions do not trigger alias insertion or rewriting"

plugin="$TMPDIR/js-literals"
write_manifest "$plugin" acme.jsliterals
printf 'import qs.Commons\nimport "Model.js" as Model\nItem {}\n' >"$plugin/Widget.qml"
cat >"$plugin/Model.js" <<'JS'
function label() { return "Use Color.accent" }
function key() { return 'lookup: Color.foreground' }
/* documentation: Color.accent */
function accent() { return Color.accent }
JS
fix "$plugin" >/dev/null
expect_file "$plugin/Model.js" "$(cat <<'JS'
function label() { return "Use Color.accent" }
function key() { return 'lookup: Color.foreground' }
/* documentation: Color.accent */
function accent() { return Commons.Color.accent }
JS
)" "JavaScript data and comments are not palette references"
pass "inherited JavaScript preserves strings and comments while qualifying actual palette access"

for source in 'Item { property color accent: Color.accent; property string label: `${Color.accent}` }' 'Item { property color accent: Color.accent; function match(s) { return /Use Color.accent/.test(s) } }'; do
  plugin="$TMPDIR/ambiguous-literals"
  rm -rf "$plugin"
  write_manifest "$plugin" acme.ambiguousliterals
  printf 'import qs.Commons\n%s\n' "$source" >"$plugin/Widget.qml"
  before=$(sha256sum <"$plugin/Widget.qml")
  output=$(fix "$plugin" 2>&1)
  [[ $(sha256sum <"$plugin/Widget.qml") == "$before" ]] || fail "ambiguous expression files remain unchanged"
  grep -qF "skipped" <<<"$output" || fail "ambiguous expressions report a skip" "$output"
done
pass "interpolated templates and regex-like syntax are skipped rather than changing literal data"

plugin="$TMPDIR/same-named-helpers"
write_manifest "$plugin" acme.samehelpers
mkdir -p "$plugin/a" "$plugin/b" "$plugin/loaders"
printf 'import qs.Commons\nimport "Model.js" as Model\nItem {}\n' >"$plugin/a/Main.qml"
printf 'import QtQuick\nimport "Model.js" as Model\nItem {}\n' >"$plugin/b/Main.qml"
printf 'import qs.Commons\nimport "./Model.js" as Model\nItem {}\n' >"$plugin/a/Another.qml"
printf 'import qs.Commons\nimport "../a/Model.js" as Model\nItem {}\n' >"$plugin/loaders/Main.qml"
printf '/* example\nimport "../a/Model.js" as Model\n*/\nimport QtQuick\nItem {}\n' >"$plugin/loaders/Comment.qml"
printf 'import QtQuick\nItem { property string note: `import "../a/Model.js" as Model` }\n' >"$plugin/loaders/Literal.qml"
printf 'function accent() { return Color.accent }\n' >"$plugin/a/Model.js"
printf 'function accent() { return Color.accent }\n' >"$plugin/b/Model.js"
fix "$plugin" >/dev/null
expect_file "$plugin/a/Model.js" 'function accent() { return Commons.Color.accent }' "a helper uses only its actual importers"
expect_file "$plugin/b/Model.js" 'function accent() { return Color.accent }' "a same-named helper without Commons remains unchanged"
for file in "$plugin/a/Main.qml" "$plugin/a/Another.qml" "$plugin/loaders/Main.qml"; do
  grep -qF 'import qs.Commons as Commons' "$file" || fail "every actual loader receives the alias" "$file"
done
expect_file "$plugin/b/Main.qml" $'import QtQuick\nimport "Model.js" as Model\nItem {}' "an unrelated loader stays unchanged"
pass "same-named helpers are matched by resolved QML-relative paths, including dot and parent segments"

# --- Files it cannot read ----------------------------------------------------

plugin="$TMPDIR/hostile"
write_manifest "$plugin" acme.hostile
printf 'import QtQuick\nimport qs.Commons\n// caf\xe9\nItem { color: Color.accent }\n' >"$plugin/Latin1.qml"
printf 'import qs.Commons\nItem { color: Color.accent }\n' >"$plugin/Locked.qml"
chmod 000 "$plugin/Locked.qml"
mkdir "$plugin/Dir.qml"
fix "$plugin" 2>/dev/null || fail "unreadable or non-UTF-8 files never fail the command"
grep -qF "Commons.Color.accent" "$plugin/Latin1.qml" || fail "a non-UTF-8 file is still rewritten"
pass "non-UTF-8, unreadable and oddly named files never fail the run"

# --- Migration ---------------------------------------------------------------

test_home="$TMPDIR/home"
plugins="$test_home/.config/omarchy/plugins"
write_manifest "$plugins/me.clone" me.clone
printf 'import QtQuick\nimport qs.Commons\nItem { color: Color.accent }\n' >"$plugins/me.clone/Widget.qml"
write_manifest "$TMPDIR/elsewhere" acme.linked
printf 'import QtQuick\nimport qs.Commons\nItem { color: Color.accent }\n' >"$TMPDIR/elsewhere/Widget.qml"
ln -s "$TMPDIR/elsewhere" "$plugins/acme.linked"

HOME="$test_home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1791448028.sh" >/dev/null
grep -qF "Commons.Color.accent" "$plugins/me.clone/Widget.qml" || fail "the migration repairs installed plugins"
grep -qF "{ color: Color.accent }" "$TMPDIR/elsewhere/Widget.qml" || fail "the migration does not follow a symlinked plugin"
HOME="$TMPDIR/empty" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1791448028.sh" >/dev/null ||
  fail "the migration succeeds without a plugins directory"
pass "the migration repairs installed plugins and skips symlinked ones"

# --- plugin add and update ---------------------------------------------------

stubs="$TMPDIR/stubs"
mkdir -p "$stubs"
printf '#!/bin/bash\nexit 0\n' >"$stubs/omarchy-shell"
chmod +x "$stubs/omarchy-shell"
plugin_cli() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stubs:$ROOT/bin:$PATH" "$@"
}

commit() {
  git -C "$upstream" add .
  git -C "$upstream" -c user.name=Test -c user.email=test@example.com commit -qm "$1"
}

upstream="$TMPDIR/upstream"
write_manifest "$upstream" acme.remote
printf 'import QtQuick\nimport qs.Commons\nItem {\n  color: Color.accent\n}\n' >"$upstream/Widget.qml"
git -C "$upstream" init -q
commit "Initial"

plugin_cli omarchy-plugin-add "$upstream" --yes >/dev/null 2>&1 || fail "plugin add succeeds"
installed="$plugins/acme.remote"
grep -qF "Commons.Color.accent" "$installed/Widget.qml" || fail "plugin add repairs what it installs"
pass "plugin add repairs a plugin as it installs it"

printf 'import QtQuick\nimport qs.Commons\nItem {\n  color: Color.accent\n  width: 10\n}\n' >"$upstream/Widget.qml"
commit "Unrelated change"
plugin_cli omarchy-plugin-update acme.remote --yes >/dev/null 2>&1 || fail "update succeeds over our own rewrite"
grep -qF "width: 10" "$installed/Widget.qml" || fail "the update landed"
grep -qF "Commons.Color.accent" "$installed/Widget.qml" || fail "the update is repaired again"
pass "plugin update fast-forwards over the rewrite and repairs the new head"

printf 'import QtQuick\nimport qs.Commons as Commons\nItem {\n  color: Commons.Color.accent\n  width: 10\n}\n' >"$upstream/Widget.qml"
commit "Author qualifies the palette"
plugin_cli omarchy-plugin-update acme.remote --yes >/dev/null 2>&1 || fail "update succeeds when the author fixes it upstream"
[[ -z $(git -C "$installed" status --porcelain) ]] || fail "the checkout is clean once upstream is fixed" "$(git -C "$installed" status --porcelain)"
pass "plugin update leaves a clean checkout once the author fixes it upstream"

printf 'import QtQuick\nimport qs.Commons\nItem {\n  color: Color.accent\n}\n' >"$upstream/Widget.qml"
commit "Regress"
plugin_cli omarchy-plugin-update acme.remote --yes >/dev/null 2>&1
printf '// mine\n' >>"$installed/Widget.qml"
printf 'import QtQuick\nimport qs.Commons\nItem {\n  color: Color.accent\n  height: 5\n}\n' >"$upstream/Widget.qml"
commit "Touch the edited file"
output=$(plugin_cli omarchy-plugin-update acme.remote --yes 2>&1) && fail "update refuses over a user's own edit" "$output"
grep -qF "// mine" "$installed/Widget.qml" || fail "the user's edit survives a refused update"
grep -qF "Commons.Color.accent" "$installed/Widget.qml" || fail "the rewrite survives a refused update"
pass "a user's own edit to a rewritten file still blocks the fast-forward, as before"

custom="$TMPDIR/custom-upstream"
write_manifest "$custom" acme.custom
printf 'import QtQuick\nimport qs.Commons\nItem {\n  color: Color.accent\n}\n' >"$custom/Widget.qml"
upstream="$custom"
git -C "$upstream" init -q
commit "Initial"
HOME="$TMPDIR/custom-home" OMARCHY_PATH="$ROOT" PATH="$stubs:$ROOT/bin:$PATH" omarchy-plugin-add "$custom" --yes >/dev/null 2>&1 ||
  fail "plugin add succeeds for the customised plugin"
installed="$TMPDIR/custom-home/.config/omarchy/plugins/acme.custom"
git -C "$installed" checkout -q -- Widget.qml
printf '// my tweak\n' >>"$installed/Widget.qml"
rm -f "$installed/.git/info/omarchy-fix-palette"
PATH="$ROOT/bin:$PATH" omarchy-plugin-fix-palette "$installed" >/dev/null
[[ ! -s $installed/.git/info/omarchy-fix-palette ]] || fail "a file the user had already edited is not recorded for restoring"
PATH="$ROOT/bin:$PATH" omarchy-plugin-fix-palette --revert "$installed"
grep -qF "// my tweak" "$installed/Widget.qml" || fail "revert never discards an edit the user made before the rewrite"
pass "an edit made before the rewrite is never restored away"

