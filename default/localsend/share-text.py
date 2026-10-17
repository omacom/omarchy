#!/usr/bin/python3
"""Print a composed text message; return 1 on cancellation and 2 on failure."""
import sys


def compose_text():
  import gi
  gi.require_version('Gtk', '3.0')
  gi.require_version('Gdk', '3.0')
  from gi.repository import Gdk, GLib, Gtk

  GLib.set_prgname('omarchy-share-text')
  GLib.set_application_name('Share Text')
  dialog = Gtk.Dialog(title='Share Text', modal=True)
  dialog.set_default_size(620, 360)
  dialog.add_button('_Cancel', Gtk.ResponseType.CANCEL)
  next_button = dialog.add_button('_Choose device', Gtk.ResponseType.OK)
  next_button.set_sensitive(False)
  next_button.get_style_context().add_class('suggested-action')

  content = dialog.get_content_area()
  content.set_border_width(16)
  content.set_spacing(12)
  label = Gtk.Label(label='Type or paste text to share with LocalSend.')
  label.set_xalign(0)
  content.pack_start(label, False, False, 0)
  editor = Gtk.TextView()
  editor.set_wrap_mode(Gtk.WrapMode.WORD_CHAR)
  editor.set_left_margin(10)
  editor.set_right_margin(10)
  editor.set_top_margin(10)
  editor.set_bottom_margin(10)
  scroll = Gtk.ScrolledWindow()
  scroll.set_shadow_type(Gtk.ShadowType.IN)
  scroll.add(editor)
  content.pack_start(scroll, True, True, 0)
  hint = Gtk.Label(label='Ctrl+Enter to choose a device • Esc to cancel')
  hint.set_xalign(0)
  content.pack_start(hint, False, False, 0)
  buffer = editor.get_buffer()

  def text_value():
    return buffer.get_text(buffer.get_start_iter(), buffer.get_end_iter(), True)

  buffer.connect('changed', lambda *_: next_button.set_sensitive(bool(text_value().strip())))

  def on_key_press(_widget, event):
    if event.keyval == Gdk.KEY_Escape:
      dialog.response(Gtk.ResponseType.CANCEL)
      return True
    if (event.state & Gdk.ModifierType.CONTROL_MASK
        and event.keyval in (Gdk.KEY_Return, Gdk.KEY_KP_Enter)):
      if text_value().strip():
        dialog.response(Gtk.ResponseType.OK)
      return True
    return False

  dialog.connect('key-press-event', on_key_press)
  dialog.show_all()
  editor.grab_focus()
  response = dialog.run()
  text = text_value() if response == Gtk.ResponseType.OK else None
  dialog.destroy()
  return text


def main():
  text = compose_text()
  if text is None or not text.strip():
    return 1
  print(text, end='')
  return 0


if __name__ == '__main__':
  try:
    sys.exit(main())
  except Exception as error:
    print(f'Could not compose text: {error}', file=sys.stderr)
    sys.exit(2)
