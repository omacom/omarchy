# Reach Omarchy Widget

Bar widget for [Reach](https://github.com/omacom/reach): one keyboard and mouse across your Omarchy machines on Circle.

## Features

- Hidden until Circle is up and another of your machines is close by (or a row is set), like Continuity offering Universal Control
- Left click opens the panel; right click turns Reach on or off on this machine
- The row of machines drawn like the Display panel's layout, this machine in the accent
- Drag a machine to move it in the row, or take it out with its ×
- Add your other Circle machines at either end of the row
- The row is written with `reach arrange`, and Reach hands it to every other machine

## Keyboard shortcuts

Inside the panel:

- `j` / `k` or arrows: move between the switch, the row and the machines to add
- `h` / `l` on the row: pick a machine; `ctrl+h` / `ctrl+l`: move it
- `x` or `delete` on the row: take the picked machine out
- `h` / `l` on a machine to add: add it on that side; `enter` adds it on the right
- `t`: turn Reach on or off
- `r`: refresh
- `esc`: close

From a script: `omarchy-shell omarchy.reach place <machine> left|right` and `omarchy-shell omarchy.reach unplace <machine>`.

## Requirements

- `reach` on `PATH`, with its `reach.service` user unit
- Circle, with your machines in one network, for Reach to find them

## State

Reach keeps `$XDG_RUNTIME_DIR/reach.json` current: the row, the machines it's connected to, and your Circle machines, marking the ones close by (a direct, fast path from one of this machine's own networks). The panel watches that file, so a hidden icon runs nothing. Opening the panel, or right-clicking its icon, asks systemd whether Reach is installed and running, since the file stays behind when it's turned off and is gone after a reboot.

## In the bar

`omarchy.reach` is in the default bar, before the network icon, and hides itself until it's useful. Add it to a bar by hand with `omarchy plugin enable omarchy.reach`.
