# omarchy-shell

A single long-running [Quickshell](https://quickshell.org/) instance
that hosts the Omarchy desktop. The bar, panels, overlays, menus, and
services all run inside as plugins. Hyprland autostart launches the
shell via `omarchy-launch-shell`; restart it with `omarchy-restart-shell`.
IPC is the canonical way for CLIs to talk to a running shell —
`omarchy-shell` forwards a call and fails when the shell is not running
(`-q` makes it quiet best-effort; `OMARCHY_SHELL_IPC_TIMEOUT` bounds the
wait).

## Plugin manifest

```json
{
  "schemaVersion": 1,
  "id": "my.org.cool-clock",
  "name": "Cool clock",
  "version": "1.0.0",
  "author": "You",
  "description": "A clock that does cool things",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" }
}
```

`kinds` (a manifest may declare more than one):

| Kind         | What it is                                  |
|--------------|---------------------------------------------|
| `bar-widget` | Component the active bar drops into a section |
| `bar`        | Full bar option that can replace `omarchy.bar` |
| `panel`      | Floating window (e.g. OSD)                     |
| `overlay`    | Fullscreen overlay (e.g. background picker)    |
| `menu`       | Summoned menu surface                          |
| `service`    | Headless singleton, no UI                      |

Only one full bar option is active at a time. The built-in `omarchy.bar` is
used when `bar.id` is omitted or when a selected third-party bar cannot load.
Panels, overlays, and menus are loaded when summoned. Plugins can set the top-level manifest key `keepLoaded: true` to survive between summons, and to keep a service mounted across plugin hot-reload (so `omarchy.lock` is not destroyed while Hyprland still holds the session lock). First-party services are loaded at startup.

Panel discovery updates a keyed loader model instead of rebuilding every panel. Rescanning user plugins preserves unchanged built-in panels and their in-flight commands, so installation can hand off to permission review without losing its caller. User panel code is still unloaded before the component cache is cleared; disabling or removing a panel retires its loader. Restart the shell to load changes to bundled panel code.

Entry points are QML `Item`s. Panel, overlay, and menu entry points expose `open(payloadJson)` and `close()` for summon/hide; on load the host injects `omarchyPath`, `shell`, `manifest`, and the registries (`pluginRegistry` / `barWidgetRegistry`) as properties. Built-in plugins receive the trusted host objects. Third-party plugins receive capability-scoped facades instead: ordinary plugins may look up and control only their own service and lifecycle, built-in clones retain narrow source-specific configuration and UI compatibility, menu plugins receive an application-library facade, and plugins can read detached scalar bar state. A full-bar plugin additionally receives detached bar configuration and widget-catalog snapshots, narrow proxies for the non-authentication services used by built-in bar widgets, and lifecycle control over configured non-authentication UI plugins. Authentication capabilities are stamped from trusted first-party manifests, authentication services are kept out of the host's public service map and QML object tree, and third-party registry/configuration snapshots can be changed only locally without mutating host state. The facades are API boundaries, not same-process QML sandboxes: a visual widget shares the host bar's scene and can walk its parent hierarchy to ordinary host objects. Sensitive state must not rely on the facade alone for isolation.

A third-party replacement bar can render registered widget components, but widgets it hosts receive a service-less entry facade. Allowing the bar to manufacture an own-service facade for an arbitrary widget would also let it retrieve that plugin's live service object. Service-backed third-party widgets therefore retain their full integration only under the trusted built-in bar; a replacement bar may still provide their target-scoped lifecycle and settings operations.

Full schema: [`shell/services/PluginRegistry.qml`](../shell/services/PluginRegistry.qml).

## Installing a third-party plugin

A plugin is a **git repo** with a `manifest.json` at its root. Adding stages and validates a clone before publishing it at `~/.config/omarchy/plugins/<id>/`; updating validates the candidate before a fast-forward merge:

```bash
omarchy plugin add https://github.com/acme/omarchy-weather.git
omarchy plugin update                # fetches, shows a diff, fast-forwards
omarchy plugin remove acme.weather
```

**Setup › Plugins › Manage Plugins** (`omarchy plugin manage`) opens the graphical installer/manager. Enter a Git URL or local repository and choose **Clone & review**. Ward clones once into a unique private `.add.XXXXXXXX/checkout` directory under the user plugin directory and validates automatically. Host-owned source and Git commit metadata live beside the checkout, outside plugin content. The reviewer imports that staged checkout without installing, approving or starting it. **Enable** verifies the reviewed revision and source again, publishes the checkout without replacing an existing plugin, approves the selections and enables through the canonical commands. Closing an idle review or choosing **Deny & Remove** discards only that attempt. Interrupted attempts cannot collide with a fresh stage or occupy the final installed-plugin path. There is no separate Check or Validate action. Errors stay visible. Ward is the default. YOLO is a deliberate opt-in with a final confirmation after **Clone in YOLO mode**: “Do you trust this plugin to execute unsandboxed?” Nothing is cloned until **Yes, clone unsandboxed** is selected; those plugins remain disabled until explicitly enabled. Changing source or mode invalidates that trust, and every fresh Add form defaults to Ward. The manager also provides review, enable, disable/revoke and confirmed removal. The existing Enable/Disable pickers still include built-ins; the separate `omarchy plugin clone` command remains limited to built-ins and opens a terminal/editor.

Select a sandbox plugin in **Manage Plugins** and choose **Review permissions** to inspect its access. Choosing Enable for a sandbox plugin opens that same reviewer; it does not approve or start the plugin automatically.

Staged reviews use ephemeral native snapshots: inspecting or discarding a not-yet-installed plugin leaves no persistent Ward identity or review history. Publication imports the matching revision into the native store immediately before installing it. **Deny & Remove** for an already installed plugin uses full removal, including private saved data and security history, and the reviewer discloses that deletion beside its actions.

Cloning `omarchy.clock`, for example, creates and switches to
`~/.config/omarchy/plugins/<username>.clock/` (e.g. `dhh.clock`), names it
`My Clock`, and preserves the built-in IPC identity so existing shortcuts keep
working. The username prefix keeps a shared clone from colliding with anyone
else's. Saving files in any installed plugin reloads its code automatically,
and removing an active clone switches back to its built-in source.

For a bar widget, on and off means its place in the bar. Everything else is
loaded by default when it is built in, so `shell.json` records only the
deviation: a third-party plugin you added under `plugins[]`, a built-in you
switched off under `disabledPlugins[]`. A full bar has no off state: enabling
one replaces the active bar, and it is therefore never offered under Disable.
Bar widgets may set `barWidget.defaultSection` to `left`, `center`, or `right`;
widgets that omit it default to `center`.

New Git installations default to Ward and reject non-compatible content. `omarchy plugin add <source> --yolo` explicitly chooses **unsandboxed code** inside `omarchy-shell`; `--trusted-local` is limited to existing local Git folders. `--yes` skips confirmation but never selects either mode. YOLO retains the shell's user-level file, process and network access; scoped QML facades are not containment. Existing legacy trusted installs and built-in clones are unchanged. All new plugins land disabled. `--inspect --json` validates without installation; `--commit <sha>` requires the inspected commit at installation.

Host-owned records at `$XDG_STATE_HOME/omarchy/plugin-installations/<id>/record.json` (default `~/.local/state`) bind source, commit and execution mode separately from Ward approval. Same-source updates retain explicit YOLO trust; changed source, identity or missing/corrupt records block managed loading and require explicit removal/reinstallation. Deleting checkout files or editing a manifest cannot change an existing Ward identity into YOLO. Explicit **Remove** ends the installation completely: after stopping the plugin, it deletes its checkout, private saved data, permissions, reviewed snapshots, isolation identity and provenance records. A later installation requires a fresh execution-mode decision and grants. **Disable & revoke permissions** instead keeps the checkout, private saved data and security history. Removal never deletes original source repositories, external symlink targets or host files accessed through grants. Records are traceability, not publisher authentication or a security boundary against the same account. The catalog and CLI list expose `installed` separately from retained records; orphaned or damaged installations remain manageable until explicitly removed. Successful removal leaves no catalog row and clears the manager's selection; the UI does not hide security records to simulate removal.

You can still install by hand: drop a plugin into
`~/.config/omarchy/plugins/<id>/`, run `omarchy-shell shell rescanPlugins`, then
`omarchy plugin enable <id>`. A bar widget starts in its declared default
section; enabling a full bar replaces the one in use. `omarchy bar` drives the
bar from the CLI — `use | reset | defaults | position | transparent | put |
move | set`, with placement flags such as `--section` and `--index`.
The lower-level IPC methods remain available through `omarchy-shell shell ...`.

## Sandboxed plugin development preview

Plugin developers and coding agents should start with the [sandbox authoring reference](sandboxed-plugin-authoring.md), which covers runtime paths, data initialization, the current request schema and worker APIs.

The command-first sandbox prototype uses the existing `omarchy plugin add` / `install` Git checkout workflow. A plugin with a `sandbox` manifest entry is never evaluated by the in-process loader, even if it appears in `shell.json`; missing native support does not downgrade it to trusted QML. This is a greenfield POC: earlier sandbox schema forms are not migrated or accepted through compatibility readers. Existing unpermissioned v1 plugins continue through the separately reviewed, trusted in-process path.

Adding `"sandbox": { "version": 1, "requests": {} }` selects the shared worker runtime, using the plugin's existing `entryPoints`. This initial loader supports one `bar-widget` with an optional own `service` and `overlay`; unsupported or mismatched kinds are rejected during review. It loads the host's packaged `qs.Ui`/`qs.Commons` inside the restricted worker, so plugins need not vendor them. Own-service lookup and own-panel lifecycle are local to that worker, with no host command executor or cross-plugin service access. Detached own-entry settings and theme/style tokens arrive before loading and update live without restarting the plugin. An explicit `settings` request and grant permit saving only the plugin's own inline settings through a bounded host operation; rejected saves restore the latest host values and display an error. This does not grant access to host config files or private font assets; real host bar slots remain unfinished. An explicit sandbox `entryPoint` retains the custom worker-QML path for development fixtures. The shared runtime is staged at `lib/ward-runtime` beside the controller, mounted read-only from a pinned directory descriptor, and required for plugins selecting this loader; a missing runtime fails startup without a fallback.

`omarchy plugin review <id>` snapshots an installed plugin into the private native store and prints its SHA-256 revision and requested permissions. `--json` supplies the same review data for command clients. Review runs no plugin code and grants nothing. `omarchy plugin approve <id> --revision <sha256>` approves that exact snapshot; `--read name`, `--write name`, `--read-setting key`, `--write-setting key`, `--http scope`, `--allow-media`, `--allow-network`, `--allow-notifications`, and `--allow-open-urls` explicitly select permissions, with everything else denied. Filesystem paths, file/directory kinds and the exact MPRIS service are declared by the plugin, not supplied by the approving user. Writable directory requests expose reads and writes to the declared host subtree; revocation cannot undo completed writes. Approval requires terminal confirmation or `--yes`, and it does not start a worker. `omarchy plugin disable <id>` revokes the sandbox record and stops its recorded controller independently of shell IPC.

Named HTTP scopes bind origins, methods, paths, query constraints and optional JSON bodies without opening the worker's network namespace. The generic client does not supply host authentication. Application-specific account providers are excluded from the security core; the earlier account fields and CLI option are rejected. Named `exec` requests instead declare an installed executable and a positive argument tree. `--exec name:leaf` selects one complete invocation branch; additional flags and unselected leaves are denied. The broker binds the executable's reviewed bytes and runs approved invocations in a supervised host job. This carries that CLI's existing account, filesystem and network authority, not only its executable name. Ordinary Quickshell Process and Bash helpers remain sandboxed; `/runtime/bin/omarchy-ward-exec name ...` explicitly forwards literal arguments. GitHub's original helper has passed fake-account integration through real `gh` without worker network or HTTP grants; original graphical and real-desktop acceptance remains separate. See the [grant inventory](../plans/sandboxed-plugin-grants.md).

Requests may be optional or explicitly required: a `true` atomic capability is optional; `{ "required": true }` makes it mandatory for activation. Filesystem requests use objects such as `{ "name": "notes", "path": "$HOME/Notes", "target": "directory", "access": "readwrite", "required": true }`; `target: "file"` selects one exact file instead of a subtree. Use `--read name` only for a `read` declaration and `--write name` only for `readwrite`; approval cannot widen or downgrade the declared access. Paths accept documented host home/XDG root tokens, not shell expansion or regex selection. Media requests declare `{ "service": "org.mpris.MediaPlayer2.Name", "required": false }`. Approval may decline required permissions, but startup reports the missing access instead of granting it. `/run/plugin/grants.json` contains the controller-authored admitted grants for worker introspection, mounted read-only. Filesystem selection is capped at 256 entries and the serialized approval at 64 KiB; long paths can reach the byte limit earlier. Write-only filesystem access remains unsupported.

A `storage` request selected with `--allow-storage` mounts a private per-identity directory at the worker's home. On the host it lives under `$XDG_STATE_HOME/omarchy/plugins/<id>` (defaulting to `~/.local/state/omarchy/plugins/<id>`) with mode 0700. The `storage` grant and `OMARCHY_PLUGIN_DATA` describe the same storage mechanism: the grant authorizes access, while the variable names its host-side location.

| Path available inside the worker | When available | Intended use |
| --- | --- | --- |
| `$HOME` (`/home/plugin`) | Every worker; persistent only when storage is granted, otherwise temporary | Normal plugin file reads and writes, including home-relative XDG state/data paths. This is not the user's real home. |
| `/plugin` | Every worker | Read the approved plugin bundle and its shipped assets, or resolve assets relative to the plugin's QML files. The bundle is read-only. |
| `$OMARCHY_PLUGIN_PATH` | Only when at least one exec grant is admitted | Pass the host-side path of staged assets from the approved revision to an approved host command. It does not point to the editable plugin checkout and is not an always-present bundle path. |
| `$OMARCHY_PLUGIN_DATA` | Only when storage is granted | Pass the host-side path of the same directory mounted at `$HOME` to an approved host command. It is not a second data directory. |

Both `OMARCHY_PLUGIN_*` variables are exposed inside the worker, but their values are host-side paths, not additional mounts accessible to ordinary sandboxed file operations. For example, a plugin writes `$HOME/save.json`; an approved host command refers to that same file as `$OMARCHY_PLUGIN_DATA/save.json`. Use `$HOME` or the plugin's normal home-relative XDG paths for local file access, and `/plugin` or relative QML URLs for shipped assets. Host commands require a separate matching exec grant and are requested explicitly through `/bootstrap --exec name ...`. The broker also resolves `$OMARCHY_PLUGIN_PATH` and `$OMARCHY_PLUGIN_DATA` tokens in exec trees and rejects traversal; knowing a path does not grant execution or host filesystem authority.

Revocation removes storage access but retains saved data. A later ungranted worker gets a temporary home and no `OMARCHY_PLUGIN_DATA` variable, even though the old host directory still exists; regranting storage reconnects that plugin identity to its retained data. Quota/disk-budget enforcement and original pet UI restart acceptance remain unfinished.

Settings requests use `{ "read": ["theme"], "write": ["volume"], "required": false }`. These are exact top-level keys in this plugin's own inline entry, not system-setting names, path patterns or access to other plugins. Read and write selections are independent. Rust filters both initial and live settings snapshots and checks every written key against the admitted write set. Saves merge approved keys into the current host entry, preserving unreadable or unselected values. Each selected key covers its whole JSON value; nested-key selection and system-setting backends are not implemented yet. The reviewer presents separate read/write rows per requested key: required selections are static labeled rows without switches; optional selections have toggles, initially off. There is no all-settings boolean or old-flag adapter.

`omarchy plugin list` distinguishes approved revisions from enabled sessions. `update` changes the checkout, not its approval or grants, and directs the user to re-review; removing the sandbox declaration through an update is refused. `remove` confirms controller shutdown before purging the installation and its saved state, even without a running shell. Cleanup failure is reported and retains denial plus remaining ownership records for retry; an unverifiable controller record is not silently forgotten. Disabling a never-approved plugin is a no-op. Sandbox installation works without shell IPC; `add --enable` leaves it installed but reports that exact-revision approval is required.

After explicit approval, `omarchy plugin enable <id>` asks the existing shell to create a trusted native surface and waits for actual worker content to be presented. The shell imports only its own optional `Omarchy.Ward` module, never plugin QML. A `{ id, sandbox: true }` config entry preserves that boundary across checkout changes and shell restarts. Missing modules, failed admission, and worker startup errors are reported without falling back to the trusted loader. Disable removes the host surface; the command separately revokes native admission.

`omarchy plugin review <id> --ui` opens the first-party reviewer for an installed plugin in the existing shell. The manager also hands staged checkouts to this same reviewer. It calls canonical lifecycle and staging commands with argument vectors. The plugin supplies the parameters. Required permissions are selected in the draft and shown as static rows labeled Required, without switches or activation styling; optional toggles start off and remain independently selectable. These are draft selections, not approval. Permission headings identify the type and required/optional status, never plugin-authored internal grant names. File and directory requests display their declared access and resolved host path; media displays its exact player service. There are no editable resource fields or implicit read-to-write upgrades. Network descriptions distinguish broad host networking, the public-destination proxy and named HTTP scopes. Attached **Command** and **Scope** disclosures expose the complete exec and HTTP constraints. Command shows the executable followed by literal arguments, `[alternative|alternative]` choices and bounded typed/regex arguments, rather than a numbered argument list. Plugin revision metadata is behind **Details** beside the plugin name. Reopening restores the required-on, optional-off draft without changing saved grants. The footer offers only **Deny & Remove** and **Enable**. One Enable click publishes a staged checkout if needed, saves the displayed revision and selected permissions, then enables through the canonical CLI. The UI guards missing required selections, and native activation enforces required grants independently. Deny & Remove discards a staged attempt or revokes admission and removes an installed checkout. Success closes the reviewer; errors keep it open. A running plugin must first be disabled through the manager before its permissions can be changed.

For the shared worker runtime, shell summon/hide/toggle operate on the plugin's own panel, not its persistent bar widget. Bounded, numbered open/close requests travel in the detached UI context; the worker applies each number once and reports its panel state through the authenticated request channel. Focus loss, focused workspace/monitor changes, and host popup switches close the panel while leaving its widget mapped. Only host pointer activation or an explicit host summon can acquire focus and popup ownership; worker-reported state is not authority or startup readiness. Custom worker entry points remain responsible for their own panel lifecycle.

This remains an uninstalled development component. The commands use `$OMARCHY_PATH/lib/omarchy-ward` as the native payload location and the shell launcher adds `$OMARCHY_PATH/lib/qml` to its module path. `OMARCHY_WARD_HOST` can explicitly select a locally built development binary. State defaults to `$XDG_STATE_HOME/omarchy/ward` (or `~/.local/state/omarchy/ward`); `OMARCHY_WARD_STORE` selects an isolated development/test store. CMake supplies staging/install rules, but no default package or setup step installs the payload yet. The initial host uses a non-exclusive, click-through canvas on the first screen; bar placement, service-only readiness, full multi-output policy, and live-desktop acceptance remain unfinished. See [`plans/sandboxed-quickshell.md`](../plans/sandboxed-quickshell.md) for the demo target and remaining gates.

## IPC

The shell exposes a `shell` target (the host also registers
`image-selector`) plus targets registered by individual plugins, named
for the plugin rather than for where it appears: `background`, `osd`,
`media`, `notifications`, and per-widget targets such as `omarchy.clock`
or `omarchy.power`. There is no `bar` target.

| Method                                | Effect                          |
|---------------------------------------|---------------------------------|
| `ping`                                | health check                    |
| `summon <id> <payloadJson>`           | load + open a plugin            |
| `hide <id>`                           | close a previously-summoned     |
| `toggle <id> <payloadJson>`           | summon if closed, hide if open  |
| `togglePanelAt <section> <index>`     | toggle the panel at a bar position |
| `call <id> <method> <arg>`            | call an already-loaded plugin   |
| `rescanPlugins`                       | re-walk plugin dirs and hot-reload plugin code |
| `reloadConfig`                        | reload shell.json               |
| `applyTheme <colorsB64> <shellB64>`   | push theme colors + shell.toml  |
| `toggleBarTransparency`               | flip the bar background between solid and transparent |
| `setPluginEnabled <id> <"true"\|…>`   | flip enabled bit (`ok` / `unknown`) |
| `enablePlugin <id> <placementJson>`   | enable and place in one mutation |
| `putBarWidget <id> <placementJson>`   | place a widget only where absent (`omarchy bar put`) |
| `moveBarWidget <id> <placementJson>`  | move a configured widget        |
| `setBarWidget <id> <key> <valueJson> <selectorJson>` | set an inline widget option |
| `listPlugins`                         | JSON of every discovered plugin |
| `listShellConfig`                     | effective shell.json as JSON    |
| `debugBarGeometry`                    | bar geometry dump for debugging |

`setPluginEnabled` takes a string; only literal `"true"` enables. Methods
answer on stdout with exit 0 — `ok` on success, `unknown` or an error
string on a miss.

## shell.json

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
      "left":   [ { "id": "omarchy.menu" } ],
      "center": [ { "id": "omarchy.clock", "format": "HH:mm" } ],
      "right":  [ { "id": "omarchy.audio" } ]
    }
  },
  "plugins": [
    { "id": "community.weather-extra" }
  ]
}
```

Rules:

1. The active bar option is `bar.id`. Omit it or set it to `omarchy.bar` for
   the built-in bar; set it to a plugin whose manifest declares `kind: "bar"`
   to replace the full bar.
2. Every plugin instance is one entry — `bar.layout.<section>` for
   bar widgets, `plugins[]` for everything else.
3. Settings are inline on the entry. No `config:` sub-object, no
   merge layers.
4. Built-in bar widget ids are namespaced (`omarchy.clock`, `omarchy.audio`, …).
5. Third-party enabled ⇔ present; for full bar options that means `bar.id`.
   First-party non-bar plugins are enabled unless listed in `disabledPlugins[]`.
6. `barWidget.allowMultiple: true` in the manifest permits multiple instances.
7. `idle.screensaver` and `idle.lock` are seconds since user idle began.
8. `version: 1` is required.

`config/omarchy/shell.json` describes the fresh-install state. When no
user `shell.json` exists, defaults are used verbatim. Once the user
customizes, `shell.json` is canonical — there is no deep-merge.

`shell.json` is shell configuration; theme tokens live in `shell.toml`
(next section). Both are current — they answer different questions. A
machine-level `~/.config/omarchy/shell.toml` is watched live by the
shell and its keys win over the active theme's `shell.toml`, so
overrides like `omarchy display text size` survive theme switches.

## Theme tokens

See [`theming.md`](theming.md) for the full theme/template workflow,
including generated `*.tpl` files, gradient helpers, and shell border syntax.

Themes ship colors in `themes/<name>/colors.toml` and surface roles +
sizing in `themes/<name>/shell.toml`. Defaults are generated from
`default/themed/shell.toml.tpl`; a theme may also drop a hand-written
`shell.toml` next to its `colors.toml` to replace the generated file,
or override a single section with `shell.<section>.toml`, merged in by
`omarchy-theme-set-templates` (see [`theming.md`](theming.md)).

`colors.toml` uses `foreground` and `background` for the foundational
text/background palette, exposed to QML as `Color.foreground` and
`Color.background`.

The shell exposes these tokens to QML via three singletons in
`qs.Commons`:

- `Color` — palette (`foreground`, `background`, `accent`, `urgent`)
  and per-surface roles (`Color.bar.*`, `Color.popups.*`,
  `Color.tooltip.*`, `Color.notifications.*`, `Color.menu.*`,
  `Color.polkit.*`, `Color.lock.*`, `Color.imagePicker.*`). Clipboard
  and emojis share `Color.menu.*`; the `[launcher]` section is consumed
  by the launcher outside shell QML.
- `Style` — structural tokens (`cornerRadius`), shared interactive
  state tokens/helpers, spacing (`Style.spacing.*` / `Style.space(px)`),
  the type scale (`Style.font.*`), and bar dimensions
  (`Style.bar.sizeHorizontal` / `Style.bar.sizeVertical`).
- `Border` — border-spec helpers for QML surfaces. Use with
  `BorderSurface` from `qs.Ui` when a border should honor shell theme
  gradients or per-side widths. `Color.<section>.border` is only the
  flat-color fallback for code that cannot render a real border.

### Interactive states

`[controls]` standardizes reusable control chrome (buttons, dropdowns,
tab strips, etc.) around four states: `normal`, `hover-cursor`, `focus`,
and `selected`. State colors and border tokens accept palette roles
(`foreground`, `accent`, `urgent`, `background`) or hex strings; border
values may also be gradients. Fill alpha applies to the state color;
border alpha applies to the state's border token.

Surfaces like `[menu]`, `[launcher]`, and `[image-picker]` define
their own `selected-*` tokens and do **not** inherit from `[controls]`.
`[controls]` only governs the shared button/dropdown chrome.

| State | Color token | Fill alpha | Border token | Border width | Border alpha |
|-------|-------------|------------|--------------|--------------|--------------|
| Normal idle chrome | `normal-color` | `normal-fill-alpha` | `normal-border` | `normal-border-width` | `normal-border-alpha` |
| Hover / keyboard cursor | `hover-cursor-color` | `hover-cursor-fill-alpha` | `hover-cursor-border` | `hover-cursor-border-width` | `hover-cursor-border-alpha` |
| Qt activeFocus | `focus-color` | `focus-fill-alpha` | `focus-border` | `focus-border-width` | `focus-border-alpha` |
| Persistent selected/current | `selected-color` | `selected-fill-alpha` | `selected-border` | `selected-border-width` | `selected-border-alpha` |

The template ships `focus-*` adjacent to `hover-cursor-*` with the same
values so mouse hover, keyboard cursor, and tab focus read identically.
Themes that want focus to stand out override the `focus-*` keys.

Border widths are the theme-level on/off switches for state borders; set
a width to `0` to keep the fill while removing that state border. The
default keeps selected borders off globally (`selected-border-width =
0`); explicitly bordered controls keep their normal border when selected.

```toml
[controls]
# Accent-tinted cursor/focus, foreground-tinted selected state.
hover-cursor-color = "accent"
focus-color        = "accent"
selected-color     = "foreground"
focus-border       = "rgba(33ccffee) rgba(00ff99ee) 45deg"

# Keep selected fills but remove selected-state borders.
selected-border-width = 0
```

Momentary fills use `pressed-fill-alpha` for button press feedback and
`selection-fill-alpha` for text selection. Themes may also provide
`pressed-color` or `selection-color`; they fall back to hover-cursor and
foreground respectively.

The section was previously named `[style]`. Hand-written theme
`shell.toml` files using the old name still apply — the parser accepts
both `[controls]` and `[style]`.

### Spacing

`[spacing] scale` multiplies the shell's shared margins, gaps, padding,
control sizes, and panel dimensions. The default is `1.0`; values above
`1.0` create more breathing room while values below `1.0` make controls
dense. By default `scale-with-font = true`, so increasing `[font]
base-size` also scales buttons, popup widths, row heights, and panel
padding proportionally.

```toml
[spacing]
scale = 1.15
scale-with-font = true  # grow controls and panels with [font] base-size
```

QML components should prefer semantic tokens where possible:

| Token | Default use |
|-------|-------------|
| `Style.spacing.controlPaddingX` / `controlPaddingY` | Button and tooltip padding |
| `Style.spacing.inputPaddingY` | Text-field vertical padding |
| `Style.spacing.controlHeight` / `popupRowHeight` | Dropdown and number-field row heights |
| `Style.spacing.dropdownWidth` / `searchableDropdownWidth` / `numberFieldWidth` | Default field widths |
| `Style.spacing.searchablePopupMinHeight` | Minimum searchable dropdown popup height |
| `Style.spacing.controlGap` | Gap between icon and label inside controls |
| `Style.spacing.labelGap` | Label-to-control and compact list gaps |
| `Style.spacing.rowGap` / `rowPaddingX` | Form rows and list row content |
| `Style.spacing.panelGap` / `panelPadding` | Panel section spacing and interior padding |
| `Style.spacing.popupPadding` | Popout interior padding |

Popout placement deliberately follows Hyprland's `general:gaps_out`
(`Style.gapsOut`) so panels align with tiled windows. Use a theme's
`hyprland.lua` to change that outer alignment; `[spacing]` controls the
interior breathing room.

For one-off proportional constants, use `Style.space(px)` to preserve the
old default at scale `1.0` and `base-size = 12` while still responding to
the theme scale and font scale. Use `Style.spaceReal(px)` only for
fractional geometry that should not be rounded, such as bar widget text
margins. Themes can override any semantic token directly in `[spacing]`,
e.g.:

```toml
[spacing]
scale = 1.0
panel-padding = 22
row-gap = 10
```

### Typography

`[font] base-size` is the rem root for the scale. Every
`Style.font.<token>` derives from it via a fixed multiplier, so
bumping `base-size` rescales the whole shell proportionally:

| Token                 | Multiplier | Default |
|-----------------------|------------|---------|
| `Style.font.caption`      | 0.833 | 10 |
| `Style.font.bodySmall`    | 0.917 | 11 |
| `Style.font.body`         | 1.0   | 12 |
| `Style.font.subtitle`     | 1.083 | 13 |
| `Style.font.title`        | 1.167 | 14 |
| `Style.font.heading`      | 1.333 | 16 |
| `Style.font.display`      | 2.0   | 24 |
| `Style.font.displayLarge` | 2.333 | 28 |
| `Style.font.iconSmall`    | bodySmall | 11 |
| `Style.font.icon`         | title     | 14 |
| `Style.font.iconLarge`    | 1.5       | 18 |

A theme can either scale everything by tweaking `base-size`:

```toml
[font]
base-size = 13   # roomier
```

…or pin individual tokens for stylistic emphasis without affecting
the rest of the scale:

```toml
[font]
base-size = 12
heading       = 20
display-large = 36
```

Recognized override keys: `base-size`, `caption`, `body-small`,
`body`, `subtitle`, `title`, `heading`, `display`, `display-large`,
`icon-small`, `icon`, `icon-large`.

`base-size` has no upper clamp; the shell only floors it at **1px** to
avoid nonsensical zero/negative sizes. Per-token overrides aren't clamped
either. The shell font family is the fontconfig `monospace` alias —
themes don't set it, the user does via `omarchy font set <name>`.

### Bar size

`[bar] size-horizontal` / `size-vertical` set the cross-axis dimension
of top/bottom and left/right bars respectively, measured at the default
12px font base. By default `scale-with-font = true`, so increasing
`[font] base-size` also increases the bar's cross-axis size:

```toml
[bar]
scale-with-font = true
size-horizontal = 26   # top/bottom bar height at base-size 12
size-vertical   = 28   # left/right bar width at base-size 12
```

Set `scale-with-font = false` to keep those bar sizes as fixed pixels.

## Custom bar modules

If a full plugin is overkill, declare a one-off module inline in
`bar.layout.<section>`:

```json
{ "id": "vpn", "type": "command", "exec": "~/.config/omarchy/bar/scripts/vpn-status",
  "interval": 5, "tooltip": "VPN", "onClick": "nm-connection-editor" }
```

Output is plain text or Waybar-style JSON (`{ "text": ..., "tooltip": ..., "class": ... }`).

For a custom QML widget:

```json
{ "id": "gpu", "type": "qml" }
```

Then `~/.config/omarchy/bar/modules/gpu.qml` (or set `source` to point
elsewhere). The module is an `Item` and receives `bar`, `moduleName`,
`settings` properties. `bar` exposes `foreground` / `background` /
`urgent` / `fontFamily` / `position` / `vertical` / `barSize`, plus
`run(cmd)`, `showTooltip(t, s)` / `hideTooltip(t)`,
`requestPopout(o)` / `releasePopout(o)`. To shell-quote arguments for
`run`, use `Util.shellQuote(v)` from `qs.Commons`.
