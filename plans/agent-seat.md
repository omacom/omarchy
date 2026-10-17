# Plan: Agent Seat — agents get their own pointer and keyboard, in sandboxed apps, next to yours

Revision 1.

Reference: [`docs/agent-seat.md`](../docs/agent-seat.md) covers how the seat works, the decisions behind it and the problems met building it.

## Problem

Omarchy ships every major coding agent, and agents increasingly need graphical apps: clicking through a web page, filling a form, checking how a UI renders, driving a desktop app that has no CLI. Today there is exactly one way for an agent to do that on Omarchy, and it's the wrong one:

- **Hyprland has one seat.** One pointer, one keyboard focus. An agent that clicks with `ydotool` or types with `wtype` moves the user's cursor and types into whatever the user has focused. The user and the agent can't both work.
- **There is no boundary.** Any process running as the user can reach Hyprland's virtual input, screencopy, the clipboard, window lists and layer-shell overlays (`ecosystem:enforce_permissions` is off), plus `hyprctl` and the keyring. An agent driving a browser that reads a hostile page is one prompt injection away from all of it.
- **Nothing upstream will change this soon.** Real multi-seat in Hyprland is "by design" out of scope (hyprwm/Hyprland#1731, discussion #10336), and the attempts at it stalled. Omarchy discussion #10688 asks for exactly this feature.

## Shape

A seat of the agent's own, made in userspace. Apps an agent needs run sandboxed and connect to a small Wayland proxy, the broker, instead of to Hyprland. The broker passes their windows through untouched, so they are real windows in the user's session, on a workspace of their own (10 by default) with an orange border. It owns their input: the agent gets its own pointer and keyboard through a private control socket, the user's own mouse and keyboard still work on the same windows, and each app's focus follows whoever acted last. It shows the apps only an allowlist of Wayland protocols, so nothing in the sandbox can inject input, capture the screen, list windows or draw overlays.

Agents use it through ordinary commands:

```bash
window=$(omarchy agent seat run chromium https://omarchy.org)
omarchy agent seat screenshot "$window"          # a PNG path to read
omarchy agent seat pointer "$window" click 640 360
omarchy agent seat type "$window" "hello" --key enter
omarchy agent seat stop
```

Python and bash only, no Hyprland plugin and no Hyprland changes. Python and libxkbcommon are already on every install, and so are `bubblewrap` (glycin and webkit2gtk depend on it) and `wayland-protocols`, whose XMLs the broker reads at startup (Hyprland and aquamarine depend on it), in practice; both join the base package list, with a migration, so the seat no longer relies on them arriving as dependencies.

## Rejected approaches

- **Injecting into the user's seat** (`ydotool`, `wtype`, a virtual pointer; `hypruse` does this): the agent and the user fight over one cursor and one focus, and the agent's keys land wherever the user is. It's the problem, not a fix.
- **A second real `wl_seat` in a Hyprland plugin** (`hyprland-computer-use`): only apps that bind every seat get independent input. Chromium, Electron and Kitty bind the first seat and fall back to borrowing focus. Plugins also break on every Hyprland ABI change, and Omarchy ships stock `extra/hyprland`.
- **Multi-seat in Hyprland itself**: out of scope upstream by the maintainer's choice, and Hyprland's contribution policy rules out an AI-written PR.
- **A nested compositor per app** (vimalinx/AgentSeat, a different project despite the name): each app gets independent input inside a compositor of its own, but nothing sandboxes the app, so a hostile page still runs with the user's files, bus and keyring.
- **Cua's Hyprland plugin**: computer use inside the compositor, so it is pinned to the Hyprland build it was compiled against, and the apps it drives run unsandboxed. The seat is the sandboxed complement for untrusted apps, not a replacement for it.
- **A nested Hyprland in a window** (built first as the "agent desk"): it works, but it's a box. Agents can only use apps launched inside it, the user can't use those apps from their own session, and it's a second compositor to theme and keep running.
- **A VM or a VNC/RDP session**: a second desktop to maintain, heavy, and far from the apps and files the agent is working on.

## Design

### The broker: one seat per app, two owners

`bin/omarchy-agent-seat-broker` is a Wayland proxy in pure Python. It parses the protocol XMLs under `/usr/share/wayland*` at startup, so it understands whatever Hyprland speaks without generated code. Every agent app connects to the broker's socket as its only display, and the broker opens one upstream connection to Hyprland per app.

- **Drawing passes through.** Surfaces, buffers and xdg-shell go straight to Hyprland, so agent windows are real windows: tiled, focusable and themed like any other.
- **Each app sees one ordinary seat**, renamed `agent`. That's why apps that only listen to the first seat work. The broker delivers the agent's pointer and keyboard events itself and passes the user's through from Hyprland, moving each app's focus to whoever acted last with the leave and enter events a real seat would send. The user can type into one agent window while the agent types into another.
- **Serials.** Agent events carry serials from `0x40000000` up. Requests that need an input serial (`set_cursor`, popup `grab`, `move`, `resize`, `show_window_menu`) are forwarded only with a recent serial from the user's seat. Popups work without a grab.
- **Window names.** Every toplevel's app id is rewritten to `agent-<n>.<app id>` before the app can set its own, so Hyprland rules can single them out and nothing can pose as a user window.
- **Rendering while hidden.** `xdg_toplevel.configure` always carries `activated` and never `suspended`, together with the Hyprland rule `render_unfocused`, so apps keep drawing on the hidden workspace for the agent to see.

### The allowlist

Agent apps see about 20 globals: compositor, subcompositor, shm, output, seat, data device manager, xdg-shell and dialogs, decorations, viewporter, fractional scale, presentation, fifo, commit timing, content type, alpha modifier, single-pixel buffers and color management. Everything else is hidden, including virtual pointer and keyboard, screencopy and image capture, toplevel export and lists, data-control (clipboard snooping), layer-shell, input method, shortcut inhibitors, global shortcuts, input capture, session lock, gamma and DRM leases. Binding a hidden global by guessing its number disconnects the app.

GPU buffers (`zwp_linux_dmabuf_v1`, `wp_linux_drm_syncobj_manager_v1`) are hidden too. Apps then draw into shared memory the broker can read, which is what makes its screenshots possible, and keeps the GPU out of the sandbox.

### The clipboard is the user's

An app reads the clipboard only while the user's keyboard is in it and the user acted last: the user can paste, but the agent's Ctrl+V gets nothing. The gate is the user's focus, not a paste: a hostile page can read the clipboard as soon as the user clicks or types into its window. An app sets the clipboard, or starts a drag, only from the user's own input serial, so the agent can't overwrite what the user copied. Primary selection and data-control stay hidden.

### Screenshots and coordinates

`omarchy agent seat screenshot` asks the broker, which keeps a duplicate of each app's shm pools and composes the window, its subsurfaces and its popups into a PNG (about 70 ms). It works while the seat's workspace is hidden, and it includes menus that open outside the window, which Hyprland's per-window capture misses. The agent then points in pixels of that screenshot. The broker converts them with the screenshot's origin and scale, then hit-tests surfaces, subsurfaces and popups, respecting input regions.

### Seeing without screenshots

Screenshots work for every app, but an image per step is slow and expensive for an agent, and pixel guessing misses small targets. Most apps already describe themselves to screen readers, so the seat reads that first and keeps screenshots for apps that don't, and for checking how something looks.

- **A private bus per sandbox.** The sandbox supervisor, `bin/omarchy-agent-seat-sandbox`, starts a `dbus-daemon` with a configuration of its own (a `unix:path` socket, no service activation, no abstract socket) and `at-spi2-registryd` on it, outside the sandbox and before bwrap, waits for the registry, then starts the app. Both are the supervisor's children with a clean environment holding only that bus, killed with `--pdeathsig` should the supervisor die, so they end with the sandbox and `stop` reaches them through the supervisor's tree. The socket sits in `$XDG_RUNTIME_DIR/omarchy/agent-seat/sandboxes/<marker>.d/bus/bus`, and only that file is bound into the sandbox, read-only, at `$XDG_RUNTIME_DIR/agent-bus/bus`: the app has no writable host directory there and cannot swap the socket for a link. The app gets it as both `DBUS_SESSION_BUS_ADDRESS` and `AT_SPI_BUS_ADDRESS`, with `GTK_A11Y=atspi`, `NO_AT_BRIDGE=0` and `QT_LINUX_ACCESSIBILITY_ALWAYS_ON=1`. The user's session bus, keyring and portals stay out of reach: names an app asks for that aren't on its own bus fail at once, since nothing is activated. The registry serves the sandboxed app's accessibility traffic from the host as the user, the trust model the broker already has for its display.
- **`omarchy agent seat ui <window>`** reads that tree from the host with libatspi, pointed at the window's bus. The broker's new `state` command gives the app's pid (from `SO_PEERCRED` on its Wayland connection), and the window's sandbox is the one whose supervisor is among that pid's ancestors, so an app cannot point the seat at another sandbox's bus. Extents come in window coordinates and are converted with the window geometry and the origin and scale of the broker's last screenshot, so `ui` positions are the pixels `pointer` takes, fractional scales included. Popups that are windows of their own (GTK 3 menus) are placed where the broker has a popup of their size.
- **Chromium and Electron** publish nothing on the bus by default, `--force-renderer-accessibility` included; with `ACCESSIBILITY_ENABLED=1` in their environment they publish the browser's own UI and the page, but they then keep a full accessibility tree for every page. `omarchy agent seat run --cdp` starts them with `--remote-debugging-port` on a free localhost port, recorded in `<marker>.d/cdp-port` where the sandbox can't write, and `ui` reads `Accessibility.getFullAXTree` and `DOM.getBoxModel` over a small stdlib WebSocket client. CSS pixels are scaled by `devicePixelRatio` against the broker's scale, and the page is placed at the bottom of the window, under any browser chrome.
- **`omarchy agent seat click-ui <window> <name>`** resolves a control by its full name (exact, then case-insensitive, optionally `role:name`; `ui --find` alone also takes a unique substring) and clicks its centre through `omarchy agent seat pointer`, so the broker's focus handling decides what the click does, exactly as for a click by coordinates. A name that only contains the query is listed and refused, and so is a control that `ui` marks covered, where a page says a sticky header or a dialog would take the click. CDP only locates; it never clicks.
- **`omarchy agent seat state [<window>]`** is the broker's view: windows, popups, size, geometry, scale, the screenshot origin, whether the app has drawn, whose input it saw last, and whether the user's keyboard or pointer is in it.

The agent's loop becomes `state`, then `ui` and `click-ui`, then `type`, then `ui` again to verify, with a screenshot only when the app has no tree (Wine, games, canvases) or to confirm something visual.

Limits: the tree is only as good as the app's accessibility. GTK 3, GTK 4 and Qt name most controls; GTK 4 popover contents are reported relative to the popover's surface and can sit a few pixels off. The DevTools route covers the page, not the browser's own toolbar, tabs or bubbles, and elements inside iframes are placed relative to their frame. A DevTools port on localhost is reachable by any local process, including other seat sandboxes, which share the network namespace; abstract Unix sockets are reachable through it too, as before. Against a broker without `state`, `ui` takes a screenshot to learn the scale and assumes the window's corner is the image's.

### Keyboard

The broker compiles Hyprland's own keymap (sent to the user's seat) with libxkbcommon over ctypes, and types text by reverse lookup, so the agent types in the user's layout. `--key` takes combos like `ctrl+l` and `ctrl+shift+t`. Text the layout can't type is refused rather than mangled.

### The sandbox

`bin/omarchy-agent-seat-run` starts each app in bubblewrap: `--unshare-all --share-net --new-session --clearenv`, read-only `/usr`, `/etc` and `/sys`, its own `/proc`, a minimal `/dev` with no uinput and no GPU, a tmpfs `/tmp` (so no X11 sockets), and its own `$XDG_RUNTIME_DIR` holding only the broker socket as `wayland-0`. Its home is `~/.local/state/omarchy/agent-seat/home`, one directory shared by every seat app and kept across app exits and `stop`, so logins and cookies persist until the user deletes it with the seat stopped; the user's fonts, icons and fontconfig are bound in read-only. Its only D-Bus is a private bus of its own (see "Seeing without screenshots"), so no keyring and no portals. A program outside `/usr` gets its own file read-only, and its directory only when that is an app bundle (`lib`, `resources`, `resources.pak` or `AppRun` beside the executable) holding nothing the shares below refuse, so `seat run ~/a.out` or `/tmp/x` doesn't bind all of `$HOME` or `/tmp`.

- **Files** reach the sandbox only when the agent shares them: `--share <path>` read-write, `--share-ro <path>` read-only, each at the same path. The seat adds no prompt of its own; sharing is part of the agent's command, so the agent's own permission rules decide it. Shares that would undo the sandbox are refused before anything starts: `/`, `$HOME` or `/tmp` as a whole, `$XDG_RUNTIME_DIR` and `/run/user` (Hyprland, D-Bus, the keyring), `/tmp/.X11-unix`, `/proc`, `/dev`, any directory holding one of those, and anything inside `~/.config`, `~/.ssh`, `~/.gnupg` or `~/.local/share/keyrings`, at their own paths and, when they are links, at their targets.
- **The network** is the host's (`--share-net`), so an agent app reaches the internet and every service listening on the host's localhost. `pasta` (package `passt`) could give it the internet without the host's loopback; it isn't in Omarchy's package set, so for now this is documented rather than closed.
- **The GPU** stays out: no `/dev/dri`, no GPU buffers. Apps draw in software, which covers browsers, Electron and toolkit apps; game engines and Vulkan apps don't run on the seat yet (see Rollout).
- **Stopping** (`omarchy agent seat stop`, or _Trigger > Agents > Stop Agent Seat_, which the menu shows while the seat runs) ends the broker and every process in every sandbox. Each sandbox keeps a lifecycle record with process start times, so a recycled pid is never killed.

### Where it lives

- `default/hypr/agent-seat.lua`: class `agent-[0-9]+(\..*)?` gets `render_unfocused`, `no_initial_focus`, `no_dim`, `pin = false` and a 3px orange border, and opens silently on the seat's workspace. `windows.lua` loads it after every app rule, and the markings match on an `agent-seat` tag so they also win Hyprland's second pass over tag rules: an agent app picks its own title, and the picture-in-picture rule (pinned, borderless) or the "is sharing" rule (special workspace) must not apply to it.
- `default/hypr/agent-workspaces.lua` decides that workspace: 10 by default, changed with `require("default.hypr.agent-workspaces").set({ seat = 8 })` in the user's `hyprland.lua` (the template there shows how). For people who give each monitor its own bank of workspaces, `per_monitor = 10` gives every monitor its own (10, 20, ...), counted from the left or in the order `monitors` lists. The placement is a named window rule rewritten whenever the focused monitor changes, so a new agent window opens on the seat workspace of the monitor the user is on, with no flash on the wrong one.
- `Super + Ctrl + Alt + A` jumps to the seat's newest window, wherever its workspace is. _Trigger > Agents > Agent Seat_ does the same, and is always in the menu: when nothing is on the seat, it first opens the default browser there (`omarchy agent seat show --start`), resolved as `omarchy-launch-browser` resolves it but sandboxed on the seat.
- Commands under `omarchy agent seat`: `run`, `windows`, `state`, `ui`, `click-ui`, `pointer`, `type`, `screenshot`, `show`, `status` and `stop`, with the broker and the sandbox supervisor hidden. `GROUP_DESCRIPTIONS[agent]` mentions the seat.
- `default/agents/skills/omarchy/agent-seat.md` teaches agents to use the seat and never the user's desktop, and when to hand over to the user (logins, captchas, two-factor).
- `manual/17-ai.md` has a section for users.

### Security

The trust boundary is the sandbox plus the allowlist, and the seat is honest about what it covers:

- **Agent input reaches only agent apps.** The control socket is `0600` and checks the peer's uid with `SO_PEERCRED`. Every action names an agent window, and the broker only delivers events to its own apps.
- **Agent apps reach only what the allowlist allows.** No input injection, screen capture, window lists, overlays or clipboard snooping, and a guessed global disconnects them.
- **The sandbox holds the rest back**: no user files unless shared, no keyring, no D-Bus but its own private bus, no GPU, and no other processes.
- **What it doesn't cover:** the network. Agent apps share the host's, so a hostile page can reach local databases, dev servers and browser debugging ports, and a debugging port an agent app opens (`--cdp` opens one) is reachable from the whole machine.
- **Nor** the clipboard once the user takes over: an agent app reads it while the user's keyboard is in it and the user acted last, so a hostile page sees it as soon as the user clicks in.
- **Nor** the agent process itself, which runs as the user. The seat keeps the apps it drives in a box; it doesn't box the agent. That's the agent harness's job, through its own permission rules.
- **Nor** a kernel escape. The box is bubblewrap (namespaces), not a VM: apps share the user's kernel.

### Tests

`test/shell.d/agent-seat-test.sh` runs the broker against a fake compositor and fake apps speaking the wire format. It covers the private control socket, the allowlist and the disconnect on a hidden bind, the renamed seat and the user's keymap, window naming, the user's keys and the agent's reaching the same app with focus correct, the clipboard (the user pastes and copies, the agent can't read or set it), bad keys refused, screenshots composing subsurfaces and popups, file sharing, and stop ending every sandboxed process without touching a recycled pid. `test/shell.d/agent-seat-sandbox-test.sh` launches a headless probe through the real launcher and checks from inside that the home, the user's runtime directory, X11, Hyprland, D-Bus and the keyring are out of reach, that private shares are refused and scratch shares work, that a program outside `/usr` gets only its file unless it is a bundle, and that launches find their windows one at a time. `test/shell.d/agent-seat-rules-test.sh` plays Hyprland's rule passes over the real rules for agent windows with hostile titles. `test/shell.d/agent-seat-ui-test.sh` checks the private bus, reads a real GTK window's accessibility tree and clicks it by name when a compositor is available, and reads a page through a fake DevTools endpoint. `test/shell.d/agent-workspaces-test.sh` checks the seat's workspace, per monitor.

## Rollout

1. **This PR.** The broker, the commands, the sandbox, the window rule, the menu entries, the binding, the skill topic, the manual section and the tests. The only migration installs `bubblewrap` where it is missing; the seat starts on first use, and its rule ships under `default/`.
2. **GPU access, behind the user's consent.** An agent asks per launch, the user answers in their own menu (once, for the session, or deny), and an allowed app gets the GPU devices and a broker socket of its own that also offers GPU buffers, with screenshots from Hyprland's toplevel capture. Built and in use on the author's machine; left out here to keep the first review to the core.
3. **Driving the user's own windows**, under a policy the user sets: typing into or capturing a window that is not on the seat, without moving the user's pointer or focus. Also built separately; it needs its own review because its policy is a guard rail, not a sandbox.
4. **Later:** a visible agent cursor while the seat's workspace is shown, and connecting upstream through `wp_security_context_v1` so Hyprland also knows agent apps are sandboxed.

## Open questions

- **Size.** The broker is the bulk of the seat, in one Python file. The screenshot composer and the debug tracing could be split out or trimmed. Is that the right size for Omarchy to own?
- **PIDs across the sandbox.** An app that writes its own pid into a shared file writes a pid from the sandbox's namespace. Unreal's hot-reload tripped on this. Sharing `/proc` would fix it but loosens the sandbox.
- **Unicode typing.** Characters outside the user's layout are refused. An input-method fallback would type anything, but it means advertising one more protocol.
