import io
import json
import re
import sys
from pathlib import Path

from gi.repository import GLib


def parse(text):
  if "\0" in text:
    raise ValueError("NUL bytes are not supported in browser flags")
  arguments = []
  # The Arch launcher parses each fgets() line separately, including its LF.
  # Do not use splitlines(): CR, VT and other characters are not fgets boundaries.
  for number, line in enumerate(io.StringIO(text, newline="\n"), 1):
    try:
      arguments.extend(GLib.shell_parse_argv(line)[1])
    except GLib.Error as error:
      if not error.matches(GLib.shell_error_quark(), GLib.ShellError.EMPTY_STRING):
        raise ValueError(f"invalid flags on physical line {number}; close quotes and escapes on the same line") from error
  return arguments


def token_spans(text):
  # Called with one physical line, so no token may consume the next line.
  spans = []
  i = 0
  while i < len(text):
    if text[i] in " \t\n":
      i += 1
      continue
    # GLib recognizes comments after a space or newline, but not after a tab.
    if text[i] == "#" and (i == 0 or text[i - 1] in " \n"):
      end = text.find("\n", i)
      i = len(text) if end < 0 else end + 1
      continue

    start = i
    quote = None
    while i < len(text):
      char = text[i]
      if char == "\\" and quote != "'":
        if text.startswith("\\\n", i):
          raise ValueError("escaped physical newlines are not supported; keep each argument on one physical line")
        i += 2
        continue
      if quote:
        if char == quote:
          quote = None
      elif char in "'\"":
        quote = char
      elif char in " \t\n":
        break
      elif char == "#" and i > 0 and text[i - 1] in " \n":
        # GLib can splice a comment into an escaped word. Do not delete such a
        # comment along with a switch or guess where that word ends.
        raise ValueError("comments inside escaped arguments are not supported")
      i += 1

    # The prefix lets GLib decode a literal # argument after a tab as well.
    decoded = parse("check\t" + text[start:i])
    if len(decoded) != 2 or decoded[0] != "check":
      raise ValueError("cannot identify browser argument boundaries safely")
    spans.append((start, i, decoded[1]))

  if [argument for _, _, argument in spans] != parse(text):
    raise ValueError("browser argument boundaries disagree with GLib")
  return spans


def merge(text, target, key):
  before = parse(text)
  spans = []
  offset = 0
  for line in io.StringIO(text, newline="\n"):
    spans.extend((start + offset, end + offset, argument) for start, end, argument in token_spans(line))
    offset += len(line)
  stop = before.index("--") if "--" in before else len(before)
  switches = [i for i, argument in enumerate(before[:stop])
    if argument == "--load-extension" or argument.startswith("--load-extension=")]
  last = switches[-1] if switches else None
  paths = before[last].partition("=")[2].split(",") if switches else []
  kept = []
  for extension in paths:
    if not extension or extension in (target, "/usr/share/omarchy/default/chromium/extensions/theme-sync"):
      continue
    manifest = Path(extension) / "manifest.json"
    try:
      legacy = json.loads(manifest.read_text(encoding="utf-8")) if manifest.is_file() else None
    except (OSError, ValueError):
      legacy = None
    if isinstance(legacy, dict) and legacy.get("key") == key:
      continue
    kept.append(extension)
  updated = "--load-extension=" + ",".join([*kept, target])
  quoted = updated if re.fullmatch(r"[A-Za-z0-9_@%+=:,./-]+", updated) else GLib.shell_quote(updated)

  after = text
  for i in reversed(switches):
    start, end, argument = spans[i]
    if "\n" in argument or "\r" in argument:
      raise ValueError("literal newlines in load-extension arguments are not supported")
    raw = text[start:end]
    replacement = ""
    if i == last:
      replacement = raw if argument == updated else quoted
    after = after[:start] + replacement + after[end:]

  if switches:
    expected = [updated if i == last else argument for i, argument in enumerate(before)
      if i not in switches or i == last]
  else:
    # Prepending preserves trailing comments and an unterminated final line, and
    # places the switch before any Chromium end-of-options marker.
    after = quoted + "\n" + text
    expected = [updated, *before]
  if parse(after) != expected:
    raise ValueError("updated browser arguments disagree with the intended merge")
  return after


if __name__ == "__main__":
  try:
    source, target, key = sys.argv[1:]
    text = Path(source).read_bytes().decode("utf-8")
    sys.stdout.buffer.write(merge(text, target, key).encode("utf-8"))
  except (OSError, ValueError, GLib.Error) as error:
    print(f"Cannot merge Theme Sync browser flags: {error}", file=sys.stderr)
    sys.exit(1)
