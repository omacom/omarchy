#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command jq

python3 - <<'PY'
import contextlib
import io
import json
import os
from pathlib import Path
import runpy
import tempfile
import types
import unittest
from unittest.mock import Mock, patch

root = Path(os.environ['ROOT'])
english = {
  'share.textTitle': 'Share Text',
  'share.textCancel': '_Cancel',
  'share.textChooseDevice': '_Choose device',
  'share.textPrompt': 'Type or paste text to share with LocalSend.',
  'share.textHint': 'Ctrl+Enter to choose a device • Esc to cancel',
}
translated = {
  'share.textTitle': 'Text teilen',
  'share.textCancel': '_Abbrechen',
  'share.textChooseDevice': '_Gerät wählen',
  'share.textPrompt': 'Text mit LocalSend teilen: café ${HOME} & <Text>',
  'share.textHint': 'Ctrl+Enter: Gerät wählen • Esc: abbrechen',
}


class ComposerTranslationTests(unittest.TestCase):
  def exercise(self, language, catalog, expected):
    with tempfile.TemporaryDirectory() as temporary:
      fixture = Path(temporary)
      for code in ('en', 'de'):
        destination = fixture / 'default/i18n' / code
        destination.mkdir(parents=True)
        source = root / 'default/i18n' / code / 'cli.json'
        data = json.loads(source.read_text())
        if code == 'de':
          # Keep missing/empty fallback cases independent of translation syncs.
          for key in english:
            data.pop(key, None)
          data.update(catalog)
        (destination / 'cli.json').write_text(json.dumps(data))
      for name in ('plural.jq', 'locales.json'):
        (fixture / 'default/i18n' / name).write_bytes((root / 'default/i18n' / name).read_bytes())
      language_file = fixture / 'language'
      language_file.write_text(language)
      environment = dict(OMARCHY_PATH=str(fixture), OMARCHY_LANGUAGE_FILE=str(language_file),
                         PATH=str(root / 'bin') + os.pathsep + os.environ['PATH'])
      # Only GTK is replaced: execute the real composer and omarchy-i18n
      # against isolated catalogs, without needing a graphical display.
      gtk = Mock()
      gtk.ResponseType.CANCEL = -6
      gtk.ResponseType.OK = -5
      gtk.Dialog.return_value.run.return_value = gtk.ResponseType.CANCEL
      glib = Mock()
      repository = types.ModuleType('gi.repository')
      repository.Gtk, repository.GLib, repository.Gdk = gtk, glib, Mock()
      gi = types.ModuleType('gi')
      gi.require_version = Mock()
      with patch.dict(os.environ, environment), patch.dict('sys.modules', {'gi': gi, 'gi.repository': repository}):
        module = runpy.run_path(str(root / 'default/localsend/share-text.py'))
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
          self.assertEqual(module['main'](), 1)
        self.assertEqual(output.getvalue(), '', 'UI translations must not enter shared text')
      gtk.Dialog.assert_called_once_with(title=expected['share.textTitle'], modal=True)
      glib.set_application_name.assert_called_once_with(expected['share.textTitle'])
      self.assertEqual(gtk.Dialog.return_value.add_button.call_args_list[0].args,
                       (expected['share.textCancel'], gtk.ResponseType.CANCEL))
      self.assertEqual(gtk.Dialog.return_value.add_button.call_args_list[1].args,
                       (expected['share.textChooseDevice'], gtk.ResponseType.OK))
      self.assertEqual([call.kwargs['label'] for call in gtk.Label.call_args_list],
                       [expected['share.textPrompt'], expected['share.textHint']])

  def test_selected_language_reaches_all_visible_labels(self):
    self.exercise('de', translated, translated)

  def test_missing_and_empty_translations_fall_back_to_english(self):
    partial = {'share.textTitle': translated['share.textTitle'], 'share.textCancel': ''}
    self.exercise('de', partial, {**english, 'share.textTitle': translated['share.textTitle']})

  def test_english_labels_come_from_source_catalog(self):
    self.exercise('en', {}, english)

  def test_unknown_language_falls_back_to_english(self):
    self.exercise('unknown', translated, english)


unittest.main()
PY

pass "composer uses selected-language labels and English fallback without sharing UI text"
