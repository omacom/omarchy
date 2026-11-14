"""Handle shortcut edits requested by the Omarchy keybindings menu."""

import fcntl
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from dataclasses import dataclass
from pathlib import Path

MODIFIERS = {"SHIFT": 1, "CTRL": 4, "ALT": 8, "SUPER": 64}
SEPARATOR = "\x1f"
STATE = Path(os.environ.get("XDG_STATE_HOME") or Path.home() / ".local/state") / "omarchy/keybindings.tsv"


@dataclass(frozen=True)
class Binding:
  modifiers: int
  key: str
  description: str
  reference: str
  identity: str
  ignore_modifiers: bool

  @property
  def label(self):
    return self.description or self.key


def run(*args, input=None):
  return subprocess.run(args, input=input, text=True, capture_output=True, check=True, timeout=15).stdout.rstrip("\n")


def select(prompt, options=(), *, editable=(), detail="", capture=False):
  with tempfile.TemporaryDirectory(prefix="omarchy-keybindings-") as directory:
    done = Path(directory) / "done"
    selection = Path(directory) / "selection"
    request = {
      "mode": "input" if capture else "select",
      "prompt": prompt,
      "options": list(options),
      "editableShortcuts": list(editable),
      "shortcutDetail": detail,
      "shortcutCapture": capture,
      "width": 800,
      "maxHeight": 500,
      "selectionFile": str(selection),
      "doneFile": str(done),
    }
    if run("omarchy-shell", "shell", "summon", "omarchy.menu", json.dumps(request)) != "ok":
      raise ValueError("The Omarchy menu could not open.")
    while not done.exists():
      time.sleep(0.05)
    return selection.read_text().removesuffix("\n") if selection.exists() else ""


def read_bindings():
  # The compositor reference pairs each displayed binding with its own Lua
  # declaration, even when several actions have the same description or chord.
  with tempfile.TemporaryDirectory(prefix="omarchy-bindings-") as directory:
    inventory = Path(directory) / "bindings"
    lua_path = json.dumps(str(inventory), ensure_ascii=False)
    run("hyprctl", "eval", f'require("default.hypr.binding-overrides").export({lua_path})')
    if not inventory.exists():
      return []
    managed = {}
    for line in inventory.read_text().splitlines():
      reference, identity, key = line.split("\t")
      managed[reference] = (identity, key)

  bindings = []
  for line in run("omarchy-menu-keybindings", "--raw-bindings").split("\n"):
    if not line:
      continue
    modifiers, key, description, dispatcher, reference, submap, flags = line.split(SEPARATOR)
    if submap:
      continue
    identity, key = managed.get(reference, ("", key)) if dispatcher == "__lua" else ("", key)
    bindings.append(Binding(
      int(modifiers), key, description, reference if identity else "", identity, "i" in flags
    ))
  return bindings


def key_symbol(code):
  flags = []
  for field in ("rules", "model", "layout", "variant", "options"):
    value = json.loads(run("hyprctl", "-j", "getoption", f"input:kb_{field}"))["str"]
    if value:
      flags.extend((f"--{field}", value.split(",")[0] if field in ("layout", "variant") else value))
  keymap = run("xkbcli", "compile-keymap", *flags, input="")
  name = re.search(rf"<(\w+)>\s*=\s*{code};", keymap)
  if not name:
    raise ValueError("The recorded key is unavailable in Hyprland’s keyboard layout.")
  symbol = re.search(rf"\bkey\s*<{name[1]}>\s*\{{[^\n\[]*\[\s*(\w+)", keymap)
  if not symbol or symbol[1] == "NoSymbol":
    raise ValueError("The recorded key has no symbol in Hyprland’s keyboard layout.")
  return symbol[1]


def read_shortcut(selection):
  shortcut = json.loads(selection)
  if not isinstance(shortcut, dict):
    raise ValueError("The keyboard did not return a valid shortcut.")
  code = shortcut.get("code")
  names = shortcut.get("modifiers")
  if type(code) is not int or not 8 <= code <= 767 or not isinstance(names, list):
    raise ValueError("The keyboard did not return a valid shortcut.")
  if not all(isinstance(name, str) and name in MODIFIERS for name in names) or len(set(names)) != len(names):
    raise ValueError("The keyboard did not return valid modifiers.")
  return code, names, key_symbol(code)


def write_overrides(overrides):
  with tempfile.NamedTemporaryFile(mode="w", dir=STATE.parent, delete=False) as output:
    temporary = Path(output.name)
    try:
      output.write("".join(f"{identity}\t{chord}\n" for identity, chord in overrides.items()))
      output.close()
      temporary.replace(STATE)
    finally:
      temporary.unlink(missing_ok=True)


def save_binding(source, chord, mask, conflicts, snapshot):
  STATE.parent.mkdir(parents=True, exist_ok=True)
  with STATE.with_suffix(".lock").open("a") as lock:
    fcntl.flock(lock, fcntl.LOCK_EX)
    if read_bindings() != snapshot:
      raise ValueError("The shortcuts changed while editing. Open the menu and try again.")
    if run("hyprctl", "configerrors").strip():
      raise ValueError("Hyprland has configuration errors. Fix them before editing shortcuts.")

    existed = STATE.exists()
    previous = dict(line.split("\t", 1) for line in STATE.read_text().splitlines()) if existed else {}
    overrides = {**previous, source.identity: chord}
    overrides.update({binding.identity: "" for binding in conflicts})
    write_overrides(overrides)
    try:
      run("hyprctl", "reload")
      errors = run("hyprctl", "configerrors").strip()
      if errors:
        raise ValueError(errors)
      current = {binding.identity: binding for binding in read_bindings() if binding.identity}
      changed = current.get(source.identity)
      code = chord.split(" + ")[-1]
      if (
        not changed or changed.key != code or changed.modifiers != mask
        or any(binding.identity in current for binding in conflicts)
      ):
        raise ValueError("Hyprland did not apply the shortcut change.")
    except (OSError, ValueError, subprocess.SubprocessError):
      if existed:
        write_overrides(previous)
      else:
        STATE.unlink(missing_ok=True)
      run("hyprctl", "reload")
      raise


def translate(command, *args):
  # The catalog checker finds literal omarchy-i18n calls in Python as well as Bash.
  return run(*command.split(), *args)


def choose_binding(row, bindings):
  if len(bindings) == 1:
    return bindings[0]
  chords = row.split(" → ", 1)[0].strip().split(" / ")
  if len(chords) == len(bindings):
    labels = chords
  else:
    labels = [f"{binding.label} ({index})" for index, binding in enumerate(bindings, 1)]
  selection = select(translate("omarchy-i18n keybindings.chooseShortcut"), labels)
  return bindings[labels.index(selection)] if selection else None


def edit_binding(row, choices, bindings):
  source = choose_binding(row, choices)
  if not source:
    return False
  captured = select(translate("omarchy-i18n keybindings.recordShortcut"), detail=source.label, capture=True)
  if not captured:
    return False
  code, modifiers, symbol = read_shortcut(captured)
  mask = sum(MODIFIERS[name] for name in modifiers)
  matching_keys = {symbol.casefold(), f"code:{code}"}
  if source.modifiers == mask and source.key.casefold() in matching_keys:
    return False
  conflicts = [
    binding
    for binding in bindings
    if binding != source
    and binding.key.casefold() in matching_keys
    and (binding.modifiers == mask or binding.ignore_modifiers or source.ignore_modifiers)
  ]
  replaced = []
  if conflicts:
    replace = translate("omarchy-i18n keybindings.replace")
    add = translate("omarchy-i18n keybindings.addAnyway")
    cancel = translate("omarchy-i18n keybindings.cancel")
    can_replace = all(binding.identity for binding in conflicts)
    options = [cancel, replace, add] if can_replace else [cancel, add]
    labels = ", ".join(dict.fromkeys(binding.label for binding in conflicts))
    if not can_replace:
      labels += "\n" + translate("omarchy-i18n keybindings.externalConflict")
    shortcut = " + ".join([*modifiers, symbol.upper()])
    answer = select(translate("omarchy-i18n keybindings.conflict", shortcut), options, detail=labels)
    if can_replace and answer == replace:
      replaced = conflicts
    elif answer != add:
      return False
  chord = " + ".join([*modifiers, f"code:{code}"])
  save_binding(source, chord, mask, replaced, bindings)
  return True


def main(prompt, records):
  rows = []
  references = []
  for record in records:
    if not record:
      continue
    row, _, refs = record.partition(SEPARATOR)
    rows.append(row.partition("\t")[0])
    references.append(refs.split())

  if not rows:
    return 0

  bindings = read_bindings()
  by_reference = {binding.reference: binding for binding in bindings if binding.reference}
  editable = {
    index: [by_reference[ref] for ref in refs]
    for index, refs in enumerate(references)
    if refs and all(ref in by_reference for ref in refs)
  }
  while True:
    selected = select(prompt, rows, editable=editable)
    if not selected.startswith("edit-shortcut:"):
      if selected:
        print(selected)
      return 0
    index = int(selected.removeprefix("edit-shortcut:"))
    if index not in editable:
      continue
    try:
      if edit_binding(rows[index], editable[index], bindings):
        return 3
    except (OSError, ValueError, subprocess.SubprocessError) as error:
      select(
        translate("omarchy-i18n keybindings.editFailed"),
        [translate("omarchy-i18n keybindings.ok")],
        detail=str(error),
      )
      return 3


if __name__ == "__main__":
  try:
    with (Path(os.environ["XDG_RUNTIME_DIR"]) / "omarchy-keybindings-picker.lock").open("a") as lock:
      try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
      except BlockingIOError:
        sys.exit(0)
      sys.exit(main(sys.argv[1], sys.stdin.read().rstrip("\n").split("\n")))
  except (OSError, ValueError, subprocess.SubprocessError) as error:
    print(error, file=sys.stderr)
    sys.exit(2)
