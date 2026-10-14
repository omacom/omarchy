#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

python3 - <<'PY'
import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib

root = Path(os.environ['ROOT'])
excluded = ['CODEX_HOME', 'CODEX_CONFIG_PATH', 'GROK_HOME', 'GROK_CONFIG_DIR', 'GROK_CONFIG_PATH', 'CLAUDE_CONFIG_DIR']
base_env = {k: v for k, v in os.environ.items() if k not in excluded}
with tempfile.TemporaryDirectory() as temporary:
    home = Path(temporary)
    env = dict(base_env, HOME=str(home), OMARCHY_PATH=str(root), PATH=str(root / 'bin') + ':' + os.environ['PATH'])
    for app, table, theme in [('codex', 'tui', 'ansi'), ('grok', 'ui', 'minimal')]:
        config = home / ('.' + app) / 'config.toml'
        config.parent.mkdir(exist_ok=True)
        for header in [f'[{table}]', f'[ "{table}" ]', f"['{table}']", '["' + r'\u0074ui' + '"]' if table == 'tui' else '["' + r'\u0075i' + '"]']:
            source = '# preserved\nmodel = "kept"\n' + header + '\n"theme" = "old"\nother = [1, 2]\n[tools]\ntext = """\n[tui]\nlooks like a table but is text\n"""\n'
            config.write_text(source)
            subprocess.run([str(root / 'bin' / ('omarchy-theme-set-' + app)), '--activate'], env=env, check=True)
            parsed = tomllib.loads(config.read_text())
            expected = tomllib.loads(source)
            expected[table]['theme'] = theme
            assert parsed == expected, (header, config.read_text())
            assert '# preserved' in config.read_text()
        for source in [f'"{table}"."theme" = "old"\nmodel = "kept"\n', f'{table} = {{ theme = "old", other = 7 }}\n', f'[{table}]\nother = 7', f'[{table}]\ntheme = """old\nmultiline"""\n', f'[{table}.nested]\nkept = true\n', f'{table}.theme = "old"\n{table}.notifications = false\n', f'{table}.notifications = false\n{table}.nested.kept = true\n', f'"{table}"."theme" = "old"\n"{table}"."equals=key" = true\n']:
            config.write_text(source)
            subprocess.run([str(root / 'bin' / ('omarchy-theme-set-' + app)), '--activate'], env=env, check=True)
            expected = tomllib.loads(source)
            expected[table]['theme'] = theme
            assert tomllib.loads(config.read_text()) == expected, (source, config.read_text())
        for quote in ['"', "'"]:
            for trailing in [1, 2]:
                delimiter = quote * 3
                source = f'developer_instructions = {delimiter}Say {quote}hello{delimiter}{quote * trailing}\n[{table}]\ntheme = "old"\n'
                config.write_text(source)
                expected = tomllib.loads(source)
                expected[table]['theme'] = theme
                subprocess.run([str(root / 'bin' / ('omarchy-theme-set-' + app)), '--activate'], env=env, check=True)
                assert tomllib.loads(config.read_text()) == expected, (source, config.read_text())
        config.write_text('invalid = [\n')
        before = config.read_bytes()
        result = subprocess.run([str(root / 'bin' / ('omarchy-theme-set-' + app)), '--activate'], env=env, capture_output=True)
        assert result.returncode != 0 and config.read_bytes() == before
        config.unlink()
        target = home / (app + '-linked.toml')
        target.write_text(f'[{table}]\ntheme = "old"\n')
        config.symlink_to(target)
        subprocess.run([str(root / 'bin' / ('omarchy-theme-set-' + app)), '--activate'], env=env, check=True)
        assert config.is_symlink() and tomllib.loads(target.read_text())[table]['theme'] == theme
    print('ok - TOML activation recognizes quoted, escaped, dotted, inline and multiline keys, preserves unrelated data and links, and rejects invalid originals')

    palette = home / '.local/state/omarchy/current/theme'
    palette.mkdir(parents=True)
    for app, selected in [('claude', 'custom:omarchy'), ('pi', 'omarchy-system')]:
        (palette / (app + '.json')).write_text('{}')
        settings = home / '.claude/settings.json' if app == 'claude' else home / '.pi/agent/settings.json'
        settings.parent.mkdir(parents=True, exist_ok=True)
        target = home / (app + '-settings.json')
        target.write_text('{"theme":"old","preserved":true}')
        settings.symlink_to(target)
        subprocess.run([str(root / 'bin' / ('omarchy-theme-set-' + app)), '--activate'], env=env, check=True)
        assert settings.is_symlink() and json.loads(target.read_text()) == {'theme': selected, 'preserved': True}
    print('ok - Claude and Pi activation updates linked settings targets')

    grok_home = home / 'custom-grok'
    subprocess.run([str(root / 'bin/omarchy-theme-set-grok'), '--activate'], env=dict(env, GROK_HOME=str(grok_home)), check=True)
    assert tomllib.loads((grok_home / 'config.toml').read_text())['ui']['theme'] == 'minimal'
    explicit = home / 'explicit.toml'
    subprocess.run([str(root / 'bin/omarchy-theme-set-grok'), '--activate'], env=dict(env, GROK_HOME=str(grok_home), GROK_CONFIG_PATH=str(explicit)), check=True)
    assert explicit.exists()
    print('ok - Grok uses GROK_HOME while preserving an explicit config-path override')

with tempfile.TemporaryDirectory() as temporary:
    home = Path(temporary)
    codex = home / 'custom-codex'
    claude = home / 'custom-claude'
    pi = home / '.pi/agent'
    for p in [codex, claude, pi / 'extensions']:
        p.mkdir(parents=True)
    extension = pi / 'extensions/omarchy-system-theme.ts'
    extension.write_text('legacy')
    current = home / '.local/state/omarchy/current'
    current.mkdir(parents=True)
    (current / 'theme.name').write_text('tokyo-night\n')
    env = dict(base_env, HOME=str(home), CODEX_HOME=str(codex), CLAUDE_CONFIG_DIR=str(claude), OMARCHY_PATH=str(root), PATH=str(root / 'bin') + ':' + os.environ['PATH'])
    subprocess.run(['bash', '-euo', 'pipefail', str(root / 'migrations/1786637624.sh')], env=env, check=True, capture_output=True)
    assert (current / 'theme/claude.json').exists() and (current / 'theme/pi.json').exists()
    assert tomllib.loads((codex / 'config.toml').read_text())['tui']['theme'] == 'ansi'
    assert json.loads((claude / 'settings.json').read_text())['theme'] == 'custom:omarchy'
    assert json.loads((pi / 'settings.json').read_text())['theme'] == 'omarchy-system' and not extension.exists()
    subprocess.run(['bash', '-euo', 'pipefail', str(root / 'migrations/1786637624.sh')], env=env, check=True, capture_output=True)
    print('ok - migration generates missing palettes before activating custom homes and retiring Pi extension; rerun succeeds')
    (current / 'theme.name').unlink()
    for name in ['claude.json', 'pi.json']:
        (current / 'theme' / name).unlink()
    extension.write_text('legacy')
    result = subprocess.run(['bash', '-euo', 'pipefail', str(root / 'migrations/1786637624.sh')], env=env, capture_output=True)
    assert result.returncode != 0 and extension.exists()
    print('ok - absent palette sources keep activation pending and preserve the old Pi extension')
PY
