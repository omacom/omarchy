"""An illustrative fingerprint. Each accepted sample lights another ridge."""
import gi
gi.require_version("Gtk", "4.0")
from gi.repository import Gtk

# Cubic paths in a 128 by 144 view. These are drawn curves, independent of
# the print on the sensor. fprintd never sends biometric images to this app.
RIDGES = (
  ((18, 59), (26, 15, 92, 7, 110, 55)),
  ((15, 80), (17, 53, 30, 28, 59, 25), (82, 21, 102, 38, 108, 60), (110, 66, 111, 75, 111, 81)),
  ((20, 96), (26, 84, 20, 68, 31, 51), (46, 26, 81, 27, 95, 50), (105, 68, 99, 90, 111, 102)),
  ((26, 106), (38, 90, 27, 71, 41, 53), (55, 36, 79, 40, 89, 57), (99, 75, 89, 89, 105, 111)),
  ((33, 115), (45, 102, 38, 88, 41, 71), (44, 48, 67, 44, 79, 58), (92, 72, 79, 99, 99, 119)),
  ((42, 121), (52, 109, 47, 87, 50, 71), (52, 57, 64, 52, 74, 63), (83, 75, 69, 100, 90, 124)),
  ((54, 126), (62, 111, 54, 89, 58, 72), (60, 64, 68, 62, 69, 72), (69, 79, 65, 86, 68, 99)),
  ((62, 110), (63, 115, 63, 122, 62, 128)),
  ((71, 106), (72, 112, 76, 122, 81, 127)),
)


class Diagram(Gtk.DrawingArea):
  def __init__(self):
    super().__init__(content_width=170, content_height=166, halign=Gtk.Align.CENTER)
    self.samples = 0
    self.complete = False
    self.present = False
    self.set_draw_func(self.draw)

  def draw(self, widget, cr, width, height):
    scale = min(width / 150, height / 150)
    cr.translate((width - 128 * scale) / 2, (height - 144 * scale) / 2)
    cr.scale(scale, scale)
    foreground = self.get_color()
    cr.set_source_rgba(foreground.red, foreground.green, foreground.blue, .11 if self.present else .055)
    cr.arc(64, 74, 69, 0, 6.284)
    cr.fill()
    cr.set_line_width(3.5)
    cr.set_line_cap(1)
    for i, (start, *curves) in enumerate(RIDGES):
      # Keep a ridge in reserve until the reader announces completion. The
      # reported number of stages is only an estimate on adaptive sensors.
      if self.complete or i < min(self.samples, len(RIDGES) - 1):
        cr.set_source_rgba(foreground.red, foreground.green, foreground.blue, 1)
      else:
        cr.set_source_rgba(foreground.red, foreground.green, foreground.blue, .30)
      cr.move_to(*start)
      for curve in curves:
        cr.curve_to(*curve)
      cr.stroke()
