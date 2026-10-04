# Bar space during shell recovery

The built-in bar keeps its screen space when plugins reload or the main shell stops. An independent Quickshell configuration at `shell/bar-reservation/` owns the layer-shell exclusive zones. The interactive bar uses `ExclusionMode.Ignore`, so it occupies that same strip without reserving it a second time.

The reservation process loads no plugins, authentication services, or main-shell singletons. Its surfaces sit on the bottom layer, accept no pointer or keyboard input, and are transparent during normal operation. During an outage they use the last bar colors and show a short status message. Fullscreen windows can cover them normally; session-lock surfaces remain above them.

![The bar space remains reserved while the shell restarts.](images/bar-recovery.png)

## Lifetime and state

`omarchy-launch-shell` starts one reservation host per configuration and Wayland display with `quickshell -d -n`. A socket under `XDG_RUNTIME_DIR`, named using a hash of the display name, connects the two processes. The socket is private to the user's runtime directory; this is coordination between processes belonging to the same user, not a security boundary against that user.

The main shell sends bounded, versioned JSON containing only screen names, edge, thickness, visibility, readiness, and opaque foreground/background colors. Incomplete and oversized frames and invalid fields are rejected. The receiver retains detached scalar values, accepts one active owner, and never evaluates code or starts commands supplied through the protocol. Loading a new bar does not clear the previous snapshot.

The host retains the last reservation when the connection closes. If a replacement shell sends an unsupported snapshot, the host releases that ownerless reservation before disconnecting it, so the replacement can safely reserve its own space. Rejecting a second client while an owner is still connected never releases the owner's reservation. A launcher UUID survives Quickshell’s crash-handler re-exec, allowing the replacement to take over from its own inherited socket while a core-dump child still holds it open. A different launcher cannot take over a live reservation. A deliberate restart announces “Shell restarting…”, including when requested outside the desktop’s environment. The restart command resolves the selected Hyprland instance to its Wayland display, and scopes both notification and shell shutdown to that display; an explicit stale instance fails without touching another session. The existing launcher reports “Shell crashed — restarting…” when it retries an abnormal exit, and “Shell stopped — restart required” when its retry budget is exhausted. A clean stop without a restart request shows “Shell unavailable”. These messages describe observed lifecycle events; there is no speculative crash diagnosis.

The launcher requires a successful `ping` response before passing the reservation socket to the main shell; a successful daemon launch alone does not prove that the host's QML loaded. Without a configured socket, the built-in bar maps immediately and owns its own zone. With one, it waits for the initial snapshot acknowledgement and initial widget loading, with a two-second fallback, before mapping. If the reservation process disconnects, the bar resumes owning its own zone. A transport connection alone never relinquishes that fallback reservation: the client waits for the host to acknowledge its snapshot. Reconnection uses a fresh socket for compatibility with Quickshell 0.3.1 and backs off from one second to at most thirty seconds after failed attempts. An accepted snapshot resets that delay, and configuration changes shorten it so corrected settings recover promptly. A failure of the reservation host must not prevent launching or restarting the main shell.

## Configuration and monitors

The main shell supplies the actual bar thickness, including theme changes and sizes above 256 pixels, and updates all connected screen names. The protocol accepts the same nonnegative signed 32-bit sizes as the native bar and exclusive-zone properties. Each reservation surface is tied to its `QuickshellScreen`, so unplugging a screen removes that surface. A newly connected screen receives a reservation once the main shell publishes it. A returning screen with a previously known name can retain its last reservation while the main shell is down.

Hidden bars reserve no space. While the shell is ready, its current hidden-state snapshot takes precedence over the host’s flag cache, so a missed directory event cannot override a successful `syncHidden`. During outages the host watches and rechecks the existing `bar-off` flag once per second, so the user can release the space while the main shell is unavailable. Moving the bar to another edge is an intentional layout change. Shell recovery at that edge preserves the resulting layout.

Full replacement bars from third-party plugins continue to own their existing exclusive zones; selecting one releases the built-in reservation. Arbitrary third-party surfaces cannot be moved between processes without changing their plugin contract. This change protects the built-in bar and its hosted widgets, not every possible replacement bar implementation.

## Limits

A second Qt Quick process has a resource cost. The accelerated QA VM measured approximately 80 MiB proportional resident memory for this process after repeated restarts; that figure depends on Qt, the graphics driver, and monitor configuration.

The reservation host itself still depends on the compositor and Qt. Losing that host or the entire compositor can cause a layout change. Its job is to survive failure or restart of the much larger process that loads plugins. It does not add a new restart policy for the main shell, override intentional stops, or restart a healthy lock client.

The reservation host stays running across main-shell restarts; changes to its QML take effect at the next session start. During development, stop its specific configuration in the disposable VM before restarting the main shell. Do not restart every Quickshell process indiscriminately.

## Verification

`test/shell.d/bar-reservation-test.sh` covers the state protocol and bounded frame assembly. `test/shell.d/bar-reservation-lifecycle-test.sh` runs the actual host and client QML with isolated homes and runtime directories on Qt's offscreen platform. It checks unset sockets, acknowledgement before handoff, missed hidden-flag events, large bars, display isolation, duplicate ownership, re-exec while an inherited socket remains open, invalid replacements after restart, rejection backoff, corrected settings, and hosts that return after a failed connection. Only the host's layer-shell surface is replaced for this test; compositor geometry is checked in the VM. The launcher and restart tests cover readiness failures, recovery messages, abnormal exits, retry limits, session environment, duplicate main-shell instances, and lock preservation.

Run `test/acceptance.d/bar-reservation-test.sh` in a disposable Omarchy VM. It opens a real tiled terminal, samples its position and size and the compositor's reservations throughout deliberate outages, restarts, `SIGKILL`, and `SIGSEGV`. A changed PID or layer-surface address proves that recovery completed; Quickshell re-execs in the same PID after `SIGSEGV`. It exercises all four edges, repeated restarts, hidden, transparent and 300-pixel bars, and host reconnection; saves the samples as JSON, captures screenshots, and restores configuration and the test window on exit. This graphical test is excluded from `test/all`.
