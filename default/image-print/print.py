"""Print an image through GTK's printer and page setup dialog."""

import argparse
from pathlib import Path
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GdkPixbuf, GLib, Gtk


def draw_image(context, pixbuf, width, height):
  scale = min(width / pixbuf.get_width(), height / pixbuf.get_height())
  context.save()
  context.translate(
    (width - pixbuf.get_width() * scale) / 2,
    (height - pixbuf.get_height() * scale) / 2,
  )
  context.scale(scale, scale)
  Gdk.cairo_set_source_pixbuf(context, pixbuf, 0, 0)
  context.paint()
  context.restore()


def main():
  parser = argparse.ArgumentParser(description=__doc__)
  parser.add_argument("image", type=Path)
  args = parser.parse_args()
  GLib.set_application_name("Print Picture")
  GLib.set_prgname("org.omarchy.ImagePrint")
  try:
    pixbuf = GdkPixbuf.Pixbuf.new_from_file(str(args.image.resolve()))
    pixbuf = pixbuf.apply_embedded_orientation()
    operation = Gtk.PrintOperation()
    operation.set_job_name(args.image.name)
    operation.set_n_pages(1)
    operation.set_unit(Gtk.Unit.POINTS)
    operation.set_use_full_page(False)
    operation.set_embed_page_setup(True)
    setup = Gtk.PageSetup()
    if pixbuf.get_width() > pixbuf.get_height():
      setup.set_orientation(Gtk.PageOrientation.LANDSCAPE)
    operation.set_default_page_setup(setup)
    operation.connect(
      "draw-page",
      lambda op, ctx, page: draw_image(
        ctx.get_cairo_context(), pixbuf, ctx.get_width(), ctx.get_height()
      ),
    )
    result = operation.run(Gtk.PrintOperationAction.PRINT_DIALOG, None)
    if result == Gtk.PrintOperationResult.ERROR:
      operation.get_error()
      return 1
  except (GLib.Error, OSError) as error:
    print(f"Cannot print image: {error}", file=sys.stderr)
    dialog = Gtk.MessageDialog(
      message_type=Gtk.MessageType.ERROR,
      buttons=Gtk.ButtonsType.CLOSE,
      text="Could not print this picture",
    )
    dialog.format_secondary_text(str(error))
    dialog.run()
    dialog.destroy()
    return 1
  return 0


if __name__ == "__main__":
  sys.exit(main())
