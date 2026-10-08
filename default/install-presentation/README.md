# Default terminal presentation

Every command launched through `omarchy-launch-floating-terminal-with-presentation` uses this dashboard, including dedicated installers, generic app installs, AUR installs and interactive setup. There is no installer allowlist.

The worker has a real PTY and controlling terminal, always visible beneath the logo. Download output, installation output, password prompts and full-screen menus share this area. Keyboard input goes directly to the worker without pressing Tab or switching views. The worker controls password echo; passwords entered without terminal echo are not logged. libvterm contains clearing, scrolling, alternate screens and cursor movement within the embedded area, answers terminal queries, and receives resize events. **Ctrl+C** reaches the worker's foreground terminal process.

One continuous snake animation covers downloading, checking and installing. It advances on English pacman milestones, aggregate download percentages and package transaction counters without resetting between phases. The percentage beneath the logo is an approximate share of these stages, marked with ~, not a download-time estimate. It follows the drawn snake and reaches 100% only after successful exit. Starting the next package credits the preceding package. Unknown work waits at the last known milestone. After completion, **L** opens the full private log under `$XDG_STATE_HOME/omarchy/installs`; Enter/Escape closes the panel.


The 380-cell path comes from Tom Ballard's [ISO animation PR #199](https://github.com/omacom/omarchy-iso/pull/199), commit `985cf4c`. The terminal composition follows the locally reviewed app-install preview. Rendering uses Python and libvterm, declared in the base package set.

The logo and completion percentage use the active theme’s `accent` from `colors.toml`, loaded when the window opens. The head uses `bright_foreground` and failures use `red`. Missing or invalid values fall back to terminal palette colours; `NO_COLOR` suppresses colour.
