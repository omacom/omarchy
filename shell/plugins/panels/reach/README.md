# Reach Omarchy Widget

Bar widget for [Reach](https://github.com/omacom/reach): one keyboard and mouse across your Omarchy machines on Circle.

## Features

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

From a script: `omarchy-shell omarchy.reach place <machine> left|right` and `omarchy-shell omarchy.reach unplace <machine>` (the panel must have been opened once).

## Requirements

- `reach` on `PATH`, with its `reach.service` user unit
- `circle` on `PATH`, signed in, to list the machines to add

## Add to the bar

This widget ships as first-party plugin `omarchy.reach`. Circle's `circle omarchy install` adds it; by hand, `omarchy plugin enable omarchy.reach`.
