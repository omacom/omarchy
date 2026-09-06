"""Add Print… directly to the context menu for local pictures."""

import gi

gi.require_version("Nautilus", "4.1")
gi.require_version("Gdk", "4.0")
from gi.repository import Gdk, Gio, GObject, Nautilus


class PrintPictureExtension(GObject.GObject, Nautilus.MenuProvider):
  def get_file_items(self, files):
    if len(files) != 1:
      return []
    selected = files[0]
    location = selected.get_location()
    if (selected.is_directory() or not location or not location.is_native()
        or not (selected.get_mime_type() or "").startswith("image/")):
      return []
    item = Nautilus.MenuItem(
      name="PrintPicture::print",
      label="Print…",
      tip="Choose a printer and page settings for this picture",
      icon="document-print",
    )
    item.connect("activate", self.print_picture, location)
    return [item]

  def print_picture(self, item, location):
    app = Gio.AppInfo.create_from_commandline(
      "omarchy-launch-image-print %f", "Print Picture", Gio.AppInfoCreateFlags.NONE
    )
    display = Gdk.Display.get_default()
    context = display.get_app_launch_context() if display else None
    app.launch([location], context)
