# Omarchy Shell Development

Read this before editing the Quickshell desktop under `shell/`.

The Quickshell desktop runs as a single long-running process out of
`shell/`. Hyprland autostart launches it directly with `quickshell -n -p`;
do not start additional standalone Quickshell instances for individual
components.

Run `omarchy-restart-shell` after making changes to QML files.

## Plugin contract

- First-party plugins live directly under `shell/plugins/` or one category
  level deeper, such as `shell/plugins/panels/weather/`. First-party bar-only
  widgets may use adjacent `*.manifest.json` files. Third-party plugins live
  at `~/.config/omarchy/plugins/<id>/` with a `manifest.json` at the root.
- Every plugin manifest declares `schemaVersion`, `id`, `name`, `version`,
  `kinds`, and `entryPoints`. See
  [`docs/omarchy-shell.md`](../../docs/omarchy-shell.md) and
  `shell/services/PluginRegistry.qml` for the current contract; fields such as
  `activation` are optional.
- Entry-point QML files are `Item`s (not `ShellRoot`), and accept the shell-injected properties `omarchyPath`, `shell`, `manifest`, and `pluginRegistry` / `barWidgetRegistry` as appropriate. First-party plugins receive the host objects. Third-party plugins receive capability-scoped facades: ordinary plugins may look up and control only their own service and lifecycle, built-in clones retain narrow source-specific configuration and UI compatibility, menu plugins receive an application-library facade, and plugins can read detached scalar bar state; full-bar plugins additionally receive detached bar configuration and widget-catalog snapshots, narrow proxies for the non-authentication services used by built-in bar widgets, and lifecycle control over configured non-authentication UI plugins. Authentication capabilities must be stamped from trusted first-party manifests, and third-party registry views and bar configuration must be detached snapshots rather than shared objects. These facades reduce accidental authority but are not a same-process QML sandbox: a visual bar widget can walk its parent hierarchy to ordinary host objects. Authentication services must therefore remain outside both `ShellRoot._services` and the host QObject tree. Do not expose authentication services through new third-party-facing properties.
- Panel / overlay / menu plugins must expose `open(payloadJson)` and
  `close()` lifecycle methods for `shell summon` and `shell hide`.
- A panel built on `KeyboardPanel` passes its card as `content: PanelKeyCatcher { … }` rather than as children, so the tree is built the first time the panel opens instead of at startup on every monitor, and kept from then on. Ids inside the content are invisible to the rest of the file: expose the ones root-level code needs with `property alias` on the content root, read them through `panel.loadedContent` (null until the first open), and keep anything that must run while the panel is closed (timers, data, IPC) outside the content.

## IPC

- `bin/omarchy-shell` is the canonical IPC entry point. It forwards to
  the running shell and does not start it. Prefer it over re-implementing
  direct Quickshell socket calls in every CLI.
- The `shell` IPC target exposes lifecycle and configuration methods including
  `ping`, `summon`, `hide`, `toggle`, `call`, `rescanPlugins`, `reloadConfig`,
  `setPluginEnabled`, and `listPlugins`. `shell.qml` also registers
  `image-selector`, which drives the `omarchy.image-picker` panel.
- Individual plugins register their own IPC targets, named for the plugin rather
  than for where they appear: the background switcher registers `background`, and
  bar widgets register one target each — `omarchy.indicators`,
  `omarchy.system-update`, `omarchy.clock`. There is no `bar` target.

## Keeping state current without polling

The shell runs all day on battery, and a widget is built once per monitor, so a `Timer` that starts a `Process` costs that process times the number of monitors, every tick, forever. Don't poll for state that only changes through known events. Pick the first of these that fits:

- A native Quickshell service that signals on change: `UPower` and `PowerProfiles` (`Quickshell.Services.UPower`), `Hyprland` and each workspace's `lastIpcObject`, `Pipewire`, `Mpris`, `SystemTray`, `Notifications`.
- An event stream the shell already runs, such as the Hyprland IPC events or the long-running `pactl subscribe` in `Commons/UntypedInput.qml`. Extend it rather than starting a second one.
- A file watch: `FileView` with `watchChanges`, or the directory watch in `plugins/bar/Bar.qml`, when the state lives in a file the user can read.
- A push from the command that changes the state. If only Omarchy commands change it, have them call `omarchy-shell -q <target> refresh` after the change, the way `omarchy-reminder` and `omarchy-sudo-passwordless` do. When the change happens later, without a command running (an expiry, say), schedule the refresh with a transient `systemd-run --user --on-active=…` timer. A root-owned timer cannot reach the user's shell.

Polling is the last resort, kept for state with no change signal at all (a remote API, say). Then gate the timer on the panel being open where you can, pick the longest interval the UI can tolerate, and put the poll in one shared service rather than in a per-monitor widget. Never poll a privileged probe: every `sudo -n` can write to the auth log.

## Editing widget files with glyphs

Widget files in `shell/plugins/bar/widgets/` contain Nerd Font glyphs as raw
unicode characters. Agent file-editing tools can strip multi-byte codepoints
in some positions — do **not** rewrite widget files wholesale through those
tools. For glyph fixes, make a targeted edit with the surrounding context, or
use a Python script that inserts codepoints via `chr(0xXXXXX)`.

## Palette references

Import `qs.Commons as Commons` and use `Commons.Color` for the palette singleton, including `Connections.target`. Qt 6.12 introduces a `Color` type in `QtQuick` that shadows unqualified palette references. This applies to first-party components and third-party plugin QML alike. Keep the unqualified `qs.Commons` import when the file also uses `Style`, `Util`, or `Border`.
