#!/bin/bash
# omarchy:exclusive - opens a fullscreen menu that takes the keyboard.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_quickshell "menu select app icons test"

# The shipped Docker entry, and apps the fixture names by desktop id, window
# class and the TUI launcher's app id.
qml_fixture_scratch
# Nothing the menu runs may reach the desktop's own shell.
printf '#!/bin/bash\nexit 0\n' >"$QML_FIXTURE_TMP/bin/omarchy-shell"
chmod +x "$QML_FIXTURE_TMP/bin/omarchy-shell"
applications="$QML_FIXTURE_TMP/home/.local/share/applications"
mkdir -p "$applications"
cp "$ROOT/default/applications/Docker.desktop" "$applications/"
printf '[Desktop Entry]\nType=Application\nName=Fixture Direct\nExec=fixture-direct\nIcon=fixture-direct-icon\nStartupWMClass=FixtureClass\n' >"$applications/fixture-direct.desktop"
icons="$QML_FIXTURE_TMP/home/.local/share/icons/hicolor/scalable/apps"
mkdir -p "$icons"
printf '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"><rect width="16" height="16"/></svg>\n' >"$icons/fixture-direct-icon.svg"
printf '[Desktop Entry]\nType=Application\nName=Fixture Top\nExec=fixturetop\nTerminal=true\nIcon=fixture-top\n' >"$applications/fixture-top.desktop"

# A cloned dock is copied out of the shell tree and gets no app library. Its
# window matcher, taken from the real Dock.qml with that file's imports, runs
# from a clone's directory so the fixture can check what a clone resolves.
clone="$QML_FIXTURE_TMP/home/.config/omarchy/plugins/dock-clone"
mkdir -p "$clone"
cp "$ROOT/shell/plugins/dock/"*.js "$clone/"
{
  grep '^import ' "$ROOT/shell/plugins/dock/Dock.qml"
  printf 'Item {\n  id: root\n  property var shell: null\n  readonly property var appLibrary: null\n'
  awk '/^  function entryForAppId\(/ { on = 1 } on { print } on && /^  }$/ { exit }' "$ROOT/shell/plugins/dock/Dock.qml"
  printf '}\n'
} >"$clone/DockMatch.qml"

run_qml_fixture menu-select-icons "menu select draws app icons matched like the dock, cloned docks included" Ui Commons services
