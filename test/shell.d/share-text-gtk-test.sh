#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
require_command timeout

export OMARCHY_PATH=$ROOT
export PATH="$ROOT/bin:$PATH"

if ! timeout 20 python3 - <<'PY'
import sys
try:
  import gi
  gi.require_version('Gtk', '3.0')
  from gi.repository import Gtk
  sys.exit(0 if Gtk.init_check()[0] else 1)
except (ImportError, ValueError):
  sys.exit(1)
PY
then
  skip "real composer checks require GTK 3 and a graphical display"
  exit 0
fi

for action in accept cancel escape blank-shortcut; do
  OMARCHY_SHARE_GTK_ACTION="$action" timeout 20 python3 - <<'PY'
import contextlib
import io
import os
from pathlib import Path
import runpy
import unittest

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Gdk', '3.0')
from gi.repository import Gdk, GLib, Gtk


class ComposerTests(unittest.TestCase):
  def test_real_composer_buttons_and_keyboard(self):
    module = runpy.run_path(str(Path(os.environ['ROOT']) / 'default/localsend/share-text.py'))
    message = 'First line\ncafé ${HOME} --share'

    def descendants(widget):
      yield widget
      if isinstance(widget, Gtk.Container):
        for child in widget.get_children():
          yield from descendants(child)

    for action in (os.environ['OMARCHY_SHARE_GTK_ACTION'],):
      with self.subTest(action=action):
        errors = []

        def press(dialog, key, state=Gdk.ModifierType(0)):
          event = Gdk.Event.new(Gdk.EventType.KEY_PRESS)
          event.keyval = key
          event.state = state
          dialog.emit('key-press-event', event)

        def exercise():
          dialog = next(window for window in Gtk.Window.list_toplevels()
                        if window.get_title() == 'Share Text')
          try:
            editor = next(widget for widget in descendants(dialog) if isinstance(widget, Gtk.TextView))
            next_button = dialog.get_widget_for_response(Gtk.ResponseType.OK)
            self.assertFalse(next_button.get_sensitive())
            editor.get_buffer().set_text(' \t\n')
            self.assertFalse(next_button.get_sensitive())
            if action == 'blank-shortcut':
              press(dialog, Gdk.KEY_Return, Gdk.ModifierType.CONTROL_MASK)
              self.assertTrue(dialog.get_visible(), 'Blank Ctrl+Enter closed the composer')
            editor.get_buffer().set_text(message)
            self.assertTrue(next_button.get_sensitive())
            def finish():
              try:
                screenshot = os.environ.get('OMARCHY_SHARE_GTK_SCREENSHOT')
                if screenshot and action == 'accept':
                  window = dialog.get_window()
                  pixbuf = Gdk.pixbuf_get_from_window(window, 0, 0, window.get_width(), window.get_height())
                  pixbuf.savev(screenshot, 'png', [], [])
                if action in ('accept', 'blank-shortcut'):
                  press(dialog, Gdk.KEY_Return, Gdk.ModifierType.CONTROL_MASK)
                elif action == 'escape':
                  press(dialog, Gdk.KEY_Escape)
                else:
                  dialog.get_widget_for_response(Gtk.ResponseType.CANCEL).clicked()
              except Exception as error:
                errors.append(error)
                dialog.response(Gtk.ResponseType.CANCEL)
              return False

            # Give GTK a frame to paint the entered text before capture/response.
            GLib.timeout_add(100, finish)
          except Exception as error:
            errors.append(error)
            dialog.response(Gtk.ResponseType.CANCEL)
          return False

        GLib.timeout_add(250, exercise)
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
          status = module['main']()
        if errors:
          raise errors[0]
        accepted = action in ('accept', 'blank-shortcut')
        self.assertEqual(status, 0 if accepted else 1)
        self.assertEqual(output.getvalue(), message if accepted else '')


unittest.main()
PY
done

pass "real GTK composer handles multiline text, buttons, and keyboard shortcuts"
