#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

/usr/bin/python "$ROOT/test/shell.d/fixtures/slack-pipe.py"

# Native theme inputs still pass through the real resolver, including legacy
# aliases. Slack itself derives shades and contrast from these four colors.
PATH="$ROOT/bin:$PATH" python - <<'PYTHON'
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

root = Path(os.environ['ROOT'])

def render(colors_file):
    with tempfile.TemporaryDirectory() as directory:
        home = Path(directory)
        staged = home / '.local/state/omarchy/current/next-theme'
        staged.mkdir(parents=True)
        shutil.copy2(colors_file, staged / 'colors.toml')
        subprocess.run(['omarchy-theme-set-templates'], env={**os.environ, 'HOME': str(home)}, check=True)
        return json.loads((staged / 'slack.json').read_text())

modes = set()
for theme in sorted((root / 'themes').glob('*/colors.toml')):
    colors = render(theme)
    modes.add(colors.pop('mode'))
    assert all(re.fullmatch(r'#[0-9a-fA-F]{6}', value) for value in colors.values()), theme
assert modes == {'dark', 'light'}
print('ok - stock themes resolve to native Slack color inputs in both modes')

with tempfile.TemporaryDirectory() as directory:
    legacy = Path(directory) / 'colors.toml'
    legacy.write_text('bg = "#101010"\nfg = "#eeeeee"\n' + '\n'.join(
        f'color{i} = "{color}"' for i, color in enumerate(
            ['#101010', '#ff5555', '#55ff55', '#ffff55', '#00aaff', '#ff55ff', '#55ffff', '#eeeeee'])))
    colors = render(legacy)
    assert colors == {'mode': 'dark', 'background': '#101010', 'accent': '#00aaff',
                      'green': '#55ff55', 'red': '#ff5555'}
    print('ok - legacy aliases resolve before native Slack theme publication')
PYTHON

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
HOME="$scratch" bash "$ROOT/bin/omarchy-theme-set-slack"
[[ ! -e $scratch/.local ]] || fail "theme sync leaves unconfigured machines alone"
pass "theme sync leaves unconfigured machines alone"

mkdir -p "$scratch/.local/state/omarchy/slack" "$scratch/.local/state/omarchy/current/theme"
touch "$scratch/.local/state/omarchy/slack/enabled"
HOME="$scratch" OMARCHY_THEME_HEADLESS=1 OMARCHY_THEME_SKIP_BACKGROUND=1 PATH="$ROOT/bin:$PATH" \
  bash "$ROOT/bin/omarchy-theme-set" catppuccin-latte
HOME="$scratch" bash "$ROOT/bin/omarchy-theme-set-slack"
[[ -s $scratch/.local/state/omarchy/slack/theme.json ]] || fail "the native adapter publishes the staged native Slack theme"
pass "the native adapter publishes the staged native Slack theme"
cp "$scratch/.local/state/omarchy/slack/theme.json" "$scratch/before.json"
printf '{"mode":"dark; invalid CSS"}\n' >"$scratch/.local/state/omarchy/current/theme/slack.json"
HOME="$scratch" bash "$ROOT/bin/omarchy-theme-set-slack" 2>"$scratch/skip.log"
cmp -s "$scratch/before.json" "$scratch/.local/state/omarchy/slack/theme.json" || fail "invalid theme data leaves the last native theme intact"
pass "invalid theme data leaves the last native theme intact"

python - <<'PY'
from pathlib import Path
import os
import subprocess
import tempfile
import time

root = Path(os.environ['ROOT'])
with tempfile.TemporaryDirectory() as directory:
    scratch = Path(directory)
    home, commands = scratch / 'home', scratch / 'bin'
    home.mkdir()
    commands.mkdir()
    log, launched = scratch / 'packages', scratch / 'launched'
    for name, body in {
        'omarchy-pkg-add': 'echo "add:$*" >>"$TEST_PACKAGES"\nexit "${TEST_PACKAGE_EXIT:-0}"',
        'omarchy-pkg-drop': 'echo "drop:$*" >>"$TEST_PACKAGES"\nexit "${TEST_PACKAGE_EXIT:-0}"',
        'omarchy-setup-slack': 'exit "${TEST_SETUP_EXIT:-0}"',
        'uwsm-app': 'printf "%s\\n" "$*" >"$TEST_LAUNCHED"',
        'update-desktop-database': 'exit 0',
    }.items():
        command = commands / name
        command.write_text('#!/bin/bash\n' + body + '\n')
        command.chmod(0o755)
    env = {**os.environ, 'HOME': str(home), 'PATH': str(commands) + ':' + os.environ['PATH'],
           'TEST_PACKAGES': str(log), 'TEST_LAUNCHED': str(launched)}
    for setup_exit, expected in [('0', '-- gtk-launch slack'),
                                 ('1', '-- gio launch /usr/share/applications/slack.desktop')]:
        launched.unlink(missing_ok=True)
        subprocess.run([root / 'bin/omarchy-install-service-slack'],
                       env={**env, 'TEST_SETUP_EXIT': setup_exit}, check=True)
        deadline = time.monotonic() + 3
        while not launched.exists() and time.monotonic() < deadline:
            time.sleep(.01)
        assert launched.read_text().strip() == expected
    launched.unlink()
    assert subprocess.run([root / 'bin/omarchy-install-service-slack'],
                          env={**env, 'TEST_PACKAGE_EXIT': '1'}).returncode != 0
    assert not launched.exists()
    assert log.read_text().splitlines() == ['add:slack-desktop'] * 3
    print('ok - installation opens packaged Slack when theme setup fails, but stops on package failure')

    override = home / '.local/share/applications/slack.desktop'
    override.parent.mkdir(parents=True)
    override.write_text('[Desktop Entry]\nExec=omarchy-launch-slack %U\n')
    backup = override.with_suffix('.desktop.before-omarchy')
    backup.write_text('original launcher')
    state, profile = (home / relative for relative in (
        '.local/state/omarchy/slack', '.config/Slack'))
    for target in (state, profile):
        target.mkdir(parents=True)
        (target / 'keep').touch()
    (state / 'enabled').touch()
    remove = [root / 'bin/omarchy-remove-service-slack']
    assert subprocess.run(remove, env={**env, 'TEST_PACKAGE_EXIT': '1'}).returncode != 0
    assert override.exists() and (state / 'enabled').exists()
    subprocess.run(remove, env=env, check=True)
    assert not override.exists() and not state.exists()
    assert (profile / 'keep').exists() and backup.read_text() == 'original launcher'
    assert log.read_text().splitlines()[-2:] == ['drop:slack-desktop'] * 2
    override.write_text('[Desktop Entry]\nExec=custom-slack\n')
    subprocess.run(remove, env=env, check=True)
    assert 'Exec=custom-slack' in override.read_text()
    print('ok - uninstall cleans integration only after package success and retains profiles and custom launchers')
PY
