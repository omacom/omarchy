#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if ! command -v quickshell >/dev/null 2>&1; then
  skip "quickshell not installed; skipping initial translation lookups"
  exit 0
fi
require_command python3

# FileView is a Quickshell plugin, so exercise the real runtime. This fixture
# creates no windows or services and uses an offscreen backend and private dirs.
python3 <<'PY'
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time

root = Path(os.environ['ROOT'])
en_catalog = {
    'test.hello': 'Hello %1',
    'test.items': {'one': '%1 item', 'other': '%1 items'},
    'test.englishOnly': 'English fallback',
}
da_catalog = {'test.hello': 'Hej %1', 'test.items': {'one': '%1 ting', 'other': '%1 ting'}}
pt_catalog = {'test.hello': 'Olá %1', 'test.items': {'one': '%1 item', 'other': '%1 itens'}}
fa_catalog = {'test.hello': 'سلام %1', 'test.items': {'one': '%1 مورد', 'other': '%1 مورد'}}
registry = {
    'en': {'formatLocale': 'en-US', 'decimal': '.', 'zeroDigit': '0', 'direction': 'ltr'},
    'da': {'formatLocale': 'da-DK', 'decimal': ',', 'zeroDigit': '0', 'direction': 'ltr'},
    'pt-BR': {'formatLocale': 'pt-BR', 'decimal': ',', 'zeroDigit': '0', 'direction': 'ltr'},
    'fa': {'formatLocale': 'fa-IR', 'decimal': '٫', 'zeroDigit': '۰', 'direction': 'rtl'},
    'fr': {'formatLocale': 'fr-FR', 'decimal': ',', 'zeroDigit': '0', 'direction': 'ltr'},
}
english = {
    'language': 'en', 'locale': 'en-US', 'number': '13.5', 'rtl': False,
    'shellText': 'Hello Ada', 'shellPlural': '2 items', 'shellFallback': 'English fallback',
    'unknown': 'explicit fallback', 'unknownPlural': 'plural fallback',
    'pluginText': 'Hello Ada', 'pluginPlural': '2 items', 'pluginBase': 'English base',
    'pluginFallback': 'English fallback', 'pluginUnknown': 'plugin fallback',
}
danish = dict(english, language='da', locale='da-DK', number='13,5', shellText='Hej Ada',
              shellPlural='2 ting', pluginText='Hej Ada', pluginPlural='2 ting')
portuguese = dict(english, language='pt-BR', locale='pt-BR', number='13,5', shellText='Olá Ada',
                  shellPlural='2 itens', pluginText='Olá Ada', pluginPlural='2 itens', pluginBase='Portuguese base')
persian = dict(english, language='fa', locale='fa-IR', number='۱۳٫۵', rtl=True,
               shellText='سلام Ada', shellPlural='۲ مورد', pluginText='سلام Ada', pluginPlural='۲ مورد')
french_fallback = dict(english, language='fr', locale='fr-FR', number='13,5')


def write_json(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False), encoding='utf-8')


class Probe:
    def __init__(self, language=None, malformed=False, malformed_english=False):
        self.tmp = tempfile.TemporaryDirectory(prefix='omarchy-i18n-startup-')
        self.path = Path(self.tmp.name)
        self.config = self.path / 'config'
        self.config.mkdir()
        (self.config / 'Commons').symlink_to(root / 'shell/Commons', target_is_directory=True)
        (self.config / 'shell.qml').write_text((root / 'test/shell.d/fixtures/i18n-startup/shell.qml').read_text())
        for name in ('runtime', 'home', 'cache', 'state'):
            (self.path / name).mkdir(mode=0o700)
        self.catalogs = self.path / 'install/default/i18n'
        self.plugin = self.path / 'plugin'
        for code, catalog in [('en', en_catalog), ('da', da_catalog), ('pt-BR', pt_catalog), ('fa', fa_catalog)]:
            write_json(self.catalogs / code / 'shell.json', catalog)
            write_json(self.plugin / f'{code}.json', catalog)
        write_json(self.plugin / 'en.json', dict(en_catalog, **{'test.baseOnly': 'English base'}))
        write_json(self.plugin / 'pt.json', {'test.baseOnly': 'Portuguese base'})
        write_json(self.catalogs / 'locales.json', registry)
        if malformed:
            (self.catalogs / 'fr').mkdir()
            (self.catalogs / 'fr/shell.json').write_text('not json')
            (self.plugin / 'fr.json').write_text('[]')
        if malformed_english:
            (self.catalogs / 'en/shell.json').write_text('not json')
        self.language = self.path / 'language'
        if language is not None:
            self.language.write_text(language)
        self.directory = self.path / 'plugin-directory'
        self.directory.write_text(str(self.plugin))
        self.result = self.path / 'result.json'
        self.log_path = self.path / 'quickshell.log'
        self.log = self.log_path.open('w')
        env = os.environ.copy()
        for key in ('WAYLAND_DISPLAY', 'HYPRLAND_INSTANCE_SIGNATURE', 'DISPLAY'):
            env.pop(key, None)
        env.update({
            'OMARCHY_PATH': str(self.path / 'install'), 'OMARCHY_LANGUAGE_FILE': str(self.language),
            'OMARCHY_TEST_PLUGIN_DIRECTORY': str(self.directory), 'OMARCHY_TEST_RESULT': str(self.result),
            'XDG_RUNTIME_DIR': str(self.path / 'runtime'), 'HOME': str(self.path / 'home'),
            'XDG_CONFIG_HOME': str(self.path / 'home/.config'), 'XDG_CACHE_HOME': str(self.path / 'cache'),
            'XDG_STATE_HOME': str(self.path / 'state'), 'QT_QPA_PLATFORM': 'offscreen',
            'QT_QPA_PLATFORMTHEME': '', 'QT_STYLE_OVERRIDE': 'Fusion', 'QT_QUICK_BACKEND': 'software',
        })
        self.process = subprocess.Popen(['quickshell', '--no-color', '-p', str(self.config)],
                                        env=env, stdout=self.log, stderr=subprocess.STDOUT)

    def wait(self, expected):
        deadline = time.monotonic() + 5
        latest = None
        while time.monotonic() < deadline:
            if self.result.exists():
                try:
                    latest = json.loads(self.result.read_text())
                except (OSError, ValueError):
                    pass
                if latest and latest['current'] == expected:
                    return latest
            if self.process.poll() is not None:
                break
            time.sleep(0.01)
        raise AssertionError(f'expected={expected!r}\nactual={latest!r}\n{self.log_path.read_text()}')

    def close(self):
        try:
            if self.process.poll() is None:
                self.process.terminate()
            self.process.wait(timeout=3)
        finally:
            if self.process.poll() is None:
                self.process.kill()
                self.process.wait()
            self.log.close()
            self.tmp.cleanup()


def startup(description, expected, **kwargs):
    probe = Probe(**kwargs)
    try:
        result = probe.wait(expected)
        assert result['first'] == expected, f"first lookup: {result['first']!r}\n{probe.log_path.read_text()}"
        log = probe.log_path.read_text()
        assert not any(message in log for message in ('Argument missing', 'Binding loop', 'TypeError', 'ReferenceError')), log
        print(f'ok - {description}', flush=True)
    finally:
        probe.close()


try:
    startup('missing language file gives correct English on the first binding', english)
    startup('selected Danish, plurals, and locale metadata are ready on the first binding', danish, language='da\n')
    startup('regional plugin catalogs fall back through the base language and English', portuguese, language='pt-BR\n')
    startup('RTL direction and localized digits are ready on the first binding', persian, language='fa\n')
    startup('invalid language selection falls back to English', english, language='not a language\n')
    startup('missing selected catalogs fall back to English', french_fallback, language='fr\n')
    startup('malformed selected catalogs fall back to English', french_fallback, language='fr\n', malformed=True)
    startup('a malformed English catalog does not hide valid selected translations',
            dict(danish, shellFallback='missing English'), language='da\n', malformed_english=True)

    probe = Probe()
    try:
        probe.wait(english)
        for language, expected in [('da', danish), ('pt-BR', portuguese), ('fr', french_fallback), ('en', english)]:
            probe.language.write_text(language)
            probe.wait(expected)
        print('ok - live language changes update shell, plugin, and locale bindings', flush=True)

        write_json(probe.catalogs / 'en/shell.json', dict(en_catalog, **{'test.hello': 'Welcome %1'}))
        changed = dict(english, shellText='Welcome Ada')
        probe.wait(changed)
        print('ok - editing the shell catalog refreshes existing bindings', flush=True)

        write_json(probe.plugin / 'en.json', dict(en_catalog, **{'test.hello': 'Plugin %1', 'test.baseOnly': 'English base'}))
        changed = dict(changed, pluginText='Plugin Ada')
        probe.wait(changed)
        print('ok - editing a plugin catalog refreshes existing bindings', flush=True)

        other = probe.path / 'other-plugin'
        write_json(other / 'en.json', dict(en_catalog, **{'test.hello': 'Other %1', 'test.baseOnly': 'English base'}))
        probe.directory.write_text(str(other))
        changed = dict(changed, pluginText='Other Ada')
        probe.wait(changed)
        probe.directory.write_text(str(probe.plugin))
        changed = dict(changed, pluginText='Plugin Ada')
        probe.wait(changed)
        print('ok - changing the plugin catalog directory refreshes existing bindings', flush=True)

        probe.language.write_text('da')
        probe.wait(danish)
        probe.language.unlink()
        probe.wait(changed)
        print('ok - deleting the language selection restores English', flush=True)

        probe.language.write_text('da')
        probe.wait(danish)
        (probe.catalogs / 'da/shell.json').unlink()
        (probe.plugin / 'da.json').unlink()
        probe.wait(dict(changed, language='da', locale='da-DK', number='13,5'))
        print('ok - deleting selected catalogs clears stale translations and falls back to English', flush=True)

        write_json(probe.catalogs / 'da/shell.json', da_catalog)
        write_json(probe.plugin / 'da.json', da_catalog)
        probe.wait(danish)
        print('ok - recreated catalogs resume live translation', flush=True)

        (probe.catalogs / 'en/shell.json').unlink()
        changed = dict(danish, shellFallback='missing English')
        probe.wait(changed)
        print('ok - deleting English does not hide valid selected translations', flush=True)

        (probe.plugin / 'en.json').unlink()
        changed = dict(changed, pluginBase='test.baseOnly', pluginFallback='test.englishOnly')
        probe.wait(changed)
        print('ok - deleting a plugin fallback catalog clears its stale values', flush=True)

        write_json(probe.catalogs / 'locales.json', dict(registry, da=dict(registry['da'], decimal='.', direction='rtl')))
        probe.wait(dict(changed, number='13.5', rtl=True))
        print('ok - editing the locale registry refreshes number formatting and direction', flush=True)
        log = probe.log_path.read_text()
        assert not any(message in log for message in ('Argument missing', 'Binding loop', 'TypeError', 'ReferenceError')), log
    finally:
        probe.close()
except Exception as error:
    print(f'not ok - initial translations and live catalog updates\n{error}', flush=True)
    raise SystemExit(1)
PY
