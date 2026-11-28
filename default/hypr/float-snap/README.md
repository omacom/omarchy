# Float Snap

Enable **Appearance → Windows → Float Snap**, then hold Shift while dragging a floating window's border, corner or title bar. Releasing Shift immediately returns to ordinary dragging. The invisible grid uses 32 logical pixels, anchored to each monitor's usable floating work area, so display scaling, menu bars and reserved space are respected.

Only windows on an Omarchy Floating workspace participate. Individually floating windows on Tiling or Scrolling workspaces, application Shift-click/drag gestures, existing mouse bindings, and aspect-ratio-constrained windows keep their existing behavior. App minimum and maximum dimensions take priority over grid alignment.

`omarchy hyprland float snap [status|on|off|toggle]` controls the same setting. Enabling builds the native extension with the installed Hyprland development headers and C++ compiler. Binaries are cached by source and compositor ABI under the user's Omarchy state directory. Loaded binaries are never overwritten. If the compositor ABI changes, toggle the setting off and on to rebuild. The extension refuses a mismatched ABI.

The compositor extension transforms geometry only for the active interactive drag. It consumes no input events, creates no visible surfaces and runs no polling process. Raw pointer geometry is recomputed by Hyprland on each motion, keeping sub-grid movement from getting lost or accumulating rounding errors. Geometry is snapped before the app receives it, without intermediate unsnapped resize events. Unloading removes both hooks.

Shift conflict audit: the default bindings and current personal bindings contain no Shift mouse-drag binding. The two existing Super mouse bindings remain intact. Hyprland 0.56.2's native border resize does not assign another meaning to Shift.

Tests: `bash test/shell.d/hyprland-float-snap-test.sh`. Native local verification also covers both monitors, edge/corner/title-bar dragging, engaging and releasing Shift during a drag, excluding floating windows on tiling workspaces, configuration reload, and toggling through the actual menu. 
