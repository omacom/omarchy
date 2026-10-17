# The agent seat

The agent seat lets a coding agent use graphical apps on your desktop without using your mouse and keyboard. An app the agent starts with `omarchy agent seat run` opens as an ordinary window in your Hyprland session, on a workspace of its own (10 by default) with an orange outline. The agent clicks, scrolls and types in it with a pointer and keyboard that belong to it alone. Your cursor doesn't move, your focus doesn't change, and you keep working on your own workspaces while it does.

That matters because Hyprland has one seat: one pointer and one keyboard focus. Without the seat, an agent that clicks with `ydotool` or types with `wtype` moves your cursor and types into whatever you have focused, and anything running as you can reach virtual input, screen capture, the clipboard, window lists, `hyprctl` and the keyring. With it, the apps the agent drives run in a bubblewrap sandbox and see only a short allowlist of Wayland protocols, so nothing in them can reach your keyring, screen or other windows, or your clipboard unless you are the one working in them. They are still real windows: you can step into one with your own mouse and keyboard, to log in or solve a captcha, while the agent carries on in another. And agents read these apps by name, through their accessibility tree, taking a screenshot only when an app has no tree or something has to be checked by eye.

The user-facing description is in the manual (`manual/17-ai.md`, "The agent seat"), the agent-facing one in the Omarchy skill (`default/agents/skills/omarchy/agent-seat.md`), and the design record in `plans/agent-seat.md`. This document explains how it is built, why, and what it doesn't do.

## How it works

```
 agent (Claude Code, Codex, ...)                   you
   │ omarchy agent seat run/pointer/type/ui/...      │ mouse and keyboard
   ▼                                                 ▼
 control socket ───► omarchy-agent-seat-broker ◄───► Hyprland (your session)
 (0600, uid checked)    │  one connection to Hyprland per app,
                        │  the allowlist, input from both owners
                        │  wayland-0: the only display an app sees
            ┌───────────┴────────────┐
            ▼                        ▼
 ┌──────────────────────┐ ┌──────────────────────┐
 │ bubblewrap sandbox   │ │ bubblewrap sandbox   │
 │ chromium             │ │ nautilus             │
 │ + its private D-Bus  │ │ + its private D-Bus  │
 └──────────────────────┘ └──────────────────────┘
```

### The broker is a Wayland proxy

`bin/omarchy-agent-seat-broker` is a Wayland proxy in pure Python (the standard library, plus libxkbcommon over ctypes). At startup it parses the protocol XMLs under `/usr/share/wayland` and `/usr/share/wayland-protocols` (the second from `wayland-protocols`, which the base package list names for this), so it decodes whatever Hyprland speaks without generated code. Every sandboxed app connects to the broker's socket as its only display, and the broker opens one connection to Hyprland per app.

Drawing passes through untouched: surfaces, buffers and xdg-shell go straight to Hyprland, so agent windows tile, float, focus and take the theme like any other. The broker rewrites one thing on the way: every toplevel's app id becomes `agent-<n>.<app id>`, set before the app can set its own, so Hyprland's rules can single agent windows out and no agent app can pose as one of yours.

### One seat per app, with two owners

Each app sees one ordinary `wl_seat`, renamed `agent`. Because each app sees exactly one seat, apps that only ever bind the first seat (Chromium, Electron, Kitty) work like any other. That seat has two owners:

- **The agent.** The broker delivers the agent's pointer and keyboard events itself, from commands on its control socket. The socket is `0600`, checks the caller's uid with `SO_PEERCRED`, and every action names an agent window, so agent input can reach nothing but agent apps.
- **You.** Hyprland's events for your own mouse and keyboard on that window come down the app's upstream connection, and the broker passes them through.

The broker moves each app's focus to whoever acted last, with the leave and enter events a real seat would send. You can type into one agent window while the agent types into another. In the same window, the last one to act has it.

Agent events carry serials from `0x40000000` up, apart from Hyprland's. Requests that need an input serial (`set_cursor`, popup `grab`, `move`, `resize`, `show_window_menu`, setting the clipboard, starting a drag) are forwarded only with a recent serial from your own input to that same app. Popups work without a grab, so the agent loses nothing by it.

Agent windows always look focused: the broker adds `activated` to every `xdg_toplevel.configure` and drops `suspended`, and the Hyprland rule `render_unfocused` keeps frames coming, so apps keep drawing while the seat's workspace is out of sight.

### The allowlist

Agent apps see 20 globals: `wl_compositor`, `wl_subcompositor`, `wl_shm`, `wl_output`, `wl_seat`, `wl_data_device_manager`, `xdg_wm_base`, `xdg_wm_dialog_v1`, `zxdg_output_manager_v1`, `zxdg_decoration_manager_v1`, `org_kde_kwin_server_decoration_manager`, `wp_viewporter`, `wp_fractional_scale_manager_v1`, `wp_presentation`, `wp_single_pixel_buffer_manager_v1`, `wp_fifo_manager_v1`, `wp_commit_timing_manager_v1`, `wp_content_type_manager_v1`, `wp_alpha_modifier_v1` and `wp_color_manager_v1`. Each is offered no newer than the version the broker's XML knows.

Everything else is hidden: virtual pointer and keyboard, screencopy and image capture, toplevel export and toplevel lists, data-control, primary selection, layer-shell, input method, shortcut inhibitors, global shortcuts, input capture, session lock, gamma, DRM leases, and GPU buffers (`zwp_linux_dmabuf_v1`, `wp_linux_drm_syncobj_manager_v1`). An app that binds a hidden global by guessing its number is disconnected.

### Screenshots and coordinates

With GPU buffers hidden, apps draw into shared memory. The broker keeps a descriptor for each app's shm pools and, on `omarchy agent seat screenshot`, composes the window, its subsurfaces and its popups into a PNG itself, in about 70 ms. It works while the seat's workspace is hidden and includes menus that open outside the window. The agent then points in pixels of that screenshot; the broker converts them with the screenshot's origin and scale and hit-tests surfaces, subsurfaces and popups, respecting input regions.

### Keyboard

The broker compiles the keymap Hyprland sends to your seat with libxkbcommon and types text by reverse lookup, so the agent types in your layout. `--key` takes combos like `ctrl+l` and `ctrl+shift+t`. Text the layout can't produce is refused rather than mangled.

### The sandbox

`bin/omarchy-agent-seat-run` starts each app under `bin/omarchy-agent-seat-sandbox`, a supervisor around `bwrap --die-with-parent`:

- `--unshare-all --share-net --new-session --clearenv`
- read-only `/usr`, `/etc` and `/sys`; its own `/proc`; a minimal `/dev` with no uinput and no GPU; a tmpfs `/tmp`, so no X11 sockets
- its own `$XDG_RUNTIME_DIR`, holding only the broker socket as `wayland-0` and the socket of its private bus, read-only
- the seat's home at `~/.local/state/omarchy/agent-seat/home`, separate from yours: one directory shared by every agent app and kept when apps exit and across `stop`, with your fonts, icons and fontconfig read-only
- a program installed outside `/usr` gets its own file read-only, and its directory only when that is an app bundle (`lib`, `resources`, `resources.pak` or `AppRun` beside the executable)
- your files only through `--share <path>` (read-write) and `--share-ro <path>` (read-only), each at the same path inside

Shares and programs that would undo the sandbox are refused before anything starts: `/`, `$HOME` or `/tmp` as a whole, `$XDG_RUNTIME_DIR` and `/run/user`, `/tmp/.X11-unix`, `/proc`, `/dev`, any directory holding one of those, and anything inside `~/.config`, `~/.ssh`, `~/.gnupg` or `~/.local/share/keyrings`, at their own paths and, when they are links, at their targets.

The supervisor writes a lifecycle record with its own and bwrap's pids and start times. `omarchy agent seat stop` ends the broker, then kills every supervisor whose pid, start time and command line still match its record; `--die-with-parent` takes the whole sandbox with it. A recycled pid is never killed.

### The rules

`default/hypr/agent-seat.lua` matches the class `agent-[0-9]+(\..*)?`, tags those windows `agent-seat`, and gives the tag `render_unfocused`, `no_initial_focus`, `no_dim`, `pin = false` and a 3 px orange border. `windows.lua` requires it after every app rule. `default/hypr/agent-workspaces.lua` places agent windows silently on the seat's workspace through a named window rule it rewrites whenever the focused monitor changes, so with one workspace per monitor a new agent window opens on the monitor you are on.

### The semantic layer

Wayland carries pixels, not widgets: the broker knows windows, popups, subsurfaces, geometry, scale, focus and input regions, but not buttons or text. Most apps describe their controls to screen readers, so the seat reads that first.

- **A private bus per sandbox.** The supervisor starts a `dbus-daemon` with a configuration of its own (a path socket, no service activation, no abstract socket) and `at-spi2-registryd` on it, outside the sandbox and before bwrap, as children of its own with nothing of your session in their environment. The app gets only the socket file, bound read-only at `$XDG_RUNTIME_DIR/agent-bus/bus`, as its session and accessibility bus, with accessibility switched on for GTK and Qt; it has no directory to write in and no way to swap the socket for a link. Your session bus, keyring and portals stay out of reach, and the daemons end with the sandbox. The registry serves the sandboxed app's accessibility traffic from the host, as the broker serves its display: the same trust model.
- **`omarchy agent seat ui <window>`** reads that tree from the host with libatspi and prints one control per line: role, name, value, states and its centre in screenshot pixels. The broker's `state` command gives the app's pid from `SO_PEERCRED`, and the window's sandbox is the one whose supervisor is among that pid's ancestors, so an app can't point the seat at another sandbox's bus. The socket is opened once, following no link, checked to be a socket of yours, and connected to through `/proc/self/fd`, so nothing swapped in afterwards redirects the reader. Controls are clipped by every scroll pane, viewport, list, table and column header above them, and each is placed at the centre of the part that shows.
- **Chromium and Electron** launched with `run --cdp` get `--remote-debugging-port` on a free localhost port, recorded where the sandbox can't write. `ui` then reads `Accessibility.getFullAXTree` and `DOM.getBoxModel` over a small standard-library WebSocket client. The DevTools route reads the page a seat window shows: a page whose own title matches the window's and whose `document.visibilityState` is "visible", the active tab of its window. If several qualify, their browser window's size (`Browser.getWindowForTarget`) is compared with the seat window's. If that still leaves several, `ui` lists them numbered, sorted by DevTools target id, and exits 1; it never falls back to the first page. `--page <N|url-substring>` on `ui` and `click-ui` picks one from that list and is honoured with a single candidate too. A selector matching none or several candidates, or a number outside the list, is an error.
- **`omarchy agent seat click-ui <window> <name>`** resolves a control by its full name (exact, then case-insensitive, optionally `role:name`) and clicks its centre with the agent's own pointer. A name that only contains the query ("Delete" in "Delete account and data") is never clicked: those controls are listed and the command exits 1, to be rerun with the full name; `ui --find` alone still reads by substring. In a page, `ui --find` asks DevTools what is at the control's centre and marks it covered when a sticky header or a dialog would take the click; `click-ui` refuses a covered control. DevTools only locates; it never clicks.
- **`omarchy agent seat state [<window>]`** is the broker's view: popups, size, geometry, scale, whether the app has drawn, and whose input it saw last.

An agent's loop is `state`, then `ui` and `click-ui`, then `type`, then `ui` again to verify, with a screenshot when the app has no tree (Wine, games, canvases) or to confirm something visual.

## Decisions and why

### A userspace proxy, not a Hyprland plugin or a Hyprland patch

Real multi-seat is out of scope in Hyprland by the maintainer's choice: one seat "by design" (hyprwm/Hyprland#1731, discussion #10336), and a contributor's logical-seat branch stalled. Hyprland's contribution policy (`hyprwm/.github/policies/AI_USAGE.md`) also rules out AI-written pull requests, which this is. A plugin avoids the review but not the cost: plugins are compiled against one Hyprland build and break on its ABI changes, and Omarchy ships stock `extra/hyprland`. Hyprland's own permission system gates screencopy, plugins and keyboard capture, and its wiki leaves the rest to the application sandbox. A proxy in userspace needs none of that: it speaks the same protocol every app speaks, and it updates with Omarchy, not with Hyprland.

### One seat per app, so first-seat-only apps work

A second `wl_seat`, from a plugin, gives independent input only to apps that bind every seat. Chromium, Electron and Kitty bind the first one and fall back to borrowing your focus. Giving each app its own proxied connection, with exactly one seat that both owners share, makes every app multi-seat without its knowing.

### Real windows in your session, not a nested compositor

The first version was a nested Hyprland running as one window on workspace 10, with its own seat: the "agent desk". It worked, but it was a box. Agents could only use apps launched inside it, you couldn't use those apps from your own session, its file pickers still opened on your desktop, and it was a second compositor to theme and keep running. vimalinx/AgentSeat takes the nested route per app, with a Cage instance for each; that isolates input and focus but sandboxes nothing. Proxying lets each app be a real window of yours, with a sandbox around it.

### Shared input, not a lockout

The desk ignored your input unless you took control, and the first seat did the same with a take-control toggle. In practice you want to act in an agent's window while it works in another: a login, a captcha, a quick correction. So the toggle went, and the broker mediates focus per app between the two owners instead.

### GPU buffers hidden, so the broker composes screenshots

Hyprland's per-window capture covers the window's box, and Chromium's menus open outside it, so screenshots missed exactly what an agent needs to see after opening a menu. Hiding `zwp_linux_dmabuf_v1` and the sync object protocol makes apps fall back to shared memory, which the broker can read and compose itself, popups included, while the workspace is hidden. The same choice keeps the GPU out of the sandbox entirely. The cost is that apps that can't draw in software (most game engines and Vulkan apps) don't run on the seat yet; GPU access behind a per-launch consent prompt is a follow-up.

### The clipboard is yours

An app reads the clipboard only while your keyboard is in it and you acted last, so the agent's Ctrl+V gets nothing. It sets the clipboard, or starts a drag, only with a serial from your own input to that app, so the agent can't overwrite what you copied. Those serials are kept per app: Hyprland's serials are sequential, so one seen by another app would be easy to guess. Data-control and primary selection stay hidden. The gate is your focus, not a paste: a hostile page can read the clipboard once you click into its window, which the manual says plainly.

### Files are shared by the agent's own command

There is no seat-level prompt for files. Sharing is a flag on the agent's `run` command, so the agent harness's own permission rules decide it, the same as for any file the agent touches directly. A second prompt from the seat would only duplicate the harness's decision. What the seat does refuse, whatever the agent is allowed, is a known list of shares that would void the sandbox or plant code you later run outside it: the root, your home, runtime and bus sockets, your config, keys, shell startup files, `~/.local/bin`, desktop entries and the agents' own homes, plus write access to the top-level `.git` of a shared repository (so the app can't commit there either). That list is a backstop, not a guarantee: a repository nested deeper in a share keeps a writable `.git`, and anything else in a share that you or an agent later runs (a build script, a `Makefile`, hooks kept in the work tree) is the app's to change.

### A configurable workspace, one per monitor if you want

Workspace 10 is a default, not a rule. `require("default.hypr.agent-workspaces").set({ seat = 8 })` moves it. People who give each monitor its own bank of workspaces (1–10 on one, 11–20 on the next) can set `per_monitor = 10`, and each monitor gets its own seat workspace, counted from the left or in the order `monitors` lists, so an agent app opens next to where you are working.

### Semantic observation first, screenshots as the fallback

A screenshot per step is slow and expensive for a model, and guessing pixels misses small targets. GTK, Qt, Chromium and Electron already describe their controls by name, so the seat reads those first. Screenshots stay: they are the only observation that works for every app (Wine, games, canvases), and the way to check how something looks.

### Titles are left alone; the rules re-assert the markings last

App ids are rewritten, so class rules can always find agent windows. Titles are the app's own, and some of Omarchy's rules match on title: the picture-in-picture rule pins and strips the border from a window titled "Picture-in-Picture", and the "is sharing" rule moves a window to a special workspace. Rather than rewrite titles, the agent rules load after every app rule and match on a tag of their own, so they win both of Hyprland's rule passes. Floating stays allowed, since picture-in-picture floats legitimately.

### `--share-net`, with the localhost exposure documented

Agent apps share your network namespace, so besides the internet they reach every service listening on your localhost, and a debugging port they open is reachable from your whole machine. `pasta` (package `passt`) could give them the internet without your loopback, but it isn't in Omarchy's package set. For now the exposure is documented in the manual, the skill and the plan rather than closed.

## Problems met and how they were solved

**Hyprland dropped connections the broker had touched.** Wayland object ids a client creates must be allocated in sequence, and the server rejects one that skips ahead. An id taken early, for an object created later, breaks the sequence. The broker now creates nothing of its own in an app's id space: it names a window by sending the app's own `get_toplevel` and then `set_app_id` on that same id, in line. It is also why the broker can't draw a cursor into an app's surfaces.

**`xdg_surface` decoded with the wrong requests.** The unstable xdg-shell v5 XML defines its own `xdg_surface` under the same name as the stable one. The broker loads unstable protocols first, then staging, then stable, so the stable definition wins.

**Descriptors past libwayland's limit.** libwayland reads at most 28 descriptors per `recvmsg`, and the kernel closes any beyond that. The broker sends whole messages with their descriptors and never more than 28 per `sendmsg`.

**`^agent-[0-9]+` matched nothing.** Hyprland rule regexes match the whole string, so the class `agent-1.foot` needs `agent-[0-9]+(\..*)?`.

**Apps stopped drawing on the hidden workspace.** A window on a workspace nobody is looking at gets no frame callbacks and may be told it is suspended. The broker always reports `activated` and never `suspended`, and the rule `render_unfocused` keeps frames coming.

**A page titled "Picture-in-Picture" could pin itself over your workspace.** `apps/pip.lua` loaded after the agent rule and matched on title, so a hostile page could get a pinned, borderless window. The agent rules moved to `default/hypr/agent-seat.lua`, loaded last from `windows.lua`, with the markings on an `agent-seat` tag: when a window's tags change Hyprland re-applies only the tag rules, in order, so a marking matched on class alone would still lose that second pass. `test/shell.d/agent-seat-rules-test.sh` plays both passes over hostile titles.

**The keybindings menu could run out of memory.** The menu scans your Hyprland config with a stand-in `hl` whose every field and call returns itself, and `ipairs(hl.get_monitors())` walks that stand-in forever. With `per_monitor` set, `agent-workspaces.lua` did exactly that. It now counts monitors with `#`, which sees the stand-in as empty, and `agent-workspaces-test.sh` runs the menu's own scan over a per-monitor config under a memory cap. The stand-in itself is upstream's to fix.

**Hostile apps could crash or exhaust the broker.** A review found that an app could crash it by hanging up with an event in flight (both channels ready in one wakeup dropped the client twice) or by shrinking a shared memory pool under a screenshot (SIGBUS); could fill its descriptor table (an unbounded descriptor queue, then `accept` spinning on `EMFILE`); and could make it buffer without limit by never reading. Now dropping a client is idempotent; screenshots read pools with `pread` bounded by `fstat`; more than 28 descriptors at once, or 112 unclaimed, drops the app; each app may hold 256 pools; each connection may keep 4,096 live objects (sync callbacks aside, which Hyprland frees at once), a sandbox 16,384 and the seat 40,960, and the rectangles of an app's regions, counting those its surfaces keep as input regions after the region is gone, are capped at 4,096 per app and 16,384 per sandbox; `accept` pauses for a second when out of descriptors; reading one side stops at 256 KiB queued for the other and the app is dropped at 16 MiB; screenshots are clamped to what the window draws and refused past 8192 px a side; control requests are capped at 1 MiB and 5 s, and `hyprctl` runs as a job killed at 5 s. Each has a test in `agent-seat-test.sh` that fails on the old code.

**A program or share could void the sandbox.** `--share` was appended last, so its mode won, and a program outside `/usr` got its whole directory bound: `seat run ~/a.out` handed over all of `$HOME`, and `/tmp/x` handed over the host's `/tmp`, X11 socket included. Shares and programs are now checked against the refusal list above, a program gets only its own file, and only a recognisable app bundle gets its directory.

**The ChatGPT desktop app needed its directory.** An Electron app installed as `~/.local/opt/chatgpt` with a launcher in `~/.local/bin` can't start from its executable alone. The bundle test (`lib`, `resources`, `resources.pak` or `AppRun` beside it, not a `bin` directory) lets it keep its directory without letting `~/.local/bin` qualify.

**Two launches could swap windows.** `run` finds its window as the one missing from the list taken before launch, and two launches at once could each take the other's. The launch lock is now held until the window appears or the wait times out; `stop` never takes it.

**`pointer move` always failed.** `do_move` returned the client object, which the control reply tried to merge into a mapping, so the command exited 1; `focus` had the same bug. Both return nothing now, and pointer tests cover the path that had none: moving over a subsurface, clicking in a popup, dragging, scrolling, and pointing outside an input region.

**Chromium published nothing on the accessibility bus.** Chromium and Electron publish no AT-SPI tree by default, `--force-renderer-accessibility` included. With `ACCESSIBILITY_ENABLED=1` they publish the browser's UI and the page, but keep a full tree for every page, which is slow on heavy ones. The seat reads them through DevTools instead, with `run --cdp`, and documents the environment variable for when the toolbar or tabs matter.

**DevTools titles didn't match window titles.** DevTools reports page titles HTML-escaped, so a page titled `Fun & games` showed up as `Fun &amp; games`, and matching a tab by window title failed on any `&`, `<`, `>` or quote: with several tabs the wrong one could be read, and without a pid none was. `ui` unescapes DevTools titles before comparing them.

**GTK 4 popovers read a few pixels off.** GTK 4 reports popover contents relative to the popover's own surface, about 13 px off at scale 1.5. Clicks on them still land, so this is documented as a limit rather than corrected.

**The sandbox probe couldn't run anything.** bubblewrap starts with an empty root, and x86_64 executables look for their loader under `/lib64`. Both the sandbox and the tests' `bwrap_works` probe link `/lib64` to `usr/lib`, and the probe makes sandbox checks skip, rather than fail, where unprivileged user namespaces are off.

**A second review found three more.** `run` returned the first new window anywhere on the seat, so a dialog another seat app opened during a launch could be handed back in its place; it now accepts a window only when the broker's pid for it descends from that launch's sandbox supervisor. The broker passed `wp_viewport.set_source` through without keeping it, so screenshots drew a surface's whole buffer where the app showed a crop; it now draws only the crop, and a window's scale comes from that crop. `windows` piped the broker's reply into `jq`, which succeeds on empty input, so a broker that was down or refused left it printing nothing and exiting 0; with `pipefail` the broker's failure is now the command's.

**A third review found ten more.** In the broker: a message cut short after its descriptors kept them open when the app was dropped, so the broker now takes a message's descriptors before decoding it, closes them when it is malformed and drops only that app. `wl_region.subtract` never reached the broker's copy of an input region, so the agent clicked where the user's pointer falls through a hole; regions are now rectangles added and cut out in order. `place_above` and `place_below` were ignored, so overlapping subsurfaces showed and took clicks in creation order; each surface now keeps its stack, a subsurface below its parent included. `set_buffer_transform` was ignored, so a window drawn for a rotated output came out sideways and at the wrong size; screenshots and sizes now follow the transform. Single-pixel buffers were left out of screenshots, so a solid background stretched by a viewport went missing; they are drawn, with alpha. Synchronized subsurfaces showed their new frame before their parent committed, so the agent saw and clicked a frame the user could not; their buffer, scale, transform, viewport and input region are now held until the parent's commit, as in wlroots. In the launcher: an app with a writable share could swap an approved path for a link between the check and bwrap's mount, so shares and programs outside `/usr` are now opened right after the check and mounted by descriptor (`--bind-fd`, `--ro-bind-fd`), and only directories and regular files can be shared. In `ui`: a control scrolled partly out of view was clicked at the centre of its whole box, beside what shows, so it now gets the centre of the shown part, and slivers under 4 px are left out. Two same-title, same-size windows of one GTK or Qt app were read in the app's order; the one holding the seat's keyboard focus now wins, and otherwise `ui` refuses with a numbered list that `--page` picks from. A browser page was placed at the bottom of its window, which a side panel or docked DevTools makes wrong; `ui` now checks that the page spans the window's width and that no docked DevTools covers more of it, and when either fails it marks the controls unverified and `click-ui` refuses them. Fixing these turned up two more: descriptors the agent's shell left open reached the app, so the launcher and the supervisor close every descriptor bwrap does not need, and an app could make a surface a subsurface of its own subsurface, which now drops the app.

**A fourth review found thirteen more.** In the broker: a pointer or keyboard enter, and the modifiers Hyprland sends with every enter, counted as you acting, so focus following the mouse across an agent window let an app read and replace your clipboard; only a key or a button counts now, while enter and modifier serials still move the cursor and start grabs. Screenshots were composed inside the event loop, blending a byte at a time, so a large translucent window stalled every seat app for seconds and an app could make its window larger with a small viewport over a large buffer; they are composed on a thread, at most two at once and 10 s each, blending whole rows, and are capped at 4096 px a side and 4 px per surface unit. A subsurface's position and stacking were applied as soon as the app asked rather than with its parent's commit, so the agent could see and click a layout you never saw; they are now the parent's pending state. A subsurface that never had a buffer still caught clicks and was drawn; unmapped surfaces and their subtrees are skipped. The pool limit was per connection and connections were unlimited, so an app could hold descriptors without bound by opening connections; connections are now grouped by the sandbox their process runs under, found through the supervisor's record, with 16 connections and 256 pools per sandbox and 64 and 640 for the whole seat. A screenshot read the app's shared memory as it was at that moment, so an app could draw something else right after committing and show the agent a frame you never saw; for two seconds after a screenshot each commit keeps a copy of its pixels, at most 64 MiB per app, and screenshots draw those. In the launcher: the seat's home sat under `~/.local/share/omarchy`, which the upgrade to Omarchy 4 replaces with a link to the read-only tree, so `mkdir` failed, the launch went on and timed out 15 s later; it lives under `~/.local/state/omarchy` now, a launch that can't make it stops at once and says why, and a home made at the old place, when it is a real directory, moves over once. The refusal list left out what you or an agent later run unsandboxed: shell startup files, `~/.gitconfig`, `~/.local/bin`, desktop entries, user units, mise, the agents' own homes and Omarchy's state are refused now, and a read-write share with a `.git` at its top keeps that `.git` read-only, so the app can edit the work tree but neither plant a hook nor commit. The private bus directory was bound read-write into the sandbox with its daemons inside, so an app could swap a link over the socket that the seat's reader would follow to your own bus, and fill your runtime tmpfs; the supervisor now runs `dbus-daemon` and `at-spi2-registryd` outside, as its children, and the sandbox gets the socket file alone, read-only, which left `omarchy-agent-seat-init` nothing to do, so it is gone. In `ui`: the bus socket was checked by path and connected to by path, so an app could swap in a link between the two; it is opened once without following links, checked to be your socket, and connected to through `/proc/self/fd`. A page whose title check timed out was dropped as if hidden, so with two same-title windows the other window's page could be read and clicked; it stays a candidate and is listed as unanswering. `click-ui` clicked a unique substring, so "Delete" clicked "Delete account and data"; it now asks `ui` for an exact name and refuses a name that only contains the query, listing those controls. Controls were clipped only to the window or the page's viewport, so one scrolled out of a scroll pane or under a table's header was listed and clicked where another control sits; they are clipped by every scroll pane, viewport, list, table and column header above them, in a page by every ancestor whose overflow is not visible, and `ui --find` asks the page what is at the centre and marks the control covered when a sticky header or a dialog is, which `click-ui` refuses.

**A fifth review found a screenshot that could exhaust the broker.** A buffer's needed pixels were read as one span from the first to the last, padded to that width: an app can declare a buffer fifty million pixels wide over a pool it never fills (a sparse file costs it nothing), shrink it through a viewport and turn it, and a small screenshot then allocated 200 MiB for each row. Reads now cover runs of needed pixels and gaps of at most 256 between them, on both the turned and the straight path, so a row costs no more than the screenshot's width. The suite declares such a buffer and checks the broker's peak memory. The same review caught a local name in `ui` that shadowed the window-size comparison, so two matching trees from a broker without pids crashed instead of being told apart.

**A sixth review found the user's click landing under the agent's pointer.** After the agent pointed elsewhere in the surface the user's pointer was in, the app held the agent's position, and Hyprland sends no motion with a button or a scroll, so a user who clicked without moving acted where the agent pointed last. The broker now records where the app believes each pointer is and, before a user's button or axis event, sends a motion to the user's coordinates when they differ, in a frame of its own.

**A seventh review found drags losing their surface.** An agent drag hit-tested every step, so one crossing into a subsurface sent a leave to the surface that took the press and the release to the other; text selection and sliders spanning surfaces stopped early. The pressed surface now holds the pointer until the release, each step in its coordinates past its edges and its input region, as a compositor's implicit grab does, and the next move hit-tests again. The same review found `ui` dividing a page's `devicePixelRatio` by the last screenshot's scale, so a browser window moved to a monitor of another scale had its page marked narrower than the window and its controls refused; CSS pixels now go through the window's current scale, then the screenshot's. Two earlier notes went in with it: `set_window_geometry` is pending until the surface's commit, like the rest of its state, and `show --start` finds the browser's desktop entry over `XDG_DATA_HOME` and `XDG_DATA_DIRS`, as `omarchy-cmd-default-browser` does.

**An eighth review found screenshots ignoring a surface's opacity.** `wp_alpha_modifier_v1` is on the allowlist, but screenshots drew a faded surface's original pixels, so the agent saw what the user did not. The multiplier is now surface state, pending until the commit and held by a synchronized subsurface until its parent's, reset when the modifier is destroyed, and screenshots fade each layer by it before blending, one multiply per row; a buffer without alpha becomes translucent, and a factor of zero leaves the layer out while clicks still reach it. The same review found `show --start` launching only the first word of the browser's `Exec` line, so an entry such as `env FLAG=1 chromium %U` started `env` and nothing opened; the line is now split as the Desktop Entry specification says, field codes dropped, and a command that comes out empty or starts with a dash is refused.

**A ninth review found regions that could exhaust the broker.** Since the third review a `wl_region` kept every add and subtract as a list, so holes hit-tested right, and the list had no limit: an app repeating one rectangle could grow the broker until it died and took every seat app with it. A region is now the disjoint rectangles its requests leave, an add cutting itself out of the others and a subtract only cutting, which answers every hit test as the old scan did; a region may hold 1,024 rectangles and an app 4,096, past which the app is dropped as for pools. The same review found the broker's keyboard enter on the user's behalf carrying no held keys, so a key held while stepping into an agent window stopped repeating; the user's held keys are kept from Hyprland's enter and key events and sent with that enter.

**A tenth review found three more.** An app could create objects without limit and the broker kept state for each; a connection may now keep 4,096 live objects, a sandbox 16,384 and the seat 40,960, checked before the request reaches Hyprland, with sync callbacks left out since the read pauses bound them, and the input regions a surface holds count against the rectangle cap so a destroyed region leaves nothing behind. The launcher checked a share's kind by path and then opened it, so a sandbox with a writable share of the parent could swap in a FIFO in between and the open blocked forever; a regular file is now opened without blocking by a helper that checks what it opened, and the launcher takes that exact file through the helper's descriptor. The menu guard's `status` request had no timeout, so a broker holding its socket open without answering stalled every guard; the request is bounded at two seconds and a timeout counts as a stopped seat.

**An eleventh review found `stop` waiting on a silent broker.** A broker holding its socket open without answering kept `stop` waiting forever with the sandbox lock held, so apps kept running and later launches blocked too, and the launcher's own check of the broker had the same unbounded call. `stop` now gives the broker three seconds, then ends the processes listening on the control socket, found by the socket's inode rather than by name, and goes on to the sandbox cleanup; the launcher bounds its checks so its ten-second deadline fires. The same review found the page-side clip mixing an overflow container's displayed position with its unscaled layout size, so a container enlarged by a CSS transform hid the controls in its second half; the container's client box is scaled into displayed coordinates before clipping, and the suite runs that script in headless Chromium.

**A twelfth review found `run` replacing a live broker.** With its check bounded, a launch over a broker that was alive but silent for three seconds started a second broker over the same sockets, stranding the first one's apps and reusing their window numbers. `run` now starts a broker only when nothing listens on the control socket, and otherwise fails naming `stop`.

## What it does not do

- **One agent lane.** The seat has one agent identity. Several agents can use it at once, but it doesn't tell them apart (see the FAQ).
- **No audio, file pickers, drag-and-drop into agent apps, or clipboard of the agent's own.** Portals aren't reachable from the sandbox. A drop needs your keyboard in the target app, and during a drag it is in the source.
- **No clicks in your own windows.** The agent's input reaches only seat apps.
- **No characters outside your keyboard layout.** They are refused; an input-method fallback would mean advertising one more protocol.
- **No network isolation.** `--share-net` reaches your localhost; a debugging port an agent app opens is reachable from your machine.
- **No clipboard protection once you step in.** An app reads your clipboard while your keyboard is in it and you acted last.
- **No VM.** bubblewrap is namespaces: the apps share your kernel.
- **No box around the agent.** The agent runs as you, under its harness's permission rules. The seat boxes the apps it drives.
- **No GPU.** Apps draw in software.
- **No sockets or FIFOs as shares.** Only directories and regular files can be shared, since each share is opened and mounted by descriptor.
- **No named clicks in a browser window with a side panel or docked DevTools.** `ui` still lists the page, marked unverified, but can't place it, so `click-ui` refuses; use coordinates from a screenshot.
- **No named clicks on a covered control.** In a page, a control under a sticky header or a dialog is marked covered and `click-ui` refuses it; scroll it clear or dismiss what covers it first. Over AT-SPI, nothing says what is on top, so such a click lands on whatever covers the control.
- **Slow screenshots of rotated buffers.** A buffer with a transform is read a pixel at a time rather than a row at a time.

## Other approaches

- **ydotool or wtype**: inject into your own seat (uinput, a virtual keyboard), so the agent moves your cursor and types where you are focused.
- **hypruse**: shares your seat with a virtual pointer, `wtype` and `hyprctl` cursor moves; adds AT-SPI targeting and an MCP server. Its README says the seat is shared.
- **Cua's Hyprland plugin** (proposed for Omarchy in #11342): second real seats inside the compositor, built against one Hyprland build; its own documentation says background input for Chromium, Electron and XWayland is unqualified and that it is not a sandbox. The seat is a sandboxed complement for untrusted apps and pages, not a replacement.
- **SamSaffron/hyprland-computer-use**: a plugin that adds a second `wl_seat`; apps that bind only the first seat fall back to borrowing focus.
- **vimalinx/AgentSeat** (a different project despite the name): a nested Cage compositor per app with its own pointer and keyboard; isolates input and focus, not files, processes or network.
- **Agent Desktops** (#10594): a separate desktops app for agents, proposed as an Omarchy pull request.
- **A VM or a VNC/RDP session**: real isolation, but a second desktop to maintain, heavy, and far from your files and apps.

## FAQ

**Does it need a Hyprland plugin?** No. It is a Wayland client to Hyprland like any app, plus window rules in Omarchy's Lua config.

**Will it survive Hyprland updates?** It depends on the Wayland protocols, not on Hyprland's ABI. It reads the protocol XMLs at startup and offers apps no protocol version newer than those, so a newer Hyprland only means apps see the versions the broker understands.

**Can the agent read my clipboard?** No. An app reads it only while your keyboard is in it and you acted last, and sets it only from your own input. Once you click into an agent app, though, a page in it can read what you copied.

**Can I use the agent's browser myself?** Yes. Jump there with `Super + Ctrl + Alt + A` or _Trigger > Agents > Agent Seat_ and use it with your own mouse and keyboard. The menu row also opens your default browser on the seat when nothing is on it.

**Why are logins my job?** Agent apps never see your own browser profile, so a site starts logged out until someone signs in to it on the seat, and passwords, captchas and two-factor prompts need your hands. The skill tells agents to hand those to you on the seat. Don't take over an agent app with a secret on your clipboard.

**Do agent apps keep their logins?** Yes. Every agent app shares one home, `~/.local/state/omarchy/agent-seat/home`, and it keeps cookies, logins and settings when the apps exit and across `omarchy agent seat stop`, so a site you signed in to on the seat stays signed in for the next agent app, and a browser may offer to restore the pages of its last run. Anything an agent runs on the seat can read that home, so sign in there only to accounts you are willing to hand to agents. To start over, run `omarchy agent seat stop` and delete `~/.local/state/omarchy/agent-seat/home`; the next launch starts with an empty one.

**What about the GPU?** Agent apps get none and draw in software. GPU access behind a per-launch consent prompt is planned as a follow-up.

**Can two agents share it?** They can use it at the same time, but the seat doesn't tell them apart: any process of yours can call the control socket, window numbers are shared, and launches take turns. Two agents in different windows work, since each app has its own focus. Two in the same window fight over it, last actor wins.

**Why Python?** It is on every Omarchy install, the broker needs nothing beyond its standard library and libxkbcommon, and there is no build step or compiled code to keep in step with Hyprland.

**How big is it?** The broker is about 2,100 lines, `ui` about 1,000, and the other commands, the launcher, the supervisor and the two Lua files about 1,000 together. The tests are about 3,200 lines.

**How do I move the workspace?** Add `require("default.hypr.agent-workspaces").set({ seat = 8 })` to `~/.config/hypr/hyprland.lua`, or `set({ per_monitor = 10 })` for one per monitor. It applies to apps that open afterwards.

**How do I stop everything?** `omarchy agent seat stop`, or _Trigger > Agents > Stop Agent Seat_. It ends the broker and every process in every sandbox.

**What happens if the broker dies?** Agent apps lose their display, and most exit with it; their sandboxes end when they do. Anything in a sandbox that doesn't need the display keeps running until `omarchy agent seat stop`, which works from the lifecycle records without a broker. The next `run` starts a new broker over the old sockets and launches its app only once that broker answers, so the app never gets the dead broker's socket; if no broker answers within 10 seconds, `run` fails and points at `broker.log`. A broker that is alive but does not answer within three seconds is never replaced: `run` fails and names `omarchy agent seat stop`, which ends it and its apps, so running apps keep their broker and their window numbers.

**How do I test it?** See below. Sandbox checks skip where bubblewrap can't make a sandbox, and the GTK check skips without a compositor.

**What is planned next?** GPU access behind a consent prompt; driving your own windows under a policy you set, without moving your pointer or focus (built, and in need of its own review); a visible agent cursor while the seat's workspace is shown; and connecting to Hyprland through `wp_security_context_v1`, so Hyprland itself knows agent apps are sandboxed.

## Testing

Run each suite with `OMARCHY_PATH` set to the checkout:

- [`test/shell.d/agent-seat-test.sh`](../test/shell.d/agent-seat-test.sh): the broker against a fake compositor and fake apps on the wire format. The control socket, the allowlist and the disconnect on a hidden bind, version caps, the renamed seat and your keymap, window naming, your keys and the agent's in one app, the clipboard both ways, pointer over subsurfaces, popups and input regions, screenshot composition on its thread and the commit it shows, subsurface stacking and unmapped subsurfaces, hostile apps (descriptor floods, apps that never read, pools shrunk mid-screenshot, connections past the sandbox's and the seat's caps, a region flooded with requests), the clipboard opened by keys and buttons but not by focus, held keys carried by the user's enter, the user's click under the user's pointer, drags held on the pressed surface, window geometry pending until commit, sandbox lifecycle and stale records, and restarting over a dead broker.
- [`test/shell.d/agent-seat-sandbox-test.sh`](../test/shell.d/agent-seat-sandbox-test.sh): real bubblewrap launches probed from inside: no home, X11, Hyprland, D-Bus or keyring; the private bus run outside with only its socket inside; the seat's home made under Omarchy's state, moved from the old place, and a launch that fails when it can't be made; refused and accepted shares, startup files and a shared repository's read-only `.git` included; linked private directories; programs outside `/usr` and app bundles; launches finding their windows one at a time; launches over a dead broker's sockets.
- [`test/shell.d/agent-seat-ui-test.sh`](../test/shell.d/agent-seat-ui-test.sh): the private bus and its isolation, the socket opened by descriptor and a link swapped over it refused, a real GTK window read and clicked by name, controls clipped by scroll panes and headers, exact names for `click-ui`, and the DevTools route against a fake endpoint, escaped titles, unanswering pages, overflow clipping and covered controls included.
- [`test/shell.d/agent-seat-show-test.sh`](../test/shell.d/agent-seat-show-test.sh): `show --start` finding the default browser's desktop entry over the XDG data directories, with every command stubbed.
- [`test/shell.d/agent-seat-status-test.sh`](../test/shell.d/agent-seat-status-test.sh): `status` against no broker and against a socket that accepts and never answers.
- [`test/shell.d/agent-seat-rules-test.sh`](../test/shell.d/agent-seat-rules-test.sh): Hyprland's two rule passes over the real rules, for agent windows with hostile titles.
- [`test/shell.d/agent-workspaces-test.sh`](../test/shell.d/agent-workspaces-test.sh): the seat's workspace, moved and per monitor, and the keybindings menu's scan over a per-monitor config.
