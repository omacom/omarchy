#!/usr/bin/env python3
"""Prepare a reversible dev-link tree based on the installed Omarchy release."""
import argparse
import hashlib
import json
import re
from pathlib import Path
import shutil
import subprocess

parser = argparse.ArgumentParser()
parser.add_argument('--source', type=Path, required=True)
parser.add_argument('--installed', type=Path, required=True)
parser.add_argument('--stock-package', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--runtime', type=Path, required=True)
args = parser.parse_args()
repo = args.source.resolve()
trial = args.output.resolve()
if trial.exists():
    raise SystemExit(f'Refusing to overwrite existing trial: {trial}')
if not args.runtime.is_file():
    raise SystemExit('Compiled runtime is missing')
trial.mkdir(parents=True)
kit = trial / 'omarchy'
shutil.copytree(args.installed, kit, symlinks=True)
changed = []


def write(relative, content):
    target = kit / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    # Installed bin entries are absolute symlinks; never follow them on writes.
    if target.is_symlink():
        target.unlink()
    target.write_text(content)
    changed.append(relative)


def block(text, marker):
    start = text.index(marker)
    brace = text.index('{', start)
    depth = 1
    end = brace + 1
    while depth:
        depth += (text[end] == '{') - (text[end] == '}')
        end += 1
    return text[start:end]


for name in ('ToolTipBase', 'ToolTipSurface', 'PanelToolTip', 'HoverCard', 'BorderSurface', 'BorderOverlay'):
    relative = f'shell/Ui/{name}.qml'
    write(relative, (repo / relative).read_text())
for path in (repo / 'shell/styles/Omarchy').iterdir():
    write(f'shell/styles/Omarchy/{path.name}', path.read_text())
relative = 'shell/Ui/qmldir'
text = (kit / relative).read_text()
for name in ('ToolTipBase', 'ToolTipSurface', 'HoverCard'):
    if f'{name} 1.0 ' not in text:
        text += f'\n{name} 1.0 {name}.qml\n'
write(relative, text)

write('shell/Commons/ToolTipStyle.qml', (repo / 'shell/Commons/ToolTipStyle.qml').read_text())
commons_dir = (kit / 'shell/Commons/qmldir').read_text()
if 'singleton ToolTipStyle ' not in commons_dir:
    write('shell/Commons/qmldir', commons_dir + '\nsingleton ToolTipStyle 1.0 ToolTipStyle.qml\n')

relative = 'shell/Ui/Button.qml'
text = (kit / relative).read_text()
old = block(text, '  PanelToolTip {' if '  PanelToolTip {' in text else '  ToolTip {')
new = block((repo / relative).read_text(), '  PanelToolTip {')
write(relative, text.replace(old, new, 1))
relative = 'shell/plugins/bar/Bar.qml'
text = (kit / relative).read_text()
old = block(text, '      ToolTipSurface {\n        id: tooltipBubble' if '      ToolTipSurface {\n        id: tooltipBubble' in text else '      BorderSurface {\n        id: tooltipBubble')
new = block((repo / relative).read_text(), '      ToolTipSurface {\n        id: tooltipBubble')
write(relative, text.replace(old, new, 1))

# Backport only the animation policy required by this release. Preserve the
# installed Color/Style tokens and unrelated APIs used by installed plugins.
relative = 'shell/Commons/Style.qml'
text = (kit / relative).read_text()
upstream = (repo / relative).read_text()
if 'function duration(' not in text:
    if 'import Quickshell.Hyprland' not in text:
        text = text.replace('import Quickshell\n', 'import Quickshell\nimport Quickshell.Hyprland\n', 1)
    policy = '  property bool reduceMotion: false\n\n  function duration(ms) {\n    return reduceMotion ? 0 : ms\n  }\n\n'
    text = text.replace('  function refresh() {', policy + '  function refresh() {', 1)
    text = text.replace('    gapsOutProc.running = true\n', '    gapsOutProc.running = true\n    animationsProc.running = true\n', 1)
    events = block(upstream, '  property Process animationsProc: Process {') + '\n\n'
    events += block(upstream, '  property Connections hyprlandEvents: Connections {') + '\n\n'
    text = text.replace('  property Process gapsOutProc:', events + '  property Process gapsOutProc:', 1)
write(relative, text)

relative = 'shell/shell.qml'
text = (kit / relative).read_text()
if '//@ pragma RespectSystemStyle' not in text:
    text = '//@ pragma RespectSystemStyle\n' + text
write(relative, text)
relative = 'bin/omarchy-launch-shell'
text = (kit / relative).read_text()
if 'QT_QUICK_CONTROLS_STYLE=Omarchy' not in text:
    # Keep every original assignment, including OMARCHY_STARTUP_BACKGROUND on
    # current base launchers. Insert before the whole environment line.
    pattern = r'(?m)^([ \t]*)([^\n]*\bQS_DISABLE_FILE_WATCHER=1[^\n]*)$'
    def style_environment(match):
        indent, assignments = match.groups()
        return (indent + 'QML_IMPORT_PATH="$OMARCHY_PATH/shell/styles${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}" \\\n'
                + indent + 'QT_QUICK_CONTROLS_STYLE=Omarchy QT_QUICK_CONTROLS_FALLBACK_STYLE=Fusion \\\n'
                + indent + assignments)
    text, count = re.subn(pattern, style_environment, text, count=1)
    if count != 1:
        raise SystemExit('Unsupported launcher: missing Quickshell environment line')
write(relative, text)
(kit / relative).chmod(0o755)
relative = 'default/uwsm/default'
text = (kit / relative).read_text()
if 'export QS_QUICK_CONTROLS_STYLE=Omarchy' not in text:
    text += '\n# Quickshell tooltip integration; unrelated Qt applications keep their style.\nexport QS_QUICK_CONTROLS_STYLE=Omarchy\n'
write(relative, text)

# Test helpers live in the copy so their root discovery validates this exact kit.
for relative in ('test/shell.d/base-test.sh', 'test/shell.d/tooltips-test.sh'):
    write(relative, (repo / relative).read_text())
for path in (repo / 'test/shell.d/fixtures/tooltips').iterdir():
    write(f'test/shell.d/fixtures/tooltips/{path.name}', path.read_text())
write('bin/omarchy-install-tooltips', (repo / 'bin/omarchy-install-tooltips').read_text())
(kit / 'bin/omarchy-install-tooltips').chmod(0o755)
shutil.copytree(repo / 'default/tooltips', kit / 'default/tooltips', dirs_exist_ok=True)
backup = trial / 'backup'
backup.mkdir()
if Path('/etc/omarchy.conf').is_file():
    shutil.copy2('/etc/omarchy.conf', backup / 'omarchy.conf')
stock = args.stock_package.resolve()
if not stock.is_file():
    raise SystemExit('Original Quickshell package unavailable; prepare rollback before installing')
shutil.copy2(stock, backup / stock.name)
shutil.copy2(args.runtime, trial / 'quickshell')

# The global module must survive a consumer replacing QML_IMPORT_PATH.
# It is shipped in the local package and imports only its own minimal kit.
import shlex
import tarfile
module = trial / 'module/Omarchy'
(module / 'Kit/Ui').mkdir(parents=True)
(module / 'Kit/Commons').mkdir(parents=True)
ui_types = ['ToolTipBase', 'ToolTipSurface', 'BorderSurface', 'BorderOverlay']
common_types = ['Style', 'Color', 'Border', 'Util', 'ToolTipStyle']
for name in ui_types:
    shutil.copy2(kit / f'shell/Ui/{name}.qml', module / f'Kit/Ui/{name}.qml')
for name in common_types:
    text = (kit / f'shell/Commons/{name}.qml').read_text()
    text = re.sub(r'(?m)^import qs\.Commons(?=\s|$)', 'import "."', text)
    (module / f'Kit/Commons/{name}.qml').write_text(text)
shutil.copy2(kit / 'shell/Commons/BorderGeometry.js', module / 'Kit/Commons/BorderGeometry.js')
# Independent applications do not receive the main shell's theme IPC payload.
# Watch the two theme files in this private provider; keep main-shell IPC intact.
color_path = module / 'Kit/Commons/Color.qml'
color_text = color_path.read_text()
for name in ['colorsFile', 'shellFile']:
    original = block(color_text, f'  property FileView {name}: FileView {{')
    watched = original.replace('watchChanges: false', 'watchChanges: true')
    if 'onFileChanged:' not in watched:
        watched = watched.replace('    printErrors: false', '    printErrors: false\n    onFileChanged: reload()', 1)
    color_text = color_text.replace(original, watched, 1)
color_path.write_text(color_text)

(module / 'Kit/Ui/qmldir').write_text('module Omarchy.Kit.Ui\n' + ''.join(f'{name} 1.0 {name}.qml\n' for name in ui_types))
(module / 'Kit/Commons/qmldir').write_text('module Omarchy.Kit.Commons\n' + ''.join(f'singleton {name} 1.0 {name}.qml\n' for name in common_types))
(module / 'qmldir').write_text((kit / 'shell/styles/Omarchy/qmldir').read_text())
(module / 'ToolTip.qml').write_text((kit / 'shell/styles/Omarchy/ToolTip.qml').read_text().replace('../../Ui', 'Kit/Ui'))

recipe = trial / 'package'
recipe.mkdir()
shutil.copy2(stock, recipe / 'stock.pkg.tar')
shutil.copy2(args.runtime, recipe / 'quickshell-trial')
with tarfile.open(recipe / 'style-kit.tar.gz', 'w:gz') as archive:
    archive.add(module, arcname='Omarchy')
metadata = {}
for line in subprocess.check_output(['bsdtar', '-xOf', str(stock), '.PKGINFO'], text=True).splitlines():
    if ' = ' in line:
        key, value = line.split(' = ', 1)
        metadata.setdefault(key, []).append(value)
if metadata.get('pkgname') != ['quickshell'] or not metadata['pkgver'][0].startswith('0.3.1-'):
    raise SystemExit('The trial requires the original Quickshell 0.3.1 package')
if '.INSTALL' in subprocess.check_output(['bsdtar', '-tf', str(stock)], text=True).splitlines():
    raise SystemExit('An unexpected package install script requires review')
quote_array = lambda values: '(' + ' '.join(shlex.quote(value) for value in values) + ')'
text = "pkgname=quickshell\npkgver=0.3.1.tooltip2\npkgrel=1\npkgdesc='Omarchy tooltip runtime trial'\n"
for key in ['arch', 'license']:
    text += key + '=' + quote_array(metadata[key]) + '\n'
text += 'url=' + shlex.quote(metadata['url'][0]) + '\n'
text += 'depends=' + quote_array(metadata['depend']) + '\n'
text += "options=('!debug' '!strip')\nsource=('stock.pkg.tar' 'quickshell-trial' 'style-kit.tar.gz')\nnoextract=('stock.pkg.tar')\n"
text += 'sha256sums=' + quote_array([hashlib.sha256((recipe / name).read_bytes()).hexdigest() for name in ['stock.pkg.tar', 'quickshell-trial', 'style-kit.tar.gz']]) + '\n'
text += '''
package() {
  bsdtar -xf "$srcdir/stock.pkg.tar" -C "$pkgdir" --exclude .PKGINFO --exclude .BUILDINFO --exclude .MTREE
  install -m755 "$srcdir/quickshell-trial" "$pkgdir/usr/bin/quickshell"
  cp -a "$srcdir/Omarchy" "$pkgdir/usr/lib/qt6/qml/"
}
'''
(recipe / 'PKGBUILD').write_text(text)
manifest = {
    'baseOmarchy': str(args.installed.resolve()), 'trialOmarchy': str(kit),
    'originalPackage': str(backup / stock.name),
    'runtimeSha256': hashlib.sha256((trial / 'quickshell').read_bytes()).hexdigest(),
    'files': {name: hashlib.sha256((kit / name).read_bytes()).hexdigest() for name in changed},
}
(trial / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(json.dumps({'trial': str(trial), 'kit': str(kit), 'recipe': str(recipe)}))
