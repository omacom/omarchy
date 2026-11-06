"""Select notifications sent by Fcitx, including addons with custom app names."""

from pathlib import Path
import re
import sys


def input_notifications(text, initial_owner):
  calls = re.split(r"(?m)^(?=(?:method call|signal|method return|error)\b)", text)
  owners = {initial_owner}
  for call in calls:
    if "interface=org.freedesktop.DBus; member=NameOwnerChanged" in call.split("\n", 1)[0]:
      names = re.findall(r'^\s*string "([^"]*)"', call, re.MULTILINE)
      if len(names) == 3 and names[0] == "org.fcitx.Fcitx5":
        owners.update(names[1:])
  owners.discard("")
  for call in calls:
    header = call.split("\n", 1)[0]
    if "interface=org.freedesktop.Notifications; member=Notify" not in header:
      continue
    sender = re.search(r"\bsender=(\S+)", header)
    if sender and sender[1] in owners:
      yield call


if __name__ == "__main__":
  found = list(input_notifications(Path(sys.argv[1]).read_text(errors="replace"), sys.argv[2]))
  if found:
    print("\n".join(found))
  raise SystemExit(1 if found else 0)
