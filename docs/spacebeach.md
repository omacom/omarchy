# SpaceBeach

SpaceBeach is a first-party Omarchy Shell plugin that turns real desktop state into two related tools:

- **Chronicle** is a local semantic timeline of workspaces and windows with an explicit, non-destructive restore path.
- **Tide Run** is a deterministic tactics game derived from the transitions between those recorded checkpoints.

The plugin deliberately does not describe itself as application-state recovery. Hyprland can tell SpaceBeach where a window was, but it cannot recover browser tabs, editor buffers, terminal processes, unsaved documents, or every compositor layout decision.

## Shape

`shell/plugins/spacebeach/manifest.json` declares one retained service and one retained overlay under the same plugin id, `omarchy.spacebeach`. The shell creates the service at startup and injects it into the overlay's `service` property.

| Part | Responsibility |
|---|---|
| `Service.qml` | Projects Hyprland objects into scalar snapshots, coalesces events, owns consent and persistence, builds restore previews, submits conservative placement requests, and exposes status IPC. |
| `SpaceBeach.qml` | Owns the fullscreen Chronicle and Tide Run experience, keyboard and pointer input, restore confirmation, and real host telemetry shown as world physics. |
| `SpaceBeachModel.js` | Provides pure normalization, hashing, journal, diff, fidelity, restore-plan, and Tide Run rules that also run under Node. |
| `WindowCard.qml` | Renders scalar vessel metadata without retaining compositor objects. |
| `LiveWindowPreview.qml` | Resolves the explicitly selected current lifecycle only while Chronicle's live-pixel preview is visible. |
| `BeachWorld.qml` | Draws the lunar coast procedurally from theme colors and current CPU/memory measurements. |

The service never retains a `HyprlandToplevel`, `HyprlandEvent`, or Wayland object. It copies their supported fields synchronously and replaces its QML `var` properties with immutable scalar trees. An address is resolved back to a live object only at the moment a user explicitly focuses or restores that window.

## Checkpoints

A normalized checkpoint contains:

- capture time and a coarse semantic reason;
- compositor session id, SpaceBeach observation epoch, and focused window address;
- window address, observed lifecycle token, application id, workspace, monitor, geometry, and a small set of compositor state flags.

Window titles are added only to the current in-memory presentation snapshot. They are removed before a snapshot enters the journal, a lighthouse, a diff, a Tide Run, or the persistent file. Command lines, environment variables, keystrokes, pixels, document contents, and network activity are never part of the schema.

Hyprland emits semantic events for many desktop changes but not every pixel move or resize. Raw events therefore request one coalesced refresh, while a low-rate adaptive timer detects geometry changes. The timer runs every 2.5 seconds while SpaceBeach is visible and every 15 seconds while recording in the background. Consecutive checkpoints with the same semantic hash are discarded.

## Consent and retention

SpaceBeach does not create a state directory on first run. The first overlay open asks the user to choose a mode:

| Mode | Journal | Disk behavior |
|---|---|---|
| Off | No new checkpoints; an existing bounded journal remains available while paused | First-run Off writes nothing. After a durable opt-in, pausing retains the existing bounded file; pausing a session tide retains it only in memory. |
| Session | Bounded in-memory journal | Removes a previous durable SpaceBeach file and writes nothing new. |
| Up to 24 hours | At most 360 changed checkpoints from the last 24 hours | Continuously records across shell restarts until paused and writes versioned JSON atomically to `$XDG_STATE_HOME/omarchy/spacebeach/state-v1.json`, with a `0700` directory and `0600` file. A failed durable write visibly falls back to session-only mode. |

The user can erase checkpoints and lighthouses independently of pausing. Erase clears memory immediately, serializes removal behind any in-flight atomic save, and reports completion only after the local file is removed. Expiry pruning runs even when no new desktop change arrives, so the rolling journal cannot silently outlive the stated window. Lighthouses are explicit saves rather than rolling history: up to 24 title-free scenes persist until erased after a durable opt-in; otherwise they remain only for the current shell session.

## Restore safety

`buildRestorePlan()` separates historical windows into four fidelity classes:

- `exact` means a non-unknown application id, address, and lifecycle token all still match inside the same uninterrupted SpaceBeach observation epoch and compositor session;
- `layout-only` means a similar live application window exists but identity and contents cannot be proven;
- `launch-only` means only a known application identity remains;
- `lost` means there is no recoverable live identity.

Only changed, dispatcher-supported fields on `exact` matches become executable placement attempts. Tiled geometry, monitor placement, fullscreen, pinned, and floating-state differences remain inert layout-only suggestions; launch-only or lost matches remain unresolved records. The plan explicitly forbids closing extra windows, launching applications, and executing commands.

The overlay shows this plan before enabling confirmation. The service then captures the desktop again and rejects the plan if its current-state hash changed while the preview was open. It revalidates identity, creates an in-memory rollback checkpoint only when at least one action is accepted, and submits workspace or floating-geometry requests. Quickshell dispatch does not acknowledge compositor completion, so the UI reports attempts rather than claiming a window moved. Floating position and size are best-effort; tiling placement remains under the compositor's current layout algorithm.

Hyprland addresses are lifetime-volatile and may be recycled. The service assigns a new scalar lifecycle token whenever it observes an address disappear, reappear, or change application identity, and it rotates the entire observation epoch after any interval where recording and the overlay were both off. A checkpoint from another observer epoch, an earlier compositor session, or an older address lifecycle can therefore never produce an exact action. SpaceBeach intentionally does not use titles, loose application matches, or regular expressions as mutation selectors.

## Tide Run

Tide Run consumes the same sanitized journal as Chronicle. A run uses the newest playable contiguous segment from one uninterrupted observation epoch; checkpoints across a recording gap or shell/compositor restart are excluded from its fleet, seed, provenance, and waves because SpaceBeach cannot truthfully infer what happened between them.

- a closed window becomes undertow;
- a workspace or monitor move becomes a crosscurrent;
- a compositor-state change becomes a squall;
- a new window becomes an arrival;
- a focus change becomes a beacon.

The initial fleet comes from the first checkpoint in the selected journal tail, including the valid case where an empty shore receives its first vessel in an arrival wave. Anchor, Drift, Repair, and Scan have fixed costs and rules. Scan reveals otherwise hidden future event data; an intervention is locked until the player meets the wave or cancels it, and an unpaid cancelled Scan withdraws its preview. The run seed is a hash of the source checkpoint hashes, and the rules use no random source or wall clock. The same journal and actions therefore produce the same byte-for-byte run state and score.

If the journal has fewer than two changed checkpoints or contains no playable transition, the model returns an explicit invalid run. The UI asks the user to create real desktop history instead of generating tutorial activity and labeling it as theirs.

## Resource boundaries

- Global CPU, memory, and load come from `omarchy-system-stats --bar-widget` every two seconds only while the overlay is visible.
- The static celestial chart is cached; only a bounded ocean layer repaints at 15 frames per second, and it stops when hidden or when reduced motion is enabled.
- Only the focused workspace island animates.
- Historical checkpoints never create screencopy streams. A single current selected window can show live pixels after the user presses `V`; hiding or closing the overlay destroys that active capture.
- The journal and lighthouse counts are hard-capped before persistence.

## Verification

`test/shell.d/spacebeach-model-test.sh` exercises the pure model under Node, including malformed input, privacy projection, stable hashing, bounded retention, all fidelity classes, restore policy, and deterministic gameplay. The general plugin contract test validates the manifest and entry points.

The graphical acceptance scenario in `test/acceptance.d/shell-surfaces-test.sh` chooses session-only consent in a disposable VM, opens Chronicle, enters Tide Run, captures both surfaces, and verifies Escape dismissal. Follow `agents/skills/visual-verification.md` for manual visual checks and `agents/skills/acceptance-tests.md` for the disposable-VM suite.
