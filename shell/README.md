# Omarchy shell

`omarchy-shell` is a single long-running [Quickshell](https://quickshell.org/)
instance that hosts the Omarchy desktop. Hyprland autostart launches one shell
per graphical session; everything else — the bar, background switcher, panels,
and overlays — runs **inside** the shell as a plugin.

Hosting everything inside one shell means:

- shared services and singletons live once, not once per process
- summoning a panel is an IPC call into a process that is already running,
  not a fresh `quickshell -p ...` cold start
- third-party plugins can be loaded from disk without changing any source
  code in Omarchy itself

The runtime layout:

```
shell/
  shell.qml              entry point (ShellRoot)
  services/
    PluginRegistry.qml   discovers, validates plugins, looks up enabled state in shell.json
    BarWidgetRegistry.qml unified registry for bar widgets (1p + 3p)
  plugins/
    bar/                 first-party plugins (see plugins/README.md)
    image-picker/
    menu/
    notifications/
    panels/
      audio/
      bluetooth/
      monitor/
      network/
      power/
      weather/
    agents/
    services/
      battery/
      idle/
    osd/
    polkit/
```

The plugin discovery path is documented in [plugins/README.md](plugins/README.md).

## Plugin manifest

Every plugin ships a `manifest.json` describing what it is and how the
shell should load it. Minimal example:

```json
{
  "schemaVersion": 1,
  "id": "my.org.cool-clock",
  "name": "Cool clock",
  "version": "1.0.0",
  "author": "You",
  "description": "A clock that does cool things",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "Cool clock",
    "category": "Time",
    "allowMultiple": false,
    "defaultSection": "left",
    "defaults": { "format": "HH:mm" },
    "schema": [
      { "key": "format", "type": "string", "label": "Format" }
    ]
  }
}
```

Supported `kinds`:

| Kind         | What it is                                                   |
|--------------|--------------------------------------------------------------|
| `bar-widget` | A component that the active bar can drop into a section      |
| `panel`      | A persistent or summoned floating window (e.g. OSD)          |
| `overlay`    | A fullscreen overlay (e.g. background switcher)              |
| `menu`       | A summoned menu surface                                      |
| `service`    | A headless singleton, no UI                                  |
| `bar`        | A full bar option that can replace the built-in `omarchy.bar` |

Only one `bar` plugin is active at a time. Missing or invalid selections fall
back to the built-in `omarchy.bar`, so users always have a safe path home.
Panels, overlays, and menus are loaded when summoned. Plugins that need
to outlive a single summon can set `keepLoaded: true` (e.g. the image
picker keeps its overlay window mounted between summons). The same flag
keeps a service mounted across plugin hot-reload, so tearing down a
changed bar widget cannot destroy `omarchy.lock` while Hyprland still
holds the session lock. The kept instance is not replaced, so code
changes to a `keepLoaded` service itself only take effect on a shell
restart. First-party services are loaded at startup.

Entry points may declare `omarchyPath`, `shell`, `manifest`, `pluginRegistry`, and `barWidgetRegistry` properties for host injection. Built-in plugins receive the trusted host objects. Third-party plugins receive capability-scoped facades: ordinary plugins can look up and control only their own service and lifecycle, built-in clones retain narrow source-specific configuration and UI compatibility, menu plugins receive an application-library facade, and plugins can read detached scalar bar state. A full-bar plugin additionally receives detached bar configuration and widget-catalog snapshots, narrow proxies for the non-authentication services used by built-in bar widgets, and lifecycle control over configured non-authentication UI plugins. Authentication capabilities are stamped from trusted first-party manifests, authentication services are retained outside the host's public service map and QML object tree, and changing a third-party registry or configuration snapshot cannot mutate host state. Facades do not isolate visual widgets from the parent hierarchy of the shared QML scene, so sensitive state must remain outside that reachable graph.

Widgets rendered by a third-party replacement bar receive a service-less entry facade with target-scoped lifecycle and settings operations. Their live service objects are available only when the trusted built-in bar hosts them; otherwise the replacement bar could request and retain any configured widget's service.

The shell-loading schema lives in `services/PluginRegistry.qml`. The CLI also
validates optional [pre-removal cleanup](#pre-removal-cleanup) metadata.

## Installing a third-party plugin

A plugin is a **git repo** with a `manifest.json` at its root. Adding one
clones it straight into `~/.config/omarchy/plugins/<id>/` (named by the
manifest id); updating is a fast-forward pull of that checkout.

```bash
omarchy plugin add https://github.com/acme/omarchy-weather.git
omarchy plugin update acme.weather       # fetches, shows a diff, fast-forwards
omarchy plugin update                    # updates every git-managed plugin
omarchy plugin remove acme.weather
```

> ⚠️ **Plugins run as unsandboxed code inside `omarchy-shell`.** Adding warns you before cloning, plugins land disabled so you can review the code before enabling, and updates show a diff of the changes before touching anything. The scoped QML interfaces remove direct authentication-service and generic replacement-bar service lookups, but visual plugins still share and can traverse the ordinary host scene. Only add repos whose code you are willing to run.

Commands use terminal pickers and confirmations when needed. Pass `--yes` to skip ordinary confirmation prompts in scripts and AI agents. Removal hooks require separate execution authorization, described below:

```bash
omarchy plugin add https://github.com/acme/omarchy-weather.git --enable --yes
omarchy plugin update --yes
```

The installer never runs plugin code, install hooks, or sudo — it only clones
files, validates the manifest, and toggles enabled state over shell IPC. Since
an installed plugin is a plain git checkout, anything beyond add/update
(pinning a ref, switching branches) is ordinary git in the plugin directory.

### Pre-removal cleanup

A plugin that owns registrations or other state outside its checkout can declare one optional executable in `manifest.json`:

```json
{
  "hooks": {
    "preRemove": "bin/cleanup"
  }
}
```

The path must name an executable regular file within the checkout. Absolute paths, `..`, control characters, and symlinks in the hook path are rejected. The installed plugin directory itself may be a symlink to a development checkout. `omarchy plugin validate <folder>` checks the declaration and file without executing plugin code. Removal records the checkout identity, manifest contents, and hook identity and contents before prompting, then checks them again before execution. A change aborts removal, including an added or removed hook.

After confirmation, `omarchy plugin remove` runs the hook **before disabling the plugin or deleting, unlinking, or moving its checkout**. It also runs for disabled plugins, including plugins that have never been enabled. The terminal asks separately for permission to execute cleanup code. `--yes` skips the ordinary removal confirmation, but does not authorize code execution. After reviewing the current hook, scripts can authorize both steps explicitly:

```bash
omarchy plugin remove <plugin-id> --yes --run-pre-remove
```

Declining either confirmation leaves the checkout in place without running cleanup. With no declaration, removal behaves as before and needs no execution authorization or systemd user manager.

The executable runs directly, respecting its shebang, with the physical checkout as its working directory, no arguments, the caller's environment and privileges, and standard input connected to `/dev/null`. Omarchy does not invoke `sudo`. Cleanup must be noninteractive. A transient systemd user service supervises the hook and its inherited cgroup, waiting for remaining processes even if the hook leader exits. After 60 seconds, it sends TERM to the group, followed by KILL after a 5-second stop grace period. Running a hook requires a reachable systemd user manager; validation does not.

An invalid declaration, changed snapshot, failure to start, nonzero exit, or timeout aborts removal before the CLI disables the plugin or removes the checkout. Inspect any partial cleanup effects, correct the cause, and retry. Cleanup must be safely retryable: failure does not roll back completed effects. An entirely absent manifest remains removable for recovery of old or broken installations; a present but malformed manifest blocks removal.

Hooks run as **unsandboxed plugin code**, even if the plugin was never enabled. Review the current executable before authorizing it. Path and snapshot checks detect intervening changes, but are not atomic protection against hostile concurrent edits. Process supervision is not a sandbox: hooks must not move cleanup into other services or otherwise escape the supervised cgroup. Hooks must clean up only state they own, wait for their cleanup work to finish, and return zero only when cleanup is complete. If a hook cannot be trusted or repaired, retain the checkout and recover manually; moving it can break external registrations that still point into it.

### Installing by hand

You can still drop a plugin in without git:

1. Put it in `~/.config/omarchy/plugins/<plugin-id>/` with a `manifest.json`
   plus the QML referenced from its `entryPoints`.
2. `omarchy-shell shell rescanPlugins`.
3. `omarchy plugin enable <id>`. Bar widgets start in
   `barWidget.defaultSection`, or in the center when it is omitted, and can be
   moved with `omarchy bar move`; a full bar replaces the one in use.

The lower-level IPC equivalents remain available via `omarchy-shell shell rescanPlugins`,
`omarchy-shell shell enablePlugin <id> '{}'`, and `omarchy-shell shell listPlugins`.
The `omarchy plugin` commands wrap those calls. `omarchy bar move` and
`omarchy bar set` edit the persisted widget layout in `shell.json`.

To hack on a built-in plugin safely, clone it into user config instead of
editing the built-in source. The complete plugin directory is copied, including
every declared kind and local dependency. A built-in id such as
`omarchy.clock` becomes `<username>.clock` (e.g. `dhh.clock`), with `My Clock`
as its display name. The username prefix keeps shared clones from colliding
with each other or with other plugin authors.

```bash
omarchy plugin clone omarchy.clock
```

Cloning switches from the built-in to the new personal plugin, preserving an
existing bar widget's position and settings. Setup > Plugins > Clone provides
the interactive picker, then opens the new `<username>.*` directory in `$EDITOR`.
Existing shortcuts and shell IPC calls made to the built-in id are routed to
the enabled clone, so cloning does not require changing its callers. Removing
an active clone switches back to its built-in source.
Saving a file anywhere under `~/.config/omarchy/plugins/` reloads plugin code
automatically; `omarchy-shell shell rescanPlugins` remains available to force a reload.

First-party plugins under `shell/plugins/` are discovered the same way and load
by default. Disabling a non-widget records it in `disabledPlugins[]`; disabling
a widget removes it from the bar layout while leaving its component available
to add again. A full bar has no off state and is replaced by enabling another.

## IPC contract

The shell exposes a single `shell` IPC target plus whatever extra targets
individual plugins register (e.g. the bar's `bar` target for refresh
hooks, the image picker's `image-selector` target). `omarchy-menu` uses the
shell target to summon the first-party `omarchy.menu` plugin instead of
running a separate Quickshell instance.

| Method                                   | Returns | Effect                                                |
|------------------------------------------|---------|-------------------------------------------------------|
| `ping`                                   | `ok`    | health check                                          |
| `summon <id> <payloadJson>`              | `ok` / `unknown` | load + open a panel/overlay plugin           |
| `hide <id>`                              | —       | close a previously-summoned plugin                    |
| `toggle <id> <payloadJson>`              | —       | summon if closed, hide if open                        |
| `call <id> <method> <arg>`               | string  | call a method on an already-loaded plugin             |
| `rescanPlugins`                          | —       | re-walk plugin dirs and hot-reload plugin code        |
| `reloadConfig`                           | `ok`    | reload `~/.config/omarchy/shell.json`                 |
| `setPluginEnabled <id> <enabled>`        | `ok` / `unknown` | flip the persisted enabled bit (see note)    |
| `listPlugins`                            | JSON    | every discovered plugin, sorted by name               |

Direct invocation:

```
quickshell ipc -p $OMARCHY_PATH/shell call shell ping
```

Hyprland autostart launches the shell directly with `quickshell -p
$OMARCHY_PATH/shell`. Use `omarchy-restart-shell` to stop every running
instance of that config and launch one fresh shell process.

A convenience wrapper, [`omarchy-shell`](../bin/omarchy-shell), forwards IPC
calls to the running shell. It does not start the shell.

```
omarchy-shell shell ping
omarchy-shell shell toggle omarchy.menu '{"menu":"root"}'
omarchy-shell shell listPlugins
omarchy-shell shell rescanPlugins
```

**Note on `setPluginEnabled`:** the `enabled` argument is a string. Only the
literal `"true"` enables the plugin; every other value (including `"True"`,
`"1"`, `"yes"`, or omitted) disables it. This keeps the IPC surface
type-stable across QML's `string`-only IPC arguments.

## Persisted state

There is one user config file. Everything that distinguishes your
customization from the shipped defaults lives in it.

| Path                              | Owner          | Purpose                                                |
|-----------------------------------|----------------|--------------------------------------------------------|
| `~/.config/omarchy/shell.json`    | the shell      | full layout + per-entry settings + enabled plugin list |
| `~/.config/omarchy/plugins/<id>/` | user           | drop-in third-party plugin source files                |

The `config/omarchy/shell.json` default config describes the
fresh-install state. When the user has no `shell.json`, the shell uses
the defaults verbatim. Once the user customizes anything, `shell.json`
becomes the authoritative file — we do **not** deep-merge defaults back in.

### shell.json shape

```json
{
  "version": 1,
  "idle": {
    "screensaver": 150,
    "lock": 300
  },
  "bar": {
    "id": "omarchy.bar",
    "position": "top",
    "transparent": false,
    "centerAnchor": "omarchy.clock",
    "layout": {
      "left":   [ { "id": "omarchy.menu" }, { "id": "omarchy.workspaces" } ],
      "center": [ { "id": "omarchy.clock", "format": "HH:mm" } ],
      "right": [
        { "id": "omarchy.audio" }
      ]
    }
  },
  "plugins": []
}
```

### Storage rules

1. **The active bar option is `bar.id`.** Omit it or set it to `omarchy.bar`
   to use the built-in bar. Set it to another plugin id whose manifest declares
   `kind: "bar"` to replace the full bar.
2. **Every plugin instance is one entry.** Either in `bar.layout.<section>`
   for bar widgets, or in `plugins[]` for panels, overlays, services,
   menus, and anything else non-bar.
3. **Settings are inline on the entry.** No `config:` sub-object, no
   separate per-plugin settings file, no merge layers. The fields on each
   entry are the values the plugin sees.
4. **Built-in widget ids are namespaced.** Use ids such as `omarchy.clock`,
   `omarchy.audio`, and `omarchy.network`. The migration rewrites older ids
   like `Clock` and `AudioPanel` forward.
5. **Third-party enabled ⇔ present.** A third-party plugin is enabled iff
   its id appears somewhere in shell.json. For full bar options, that means
   `bar.id`; for bar widgets, plugin enable/disable adds/removes layout entries;
   other plugin kinds are enabled the same way. First-party non-bar plugins
   are enabled unless listed in `disabledPlugins[]`.
6. **Multiple instances** are allowed when a manifest sets
   `allowMultiple: true`. Each instance is independent — e.g. two clock
   widgets in different timezones are just two `{"id":"omarchy.clock", "timezone": ...}`
   entries with their own values.
7. **Idle timings are top-level.** `idle.screensaver` and `idle.lock`
   are seconds since user idle began, so the default lock fires at 300s
   even if the 150s screensaver starts first.
8. **`version: 1` is required** at the top level. The shell will fall back
   to defaults rather than load an unknown version.

## Implementation history

Built up in phases on this branch:

- Phase 1 — `omarchy-shell phase 1: host the existing bar in a single shell`
- Phase 2 — `omarchy-shell phase 2: plugin registry and bar widget registry`
- Phase 3 — `omarchy-shell phase 3: fold bar-settings into the shell as a panel plugin`
- Phase 4 — `omarchy-shell phase 4: absorb background-switcher as a plugin`
- Phase 5 — `omarchy-shell phase 5: docs, cleanup, and migration crumbs`
- Phase 6 — `omarchy-shell phase 6: reviewer cleanup (path traversal, collision, races)`
- Phase 7 — `omarchy-shell phase 7: replace socket with IpcHandler, rename to image-picker`
- Phase 8a — `omarchy-shell phase 8a: unified shell.json with inline plugin settings`

Shared services and Pipewire/UPower/Hyprland consolidation are explicitly
out of scope here and deferred to a follow-up after a review pass.
