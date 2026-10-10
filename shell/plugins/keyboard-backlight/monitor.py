#!/usr/bin/python3
"""Read hardware LED notifications; never write keyboard brightness.

ASUS WMI handles some backlight keys in the kernel without emitting a key
press to the compositor. sysfs POLLPRI reports these hardware changes;
regular brightnessctl writes do not produce a second notification here.
"""
import json
import os
from pathlib import Path
import select


def payload_for(value, maximum):
  value = max(0, min(value, maximum))
  percent = (value * 100 + maximum // 2) // maximum
  return {
    "icon": "keyboard",
    "message": "",
    "value": str(value),
    "max": str(maximum),
    "progressText": f"{value}/{maximum}" if maximum <= 10 else f"{percent}%",
    "duration": "",
  }


def acknowledge(fd):
  os.lseek(fd, 0, os.SEEK_SET)
  os.read(fd, 64)


def monitor(leds_path=Path("/sys/class/leds")):
  poller = select.poll()
  devices = {}
  try:
    for led in sorted(leds_path.glob("*kbd_backlight*")):
      try:
        maximum = int((led / "max_brightness").read_text())
        if maximum <= 0:
          continue
        fd = os.open(led / "brightness_hw_changed", os.O_RDONLY | os.O_NONBLOCK)
      except (OSError, ValueError):
        continue
      devices[fd] = (led, maximum)
      acknowledge(fd)
      poller.register(fd, select.POLLPRI | select.POLLERR)

    # Most keyboards expose no hardware notifications. Exit quietly there.
    while devices:
      for fd, flags in poller.poll():
        led, maximum = devices[fd]
        try:
          if flags & (select.POLLHUP | select.POLLNVAL):
            raise OSError("keyboard disconnected")
          acknowledge(fd)
          value = int((led / "brightness").read_text())
        except (OSError, ValueError):
          poller.unregister(fd)
          os.close(fd)
          del devices[fd]
          continue
        print(json.dumps(payload_for(value, maximum)), flush=True)
  finally:
    for fd in devices:
      os.close(fd)


if __name__ == "__main__":
  monitor()
