#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The notification persistence queue is serial. An oversized notification used
# to be serialized into the spawned process's argv, where Linux's MAX_ARG_STRLEN
# made the spawn fail with E2BIG. A failed spawn emits no `exited`, so the queue
# stalled and every notification behind the oversized one went unpersisted.
#
# Drive the real queue through the D-Bus notification server and prove that the
# notification arriving after an oversized one still reaches disk. The source
# checks in test/shell.d only inspect text, so this is what actually exercises
# Service.qml's stdin handoff and queue.

state="$HOME/.local/state/omarchy/notifications"
huge_marker="omarchy-f2-huge-$$"
after_marker="omarchy-f2-after-$$"

marker_present() {
  grep -rlq -- "$1" "$state" 2>/dev/null
}

cleanup() {
  omarchy-shell -q notifications dismissAll >/dev/null 2>&1 || true
  sleep 1
  grep -rl -- "$huge_marker" "$state" 2>/dev/null | xargs -r rm -f
  grep -rl -- "$after_marker" "$state" 2>/dev/null | xargs -r rm -f
}
trap cleanup EXIT

# Build the notification bodies in-process. A CLI tool would pass the body as a
# single argv element and hit the very limit this test is about; python-gobject
# is part of the base install and speaks D-Bus directly.
python3 - "$huge_marker" "$after_marker" <<'PY'
import sys
import gi

gi.require_version("Gio", "2.0")
from gi.repository import Gio, GLib

huge_marker, after_marker = sys.argv[1], sys.argv[2]
bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)


def notify(summary, body):
    bus.call_sync(
        "org.freedesktop.Notifications",
        "/org/freedesktop/Notifications",
        "org.freedesktop.Notifications",
        "Notify",
        GLib.Variant(
            "(susssasa{sv}i)",
            ("omarchy-acceptance", 0, "", summary, body, [], {}, -1),
        ),
        None,
        Gio.DBusCallFlags.NONE,
        -1,
        None,
    )


# ~140 KiB keeps the serialized JSON safely past MAX_ARG_STRLEN (131072), with
# the marker at the end so a truncated body is caught.
notify("acceptance huge", "x" * 140000 + huge_marker)
notify("acceptance after", after_marker)
PY

wait_until "oversized notification is persisted" 30 marker_present "$huge_marker"
wait_until "notification after the oversized one is persisted" 30 marker_present "$after_marker"
