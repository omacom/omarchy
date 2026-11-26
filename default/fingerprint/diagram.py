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
  def __init__(self, compact=False):
    super().__init__(content_width=52 if compact else 200, content_height=52 if compact else 190,
                     halign=Gtk.Align.CENTER, valign=Gtk.Align.CENTER, accessible_role=Gtk.AccessibleRole.PRESENTATION)
    self.compact = compact
    self.samples = 0
    self.complete = False
    self.present = False
    self.set_draw_func(self.draw)

  def draw(self, widget, cr, width, height):
    scale = min(width / 150, height / 150)
    cr.translate((width - 128 * scale) / 2, (height - 144 * scale) / 2)
    cr.scale(scale, scale)
    foreground = self.get_color()
    style = self.get_style_context()
    found, tint = style.lookup_color("success_color" if self.complete else "theme_selected_bg_color")
    # The selected background alone can disappear on dark themes. Mix it
    # with the normal text color so each captured ridge remains legible.
    fg = (foreground.red, foreground.green, foreground.blue)
    ink = tuple(.58 * c + .42 * f for c, f in zip((tint.red, tint.green, tint.blue), fg)) if found else fg
    cr.set_source_rgba(*ink, .14 if self.present or self.complete else .075)
    cr.arc(64, 74, 69, 0, 6.284)
    cr.fill()
    cr.set_line_width(3.5)
    cr.set_line_cap(1)
    for i, (start, *curves) in enumerate(RIDGES):
      # Keep a ridge in reserve until the reader announces completion. The
      # reported number of stages is only an estimate on adaptive sensors.
      if self.compact or self.complete or i < min(self.samples, len(RIDGES) - 1):
        cr.set_source_rgb(*ink)
      else:
        cr.set_source_rgba(*fg, .28)
      cr.move_to(*start)
      for curve in curves:
        cr.curve_to(*curve)
      cr.stroke()
    if self.complete:
      cr.set_source_rgb(*ink)
      cr.arc(112, 119, 13, 0, 6.284)
      cr.fill()
      _, bg = style.lookup_color("theme_bg_color")
      cr.set_source_rgb(bg.red, bg.green, bg.blue)
      cr.set_line_width(2.8)
      cr.move_to(106, 119)
      cr.line_to(111, 124)
      cr.line_to(119, 114)
      cr.stroke()
