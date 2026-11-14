import colorsys
import glob
import os
import select
import sys
import time

VID = 0x3434
MAGIC = b"\x06\x60\xff\x09\x61"
REPORT_LEN = 32
REPLY_TIMEOUT = 1.0

CMD_BACKLIGHT_GET = 8
CMD_BACKLIGHT_SET = 7
CMD_BACKLIGHT_SAVE = 9
CH_LIGHTING = 3
LID_EFFECT = 2
LID_COLOR = 4


def is_config_interface(hidraw_name, sys_class_hidraw="/sys/class/hidraw"):
  descriptor = os.path.join(sys_class_hidraw, hidraw_name, "device", "report_descriptor")
  try:
    with open(descriptor, "rb") as f:
      return MAGIC in f.read()
  except OSError:
    return False


def find_live_device():
  for path in sorted(glob.glob("/sys/class/hidraw/hidraw*/device")):
    try:
      with open(path + "/uevent") as f:
        hid_id = next((line for line in f if line.startswith("HID_ID=")), "")
    except OSError:
      continue
    try:
      _, vendor, _ = (int(part, 16) for part in hid_id.strip().split("=")[1].split(":"))
    except ValueError:
      continue
    if vendor != VID:
      continue
    hidraw_name = os.path.basename(os.path.dirname(path))
    if not is_config_interface(hidraw_name):
      continue
    node = "/dev/" + hidraw_name
    try:
      fd = os.open(node, os.O_RDWR)
    except OSError:
      continue
    if transact(fd, [1]) is not None:
      return fd
    os.close(fd)
  return None


def transact(fd, cmd):
  try:
    os.write(fd, bytes(cmd) + b"\x00" * (REPORT_LEN - len(cmd)))
  except OSError:
    return None
  deadline = time.monotonic() + REPLY_TIMEOUT
  while time.monotonic() < deadline:
    remaining = deadline - time.monotonic()
    ready, _, _ = select.select([fd], [], [], remaining)
    if not ready:
      break
    try:
      reply = os.read(fd, REPORT_LEN)
    except OSError:
      break
    if reply and reply[0] == cmd[0]:
      return reply
  return None


def set_color(fd, hex_color):
  try:
    r, g, b = (int(hex_color[i:i + 2], 16) for i in (0, 2, 4))
  except ValueError:
    print(f"invalid color: {hex_color} (use RRGGBB)", file=sys.stderr)
    sys.exit(2)
  h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
  hb, sb, vb = round(h * 255), round(s * 255), round(v * 255)
  if transact(fd, [CMD_BACKLIGHT_SET, CH_LIGHTING, LID_EFFECT, 1]) is None:
    sys.exit(3)
  if transact(fd, [CMD_BACKLIGHT_SET, CH_LIGHTING, LID_COLOR, hb, sb, vb]) is None:
    sys.exit(3)
  if transact(fd, [CMD_BACKLIGHT_SAVE, CH_LIGHTING]) is None:
    sys.exit(3)
  time.sleep(0.2)
  print(f"set #{r:02x}{g:02x}{b:02x} (h={hb} s={sb} v={vb}) saved")


def get_color(fd):
  reply = transact(fd, [CMD_BACKLIGHT_GET, CH_LIGHTING, LID_COLOR])
  if reply is None:
    sys.exit(3)
  h, s, v = reply[3], reply[4], reply[5]
  r, g, b = (round(channel * 255) for channel in colorsys.hsv_to_rgb(h / 255, s / 255, v / 255))
  print(f"color #{r:02x}{g:02x}{b:02x} (h={h} s={s} v={v})")


def main(argv=None):
  argv = sys.argv[1:] if argv is None else argv
  if not argv:
    print("usage: omarchy-keychron-rgb <set <RRGGBB>|get>", file=sys.stderr)
    return 2
  fd = find_live_device()
  if fd is None:
    print("keychron config channel not found (or no permission)", file=sys.stderr)
    return 1
  try:
    if argv[0] == "set" and len(argv) >= 2:
      set_color(fd, argv[1].lstrip("#").lower())
    elif argv[0] == "get" and len(argv) == 1:
      get_color(fd)
    else:
      print("usage: omarchy-keychron-rgb <set <RRGGBB>|get>", file=sys.stderr)
      return 2
  finally:
    os.close(fd)
  return 0


if __name__ == "__main__":
  sys.exit(main())
