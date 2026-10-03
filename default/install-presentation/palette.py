"""Read the active Omarchy theme without executing theme content."""
import os
from pathlib import Path
import re
import tomllib


def colors():
  if "NO_COLOR" in os.environ:
    return "", "", ""
  state = Path(os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state")))
  try:
    with (state / "omarchy/current/theme/colors.toml").open("rb") as source:
      theme = tomllib.load(source)
  except (OSError, ValueError):
    theme = {}

  def color(key, fallback):
    value = theme.get(key)
    if isinstance(value, str) and re.fullmatch(r"#[0-9a-fA-F]{6}", value):
      rgb = [int(value[i:i + 2], 16) for i in (1, 3, 5)]
      return "\033[38;2;{};{};{}m".format(*rgb)
    return f"\033[{fallback}m"

  return color("accent", 34), color("bright_foreground", 97), color("red", 31)
