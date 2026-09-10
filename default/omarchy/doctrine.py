"""An offline reader for the Omarchy Doctrine, using the terminal's palette."""

import curses
import os
from pathlib import Path
import re
import subprocess
import sys
import textwrap


WEBSITE = "https://omarchy.org/doctrine/"
USAGE = "Usage: omarchy doctrine [--plain|--full|--web|1-10]"


def load_principles():
  document = Path(os.environ["OMARCHY_PATH"], "default/omarchy/doctrine.md").read_text()
  principles = []
  for section in document.split("## ")[1:]:
    title, body = section.strip().split("\n", 1)
    slug = re.sub(r"[^a-z0-9 ]", "", title.lower()).replace(" ", "-")
    principles.append((title, body.strip(), WEBSITE + "#" + slug))
  return principles


def plain_text(principles, mode, selected=0):
  lines = ["The Omarchy Doctrine", "By DHH", ""]
  if mode == "index":
    lines += [f"{i + 1:2}. {title}" for i, (title, _, _) in enumerate(principles)]
  else:
    entries = principles if mode == "full" else [principles[selected]]
    for title, body, _ in entries:
      lines += [title, "", textwrap.fill(body, 80), ""]
  url = principles[selected][2] if mode == "read" else WEBSITE
  return "\n".join(lines).rstrip() + "\n\n" + url + "\n"


def open_website(url):
  result = subprocess.run(["omarchy-launch-browser", url], stdout=subprocess.DEVNULL,
                          stderr=subprocess.DEVNULL)
  return result.returncode == 0


class Reader:
  def __init__(self, screen, principles, mode="index", selected=0):
    self.screen = screen
    self.principles = principles
    self.mode = mode
    self.selected = selected
    self.scroll = 0
    self.max_scroll = 0
    self.links = []
    self.notice = ""
    self.accent = curses.A_BOLD
    if curses.has_colors() and "NO_COLOR" not in os.environ:
      curses.start_color()
      curses.use_default_colors()
      curses.init_pair(1, curses.COLOR_BLUE, -1)
      self.accent |= curses.color_pair(1)
    self.screen.keypad(True)
    curses.curs_set(0)
    curses.set_escdelay(25)
    curses.mousemask(curses.ALL_MOUSE_EVENTS)
    curses.mouseinterval(0)

  def put(self, y, x, text, style=0, width=None):
    rows, cols = self.screen.getmaxyx()
    if 0 <= y < rows and 0 <= x < cols - 1:
      limit = min(cols - x - 1, width if width is not None else cols)
      self.screen.addnstr(y, x, text, max(0, limit), style)

  def link(self, y, x, label, action, style=0):
    self.put(y, x, label, style)
    self.links.append((y, x, x + len(label), action))

  def select(self, number):
    self.selected = number % len(self.principles)
    self.scroll = 0
    self.notice = ""

  def article(self, width):
    entries = self.principles if self.mode == "full" else [self.principles[self.selected]]
    lines = []
    for title, body, _ in entries:
      lines += [(line, self.accent) for line in textwrap.wrap(title, width)]
      lines.append(("", 0))
      lines += [(line, 0) for line in textwrap.wrap(body, width)]
      lines += [("", 0), ("", 0)]
    return lines[:-2]

  def draw(self):
    self.screen.erase()
    self.links = []
    rows, cols = self.screen.getmaxyx()
    if rows < 20 or cols < 48:
      self.put(0, 0, "The Omarchy Doctrine", self.accent)
      self.put(2, 0, "Resize to at least 48 columns × 20 rows.")
      self.put(4, 0, "w website · q quit")
      self.screen.refresh()
      return

    width = min(cols - 6, 112)
    left = (cols - width) // 2
    self.put(2, left, "OMARCHY  /  DOCTRINE", self.accent)
    self.put(3, left, "Ten principles. By DHH.", curses.A_DIM)
    if self.mode != "index":
      self.link(3, left + width - 7, "← Index", "index", self.accent)
    self.put(5, left, "─" * width, curses.A_DIM)
    wide = width >= 96 and self.mode == "index"
    reading = self.mode != "index" or wide

    if self.mode == "index":
      step = 2 if rows >= 34 else 1
      visible = min(10, max(1, (rows - 16) // step + 1))
      start = min(max(0, self.selected - visible + 1), 10 - visible)
      for row, number in enumerate(range(start, start + visible)):
        title = self.principles[number][0]
        active = number == self.selected
        label = f"{'›' if active else ' '} {number + 1:02}  {title}"
        self.link(8 + row * step, left, label, number,
                  self.accent if active else 0)
      self.link(rows - 7, left, "Read the whole doctrine →", "full", self.accent)

    if reading:
      content_left = left + 36 if wide else left
      content_width = min(68, width - 36 if wide else width)
      if wide:
        for y in range(7, rows - 8):
          self.put(y, left + 32, "│", curses.A_DIM)
      label = "THE FULL DOCTRINE" if self.mode == "full" else f"PRINCIPLE {self.selected + 1:02} / 10"
      self.put(7, content_left, label, curses.A_DIM)
      lines = self.article(content_width)
      available = max(1, rows - 18)
      self.max_scroll = max(0, len(lines) - available)
      self.scroll = min(self.scroll, self.max_scroll)
      for offset, (line, style) in enumerate(lines[self.scroll:self.scroll + available]):
        self.put(9 + offset, content_left, line, style, content_width)
      if wide:
        self.link(rows - 7, content_left, "Enter to read →", "read", self.accent)
      elif self.max_scroll:
        self.put(rows - 7, left, f"{self.scroll + 1}–{min(len(lines), self.scroll + available)} / {len(lines)} lines", curses.A_DIM)

    self.put(rows - 5, left, "─" * width, curses.A_DIM)
    self.link(rows - 4, left, "↗ omarchy.org/doctrine/", "web", curses.A_UNDERLINE)
    if self.notice:
      self.put(rows - 3, left, self.notice, self.accent)
    help_text = "↑↓ choose · Enter read · f full · w web · q quit"
    if self.mode != "index":
      help_text = "↑↓ scroll · ←→ principle · Esc index · w web · q quit"
    if width < len(help_text):
      help_text = "↑↓ choose  ↵ read  f all  w web  q quit" if self.mode == "index" else "↑↓ scroll  Esc index  w web  q quit"
    self.put(rows - 2, left, help_text, curses.A_DIM)
    self.screen.refresh()

  def action(self, action):
    if isinstance(action, int):
      self.select(action)
    elif action in ("read", "full", "index"):
      self.mode = action
      self.scroll = 0
      self.notice = ""
    elif action == "web":
      url = WEBSITE if self.mode == "full" else self.principles[self.selected][2]
      self.notice = "Opened in your browser." if open_website(url) else "Could not open the browser. Use the link above."

  def move(self, delta):
    if self.mode == "index":
      self.select(self.selected + delta)
    else:
      self.scroll = min(self.max_scroll, max(0, self.scroll + delta))

  def mouse(self):
    try:
      _, x, y, _, state = curses.getmouse()
    except curses.error:
      return
    if state & curses.BUTTON4_PRESSED:
      self.move(-3 if self.mode != "index" else -1)
    elif state & curses.BUTTON5_PRESSED:
      self.move(3 if self.mode != "index" else 1)
    elif state & (curses.BUTTON1_PRESSED | curses.BUTTON1_CLICKED):
      for row, start, end, action in self.links:
        if row == y and start <= x < end:
          self.action(action)
          if isinstance(action, int) and self.screen.getmaxyx()[1] - 6 < 96:
            self.action("read")
          break

  def run(self):
    while True:
      self.draw()
      key = self.screen.getch()
      if key in (ord("q"), 3):
        break
      if key == 27:
        if self.mode == "index":
          break
        self.action("index")
      elif key in (curses.KEY_DOWN, ord("j")):
        self.move(1)
      elif key in (curses.KEY_UP, ord("k")):
        self.move(-1)
      elif key in (curses.KEY_RIGHT, ord("l"), curses.KEY_LEFT, ord("h")):
        self.select(self.selected + (1 if key in (curses.KEY_RIGHT, ord("l")) else -1))
        if self.mode == "full":
          self.action("read")
      elif key in (10, 13, curses.KEY_ENTER):
        self.action("read")
      elif key == ord("f"):
        self.action("full")
      elif key == ord("w"):
        self.action("web")
      elif ord("0") <= key <= ord("9"):
        self.select((key - ord("1")) % 10)
        if self.mode == "full":
          self.action("read")
      elif key == ord(" ") and self.mode == "index":
        self.action("read")
      elif key in (curses.KEY_NPAGE, ord(" ")):
        self.move(max(1, self.screen.getmaxyx()[0] - 18))
      elif key == curses.KEY_PPAGE:
        self.move(-max(1, self.screen.getmaxyx()[0] - 18))
      elif key == curses.KEY_HOME:
        self.scroll = 0
        if self.mode == "index":
          self.select(0)
      elif key == curses.KEY_END:
        self.scroll = self.max_scroll
        if self.mode == "index":
          self.select(9)
      elif key == curses.KEY_MOUSE:
        self.mouse()


def main(args):
  if args in (["--help"], ["-h"]):
    print(USAGE)
    return 0
  if len(args) > 1 or (args and args[0] not in ["--plain", "--full", "--web", *map(str, range(1, 11))]):
    print(USAGE, file=sys.stderr)
    return 2
  if args == ["--web"]:
    return 0 if open_website(WEBSITE) else 1
  principles = load_principles()
  mode, selected = "index", 0
  if args == ["--full"]:
    mode = "full"
  elif args and args[0].isdigit():
    mode, selected = "read", int(args[0]) - 1
  interactive = sys.stdin.isatty() and sys.stdout.isatty() and os.environ.get("TERM", "dumb") != "dumb"
  if args == ["--plain"] or not interactive:
    print(plain_text(principles, mode, selected), end="")
  else:
    try:
      curses.wrapper(lambda screen: Reader(screen, principles, mode, selected).run())
    except KeyboardInterrupt:
      return 130
  return 0


if __name__ == "__main__":
  sys.exit(main(sys.argv[1:]))
